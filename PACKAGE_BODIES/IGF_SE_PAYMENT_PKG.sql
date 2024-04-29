--------------------------------------------------------
--  DDL for Package Body IGF_SE_PAYMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SE_PAYMENT_PKG" AS
/* $Header: IGFSI02B.pls 120.1 2005/10/06 05:34:22 appldev ship $ */
/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: IGF_SE_PAYMENT_PKG
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | This package has a flag on the end of some of the procedures called   |
 | X_MODE. Pass either 'R' for runtime, or 'I' for Install-time.         |
 | This will control how the who columns are filled in; If you are       |
 | running in runtime mode, they are taken from the profiles, whereas in |
 | install-time mode they get defaulted with special values to indicate  |
 | that they were inserted by datamerge.                                 |
 |                                                                       |
 | The ADD_ROW routine will see whether a row exists by selecting        |
 | based on the primary key, and updates the row if it exists,           |
 | or inserts the row if it doesn't already exist.                       |
 |                                                                       |
 | This module is called by AutoInstall (afplss.drv) on install and      |
 | upgrade.  The WHENEVER SQLERROR and EXIT (at bottom) are required.    |
 |                                                                       |
 | HISTORY                                                               |
 | who        when           what                                        |
 | veramach   July 2004      FA 151 HR Integration                       |
 |                           Obsoleted ld_cal_type,ld_sequence_number,   |
 |                           hrs_worked                                  |
 |                           Added check_constraints                     |
 | brajendr   01-Jul-2002    Bug # 2415194                               |
 |                           Modified the Message IGF_SE_ERR_PAY_ADJ to  |
 |                           have the extra token to give more clarity   |
 |                                                                       |
 *=======================================================================*/

  l_rowid VARCHAR2(25);
  old_references igf_se_payment%ROWTYPE;
  new_references igf_se_payment%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_transaction_id                    IN     NUMBER  ,
    x_payroll_id                        IN     NUMBER  ,
    x_payroll_date                      IN     DATE    ,
    x_auth_id                           IN     NUMBER  ,
    x_person_id                         IN     NUMBER  ,
    x_fund_id                           IN     NUMBER  ,
    x_paid_amount                       IN     NUMBER  ,
    x_org_unit_cd                       IN     VARCHAR2,
    x_source                            IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 31-DEC-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_SE_PAYMENT
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
    new_references.transaction_id                    := x_transaction_id;
    new_references.payroll_id                        := x_payroll_id;
    new_references.payroll_date                      := x_payroll_date;
    new_references.auth_id                           := x_auth_id;
    new_references.person_id                         := x_person_id;
    new_references.fund_id                           := x_fund_id;
    new_references.paid_amount                       := x_paid_amount;
    new_references.org_unit_cd                       := x_org_unit_cd;
    new_references.source                            := x_source;

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
  ||  Created By : ssawhney
  ||  Created On : 31-DEC-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF NOT igs_pe_person_pkg.get_pk_for_validation (
                new_references.person_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_transaction_id                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 31-DEC-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_se_payment
      WHERE    transaction_id = x_transaction_id
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


  PROCEDURE get_fk_hz_parties (
    x_party_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 31-DEC-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  NOTE : THIS WILL NOT GET EXECUTED AS IGS DOESNT CALL THIS CODE
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Bug : 2413695
  ||  Desc :IGF Messages Issues
  ||  Who             When            What
  ||  mesriniv        14-jun-2002     message name added
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_se_payment
      WHERE   ((person_id = x_party_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_SE_SEP_HP_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_hz_parties;

  PROCEDURE check_constraints AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 27-Jul-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  -- Get authorization id
  CURSOR c_auth(
                 cp_auth_id     igf_se_payment.auth_id%TYPE,
                 cp_person_id   igf_ap_fa_base_rec_all.person_id%TYPE
                ) IS
    SELECT 'x'
      FROM igf_se_auth
     WHERE auth_id   = cp_auth_id
       AND person_id = cp_person_id
       AND flag      = 'A';
  l_auth     c_auth%ROWTYPE;

  -- Get fund id
  CURSOR c_fund(
                cp_auth_id      igf_se_payment.auth_id%TYPE,
                cp_person_id    igf_ap_fa_base_rec_all.person_id%TYPE
               ) IS
    SELECT auth.fund_id
      FROM igf_se_auth auth
     WHERE auth_id   = cp_auth_id
       AND person_id = cp_person_id;
  l_fund  igf_aw_fund_mast_all.fund_id%TYPE;

  -- Get lookup meaning
  CURSOR c_lookup(
                  cp_lookup_type igf_lookups_view.lookup_type%TYPE,
                  cp_lookup_code igf_lookups_view.lookup_code%TYPE
                 ) IS
    SELECT 'x'
      FROM igf_lookups_view
     WHERE lookup_type = cp_lookup_type
       AND lookup_code = cp_lookup_code
       AND enabled_flag = 'Y';
  l_lookup     c_lookup%ROWTYPE;

  CURSOR c_pers_num(
                    cp_person_id hz_parties.party_id%TYPE
                   ) IS
    SELECT party_number
      FROM hz_parties
     WHERE party_id = cp_person_id;
  l_pers_num    hz_parties.party_number%TYPE;

  BEGIN

    IF new_references.payroll_date IS NULL THEN
      fnd_message.set_name('IGF','IGF_SE_PAY_DT_INVALID');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF new_references.auth_id IS NULL THEN
      fnd_message.set_name('IGF','IGF_SE_AUTH_ID_NULL');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF new_references.person_id IS NULL THEN
      fnd_message.set_name('IGF','IGF_SE_PERSON_ID_NULL');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF new_references.paid_amount IS NULL THEN
      fnd_message.set_name('IGF','IGF_SE_PAID_AMT_NULL');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF new_references.source IS NULL THEN
      fnd_message.set_name('IGF','IGF_SE_SOURCE_INVALID');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    OPEN c_auth(new_references.auth_id,new_references.person_id);
    FETCH c_auth INTO l_auth;
    IF c_auth%NOTFOUND THEN
      CLOSE c_auth;
      fnd_message.set_name('IGF','IGF_SE_INV_AUTH_PERSON');
      fnd_message.set_token('AUTH_ID',TO_CHAR(new_references.auth_id));

      l_pers_num := NULL;
      OPEN c_pers_num(new_references.person_id);
      FETCH c_pers_num INTO l_pers_num;
      CLOSE c_pers_num;
      fnd_message.set_token('PERSON_NUM',l_pers_num);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
    CLOSE c_auth;

    l_fund := NULL;
    OPEN c_fund(new_references.auth_id,new_references.person_id);
    FETCH c_fund INTO l_fund;
    CLOSE c_fund;
    IF l_fund IS NULL THEN
      fnd_message.set_name('IGF','IGF_SE_NO_VALID_FUND');
      l_pers_num := NULL;
      OPEN c_pers_num(new_references.person_id);
      FETCH c_pers_num INTO l_pers_num;
      CLOSE c_pers_num;
      fnd_message.set_token('PERSON_NUM',l_pers_num);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    OPEN c_lookup('IGF_SE_SOURCE',new_references.source);
    FETCH c_lookup INTO l_lookup;
    IF c_lookup%NOTFOUND THEN
      CLOSE c_lookup;
      fnd_message.set_name('IGF','IGF_SE_SOURCE_INVALID');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_constraints;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_transaction_id                    IN     NUMBER  ,
    x_payroll_id                        IN     NUMBER  ,
    x_payroll_date                      IN     DATE    ,
    x_auth_id                           IN     NUMBER  ,
    x_person_id                         IN     NUMBER  ,
    x_fund_id                           IN     NUMBER  ,
    x_paid_amount                       IN     NUMBER  ,
    x_org_unit_cd                       IN     VARCHAR2,
    x_source                            IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 31-DEC-2001
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
      x_transaction_id,
      x_payroll_id,
      x_payroll_date,
      x_auth_id,
      x_person_id,
      x_fund_id,
      x_paid_amount,
      x_org_unit_cd,
      x_source,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );


    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.

      IF ( get_pk_for_validation(
             new_references.transaction_id
           )
         ) THEN

        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
      check_constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.transaction_id
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
    x_transaction_id                    IN OUT NOCOPY NUMBER,
    x_payroll_id                        IN     NUMBER,
    x_payroll_date                      IN     DATE,
    x_auth_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_paid_amount                       IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_source                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 31-DEC-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_se_payment
      WHERE    transaction_id                    = x_transaction_id;

    CURSOR c_payment_int  IS
      SELECT rowid , spi.*
      FROM   igf_se_payment_int spi
      WHERE  spi.auth_id =x_auth_id AND
             spi.payroll_id =x_payroll_id AND
	     spi.status NOT IN ('DONE','ERROR');

    CURSOR c_get_se_errors(
                           c_error_cd  igf_se_payment_int.error_code%TYPE
                          ) IS
    SELECT meaning
      FROM igf_lookups_view
     WHERE lookup_type = 'IGF_STUD_EMP_ERROR'
       AND lookup_code = c_error_cd;

    payment_int_rec c_payment_int%ROWTYPE;


    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_status                     igf_se_payment_int.status%TYPE;
    l_error                      igf_se_payment_int.error_code%TYPE;
    l_error_meaming              igf_lookups_view.meaning%TYPE;
    my_exception                 EXCEPTION;

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
      x_request_id             := fnd_global.conc_request_id;
      x_program_id             := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;

      IF (x_request_id = -1) THEN
        x_request_id             := NULL;
        x_program_id             := NULL;
        x_program_application_id := NULL;
        x_program_update_date    := NULL;
      ELSE
        x_program_update_date    := SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT    igf_se_payment_s.NEXTVAL
    INTO      x_transaction_id
    FROM      dual;


    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_transaction_id                    => x_transaction_id,
      x_payroll_id                        => x_payroll_id,
      x_payroll_date                      => x_payroll_date,
      x_auth_id                           => x_auth_id,
      x_person_id                         => x_person_id,
      x_fund_id                           => x_fund_id,
      x_paid_amount                       => x_paid_amount,
      x_org_unit_cd                       => x_org_unit_cd,
      x_source                            => x_source,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    -- issue a savepoint
    SAVEPOINT se_payment;

    INSERT INTO igf_se_payment (
      transaction_id,
      payroll_id,
      payroll_date,
      auth_id,
      person_id,
      fund_id,
      paid_amount,
      org_unit_cd,
      source,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date
    ) VALUES (
      new_references.transaction_id,
      new_references.payroll_id,
      new_references.payroll_date,
      new_references.auth_id,
      new_references.person_id,
      new_references.fund_id,
      new_references.paid_amount,
      new_references.org_unit_cd,
      new_references.source,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    );

       OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

     -- specific code for the logic of this table.
     -- make a call for adjustment to IGF_AW_AWD_DISB table

    BEGIN

      igf_se_gen_001.payroll_adjust(
                                    new_references,
                                    l_status,
                                    l_error
                                   );



      IF  l_status ='DONE' THEN -- that is its a success

        IF  new_references.payroll_id IS NOT NULL THEN

          -- this means that the record is coming from IGF_SE_PAYMENT_INT table
          -- update payment int table with the error code
          OPEN c_payment_int;
          FETCH c_payment_int INTO payment_int_rec;
          IF c_payment_int%FOUND THEN
            CLOSE c_payment_int;

            BEGIN
              igf_se_payment_int_pkg.update_row (
                 x_rowid                            => payment_int_rec.rowid,
                 x_transaction_id                    => payment_int_rec.transaction_id,
                 x_batch_id                          => payment_int_rec.batch_id,
                 x_payroll_id                        => payment_int_rec.payroll_id,
                 x_payroll_date                      => payment_int_rec.payroll_date,
                 x_auth_id                           => payment_int_rec.auth_id,
                 x_person_id                         => payment_int_rec.person_id,
                 x_fund_id                           => payment_int_rec.fund_id,
                 x_paid_amount                       => payment_int_rec.paid_amount,
                 x_org_unit_cd                       => payment_int_rec.org_unit_cd,
                 x_status                            => l_status,
                 x_error_code			       => l_error
                 );
            EXCEPTION
            WHEN OTHERS THEN
              fnd_message.set_name('IGF','IGF_SE_ERR_PAYINT_UPD');
              igs_ge_msg_stack.add;
              app_exception.raise_exception;
            END;

          ELSE
            CLOSE c_payment_int;
          END IF;

        END IF;  -- new payroll if

      ELSIF l_status = 'ERROR' THEN
        raise my_exception;
      END IF;

    -- if adjusment is successful then do NULL , return stat would be DONE else
    -- rollback the transaction and update the PAYMENT_INT table for error.
    EXCEPTION

    WHEN my_exception THEN
      IF  new_references.payroll_id IS NOT NULL THEN

    -- this means that the record is coming from IGF_SE_PAYMENT_INT table
    -- update payment int table with the error code
         OPEN c_payment_int;
         FETCH c_payment_int INTO payment_int_rec;
         IF c_payment_int%FOUND THEN
           CLOSE c_payment_int;

           -- rollback the transaction insert into PAYMENT.
           -- update the int table

           ROLLBACK TO se_payment;

           BEGIN
           igf_se_payment_int_pkg.update_row (
             x_rowid                            => payment_int_rec.rowid,
             x_transaction_id                    => payment_int_rec.transaction_id,
             x_batch_id                          => payment_int_rec.batch_id,
             x_payroll_id                        => payment_int_rec.payroll_id,
             x_payroll_date                      => payment_int_rec.payroll_date,
             x_auth_id                           => payment_int_rec.auth_id,
             x_person_id                         => payment_int_rec.person_id,
             x_fund_id                           => payment_int_rec.fund_id,
             x_paid_amount                       => payment_int_rec.paid_amount,
             x_org_unit_cd                       => payment_int_rec.org_unit_cd,
             x_status                            => l_status,
             x_error_code			       => l_error
             );
           EXCEPTION
           WHEN OTHERS THEN

             fnd_message.set_name('IGF','IGF_SE_ERR_PAYINT_UPD');
             igs_ge_msg_stack.add;
             app_exception.raise_exception;
           END;

         ELSE
           CLOSE c_payment_int;
           ROLLBACK TO se_payment;
         END IF;
      ELSIF  new_references.payroll_id IS NULL THEN
    -- this means that the record is being entered from the screen.

        ROLLBACK TO se_payment;

        -- Get the error code meaning from the lookups and show the exact error to the user
        OPEN c_get_se_errors( l_error);
        FETCH c_get_se_errors INTO l_error_meaming;
        CLOSE c_get_se_errors;

        FND_MESSAGE.SET_NAME('IGF', 'IGF_SE_ERR_PAY_ADJ');
        FND_MESSAGE.SET_TOKEN('ERROR',l_error_meaming);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;


      END IF;
    END; -- exception of calling adjustment

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_transaction_id                    IN     NUMBER,
    x_payroll_id                        IN     NUMBER,
    x_payroll_date                      IN     DATE,
    x_auth_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_paid_amount                       IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_source                            IN     VARCHAR2
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 31-DEC-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        payroll_id,
        payroll_date,
        auth_id,
        person_id,
        fund_id,
        paid_amount,
        org_unit_cd,
        source
      FROM  igf_se_payment
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
        ((tlinfo.payroll_id = x_payroll_id) OR ((tlinfo.payroll_id IS NULL) AND (X_payroll_id IS NULL)))
        AND (tlinfo.payroll_date = x_payroll_date)
        AND (tlinfo.auth_id = x_auth_id)
        AND (tlinfo.person_id = x_person_id)
        AND (tlinfo.fund_id = x_fund_id)
        AND (tlinfo.paid_amount = x_paid_amount)
        AND ((tlinfo.org_unit_cd = x_org_unit_cd) OR ((tlinfo.org_unit_cd IS NULL) AND (X_org_unit_cd IS NULL)))
        AND ((tlinfo.source = x_source) OR ((tlinfo.source IS NULL) AND (X_source IS NULL)))
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
    x_transaction_id                    IN     NUMBER,
    x_payroll_id                        IN     NUMBER,
    x_payroll_date                      IN     DATE,
    x_auth_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_paid_amount                       IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_source                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 31-DEC-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR c_get_se_errors(
                           c_error_cd  igf_se_payment_int.error_code%TYPE
                          ) IS
    SELECT meaning
      FROM igf_lookups_view
     WHERE lookup_type = 'IGF_STUD_EMP_ERROR'
       AND lookup_code = c_error_cd;

    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_status                     igf_se_payment_int.status%TYPE;
    l_error                      igf_se_payment_int.error_code%TYPE;
    l_error_meaming              igf_lookups_view.meaning%TYPE;
    my_exception                 EXCEPTION;

    CURSOR c_payment_int  IS
      SELECT rowid , spi.*
      FROM   igf_se_payment_int spi
      WHERE  spi.auth_id =x_auth_id AND
             spi.payroll_id =x_payroll_id AND
	     spi.status NOT IN ('DONE','ERROR');

    payment_int_rec c_payment_int%ROWTYPE;


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
      x_transaction_id                    => x_transaction_id,
      x_payroll_id                        => x_payroll_id,
      x_payroll_date                      => x_payroll_date,
      x_auth_id                           => x_auth_id,
      x_person_id                         => x_person_id,
      x_fund_id                           => x_fund_id,
      x_paid_amount                       => x_paid_amount,
      x_org_unit_cd                       => x_org_unit_cd,
      x_source                            => x_source,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    IF (x_mode = 'R') THEN
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id =  -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
        x_program_update_date := old_references.program_update_date;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    END IF;

    -- issue a savepoint

    SAVEPOINT se_payment_upd;

    UPDATE igf_se_payment
      SET
        payroll_id                        = new_references.payroll_id,
        payroll_date                      = new_references.payroll_date,
        auth_id                           = new_references.auth_id,
        person_id                         = new_references.person_id,
        fund_id                           = new_references.fund_id,
        paid_amount                       = new_references.paid_amount,
        org_unit_cd                       = new_references.org_unit_cd,
        source                            = new_references.source,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    BEGIN
     -- make a call for adjustment to IGF_AW_AWD_DISB table
    igf_se_gen_001.payroll_adjust(
                                  new_references,
                                  l_status,
                                  l_error
                                 );

    IF  l_status ='DONE' THEN -- that is its a success

      IF  new_references.payroll_id IS NOT NULL THEN

         -- this means that the record is coming from IGF_SE_PAYMENT_INT table
         -- update payment int table with the error code
         OPEN c_payment_int;
         FETCH c_payment_int INTO payment_int_rec;
         IF c_payment_int%FOUND THEN
           CLOSE c_payment_int;

           BEGIN
             igf_se_payment_int_pkg.update_row(
                                               x_rowid          => payment_int_rec.rowid,
                                               x_transaction_id => payment_int_rec.transaction_id,
                                               x_batch_id       => payment_int_rec.batch_id,
                                               x_payroll_id     => payment_int_rec.payroll_id,
                                               x_payroll_date   => payment_int_rec.payroll_date,
                                               x_auth_id        => payment_int_rec.auth_id,
                                               x_person_id      => payment_int_rec.person_id,
                                               x_fund_id        => payment_int_rec.fund_id,
                                               x_paid_amount    => payment_int_rec.paid_amount,
                                               x_org_unit_cd    => payment_int_rec.org_unit_cd,
                                               x_status         => l_status,
                                               x_error_code			=> l_error
                                              );
           EXCEPTION
             WHEN OTHERS THEN
               fnd_message.set_name('IGF','IGF_SE_ERR_PAYINT_UPD');
               igs_ge_msg_stack.add;
               app_exception.raise_exception;
           END; -- new payroll not null
         ELSE
           CLOSE c_payment_int;
         END IF;

      END IF;
    ELSIF l_status = 'ERROR' THEN
       raise my_exception;
    END IF;

    -- if adjusment is successful then do NULL , return stat would be DONE else
    -- rollback the transaction and update the PAYMENT_INT table for error.
    EXCEPTION

    WHEN my_exception THEN
      IF  new_references.payroll_id IS NOT NULL THEN

         -- this means that the record is coming from IGF_SE_PAYMENT_INT table
         -- update payment int table with the error code
         OPEN c_payment_int;
         FETCH c_payment_int INTO payment_int_rec;
         IF c_payment_int%FOUND THEN
           CLOSE c_payment_int;

           -- rollback the transaction insert into PAYMENT.
           -- update the int table

           ROLLBACK TO se_payment_upd;

           BEGIN
             igf_se_payment_int_pkg.update_row(
                                               x_rowid          => payment_int_rec.rowid,
                                               x_transaction_id => payment_int_rec.transaction_id,
                                               x_batch_id       => payment_int_rec.batch_id,
                                               x_payroll_id     => payment_int_rec.payroll_id,
                                               x_payroll_date   => payment_int_rec.payroll_date,
                                               x_auth_id        => payment_int_rec.auth_id,
                                               x_person_id      => payment_int_rec.person_id,
                                               x_fund_id        => payment_int_rec.fund_id,
                                               x_paid_amount    => payment_int_rec.paid_amount,
                                               x_org_unit_cd    => payment_int_rec.org_unit_cd,
                                               x_status         => l_status,
                                               x_error_code			=> l_error
                                              );
             EXCEPTION
               WHEN OTHERS THEN
                 fnd_message.set_name('IGF','IGF_SE_ERR_PAYINT_UPD');
                 igs_ge_msg_stack.add;
                 app_exception.raise_exception;
           END;
         ELSE
           CLOSE c_payment_int;
           ROLLBACK TO se_payment_upd;
         END IF;

      ELSIF  new_references.payroll_id IS NULL THEN
    -- this means that the record is being entered from the screen.

        ROLLBACK TO se_payment_upd;

        -- Get the error code meaning from the lookups and show the exact error to the user
        OPEN c_get_se_errors( l_error);
        FETCH c_get_se_errors INTO l_error_meaming;
        CLOSE c_get_se_errors;

        FND_MESSAGE.SET_NAME('IGF', 'IGF_SE_ERR_PAY_ADJ');
        FND_MESSAGE.SET_TOKEN('ERROR',l_error_meaming);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

      END IF;
    END; -- exception of calling adjustment
  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_transaction_id                    IN OUT NOCOPY NUMBER,
    x_payroll_id                        IN     NUMBER,
    x_payroll_date                      IN     DATE,
    x_auth_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_paid_amount                       IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_source                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 31-DEC-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks : AVOID USING THIS. DUE TO SPECIFIC LOGIC OF INSERT/UPDATE
  ||      FOR THIS TABLE.
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_se_payment
      WHERE    transaction_id                    = x_transaction_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_transaction_id,
        x_payroll_id,
        x_payroll_date,
        x_auth_id,
        x_person_id,
        x_fund_id,
        x_paid_amount,
        x_org_unit_cd,
        x_source,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_transaction_id,
      x_payroll_id,
      x_payroll_date,
      x_auth_id,
      x_person_id,
      x_fund_id,
      x_paid_amount,
      x_org_unit_cd,
      x_source,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 31-DEC-2001
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

    DELETE FROM igf_se_payment
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_se_payment_pkg;

/
