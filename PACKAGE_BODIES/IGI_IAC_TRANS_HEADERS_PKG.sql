--------------------------------------------------------
--  DDL for Package Body IGI_IAC_TRANS_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_TRANS_HEADERS_PKG" AS
-- $Header: igiiathb.pls 120.4.12000000.2 2007/10/31 16:12:48 npandya ship $


  --===========================FND_LOG.START=====================================

  g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
  g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
  g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
  g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
  g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
  g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
  g_path        VARCHAR2(100):= 'IGI.PLSQL.igiiathb.igi_iac_trans_headers_pkg.';

  --===========================FND_LOG.END=====================================

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_adjustment_id                     IN OUT NOCOPY NUMBER,
    x_transaction_header_id             IN     NUMBER,
    x_adjustment_id_out                 IN     NUMBER,
    x_transaction_type_code             IN     VARCHAR2,
    x_transaction_date_entered          IN     DATE,
    x_mass_refrence_id                  IN     NUMBER,
    x_transaction_sub_type              IN     VARCHAR2,
    x_book_type_code                    IN     VARCHAR2,
    x_asset_id                          IN     NUMBER,
    x_category_id                       IN     NUMBER,
    x_adj_deprn_start_date              IN     DATE,
    x_revaluation_type_flag             IN     VARCHAR2,
    x_adjustment_status                 IN     VARCHAR2,
    x_period_counter                    IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_event_id                          in     number
  ) AS
  /*
  ||  Created By : Narayanan Iyer
  ||  Created On : 14-APR-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :

  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igi_iac_transaction_headers
      WHERE    adjustment_id                     = x_adjustment_id;

    CURSOR c1 IS
    SELECT    igi_iac_transaction_headers_s.NEXTVAL
    FROM      sys.dual;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_creation_date              DATE;
    x_created_by                 NUMBER;
    l_path_name VARCHAR2(150) := g_path||'insert_row';

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
      igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  p_full_path => l_path_name,
		  p_remove_from_stack => FALSE);
      app_exception.raise_exception;
    END IF;

   IF x_adjustment_id is null THEN
      OPEN c1;
      FETCH c1 INTO x_adjustment_id;
      CLOSE c1;
   END IF;




    INSERT INTO igi_iac_transaction_headers (
      adjustment_id,
      transaction_header_id,
      adjustment_id_out,
      transaction_type_code,
      transaction_date_entered,
      mass_reference_id,
      transaction_sub_type,
      book_type_code,
      asset_id,
      category_id,
      adj_deprn_start_date,
      revaluation_type_flag,
      adjustment_status,
      period_counter,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      event_id

    ) VALUES (
      x_adjustment_id,
      x_transaction_header_id,
      x_adjustment_id_out,
      x_transaction_type_code,
      x_transaction_date_entered,
      x_mass_refrence_id,
      x_transaction_sub_type,
      x_book_type_code,
      x_asset_id,
      x_category_id,
      x_adj_deprn_start_date,
      x_revaluation_type_flag,
      x_adjustment_status,
      x_period_counter,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_event_id
    );

    OPEN c;

    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

  END insert_row;


  -- For FND logging purpose this procedure has been aliased as update_row1
  PROCEDURE update_row (
  --  x_rowid                             IN     VARCHAR2,
    x_prev_adjustment_id                IN     NUMBER,
    x_adjustment_id                     IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Narayanan Iyer
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
    l_path_name VARCHAR2(150) := g_path||'update_row1';

/*
      CURSOR c IS
      SELECT   rowid
      FROM     igi_iac_transaction_headers
      WHERE    adjustment_id                     = x_prev_adjustment_id;
*/


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
      igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  p_full_path => l_path_name,
		  p_remove_from_stack => FALSE);
      app_exception.raise_exception;
    END IF;

/*
    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;
  */


    UPDATE igi_iac_transaction_headers
      SET
        adjustment_id_out                 = x_adjustment_id,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
--      WHERE rowid = x_rowid
        WHERE adjustment_id = x_prev_adjustment_id;

  /*
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  */

  END update_row;


  -- For FND logging purpose this procedure has been aliased as update_row2
  PROCEDURE update_row (
  --  x_rowid                             IN     VARCHAR2,
    x_adjustment_id                     IN     NUMBER,
    x_adjustment_status                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2

  ) AS
  /*
  ||  Created By : Narayanan Iyer
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
    l_path_name VARCHAR2(150) := g_path||'update_row2';

      CURSOR c IS
      SELECT   rowid
      FROM     igi_iac_transaction_headers
      WHERE    adjustment_id                     = x_adjustment_id;

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
      igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  p_full_path => l_path_name,
		  p_remove_from_stack => FALSE);
      app_exception.raise_exception;
    END IF;

/*
    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;

    END IF;
    CLOSE c;
*/

    UPDATE igi_iac_transaction_headers
      SET
        adjustment_status                 = x_adjustment_status,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
--      WHERE rowid = x_rowid
        WHERE adjustment_id = x_adjustment_id;

/*
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
*/

  END update_row;


  PROCEDURE delete_row (

    x_adjustment_id  IN     NUMBER
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


    DELETE FROM igi_iac_transaction_headers
    WHERE adjustment_id = x_adjustment_id;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;



END igi_iac_trans_headers_pkg;

/
