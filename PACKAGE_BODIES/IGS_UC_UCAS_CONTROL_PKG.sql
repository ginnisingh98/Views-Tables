--------------------------------------------------------
--  DDL for Package Body IGS_UC_UCAS_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_UCAS_CONTROL_PKG" AS
/* $Header: IGSXI33B.pls 120.2 2006/02/22 01:37:13 jchakrab noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_ucas_control%ROWTYPE;
  new_references igs_uc_ucas_control%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_entry_year                        IN     NUMBER  ,
    x_time_of_year                      IN     VARCHAR2,
    x_time_of_day                       IN     VARCHAR2,
    x_routeb_time_of_year               IN     VARCHAR2,
    x_appno_first                       IN     NUMBER  ,
    x_appno_maximum                     IN     NUMBER  ,
    x_appno_last_used                   IN     NUMBER  ,
    x_last_daily_run_no                 IN     NUMBER  ,
    x_last_daily_run_date               IN     DATE    ,
    x_appno_15dec                       IN     NUMBER  ,
    x_run_date_15dec                    IN     DATE    ,
    x_appno_24mar                       IN     NUMBER  ,
    x_run_date_24mar                    IN     DATE    ,
    x_appno_16may                       IN     NUMBER  ,
    x_run_date_16may                    IN     DATE    ,
    x_appno_decision_proc               IN     NUMBER  ,
    x_run_date_decision_proc            IN     DATE    ,
    x_appno_first_pre_num               IN     NUMBER  ,
    x_news                              IN     VARCHAR2,
    x_no_more_la_tran                   IN     VARCHAR2,
    x_star_x_avail                      IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    -- Added following 3 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_appno_first_opf                   IN     NUMBER ,
    x_appno_first_rpa_noneu             IN     NUMBER ,
    x_appno_first_rpa_eu                IN     NUMBER ,
    -- Added following 3 Columns as part of UCFD06 Build. Bug#2574566 by Nishikant
    x_extra_start_date                  IN     DATE,
    x_last_passport_date                IN     DATE,
    x_last_le_date                      IN     DATE,
    x_system_code                       IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER,
    -- Added following 2 Columns as part of UCCR008 Build. Bug#3239860 by arvsrini
    x_gttr_clear_toy_code               IN     VARCHAR2,
    x_transaction_toy_code              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_UC_UCAS_CONTROL
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
    new_references.entry_year                        := x_entry_year;
    new_references.time_of_year                      := x_time_of_year;
    new_references.time_of_day                       := x_time_of_day;
    new_references.routeb_time_of_year               := x_routeb_time_of_year;
    new_references.appno_first                       := x_appno_first;
    new_references.appno_maximum                     := x_appno_maximum;
    new_references.appno_last_used                   := x_appno_last_used;
    new_references.last_daily_run_no                 := x_last_daily_run_no;
    new_references.last_daily_run_date               := x_last_daily_run_date;
    new_references.appno_15dec                       := x_appno_15dec;
    new_references.run_date_15dec                    := x_run_date_15dec;
    new_references.appno_24mar                       := x_appno_24mar;
    new_references.run_date_24mar                    := x_run_date_24mar;
    new_references.appno_16may                       := x_appno_16may;
    new_references.run_date_16may                    := x_run_date_16may;
    new_references.appno_decision_proc               := x_appno_decision_proc;
    new_references.run_date_decision_proc            := x_run_date_decision_proc;
    new_references.appno_first_pre_num               := x_appno_first_pre_num;
    new_references.news                              := x_news;
    new_references.no_more_la_tran                   := x_no_more_la_tran;
    new_references.star_x_avail                      := x_star_x_avail;
    new_references.appno_first_opf                   := x_appno_first_opf;
    new_references.appno_first_rpa_noneu             := x_appno_first_rpa_noneu;
    new_references.appno_first_rpa_eu                := x_appno_first_rpa_eu;
    new_references.extra_start_date                  := x_extra_start_date;
    new_references.last_passport_date                := x_last_passport_date;
    new_references.last_le_date                      := x_last_le_date;
    new_references.system_code                       := x_system_code;
    new_references.ucas_cycle                        := x_ucas_cycle;
    new_references.gttr_clear_toy_code               := x_gttr_clear_toy_code;
    new_references.transaction_toy_code              := x_transaction_toy_code;

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
    x_system_code                       IN    VARCHAR2,
    x_ucas_cycle  IN NUMBER
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
      FROM     igs_uc_ucas_control
      WHERE    system_code = x_system_code
      AND      ucas_cycle  = x_ucas_cycle;

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
    x_entry_year                        IN     NUMBER  ,
    x_time_of_year                      IN     VARCHAR2,
    x_time_of_day                       IN     VARCHAR2,
    x_routeb_time_of_year               IN     VARCHAR2,
    x_appno_first                       IN     NUMBER  ,
    x_appno_maximum                     IN     NUMBER  ,
    x_appno_last_used                   IN     NUMBER  ,
    x_last_daily_run_no                 IN     NUMBER  ,
    x_last_daily_run_date               IN     DATE    ,
    x_appno_15dec                       IN     NUMBER  ,
    x_run_date_15dec                    IN     DATE    ,
    x_appno_24mar                       IN     NUMBER  ,
    x_run_date_24mar                    IN     DATE    ,
    x_appno_16may                       IN     NUMBER  ,
    x_run_date_16may                    IN     DATE    ,
    x_appno_decision_proc               IN     NUMBER  ,
    x_run_date_decision_proc            IN     DATE    ,
    x_appno_first_pre_num               IN     NUMBER  ,
    x_news                              IN     VARCHAR2,
    x_no_more_la_tran                   IN     VARCHAR2,
    x_star_x_avail                      IN     VARCHAR2,
    x_creation_date                     IN     DATE  ,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE  ,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    -- Added following 3 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_appno_first_opf                   IN     NUMBER,
    x_appno_first_rpa_noneu             IN     NUMBER,
    x_appno_first_rpa_eu                IN     NUMBER,
    -- Added following 3 Columns as part of UCFD06 Build. Bug#2574566 by Nishikant
    x_extra_start_date                  IN     DATE,
    x_last_passport_date                IN     DATE,
    x_last_le_date                      IN     DATE,
    x_system_code                       IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER,
     -- Added following 2 Columns as part of UCCR008 Build. Bug#3239860 by arvsrini
    x_gttr_clear_toy_code               IN     VARCHAR2,
    x_transaction_toy_code              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
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
      x_entry_year,
      x_time_of_year,
      x_time_of_day,
      x_routeb_time_of_year,
      x_appno_first,
      x_appno_maximum,
      x_appno_last_used,
      x_last_daily_run_no,
      x_last_daily_run_date,
      x_appno_15dec,
      x_run_date_15dec,
      x_appno_24mar,
      x_run_date_24mar,
      x_appno_16may,
      x_run_date_16may,
      x_appno_decision_proc,
      x_run_date_decision_proc,
      x_appno_first_pre_num,
      x_news,
      x_no_more_la_tran,
      x_star_x_avail,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_appno_first_opf,
      x_appno_first_rpa_noneu,
      x_appno_first_rpa_eu,
      x_extra_start_date,
      x_last_passport_date,
      x_last_le_date,
      x_system_code,
      x_ucas_cycle,
      x_gttr_clear_toy_code ,
      x_transaction_toy_code
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.


      IF ( get_pk_for_validation(new_references.system_code, new_references.ucas_cycle)
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation ( new_references.system_code, new_references.ucas_cycle )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_entry_year                        IN     NUMBER,
    x_time_of_year                      IN     VARCHAR2,
    x_time_of_day                       IN     VARCHAR2,
    x_routeb_time_of_year               IN     VARCHAR2,
    x_appno_first                       IN     NUMBER,
    x_appno_maximum                     IN     NUMBER,
    x_appno_last_used                   IN     NUMBER,
    x_last_daily_run_no                 IN     NUMBER,
    x_last_daily_run_date               IN     DATE,
    x_appno_15dec                       IN     NUMBER,
    x_run_date_15dec                    IN     DATE,
    x_appno_24mar                       IN     NUMBER,
    x_run_date_24mar                    IN     DATE,
    x_appno_16may                       IN     NUMBER,
    x_run_date_16may                    IN     DATE,
    x_appno_decision_proc               IN     NUMBER,
    x_run_date_decision_proc            IN     DATE,
    x_appno_first_pre_num               IN     NUMBER,
    x_news                              IN     VARCHAR2,
    x_no_more_la_tran                   IN     VARCHAR2,
    x_star_x_avail                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    -- Added following 3 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_appno_first_opf                   IN     NUMBER,
    x_appno_first_rpa_noneu             IN     NUMBER,
    x_appno_first_rpa_eu                IN     NUMBER,
    -- Added following 3 Columns as part of UCFD06 Build. Bug#2574566 by Nishikant
    x_extra_start_date                  IN     DATE,
    x_last_passport_date                IN     DATE,
    x_last_le_date                      IN     DATE,
    x_system_code                       IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER,
     -- Added following 2 Columns as part of UCCR008 Build. Bug#3239860 by arvsrini
    x_gttr_clear_toy_code               IN     VARCHAR2,
    x_transaction_toy_code              IN     VARCHAR2

  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who        When          What
  ||  jchakrab   20-Feb-2006   Modified cursor c for 3696223 - added WHERE clause
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_uc_ucas_control
      WHERE    system_code = x_system_code
      AND      ucas_cycle = x_ucas_cycle;


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
      x_entry_year                        => x_entry_year,
      x_time_of_year                      => x_time_of_year,
      x_time_of_day                       => x_time_of_day,
      x_routeb_time_of_year               => x_routeb_time_of_year,
      x_appno_first                       => x_appno_first,
      x_appno_maximum                     => x_appno_maximum,
      x_appno_last_used                   => x_appno_last_used,
      x_last_daily_run_no                 => x_last_daily_run_no,
      x_last_daily_run_date               => x_last_daily_run_date,
      x_appno_15dec                       => x_appno_15dec,
      x_run_date_15dec                    => x_run_date_15dec,
      x_appno_24mar                       => x_appno_24mar,
      x_run_date_24mar                    => x_run_date_24mar,
      x_appno_16may                       => x_appno_16may,
      x_run_date_16may                    => x_run_date_16may,
      x_appno_decision_proc               => x_appno_decision_proc,
      x_run_date_decision_proc            => x_run_date_decision_proc,
      x_appno_first_pre_num               => x_appno_first_pre_num,
      x_news                              => x_news,
      x_no_more_la_tran                   => x_no_more_la_tran,
      x_star_x_avail                      => x_star_x_avail,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_appno_first_opf                   => x_appno_first_opf,
      x_appno_first_rpa_noneu             => x_appno_first_rpa_noneu,
      x_appno_first_rpa_eu                => x_appno_first_rpa_eu,
    -- Added following 3 Columns as part of UCFD06 Build. Bug#2574566 by Nishikant
      x_extra_start_date                  => x_extra_start_date  ,
      x_last_passport_date                => x_last_passport_date,
      x_last_le_date                      => x_last_le_date      ,
      x_system_code                       => x_system_code ,
      x_ucas_cycle                        => x_ucas_cycle,
      x_gttr_clear_toy_code               => x_gttr_clear_toy_code,
      x_transaction_toy_code              => x_transaction_toy_code
    );

    INSERT INTO igs_uc_ucas_control (
      entry_year,
      time_of_year,
      time_of_day,
      routeb_time_of_year,
      appno_first,
      appno_maximum,
      appno_last_used,
      last_daily_run_no,
      last_daily_run_date,
      appno_15dec,
      run_date_15dec,
      appno_24mar,
      run_date_24mar,
      appno_16may,
      run_date_16may,
      appno_decision_proc,
      run_date_decision_proc,
      appno_first_pre_num,
      news,
      no_more_la_tran,
      star_x_avail,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      appno_first_opf,
      appno_first_rpa_noneu,
      appno_first_rpa_eu,
      extra_start_date,
      last_passport_date,
      last_le_date,
      system_code,
      ucas_cycle,
      gttr_clear_toy_code,
      transaction_toy_code

    ) VALUES (
      new_references.entry_year,
      new_references.time_of_year,
      new_references.time_of_day,
      new_references.routeb_time_of_year,
      new_references.appno_first,
      new_references.appno_maximum,
      new_references.appno_last_used,
      new_references.last_daily_run_no,
      new_references.last_daily_run_date,
      new_references.appno_15dec,
      new_references.run_date_15dec,
      new_references.appno_24mar,
      new_references.run_date_24mar,
      new_references.appno_16may,
      new_references.run_date_16may,
      new_references.appno_decision_proc,
      new_references.run_date_decision_proc,
      new_references.appno_first_pre_num,
      new_references.news,
      new_references.no_more_la_tran,
      new_references.star_x_avail,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.appno_first_opf,
      new_references.appno_first_rpa_noneu,
      new_references.appno_first_rpa_eu,
      new_references.extra_start_date  ,
      new_references.last_passport_date,
      new_references.last_le_date ,
      new_references.system_code,
      new_references.ucas_cycle,
      new_references.gttr_clear_toy_code,
      new_references.transaction_toy_code
    );

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
    x_entry_year                        IN     NUMBER,
    x_time_of_year                      IN     VARCHAR2,
    x_time_of_day                       IN     VARCHAR2,
    x_routeb_time_of_year               IN     VARCHAR2,
    x_appno_first                       IN     NUMBER,
    x_appno_maximum                     IN     NUMBER,
    x_appno_last_used                   IN     NUMBER,
    x_last_daily_run_no                 IN     NUMBER,
    x_last_daily_run_date               IN     DATE,
    x_appno_15dec                       IN     NUMBER,
    x_run_date_15dec                    IN     DATE,
    x_appno_24mar                       IN     NUMBER,
    x_run_date_24mar                    IN     DATE,
    x_appno_16may                       IN     NUMBER,
    x_run_date_16may                    IN     DATE,
    x_appno_decision_proc               IN     NUMBER,
    x_run_date_decision_proc            IN     DATE,
    x_appno_first_pre_num               IN     NUMBER,
    x_news                              IN     VARCHAR2,
    x_no_more_la_tran                   IN     VARCHAR2,
    x_star_x_avail                      IN     VARCHAR2,
    -- Added following 3 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_appno_first_opf                   IN     NUMBER,
    x_appno_first_rpa_noneu             IN     NUMBER,
    x_appno_first_rpa_eu                IN     NUMBER,
    -- Added following 3 Columns as part of UCFD06 Build. Bug#2574566 by Nishikant
    x_extra_start_date                  IN     DATE,
    x_last_passport_date                IN     DATE,
    x_last_le_date                      IN     DATE,
    x_system_code                       IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER,
     -- Added following 2 Columns as part of UCCR008 Build. Bug#3239860 by arvsrini
    x_gttr_clear_toy_code               IN     VARCHAR2,
    x_transaction_toy_code              IN     VARCHAR2


  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        entry_year,
        time_of_year,
        time_of_day,
        routeb_time_of_year,
        appno_first,
        appno_maximum,
        appno_last_used,
        last_daily_run_no,
        last_daily_run_date,
        appno_15dec,
        run_date_15dec,
        appno_24mar,
        run_date_24mar,
        appno_16may,
        run_date_16may,
        appno_decision_proc,
        run_date_decision_proc,
        appno_first_pre_num,
        news,
        no_more_la_tran,
        star_x_avail,
        appno_first_opf,
        appno_first_rpa_noneu,
        appno_first_rpa_eu,
        extra_start_date,
        last_passport_date,
        last_le_date,
        system_code,
        ucas_cycle,
        gttr_clear_toy_code,
        transaction_toy_code

      FROM  igs_uc_ucas_control
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
        ((tlinfo.entry_year = x_entry_year) OR ((tlinfo.entry_year IS NULL) AND (X_entry_year IS NULL)))
        AND ((tlinfo.time_of_year = x_time_of_year) OR ((tlinfo.time_of_year IS NULL) AND (X_time_of_year IS NULL)))
        AND ((tlinfo.time_of_day = x_time_of_day) OR ((tlinfo.time_of_day IS NULL) AND (X_time_of_day IS NULL)))
        AND ((tlinfo.routeb_time_of_year = x_routeb_time_of_year) OR ((tlinfo.routeb_time_of_year IS NULL) AND (X_routeb_time_of_year IS NULL)))
        AND ((tlinfo.appno_first = x_appno_first) OR ((tlinfo.appno_first IS NULL) AND (X_appno_first IS NULL)))
        AND ((tlinfo.appno_maximum = x_appno_maximum) OR ((tlinfo.appno_maximum IS NULL) AND (X_appno_maximum IS NULL)))
        AND ((tlinfo.appno_last_used = x_appno_last_used) OR ((tlinfo.appno_last_used IS NULL) AND (X_appno_last_used IS NULL)))
        AND ((tlinfo.last_daily_run_no = x_last_daily_run_no) OR ((tlinfo.last_daily_run_no IS NULL) AND (X_last_daily_run_no IS NULL)))
        AND ((TRUNC(tlinfo.last_daily_run_date) = TRUNC(x_last_daily_run_date)) OR ((tlinfo.last_daily_run_date IS NULL) AND (X_last_daily_run_date IS NULL)))
        AND ((tlinfo.appno_15dec = x_appno_15dec) OR ((tlinfo.appno_15dec IS NULL) AND (X_appno_15dec IS NULL)))
        AND ((TRUNC(tlinfo.run_date_15dec) = TRUNC(x_run_date_15dec)) OR ((tlinfo.run_date_15dec IS NULL) AND (X_run_date_15dec IS NULL)))
        AND ((tlinfo.appno_24mar = x_appno_24mar) OR ((tlinfo.appno_24mar IS NULL) AND (X_appno_24mar IS NULL)))
        AND ((TRUNC(tlinfo.run_date_24mar) = TRUNC(x_run_date_24mar)) OR ((tlinfo.run_date_24mar IS NULL) AND (X_run_date_24mar IS NULL)))
        AND ((tlinfo.appno_16may = x_appno_16may) OR ((tlinfo.appno_16may IS NULL) AND (X_appno_16may IS NULL)))
        AND ((TRUNC(tlinfo.run_date_16may) = TRUNC(x_run_date_16may)) OR ((tlinfo.run_date_16may IS NULL) AND (X_run_date_16may IS NULL)))
        AND ((tlinfo.appno_decision_proc = x_appno_decision_proc) OR ((tlinfo.appno_decision_proc IS NULL) AND (X_appno_decision_proc IS NULL)))
        AND ((TRUNC(tlinfo.run_date_decision_proc) = TRUNC(x_run_date_decision_proc)) OR ((tlinfo.run_date_decision_proc IS NULL) AND (X_run_date_decision_proc IS NULL)))
        AND ((tlinfo.appno_first_pre_num = x_appno_first_pre_num) OR ((tlinfo.appno_first_pre_num IS NULL) AND (X_appno_first_pre_num IS NULL)))
        AND ((tlinfo.news = x_news) OR ((tlinfo.news IS NULL) AND (X_news IS NULL)))
        AND ((tlinfo.no_more_la_tran = x_no_more_la_tran) OR ((tlinfo.no_more_la_tran IS NULL) AND (X_no_more_la_tran IS NULL)))
        AND ((tlinfo.star_x_avail = x_star_x_avail) OR ((tlinfo.star_x_avail IS NULL) AND (X_star_x_avail IS NULL)))
        AND (tlinfo.appno_first_opf       = x_appno_first_opf)
        AND (tlinfo.appno_first_rpa_noneu = x_appno_first_rpa_noneu)
        AND (tlinfo.appno_first_rpa_eu    = x_appno_first_rpa_eu)
        AND ((TRUNC(tlinfo.extra_start_date) = TRUNC(x_extra_start_date)) OR ((tlinfo.extra_start_date IS NULL) AND (x_extra_start_date IS NULL)))
        AND ((TRUNC(tlinfo.last_passport_date) = TRUNC(x_last_passport_date)) OR ((tlinfo.last_passport_date IS NULL) AND (x_last_passport_date IS NULL)))
        AND ((TRUNC(tlinfo.last_le_date) = TRUNC(x_last_le_date)) OR ((tlinfo.last_le_date IS NULL) AND (x_last_le_date IS NULL)))
        AND ((tlinfo.gttr_clear_toy_code = x_gttr_clear_toy_code) OR ((tlinfo.gttr_clear_toy_code IS NULL) AND (x_gttr_clear_toy_code IS NULL)))
        AND ((tlinfo.transaction_toy_code = x_transaction_toy_code) OR ((tlinfo.transaction_toy_code IS NULL) AND (x_transaction_toy_code IS NULL)))
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
    x_entry_year                        IN     NUMBER,
    x_time_of_year                      IN     VARCHAR2,
    x_time_of_day                       IN     VARCHAR2,
    x_routeb_time_of_year               IN     VARCHAR2,
    x_appno_first                       IN     NUMBER,
    x_appno_maximum                     IN     NUMBER,
    x_appno_last_used                   IN     NUMBER,
    x_last_daily_run_no                 IN     NUMBER,
    x_last_daily_run_date               IN     DATE,
    x_appno_15dec                       IN     NUMBER,
    x_run_date_15dec                    IN     DATE,
    x_appno_24mar                       IN     NUMBER,
    x_run_date_24mar                    IN     DATE,
    x_appno_16may                       IN     NUMBER,
    x_run_date_16may                    IN     DATE,
    x_appno_decision_proc               IN     NUMBER,
    x_run_date_decision_proc            IN     DATE,
    x_appno_first_pre_num               IN     NUMBER,
    x_news                              IN     VARCHAR2,
    x_no_more_la_tran                   IN     VARCHAR2,
    x_star_x_avail                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    -- Added following 3 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_appno_first_opf                   IN     NUMBER,
    x_appno_first_rpa_noneu             IN     NUMBER,
    x_appno_first_rpa_eu                IN     NUMBER,
    -- Added following 3 Columns as part of UCFD06 Build. Bug#2574566 by Nishikant
    x_extra_start_date                  IN     DATE,
    x_last_passport_date                IN     DATE,
    x_last_le_date                      IN     DATE,
    x_system_code                       IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER,
     -- Added following 2 Columns as part of UCCR008 Build. Bug#3239860 by arvsrini
    x_gttr_clear_toy_code               IN     VARCHAR2,
    x_transaction_toy_code              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
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
      x_entry_year                        => x_entry_year,
      x_time_of_year                      => x_time_of_year,
      x_time_of_day                       => x_time_of_day,
      x_routeb_time_of_year               => x_routeb_time_of_year,
      x_appno_first                       => x_appno_first,
      x_appno_maximum                     => x_appno_maximum,
      x_appno_last_used                   => x_appno_last_used,
      x_last_daily_run_no                 => x_last_daily_run_no,
      x_last_daily_run_date               => x_last_daily_run_date,
      x_appno_15dec                       => x_appno_15dec,
      x_run_date_15dec                    => x_run_date_15dec,
      x_appno_24mar                       => x_appno_24mar,
      x_run_date_24mar                    => x_run_date_24mar,
      x_appno_16may                       => x_appno_16may,
      x_run_date_16may                    => x_run_date_16may,
      x_appno_decision_proc               => x_appno_decision_proc,
      x_run_date_decision_proc            => x_run_date_decision_proc,
      x_appno_first_pre_num               => x_appno_first_pre_num,
      x_news                              => x_news,
      x_no_more_la_tran                   => x_no_more_la_tran,
      x_star_x_avail                      => x_star_x_avail,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_appno_first_opf                   => x_appno_first_opf,
      x_appno_first_rpa_noneu             => x_appno_first_rpa_noneu,
      x_appno_first_rpa_eu                => x_appno_first_rpa_eu,
      x_extra_start_date                  => x_extra_start_date  ,
      x_last_passport_date                => x_last_passport_date,
      x_last_le_date                         => x_last_le_date,
      x_system_code                       => x_system_code  ,
      x_ucas_cycle                        => x_ucas_cycle,
      x_gttr_clear_toy_code               => x_gttr_clear_toy_code,
      x_transaction_toy_code              => x_transaction_toy_code
     );

    UPDATE igs_uc_ucas_control
      SET
        entry_year                        = new_references.entry_year,
        time_of_year                      = new_references.time_of_year,
        time_of_day                       = new_references.time_of_day,
        routeb_time_of_year               = new_references.routeb_time_of_year,
        appno_first                       = new_references.appno_first,
        appno_maximum                     = new_references.appno_maximum,
        appno_last_used                   = new_references.appno_last_used,
        last_daily_run_no                 = new_references.last_daily_run_no,
        last_daily_run_date               = new_references.last_daily_run_date,
        appno_15dec                       = new_references.appno_15dec,
        run_date_15dec                    = new_references.run_date_15dec,
        appno_24mar                       = new_references.appno_24mar,
        run_date_24mar                    = new_references.run_date_24mar,
        appno_16may                       = new_references.appno_16may,
        run_date_16may                    = new_references.run_date_16may,
        appno_decision_proc               = new_references.appno_decision_proc,
        run_date_decision_proc            = new_references.run_date_decision_proc,
        appno_first_pre_num               = new_references.appno_first_pre_num,
        news                              = new_references.news,
        no_more_la_tran                   = new_references.no_more_la_tran,
        star_x_avail                      = new_references.star_x_avail,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        appno_first_opf                   = new_references.appno_first_opf,
        appno_first_rpa_noneu             = new_references.appno_first_rpa_noneu,
        appno_first_rpa_eu                = new_references.appno_first_rpa_eu,
        extra_start_date                  = new_references.extra_start_date,
        last_passport_date                          = new_references.last_passport_date ,
        last_le_date                                  = new_references.last_le_date,

        system_code                       = new_references.system_code  ,
        ucas_cycle                        = new_references.ucas_cycle,
        gttr_clear_toy_code               = new_references.gttr_clear_toy_code,
        transaction_toy_code              = new_references.transaction_toy_code



      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_entry_year                        IN     NUMBER,
    x_time_of_year                      IN     VARCHAR2,
    x_time_of_day                       IN     VARCHAR2,
    x_routeb_time_of_year               IN     VARCHAR2,
    x_appno_first                       IN     NUMBER,
    x_appno_maximum                     IN     NUMBER,
    x_appno_last_used                   IN     NUMBER,
    x_last_daily_run_no                 IN     NUMBER,
    x_last_daily_run_date               IN     DATE,
    x_appno_15dec                       IN     NUMBER,
    x_run_date_15dec                    IN     DATE,
    x_appno_24mar                       IN     NUMBER,
    x_run_date_24mar                    IN     DATE,
    x_appno_16may                       IN     NUMBER,
    x_run_date_16may                    IN     DATE,
    x_appno_decision_proc               IN     NUMBER,
    x_run_date_decision_proc            IN     DATE,
    x_appno_first_pre_num               IN     NUMBER,
    x_news                              IN     VARCHAR2,
    x_no_more_la_tran                   IN     VARCHAR2,
    x_star_x_avail                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    -- Added following 3 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_appno_first_opf                   IN     NUMBER,
    x_appno_first_rpa_noneu             IN     NUMBER,
    x_appno_first_rpa_eu                IN     NUMBER ,
    -- Added following 3 Columns as part of UCFD06 Build. Bug#2574566 by Nishikant
    x_extra_start_date                  IN     DATE,
    x_last_passport_date                IN     DATE,
    x_last_le_date                      IN     DATE,
    x_system_code                       IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER,
     -- Added following 2 Columns as part of UCCR008 Build. Bug#3239860 by arvsrini
    x_gttr_clear_toy_code               IN     VARCHAR2,
    x_transaction_toy_code              IN     VARCHAR2


  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who        When          What
  ||  jchakrab   20-Feb-2006   Modified cursor c1 for 3696223 - added WHERE clause
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_ucas_control
      WHERE    system_code = x_system_code
      AND      ucas_cycle = x_ucas_cycle;


  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_entry_year,
        x_time_of_year,
        x_time_of_day,
        x_routeb_time_of_year,
        x_appno_first,
        x_appno_maximum,
        x_appno_last_used,
        x_last_daily_run_no,
        x_last_daily_run_date,
        x_appno_15dec,
        x_run_date_15dec,
        x_appno_24mar,
        x_run_date_24mar,
        x_appno_16may,
        x_run_date_16may,
        x_appno_decision_proc,
        x_run_date_decision_proc,
        x_appno_first_pre_num,
        x_news,
        x_no_more_la_tran,
        x_star_x_avail,
        x_mode,
        x_appno_first_opf,
        x_appno_first_rpa_noneu,
        x_appno_first_rpa_eu,
        x_extra_start_date,
        x_last_passport_date,
        x_last_le_date,
        x_system_code,
        x_ucas_cycle,
        x_gttr_clear_toy_code,
        x_transaction_toy_code
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_entry_year,
      x_time_of_year,
      x_time_of_day,
      x_routeb_time_of_year,
      x_appno_first,
      x_appno_maximum,
      x_appno_last_used,
      x_last_daily_run_no,
      x_last_daily_run_date,
      x_appno_15dec,
      x_run_date_15dec,
      x_appno_24mar,
      x_run_date_24mar,
      x_appno_16may,
      x_run_date_16may,
      x_appno_decision_proc,
      x_run_date_decision_proc,
      x_appno_first_pre_num,
      x_news,
      x_no_more_la_tran,
      x_star_x_avail,
      x_mode,
      x_appno_first_opf,
      x_appno_first_rpa_noneu,
      x_appno_first_rpa_eu   ,
      x_extra_start_date,
      x_last_passport_date,
      x_last_le_date,
      x_system_code,
      x_ucas_cycle,
      x_gttr_clear_toy_code,
      x_transaction_toy_code
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
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

    DELETE FROM igs_uc_ucas_control
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_ucas_control_pkg;

/
