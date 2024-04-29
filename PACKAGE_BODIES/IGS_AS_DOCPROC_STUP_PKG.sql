--------------------------------------------------------
--  DDL for Package Body IGS_AS_DOCPROC_STUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_DOCPROC_STUP_PKG" AS
/* $Header: IGSDI67B.pls 115.2 2002/11/28 23:27:51 nsidana noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_as_docproc_stup%ROWTYPE;
  new_references igs_as_docproc_stup%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_tpset_id                          IN     NUMBER,
    x_lifetime_trans_fee_ind            IN     VARCHAR2,
    x_provide_transcript_ind            IN     VARCHAR2,
    x_trans_request_if_hold_ind         IN     VARCHAR2,
    x_all_acad_hist_in_one_doc_ind      IN     VARCHAR2,
    x_hold_deliv_ind                    IN     VARCHAR2,
    x_allow_enroll_cert_ind             IN     VARCHAR2,
    x_bill_me_later_ind                 IN     VARCHAR2,
    x_edi_capable_ind                   IN     VARCHAR2,
    x_always_send_docs_via_edi          IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_provide_duplicate_doc_ind    IN     VARCHAR2,
    x_charge_document_fee_ind           IN     VARCHAR2,
    x_charge_delivery_fee_ind           IN     VARCHAR2,
    x_administrator_id                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kkillams
  ||  Created On : 06-FEB-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who      When        What
  ||  (reverse chronological order - newest change first)
  ||  kdande   18-Oct-2002 Added new columns as per the new 2632096.
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_as_docproc_stup
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
    new_references.tpset_id                          := x_tpset_id;
    new_references.lifetime_trans_fee_ind            := x_lifetime_trans_fee_ind;
    new_references.provide_transcript_ind            := x_provide_transcript_ind;
    new_references.trans_request_if_hold_ind         := x_trans_request_if_hold_ind;
    new_references.all_acad_hist_in_one_doc_ind      := x_all_acad_hist_in_one_doc_ind;
    new_references.hold_deliv_ind                    := x_hold_deliv_ind;
    new_references.allow_enroll_cert_ind             := x_allow_enroll_cert_ind;
    new_references.bill_me_later_ind                 := x_bill_me_later_ind;
    new_references.edi_capable_ind                   := x_edi_capable_ind;
    new_references.always_send_docs_via_edi          := x_always_send_docs_via_edi;
    new_references.provide_duplicate_doc_ind    := x_provide_duplicate_doc_ind;
    new_references.charge_document_fee_ind           := x_charge_document_fee_ind;
    new_references.charge_delivery_fee_ind           := x_charge_delivery_fee_ind;
    new_references.administrator_id                  := x_administrator_id;

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


  FUNCTION get_pk_for_validation (
    x_tpset_id                          IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kkillams
  ||  Created On : 06-FEB-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_docproc_stup
      WHERE    tpset_id = x_tpset_id
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


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_tpset_id                          IN     NUMBER,
    x_lifetime_trans_fee_ind            IN     VARCHAR2,
    x_provide_transcript_ind            IN     VARCHAR2,
    x_trans_request_if_hold_ind         IN     VARCHAR2,
    x_all_acad_hist_in_one_doc_ind      IN     VARCHAR2,
    x_hold_deliv_ind                    IN     VARCHAR2,
    x_allow_enroll_cert_ind             IN     VARCHAR2,
    x_bill_me_later_ind                 IN     VARCHAR2,
    x_edi_capable_ind                   IN     VARCHAR2,
    x_always_send_docs_via_edi          IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_provide_duplicate_doc_ind    IN     VARCHAR2,
    x_charge_document_fee_ind           IN     VARCHAR2,
    x_charge_delivery_fee_ind           IN     VARCHAR2,
    x_administrator_id                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kkillams
  ||  Created On : 06-FEB-2002
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who      When        What
  ||  (reverse chronological order - newest change first)
  ||  kdande   18-Oct-2002 Added new columns as per the Enh# 2632096.
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_tpset_id,
      x_lifetime_trans_fee_ind,
      x_provide_transcript_ind,
      x_trans_request_if_hold_ind,
      x_all_acad_hist_in_one_doc_ind,
      x_hold_deliv_ind,
      x_allow_enroll_cert_ind,
      x_bill_me_later_ind,
      x_edi_capable_ind,
      x_always_send_docs_via_edi,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_provide_duplicate_doc_ind,
      x_charge_document_fee_ind,
      x_charge_delivery_fee_ind,
      x_administrator_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.tpset_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.tpset_id
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
    x_tpset_id                          IN OUT NOCOPY NUMBER,
    x_lifetime_trans_fee_ind            IN     VARCHAR2,
    x_provide_transcript_ind            IN     VARCHAR2,
    x_trans_request_if_hold_ind         IN     VARCHAR2,
    x_all_acad_hist_in_one_doc_ind      IN     VARCHAR2,
    x_hold_deliv_ind                    IN     VARCHAR2,
    x_allow_enroll_cert_ind             IN     VARCHAR2,
    x_bill_me_later_ind                 IN     VARCHAR2,
    x_edi_capable_ind                   IN     VARCHAR2,
    x_always_send_docs_via_edi          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_provide_duplicate_doc_ind    IN     VARCHAR2,
    x_charge_document_fee_ind           IN     VARCHAR2,
    x_charge_delivery_fee_ind           IN     VARCHAR2,
    x_administrator_id                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kkillams
  ||  Created On : 06-FEB-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who      When        What
  ||  (reverse chronological order - newest change first)
  ||  kdande   18-Oct-2002 Added new columns as per the Enh# 2632096.
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_as_docproc_stup
      WHERE    tpset_id                          = x_tpset_id;

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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT    igs_as_docproc_stup_s.NEXTVAL
    INTO      x_tpset_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_tpset_id                          => x_tpset_id,
      x_lifetime_trans_fee_ind            => x_lifetime_trans_fee_ind,
      x_provide_transcript_ind            => x_provide_transcript_ind,
      x_trans_request_if_hold_ind         => x_trans_request_if_hold_ind,
      x_all_acad_hist_in_one_doc_ind      => x_all_acad_hist_in_one_doc_ind,
      x_hold_deliv_ind                    => x_hold_deliv_ind,
      x_allow_enroll_cert_ind             => x_allow_enroll_cert_ind,
      x_bill_me_later_ind                 => x_bill_me_later_ind,
      x_edi_capable_ind                   => x_edi_capable_ind,
      x_always_send_docs_via_edi          => x_always_send_docs_via_edi,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_provide_duplicate_doc_ind         => x_provide_duplicate_doc_ind,
      x_charge_document_fee_ind           => x_charge_document_fee_ind,
      x_charge_delivery_fee_ind           => x_charge_delivery_fee_ind,
      x_administrator_id                  => x_administrator_id
    );

    INSERT INTO igs_as_docproc_stup (
      tpset_id,
      lifetime_trans_fee_ind,
      provide_transcript_ind,
      trans_request_if_hold_ind,
      all_acad_hist_in_one_doc_ind,
      hold_deliv_ind,
      allow_enroll_cert_ind,
      bill_me_later_ind,
      edi_capable_ind,
      always_send_docs_via_edi,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      provide_duplicate_doc_ind,
      charge_document_fee_ind,
      charge_delivery_fee_ind,
      administrator_id
    ) VALUES (
      new_references.tpset_id,
      new_references.lifetime_trans_fee_ind,
      new_references.provide_transcript_ind,
      new_references.trans_request_if_hold_ind,
      new_references.all_acad_hist_in_one_doc_ind,
      new_references.hold_deliv_ind,
      new_references.allow_enroll_cert_ind,
      new_references.bill_me_later_ind,
      new_references.edi_capable_ind,
      new_references.always_send_docs_via_edi,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.provide_duplicate_doc_ind,
      new_references.charge_document_fee_ind,
      new_references.charge_delivery_fee_ind,
      new_references.administrator_id
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
    x_tpset_id                          IN     NUMBER,
    x_lifetime_trans_fee_ind            IN     VARCHAR2,
    x_provide_transcript_ind            IN     VARCHAR2,
    x_trans_request_if_hold_ind         IN     VARCHAR2,
    x_all_acad_hist_in_one_doc_ind      IN     VARCHAR2,
    x_hold_deliv_ind                    IN     VARCHAR2,
    x_allow_enroll_cert_ind             IN     VARCHAR2,
    x_bill_me_later_ind                 IN     VARCHAR2,
    x_edi_capable_ind                   IN     VARCHAR2,
    x_always_send_docs_via_edi          IN     VARCHAR2,
    x_provide_duplicate_doc_ind    IN     VARCHAR2,
    x_charge_document_fee_ind           IN     VARCHAR2,
    x_charge_delivery_fee_ind           IN     VARCHAR2,
    x_administrator_id                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kkillams
  ||  Created On : 06-FEB-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who      When        What
  ||  (reverse chronological order - newest change first)
  ||  kdande   18-Oct-2002 Added new columns as per the Enh# 2632096.
  */
    CURSOR c1 IS
      SELECT
        lifetime_trans_fee_ind,
        provide_transcript_ind,
        trans_request_if_hold_ind,
        all_acad_hist_in_one_doc_ind,
        hold_deliv_ind,
        allow_enroll_cert_ind,
        bill_me_later_ind,
        edi_capable_ind,
        always_send_docs_via_edi,
        provide_duplicate_doc_ind,
        charge_document_fee_ind,
        charge_delivery_fee_ind,
        administrator_id
      FROM  igs_as_docproc_stup
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
        (tlinfo.lifetime_trans_fee_ind = x_lifetime_trans_fee_ind)
        AND (tlinfo.provide_transcript_ind = x_provide_transcript_ind)
        AND (tlinfo.trans_request_if_hold_ind = x_trans_request_if_hold_ind)
        AND (tlinfo.all_acad_hist_in_one_doc_ind = x_all_acad_hist_in_one_doc_ind)
        AND (tlinfo.hold_deliv_ind = x_hold_deliv_ind)
        AND (tlinfo.allow_enroll_cert_ind = x_allow_enroll_cert_ind)
        AND (tlinfo.bill_me_later_ind = x_bill_me_later_ind)
        AND (tlinfo.edi_capable_ind = x_edi_capable_ind)
        AND (tlinfo.always_send_docs_via_edi = x_always_send_docs_via_edi)
        AND ((tlinfo.charge_document_fee_ind = x_charge_document_fee_ind) OR ((tlinfo.charge_document_fee_ind IS NULL) AND (X_charge_document_fee_ind IS NULL)))
        AND ((tlinfo.charge_delivery_fee_ind = x_charge_delivery_fee_ind) OR ((tlinfo.charge_delivery_fee_ind IS NULL) AND (X_charge_delivery_fee_ind IS NULL)))
        AND ((tlinfo.administrator_id = x_administrator_id) OR ((tlinfo.administrator_id IS NULL) AND (X_administrator_id IS NULL)))
        AND ((tlinfo.provide_duplicate_doc_ind = x_provide_duplicate_doc_ind) OR ((tlinfo.provide_duplicate_doc_ind IS NULL) AND (X_provide_duplicate_doc_ind IS NULL)))
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
    x_tpset_id                          IN     NUMBER,
    x_lifetime_trans_fee_ind            IN     VARCHAR2,
    x_provide_transcript_ind            IN     VARCHAR2,
    x_trans_request_if_hold_ind         IN     VARCHAR2,
    x_all_acad_hist_in_one_doc_ind      IN     VARCHAR2,
    x_hold_deliv_ind                    IN     VARCHAR2,
    x_allow_enroll_cert_ind             IN     VARCHAR2,
    x_bill_me_later_ind                 IN     VARCHAR2,
    x_edi_capable_ind                   IN     VARCHAR2,
    x_always_send_docs_via_edi          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_provide_duplicate_doc_ind    IN     VARCHAR2,
    x_charge_document_fee_ind           IN     VARCHAR2,
    x_charge_delivery_fee_ind           IN     VARCHAR2,
    x_administrator_id                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kkillams
  ||  Created On : 06-FEB-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who      When        What
  ||  (reverse chronological order - newest change first)
  ||  kdande   18-Oct-2002 Added new columns as per the Enh# 2632096.
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_tpset_id                          => x_tpset_id,
      x_lifetime_trans_fee_ind            => x_lifetime_trans_fee_ind,
      x_provide_transcript_ind            => x_provide_transcript_ind,
      x_trans_request_if_hold_ind         => x_trans_request_if_hold_ind,
      x_all_acad_hist_in_one_doc_ind      => x_all_acad_hist_in_one_doc_ind,
      x_hold_deliv_ind                    => x_hold_deliv_ind,
      x_allow_enroll_cert_ind             => x_allow_enroll_cert_ind,
      x_bill_me_later_ind                 => x_bill_me_later_ind,
      x_edi_capable_ind                   => x_edi_capable_ind,
      x_always_send_docs_via_edi          => x_always_send_docs_via_edi,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_provide_duplicate_doc_ind    => x_provide_duplicate_doc_ind,
      x_charge_document_fee_ind           => x_charge_document_fee_ind,
      x_charge_delivery_fee_ind           => x_charge_delivery_fee_ind,
      x_administrator_id                  => x_administrator_id
    );

    UPDATE igs_as_docproc_stup
      SET
        lifetime_trans_fee_ind            = new_references.lifetime_trans_fee_ind,
        provide_transcript_ind            = new_references.provide_transcript_ind,
        trans_request_if_hold_ind         = new_references.trans_request_if_hold_ind,
        all_acad_hist_in_one_doc_ind      = new_references.all_acad_hist_in_one_doc_ind,
        hold_deliv_ind                    = new_references.hold_deliv_ind,
        allow_enroll_cert_ind             = new_references.allow_enroll_cert_ind,
        bill_me_later_ind                 = new_references.bill_me_later_ind,
        edi_capable_ind                   = new_references.edi_capable_ind,
        always_send_docs_via_edi          = new_references.always_send_docs_via_edi,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        provide_duplicate_doc_ind    = x_provide_duplicate_doc_ind,
        charge_document_fee_ind           = x_charge_document_fee_ind,
        charge_delivery_fee_ind           = x_charge_delivery_fee_ind,
        administrator_id                  = x_administrator_id
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_tpset_id                          IN OUT NOCOPY NUMBER,
    x_lifetime_trans_fee_ind            IN     VARCHAR2,
    x_provide_transcript_ind            IN     VARCHAR2,
    x_trans_request_if_hold_ind         IN     VARCHAR2,
    x_all_acad_hist_in_one_doc_ind      IN     VARCHAR2,
    x_hold_deliv_ind                    IN     VARCHAR2,
    x_allow_enroll_cert_ind             IN     VARCHAR2,
    x_bill_me_later_ind                 IN     VARCHAR2,
    x_edi_capable_ind                   IN     VARCHAR2,
    x_always_send_docs_via_edi          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_provide_duplicate_doc_ind    IN     VARCHAR2,
    x_charge_document_fee_ind           IN     VARCHAR2,
    x_charge_delivery_fee_ind           IN     VARCHAR2,
    x_administrator_id                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kkillams
  ||  Created On : 06-FEB-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who      When        What
  ||  (reverse chronological order - newest change first)
  ||  kdande   18-Oct-2002 Added new columns as per the Enh# 2632096.
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_as_docproc_stup
      WHERE    tpset_id                          = x_tpset_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_tpset_id,
        x_lifetime_trans_fee_ind,
        x_provide_transcript_ind,
        x_trans_request_if_hold_ind,
        x_all_acad_hist_in_one_doc_ind,
        x_hold_deliv_ind,
        x_allow_enroll_cert_ind,
        x_bill_me_later_ind,
        x_edi_capable_ind,
        x_always_send_docs_via_edi,
        x_mode,
        x_provide_duplicate_doc_ind,
        x_charge_document_fee_ind,
        x_charge_delivery_fee_ind,
        x_administrator_id
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_tpset_id,
      x_lifetime_trans_fee_ind,
      x_provide_transcript_ind,
      x_trans_request_if_hold_ind,
      x_all_acad_hist_in_one_doc_ind,
      x_hold_deliv_ind,
      x_allow_enroll_cert_ind,
      x_bill_me_later_ind,
      x_edi_capable_ind,
      x_always_send_docs_via_edi,
      x_mode,
      x_provide_duplicate_doc_ind,
      x_charge_document_fee_ind,
      x_charge_delivery_fee_ind,
      x_administrator_id
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : kkillams
  ||  Created On : 06-FEB-2002
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

    DELETE FROM igs_as_docproc_stup
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_as_docproc_stup_pkg;

/
