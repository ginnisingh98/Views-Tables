--------------------------------------------------------
--  DDL for Package Body IGI_IAC_PROJ_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_PROJ_DETAILS_PKG" AS
/* $Header: igiiapdb.pls 120.5.12000000.1 2007/08/01 16:15:47 npandya ship $ */

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiapdb.igi_iac_proj_details_pkg.';

--===========================FND_LOG.END=======================================

  l_rowid VARCHAR2(25);
  old_references igi_iac_proj_details%ROWTYPE;
  new_references igi_iac_proj_details%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2   ,
    x_projection_id                     IN     NUMBER     ,
    x_period_counter                    IN     NUMBER     ,
    x_fiscal_year                       IN     NUMBER     ,
    x_company                           IN     VARCHAR2    ,
    x_cost_center                       IN     VARCHAR2    ,
    x_account                           IN     VARCHAR2    ,
    x_asset_id                          IN     NUMBER      ,
    x_latest_reval_cost                 IN     NUMBER      ,
    x_deprn_period                      IN     NUMBER      ,
    x_deprn_ytd                         IN     NUMBER      ,
    x_deprn_reserve                     IN     NUMBER      ,
    x_asset_exception                   IN     VARCHAR2    ,
    x_revaluation_flag                  IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER    ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 30-MAY-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igi_iac_proj_details
      WHERE    rowid = x_rowid;
    l_path varchar2(150) := g_path||'set_column_values';
  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igi_iac_debug_pkg.debug_other_msg(g_error_level,l_path,FALSE);
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.projection_id                     := x_projection_id;
    new_references.period_counter                    := x_period_counter;
    new_references.fiscal_year                       := x_fiscal_year;
    new_references.company                           := x_company;
    new_references.cost_center                       := x_cost_center;
    new_references.account                           := x_account;
    new_references.asset_id                          := x_asset_id;
    new_references.latest_reval_cost                 := x_latest_reval_cost;
    new_references.deprn_period                      := x_deprn_period;
    new_references.deprn_ytd                         := x_deprn_ytd;
    new_references.deprn_reserve                     := x_deprn_reserve;
    new_references.asset_exception                   := x_asset_exception;
    new_references.revaluation_flag                  := x_revaluation_flag;

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
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 30-MAY-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    l_path varchar2(150) := g_path||'check_parent_existance';
  BEGIN

    IF (((old_references.projection_id = new_references.projection_id)) OR
        ((new_references.projection_id IS NULL))) THEN
      NULL;
    ELSIF NOT igi_iac_projections_pkg.get_pk_for_validation (
                new_references.projection_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igi_iac_debug_pkg.debug_other_msg(g_error_level,l_path,FALSE);
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_projection_id                     IN     NUMBER,
    x_asset_id                          IN     NUMBER,
    x_period_counter                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 30-MAY-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_iac_proj_details
      WHERE    projection_id = x_projection_id
      AND      asset_id = x_asset_id
      AND      period_counter = x_period_counter
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


  PROCEDURE get_fk_igi_iac_projections (
    x_projection_id                     IN     NUMBER
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 30-MAY-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_iac_proj_details
      WHERE   ((projection_id = x_projection_id));

    lv_rowid cur_rowid%RowType;
    l_path varchar2(150) := g_path||'get_fk_igi_iac_projections';
  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('FND', 'FND-CANNOT DELETE MASTER');
      igi_iac_debug_pkg.debug_other_msg(g_error_level,l_path,FALSE);
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igi_iac_projections;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2   ,
    x_projection_id                     IN     NUMBER      ,
    x_period_counter                    IN     NUMBER      ,
    x_fiscal_year                       IN     NUMBER      ,
    x_company                           IN     VARCHAR2    ,
    x_cost_center                       IN     VARCHAR2    ,
    x_account                           IN     VARCHAR2    ,
    x_asset_id                          IN     NUMBER      ,
    x_latest_reval_cost                 IN     NUMBER      ,
    x_deprn_period                      IN     NUMBER      ,
    x_deprn_ytd                         IN     NUMBER      ,
    x_deprn_reserve                     IN     NUMBER      ,
    x_asset_exception                   IN     VARCHAR2    ,
    x_revaluation_flag                  IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 30-MAY-2002
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
      l_path varchar2(150) := g_path||'before_dml';
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_projection_id,
      x_period_counter,
      x_fiscal_year,
      x_company,
      x_cost_center,
      x_account,
      x_asset_id,
      x_latest_reval_cost,
      x_deprn_period,
      x_deprn_ytd,
      x_deprn_reserve,
      x_asset_exception,
      x_revaluation_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.projection_id,
             new_references.asset_id,
             new_references.period_counter
           )
         ) THEN
        fnd_message.set_name('FND','FORM_DUPLICATE_KEY_IN_INDEX');
        igi_iac_debug_pkg.debug_other_msg(g_error_level,l_path,FALSE);
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.projection_id,
             new_references.asset_id,
             new_references.period_counter
           )
         ) THEN
        fnd_message.set_name('FND','FORM_DUPLICATE_KEY_IN_INDEX');
        igi_iac_debug_pkg.debug_other_msg(g_error_level,l_path,FALSE);
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_projection_id                     IN     NUMBER,
    x_period_counter                    IN     NUMBER,
    x_fiscal_year                       IN     NUMBER,
    x_company                           IN     VARCHAR2,
    x_cost_center                       IN     VARCHAR2,
    x_account                           IN     VARCHAR2,
    x_asset_id                          IN     NUMBER,
    x_latest_reval_cost                 IN     NUMBER,
    x_deprn_period                      IN     NUMBER,
    x_deprn_ytd                         IN     NUMBER,
    x_deprn_reserve                     IN     NUMBER,
    x_asset_exception                   IN     VARCHAR2,
    x_revaluation_flag                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 30-MAY-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igi_iac_proj_details
      WHERE    projection_id                     = x_projection_id
      AND      asset_id                          = x_asset_id
      AND      period_counter                    = x_period_counter;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    l_path 			 varchar2(150) := g_path||'insert_row';
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
      igi_iac_debug_pkg.debug_other_msg(g_error_level,l_path,FALSE);
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_projection_id                     => x_projection_id,
      x_period_counter                    => x_period_counter,
      x_fiscal_year                       => x_fiscal_year,
      x_company                           => x_company,
      x_cost_center                       => x_cost_center,
      x_account                           => x_account,
      x_asset_id                          => x_asset_id,
      x_latest_reval_cost                 => x_latest_reval_cost,
      x_deprn_period                      => x_deprn_period,
      x_deprn_ytd                         => x_deprn_ytd,
      x_deprn_reserve                     => x_deprn_reserve,
      x_asset_exception                   => x_asset_exception,
      x_revaluation_flag                  => x_revaluation_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igi_iac_proj_details (
      projection_id,
      period_counter,
      fiscal_year,
      company,
      cost_center,
      account,
      asset_id,
      latest_reval_cost,
      deprn_period,
      deprn_ytd,
      deprn_reserve,
      asset_exception,
      revaluation_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.projection_id,
      new_references.period_counter,
      new_references.fiscal_year,
      new_references.company,
      new_references.cost_center,
      new_references.account,
      new_references.asset_id,
      new_references.latest_reval_cost,
      new_references.deprn_period,
      new_references.deprn_ytd,
      new_references.deprn_reserve,
      new_references.asset_exception,
      new_references.revaluation_flag,
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

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_projection_id                     IN     NUMBER,
    x_period_counter                    IN     NUMBER,
    x_fiscal_year                       IN     NUMBER,
    x_company                           IN     VARCHAR2,
    x_cost_center                       IN     VARCHAR2,
    x_account                           IN     VARCHAR2,
    x_asset_id                          IN     NUMBER,
    x_latest_reval_cost                 IN     NUMBER,
    x_deprn_period                      IN     NUMBER,
    x_deprn_ytd                         IN     NUMBER,
    x_deprn_reserve                     IN     NUMBER,
    x_asset_exception                   IN     VARCHAR2,
    x_revaluation_flag                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 30-MAY-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        fiscal_year,
        company,
        cost_center,
        account,
        latest_reval_cost,
        deprn_period,
        deprn_ytd,
        deprn_reserve,
        asset_exception,
        revaluation_flag
      FROM  igi_iac_proj_details
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;
    l_path varchar2(150) := g_path||'lock_row';
  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igi_iac_debug_pkg.debug_other_msg(g_error_level,l_path,FALSE);
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.fiscal_year = x_fiscal_year)
        AND (tlinfo.company = x_company)
        AND (tlinfo.cost_center = x_cost_center)
        AND ((tlinfo.account = x_account) OR ((tlinfo.account IS NULL) AND (X_account IS NULL)))
        AND ((tlinfo.latest_reval_cost = x_latest_reval_cost) OR ((tlinfo.latest_reval_cost IS NULL) AND (X_latest_reval_cost IS NULL)))
        AND ((tlinfo.deprn_period = x_deprn_period) OR ((tlinfo.deprn_period IS NULL) AND (X_deprn_period IS NULL)))
        AND ((tlinfo.deprn_ytd = x_deprn_ytd) OR ((tlinfo.deprn_ytd IS NULL) AND (X_deprn_ytd IS NULL)))
        AND ((tlinfo.deprn_reserve = x_deprn_reserve) OR ((tlinfo.deprn_reserve IS NULL) AND (X_deprn_reserve IS NULL)))
        AND ((tlinfo.asset_exception = x_asset_exception) OR ((tlinfo.asset_exception IS NULL) AND (X_asset_exception IS NULL)))
        AND ((tlinfo.revaluation_flag = x_revaluation_flag) OR ((tlinfo.revaluation_flag IS NULL) AND (X_revaluation_flag IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igi_iac_debug_pkg.debug_other_msg(g_error_level,l_path,FALSE);
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_projection_id                     IN     NUMBER,
    x_period_counter                    IN     NUMBER,
    x_fiscal_year                       IN     NUMBER,
    x_company                           IN     VARCHAR2,
    x_cost_center                       IN     VARCHAR2,
    x_account                           IN     VARCHAR2,
    x_asset_id                          IN     NUMBER,
    x_latest_reval_cost                 IN     NUMBER,
    x_deprn_period                      IN     NUMBER,
    x_deprn_ytd                         IN     NUMBER,
    x_deprn_reserve                     IN     NUMBER,
    x_asset_exception                   IN     VARCHAR2,
    x_revaluation_flag                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 30-MAY-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    l_path 			 varchar2(150) := g_path||'update_row';
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
      igi_iac_debug_pkg.debug_other_msg(g_error_level,l_path,FALSE);
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_projection_id                     => x_projection_id,
      x_period_counter                    => x_period_counter,
      x_fiscal_year                       => x_fiscal_year,
      x_company                           => x_company,
      x_cost_center                       => x_cost_center,
      x_account                           => x_account,
      x_asset_id                          => x_asset_id,
      x_latest_reval_cost                 => x_latest_reval_cost,
      x_deprn_period                      => x_deprn_period,
      x_deprn_ytd                         => x_deprn_ytd,
      x_deprn_reserve                     => x_deprn_reserve,
      x_asset_exception                   => x_asset_exception,
      x_revaluation_flag                  => x_revaluation_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igi_iac_proj_details
      SET
        fiscal_year                       = new_references.fiscal_year,
        company                           = new_references.company,
        cost_center                       = new_references.cost_center,
        account                           = new_references.account,
        latest_reval_cost                 = new_references.latest_reval_cost,
        deprn_period                      = new_references.deprn_period,
        deprn_ytd                         = new_references.deprn_ytd,
        deprn_reserve                     = new_references.deprn_reserve,
        asset_exception                   = new_references.asset_exception,
        revaluation_flag                  = new_references.revaluation_flag,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_projection_id                     IN     NUMBER,
    x_period_counter                    IN     NUMBER,
    x_fiscal_year                       IN     NUMBER,
    x_company                           IN     VARCHAR2,
    x_cost_center                       IN     VARCHAR2,
    x_account                           IN     VARCHAR2,
    x_asset_id                          IN     NUMBER,
    x_latest_reval_cost                 IN     NUMBER,
    x_deprn_period                      IN     NUMBER,
    x_deprn_ytd                         IN     NUMBER,
    x_deprn_reserve                     IN     NUMBER,
    x_asset_exception                   IN     VARCHAR2,
    x_revaluation_flag                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 30-MAY-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igi_iac_proj_details
      WHERE    projection_id                     = x_projection_id
      AND      asset_id                          = x_asset_id
      AND      period_counter                    = x_period_counter;
  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_projection_id,
        x_period_counter,
        x_fiscal_year,
        x_company,
        x_cost_center,
        x_account,
        x_asset_id,
        x_latest_reval_cost,
        x_deprn_period,
        x_deprn_ytd,
        x_deprn_reserve,
        x_asset_exception,
        x_revaluation_flag,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_projection_id,
      x_period_counter,
      x_fiscal_year,
      x_company,
      x_cost_center,
      x_account,
      x_asset_id,
      x_latest_reval_cost,
      x_deprn_period,
      x_deprn_ytd,
      x_deprn_reserve,
      x_asset_exception,
      x_revaluation_flag,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 30-MAY-2002
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

    DELETE FROM igi_iac_proj_details
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igi_iac_proj_details_pkg;

/
