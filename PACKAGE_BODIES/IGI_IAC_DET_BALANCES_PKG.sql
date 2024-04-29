--------------------------------------------------------
--  DDL for Package Body IGI_IAC_DET_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_DET_BALANCES_PKG" AS
-- $Header: igiiadbb.pls 120.4.12000000.1 2007/08/01 16:14:19 npandya ship $

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiadbb.igi_iac_det_balances_pkg.';

--===========================FND_LOG.END=====================================

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_adjustment_id                     IN     NUMBER,
    x_asset_id                          IN     NUMBER,
    x_distribution_id                   IN     NUMBER,
    x_book_type_code                    IN     VARCHAR2,
    x_period_counter                    IN     NUMBER,
    x_adjustment_cost                   IN     NUMBER,
    x_net_book_value                    IN     NUMBER,
    x_reval_reserve_cost                IN     NUMBER,
    x_reval_reserve_backlog             IN     NUMBER,
    x_reval_reserve_gen_fund            IN     NUMBER,
    x_reval_reserve_net                 IN     NUMBER,
    x_operating_acct_cost               IN     NUMBER,
    x_operating_acct_backlog            IN     NUMBER,
    x_operating_acct_net                IN     NUMBER,
    x_operating_acct_ytd                IN     NUMBER,
    x_deprn_period                      IN     NUMBER,
    x_deprn_ytd                         IN     NUMBER,
    x_deprn_reserve                     IN     NUMBER,
    x_deprn_reserve_backlog             IN     NUMBER,
    x_general_fund_per                  IN     NUMBER,

    x_general_fund_acc                  IN     NUMBER,
    x_last_reval_date                   IN     DATE,
    x_current_reval_factor              IN     NUMBER,
    x_cumulative_reval_factor           IN     NUMBER,
    x_active_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
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

    l_path 			 VARCHAR2(100) := g_path||'insert_row';


    CURSOR c IS
      SELECT   rowid
      FROM     igi_iac_det_balances
      WHERE    adjustment_id = x_adjustment_id
      AND      asset_id      = x_asset_id
      AND      distribution_id = x_distribution_id
      AND      book_type_code  = x_book_type_code
      AND      period_counter  = x_period_counter;


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
      igi_iac_debug_pkg.debug_other_msg(g_error_level,l_path,FALSE);
      app_exception.raise_exception;
    END IF;


    INSERT INTO igi_iac_det_balances (
      adjustment_id,
      asset_id,
      distribution_id,
      book_type_code,
      period_counter,
      adjustment_cost,
      net_book_value,
      reval_reserve_cost,
      reval_reserve_backlog,
      reval_reserve_gen_fund,

      reval_reserve_net,
      operating_acct_cost,
      operating_acct_backlog,
      operating_acct_net,
      operating_acct_ytd,
      deprn_period,
      deprn_ytd,
      deprn_reserve,
      deprn_reserve_backlog,
      general_fund_per,
      general_fund_acc,
      last_reval_date,
      current_reval_factor,
      cumulative_reval_factor,
      active_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      x_adjustment_id,
      x_asset_id,

      x_distribution_id,
      x_book_type_code,
      x_period_counter,
      x_adjustment_cost,
      x_net_book_value,
      x_reval_reserve_cost,
      x_reval_reserve_backlog,
      x_reval_reserve_gen_fund,
      x_reval_reserve_net,
      x_operating_acct_cost,
      x_operating_acct_backlog,
      x_operating_acct_net,
      x_operating_acct_ytd,
      x_deprn_period,
      x_deprn_ytd,
      x_deprn_reserve,
      x_deprn_reserve_backlog,
      x_general_fund_per,
      x_general_fund_acc,
      x_last_reval_date,
      x_current_reval_factor,
      x_cumulative_reval_factor,
      x_active_flag,

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


  PROCEDURE Update_Row (
    x_adjustment_id                     IN     NUMBER,
    x_asset_id                          IN     NUMBER,
    x_distribution_id                   IN     NUMBER,
    x_book_type_code                    IN     VARCHAR2,
    x_period_counter                    IN     NUMBER,
    x_adjustment_cost                   IN     NUMBER,
    x_net_book_value                    IN     NUMBER,
    x_reval_reserve_cost                IN     NUMBER,
    x_reval_reserve_backlog             IN     NUMBER,
    x_reval_reserve_gen_fund            IN     NUMBER,
    x_reval_reserve_net                 IN     NUMBER,
    x_operating_acct_cost               IN     NUMBER,
    x_operating_acct_backlog            IN     NUMBER,
    x_operating_acct_net                IN     NUMBER,
    x_operating_acct_ytd                IN     NUMBER,
    x_deprn_period                      IN     NUMBER,
    x_deprn_ytd                         IN     NUMBER,
    x_deprn_reserve                     IN     NUMBER,
    x_deprn_reserve_backlog             IN     NUMBER,
    x_general_fund_per                  IN     NUMBER,
    x_general_fund_acc                  IN     NUMBER,
    x_last_reval_date                   IN     DATE,
    x_current_reval_factor              IN     NUMBER,
    x_cumulative_reval_factor           IN     NUMBER,
    x_active_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS

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

    l_path 			 VARCHAR2(100) := g_path||'Update_Row';
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
      igi_iac_debug_pkg.debug_other_msg(g_error_level,l_path,FALSE);
      app_exception.raise_exception;
    END IF;

    UPDATE igi_iac_det_balances SET
      adjustment_cost           = x_adjustment_cost,
      net_book_value            = x_net_book_value,
      reval_reserve_cost        = x_reval_reserve_cost,
      reval_reserve_backlog     = x_reval_reserve_backlog,
      reval_reserve_gen_fund    = x_reval_reserve_gen_fund,
      reval_reserve_net         = x_reval_reserve_net,
      operating_acct_cost       = x_operating_acct_cost,
      operating_acct_backlog    = x_operating_acct_backlog,
      operating_acct_net        = x_operating_acct_net,
      operating_acct_ytd        = x_operating_acct_ytd,
      deprn_period              = x_deprn_period,
      deprn_ytd                 = x_deprn_ytd,
      deprn_reserve             = x_deprn_reserve,
      deprn_reserve_backlog     = x_deprn_reserve_backlog,
      general_fund_per          = x_general_fund_per,
      general_fund_acc          = x_general_fund_acc,
      last_reval_date           = x_last_reval_date,
      current_reval_factor      = x_current_reval_factor,
      cumulative_reval_factor   = x_cumulative_reval_factor,
      active_flag               = x_active_flag,
      last_update_date          = x_last_update_date,
      last_updated_by           = x_last_updated_by,
      last_update_login         = x_last_update_login
    WHERE    adjustment_id = x_adjustment_id
    AND      asset_id      = x_asset_id
    AND      distribution_id = x_distribution_id
    AND      book_type_code  = x_book_type_code
    AND      period_counter  = x_period_counter;


  END Update_Row;


  PROCEDURE delete_row (
    x_adjustment_id                     IN     NUMBER,

    x_asset_id                          IN     NUMBER,
    x_distribution_id                   IN     NUMBER,
    x_book_type_code                    IN     VARCHAR2,
    x_period_counter                    IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 14-APR-2002
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    DELETE FROM igi_iac_det_balances
    WHERE    adjustment_id = x_adjustment_id
    AND      asset_id      = x_asset_id
    AND      distribution_id = x_distribution_id
    AND      book_type_code  = x_book_type_code
    AND      period_counter  = x_period_counter;


/*
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
*/

  END delete_row;


END igi_iac_det_balances_pkg;

/
