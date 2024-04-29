--------------------------------------------------------
--  DDL for Package Body IGF_SL_CL_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_CL_SETUP_PKG" AS
/* $Header: IGFLI08B.pls 120.0 2005/06/01 14:00:57 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_sl_cl_setup_all%ROWTYPE;
  new_references igf_sl_cl_setup_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_clset_id                          IN     NUMBER      DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_borw_interest_ind                 IN     VARCHAR2    DEFAULT NULL,
    x_sch_non_ed_brc_id                 IN     VARCHAR2    DEFAULT NULL,
    x_lender_id                         IN     VARCHAR2    DEFAULT NULL,
    x_duns_lender_id                    IN     VARCHAR2    DEFAULT NULL,
    x_lend_non_ed_brc_id                IN     VARCHAR2    DEFAULT NULL,
    x_guarantor_id                      IN     VARCHAR2    DEFAULT NULL,
    x_duns_guarnt_id                    IN     VARCHAR2    DEFAULT NULL,
    x_recipient_id                      IN     VARCHAR2    DEFAULT NULL,
    x_recipient_type                    IN     VARCHAR2    DEFAULT NULL,
    x_duns_recip_id                     IN     VARCHAR2    DEFAULT NULL,
    x_recip_non_ed_brc_id               IN     VARCHAR2    DEFAULT NULL,
    x_est_orig_fee_perct                IN     NUMBER      DEFAULT NULL,
    x_est_guarnt_fee_perct              IN     NUMBER      DEFAULT NULL,
    x_hold_rel_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_req_serial_loan_code              IN     VARCHAR2    DEFAULT NULL,
    x_loan_award_method                 IN     VARCHAR2    DEFAULT NULL,
    x_prc_type_code                     IN     VARCHAR2    DEFAULT NULL,
    x_pnote_delivery_code               IN     VARCHAR2    DEFAULT NULL,
    x_media_type                        IN     VARCHAR2    DEFAULT NULL,
    x_eft_authorization                 IN     VARCHAR2    DEFAULT NULL,
    x_auto_late_disb_ind                IN     VARCHAR2    DEFAULT NULL,
    x_cl_version                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_est_alt_orig_fee_perct            IN     NUMBER      DEFAULT NULL,
    x_est_alt_guarnt_fee_perct          IN     NUMBER      DEFAULT NULL,
    x_relationship_cd                   IN     VARCHAR2    DEFAULT NULL,
    x_default_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_plus_processing_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_fund_return_method_code           IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || veramach        5-SEP-2003      Added x_relationship_code_txt,x_default_flag,x_party_id for the newly added columns
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_SL_CL_SETUP_ALL
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
    new_references.clset_id                          := x_clset_id;
    new_references.ci_cal_type                       := x_ci_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.borw_interest_ind                 := x_borw_interest_ind;
    new_references.est_orig_fee_perct                := x_est_orig_fee_perct;
    new_references.est_guarnt_fee_perct              := x_est_guarnt_fee_perct;
    new_references.hold_rel_ind                      := x_hold_rel_ind;
    new_references.req_serial_loan_code              := x_req_serial_loan_code;
    new_references.prc_type_code                     := x_prc_type_code;
    new_references.pnote_delivery_code               := x_pnote_delivery_code;
    new_references.eft_authorization                 := x_eft_authorization;
    new_references.auto_late_disb_ind                := x_auto_late_disb_ind;

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

    -- brajendr: newly added bcoz of datamodel changes
    new_references.est_alt_orig_fee_perct            := x_est_alt_orig_fee_perct;
    new_references.est_alt_guarnt_fee_perct          := x_est_alt_guarnt_fee_perct;


    new_references.relationship_cd                   := x_relationship_cd      ;
    new_references.default_flag                      := x_default_flag;
    new_references.party_id                          := x_party_id;
    new_references.cl_version			     :=x_cl_version;
    new_references.plus_processing_type_code         := x_plus_processing_type_code;
    new_references.fund_return_method_code           := x_fund_return_method_code;

END set_column_values;


  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.ci_cal_type,
           new_references.ci_sequence_number,
	   new_references.relationship_cd      ,
	   new_references.party_id
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||veramach          5-SEP-2003      Added call to igf_sl_cl_recipient_pkg.get_uk1_for_validation
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    IF (((old_references.ci_cal_type = new_references.ci_cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.ci_cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.ci_cal_type,
                new_references.ci_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
    IF (((old_references.relationship_cd       = new_references.relationship_cd      )) OR
        ((new_references.relationship_cd       IS NULL))) THEN
      NULL;
    ELSIF NOT igf_sl_cl_recipient_pkg.get_uk1_for_validation (
                new_references.relationship_cd
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_clset_id                          IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_cl_setup_all
      WHERE    clset_id = x_clset_id
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


  FUNCTION get_uk_for_validation (
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_relationship_cd                   IN     VARCHAR2,
    x_party_id                          IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || veramach         5-SEP-2003      Changed the signature of the function to use relationship_code_txt and party_id
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_cl_setup_all
      WHERE    ci_cal_type            = x_ci_cal_type
      AND      ci_sequence_number     = x_ci_sequence_number
      AND      relationship_cd        = x_relationship_cd
      AND      NVL(party_id,-100) = NVL(x_party_id,-100)
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (true);
        ELSE
       CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_uk_for_validation ;


  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_cl_setup_all
      WHERE   ((ci_cal_type = x_cal_type) AND
               (ci_sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_SL_CLSET_CI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst;


  PROCEDURE get_fk_igf_sl_cl_recipient (
    x_relationship_cd                 IN     VARCHAR2
  ) AS
  /*
  ||  Created By : veramach
  ||  Created On : 05-SEP-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||veramach         16-SEP-2003      1. Changed message name from IGF_SL_CL_RECIP_FK to IGF_SL_CLSET_FK
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_cl_setup_all
      WHERE   ((relationship_cd       = x_relationship_cd      ));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_SL_CLSET_RECIP_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_sl_cl_recipient;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_clset_id                          IN     NUMBER      DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_borw_interest_ind                 IN     VARCHAR2    DEFAULT NULL,
    x_sch_non_ed_brc_id                 IN     VARCHAR2    DEFAULT NULL,
    x_lender_id                         IN     VARCHAR2    DEFAULT NULL,
    x_duns_lender_id                    IN     VARCHAR2    DEFAULT NULL,
    x_lend_non_ed_brc_id                IN     VARCHAR2    DEFAULT NULL,
    x_guarantor_id                      IN     VARCHAR2    DEFAULT NULL,
    x_duns_guarnt_id                    IN     VARCHAR2    DEFAULT NULL,
    x_recipient_id                      IN     VARCHAR2    DEFAULT NULL,
    x_recipient_type                    IN     VARCHAR2    DEFAULT NULL,
    x_duns_recip_id                     IN     VARCHAR2    DEFAULT NULL,
    x_recip_non_ed_brc_id               IN     VARCHAR2    DEFAULT NULL,
    x_est_orig_fee_perct                IN     NUMBER      DEFAULT NULL,
    x_est_guarnt_fee_perct              IN     NUMBER      DEFAULT NULL,
    x_hold_rel_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_req_serial_loan_code              IN     VARCHAR2    DEFAULT NULL,
    x_loan_award_method                 IN     VARCHAR2    DEFAULT NULL,
    x_prc_type_code                     IN     VARCHAR2    DEFAULT NULL,
    x_pnote_delivery_code               IN     VARCHAR2    DEFAULT NULL,
    x_media_type                        IN     VARCHAR2    DEFAULT NULL,
    x_eft_authorization                 IN     VARCHAR2    DEFAULT NULL,
    x_auto_late_disb_ind                IN     VARCHAR2    DEFAULT NULL,
    x_cl_version                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_est_alt_orig_fee_perct            IN     NUMBER      DEFAULT NULL,
    x_est_alt_guarnt_fee_perct          IN     NUMBER      DEFAULT NULL,
    x_relationship_cd                   IN     VARCHAR2    DEFAULT NULL,
    x_default_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_plus_processing_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_fund_return_method_code           IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || veramach        5-SEP-2003      Added x_relationship_code_txt,x_default_flag,x_party_id for the newly added columns
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_clset_id,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_borw_interest_ind,
      x_sch_non_ed_brc_id,
      x_lender_id,
      x_duns_lender_id,
      x_lend_non_ed_brc_id,
      x_guarantor_id,
      x_duns_guarnt_id,
      x_recipient_id,
      x_recipient_type,
      x_duns_recip_id,
      x_recip_non_ed_brc_id,
      x_est_orig_fee_perct,
      x_est_guarnt_fee_perct,
      x_hold_rel_ind,
      x_req_serial_loan_code,
      x_loan_award_method,
      x_prc_type_code,
      x_pnote_delivery_code,
      x_media_type,
      x_eft_authorization,
      x_auto_late_disb_ind,
      x_cl_version,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_est_alt_orig_fee_perct,
      x_est_alt_guarnt_fee_perct,
      x_relationship_cd      ,
      x_default_flag,
      x_party_id,
      x_plus_processing_type_code,
      x_fund_return_method_code
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.clset_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.clset_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_clset_id                          IN OUT NOCOPY NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_borw_interest_ind                 IN     VARCHAR2,
    x_sch_non_ed_brc_id                 IN     VARCHAR2 DEFAULT NULL,
    x_lender_id                         IN     VARCHAR2,
    x_duns_lender_id                    IN     VARCHAR2 DEFAULT NULL,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2 DEFAULT NULL,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_duns_recip_id                     IN     VARCHAR2 DEFAULT NULL,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_est_orig_fee_perct                IN     NUMBER   DEFAULT NULL,
    x_est_guarnt_fee_perct              IN     NUMBER   DEFAULT NULL,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_req_serial_loan_code              IN     VARCHAR2,
    x_loan_award_method                 IN     VARCHAR2,
    x_prc_type_code                     IN     VARCHAR2,
    x_pnote_delivery_code               IN     VARCHAR2,
    x_media_type                        IN     VARCHAR2,
    x_eft_authorization                 IN     VARCHAR2,
    x_auto_late_disb_ind                IN     VARCHAR2,
    x_cl_version                        IN     VARCHAR2 DEFAULT NULL,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_est_alt_orig_fee_perct            IN     NUMBER   DEFAULT NULL,
    x_est_alt_guarnt_fee_perct          IN     NUMBER   DEFAULT NULL,
    x_relationship_cd                   IN     VARCHAR2    DEFAULT NULL,
    x_default_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_plus_processing_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_fund_return_method_code           IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || veramach        5-SEP-2003      Added x_relationship_code_txt,x_default_flag,x_party_id for the newly added columns
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_sl_cl_setup_all
      WHERE    clset_id                          = x_clset_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    l_org_id			 igf_sl_cl_setup_all.org_id%TYPE DEFAULT igf_aw_gen.get_org_id;

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

    SELECT igf_sl_cl_setup_s.nextval INTO x_clset_id FROM DUAL;


    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_clset_id                          => x_clset_id,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_borw_interest_ind                 => x_borw_interest_ind,
      x_sch_non_ed_brc_id                 => x_sch_non_ed_brc_id,
      x_lender_id                         => x_lender_id,
      x_duns_lender_id                    => x_duns_lender_id,
      x_lend_non_ed_brc_id                => x_lend_non_ed_brc_id,
      x_guarantor_id                      => x_guarantor_id,
      x_duns_guarnt_id                    => x_duns_guarnt_id,
      x_recipient_id                      => x_recipient_id,
      x_recipient_type                    => x_recipient_type,
      x_duns_recip_id                     => x_duns_recip_id,
      x_recip_non_ed_brc_id               => x_recip_non_ed_brc_id,
      x_est_orig_fee_perct                => x_est_orig_fee_perct,
      x_est_guarnt_fee_perct              => x_est_guarnt_fee_perct,
      x_hold_rel_ind                      => x_hold_rel_ind,
      x_req_serial_loan_code              => x_req_serial_loan_code,
      x_loan_award_method                 => x_loan_award_method,
      x_prc_type_code                     => x_prc_type_code,
      x_pnote_delivery_code               => x_pnote_delivery_code,
      x_media_type                        => x_media_type,
      x_eft_authorization                 => x_eft_authorization,
      x_auto_late_disb_ind                => x_auto_late_disb_ind,
      x_cl_version                        => x_cl_version,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_est_alt_orig_fee_perct            => x_est_alt_orig_fee_perct,
      x_est_alt_guarnt_fee_perct          => x_est_alt_guarnt_fee_perct,
      x_relationship_cd                   => x_relationship_cd      ,
      x_default_flag                      => x_default_flag,
      x_party_id                          => x_party_id,
      x_plus_processing_type_code         => x_plus_processing_type_code,
      x_fund_return_method_code           => x_fund_return_method_code
    );


    INSERT INTO igf_sl_cl_setup_all(
      clset_id,
      ci_cal_type,
      ci_sequence_number,
      borw_interest_ind,
      est_orig_fee_perct,
      est_guarnt_fee_perct,
      hold_rel_ind,
      req_serial_loan_code,
      prc_type_code,
      pnote_delivery_code,
      eft_authorization,
      auto_late_disb_ind,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      org_id,
      est_alt_orig_fee_perct,
      est_alt_guarnt_fee_perct,
      relationship_cd      ,
      default_flag,
      party_id,
      cl_version,
      plus_processing_type_code,
      fund_return_method_code
    ) VALUES (
      new_references.clset_id,
      new_references.ci_cal_type,
      new_references.ci_sequence_number,
      new_references.borw_interest_ind,
      new_references.est_orig_fee_perct,
      new_references.est_guarnt_fee_perct,
      new_references.hold_rel_ind,
      new_references.req_serial_loan_code,
      new_references.prc_type_code,
      new_references.pnote_delivery_code,
      new_references.eft_authorization,
      new_references.auto_late_disb_ind,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      l_org_id,
      new_references.est_alt_orig_fee_perct,
      new_references.est_alt_guarnt_fee_perct,
      new_references.relationship_cd      ,
      new_references.default_flag,
      new_references.party_id,
      new_references.cl_version,
      new_references.plus_processing_type_code,
      new_references.fund_return_method_code
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
    x_clset_id                          IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_borw_interest_ind                 IN     VARCHAR2,
    x_sch_non_ed_brc_id                 IN     VARCHAR2 DEFAULT NULL,
    x_lender_id                         IN     VARCHAR2,
    x_duns_lender_id                    IN     VARCHAR2 DEFAULT NULL,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2 DEFAULT NULL,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_duns_recip_id                     IN     VARCHAR2 DEFAULT NULL,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_est_orig_fee_perct                IN     NUMBER   DEFAULT NULL,
    x_est_guarnt_fee_perct              IN     NUMBER   DEFAULT NULL,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_req_serial_loan_code              IN     VARCHAR2,
    x_loan_award_method                 IN     VARCHAR2,
    x_prc_type_code                     IN     VARCHAR2,
    x_pnote_delivery_code               IN     VARCHAR2,
    x_media_type                        IN     VARCHAR2,
    x_eft_authorization                 IN     VARCHAR2,
    x_auto_late_disb_ind                IN     VARCHAR2,
    x_cl_version                        IN     VARCHAR2    DEFAULT NULL,
    x_est_alt_orig_fee_perct            IN     NUMBER   DEFAULT NULL,
    x_est_alt_guarnt_fee_perct          IN     NUMBER   DEFAULT NULL,
    x_relationship_cd                   IN     VARCHAR2    DEFAULT NULL,
    x_default_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_plus_processing_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_fund_return_method_code           IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || veramach        5-SEP-2003      Added x_relationship_code_txt,x_default_flag,x_party_id for the newly added columns
  ||  masehgal        16-Jun-2003     # 2990040   FACR115
  ||                                  Changes to lock row for cl_version
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        ci_cal_type,
        ci_sequence_number,
        borw_interest_ind,
        est_orig_fee_perct,
        est_guarnt_fee_perct,
        hold_rel_ind,
        req_serial_loan_code,
        prc_type_code,
        pnote_delivery_code,
        eft_authorization,
        auto_late_disb_ind,
        org_id,
        est_alt_orig_fee_perct,
        est_alt_guarnt_fee_perct,
        relationship_cd      ,
        default_flag,
        party_id,
	cl_version,
	plus_processing_type_code,
        fund_return_method_code
      FROM  igf_sl_cl_setup_all
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
        (tlinfo.ci_cal_type = x_ci_cal_type)
        AND (tlinfo.ci_sequence_number = x_ci_sequence_number)
        AND ((tlinfo.borw_interest_ind = x_borw_interest_ind) OR ((tlinfo.borw_interest_ind IS NULL) AND (X_borw_interest_ind IS NULL)))
        AND ((tlinfo.est_orig_fee_perct = x_est_orig_fee_perct) OR ((tlinfo.est_orig_fee_perct IS NULL) AND (x_est_orig_fee_perct IS NULL)))
        AND ((tlinfo.est_guarnt_fee_perct = x_est_guarnt_fee_perct) OR ((tlinfo.est_guarnt_fee_perct IS NULL) AND (x_est_guarnt_fee_perct IS NULL)))
        AND (tlinfo.hold_rel_ind = x_hold_rel_ind)
        AND (tlinfo.req_serial_loan_code = x_req_serial_loan_code)
        AND (tlinfo.prc_type_code = x_prc_type_code)
        AND (tlinfo.pnote_delivery_code = x_pnote_delivery_code)
        AND ((tlinfo.eft_authorization = x_eft_authorization) OR ((tlinfo.eft_authorization IS NULL) AND (X_eft_authorization IS NULL)))
        AND ((tlinfo.auto_late_disb_ind = x_auto_late_disb_ind) OR ((tlinfo.auto_late_disb_ind IS NULL) AND (X_auto_late_disb_ind IS NULL)))
        AND ((tlinfo.est_alt_orig_fee_perct = x_est_alt_orig_fee_perct) OR ((tlinfo.est_alt_orig_fee_perct IS NULL) AND (x_est_alt_orig_fee_perct IS NULL)))
        AND ((tlinfo.est_alt_guarnt_fee_perct = x_est_alt_guarnt_fee_perct) OR ((tlinfo.est_alt_guarnt_fee_perct IS NULL) AND (x_est_alt_guarnt_fee_perct IS NULL)))
	AND ((tlinfo.relationship_cd       = x_relationship_cd      ) OR ((tlinfo.relationship_cd       IS NULL) AND (x_relationship_cd       IS NULL)))
	AND ((tlinfo.default_flag = x_default_flag) OR ((tlinfo.default_flag IS NULL) AND (x_default_flag IS NULL)))
	AND ((tlinfo.party_id = x_party_id) OR ((tlinfo.party_id IS NULL) AND (x_party_id IS NULL)))
        AND ((tlinfo.cl_version = x_cl_version) OR ((tlinfo.cl_version IS NULL) AND (x_cl_version IS NULL)))
        AND ((tlinfo.plus_processing_type_code = x_plus_processing_type_code) OR ((tlinfo.plus_processing_type_code IS NULL) AND (x_plus_processing_type_code IS NULL)))
	AND ((tlinfo.fund_return_method_code = x_fund_return_method_code) OR ((tlinfo.fund_return_method_code IS NULL) AND (x_fund_return_method_code IS NULL)))
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
    x_clset_id                          IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_borw_interest_ind                 IN     VARCHAR2,
    x_sch_non_ed_brc_id                 IN     VARCHAR2    DEFAULT NULL,
    x_lender_id                         IN     VARCHAR2,
    x_duns_lender_id                    IN     VARCHAR2   DEFAULT NULL,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2   DEFAULT NULL,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_duns_recip_id                     IN     VARCHAR2   DEFAULT NULL,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_est_orig_fee_perct                IN     NUMBER   DEFAULT NULL,
    x_est_guarnt_fee_perct              IN     NUMBER   DEFAULT NULL,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_req_serial_loan_code              IN     VARCHAR2,
    x_loan_award_method                 IN     VARCHAR2,
    x_prc_type_code                     IN     VARCHAR2,
    x_pnote_delivery_code               IN     VARCHAR2,
    x_media_type                        IN     VARCHAR2,
    x_eft_authorization                 IN     VARCHAR2,
    x_auto_late_disb_ind                IN     VARCHAR2,
    x_cl_version                        IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_est_alt_orig_fee_perct            IN     NUMBER   DEFAULT NULL,
    x_est_alt_guarnt_fee_perct          IN     NUMBER   DEFAULT NULL,
    x_relationship_cd                   IN     VARCHAR2     DEFAULT NULL,
    x_default_flag                      IN     VARCHAR2     DEFAULT NULL,
    x_party_id                          IN     NUMBER       DEFAULT NULL,
    x_plus_processing_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_fund_return_method_code           IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || veramach        5-SEP-2003      Added x_relationship_code_txt,x_default_flag,x_party_id for the newly added columns
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_clset_id                          => x_clset_id,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_borw_interest_ind                 => x_borw_interest_ind,
      x_sch_non_ed_brc_id                 => x_sch_non_ed_brc_id,
      x_lender_id                         => x_lender_id,
      x_duns_lender_id                    => x_duns_lender_id,
      x_lend_non_ed_brc_id                => x_lend_non_ed_brc_id,
      x_guarantor_id                      => x_guarantor_id,
      x_duns_guarnt_id                    => x_duns_guarnt_id,
      x_recipient_id                      => x_recipient_id,
      x_recipient_type                    => x_recipient_type,
      x_duns_recip_id                     => x_duns_recip_id,
      x_recip_non_ed_brc_id               => x_recip_non_ed_brc_id,
      x_est_orig_fee_perct                => x_est_orig_fee_perct,
      x_est_guarnt_fee_perct              => x_est_guarnt_fee_perct,
      x_hold_rel_ind                      => x_hold_rel_ind,
      x_req_serial_loan_code              => x_req_serial_loan_code,
      x_loan_award_method                 => x_loan_award_method,
      x_prc_type_code                     => x_prc_type_code,
      x_pnote_delivery_code               => x_pnote_delivery_code,
      x_media_type                        => x_media_type,
      x_eft_authorization                 => x_eft_authorization,
      x_auto_late_disb_ind                => x_auto_late_disb_ind,
      x_cl_version                        => x_cl_version,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_est_alt_orig_fee_perct            => x_est_alt_orig_fee_perct,
      x_est_alt_guarnt_fee_perct          => x_est_alt_guarnt_fee_perct,
      x_relationship_cd                   => x_relationship_cd      ,
      x_default_flag                      => x_default_flag,
      x_party_id                          => x_party_id,
      x_plus_processing_type_code         => x_plus_processing_type_code,
      x_fund_return_method_code		  => x_fund_return_method_code
    );

    UPDATE igf_sl_cl_setup_all
      SET
        ci_cal_type                       = new_references.ci_cal_type,
        ci_sequence_number                = new_references.ci_sequence_number,
        borw_interest_ind                 = new_references.borw_interest_ind,
        est_orig_fee_perct                = new_references.est_orig_fee_perct,
        est_guarnt_fee_perct              = new_references.est_guarnt_fee_perct,
        hold_rel_ind                      = new_references.hold_rel_ind,
        req_serial_loan_code              = new_references.req_serial_loan_code,
        prc_type_code                     = new_references.prc_type_code,
        pnote_delivery_code               = new_references.pnote_delivery_code,
        eft_authorization                 = new_references.eft_authorization,
        auto_late_disb_ind                = new_references.auto_late_disb_ind,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        est_alt_orig_fee_perct            = x_est_alt_orig_fee_perct,
        est_alt_guarnt_fee_perct          = x_est_alt_guarnt_fee_perct,
	    relationship_cd                   = x_relationship_cd,
	    default_flag                      = x_default_flag,
	    party_id                          = x_party_id,
	    cl_version			      = x_cl_version,
	    plus_processing_type_code         = x_plus_processing_type_code,
	    fund_return_method_code	      = x_fund_return_method_code
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_clset_id                          IN OUT NOCOPY NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_borw_interest_ind                 IN     VARCHAR2,
    x_sch_non_ed_brc_id                 IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_duns_lender_id                    IN     VARCHAR2   DEFAULT NULL,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2   DEFAULT NULL,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_duns_recip_id                     IN     VARCHAR2   DEFAULT NULL,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_est_orig_fee_perct                IN     NUMBER   DEFAULT NULL,
    x_est_guarnt_fee_perct              IN     NUMBER   DEFAULT NULL,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_req_serial_loan_code              IN     VARCHAR2,
    x_loan_award_method                 IN     VARCHAR2,
    x_prc_type_code                     IN     VARCHAR2,
    x_pnote_delivery_code               IN     VARCHAR2,
    x_media_type                        IN     VARCHAR2,
    x_eft_authorization                 IN     VARCHAR2,
    x_auto_late_disb_ind                IN     VARCHAR2,
    x_cl_version                        IN     VARCHAR2   DEFAULT NULL,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_est_alt_orig_fee_perct            IN     NUMBER   DEFAULT NULL,
    x_est_alt_guarnt_fee_perct          IN     NUMBER   DEFAULT NULL,
    x_relationship_cd                   IN     VARCHAR2    DEFAULT NULL,
    x_default_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_plus_processing_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_fund_return_method_code           IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || veramach        5-SEP-2003      Added x_relationship_code_txt,x_default_flag,x_party_id for the newly added columns
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_sl_cl_setup_all
      WHERE    clset_id                          = x_clset_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_clset_id,
        x_ci_cal_type,
        x_ci_sequence_number,
        x_borw_interest_ind,
        x_sch_non_ed_brc_id,
        x_lender_id,
        x_duns_lender_id,
        x_lend_non_ed_brc_id,
        x_guarantor_id,
        x_duns_guarnt_id,
        x_recipient_id,
        x_recipient_type,
        x_duns_recip_id,
        x_recip_non_ed_brc_id,
        x_est_orig_fee_perct,
        x_est_guarnt_fee_perct,
        x_hold_rel_ind,
        x_req_serial_loan_code,
        x_loan_award_method,
        x_prc_type_code,
        x_pnote_delivery_code,
        x_media_type,
        x_eft_authorization,
        x_auto_late_disb_ind,
        x_cl_version,
        x_mode,
        x_est_alt_orig_fee_perct,
        x_est_alt_guarnt_fee_perct,
	x_relationship_cd      ,
	x_default_flag,
	x_party_id,
	x_plus_processing_type_code,
        x_fund_return_method_code
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_clset_id,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_borw_interest_ind,
      x_sch_non_ed_brc_id,
      x_lender_id,
      x_duns_lender_id,
      x_lend_non_ed_brc_id,
      x_guarantor_id,
      x_duns_guarnt_id,
      x_recipient_id,
      x_recipient_type,
      x_duns_recip_id,
      x_recip_non_ed_brc_id,
      x_est_orig_fee_perct,
      x_est_guarnt_fee_perct,
      x_hold_rel_ind,
      x_req_serial_loan_code,
      x_loan_award_method,
      x_prc_type_code,
      x_pnote_delivery_code,
      x_media_type,
      x_eft_authorization,
      x_auto_late_disb_ind,
      x_cl_version,
      x_mode,
      x_est_alt_orig_fee_perct,
      x_est_alt_guarnt_fee_perct,
      x_relationship_cd      ,
      x_default_flag,
      x_party_id,
      x_plus_processing_type_code,
      x_fund_return_method_code
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
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

    DELETE FROM igf_sl_cl_setup_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_sl_cl_setup_pkg;

/
