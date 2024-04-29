--------------------------------------------------------
--  DDL for Package Body IGS_EN_CPD_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_CPD_EXT_PKG" AS
/* $Header: IGSEI50B.pls 115.5 2003/06/11 06:37:05 rnirwani ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_en_cpd_ext_all%ROWTYPE;
  new_references igs_en_cpd_ext_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_igs_en_cpd_ext_id                 IN     NUMBER      ,
    x_enrolment_cat                     IN     VARCHAR2    ,
    x_enr_method_type                   IN     VARCHAR2    ,
    x_s_student_comm_type               IN     VARCHAR2    ,
    x_step_order_num                    IN     NUMBER      ,
    x_s_enrolment_step_type             IN     VARCHAR2    ,
    x_notification_flag                 IN     VARCHAR2    ,
    x_s_rule_call_cd                    IN     VARCHAR2    ,
    x_rul_sequence_number               IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_STUD_AUDIT_LIM                    IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-JUN-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_CPD_EXT_ALL
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
    new_references.igs_en_cpd_ext_id                 := x_igs_en_cpd_ext_id;
    new_references.enrolment_cat                     := x_enrolment_cat;
    new_references.enr_method_type                   := x_enr_method_type;
    new_references.s_student_comm_type               := x_s_student_comm_type;
    new_references.step_order_num                    := x_step_order_num;
    new_references.s_enrolment_step_type             := x_s_enrolment_step_type;
    new_references.notification_flag                 := x_notification_flag;
    new_references.s_rule_call_cd                    := x_s_rule_call_cd;
    new_references.rul_sequence_number               := x_rul_sequence_number;
    new_references.stud_audit_lim                    := x_stud_audit_lim;

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


  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-JUN-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.enrolment_cat,
           new_references.enr_method_type,
           new_references.org_id,
           new_references.s_enrolment_step_type,
           new_references.s_student_comm_type
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-JUN-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.enrolment_cat = new_references.enrolment_cat)) OR
        ((new_references.enrolment_cat IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_enrolment_cat_pkg.get_pk_for_validation (
                new_references.enrolment_cat
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.enr_method_type = new_references.enr_method_type)) OR
        ((new_references.enr_method_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_method_type_pkg.get_pk_for_validation (
                new_references.enr_method_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.s_rule_call_cd = new_references.s_rule_call_cd)) OR
        ((new_references.s_rule_call_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ru_call_pkg.get_pk_for_validation (
                new_references.s_rule_call_cd
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.rul_sequence_number = new_references.rul_sequence_number)) OR
        ((new_references.rul_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ru_rule_pkg.get_pk_for_validation (
                new_references.rul_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

--*****
    IF (((old_references.s_student_comm_type =
           new_references.s_student_comm_type)) OR
        ((new_references.s_student_comm_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_LOOKUPS_VIEW_Pkg.Get_PK_For_Validation ('VS_EN_COMMENCE',
         new_references.s_student_comm_type) THEN
         Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
         Igs_Ge_Msg_Stack.Add;
         App_Exception.Raise_Exception;
      END IF;
    END IF;


    IF (((old_references.s_enrolment_step_type =
           new_references.s_enrolment_step_type)) OR
        ((new_references.s_enrolment_step_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_LOOKUPS_VIEW_Pkg.Get_PK_For_Validation ('ENROLMENT_STEP_TYPE_EXT',
         new_references.s_enrolment_step_type) THEN
         Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
         Igs_Ge_Msg_Stack.Add;
         App_Exception.Raise_Exception;
      END IF;
    END IF;
--*****

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_igs_en_cpd_ext_id                 IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-JUN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_cpd_ext_all
      WHERE    igs_en_cpd_ext_id = x_igs_en_cpd_ext_id
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
    x_enrolment_cat                     IN     VARCHAR2,
    x_enr_method_type                   IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_s_enrolment_step_type             IN     VARCHAR2,
    x_s_student_comm_type               IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-JUN-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_cpd_ext
      WHERE    enrolment_cat = x_enrolment_cat
      AND      enr_method_type = x_enr_method_type
      AND      s_enrolment_step_type = x_s_enrolment_step_type
      AND      s_student_comm_type = x_s_student_comm_type
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (true);
        ELSE
       CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_uk_for_validation ;


  PROCEDURE get_fk_igs_en_enrolment_cat (
    x_enrolment_cat                     IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-JUN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_cpd_ext_all
      WHERE   ((enrolment_cat = x_enrolment_cat));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_EN_CPDE_EC_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_enrolment_cat;


  PROCEDURE get_fk_igs_en_method_type (
    x_enr_method_type                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-JUN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_cpd_ext_all
      WHERE   ((enr_method_type = x_enr_method_type));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_EN_CPDE_EMT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_method_type;


  PROCEDURE get_fk_igs_ru_call (
    x_s_rule_call_cd                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-JUN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_cpd_ext_all
      WHERE   ((s_rule_call_cd = x_s_rule_call_cd));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_EN_CPDE_SRC_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ru_call;


  PROCEDURE get_fk_igs_ru_rule (
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-JUN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_cpd_ext_all
      WHERE   ((rul_sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_EN_CPDE_RUL_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ru_rule;

--*****


  PROCEDURE get_fk_igs_lookups_view_1 (
    x_s_student_comm_type               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-JUN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_CPD_EXT_ALL
      WHERE     s_student_comm_type = x_s_student_comm_type;
    lv_rowid cur_rowid%RowType;

  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_CPDE_LVAL_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END get_fk_igs_lookups_view_1;


  PROCEDURE get_fk_igs_lookups_view_2 (
    x_s_enrolment_step_type             IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-JUN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_CPD_EXT_ALL
      WHERE    s_enrolment_step_type = x_s_enrolment_step_type;
    lv_rowid cur_rowid%RowType;

  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_CPDE_LVAL_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END get_fk_igs_lookups_view_2;

--*****

   PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_igs_en_cpd_ext_id                 IN     NUMBER      ,
    x_enrolment_cat                     IN     VARCHAR2    ,
    x_enr_method_type                   IN     VARCHAR2    ,
    x_s_student_comm_type               IN     VARCHAR2    ,
    x_step_order_num                    IN     NUMBER      ,
    x_s_enrolment_step_type             IN     VARCHAR2    ,
    x_notification_flag                 IN     VARCHAR2    ,
    x_s_rule_call_cd                    IN     VARCHAR2    ,
    x_rul_sequence_number               IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_STUD_AUDIT_LIM                    IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-JUN-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_igs_en_cpd_ext_id,
      x_enrolment_cat,
      x_enr_method_type,
      x_s_student_comm_type,
      x_step_order_num,
      x_s_enrolment_step_type,
      x_notification_flag,
      x_s_rule_call_cd,
      x_rul_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_stud_audit_lim
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.igs_en_cpd_ext_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.igs_en_cpd_ext_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    END IF;

  END before_dml;

  PROCEDURE AfterStmtInsertUpdateDelete(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
  CURSOR c_cpdext (cp_enr_cat igs_en_cpd_ext_all.enrolment_cat%TYPE,
                    cp_enr_mth igs_en_cpd_ext_all.enr_method_type%TYPE,
                    cp_comm_type igs_en_cpd_ext_all.s_student_comm_type%TYPE,
                    cp_step_type igs_en_cpd_ext_all.s_enrolment_Step_type%TYPE) IS
  SELECT 'x'
  FROM igs_en_cpd_ext
  WHERE enrolment_cat = cp_enr_cat
  AND enr_method_type = cp_enr_mth
  AND s_student_comm_type = cp_comm_type
  AND s_enrolment_Step_type = cp_step_type;

  CURSOR c_catprc (cp_enr_cat igs_en_cpd_ext_all.enrolment_cat%TYPE,
                    cp_enr_mth igs_en_cpd_ext_all.enr_method_type%TYPE,
                    cp_comm_type igs_en_cpd_ext_all.s_student_comm_type%TYPE) IS
  SELECT rowid row_id,
        enrolment_cat,
        s_student_comm_type,
        enr_method_type,
        person_add_allow_ind,
        course_add_allow_ind
   FROM igs_en_cat_prc_dtl
   WHERE enrolment_cat = cp_enr_cat
     AND s_student_comm_type = cp_comm_type
     AND enr_method_type = cp_enr_mth;

  l_step_type igs_en_cpd_ext_all.s_enrolment_Step_type%TYPE;
  l_record_exist varchar2(1);
  l_catprc c_catprc%ROWTYPE;

  BEGIN
	-- If trigger has not been disabled, perform required processing
	IF p_deleting THEN
        IF old_references.s_enrolment_step_type IN ('FMIN_CRDT','FATD_TYPE') THEN

            IF old_references.s_enrolment_step_type = 'FMIN_CRDT' THEN
              l_step_type := 'FATD_TYPE';
            ELSE
              l_step_type := 'FMIN_CRDT';
            END IF;

            OPEN c_cpdext (old_references.enrolment_cat, old_references.enr_method_type, old_references.s_student_comm_type, l_step_type);
            FETCH c_cpdext INTO l_record_exist;
            IF c_cpdext%NOTFOUND THEN

                OPEN c_catprc (old_references.enrolment_cat, old_references.enr_method_type, old_references.s_student_comm_type);
                FETCH c_catprc INTO l_catprc;
                CLOSE c_catprc;

                igs_en_cat_prc_dtl_pkg.update_row (
                  x_mode                              => 'R',
                  x_rowid                             => l_catprc.row_id,
                  x_enrolment_cat                     => l_catprc.enrolment_cat,
                  x_s_student_comm_type               => l_catprc.s_student_comm_type,
                  x_enr_method_type                   => l_catprc.enr_method_type,
                  x_person_add_allow_ind              => l_catprc.person_add_allow_ind,
                  x_course_add_allow_ind              => l_catprc.course_add_allow_ind,
                  x_enforce_date_alias                => NULL,
                  x_config_min_cp_valdn               => NULL
                );

            END IF;
            CLOSE c_cpdext;

        END IF;

	END IF;
  END AfterStmtInsertUpdateDelete;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
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
      AfterStmtInsertUpdateDelete(FALSE,FALSE,TRUE);
    END IF;

  END After_DML;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_igs_en_cpd_ext_id                 IN OUT NOCOPY NUMBER,
    x_enrolment_cat                     IN     VARCHAR2,
    x_enr_method_type                   IN     VARCHAR2,
    x_s_student_comm_type               IN     VARCHAR2,
    x_step_order_num                    IN     NUMBER,
    x_s_enrolment_step_type             IN     VARCHAR2,
    x_notification_flag                 IN     VARCHAR2,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_mode                              IN     VARCHAR2 ,
    x_STUD_AUDIT_LIM                    IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-JUN-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_en_cpd_ext_all
      WHERE    igs_en_cpd_ext_id                 = x_igs_en_cpd_ext_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF (x_last_updated_by IS NULL) THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT    igs_en_cpd_ext_s.NEXTVAL
    INTO      x_igs_en_cpd_ext_id
    FROM      dual;

    new_references.org_id := igs_ge_gen_003.get_org_id;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_igs_en_cpd_ext_id                 => x_igs_en_cpd_ext_id,
      x_enrolment_cat                     => x_enrolment_cat,
      x_enr_method_type                   => x_enr_method_type,
      x_s_student_comm_type               => x_s_student_comm_type,
      x_step_order_num                    => x_step_order_num,
      x_s_enrolment_step_type             => x_s_enrolment_step_type,
      x_notification_flag                 => x_notification_flag,
      x_s_rule_call_cd                    => x_s_rule_call_cd,
      x_rul_sequence_number               => x_rul_sequence_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_stud_audit_lim                    => x_stud_audit_lim
    );

    INSERT INTO igs_en_cpd_ext_all (
      igs_en_cpd_ext_id,
      org_id,
      enrolment_cat,
      enr_method_type,
      s_student_comm_type,
      step_order_num,
      s_enrolment_step_type,
      notification_flag,
      s_rule_call_cd,
      rul_sequence_number,
      stud_audit_lim,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.igs_en_cpd_ext_id,
      new_references.org_id,
      new_references.enrolment_cat,
      new_references.enr_method_type,
      new_references.s_student_comm_type,
      new_references.step_order_num,
      new_references.s_enrolment_step_type,
      new_references.notification_flag,
      new_references.s_rule_call_cd,
      new_references.rul_sequence_number,
      new_references.stud_audit_lim,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

    After_DML(
      p_action => 'INSERT',
      x_rowid => X_ROWID
    );

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_igs_en_cpd_ext_id                 IN     NUMBER,
    x_enrolment_cat                     IN     VARCHAR2,
    x_enr_method_type                   IN     VARCHAR2,
    x_s_student_comm_type               IN     VARCHAR2,
    x_step_order_num                    IN     NUMBER,
    x_s_enrolment_step_type             IN     VARCHAR2,
    x_notification_flag                 IN     VARCHAR2,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_STUD_AUDIT_LIM                    IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-JUN-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        enrolment_cat,
        enr_method_type,
        s_student_comm_type,
        step_order_num,
        s_enrolment_step_type,
        notification_flag,
        s_rule_call_cd,
        rul_sequence_number,
	stud_audit_lim
      FROM  igs_en_cpd_ext_all
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
        (tlinfo.enrolment_cat = x_enrolment_cat)
        AND (tlinfo.enr_method_type = x_enr_method_type)
        AND (tlinfo.s_student_comm_type = x_s_student_comm_type)
        AND (tlinfo.step_order_num = x_step_order_num)
        AND (tlinfo.s_enrolment_step_type = x_s_enrolment_step_type)
        AND (tlinfo.notification_flag = x_notification_flag)
        AND ((tlinfo.s_rule_call_cd = x_s_rule_call_cd) OR ((tlinfo.s_rule_call_cd IS NULL) AND (X_s_rule_call_cd IS NULL)))
        AND ((tlinfo.rul_sequence_number = x_rul_sequence_number) OR ((tlinfo.rul_sequence_number IS NULL) AND (X_rul_sequence_number IS NULL)))
        AND ((tlinfo.stud_audit_lim = x_stud_audit_lim) OR ((tlinfo.stud_audit_lim IS NULL) AND (X_stud_audit_lim IS NULL)))
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
    x_igs_en_cpd_ext_id                 IN     NUMBER,
    x_enrolment_cat                     IN     VARCHAR2,
    x_enr_method_type                   IN     VARCHAR2,
    x_s_student_comm_type               IN     VARCHAR2,
    x_step_order_num                    IN     NUMBER,
    x_s_enrolment_step_type             IN     VARCHAR2,
    x_notification_flag                 IN     VARCHAR2,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_mode                              IN     VARCHAR2 ,
    x_STUD_AUDIT_LIM                    IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-JUN-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

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
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_igs_en_cpd_ext_id                 => x_igs_en_cpd_ext_id,
      x_enrolment_cat                     => x_enrolment_cat,
      x_enr_method_type                   => x_enr_method_type,
      x_s_student_comm_type               => x_s_student_comm_type,
      x_step_order_num                    => x_step_order_num,
      x_s_enrolment_step_type             => x_s_enrolment_step_type,
      x_notification_flag                 => x_notification_flag,
      x_s_rule_call_cd                    => x_s_rule_call_cd,
      x_rul_sequence_number               => x_rul_sequence_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_stud_audit_lim                    => x_stud_audit_lim
    );

    UPDATE igs_en_cpd_ext_all
      SET
        enrolment_cat                     = new_references.enrolment_cat,
        enr_method_type                   = new_references.enr_method_type,
        s_student_comm_type               = new_references.s_student_comm_type,
        step_order_num                    = new_references.step_order_num,
        s_enrolment_step_type             = new_references.s_enrolment_step_type,
        notification_flag                 = new_references.notification_flag,
        s_rule_call_cd                    = new_references.s_rule_call_cd,
        rul_sequence_number               = new_references.rul_sequence_number,
	stud_audit_lim                    = new_references.stud_audit_lim,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    After_DML(
      p_action => 'UPDATE',
      x_rowid => X_ROWID
    );

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_igs_en_cpd_ext_id                 IN OUT NOCOPY NUMBER,
    x_enrolment_cat                     IN     VARCHAR2,
    x_enr_method_type                   IN     VARCHAR2,
    x_s_student_comm_type               IN     VARCHAR2,
    x_step_order_num                    IN     NUMBER,
    x_s_enrolment_step_type             IN     VARCHAR2,
    x_notification_flag                 IN     VARCHAR2,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_mode                              IN     VARCHAR2 ,
    x_STUD_AUDIT_LIM                    IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-JUN-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_en_cpd_ext_all
      WHERE    igs_en_cpd_ext_id                 = x_igs_en_cpd_ext_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_igs_en_cpd_ext_id,
        x_enrolment_cat,
        x_enr_method_type,
        x_s_student_comm_type,
        x_step_order_num,
        x_s_enrolment_step_type,
        x_notification_flag,
        x_s_rule_call_cd,
        x_rul_sequence_number,
        x_mode,
	x_stud_audit_lim
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_igs_en_cpd_ext_id,
      x_enrolment_cat,
      x_enr_method_type,
      x_s_student_comm_type,
      x_step_order_num,
      x_s_enrolment_step_type,
      x_notification_flag,
      x_s_rule_call_cd,
      x_rul_sequence_number,
      x_mode,
      x_stud_audit_lim
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-JUN-2001
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

    DELETE FROM igs_en_cpd_ext_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    After_DML(
      p_action => 'DELETE',
      x_rowid => X_ROWID
    );

  END delete_row;

END igs_en_cpd_ext_pkg;

/
