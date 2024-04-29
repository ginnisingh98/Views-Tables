--------------------------------------------------------
--  DDL for Package Body IGI_IAC_FA_DEPRN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_FA_DEPRN_PKG" AS
-- $Header: igiiafdb.pls 120.4.12000000.1 2007/08/01 16:15:29 npandya noship $

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiafdb.igi_iac_fa_deprn_pkg.';

--===========================FND_LOG.END=======================================


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_book_type_code                    IN     VARCHAR2,
    x_asset_id                          IN     NUMBER,
    x_period_counter                    IN     NUMBER,
    x_adjustment_id                     IN     NUMBER,
    x_distribution_id                   IN     NUMBER,
    x_deprn_period                      IN     NUMBER,
    x_deprn_ytd                         IN     NUMBER,
    x_deprn_reserve                     IN     NUMBER,
    x_active_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 23-SEP-2002
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
      FROM     igi_iac_fa_deprn
      WHERE    adjustment_id = x_adjustment_id
      AND      asset_id      = x_asset_id
      AND      distribution_id = x_distribution_id
      AND      book_type_code  = x_book_type_code
      AND      period_counter  = x_period_counter;

      l_path 		 VARCHAR2(150) := g_path||'insert_row';

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


    INSERT INTO igi_iac_fa_deprn (
      book_type_code,
      asset_id,
      period_counter,
      adjustment_id,
      distribution_id,
      deprn_period,
      deprn_ytd,
      deprn_reserve,
      active_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      x_book_type_code,
      x_asset_id,
      x_period_counter,
      x_adjustment_id,
      x_distribution_id,
      x_deprn_period,
      x_deprn_ytd,
      x_deprn_reserve,
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
    x_book_type_code                    IN     VARCHAR2,
    x_asset_id                          IN     NUMBER,
    x_period_counter                    IN     NUMBER,
    x_adjustment_id                     IN     NUMBER,
    x_distribution_id                   IN     NUMBER,
    x_deprn_period                      IN     NUMBER,
    x_deprn_ytd                         IN     NUMBER,
    x_deprn_reserve                     IN     NUMBER,
    x_active_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS

  /*
  ||  Created By :
  ||  Created On : 23-SEP-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

    l_path 			 VARCHAR2(150) := g_path||'Update_Row';

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

    UPDATE igi_iac_fa_deprn SET
      deprn_period              = x_deprn_period,
      deprn_ytd                 = x_deprn_ytd,
      deprn_reserve             = x_deprn_reserve,
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
    x_book_type_code                    IN     VARCHAR2,
    x_asset_id                          IN     NUMBER,
    x_period_counter                    IN     NUMBER,
    x_adjustment_id                     IN     NUMBER,
    x_distribution_id                   IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 23-SEP-2002
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    DELETE FROM igi_iac_fa_deprn
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


END igi_iac_fa_deprn_pkg;

/
