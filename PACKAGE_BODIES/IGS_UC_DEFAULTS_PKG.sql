--------------------------------------------------------
--  DDL for Package Body IGS_UC_DEFAULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_DEFAULTS_PKG" AS
/* $Header: IGSXI17B.pls 115.15 2003/12/04 11:49:07 rbezawad noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_defaults%ROWTYPE;
  new_references igs_uc_defaults%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_current_inst_code                 IN     VARCHAR2,
    x_ucas_id_format                    IN     VARCHAR2,
    x_test_app_no                       IN     NUMBER  ,
    x_test_choice_no                    IN     NUMBER  ,
    x_test_transaction_type             IN     VARCHAR2,
    x_copy_ucas_id                      IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_decision_make_id                  IN     NUMBER,
    x_decision_reason_id                IN     NUMBER,
    x_obsolete_outcome_status           IN     VARCHAR2,
    x_pending_outcome_status            IN     VARCHAR2,
    x_rejected_outcome_status           IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_ni_number_alt_pers_type           IN     VARCHAR2,
    x_application_type                  IN     VARCHAR2,
    -- smaddali added these cols for ucfd203 - multiple cycles build , bug#2669208
    x_name                              IN     VARCHAR2   ,
    x_description                       IN     VARCHAR2   ,
    x_ucas_security_key                 IN     VARCHAR2   ,
    x_current_cycle                     IN     VARCHAR2   ,
    x_configured_cycle                  IN     VARCHAR2,
    x_prev_inst_left_date               IN     DATE
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali  11-jun-03  removed calendar cols and added new cols for bug#2669208 , ucfd203 build
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_UC_DEFAULTS
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
    new_references.current_inst_code                 := x_current_inst_code;
    new_references.ucas_id_format                    := x_ucas_id_format;
    new_references.test_app_no                       := x_test_app_no;
    new_references.test_choice_no                    := x_test_choice_no;
    new_references.test_transaction_type             := x_test_transaction_type;
    new_references.copy_ucas_id                      := x_copy_ucas_id;
    new_references.decision_make_id                  := x_decision_make_id;
    new_references.decision_reason_id                := x_decision_reason_id;
    new_references.obsolete_outcome_status           := x_obsolete_outcome_status;
    new_references.pending_outcome_status            := x_pending_outcome_status;
    new_references.rejected_outcome_status           := x_rejected_outcome_status;
    new_references.system_code                       := x_system_code ;
    new_references.ni_number_alt_pers_type           := x_ni_number_alt_pers_type ;
    new_references.application_type                  := x_application_type ;
    -- smaddali added these cols for ucfd203 - multiple cycles build , bug#2669208
    new_references.name                              := x_name         ;
    new_references.description                       := x_description   ;
    new_references.ucas_security_key                 := x_ucas_security_key  ;
    new_references.current_cycle                     := x_current_cycle      ;
    new_references.configured_cycle                  := x_configured_cycle  ;
    new_references.prev_inst_left_date               := x_prev_inst_left_date;

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


  PROCEDURE Check_Parent_Existance as
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : checks if parent record exists
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali  11-jun-03  removed parent check with igs_uc_adm_systems for bug#2669208 , ucfd203 build
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

             IF (((old_references.obsolete_outcome_status = new_references.obsolete_outcome_status)) OR
                ((new_references.obsolete_outcome_status IS NULL))) THEN
                 NULL;
             ELSE
                IF NOT IGS_AD_OU_STAT_PKG.Get_PK_For_Validation ( new_references.obsolete_outcome_status , 'N' ) THEN
                    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                    IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
               END IF;
            END IF;


           IF (((old_references.pending_outcome_status = new_references.pending_outcome_status)) OR
                ((new_references.pending_outcome_status IS NULL))) THEN
              NULL;
            ELSE
                 IF NOT IGS_AD_OU_STAT_PKG.Get_PK_For_Validation (new_references.pending_outcome_status , 'N' ) THEN
                    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
                 END IF;
            END IF;


           IF (((old_references.rejected_outcome_status = new_references.rejected_outcome_status)) OR
                ((new_references.rejected_outcome_status IS NULL))) THEN
              NULL;
            ELSE
                IF NOT IGS_AD_OU_STAT_PKG.Get_PK_For_Validation (new_references.rejected_outcome_status , 'N') THEN
                    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
                 END IF;

            END IF;



           IF (((old_references.decision_reason_id = new_references.decision_reason_id)) OR
                ((new_references.decision_reason_id IS NULL))) THEN
              NULL;
            ELSE
                IF NOT IGS_AD_CODE_CLASSES_PKG.Get_PK_For_Validation (new_references.decision_reason_id, 'N' ) THEN
                    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
                 END IF;

            END IF;



         IF (((old_references.application_type = new_references.application_type)) OR
                ((new_references.application_type IS NULL))) THEN
              NULL;
         ELSE
                IF NOT  IGS_AD_SS_APPL_TYP_PKG.get_pk_for_validation ( new_references.application_type, 'N') THEN
                    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
                 END IF;

         END IF;

        IF (((old_references.ni_number_alt_pers_type = new_references.ni_number_alt_pers_type)) OR
                ((new_references.ni_number_alt_pers_type IS NULL))) THEN
              NULL;
            ELSE
                IF NOT IGS_PE_PERSON_ID_TYP_PKG.Get_PK_For_Validation (new_references.ni_number_alt_pers_type ) THEN
                    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
                 END IF;

        END IF;

  END Check_Parent_Existance;


  PROCEDURE GET_FK_IGS_AD_OU_STAT(
    x_adm_outcome_status IN VARCHAR2
    ) as

    CURSOR cur_rowid1 IS
      SELECT   rowid
      FROM     IGS_UC_DEFAULTS
      WHERE  obsolete_outcome_status= x_adm_outcome_status ;


      CURSOR cur_rowid2 IS
      SELECT   rowid
      FROM     IGS_UC_DEFAULTS
      WHERE   pending_outcome_status= x_adm_outcome_status;


      CURSOR cur_rowid3 IS
      SELECT   rowid
      FROM     IGS_UC_DEFAULTS
      WHERE   rejected_outcome_status= x_adm_outcome_status ;

    lv_rowid1 cur_rowid1%RowType;
    lv_rowid2 cur_rowid2%RowType;
    lv_rowid3 cur_rowid3%RowType;

  BEGIN

    Open cur_rowid1;
    Fetch cur_rowid1 INTO lv_rowid1;
    IF (cur_rowid1%FOUND) THEN
      Close cur_rowid1;
                Fnd_Message.Set_Name ('IGS', 'IGS_AD_AOS_UCDF_FK1');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
                Return;
    END IF;
   Close cur_rowid1;

    Open  cur_rowid2;
    Fetch cur_rowid2 INTO lv_rowid2;
    IF (cur_rowid2%FOUND) THEN
          Close cur_rowid2;
          Fnd_Message.Set_Name ('IGS', 'IGS_AD_AOS_UCDF_FK2');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
          Return;
    END IF;
    Close cur_rowid2;


    Open cur_rowid3;
    Fetch cur_rowid3 INTO lv_rowid3;
    IF (cur_rowid3%FOUND) THEN
               Close cur_rowid3;
               Fnd_Message.Set_Name ('IGS', 'IGS_AD_AOS_UCDF_FK3');
               IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
               Return;
    END IF;
    Close cur_rowid3;


  END GET_FK_IGS_AD_OU_STAT;


  PROCEDURE GET_FK_IGS_AD_CODE_CLASSES(
    x_code_id IN NUMBER
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_UC_DEFAULTS
      WHERE    decision_reason_id = x_code_id;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
               Fnd_Message.Set_Name ('IGS', 'IGS_AD_ADCC_UCDF_FK');
               IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
               Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_CODE_CLASSES;


   PROCEDURE get_fk_igs_ad_ss_appl_typ(
    x_application_type IN VARCHAR2
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_UC_DEFAULTS
      WHERE    application_type = x_application_type;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_UC_UCDF_SSAT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END get_fk_igs_ad_ss_appl_typ;


  FUNCTION get_pk_for_validation (
    x_system_code                       IN    VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 23-OCT-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_defaults
      WHERE    system_code = x_system_code;

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

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_current_inst_code                 IN     VARCHAR2,
    x_ucas_id_format                    IN     VARCHAR2,
    x_test_app_no                       IN     NUMBER  ,
    x_test_choice_no                    IN     NUMBER  ,
    x_test_transaction_type             IN     VARCHAR2,
    x_copy_ucas_id                      IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_decision_make_id                  IN     NUMBER  ,
    x_decision_reason_id                IN     NUMBER  ,
    x_obsolete_outcome_status           IN     VARCHAR2,
    x_pending_outcome_status            IN     VARCHAR2,
    x_rejected_outcome_status           IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_ni_number_alt_pers_type           IN     VARCHAR2,
    x_application_type                  IN     VARCHAR2,
    -- smaddali added these cols for ucfd203 - multiple cycles build , bug#2669208
    x_name                              IN     VARCHAR2  ,
    x_description                       IN     VARCHAR2  ,
    x_ucas_security_key                 IN     VARCHAR2  ,
    x_current_cycle                     IN     VARCHAR2  ,
    x_configured_cycle                  IN     VARCHAR2,
    x_prev_inst_left_date               IN     DATE
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali  11-jun-03  removed calendar cols and added new cols for bug#2669208 , ucfd203 build
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

 set_column_values (
      p_action,
      x_rowid,
      x_current_inst_code,
      x_ucas_id_format,
      x_test_app_no,
      x_test_choice_no,
      x_test_transaction_type,
      x_copy_ucas_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_decision_make_id,
      x_decision_reason_id,
      x_obsolete_outcome_status,
      x_pending_outcome_status,
      x_rejected_outcome_status,
      x_system_code   ,
      x_ni_number_alt_pers_type   ,
      x_application_type   ,
      -- smaddali added these cols for ucfd203 - multiple cycles build , bug#2669208
      x_name         ,
      x_description  ,
      x_ucas_security_key  ,
      x_current_cycle   ,
      x_configured_cycle,
      x_prev_inst_left_date
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
       IF ( get_pk_for_validation(
             new_references.system_code
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      Check_Parent_Existance;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
       IF ( get_pk_for_validation (
             new_references.system_code
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;

    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_current_inst_code                 IN     VARCHAR2,
    x_ucas_id_format                    IN     VARCHAR2,
    x_test_app_no                       IN     NUMBER,
    x_test_choice_no                    IN     NUMBER,
    x_test_transaction_type             IN     VARCHAR2,
    x_copy_ucas_id                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_decision_make_id                  IN     NUMBER,
    x_decision_reason_id                IN     NUMBER,
    x_obsolete_outcome_status           IN     VARCHAR2,
    x_pending_outcome_status            IN     VARCHAR2 ,
    x_rejected_outcome_status           IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_ni_number_alt_pers_type           IN     VARCHAR2,
    x_application_type                  IN     VARCHAR2,
    -- smaddali added these cols for ucfd203 - multiple cycles build , bug#2669208
    x_name                              IN     VARCHAR2  ,
    x_description                       IN     VARCHAR2  ,
    x_ucas_security_key                 IN     VARCHAR2  ,
    x_current_cycle                     IN     VARCHAR2  ,
    x_configured_cycle                  IN     VARCHAR2,
    x_prev_inst_left_date               IN     DATE
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali  11-jun-03  removed calendar cols and added new cols for bug#2669208 , ucfd203 build
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_uc_defaults
          ;

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

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_current_inst_code                 => x_current_inst_code,
      x_ucas_id_format                    => x_ucas_id_format,
      x_test_app_no                       => x_test_app_no,
      x_test_choice_no                    => x_test_choice_no,
      x_test_transaction_type             => x_test_transaction_type,
      x_copy_ucas_id                      => x_copy_ucas_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_decision_make_id                  => x_decision_make_id,
      x_decision_reason_id                => x_decision_reason_id,
      x_obsolete_outcome_status           => x_obsolete_outcome_status,
      x_pending_outcome_status            => x_pending_outcome_status,
      x_rejected_outcome_status           => x_rejected_outcome_status,
      x_system_code                       => x_system_code,
      x_ni_number_alt_pers_type           => x_ni_number_alt_pers_type,
      x_application_type                  => x_application_type,
      -- smaddali added these cols for ucfd203 - multiple cycles build , bug#2669208
      x_name                              => x_name ,
      x_description                       => x_description ,
      x_ucas_security_key                 => x_ucas_security_key ,
      x_current_cycle                     => x_current_cycle ,
      x_configured_cycle                  => x_configured_cycle,
      x_prev_inst_left_date               => x_prev_inst_left_date
    );

    INSERT INTO igs_uc_defaults (
      current_inst_code,
      ucas_id_format,
      test_app_no,
      test_choice_no,
      test_transaction_type,
      copy_ucas_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      decision_make_id,
      decision_reason_id,
      obsolete_outcome_status,
      pending_outcome_status,
      rejected_outcome_status,
      system_code   ,
      ni_number_alt_pers_type   ,
      application_type ,
      -- smaddali added these cols for ucfd203 - multiple cycles build , bug#2669208
      name      ,
      description   ,
      ucas_security_key  ,
      current_cycle    ,
      configured_cycle,
      prev_inst_left_date
    ) VALUES (
      new_references.current_inst_code,
      new_references.ucas_id_format,
      new_references.test_app_no,
      new_references.test_choice_no,
      new_references.test_transaction_type,
      new_references.copy_ucas_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      new_references.decision_make_id,
      new_references.decision_reason_id,
      new_references.obsolete_outcome_status,
      new_references.pending_outcome_status,
      new_references.rejected_outcome_status,
      new_references.system_code   ,
      new_references.ni_number_alt_pers_type   ,
      new_references.application_type ,
      -- smaddali added these cols for ucfd203 - multiple cycles build , bug#2669208
      new_references.name        ,
      new_references.description    ,
      new_references.ucas_security_key   ,
      new_references.current_cycle      ,
      new_references.configured_cycle,
      new_references.prev_inst_left_date);

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_current_inst_code                 IN     VARCHAR2,
    x_ucas_id_format                    IN     VARCHAR2,
    x_test_app_no                       IN     NUMBER,
    x_test_choice_no                    IN     NUMBER,
    x_test_transaction_type             IN     VARCHAR2,
    x_copy_ucas_id                      IN     VARCHAR2,
    x_decision_make_id                  IN     NUMBER ,
    x_decision_reason_id                IN     NUMBER,
    x_obsolete_outcome_status           IN     VARCHAR2,
    x_pending_outcome_status            IN     VARCHAR2 ,
    x_rejected_outcome_status           IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_ni_number_alt_pers_type           IN     VARCHAR2,
    x_application_type                  IN     VARCHAR2,
    -- smaddali added these cols for ucfd203 - multiple cycles build , bug#2669208
    x_name                              IN     VARCHAR2   ,
    x_description                       IN     VARCHAR2   ,
    x_ucas_security_key                 IN     VARCHAR2   ,
    x_current_cycle                     IN     VARCHAR2   ,
    x_configured_cycle                  IN     VARCHAR2,
    x_prev_inst_left_date               IN     DATE
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali  11-jun-03  removed calendar cols and added new cols for bug#2669208 , ucfd203 build
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        current_inst_code,
        ucas_id_format,
        test_app_no,
        test_choice_no,
        test_transaction_type,
        copy_ucas_id,
        decision_make_id,
        decision_reason_id,
        obsolete_outcome_status,
        pending_outcome_status,
        rejected_outcome_status,
        system_code,
        ni_number_alt_pers_type,
        application_type  ,
        -- smaddali added these cols for ucfd203 - multiple cycles build , bug#2669208
        name      ,
        description      ,
        ucas_security_key     ,
        current_cycle     ,
        configured_cycle,
        prev_inst_left_date
      FROM  igs_uc_defaults
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
        ((tlinfo.current_inst_code = x_current_inst_code) OR ((tlinfo.current_inst_code IS NULL) AND (X_current_inst_code IS NULL)))
        AND ((tlinfo.ucas_id_format = x_ucas_id_format) OR ((tlinfo.ucas_id_format IS NULL) AND (X_ucas_id_format IS NULL)))
        AND ((tlinfo.test_app_no = x_test_app_no) OR ((tlinfo.test_app_no IS NULL) AND (X_test_app_no IS NULL)))
        AND ((tlinfo.test_choice_no = x_test_choice_no) OR ((tlinfo.test_choice_no IS NULL) AND (X_test_choice_no IS NULL)))
        AND ((tlinfo.test_transaction_type = x_test_transaction_type) OR ((tlinfo.test_transaction_type IS NULL) AND (X_test_transaction_type IS NULL)))
        AND (tlinfo.copy_ucas_id = x_copy_ucas_id)
        AND ((tlinfo.decision_make_id = x_decision_make_id) OR ((tlinfo.decision_make_id IS NULL) AND (X_decision_make_id IS NULL)))
        AND ((tlinfo.decision_reason_id = x_decision_reason_id) OR ((tlinfo.decision_reason_id IS NULL) AND (X_decision_reason_id IS NULL)))
        AND ((tlinfo.obsolete_outcome_status = x_obsolete_outcome_status) OR ((tlinfo.obsolete_outcome_status IS NULL) AND (X_obsolete_outcome_status IS NULL)))
        AND ((tlinfo.pending_outcome_status = x_pending_outcome_status) OR ((tlinfo.pending_outcome_status IS NULL) AND (X_pending_outcome_status IS NULL)))
        AND ((tlinfo.rejected_outcome_status = x_rejected_outcome_status) OR ((tlinfo.rejected_outcome_status IS NULL) AND (X_rejected_outcome_status IS NULL)))
        AND ((tlinfo.system_code = x_system_code) )
        AND ((tlinfo.ni_number_alt_pers_type = x_ni_number_alt_pers_type) OR ((tlinfo.ni_number_alt_pers_type IS NULL) AND (X_ni_number_alt_pers_type IS NULL)))
        AND ((tlinfo.application_type = x_application_type) OR ((tlinfo.application_type IS NULL) AND (X_application_type IS NULL)))
        -- smaddali added new cols for ucfd203 -multiple cycles build , bug#2669208
        AND ((tlinfo.name = x_name) OR ((tlinfo.name IS NULL) AND (X_name IS NULL)))
        AND ((tlinfo.description = x_description) OR ((tlinfo.description IS NULL) AND (X_description IS NULL)))
        AND ((tlinfo.ucas_security_key = x_ucas_security_key) OR ((tlinfo.ucas_security_key IS NULL) AND (X_ucas_security_key IS NULL)))
        AND ((tlinfo.current_cycle = x_current_cycle) OR ((tlinfo.current_cycle IS NULL) AND (X_current_cycle IS NULL)))
        AND ((tlinfo.configured_cycle = x_configured_cycle) OR ((tlinfo.configured_cycle IS NULL) AND (X_configured_cycle IS NULL)))
        AND ((tlinfo.prev_inst_left_date = x_prev_inst_left_date) OR ((tlinfo.prev_inst_left_date IS NULL) AND (x_prev_inst_left_date IS NULL)))
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
    x_current_inst_code                 IN     VARCHAR2,
    x_ucas_id_format                    IN     VARCHAR2,
    x_test_app_no                       IN     NUMBER,
    x_test_choice_no                    IN     NUMBER,
    x_test_transaction_type             IN     VARCHAR2,
    x_copy_ucas_id                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_decision_make_id                  IN     NUMBER ,
    x_decision_reason_id                IN     NUMBER ,
    x_obsolete_outcome_status           IN     VARCHAR2,
    x_pending_outcome_status            IN     VARCHAR2 ,
    x_rejected_outcome_status           IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_ni_number_alt_pers_type           IN     VARCHAR2,
    x_application_type                  IN     VARCHAR2,
    -- smaddali added these cols for ucfd203 - multiple cycles build , bug#2669208
    x_name                              IN     VARCHAR2  ,
    x_description                       IN     VARCHAR2  ,
    x_ucas_security_key                 IN     VARCHAR2  ,
    x_current_cycle                     IN     VARCHAR2  ,
    x_configured_cycle                  IN     VARCHAR2,
    x_prev_inst_left_date               IN     DATE
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali  11-jun-03  removed calendar cols and added new cols for bug#2669208 , ucfd203 build
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
      x_current_inst_code                 => x_current_inst_code,
      x_ucas_id_format                    => x_ucas_id_format,
      x_test_app_no                       => x_test_app_no,
      x_test_choice_no                    => x_test_choice_no,
      x_test_transaction_type             => x_test_transaction_type,
      x_copy_ucas_id                      => x_copy_ucas_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_decision_make_id                  => x_decision_make_id,
      x_decision_reason_id                => x_decision_reason_id,
      x_obsolete_outcome_status           => x_obsolete_outcome_status,
      x_pending_outcome_status            => x_pending_outcome_status,
      x_rejected_outcome_status           => x_rejected_outcome_status,
      x_system_code                       => x_system_code,
      x_ni_number_alt_pers_type           => x_ni_number_alt_pers_type,
      x_application_type                  => x_application_type,
      -- smaddali added these cols for ucfd203 - multiple cycles build , bug#2669208
      x_name                              => x_name          ,
      x_description                       => x_description   ,
      x_ucas_security_key                 => x_ucas_security_key  ,
      x_current_cycle                     => x_current_cycle      ,
      x_configured_cycle                  => x_configured_cycle,
      x_prev_inst_left_date               => x_prev_inst_left_date
    );

    UPDATE igs_uc_defaults
      SET
        current_inst_code                 = new_references.current_inst_code,
        ucas_id_format                    = new_references.ucas_id_format,
        test_app_no                       = new_references.test_app_no,
        test_choice_no                    = new_references.test_choice_no,
        test_transaction_type             = new_references.test_transaction_type,
        copy_ucas_id                      = new_references.copy_ucas_id,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        decision_make_id                  = new_references.decision_make_id,
        decision_reason_id                = new_references.decision_reason_id,
        obsolete_outcome_status           = new_references.obsolete_outcome_status,
        pending_outcome_status            = new_references.pending_outcome_status,
        rejected_outcome_status           = new_references.rejected_outcome_status,
        ni_number_alt_pers_type           = new_references.ni_number_alt_pers_type,
        application_type                  = new_references.application_type,
        -- smaddali added these cols for ucfd203 - multiple cycles build , bug#2669208
        name                              = new_references.name          ,
        description                       = new_references.description   ,
        ucas_security_key                 = new_references.ucas_security_key  ,
        current_cycle                     = new_references.current_cycle      ,
        configured_cycle                  = new_references.configured_cycle,
        prev_inst_left_date               = new_references.prev_inst_left_date
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_current_inst_code                 IN     VARCHAR2,
    x_ucas_id_format                    IN     VARCHAR2,
    x_test_app_no                       IN     NUMBER,
    x_test_choice_no                    IN     NUMBER,
    x_test_transaction_type             IN     VARCHAR2,
    x_copy_ucas_id                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_decision_make_id                  IN     NUMBER ,
    x_decision_reason_id                IN     NUMBER ,
    x_obsolete_outcome_status           IN     VARCHAR2,
    x_pending_outcome_status            IN     VARCHAR2 ,
    x_rejected_outcome_status           IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_ni_number_alt_pers_type           IN     VARCHAR2,
    x_application_type                  IN     VARCHAR2,
    -- smaddali added these cols for ucfd203 - multiple cycles build , bug#2669208
    x_name                              IN     VARCHAR2  ,
    x_description                       IN     VARCHAR2  ,
    x_ucas_security_key                 IN     VARCHAR2  ,
    x_current_cycle                     IN     VARCHAR2 ,
    x_configured_cycle                  IN     VARCHAR2,
    x_prev_inst_left_date               IN     DATE
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali  11-jun-03  removed calendar cols and added new cols for bug#2669208 , ucfd203 build
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_defaults
        ;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_current_inst_code,
        x_ucas_id_format,
        x_test_app_no,
        x_test_choice_no,
        x_test_transaction_type,
        x_copy_ucas_id,
        x_mode,
        x_decision_make_id,
        x_decision_reason_id,
        x_obsolete_outcome_status,
        x_pending_outcome_status,
        x_rejected_outcome_status,
        x_system_code  ,
        x_ni_number_alt_pers_type    ,
        x_application_type ,
        -- smaddali added these cols for ucfd203 - multiple cycles build , bug#2669208
        x_name          ,
        x_description   ,
        x_ucas_security_key  ,
        x_current_cycle      ,
        x_configured_cycle,
        x_prev_inst_left_date
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_current_inst_code,
      x_ucas_id_format,
      x_test_app_no,
      x_test_choice_no,
      x_test_transaction_type,
      x_copy_ucas_id,
      x_mode,
      x_decision_make_id,
      x_decision_reason_id,
      x_obsolete_outcome_status,
      x_pending_outcome_status,
      x_rejected_outcome_status,
      x_system_code  ,
      x_ni_number_alt_pers_type    ,
      x_application_type,
      -- smaddali added these cols for ucfd203 - multiple cycles build , bug#2669208
      x_name          ,
      x_description   ,
      x_ucas_security_key  ,
      x_current_cycle      ,
      x_configured_cycle,
      x_prev_inst_left_date
    );

  END add_row;


END igs_uc_defaults_pkg;

/
