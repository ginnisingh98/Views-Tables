--------------------------------------------------------
--  DDL for Package Body IGI_IAC_BOOK_CONTROLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_BOOK_CONTROLS_PKG" AS
-- $Header: igiiabcb.pls 120.7.12000000.1 2007/08/01 16:12:51 npandya ship $

  l_rowid VARCHAR2(25);

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

    x_book_type_code                    IN     VARCHAR2,

    x_gl_je_source                      IN     VARCHAR2,

    x_je_iac_deprn_category             IN     VARCHAR2,

    x_je_iac_reval_category             IN     VARCHAR2,

    x_je_iac_txn_category               IN     VARCHAR2,

    x_period_num_for_catchup            IN     NUMBER,

    x_mode                              IN     VARCHAR2

  ) AS

  /*

  ||  Created By :

  ||  Created On : 29-APR-2002

  ||  Purpose : Handles the INSERT DML logic for the table.

  ||  Known limitations, enhancements or remarks :

  ||  Change History :

  ||  Who             When            What

  ||  (reverse chronological order - newest change first)

  */

    CURSOR c IS

      SELECT   rowid

      FROM     igi_iac_book_controls

      WHERE    book_type_code = x_book_type_code;



    x_last_update_date           DATE;

    x_last_updated_by            NUMBER;

    x_last_update_login          NUMBER;

    x_org_id                     NUMBER;

  BEGIN

    x_org_id := NULL;

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
      igi_iac_debug_pkg.debug_other_msg(g_error_level,g_path||'insert_row',FALSE);
      app_exception.raise_exception;

    END IF;

    INSERT INTO igi_iac_book_controls (

      book_type_code,

      gl_je_source,

      je_iac_deprn_category,

      je_iac_reval_category,

      je_iac_txn_category,

      period_num_for_catchup,

      org_id,

      creation_date,

      created_by,

      last_update_date,

      last_updated_by,

      last_update_login

    ) VALUES (

      x_book_type_code,

      x_gl_je_source,

      x_je_iac_deprn_category,

      x_je_iac_reval_category,

      x_je_iac_txn_category,

      x_period_num_for_catchup,

      x_org_id,

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

    x_book_type_code                    IN     VARCHAR2,

    x_gl_je_source                      IN     VARCHAR2,

    x_je_iac_deprn_category             IN     VARCHAR2,

    x_je_iac_reval_category             IN     VARCHAR2,

    x_je_iac_txn_category               IN     VARCHAR2,

    x_period_num_for_catchup            IN     NUMBER

  ) AS

  /*

  ||  Created By :

  ||  Created On : 29-APR-2002

  ||  Purpose : Handles the LOCK mechanism for the table.

  ||  Known limitations, enhancements or remarks :

  ||  Change History :

  ||  Who             When            What

  ||  (reverse chronological order - newest change first)

  */

    CURSOR c1 IS

      SELECT

        book_type_code,

        gl_je_source,

        je_iac_deprn_category,

        je_iac_reval_category,

        je_iac_txn_category,

        period_num_for_catchup

      FROM  igi_iac_book_controls

      WHERE rowid = x_rowid

      FOR UPDATE NOWAIT;



    tlinfo c1%ROWTYPE;



  BEGIN



    OPEN c1;

    FETCH c1 INTO tlinfo;

    IF (c1%notfound) THEN

      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igi_iac_debug_pkg.debug_other_msg(g_error_level,g_path||'lock_row',FALSE);
      CLOSE c1;

      app_exception.raise_exception;

      RETURN;

    END IF;

    CLOSE c1;



    IF (

        (tlinfo.book_type_code = x_book_type_code)

        AND (tlinfo.gl_je_source = x_gl_je_source)

        AND (tlinfo.je_iac_deprn_category = x_je_iac_deprn_category)

        AND (tlinfo.je_iac_reval_category = x_je_iac_reval_category)

        AND (tlinfo.je_iac_txn_category = x_je_iac_txn_category)

        AND (tlinfo.period_num_for_catchup = x_period_num_for_catchup)

       ) THEN

      NULL;

    ELSE

      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igi_iac_debug_pkg.debug_other_msg(g_error_level,g_path||'lock_row',FALSE);
      app_exception.raise_exception;

    END IF;



    RETURN;



  END lock_row;





  PROCEDURE update_row (

    x_rowid                             IN     VARCHAR2,

    x_book_type_code                    IN     VARCHAR2,

    x_gl_je_source                      IN     VARCHAR2,

    x_je_iac_deprn_category             IN     VARCHAR2,

    x_je_iac_reval_category             IN     VARCHAR2,

    x_je_iac_txn_category               IN     VARCHAR2,

    x_period_num_for_catchup            IN     NUMBER,

    x_mode                              IN     VARCHAR2

  ) AS

  /*

  ||  Created By :

  ||  Created On : 29-APR-2002

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
      igi_iac_debug_pkg.debug_other_msg(g_error_level,g_path||'update_row',FALSE);
      app_exception.raise_exception;

    END IF;





    UPDATE igi_iac_book_controls

      SET

        book_type_code                    = x_book_type_code,

        gl_je_source                      = x_gl_je_source,

        je_iac_deprn_category             = x_je_iac_deprn_category,

        je_iac_reval_category             = x_je_iac_reval_category,

        je_iac_txn_category               = x_je_iac_txn_category,

        period_num_for_catchup            = x_period_num_for_catchup,

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

  ||  Created On : 29-APR-2002

  ||  Purpose : Handles the DELETE DML logic for the table.

  ||  Known limitations, enhancements or remarks :

  ||  Change History :

  ||  Who             When            What

  ||  (reverse chronological order - newest change first)

  */

  BEGIN





    DELETE FROM igi_iac_book_controls

    WHERE rowid = x_rowid;



    IF (SQL%NOTFOUND) THEN

      RAISE NO_DATA_FOUND;

    END IF;



  END delete_row;





  FUNCTION get_org_id RETURN NUMBER AS

    CURSOR cur_orgid IS

    SELECT

 NVL ( TO_NUMBER ( DECODE ( SUBSTRB ( USERENV ('CLIENT_INFO' ), 1, 1  ), ' ', NULL,  SUBSTRB (USERENV ('CLIENT_INFO'),1,10)  )   ), NULL  ) org_id FROM dual;



    lv_org_id Number(15);



  BEGIN



    OPEN cur_orgid;

    FETCH cur_orgid INTO lv_org_id;

    CLOSE cur_orgid;



 RETURN lv_org_id ;





END get_org_id ;

BEGIN

g_state_level :=      FND_LOG.LEVEL_STATEMENT;
g_proc_level  :=      FND_LOG.LEVEL_PROCEDURE;
g_event_level :=      FND_LOG.LEVEL_EVENT;
g_excep_level :=      FND_LOG.LEVEL_EXCEPTION;
g_error_level :=      FND_LOG.LEVEL_ERROR;
g_unexp_level :=      FND_LOG.LEVEL_UNEXPECTED;
g_path        :=      'IGI.PLSQL.igiiabcb.igi_iac_book_controls_pkg.';


END igi_iac_book_controls_pkg;


/
