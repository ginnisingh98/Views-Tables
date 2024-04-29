--------------------------------------------------------
--  DDL for Package Body IGI_IAC_ASSET_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_ASSET_BALANCES_PKG" AS
-- $Header: igiiaabb.pls 120.6.12000000.1 2007/08/01 16:12:34 npandya ship $

--===========================FND_LOG.START=====================================
g_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiaabb.igi_iac_asset_balances_pkg.';
--===========================FND_LOG.END=====================================


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_asset_id                          IN     NUMBER,
    x_book_type_code                    IN     VARCHAR2,
    x_period_counter                    IN     NUMBER,
    x_net_book_value                    IN     NUMBER,
    x_adjusted_cost                     IN     NUMBER,
    x_operating_acct                    IN     NUMBER,
    x_reval_reserve                     IN     NUMBER,
    x_deprn_amount                      IN     NUMBER,
    x_deprn_reserve                     IN     NUMBER,
    x_backlog_deprn_reserve             IN     NUMBER,
    x_general_fund                      IN     NUMBER,
    x_last_reval_date                   IN     DATE,
    x_current_reval_factor              IN     NUMBER,
    x_cumulative_reval_factor           IN     NUMBER,
    x_mode                              IN     VARCHAR2 ) AS
  /*

  ||  Created By : Narayanan Iyer
  ||  Created On : 14-APR-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */


    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_creation_date              DATE;
    x_created_by                 NUMBER;


    CURSOR c IS
      SELECT   rowid
      FROM     igi_iac_asset_balances
      WHERE    asset_id                          = x_asset_id
      AND      book_type_code                    = x_book_type_code
      AND      period_counter                    = x_period_counter;


  BEGIN

    IF (x_mode = 'R') THEN
      x_last_update_date := SYSDATE;
      x_creation_date    := SYSDATE;
      x_created_by       := fnd_global.user_id;
      IF (x_created_by IS NULL) THEN
         x_created_by    := -1;
      END IF;
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
      igi_iac_debug_pkg.debug_other_msg(g_error_level,g_path||'insert_row',FALSE);
      app_exception.raise_exception;
    END IF;


    INSERT INTO igi_iac_asset_balances (
      asset_id,
      book_type_code,
      period_counter,
      net_book_value,
      adjusted_cost,
      operating_acct,
      reval_reserve,
      deprn_amount,
      deprn_reserve,
      backlog_deprn_reserve,
      general_fund,
      last_reval_date,
      current_reval_factor,
      cumulative_reval_factor,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      x_asset_id,
      x_book_type_code,

      x_period_counter,
      x_net_book_value,
      x_adjusted_cost,
      x_operating_acct,
      x_reval_reserve,
      x_deprn_amount,
      x_deprn_reserve,
      x_backlog_deprn_reserve,
      x_general_fund,
      x_last_reval_date,
      x_current_reval_factor,
      x_cumulative_reval_factor,
      x_creation_date,
      x_created_by,
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


  PROCEDURE update_row (
  --  x_rowid                             IN     VARCHAR2,
    x_asset_id                          IN     NUMBER,
    x_book_type_code                    IN     VARCHAR2,
    x_period_counter                    IN     NUMBER,
    x_net_book_value                    IN     NUMBER,
    x_adjusted_cost                     IN     NUMBER,
    x_operating_acct                    IN     NUMBER,
    x_reval_reserve                     IN     NUMBER,
    x_deprn_amount                      IN     NUMBER,
    x_deprn_reserve                     IN     NUMBER,
    x_backlog_deprn_reserve             IN     NUMBER,
    x_general_fund                      IN     NUMBER,
    x_last_reval_date                   IN     DATE,
    x_current_reval_factor              IN     NUMBER,
    x_cumulative_reval_factor           IN     NUMBER,

    x_mode                              IN     VARCHAR2 ) AS
  /*
  ||  Created By :
  ||  Created On : 14-APR-2002
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
      IF (x_mode = 'R') THEN
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
      igi_iac_debug_pkg.debug_other_msg(g_error_level,g_path||'update_row',FALSE);
      app_exception.raise_exception;
    END IF;

    UPDATE igi_iac_asset_balances
      SET
        net_book_value                    = x_net_book_value,
        adjusted_cost                     = x_adjusted_cost,
        operating_acct                    = x_operating_acct,
        reval_reserve                     = x_reval_reserve,
        deprn_amount                      = x_deprn_amount,
        deprn_reserve                     = x_deprn_reserve,
        backlog_deprn_reserve             = x_backlog_deprn_reserve,
        general_fund                      = x_general_fund,
        last_reval_date                   = x_last_reval_date,
        current_reval_factor              = x_current_reval_factor,

        cumulative_reval_factor           = x_cumulative_reval_factor,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE    asset_id                          = x_asset_id
      AND      book_type_code                    = x_book_type_code
      AND      period_counter                    = x_period_counter;


  END update_row;



  PROCEDURE delete_row (
    x_asset_id                          IN     NUMBER,
    x_book_type_code                    IN     VARCHAR2,
    x_period_counter                    IN     NUMBER
  ) AS
  /*
  ||  Created By : Narayanan Iyer
  ||  Created On : 14-APR-2002
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :

  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */


  BEGIN


    DELETE FROM igi_iac_asset_balances
    WHERE    asset_id                          = x_asset_id
    AND      book_type_code                    = x_book_type_code
    AND      period_counter                    = x_period_counter;


    /*
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
    */

  END delete_row;


END igi_iac_asset_balances_pkg;

/
