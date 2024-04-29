--------------------------------------------------------
--  DDL for Package Body IGF_DB_AWD_DISB_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_DB_AWD_DISB_DTL_PKG" AS
/* $Header: IGFDI01B.pls 120.1 2006/06/06 07:30:42 akomurav noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_db_awd_disb_dtl_all%ROWTYPE;
  new_references igf_db_awd_disb_dtl_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_adj_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_disb_activity                     IN     VARCHAR2,
    x_disb_batch_id                     IN     VARCHAR2,
    x_disb_ack_date                     IN     DATE,
    x_booking_batch_id                  IN     VARCHAR2,
    x_booked_date                       IN     DATE,
    x_disb_status                       IN     VARCHAR2,
    x_disb_status_date                  IN     DATE,
    x_sf_status                         IN     VARCHAR2,
    x_sf_status_date                    IN     DATE,
    x_sf_invoice_num                    IN     NUMBER,
    x_spnsr_credit_id			IN     NUMBER,
    x_spnsr_charge_id			IN     NUMBER,
    x_sf_credit_id	                IN     NUMBER,
    x_error_desc		        IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_notification_date                 IN     DATE,
    x_interest_rebate_amt               IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_db_awd_disb_dtl_all
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
    new_references.award_id                          := x_award_id;
    new_references.disb_num                          := x_disb_num;
    new_references.disb_seq_num                      := x_disb_seq_num;
    new_references.disb_gross_amt                    := x_disb_gross_amt;
    new_references.fee_1                             := x_fee_1;
    new_references.fee_2                             := x_fee_2;
    new_references.disb_net_amt                      := x_disb_net_amt;
    new_references.disb_adj_amt                      := x_disb_adj_amt;
    new_references.disb_date                         := x_disb_date;
    new_references.fee_paid_1                        := x_fee_paid_1;
    new_references.fee_paid_2                        := x_fee_paid_2;
    new_references.disb_activity                     := x_disb_activity;
    new_references.disb_batch_id                     := x_disb_batch_id;
    new_references.disb_ack_date                     := x_disb_ack_date;
    new_references.booking_batch_id                  := x_booking_batch_id;
    new_references.booked_date                       := x_booked_date;
    new_references.disb_status                       := x_disb_status;
    new_references.disb_status_date                  := x_disb_status_date;
    new_references.sf_status                         := x_sf_status;
    new_references.sf_status_date                    := x_sf_status_date;
    new_references.sf_invoice_num                    := x_sf_invoice_num;
    new_references.spnsr_credit_id	    	           := x_spnsr_credit_id;
    new_references.spnsr_charge_id		               := x_spnsr_charge_id;
    new_references.sf_credit_id                      := x_sf_credit_id;
    new_references.error_desc                        := x_error_desc;
    new_references.notification_date                 := x_notification_date;
    new_references.interest_rebate_amt               := x_interest_rebate_amt;
    new_references.ld_cal_type			     := x_ld_cal_type;
    new_references.ld_sequence_number		     := x_ld_sequence_number;


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
  ||  Created By : prchandr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.award_id = new_references.award_id) AND
         (old_references.disb_num = new_references.disb_num)) OR
        ((new_references.award_id IS NULL) OR
         (new_references.disb_num IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_awd_disb_pkg.get_pk_for_validation (
                new_references.award_id,
                new_references.disb_num
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;



  FUNCTION get_pk_for_validation (
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : prchandr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_db_awd_disb_dtl_all
      WHERE    award_id = x_award_id
      AND      disb_num = x_disb_num
      AND      disb_seq_num = x_disb_seq_num
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


  PROCEDURE get_fk_igf_aw_awd_disb (
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_db_awd_disb_dtl_all
      WHERE   ((award_id = x_award_id) AND
               (disb_num = x_disb_num));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_DB_DDTL_AWDD_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_awd_disb;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_adj_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_disb_activity                     IN     VARCHAR2,
    x_disb_batch_id                     IN     VARCHAR2,
    x_disb_ack_date                     IN     DATE,
    x_booking_batch_id                  IN     VARCHAR2,
    x_booked_date                       IN     DATE,
    x_disb_status                       IN     VARCHAR2,
    x_disb_status_date                  IN     DATE,
    x_sf_status                         IN     VARCHAR2,
    x_sf_status_date                    IN     DATE,
    x_sf_invoice_num                    IN     NUMBER,
    x_spnsr_credit_id			IN     NUMBER,
    x_spnsr_charge_id			IN     NUMBER,
    x_sf_credit_id		        IN     NUMBER,
    x_error_desc			IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_notification_date                 IN     DATE,
    x_interest_rebate_amt               IN     NUMBER,
    x_ld_cal_type			IN     VARCHAR2,
    x_ld_sequence_number		IN     NUMBER
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  veramach        23-SEP-2003     1.Added rowid check in cursors c_sf_credit_id,
  ||                                    c_spnsr_credit_id,c_spnsr_charge_id,c_sf_invoice_num
  ||  (reverse chronological order - newest change first)
  */

  CURSOR c_sf_credit_id(cp_sf_credit_id NUMBER)
  IS
  SELECT 'X'
  FROM igf_db_awd_disb_dtl
  WHERE sf_credit_id = cp_sf_credit_id
  AND   ((l_rowid IS NULL) OR (x_rowid <> l_rowid));

  l_sf_credit_id   c_sf_credit_id%ROWTYPE;

  CURSOR c_spnsr_credit_id(cp_spnsr_credit_id  NUMBER)
  IS
  SELECT 'X'
  FROM igf_db_awd_disb_dtl
  WHERE spnsr_credit_id  = cp_spnsr_credit_id
  AND   ((l_rowid IS NULL) OR (x_rowid <> l_rowid));

  l_spnsr_credit_id  c_spnsr_credit_id%ROWTYPE;

  CURSOR c_spnsr_charge_id(cp_spnsr_charge_id   NUMBER)
  IS
  SELECT 'X'
  FROM igf_db_awd_disb_dtl
  WHERE spnsr_charge_id   = cp_spnsr_charge_id
  AND   ((l_rowid IS NULL) OR (x_rowid <> l_rowid));

  l_spnsr_charge_id  c_spnsr_charge_id%ROWTYPE;

  CURSOR c_sf_invoice_num (cp_sf_invoice_num    NUMBER)
  IS
  SELECT 'X'
  FROM igf_db_awd_disb_dtl
  WHERE sf_invoice_num  = cp_sf_invoice_num
  AND   ((l_rowid IS NULL) OR (x_rowid <> l_rowid));

  l_sf_invoice_num  c_sf_invoice_num%ROWTYPE;

  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_award_id,
      x_disb_num,
      x_disb_seq_num,
      x_disb_gross_amt,
      x_fee_1,
      x_fee_2,
      x_disb_net_amt,
      x_disb_adj_amt,
      x_disb_date,
      x_fee_paid_1,
      x_fee_paid_2,
      x_disb_activity,
      x_disb_batch_id,
      x_disb_ack_date,
      x_booking_batch_id,
      x_booked_date,
      x_disb_status,
      x_disb_status_date,
      x_sf_status,
      x_sf_status_date,
      x_sf_invoice_num,
      x_spnsr_credit_id,
      x_spnsr_charge_id,
      x_sf_credit_id,
      x_error_desc,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_notification_date,
      x_interest_rebate_amt,
      x_ld_cal_type,
      x_ld_sequence_number
    );

    IF (p_action = 'INSERT') THEN
      -- Check for uniqueness of Credit Number
      IF new_references.sf_credit_id IS NOT NULL THEN
        OPEN  c_sf_credit_id(new_references.sf_credit_id);
        FETCH c_sf_credit_id INTO l_sf_credit_id;
        IF c_sf_credit_id%FOUND THEN
           CLOSE c_sf_credit_id;
           fnd_message.set_name ('IGF','IGF_DB_DUP_CR_NUM');
           igs_ge_msg_stack.add;
           app_exception.raise_exception;
        ELSE
           CLOSE c_sf_credit_id;
        END IF;
      END IF;

      -- Check for uniqueness of  Sponsor Credit Number
      IF new_references.spnsr_credit_id IS NOT NULL THEN
        OPEN  c_spnsr_credit_id(new_references.spnsr_credit_id);
        FETCH c_spnsr_credit_id INTO l_spnsr_credit_id;
        IF c_spnsr_credit_id%FOUND THEN
        CLOSE c_spnsr_credit_id;
              fnd_message.set_name ('IGF','IGF_DB_DUP_SP_CR_NUM');
              igs_ge_msg_stack.add;
              app_exception.raise_exception;
        ELSE
        CLOSE c_spnsr_credit_id;
        END IF;
      END IF;

      -- Check for uniqueness of  Sponsor Invoice Number
      IF new_references.spnsr_charge_id IS NOT NULL THEN
        OPEN  c_spnsr_charge_id(new_references.spnsr_charge_id);
        FETCH c_spnsr_charge_id INTO l_spnsr_charge_id;
        IF c_spnsr_charge_id%FOUND THEN
        CLOSE c_spnsr_charge_id;
              fnd_message.set_name ('IGF','IGF_DB_DUP_SP_INV_NUM');
              igs_ge_msg_stack.add;
              app_exception.raise_exception;
        ELSE
        CLOSE c_spnsr_charge_id;
        END IF;
      END IF;

      -- Check for uniqueness of Invoice Number
      IF new_references.sf_invoice_num IS NOT NULL THEN
        OPEN  c_sf_invoice_num (new_references.sf_invoice_num);
        FETCH c_sf_invoice_num INTO l_sf_invoice_num;
        IF c_sf_invoice_num%FOUND THEN
        CLOSE c_sf_invoice_num;
              fnd_message.set_name ('IGF','IGF_DB_DUP_INV_NUM');
              igs_ge_msg_stack.add;
              app_exception.raise_exception;
        ELSE
        CLOSE c_sf_invoice_num;
        END IF;
      END IF;

      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.award_id,
             new_references.disb_num,
             new_references.disb_seq_num
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Check for uniqueness of Credit Number
      IF new_references.sf_credit_id IS NOT NULL THEN
        OPEN  c_sf_credit_id(new_references.sf_credit_id);
        FETCH c_sf_credit_id INTO l_sf_credit_id;
        IF c_sf_credit_id%FOUND THEN
           CLOSE c_sf_credit_id;
           fnd_message.set_name ('IGF','IGF_DB_DUP_CR_NUM');
           igs_ge_msg_stack.add;
           app_exception.raise_exception;
        ELSE
           CLOSE c_sf_credit_id;
        END IF;
      END IF;

      -- Check for uniqueness of  Sponsor Credit Number
      IF new_references.spnsr_credit_id IS NOT NULL THEN
        OPEN  c_spnsr_credit_id(new_references.spnsr_credit_id);
        FETCH c_spnsr_credit_id INTO l_spnsr_credit_id;
        IF c_spnsr_credit_id%FOUND THEN
        CLOSE c_spnsr_credit_id;
              fnd_message.set_name ('IGF','IGF_DB_DUP_SP_CR_NUM');
              igs_ge_msg_stack.add;
              app_exception.raise_exception;
        ELSE
        CLOSE c_spnsr_credit_id;
        END IF;
      END IF;

      -- Check for uniqueness of  Sponsor Invoice Number
      IF new_references.spnsr_charge_id IS NOT NULL THEN
        OPEN  c_spnsr_charge_id(new_references.spnsr_charge_id);
        FETCH c_spnsr_charge_id INTO l_spnsr_charge_id;
        IF c_spnsr_charge_id%FOUND THEN
        CLOSE c_spnsr_charge_id;
              fnd_message.set_name ('IGF','IGF_DB_DUP_SP_INV_NUM');
              igs_ge_msg_stack.add;
              app_exception.raise_exception;
        ELSE
        CLOSE c_spnsr_charge_id;
        END IF;
      END IF;

      -- Check for uniqueness of Invoice Number
      IF new_references.sf_invoice_num IS NOT NULL THEN
        OPEN  c_sf_invoice_num (new_references.sf_invoice_num);
        FETCH c_sf_invoice_num INTO l_sf_invoice_num;
        IF c_sf_invoice_num%FOUND THEN
        CLOSE c_sf_invoice_num;
              fnd_message.set_name ('IGF','IGF_DB_DUP_INV_NUM');
              igs_ge_msg_stack.add;
              app_exception.raise_exception;
        ELSE
        CLOSE c_sf_invoice_num;
        END IF;
      END IF;

      -- Call all the procedures related to Before Update.
        check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
	 null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.award_id,
             new_references.disb_num,
             new_references.disb_seq_num
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
	 null;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_adj_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_disb_activity                     IN     VARCHAR2,
    x_disb_batch_id                     IN     VARCHAR2,
    x_disb_ack_date                     IN     DATE,
    x_booking_batch_id                  IN     VARCHAR2,
    x_booked_date                       IN     DATE,
    x_disb_status                       IN     VARCHAR2,
    x_disb_status_date                  IN     DATE,
    x_sf_status                         IN     VARCHAR2,
    x_sf_status_date                    IN     DATE,
    x_sf_invoice_num                    IN     NUMBER,
    x_spnsr_credit_id			     IN     NUMBER,
    x_spnsr_charge_id			     IN     NUMBER,
    x_sf_credit_id				     IN     NUMBER,
    x_error_desc			          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_notification_date                 IN     DATE,
    x_interest_rebate_amt               IN     NUMBER,
    x_ld_cal_type			IN     VARCHAR2,
    x_ld_sequence_number		IN     NUMBER
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_db_awd_disb_dtl_all
      WHERE    award_id                          = x_award_id
      AND      disb_num                          = x_disb_num
      AND      disb_seq_num                      = x_disb_seq_num;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_org_id                     igf_db_awd_disb_dtl_all.org_id%TYPE;

  BEGIN

    l_org_id := igf_aw_gen.get_org_id;

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

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_award_id                          => x_award_id,
      x_disb_num                          => x_disb_num,
      x_disb_seq_num                      => x_disb_seq_num,
      x_disb_gross_amt                    => x_disb_gross_amt,
      x_fee_1                             => x_fee_1,
      x_fee_2                             => x_fee_2,
      x_disb_net_amt                      => x_disb_net_amt,
      x_disb_adj_amt                      => x_disb_adj_amt,
      x_disb_date                         => x_disb_date,
      x_fee_paid_1                        => x_fee_paid_1,
      x_fee_paid_2                        => x_fee_paid_2,
      x_disb_activity                     => x_disb_activity,
      x_disb_batch_id                     => x_disb_batch_id,
      x_disb_ack_date                     => x_disb_ack_date,
      x_booking_batch_id                  => x_booking_batch_id,
      x_booked_date                       => x_booked_date,
      x_disb_status                       => x_disb_status,
      x_disb_status_date                  => x_disb_status_date,
      x_sf_status                         => x_sf_status,
      x_sf_status_date                    => x_sf_status_date,
      x_sf_invoice_num                    => x_sf_invoice_num,
      x_spnsr_credit_id			       => x_spnsr_credit_id,
      x_spnsr_charge_id			       => x_spnsr_charge_id,
      x_sf_credit_id			       => x_sf_credit_id,
      x_error_desc			            => x_error_desc,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_notification_date                 => x_notification_date,
      x_interest_rebate_amt               => x_interest_rebate_amt,
      x_ld_cal_type			  => x_ld_cal_type,
      x_ld_sequence_number		  => x_ld_sequence_number
    );

    INSERT INTO igf_db_awd_disb_dtl_all (
      award_id,
      disb_num,
      disb_seq_num,
      disb_gross_amt,
      fee_1,
      fee_2,
      disb_net_amt,
      disb_adj_amt,
      disb_date,
      fee_paid_1,
      fee_paid_2,
      disb_activity,
      disb_batch_id,
      disb_ack_date,
      booking_batch_id,
      booked_date,
      disb_status,
      disb_status_date,
      sf_status,
      sf_status_date,
      sf_invoice_num,
      spnsr_credit_id,
      spnsr_charge_id,
      sf_credit_id,
      error_desc,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      org_id,
      notification_date,
      interest_rebate_amt,
      ld_cal_type,
      ld_sequence_number
    ) VALUES (
      new_references.award_id,
      new_references.disb_num,
      new_references.disb_seq_num,
      new_references.disb_gross_amt,
      new_references.fee_1,
      new_references.fee_2,
      new_references.disb_net_amt,
      new_references.disb_adj_amt,
      new_references.disb_date,
      new_references.fee_paid_1,
      new_references.fee_paid_2,
      new_references.disb_activity,
      new_references.disb_batch_id,
      new_references.disb_ack_date,
      new_references.booking_batch_id,
      new_references.booked_date,
      new_references.disb_status,
      new_references.disb_status_date,
      new_references.sf_status,
      new_references.sf_status_date,
      new_references.sf_invoice_num,
      new_references.spnsr_credit_id,
      new_references.spnsr_charge_id,
      new_references.sf_credit_id,
      new_references.error_desc,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
      l_org_id,
      new_references.notification_date,
      new_references.interest_rebate_amt,
      new_references.ld_cal_type,
      new_references.ld_sequence_number
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
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_adj_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_disb_activity                     IN     VARCHAR2,
    x_disb_batch_id                     IN     VARCHAR2,
    x_disb_ack_date                     IN     DATE,
    x_booking_batch_id                  IN     VARCHAR2,
    x_booked_date                       IN     DATE,
    x_disb_status                       IN     VARCHAR2,
    x_disb_status_date                  IN     DATE,
    x_sf_status                         IN     VARCHAR2,
    x_sf_status_date                    IN     DATE,
    x_sf_invoice_num                    IN     NUMBER,
    x_spnsr_credit_id			     IN     NUMBER,
    x_spnsr_charge_id			     IN     NUMBER,
    x_sf_credit_id				     IN     NUMBER,
    x_error_desc			          IN     VARCHAR2,
    x_notification_date                 IN     DATE,
    x_interest_rebate_amt       IN    NUMBER,
    x_ld_cal_type		IN    VARCHAR2,
    x_ld_sequence_number	IN    NUMBER
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        disb_gross_amt,
        fee_1,
        fee_2,
        disb_net_amt,
        disb_adj_amt,
        disb_date,
        fee_paid_1,
        fee_paid_2,
        disb_activity,
        disb_batch_id,
        disb_ack_date,
        booking_batch_id,
        booked_date,
        disb_status,
        disb_status_date,
        sf_status,
        sf_status_date,
        sf_invoice_num,
        spnsr_credit_id,
        spnsr_charge_id,
        sf_credit_id,
        error_desc,
        org_id,
        notification_date,
        interest_rebate_amt,
	ld_cal_type,
	ld_sequence_number
      FROM  igf_db_awd_disb_dtl_all
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
        (tlinfo.disb_gross_amt = x_disb_gross_amt)
        AND ((tlinfo.fee_1 = x_fee_1) OR ((tlinfo.fee_1 IS NULL) AND (X_fee_1 IS NULL)))
        AND ((tlinfo.fee_2 = x_fee_2) OR ((tlinfo.fee_2 IS NULL) AND (X_fee_2 IS NULL)))
        AND (tlinfo.disb_net_amt = x_disb_net_amt)
        AND ((tlinfo.disb_adj_amt = x_disb_adj_amt) OR ((tlinfo.disb_adj_amt IS NULL) AND (X_disb_adj_amt IS NULL)))
        AND (tlinfo.disb_date = x_disb_date)
        AND ((tlinfo.fee_paid_1 = x_fee_paid_1) OR ((tlinfo.fee_paid_1 IS NULL) AND (X_fee_paid_1 IS NULL)))
        AND ((tlinfo.fee_paid_2 = x_fee_paid_2) OR ((tlinfo.fee_paid_2 IS NULL) AND (X_fee_paid_2 IS NULL)))
        AND ((tlinfo.disb_activity = x_disb_activity) OR ((tlinfo.disb_activity IS NULL) AND (X_disb_activity IS NULL)))
        AND ((tlinfo.sf_status = x_sf_status) OR ((tlinfo.sf_status IS NULL) AND (X_sf_status IS NULL)))
        AND ((tlinfo.sf_status_date = x_sf_status_date) OR ((tlinfo.sf_status_date IS NULL) AND (X_sf_status_date IS NULL)))
        AND ((tlinfo.sf_invoice_num = x_sf_invoice_num) OR ((tlinfo.sf_invoice_num IS NULL) AND (X_sf_invoice_num IS NULL)))
        AND ((tlinfo.spnsr_credit_id = x_spnsr_credit_id) OR ((tlinfo.spnsr_credit_id IS NULL) AND (x_spnsr_credit_id IS NULL)))
        AND ((tlinfo.spnsr_charge_id = x_spnsr_charge_id) OR ((tlinfo.spnsr_charge_id IS NULL) AND (x_spnsr_charge_id IS NULL)))
        AND ((tlinfo.sf_credit_id = x_sf_credit_id) OR ((tlinfo.sf_credit_id IS NULL) AND (x_sf_credit_id IS NULL)))
        AND ((tlinfo.error_desc = x_error_desc) OR ((tlinfo.error_desc IS NULL) AND (x_error_desc IS NULL)))
        AND ((tlinfo.notification_date = x_notification_date) OR ((tlinfo.notification_date IS NULL) AND (x_notification_date IS NULL)))
        AND ((tlinfo.interest_rebate_amt = x_interest_rebate_amt) OR ((tlinfo.interest_rebate_amt IS NULL) AND (x_interest_rebate_amt IS NULL)))
	AND ((tlinfo.ld_cal_type = x_ld_cal_type) OR ((tlinfo.ld_cal_type IS NULL) AND (x_ld_cal_type IS NULL)))
	AND ((tlinfo.ld_sequence_number= x_ld_sequence_number) OR ((tlinfo.ld_sequence_number IS NULL) AND (x_ld_sequence_number IS NULL)))
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
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_adj_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_disb_activity                     IN     VARCHAR2,
    x_disb_batch_id                     IN     VARCHAR2,
    x_disb_ack_date                     IN     DATE,
    x_booking_batch_id                  IN     VARCHAR2,
    x_booked_date                       IN     DATE,
    x_disb_status                       IN     VARCHAR2,
    x_disb_status_date                  IN     DATE,
    x_sf_status                         IN     VARCHAR2,
    x_sf_status_date                    IN     DATE,
    x_sf_invoice_num                    IN     NUMBER,
    x_spnsr_credit_id		          IN     NUMBER,
    x_spnsr_charge_id		          IN     NUMBER,
    x_sf_credit_id			          IN     NUMBER,
    x_error_desc			          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_notification_date                 IN     DATE,
    x_interest_rebate_amt               IN     NUMBER,
    x_ld_cal_type			IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

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
      x_award_id                          => x_award_id,
      x_disb_num                          => x_disb_num,
      x_disb_seq_num                      => x_disb_seq_num,
      x_disb_gross_amt                    => x_disb_gross_amt,
      x_fee_1                             => x_fee_1,
      x_fee_2                             => x_fee_2,
      x_disb_net_amt                      => x_disb_net_amt,
      x_disb_adj_amt                      => x_disb_adj_amt,
      x_disb_date                         => x_disb_date,
      x_fee_paid_1                        => x_fee_paid_1,
      x_fee_paid_2                        => x_fee_paid_2,
      x_disb_activity                     => x_disb_activity,
      x_disb_batch_id                     => x_disb_batch_id,
      x_disb_ack_date                     => x_disb_ack_date,
      x_booking_batch_id                  => x_booking_batch_id,
      x_booked_date                       => x_booked_date,
      x_disb_status                       => x_disb_status,
      x_disb_status_date                  => x_disb_status_date,
      x_sf_status                         => x_sf_status,
      x_sf_status_date                    => x_sf_status_date,
      x_sf_invoice_num                    => x_sf_invoice_num,
      x_spnsr_credit_id			  => x_spnsr_credit_id,
      x_spnsr_charge_id			  => x_spnsr_charge_id,
      x_sf_credit_id			  => x_sf_credit_id,
      x_error_desc			  => x_error_desc,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_notification_date                 => x_notification_date,
      x_interest_rebate_amt               => x_interest_rebate_amt,
      x_ld_cal_type			  => x_ld_cal_type,
      x_ld_sequence_number                => x_ld_sequence_number

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

    UPDATE igf_db_awd_disb_dtl_all
      SET
        disb_gross_amt                    = new_references.disb_gross_amt,
        fee_1                             = new_references.fee_1,
        fee_2                             = new_references.fee_2,
        disb_net_amt                      = new_references.disb_net_amt,
        disb_adj_amt                      = new_references.disb_adj_amt,
        disb_date                         = new_references.disb_date,
        fee_paid_1                        = new_references.fee_paid_1,
        fee_paid_2                        = new_references.fee_paid_2,
        disb_activity                     = new_references.disb_activity,
        disb_batch_id                     = new_references.disb_batch_id,
        disb_ack_date                     = new_references.disb_ack_date,
        booking_batch_id                  = new_references.booking_batch_id,
        booked_date                       = new_references.booked_date,
        disb_status                       = new_references.disb_status,
        disb_status_date                  = new_references.disb_status_date,
        sf_status                         = new_references.sf_status,
        sf_status_date                    = new_references.sf_status_date,
        sf_invoice_num                    = new_references.sf_invoice_num,
        spnsr_credit_id		            = new_references.spnsr_credit_id,
        spnsr_charge_id			       = new_references.spnsr_charge_id,
        sf_credit_id			       = new_references.sf_credit_id,
        error_desc			            = new_references.error_desc,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date ,
        notification_date                 = new_references.notification_date,
        interest_rebate_amt               = new_references.interest_rebate_amt,
	ld_cal_type			  = new_references.ld_cal_type,
	ld_sequence_number		  = new_references.ld_sequence_number
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_adj_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_disb_activity                     IN     VARCHAR2,
    x_disb_batch_id                     IN     VARCHAR2,
    x_disb_ack_date                     IN     DATE,
    x_booking_batch_id                  IN     VARCHAR2,
    x_booked_date                       IN     DATE,
    x_disb_status                       IN     VARCHAR2,
    x_disb_status_date                  IN     DATE,
    x_sf_status                         IN     VARCHAR2,
    x_sf_status_date                    IN     DATE,
    x_sf_invoice_num                    IN     NUMBER,
    x_spnsr_credit_id		          IN     NUMBER,
    x_spnsr_charge_id		          IN     NUMBER,
    x_sf_credit_id			          IN     NUMBER,
    x_error_desc			          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_notification_date                 IN     DATE,
    x_interest_rebate_amt               IN     NUMBER,
    x_ld_cal_type			IN     VARCHAR2,
    x_ld_sequence_number		IN     NUMBER
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_db_awd_disb_dtl_all
      WHERE    award_id                          = x_award_id
      AND      disb_num                          = x_disb_num
      AND      disb_seq_num                      = x_disb_seq_num;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_award_id,
        x_disb_num,
        x_disb_seq_num,
        x_disb_gross_amt,
        x_fee_1,
        x_fee_2,
        x_disb_net_amt,
        x_disb_adj_amt,
        x_disb_date,
        x_fee_paid_1,
        x_fee_paid_2,
        x_disb_activity,
        x_disb_batch_id,
        x_disb_ack_date,
        x_booking_batch_id,
        x_booked_date,
        x_disb_status,
        x_disb_status_date,
        x_sf_status,
        x_sf_status_date,
        x_sf_invoice_num,
        x_spnsr_credit_id,
        x_spnsr_charge_id,
        x_sf_credit_id,
        x_error_desc,
        x_mode ,
        x_notification_date,
        x_interest_rebate_amt,
	x_ld_cal_type,
	x_ld_sequence_number
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
    x_rowid,
    x_award_id,
    x_disb_num,
    x_disb_seq_num,
    x_disb_gross_amt,
    x_fee_1,
    x_fee_2,
    x_disb_net_amt,
    x_disb_adj_amt,
    x_disb_date,
    x_fee_paid_1,
    x_fee_paid_2,
    x_disb_activity,
    x_disb_batch_id,
    x_disb_ack_date,
    x_booking_batch_id,
    x_booked_date,
    x_disb_status,
    x_disb_status_date,
    x_sf_status,
    x_sf_status_date,
    x_sf_invoice_num,
    x_spnsr_credit_id,
    x_spnsr_charge_id,
    x_sf_credit_id,
    x_error_desc,
    x_mode,
    x_notification_date,
    x_interest_rebate_amt,
    x_ld_cal_type,
    x_ld_sequence_number
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 14-DEC-2000
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

    DELETE FROM igf_db_awd_disb_dtl_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_db_awd_disb_dtl_pkg;

/
