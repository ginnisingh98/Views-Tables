--------------------------------------------------------
--  DDL for Package Body PA_UTILIZATION_OPTIONS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_UTILIZATION_OPTIONS_ALL_PKG" AS
/* $Header: PARUTOPB.pls 120.1 2005/08/19 17:03:01 mwasowic noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
    x_org_id                            IN     NUMBER,
    x_gl_period_flag                    IN     VARCHAR2,
    x_pa_period_flag                    IN     VARCHAR2,
    x_global_exp_period_flag            IN     VARCHAR2,
    x_forecast_thru_date                IN     DATE,
    x_actuals_thru_date                 IN     DATE,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By :
  ||  Created On : 16-OCT-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     pa_utilization_options_all
      WHERE    nvl(org_id,-99)                            = nvl(x_org_id,-99);

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
      app_exception.raise_exception;
    END IF;

    INSERT INTO pa_utilization_options_all (
      org_id,
      gl_period_flag,
      pa_period_flag,
      global_exp_period_flag,
      forecast_thru_date,
      actuals_thru_date,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      x_org_id,
      x_gl_period_flag,
      x_pa_period_flag,
      x_global_exp_period_flag,
      x_forecast_thru_date,
      x_actuals_thru_date,
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
    x_org_id                            IN     NUMBER,
    x_gl_period_flag                    IN     VARCHAR2,
    x_pa_period_flag                    IN     VARCHAR2,
    x_global_exp_period_flag            IN     VARCHAR2,
    x_forecast_thru_date                IN     DATE,
    x_actuals_thru_date                 IN     DATE
  ) AS
  /*
  ||  Created By :
  ||  Created On : 16-OCT-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        gl_period_flag,
        pa_period_flag,
        global_exp_period_flag,
        forecast_thru_date,
        actuals_thru_date
      FROM  pa_utilization_options_all
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.gl_period_flag = x_gl_period_flag)
        AND (tlinfo.pa_period_flag = x_pa_period_flag)
        AND (tlinfo.global_exp_period_flag = x_global_exp_period_flag)
        AND (tlinfo.forecast_thru_date = x_forecast_thru_date)
        AND (tlinfo.actuals_thru_date = x_actuals_thru_date)
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_gl_period_flag                    IN     VARCHAR2,
    x_pa_period_flag                    IN     VARCHAR2,
    x_global_exp_period_flag            IN     VARCHAR2,
    x_forecast_thru_date                IN     DATE,
    x_actuals_thru_date                 IN     DATE,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By :
  ||  Created On : 16-OCT-2000
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
      app_exception.raise_exception;
    END IF;

    UPDATE pa_utilization_options_all
      SET
        gl_period_flag                    = x_gl_period_flag,
        pa_period_flag                    = x_pa_period_flag,
        global_exp_period_flag            = x_global_exp_period_flag,
        forecast_thru_date                = x_forecast_thru_date,
        actuals_thru_date                 = x_actuals_thru_date,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 16-OCT-2000
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    DELETE FROM pa_utilization_options_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END pa_utilization_options_all_pkg;

/
