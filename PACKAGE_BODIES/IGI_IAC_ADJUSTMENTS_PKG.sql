--------------------------------------------------------
--  DDL for Package Body IGI_IAC_ADJUSTMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_ADJUSTMENTS_PKG" AS
-- $Header: igiiaadb.pls 120.8.12000000.2 2007/10/04 10:54:01 sharoy ship $

--===========================FND_LOG.START=====================================
g_state_level NUMBER;
g_proc_level  NUMBER;
g_event_level NUMBER;
g_excep_level NUMBER;
g_error_level NUMBER;
g_unexp_level NUMBER;
g_path        VARCHAR2(100);
--===========================FND_LOG.END=====================================

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_adjustment_id                     IN     NUMBER,
    x_book_type_code                    IN     VARCHAR2,
    x_code_combination_id               IN     NUMBER,
    x_set_of_books_id                   IN     NUMBER,
    x_dr_cr_flag                        IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_adjustment_type                   IN     VARCHAR2,
    x_adjustment_offset_type            IN     VARCHAR2,
    x_transfer_to_gl_flag               IN     VARCHAR2,
    x_units_assigned                    IN     NUMBER,
    x_asset_id                          IN     NUMBER,
    x_distribution_id                   IN     NUMBER,
    x_period_counter                    IN     NUMBER,
    x_report_ccid                       IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_event_id				IN     NUMBER       -- for R12 SLA upgrade

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

  /*  This is commented out NOCOPY as the this table contains multiple rows for the same
      adjustment id.
    CURSOR c IS
      SELECT   rowid
      FROM     igi_iac_adjustments
      WHERE    adjustment_id = x_adjustment_id;
  */

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_creation_date              DATE;

    x_created_by                 NUMBER;
    x_new_dr_cr_flag             VARCHAR2(2);
    x_new_amount                 NUMBER;
    l_mode                       VARCHAR2(1);
  BEGIN

    IF x_mode IS NULL THEN
        l_mode := 'R';
    ELSE
        l_mode := x_mode;
    END IF;

    IF (l_mode = 'R') THEN
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



    /* Bug 2454950 vgadde 10/07/2002 Start */
    /* Commented the below code as swapping is not required */
    /*  Bug 2462546 Ckappaga 16/07/2002 start*/
    /* uncommented the code and amde abs amount if negative */
     IF x_amount < 0 THEN
               x_new_amount := abs(x_amount);
              IF x_dr_cr_flag = 'DR' THEN --swap
          x_new_dr_cr_flag := 'CR';
       ELSIF x_dr_cr_flag = 'CR' THEN --swap
          x_new_dr_cr_flag := 'DR';
       END IF;
    ELSE
       x_new_dr_cr_flag := x_dr_cr_flag;
       x_new_amount := x_amount;
    END IF;
    /* Bug 2454950 vgadde 10/07/2002 End */
    /* Bug 2462546 ckappaga 16/07/2002 End */

    INSERT INTO igi_iac_adjustments (
      adjustment_id,
      book_type_code,
      code_combination_id,
      set_of_books_id,
      dr_cr_flag,
      amount,
      adjustment_type,
      adjustment_offset_type,
      transfer_to_gl_flag,
      units_assigned,
      asset_id,
      distribution_id,
      period_counter,
      report_ccid,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      event_id                       -- for R12 SLA upgrade
    ) VALUES (
      x_adjustment_id,
      x_book_type_code,
      x_code_combination_id,
      x_set_of_books_id,
      x_new_dr_cr_flag,
      x_new_amount,
      x_adjustment_type,
      x_adjustment_offset_type,
      x_transfer_to_gl_flag,
      x_units_assigned,
      x_asset_id,
      x_distribution_id,
      x_period_counter,
      x_report_ccid,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_event_id                      -- for R12 SLA upgrade
    );


  /*  This is commented out NOCOPY as the this table contains multiple rows for the same
      adjustment id.
    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;
  */


  END insert_row;



  PROCEDURE delete_row (

    x_adjustment_id   IN     NUMBER
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

    DELETE FROM igi_iac_adjustments
    WHERE adjustment_id  = x_adjustment_id;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;

BEGIN
    --===========================FND_LOG.START=====================================
    g_state_level :=	FND_LOG.LEVEL_STATEMENT;
    g_proc_level  :=	FND_LOG.LEVEL_PROCEDURE;
    g_event_level :=	FND_LOG.LEVEL_EVENT;
    g_excep_level :=	FND_LOG.LEVEL_EXCEPTION;
    g_error_level :=	FND_LOG.LEVEL_ERROR;
    g_unexp_level :=	FND_LOG.LEVEL_UNEXPECTED;
    g_path        := 'IGI.PLSQL.igiiaadb.igi_arc_rxi.';
    --===========================FND_LOG.END=====================================

END igi_iac_adjustments_pkg;

/
