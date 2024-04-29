--------------------------------------------------------
--  DDL for Package Body IGS_UC_TRANSACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_TRANSACTIONS_PKG" AS
/* $Header: IGSXI32B.pls 120.3 2006/08/21 03:36:53 jbaber ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_transactions%ROWTYPE;
  new_references igs_uc_transactions%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_uc_tran_id                        IN     NUMBER      ,
    x_transaction_id                    IN     NUMBER      ,
    x_datetimestamp                     IN     DATE        ,
    x_updater                           IN     VARCHAR2    ,
    x_error_code                        IN     NUMBER      ,
    x_transaction_type                  IN     VARCHAR2    ,
    x_app_no                            IN     NUMBER      ,
    x_choice_no                         IN     NUMBER      ,
    x_decision                          IN     VARCHAR2    ,
    x_program_code                      IN     VARCHAR2   ,
    x_campus                            IN     VARCHAR2    ,
    x_entry_month                       IN     NUMBER      ,
    x_entry_year                        IN     NUMBER     ,
    x_entry_point                       IN     NUMBER      ,
    x_soc                               IN     VARCHAR2    ,
    x_comments_in_offer                 IN     VARCHAR2    ,
    x_return1                           IN     NUMBER      ,
    x_return2                           IN     VARCHAR2    ,
    x_hold_flag                         IN     VARCHAR2    ,
    x_sent_to_ucas                      IN     VARCHAR2    ,
    x_test_cond_cat                     IN     VARCHAR2    ,
    x_test_cond_name                    IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    -- Added inst_reference Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_inst_reference                    IN     VARCHAR2     ,
    -- smaddali added column auto generated flag for bug 2603384
    x_auto_generated_flag               IN     VARCHAR2  ,
    x_system_code                       IN     VARCHAR2  ,
    x_ucas_cycle                        IN     VARCHAR2  ,
    x_modular                           IN     VARCHAR2  ,
    x_part_time                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : SOLAKSHM@ORACLE.COM
  ||  Created On : 31-JAN-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_UC_TRANSACTIONS
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
    new_references.uc_tran_id                        := x_uc_tran_id;
    new_references.transaction_id                    := x_transaction_id;
    new_references.datetimestamp                     := x_datetimestamp;
    new_references.updater                           := x_updater;
    new_references.error_code                        := x_error_code;
    new_references.transaction_type                  := x_transaction_type;
    new_references.app_no                            := x_app_no;
    new_references.choice_no                         := x_choice_no;
    new_references.decision                          := x_decision;
    new_references.program_code                      := x_program_code;
    new_references.campus                            := x_campus;
    new_references.entry_month                       := x_entry_month;
    new_references.entry_year                        := x_entry_year;
    new_references.entry_point                       := x_entry_point;
    new_references.soc                               := x_soc;
    new_references.comments_in_offer                 := x_comments_in_offer;
    new_references.return1                           := x_return1;
    new_references.return2                           := x_return2;
    new_references.hold_flag                         := x_hold_flag;
    new_references.sent_to_ucas                      := x_sent_to_ucas;
    new_references.test_cond_cat                     := x_test_cond_cat;
    new_references.test_cond_name                    := x_test_cond_name;
    new_references.inst_reference                    := x_inst_reference;
    new_references.auto_generated_flag               := x_auto_generated_flag ;
    new_references.system_code                       := x_system_code  ;
    new_references.ucas_cycle                        := x_ucas_cycle;
    new_references.modular                           := x_modular;
    new_references.part_time                         := x_part_time;

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


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : bayadav
  ||  Created On : 11-NOV-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  rgangara       10-Jun-03   Modified this procedure to check for
  ||                             parent in IGS_UC_DEFAULTS instead of
  ||                             ADM_SYSTEMS as it is obsoleted
  ||                             as part of bug# 2669208.
  */

  BEGIN

    IF ((old_references.system_code = new_references.system_code)  OR
        (new_references.system_code IS NULL)) THEN
      NULL;
    ELSIF NOT igs_uc_defaults_pkg.get_pk_for_validation (
                new_references.system_code
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_uc_tran_id                        IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : SOLAKSHM@ORACLE.COM
  ||  Created On : 31-JAN-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_transactions
      WHERE    uc_tran_id = x_uc_tran_id ;

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
    x_rowid                             IN     VARCHAR2    ,
    x_uc_tran_id                        IN     NUMBER      ,
    x_transaction_id                    IN     NUMBER      ,
    x_datetimestamp                     IN     DATE        ,
    x_updater                           IN     VARCHAR2    ,
    x_error_code                        IN     NUMBER     ,
    x_transaction_type                  IN     VARCHAR2   ,
    x_app_no                            IN     NUMBER     ,
    x_choice_no                         IN     NUMBER     ,
    x_decision                          IN     VARCHAR2    ,
    x_program_code                      IN     VARCHAR2    ,
    x_campus                            IN     VARCHAR2   ,
    x_entry_month                       IN     NUMBER     ,
    x_entry_year                        IN     NUMBER      ,
    x_entry_point                       IN     NUMBER      ,
    x_soc                               IN     VARCHAR2    ,
    x_comments_in_offer                 IN     VARCHAR2    ,
    x_return1                           IN     NUMBER     ,
    x_return2                           IN     VARCHAR2    ,
    x_hold_flag                         IN     VARCHAR2    ,
    x_sent_to_ucas                      IN     VARCHAR2    ,
    x_test_cond_cat                     IN     VARCHAR2    ,
    x_test_cond_name                    IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE       ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER     ,
    -- Added inst_reference Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_inst_reference                    IN     VARCHAR2    ,
    -- smaddali added column auto generated flag for bug 2603384
    x_auto_generated_flag               IN     VARCHAR2  ,
    x_system_code                       IN     VARCHAR2  ,
    x_ucas_cycle                        IN     VARCHAR2  ,
    x_modular                           IN     VARCHAR2  ,
    x_part_time                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : SOLAKSHM@ORACLE.COM
  ||  Created On : 31-JAN-2002
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
      x_uc_tran_id,
      x_transaction_id,
      x_datetimestamp,
      x_updater,
      x_error_code,
      x_transaction_type,
      x_app_no,
      x_choice_no,
      x_decision,
      x_program_code,
      x_campus,
      x_entry_month,
      x_entry_year,
      x_entry_point,
      x_soc,
      x_comments_in_offer,
      x_return1,
      x_return2,
      x_hold_flag,
      x_sent_to_ucas,
      x_test_cond_cat,
      x_test_cond_name,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_inst_reference ,
      x_auto_generated_flag,
      x_system_code,
      x_ucas_cycle,
      x_modular,
      x_part_time
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.uc_tran_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.uc_tran_id
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
    x_uc_tran_id                        IN OUT NOCOPY NUMBER,
    x_transaction_id                    IN     NUMBER,
    x_datetimestamp                     IN     DATE,
    x_updater                           IN     VARCHAR2,
    x_error_code                        IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER,
    x_decision                          IN     VARCHAR2,
    x_program_code                      IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_entry_month                       IN     NUMBER,
    x_entry_year                        IN     NUMBER,
    x_entry_point                       IN     NUMBER,
    x_soc                               IN     VARCHAR2,
    x_comments_in_offer                 IN     VARCHAR2,
    x_return1                           IN     NUMBER,
    x_return2                           IN     VARCHAR2,
    x_hold_flag                         IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_test_cond_cat                     IN     VARCHAR2,
    x_test_cond_name                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    -- Added inst_reference Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_inst_reference                    IN     VARCHAR2    ,
    -- smaddali added column auto generated flag for bug 2603384
    x_auto_generated_flag               IN     VARCHAR2  ,
    x_system_code                       IN     VARCHAR2  ,
    x_ucas_cycle                        IN     VARCHAR2  ,
    x_modular                           IN     VARCHAR2  ,
    x_part_time                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : SOLAKSHM@ORACLE.COM
  ||  Created On : 31-JAN-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_uc_transactions
      WHERE    uc_tran_id                        = x_uc_tran_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  BEGIN

    x_last_update_date := SYSDATE;
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
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT    igs_uc_transactions_s.NEXTVAL
    INTO      x_uc_tran_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_uc_tran_id                        => x_uc_tran_id,
      x_transaction_id                    => x_transaction_id,
      x_datetimestamp                     => x_datetimestamp,
      x_updater                           => x_updater,
      x_error_code                        => x_error_code,
      x_transaction_type                  => x_transaction_type,
      x_app_no                            => x_app_no,
      x_choice_no                         => x_choice_no,
      x_decision                          => x_decision,
      x_program_code                      => x_program_code,
      x_campus                            => x_campus,
      x_entry_month                       => x_entry_month,
      x_entry_year                        => x_entry_year,
      x_entry_point                       => x_entry_point,
      x_soc                               => x_soc,
      x_comments_in_offer                 => x_comments_in_offer,
      x_return1                           => x_return1,
      x_return2                           => x_return2,
      x_hold_flag                         => x_hold_flag,
      x_sent_to_ucas                      => x_sent_to_ucas,
      x_test_cond_cat                     => x_test_cond_cat,
      x_test_cond_name                    => x_test_cond_name,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_inst_reference                    => x_inst_reference ,
      x_auto_generated_flag               => x_auto_generated_flag,
      x_system_code                       => x_system_code ,
      x_ucas_cycle                        => x_ucas_cycle ,
      x_modular                           => x_modular ,
      x_part_time                         => x_part_time
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_uc_transactions (
      uc_tran_id,
      transaction_id,
      datetimestamp,
      updater,
      error_code,
      transaction_type,
      app_no,
      choice_no,
      decision,
      program_code,
      campus,
      entry_month,
      entry_year,
      entry_point,
      soc,
      comments_in_offer,
      return1,
      return2,
      hold_flag,
      sent_to_ucas,
      test_cond_cat,
      test_cond_name,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      inst_reference ,
      auto_generated_flag,
      system_code,
      ucas_cycle,
      modular,
      part_time
    ) VALUES (
      new_references.uc_tran_id,
      new_references.transaction_id,
      new_references.datetimestamp,
      new_references.updater,
      new_references.error_code,
      new_references.transaction_type,
      new_references.app_no,
      new_references.choice_no,
      new_references.decision,
      new_references.program_code,
      new_references.campus,
      new_references.entry_month,
      new_references.entry_year,
      new_references.entry_point,
      new_references.soc,
      new_references.comments_in_offer,
      new_references.return1,
      new_references.return2,
      new_references.hold_flag,
      new_references.sent_to_ucas,
      new_references.test_cond_cat,
      new_references.test_cond_name,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.inst_reference ,
      new_references.auto_generated_flag,
      new_references.system_code ,
      new_references.ucas_cycle ,
      new_references.modular ,
      new_references.part_time
    );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;


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
    x_uc_tran_id                        IN     NUMBER,
    x_transaction_id                    IN     NUMBER,
    x_datetimestamp                     IN     DATE,
    x_updater                           IN     VARCHAR2,
    x_error_code                        IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER,
    x_decision                          IN     VARCHAR2,
    x_program_code                      IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_entry_month                       IN     NUMBER,
    x_entry_year                        IN     NUMBER,
    x_entry_point                       IN     NUMBER,
    x_soc                               IN     VARCHAR2,
    x_comments_in_offer                 IN     VARCHAR2,
    x_return1                           IN     NUMBER,
    x_return2                           IN     VARCHAR2,
    x_hold_flag                         IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_test_cond_cat                     IN     VARCHAR2,
    x_test_cond_name                    IN     VARCHAR2,
    -- Added inst_reference Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_inst_reference                    IN     VARCHAR2  ,
    -- smaddali added column auto generated flag for bug 2603384
    x_auto_generated_flag               IN     VARCHAR2  ,
    x_system_code                       IN     VARCHAR2 ,
    x_ucas_cycle                        IN     VARCHAR2 ,
    x_modular                           IN     VARCHAR2 ,
    x_part_time                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : SOLAKSHM@ORACLE.COM
  ||  Created On : 31-JAN-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        transaction_id,
        datetimestamp,
        updater,
        error_code,
        transaction_type,
        app_no,
        choice_no,
        decision,
        program_code,
        campus,
        entry_month,
        entry_year,
        entry_point,
        soc,
        comments_in_offer,
        return1,
        return2,
        hold_flag,
        sent_to_ucas,
        test_cond_cat,
        test_cond_name,
        inst_reference ,
        auto_generated_flag,
        system_code,
        ucas_cycle,
        modular,
        part_time
      FROM  igs_uc_transactions
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
        ((tlinfo.transaction_id = x_transaction_id) OR ((tlinfo.transaction_id IS NULL) AND (X_transaction_id IS NULL)))
        AND ((tlinfo.datetimestamp = x_datetimestamp) OR ((tlinfo.datetimestamp IS NULL) AND (X_datetimestamp IS NULL)))
        AND ((tlinfo.updater = x_updater) OR ((tlinfo.updater IS NULL) AND (X_updater IS NULL)))
        AND ((tlinfo.error_code = x_error_code) OR ((tlinfo.error_code IS NULL) AND (X_error_code IS NULL)))
        AND (tlinfo.transaction_type = x_transaction_type)
        AND ((tlinfo.app_no = x_app_no) OR ((tlinfo.app_no IS NULL) AND (X_app_no IS NULL)))
        AND ((tlinfo.choice_no = x_choice_no) OR ((tlinfo.choice_no IS NULL) AND (X_choice_no IS NULL)))
        AND ((tlinfo.decision = x_decision) OR ((tlinfo.decision IS NULL) AND (X_decision IS NULL)))
        AND ((tlinfo.program_code = x_program_code) OR ((tlinfo.program_code IS NULL) AND (X_program_code IS NULL)))
        AND ((tlinfo.campus = x_campus) OR ((tlinfo.campus IS NULL) AND (X_campus IS NULL)))
        AND ((tlinfo.entry_month = x_entry_month) OR ((tlinfo.entry_month IS NULL) AND (X_entry_month IS NULL)))
        AND ((tlinfo.entry_year = x_entry_year) OR ((tlinfo.entry_year IS NULL) AND (X_entry_year IS NULL)))
        AND ((tlinfo.entry_point = x_entry_point) OR ((tlinfo.entry_point IS NULL) AND (X_entry_point IS NULL)))
        AND ((tlinfo.soc = x_soc) OR ((tlinfo.soc IS NULL) AND (X_soc IS NULL)))
        AND ((tlinfo.comments_in_offer = x_comments_in_offer) OR ((tlinfo.comments_in_offer IS NULL) AND (X_comments_in_offer IS NULL)))
        AND ((tlinfo.return1 = x_return1) OR ((tlinfo.return1 IS NULL) AND (X_return1 IS NULL)))
        AND ((tlinfo.return2 = x_return2) OR ((tlinfo.return2 IS NULL) AND (X_return2 IS NULL)))
        AND (tlinfo.hold_flag = x_hold_flag)
        AND (tlinfo.sent_to_ucas = x_sent_to_ucas)
        AND ((tlinfo.test_cond_cat = x_test_cond_cat) OR ((tlinfo.test_cond_cat IS NULL) AND (X_test_cond_cat IS NULL)))
        AND ((tlinfo.test_cond_name = x_test_cond_name) OR ((tlinfo.test_cond_name IS NULL) AND (X_test_cond_name IS NULL)))
        AND ((tlinfo.inst_reference = x_inst_reference) OR ((tlinfo.inst_reference IS NULL) AND (x_inst_reference IS NULL)))
        AND ((tlinfo.auto_generated_flag = x_auto_generated_flag) OR ((tlinfo.auto_generated_flag IS NULL) AND (x_auto_generated_flag IS NULL)) )
        AND ((tlinfo.system_code = x_system_code) )
        AND (tlinfo.ucas_cycle   = x_ucas_cycle)
        AND ((tlinfo.modular = x_modular) OR ((tlinfo.modular IS NULL) AND (x_modular IS NULL)) )
        AND ((tlinfo.part_time = x_part_time) OR ((tlinfo.part_time IS NULL) AND (x_part_time IS NULL)) )
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
    x_uc_tran_id                        IN     NUMBER,
    x_transaction_id                    IN     NUMBER,
    x_datetimestamp                     IN     DATE,
    x_updater                           IN     VARCHAR2,
    x_error_code                        IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER,
    x_decision                          IN     VARCHAR2,
    x_program_code                      IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_entry_month                       IN     NUMBER,
    x_entry_year                        IN     NUMBER,
    x_entry_point                       IN     NUMBER,
    x_soc                               IN     VARCHAR2,
    x_comments_in_offer                 IN     VARCHAR2,
    x_return1                           IN     NUMBER,
    x_return2                           IN     VARCHAR2,
    x_hold_flag                         IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_test_cond_cat                     IN     VARCHAR2,
    x_test_cond_name                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    -- Added inst_reference Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_inst_reference                    IN     VARCHAR2    ,
    -- smaddali added column auto generated flag for bug 2603384
    x_auto_generated_flag               IN     VARCHAR2 ,
    x_system_code                       IN     VARCHAR2 ,
    x_ucas_cycle                        IN     VARCHAR2 ,
    x_modular                           IN     VARCHAR2 ,
    x_part_time                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : SOLAKSHM@ORACLE.COM
  ||  Created On : 31-JAN-2002
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_uc_tran_id                        => x_uc_tran_id,
      x_transaction_id                    => x_transaction_id,
      x_datetimestamp                     => x_datetimestamp,
      x_updater                           => x_updater,
      x_error_code                        => x_error_code,
      x_transaction_type                  => x_transaction_type,
      x_app_no                            => x_app_no,
      x_choice_no                         => x_choice_no,
      x_decision                          => x_decision,
      x_program_code                      => x_program_code,
      x_campus                            => x_campus,
      x_entry_month                       => x_entry_month,
      x_entry_year                        => x_entry_year,
      x_entry_point                       => x_entry_point,
      x_soc                               => x_soc,
      x_comments_in_offer                 => x_comments_in_offer,
      x_return1                           => x_return1,
      x_return2                           => x_return2,
      x_hold_flag                         => x_hold_flag,
      x_sent_to_ucas                      => x_sent_to_ucas,
      x_test_cond_cat                     => x_test_cond_cat,
      x_test_cond_name                    => x_test_cond_name,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_inst_reference                    => x_inst_reference  ,
      x_auto_generated_flag               => x_auto_generated_flag,
      x_system_code                       => x_system_code ,
      x_ucas_cycle                        => x_ucas_cycle ,
      x_modular                           => x_modular ,
      x_part_time                         => x_part_time
     );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_uc_transactions
      SET
        transaction_id                    = new_references.transaction_id,
        datetimestamp                     = new_references.datetimestamp,
        updater                           = new_references.updater,
        error_code                        = new_references.error_code,
        transaction_type                  = new_references.transaction_type,
        app_no                            = new_references.app_no,
        choice_no                         = new_references.choice_no,
        decision                          = new_references.decision,
        program_code                      = new_references.program_code,
        campus                            = new_references.campus,
        entry_month                       = new_references.entry_month,
        entry_year                        = new_references.entry_year,
        entry_point                       = new_references.entry_point,
        soc                               = new_references.soc,
        comments_in_offer                 = new_references.comments_in_offer,
        return1                           = new_references.return1,
        return2                           = new_references.return2,
        hold_flag                         = new_references.hold_flag,
        sent_to_ucas                      = new_references.sent_to_ucas,
        test_cond_cat                     = new_references.test_cond_cat,
        test_cond_name                    = new_references.test_cond_name,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        inst_reference                    = new_references.inst_reference ,
        auto_generated_flag               = new_references.auto_generated_flag,
        system_code                       = new_references.system_code ,
        ucas_cycle                        = new_references.ucas_cycle ,
        modular                           = new_references.modular ,
        part_time                         = new_references.part_time
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
    x_uc_tran_id                        IN OUT NOCOPY NUMBER,
    x_transaction_id                    IN     NUMBER,
    x_datetimestamp                     IN     DATE,
    x_updater                           IN     VARCHAR2,
    x_error_code                        IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER,
    x_decision                          IN     VARCHAR2,
    x_program_code                      IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_entry_month                       IN     NUMBER,
    x_entry_year                        IN     NUMBER,
    x_entry_point                       IN     NUMBER,
    x_soc                               IN     VARCHAR2,
    x_comments_in_offer                 IN     VARCHAR2,
    x_return1                           IN     NUMBER,
    x_return2                           IN     VARCHAR2,
    x_hold_flag                         IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_test_cond_cat                     IN     VARCHAR2,
    x_test_cond_name                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    -- Added inst_reference Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_inst_reference                    IN     VARCHAR2   ,
    -- smaddali added column auto generated flag for bug 2603384
    x_auto_generated_flag               IN     VARCHAR2 ,
    x_system_code                       IN     VARCHAR2 ,
    x_ucas_cycle                        IN     VARCHAR2 ,
    x_modular                           IN     VARCHAR2 ,
    x_part_time                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : SOLAKSHM@ORACLE.COM
  ||  Created On : 31-JAN-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_transactions
      WHERE    uc_tran_id                        = x_uc_tran_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_uc_tran_id,
        x_transaction_id,
        x_datetimestamp,
        x_updater,
        x_error_code,
        x_transaction_type,
        x_app_no,
        x_choice_no,
        x_decision,
        x_program_code,
        x_campus,
        x_entry_month,
        x_entry_year,
        x_entry_point,
        x_soc,
        x_comments_in_offer,
        x_return1,
        x_return2,
        x_hold_flag,
        x_sent_to_ucas,
        x_test_cond_cat,
        x_test_cond_name,
        x_mode,
        x_inst_reference,
        x_auto_generated_flag,
        x_system_code ,
        x_ucas_cycle ,
        x_modular ,
        x_part_time
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_uc_tran_id,
      x_transaction_id,
      x_datetimestamp,
      x_updater,
      x_error_code,
      x_transaction_type,
      x_app_no,
      x_choice_no,
      x_decision,
      x_program_code,
      x_campus,
      x_entry_month,
      x_entry_year,
      x_entry_point,
      x_soc,
      x_comments_in_offer,
      x_return1,
      x_return2,
      x_hold_flag,
      x_sent_to_ucas,
      x_test_cond_cat,
      x_test_cond_name,
      x_mode,
      x_inst_reference,
      x_auto_generated_flag,
      x_system_code,
      x_ucas_cycle,
      x_modular,
      x_part_time
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : SOLAKSHM@ORACLE.COM
  ||  Created On : 31-JAN-2002
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
 DELETE FROM igs_uc_transactions
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


END igs_uc_transactions_pkg;

/
