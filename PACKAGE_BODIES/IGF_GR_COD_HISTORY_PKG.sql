--------------------------------------------------------
--  DDL for Package Body IGF_GR_COD_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_GR_COD_HISTORY_PKG" AS
/* $Header: IGFGI23B.pls 120.0 2005/06/02 17:59:27 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_gr_cod_history%ROWTYPE;
  new_references igf_gr_cod_history%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_rfms_orig_hist_id                 IN     NUMBER ,
    x_origination_id                    IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_document_id_txt                   IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_fin_award_year                    IN     VARCHAR2,
    x_cps_trans_num                     IN     VARCHAR2,
    x_award_amt                         IN     NUMBER,
    x_coa_amt                           IN     NUMBER,
    x_low_tution_fee                    IN     VARCHAR2,
    x_incarc_flag                       IN     VARCHAR2,
    x_ver_status_code                   IN     VARCHAR2,
    x_enrollment_date                   IN     DATE,
    x_sec_efc_code                      IN     VARCHAR2,
    x_ytd_disb_amt                      IN     NUMBER,
    x_tot_elig_used                     IN     NUMBER,
    x_schd_pell_amt                     IN     NUMBER,
    x_neg_pend_amt                      IN     NUMBER,
    x_cps_verif_flag                    IN     VARCHAR2,
    x_high_cps_trans_num                IN     VARCHAR2,
    x_note_message                      IN     VARCHAR2,
    x_full_resp_code                    IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_source_entity_id_txt              IN     VARCHAR2,
    x_pell_status                       IN     VARCHAR2,
    x_pell_status_date                  IN     DATE,
    x_s_chg_ssn                         IN     VARCHAR2,
    x_driver_lic_state                  IN     VARCHAR2,
    x_driver_lic_number                 IN     VARCHAR2,
    x_s_chg_date_of_birth               IN     DATE,
    x_first_name                        IN     VARCHAR2,
    x_middle_name                       IN     VARCHAR2,
    x_s_chg_last_name                   IN     VARCHAR2,
    x_s_date_of_birth                   IN     DATE,
    x_s_ssn                             IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_permt_addr_foreign_flag           IN     VARCHAR2,
    x_addr_type_code                    IN     VARCHAR2,
    x_permt_addr_line_1                 IN     VARCHAR2,
    x_permt_addr_line_2                 IN     VARCHAR2,
    x_permt_addr_line_3                 IN     VARCHAR2,
    x_permt_addr_city                   IN     VARCHAR2,
    x_permt_addr_state_code             IN     VARCHAR2,
    x_permt_addr_post_code              IN     VARCHAR2,
    x_permt_addr_county                 IN     VARCHAR2,
    x_permt_addr_country                IN     VARCHAR2,
    x_phone_number_1                    IN     VARCHAR2,
    x_phone_number_2                    IN     VARCHAR2,
    x_phone_number_3                    IN     VARCHAR2,
    x_email_address                     IN     VARCHAR2,
    x_citzn_status_code                 IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 02-NOV-2004
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_gr_cod_history
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
    new_references.rfms_orig_hist_id                 := x_rfms_orig_hist_id;
    new_references.origination_id                    := x_origination_id;
    new_references.award_id                          := x_award_id;
    new_references.document_id_txt                   := x_document_id_txt;
    new_references.base_id                           := x_base_id;
    new_references.fin_award_year                    := x_fin_award_year;
    new_references.cps_trans_num                     := x_cps_trans_num;
    new_references.award_amt                         := x_award_amt;
    new_references.coa_amt                           := x_coa_amt;
    new_references.low_tution_fee                    := x_low_tution_fee;
    new_references.incarc_flag                       := x_incarc_flag;
    new_references.ver_status_code                   := x_ver_status_code;
    new_references.enrollment_date                   := x_enrollment_date;
    new_references.sec_efc_code                      := x_sec_efc_code;
    new_references.ytd_disb_amt                      := x_ytd_disb_amt;
    new_references.tot_elig_used                     := x_tot_elig_used;
    new_references.schd_pell_amt                     := x_schd_pell_amt;
    new_references.neg_pend_amt                      := x_neg_pend_amt;
    new_references.cps_verif_flag                    := x_cps_verif_flag;
    new_references.high_cps_trans_num                := x_high_cps_trans_num;
    new_references.note_message                      := x_note_message;
    new_references.full_resp_code                    := x_full_resp_code;
    new_references.atd_entity_id_txt                 := x_atd_entity_id_txt;
    new_references.rep_entity_id_txt                 := x_rep_entity_id_txt;
    new_references.source_entity_id_txt              := x_source_entity_id_txt;
    new_references.pell_status                       := x_pell_status;
    new_references.pell_status_date                  := x_pell_status_date;
    new_references.s_chg_ssn                         := x_s_chg_ssn;
    new_references.driver_lic_state                  := x_driver_lic_state;
    new_references.driver_lic_number                 := x_driver_lic_number;
    new_references.s_chg_date_of_birth               := x_s_chg_date_of_birth;
    new_references.first_name                        := x_first_name;
    new_references.middle_name                       := x_middle_name;
    new_references.s_chg_last_name                   := x_s_chg_last_name;
    new_references.s_date_of_birth                   := x_s_date_of_birth;
    new_references.s_ssn                             := x_s_ssn;
    new_references.s_last_name                       := x_s_last_name;
    new_references.permt_addr_foreign_flag           := x_permt_addr_foreign_flag;
    new_references.addr_type_code                    := x_addr_type_code;
    new_references.permt_addr_line_1                 := x_permt_addr_line_1;
    new_references.permt_addr_line_2                 := x_permt_addr_line_2;
    new_references.permt_addr_line_3                 := x_permt_addr_line_3;
    new_references.permt_addr_city                   := x_permt_addr_city;
    new_references.permt_addr_state_code             := x_permt_addr_state_code;
    new_references.permt_addr_post_code              := x_permt_addr_post_code;
    new_references.permt_addr_county                 := x_permt_addr_county;
    new_references.permt_addr_country                := x_permt_addr_country;
    new_references.phone_number_1                    := x_phone_number_1;
    new_references.phone_number_2                    := x_phone_number_2;
    new_references.phone_number_3                    := x_phone_number_3;
    new_references.email_address                     := x_email_address;
    new_references.citzn_status_code                 := x_citzn_status_code;

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
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 21-Oct-2004
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.award_id = new_references.award_id)) OR
        ((new_references.award_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_award_pkg.get_pk_for_validation (
                new_references.award_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;

 FUNCTION get_pk_for_validation (
    x_rfms_orig_hist_id                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 21-OCT-2004
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_gr_cod_history
      WHERE    rfms_orig_hist_id = x_rfms_orig_hist_id
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
    x_rfms_orig_hist_id                 IN     NUMBER ,
    x_origination_id                    IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_document_id_txt                   IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_fin_award_year                    IN     VARCHAR2,
    x_cps_trans_num                     IN     VARCHAR2,
    x_award_amt                         IN     NUMBER,
    x_coa_amt                           IN     NUMBER,
    x_low_tution_fee                    IN     VARCHAR2,
    x_incarc_flag                       IN     VARCHAR2,
    x_ver_status_code                   IN     VARCHAR2,
    x_enrollment_date                   IN     DATE,
    x_sec_efc_code                      IN     VARCHAR2,
    x_ytd_disb_amt                      IN     NUMBER,
    x_tot_elig_used                     IN     NUMBER,
    x_schd_pell_amt                     IN     NUMBER,
    x_neg_pend_amt                      IN     NUMBER,
    x_cps_verif_flag                    IN     VARCHAR2,
    x_high_cps_trans_num                IN     VARCHAR2,
    x_note_message                      IN     VARCHAR2,
    x_full_resp_code                    IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_source_entity_id_txt              IN     VARCHAR2,
    x_pell_status                       IN     VARCHAR2,
    x_pell_status_date                  IN     DATE,
    x_s_chg_ssn                         IN     VARCHAR2,
    x_driver_lic_state                  IN     VARCHAR2,
    x_driver_lic_number                 IN     VARCHAR2,
    x_s_chg_date_of_birth               IN     DATE,
    x_first_name                        IN     VARCHAR2,
    x_middle_name                       IN     VARCHAR2,
    x_s_chg_last_name                   IN     VARCHAR2,
    x_s_date_of_birth                   IN     DATE,
    x_s_ssn                             IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_permt_addr_foreign_flag           IN     VARCHAR2,
    x_addr_type_code                    IN     VARCHAR2,
    x_permt_addr_line_1                 IN     VARCHAR2,
    x_permt_addr_line_2                 IN     VARCHAR2,
    x_permt_addr_line_3                 IN     VARCHAR2,
    x_permt_addr_city                   IN     VARCHAR2,
    x_permt_addr_state_code             IN     VARCHAR2,
    x_permt_addr_post_code              IN     VARCHAR2,
    x_permt_addr_county                 IN     VARCHAR2,
    x_permt_addr_country                IN     VARCHAR2,
    x_phone_number_1                    IN     VARCHAR2,
    x_phone_number_2                    IN     VARCHAR2,
    x_phone_number_3                    IN     VARCHAR2,
    x_email_address                     IN     VARCHAR2,
    x_citzn_status_code                 IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 02-NOV-2004
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
      x_rfms_orig_hist_id,
      x_origination_id,
      x_award_id,
      x_document_id_txt,
      x_base_id,
      x_fin_award_year,
      x_cps_trans_num,
      x_award_amt,
      x_coa_amt,
      x_low_tution_fee,
      x_incarc_flag,
      x_ver_status_code,
      x_enrollment_date,
      x_sec_efc_code,
      x_ytd_disb_amt,
      x_tot_elig_used,
      x_schd_pell_amt,
      x_neg_pend_amt,
      x_cps_verif_flag,
      x_high_cps_trans_num,
      x_note_message,
      x_full_resp_code,
      x_atd_entity_id_txt,
      x_rep_entity_id_txt,
      x_source_entity_id_txt,
      x_pell_status,
      x_pell_status_date,
      x_s_chg_ssn,
      x_driver_lic_state,
      x_driver_lic_number,
      x_s_chg_date_of_birth,
      x_first_name,
      x_middle_name,
      x_s_chg_last_name,
      x_s_date_of_birth,
      x_s_ssn,
      x_s_last_name,
      x_permt_addr_foreign_flag,
      x_addr_type_code,
      x_permt_addr_line_1,
      x_permt_addr_line_2,
      x_permt_addr_line_3,
      x_permt_addr_city,
      x_permt_addr_state_code,
      x_permt_addr_post_code,
      x_permt_addr_county,
      x_permt_addr_country,
      x_phone_number_1,
      x_phone_number_2,
      x_phone_number_3,
      x_email_address,
      x_citzn_status_code,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
            new_references.rfms_orig_hist_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
            new_references.rfms_orig_hist_id
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
    x_rfms_orig_hist_id                 IN OUT NOCOPY   NUMBER ,
    x_origination_id                    IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_document_id_txt                   IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_fin_award_year                    IN     VARCHAR2,
    x_cps_trans_num                     IN     VARCHAR2,
    x_award_amt                         IN     NUMBER,
    x_coa_amt                           IN     NUMBER,
    x_low_tution_fee                    IN     VARCHAR2,
    x_incarc_flag                       IN     VARCHAR2,
    x_ver_status_code                   IN     VARCHAR2,
    x_enrollment_date                   IN     DATE,
    x_sec_efc_code                      IN     VARCHAR2,
    x_ytd_disb_amt                      IN     NUMBER,
    x_tot_elig_used                     IN     NUMBER,
    x_schd_pell_amt                     IN     NUMBER,
    x_neg_pend_amt                      IN     NUMBER,
    x_cps_verif_flag                    IN     VARCHAR2,
    x_high_cps_trans_num                IN     VARCHAR2,
    x_note_message                      IN     VARCHAR2,
    x_full_resp_code                    IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_source_entity_id_txt              IN     VARCHAR2,
    x_pell_status                       IN     VARCHAR2,
    x_pell_status_date                  IN     DATE,
    x_s_chg_ssn                         IN     VARCHAR2,
    x_driver_lic_state                  IN     VARCHAR2,
    x_driver_lic_number                 IN     VARCHAR2,
    x_s_chg_date_of_birth               IN     DATE,
    x_first_name                        IN     VARCHAR2,
    x_middle_name                       IN     VARCHAR2,
    x_s_chg_last_name                   IN     VARCHAR2,
    x_s_date_of_birth                   IN     DATE,
    x_s_ssn                             IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_permt_addr_foreign_flag           IN     VARCHAR2,
    x_addr_type_code                    IN     VARCHAR2,
    x_permt_addr_line_1                 IN     VARCHAR2,
    x_permt_addr_line_2                 IN     VARCHAR2,
    x_permt_addr_line_3                 IN     VARCHAR2,
    x_permt_addr_city                   IN     VARCHAR2,
    x_permt_addr_state_code             IN     VARCHAR2,
    x_permt_addr_post_code              IN     VARCHAR2,
    x_permt_addr_county                 IN     VARCHAR2,
    x_permt_addr_country                IN     VARCHAR2,
    x_phone_number_1                    IN     VARCHAR2,
    x_phone_number_2                    IN     VARCHAR2,
    x_phone_number_3                    IN     VARCHAR2,
    x_email_address                     IN     VARCHAR2,
    x_citzn_status_code                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 02-NOV-2004
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

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
      fnd_message.set_token ('ROUTINE', 'IGF_GR_COD_HISTORY_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT igf_gr_cod_history_s.NEXTVAL INTO x_rfms_orig_hist_id FROM dual;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_rfms_orig_hist_id                 => x_rfms_orig_hist_id,
      x_origination_id                    => x_origination_id,
      x_award_id                          => x_award_id,
      x_document_id_txt                   => x_document_id_txt,
      x_base_id                           => x_base_id,
      x_fin_award_year                    => x_fin_award_year,
      x_cps_trans_num                     => x_cps_trans_num,
      x_award_amt                         => x_award_amt,
      x_coa_amt                           => x_coa_amt,
      x_low_tution_fee                    => x_low_tution_fee,
      x_incarc_flag                       => x_incarc_flag,
      x_ver_status_code                   => x_ver_status_code,
      x_enrollment_date                   => x_enrollment_date,
      x_sec_efc_code                      => x_sec_efc_code,
      x_ytd_disb_amt                      => x_ytd_disb_amt,
      x_tot_elig_used                     => x_tot_elig_used,
      x_schd_pell_amt                     => x_schd_pell_amt,
      x_neg_pend_amt                      => x_neg_pend_amt,
      x_cps_verif_flag                    => x_cps_verif_flag,
      x_high_cps_trans_num                => x_high_cps_trans_num,
      x_note_message                      => x_note_message,
      x_full_resp_code                    => x_full_resp_code,
      x_atd_entity_id_txt                 => x_atd_entity_id_txt,
      x_rep_entity_id_txt                 => x_rep_entity_id_txt,
      x_source_entity_id_txt              => x_source_entity_id_txt,
      x_pell_status                       => x_pell_status,
      x_pell_status_date                  => x_pell_status_date,
      x_s_chg_ssn                         => x_s_chg_ssn,
      x_driver_lic_state                  => x_driver_lic_state,
      x_driver_lic_number                 => x_driver_lic_number,
      x_s_chg_date_of_birth               => x_s_chg_date_of_birth,
      x_first_name                        => x_first_name,
      x_middle_name                       => x_middle_name,
      x_s_chg_last_name                   => x_s_chg_last_name,
      x_s_date_of_birth                   => x_s_date_of_birth,
      x_s_ssn                             => x_s_ssn,
      x_s_last_name                       => x_s_last_name,
      x_permt_addr_foreign_flag           => x_permt_addr_foreign_flag,
      x_addr_type_code                    => x_addr_type_code,
      x_permt_addr_line_1                 => x_permt_addr_line_1,
      x_permt_addr_line_2                 => x_permt_addr_line_2,
      x_permt_addr_line_3                 => x_permt_addr_line_3,
      x_permt_addr_city                   => x_permt_addr_city,
      x_permt_addr_state_code             => x_permt_addr_state_code,
      x_permt_addr_post_code              => x_permt_addr_post_code,
      x_permt_addr_county                 => x_permt_addr_county,
      x_permt_addr_country                => x_permt_addr_country,
      x_phone_number_1                    => x_phone_number_1,
      x_phone_number_2                    => x_phone_number_2,
      x_phone_number_3                    => x_phone_number_3,
      x_email_address                     => x_email_address,
      x_citzn_status_code                 => x_citzn_status_code,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_gr_cod_history (
      rfms_orig_hist_id,
      origination_id,
      award_id,
      document_id_txt,
      base_id,
      fin_award_year,
      cps_trans_num,
      award_amt,
      coa_amt,
      low_tution_fee,
      incarc_flag,
      ver_status_code,
      enrollment_date,
      sec_efc_code,
      ytd_disb_amt,
      tot_elig_used,
      schd_pell_amt,
      neg_pend_amt,
      cps_verif_flag,
      high_cps_trans_num,
      note_message,
      full_resp_code,
      atd_entity_id_txt,
      rep_entity_id_txt,
      source_entity_id_txt,
      pell_status,
      pell_status_date,
      s_chg_ssn,
      driver_lic_state,
      driver_lic_number,
      s_chg_date_of_birth,
      first_name,
      middle_name,
      s_chg_last_name,
      s_date_of_birth,
      s_ssn,
      s_last_name,
      permt_addr_foreign_flag,
      addr_type_code,
      permt_addr_line_1,
      permt_addr_line_2,
      permt_addr_line_3,
      permt_addr_city,
      permt_addr_state_code,
      permt_addr_post_code,
      permt_addr_county,
      permt_addr_country,
      phone_number_1,
      phone_number_2,
      phone_number_3,
      email_address,
      citzn_status_code,
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
      new_references.rfms_orig_hist_id,
      new_references.origination_id,
      new_references.award_id,
      new_references.document_id_txt,
      new_references.base_id,
      new_references.fin_award_year,
      new_references.cps_trans_num,
      new_references.award_amt,
      new_references.coa_amt,
      new_references.low_tution_fee,
      new_references.incarc_flag,
      new_references.ver_status_code,
      new_references.enrollment_date,
      new_references.sec_efc_code,
      new_references.ytd_disb_amt,
      new_references.tot_elig_used,
      new_references.schd_pell_amt,
      new_references.neg_pend_amt,
      new_references.cps_verif_flag,
      new_references.high_cps_trans_num,
      new_references.note_message,
      new_references.full_resp_code,
      new_references.atd_entity_id_txt,
      new_references.rep_entity_id_txt,
      new_references.source_entity_id_txt,
      new_references.pell_status,
      new_references.pell_status_date,
      new_references.s_chg_ssn,
      new_references.driver_lic_state,
      new_references.driver_lic_number,
      new_references.s_chg_date_of_birth,
      new_references.first_name,
      new_references.middle_name,
      new_references.s_chg_last_name,
      new_references.s_date_of_birth,
      new_references.s_ssn,
      new_references.s_last_name,
      new_references.permt_addr_foreign_flag,
      new_references.addr_type_code,
      new_references.permt_addr_line_1,
      new_references.permt_addr_line_2,
      new_references.permt_addr_line_3,
      new_references.permt_addr_city,
      new_references.permt_addr_state_code,
      new_references.permt_addr_post_code,
      new_references.permt_addr_county,
      new_references.permt_addr_country,
      new_references.phone_number_1,
      new_references.phone_number_2,
      new_references.phone_number_3,
      new_references.email_address,
      new_references.citzn_status_code,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_rfms_orig_hist_id                 IN     NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_document_id_txt                   IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_fin_award_year                    IN     VARCHAR2,
    x_cps_trans_num                     IN     VARCHAR2,
    x_award_amt                         IN     NUMBER,
    x_coa_amt                           IN     NUMBER,
    x_low_tution_fee                    IN     VARCHAR2,
    x_incarc_flag                       IN     VARCHAR2,
    x_ver_status_code                   IN     VARCHAR2,
    x_enrollment_date                   IN     DATE,
    x_sec_efc_code                      IN     VARCHAR2,
    x_ytd_disb_amt                      IN     NUMBER,
    x_tot_elig_used                     IN     NUMBER,
    x_schd_pell_amt                     IN     NUMBER,
    x_neg_pend_amt                      IN     NUMBER,
    x_cps_verif_flag                    IN     VARCHAR2,
    x_high_cps_trans_num                IN     VARCHAR2,
    x_note_message                      IN     VARCHAR2,
    x_full_resp_code                    IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_source_entity_id_txt              IN     VARCHAR2,
    x_pell_status                       IN     VARCHAR2,
    x_pell_status_date                  IN     DATE,
    x_s_chg_ssn                         IN     VARCHAR2,
    x_driver_lic_state                  IN     VARCHAR2,
    x_driver_lic_number                 IN     VARCHAR2,
    x_s_chg_date_of_birth               IN     DATE,
    x_first_name                        IN     VARCHAR2,
    x_middle_name                       IN     VARCHAR2,
    x_s_chg_last_name                   IN     VARCHAR2,
    x_s_date_of_birth                   IN     DATE,
    x_s_ssn                             IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_permt_addr_foreign_flag           IN     VARCHAR2,
    x_addr_type_code                    IN     VARCHAR2,
    x_permt_addr_line_1                 IN     VARCHAR2,
    x_permt_addr_line_2                 IN     VARCHAR2,
    x_permt_addr_line_3                 IN     VARCHAR2,
    x_permt_addr_city                   IN     VARCHAR2,
    x_permt_addr_state_code             IN     VARCHAR2,
    x_permt_addr_post_code              IN     VARCHAR2,
    x_permt_addr_county                 IN     VARCHAR2,
    x_permt_addr_country                IN     VARCHAR2,
    x_phone_number_1                    IN     VARCHAR2,
    x_phone_number_2                    IN     VARCHAR2,
    x_phone_number_3                    IN     VARCHAR2,
    x_email_address                     IN     VARCHAR2,
    x_citzn_status_code                 IN     VARCHAR2
  ) AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 02-NOV-2004
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        rfms_orig_hist_id,
        origination_id,
        award_id,
        document_id_txt,
        base_id,
        fin_award_year,
        cps_trans_num,
        award_amt,
        coa_amt,
        low_tution_fee,
        incarc_flag,
        ver_status_code,
        enrollment_date,
        sec_efc_code,
        ytd_disb_amt,
        tot_elig_used,
        schd_pell_amt,
        neg_pend_amt,
        cps_verif_flag,
        high_cps_trans_num,
        note_message,
        full_resp_code,
        atd_entity_id_txt,
        rep_entity_id_txt,
        source_entity_id_txt,
        pell_status,
        pell_status_date,
        s_chg_ssn,
        driver_lic_state,
        driver_lic_number,
        s_chg_date_of_birth,
        first_name,
        middle_name,
        s_chg_last_name,
        s_date_of_birth,
        s_ssn,
        s_last_name,
        permt_addr_foreign_flag,
        addr_type_code,
        permt_addr_line_1,
        permt_addr_line_2,
        permt_addr_line_3,
        permt_addr_city,
        permt_addr_state_code,
        permt_addr_post_code,
        permt_addr_county,
        permt_addr_country,
        phone_number_1,
        phone_number_2,
        phone_number_3,
        email_address,
        citzn_status_code
      FROM  igf_gr_cod_history
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
        (tlinfo.rfms_orig_hist_id = x_rfms_orig_hist_id)
        AND (tlinfo.origination_id = x_origination_id)
        AND (tlinfo.award_id = x_award_id)
        AND (tlinfo.document_id_txt = x_document_id_txt)
        AND (tlinfo.base_id = x_base_id)
        AND ((tlinfo.fin_award_year = x_fin_award_year) OR ((tlinfo.fin_award_year IS NULL) AND (X_fin_award_year IS NULL)))
        AND ((tlinfo.cps_trans_num = x_cps_trans_num) OR ((tlinfo.cps_trans_num IS NULL) AND (X_cps_trans_num IS NULL)))
        AND (tlinfo.award_amt = x_award_amt)
        AND ((tlinfo.coa_amt = x_coa_amt) OR ((tlinfo.coa_amt IS NULL) AND (X_coa_amt IS NULL)))
        AND ((tlinfo.low_tution_fee = x_low_tution_fee) OR ((tlinfo.low_tution_fee IS NULL) AND (X_low_tution_fee IS NULL)))
        AND ((tlinfo.incarc_flag = x_incarc_flag) OR ((tlinfo.incarc_flag IS NULL) AND (X_incarc_flag IS NULL)))
        AND ((tlinfo.ver_status_code = x_ver_status_code) OR ((tlinfo.ver_status_code IS NULL) AND (X_ver_status_code IS NULL)))
        AND ((tlinfo.enrollment_date = x_enrollment_date) OR ((tlinfo.enrollment_date IS NULL) AND (X_enrollment_date IS NULL)))
        AND ((tlinfo.sec_efc_code = x_sec_efc_code) OR ((tlinfo.sec_efc_code IS NULL) AND (X_sec_efc_code IS NULL)))
        AND ((tlinfo.ytd_disb_amt = x_ytd_disb_amt) OR ((tlinfo.ytd_disb_amt IS NULL) AND (X_ytd_disb_amt IS NULL)))
        AND ((tlinfo.tot_elig_used = x_tot_elig_used) OR ((tlinfo.tot_elig_used IS NULL) AND (X_tot_elig_used IS NULL)))
        AND ((tlinfo.schd_pell_amt = x_schd_pell_amt) OR ((tlinfo.schd_pell_amt IS NULL) AND (X_schd_pell_amt IS NULL)))
        AND ((tlinfo.neg_pend_amt = x_neg_pend_amt) OR ((tlinfo.neg_pend_amt IS NULL) AND (X_neg_pend_amt IS NULL)))
        AND ((tlinfo.cps_verif_flag = x_cps_verif_flag) OR ((tlinfo.cps_verif_flag IS NULL) AND (X_cps_verif_flag IS NULL)))
        AND ((tlinfo.high_cps_trans_num = x_high_cps_trans_num) OR ((tlinfo.high_cps_trans_num IS NULL) AND (X_high_cps_trans_num IS NULL)))
        AND ((tlinfo.note_message = x_note_message) OR ((tlinfo.note_message IS NULL) AND (X_note_message IS NULL)))
        AND ((tlinfo.full_resp_code = x_full_resp_code) OR ((tlinfo.full_resp_code IS NULL) AND (X_full_resp_code IS NULL)))
        AND ((tlinfo.atd_entity_id_txt = x_atd_entity_id_txt) OR ((tlinfo.atd_entity_id_txt IS NULL) AND (X_atd_entity_id_txt IS NULL)))
        AND ((tlinfo.rep_entity_id_txt = x_rep_entity_id_txt) OR ((tlinfo.rep_entity_id_txt IS NULL) AND (X_rep_entity_id_txt IS NULL)))
        AND ((tlinfo.source_entity_id_txt = x_source_entity_id_txt) OR ((tlinfo.source_entity_id_txt IS NULL) AND (X_source_entity_id_txt IS NULL)))
        AND ((tlinfo.pell_status = x_pell_status) OR ((tlinfo.pell_status IS NULL) AND (X_pell_status IS NULL)))
        AND ((tlinfo.pell_status_date = x_pell_status_date) OR ((tlinfo.pell_status_date IS NULL) AND (X_pell_status_date IS NULL)))
        AND ((tlinfo.s_chg_ssn = x_s_chg_ssn) OR ((tlinfo.s_chg_ssn IS NULL) AND (X_s_chg_ssn IS NULL)))
        AND ((tlinfo.driver_lic_state = x_driver_lic_state) OR ((tlinfo.driver_lic_state IS NULL) AND (X_driver_lic_state IS NULL)))
        AND ((tlinfo.driver_lic_number = x_driver_lic_number) OR ((tlinfo.driver_lic_number IS NULL) AND (X_driver_lic_number IS NULL)))
        AND ((tlinfo.s_chg_date_of_birth = x_s_chg_date_of_birth) OR ((tlinfo.s_chg_date_of_birth IS NULL) AND (X_s_chg_date_of_birth IS NULL)))
        AND ((tlinfo.first_name = x_first_name) OR ((tlinfo.first_name IS NULL) AND (X_first_name IS NULL)))
        AND ((tlinfo.middle_name = x_middle_name) OR ((tlinfo.middle_name IS NULL) AND (X_middle_name IS NULL)))
        AND ((tlinfo.s_chg_last_name = x_s_chg_last_name) OR ((tlinfo.s_chg_last_name IS NULL) AND (X_s_chg_last_name IS NULL)))
        AND ((tlinfo.s_date_of_birth = x_s_date_of_birth) OR ((tlinfo.s_date_of_birth IS NULL) AND (X_s_date_of_birth IS NULL)))
        AND ((tlinfo.s_ssn = x_s_ssn) OR ((tlinfo.s_ssn IS NULL) AND (X_s_ssn IS NULL)))
        AND ((tlinfo.s_last_name = x_s_last_name) OR ((tlinfo.s_last_name IS NULL) AND (X_s_last_name IS NULL)))
        AND ((tlinfo.permt_addr_foreign_flag = x_permt_addr_foreign_flag) OR ((tlinfo.permt_addr_foreign_flag IS NULL) AND (X_permt_addr_foreign_flag IS NULL)))
        AND ((tlinfo.addr_type_code = x_addr_type_code) OR ((tlinfo.addr_type_code IS NULL) AND (X_addr_type_code IS NULL)))
        AND ((tlinfo.permt_addr_line_1 = x_permt_addr_line_1) OR ((tlinfo.permt_addr_line_1 IS NULL) AND (X_permt_addr_line_1 IS NULL)))
        AND ((tlinfo.permt_addr_line_2 = x_permt_addr_line_2) OR ((tlinfo.permt_addr_line_2 IS NULL) AND (X_permt_addr_line_2 IS NULL)))
        AND ((tlinfo.permt_addr_line_3 = x_permt_addr_line_3) OR ((tlinfo.permt_addr_line_3 IS NULL) AND (X_permt_addr_line_3 IS NULL)))
        AND ((tlinfo.permt_addr_city = x_permt_addr_city) OR ((tlinfo.permt_addr_city IS NULL) AND (X_permt_addr_city IS NULL)))
        AND ((tlinfo.permt_addr_state_code = x_permt_addr_state_code) OR ((tlinfo.permt_addr_state_code IS NULL) AND (X_permt_addr_state_code IS NULL)))
        AND ((tlinfo.permt_addr_post_code = x_permt_addr_post_code) OR ((tlinfo.permt_addr_post_code IS NULL) AND (X_permt_addr_post_code IS NULL)))
        AND ((tlinfo.permt_addr_county = x_permt_addr_county) OR ((tlinfo.permt_addr_county IS NULL) AND (X_permt_addr_county IS NULL)))
        AND ((tlinfo.permt_addr_country = x_permt_addr_country) OR ((tlinfo.permt_addr_country IS NULL) AND (X_permt_addr_country IS NULL)))
        AND ((tlinfo.phone_number_1 = x_phone_number_1) OR ((tlinfo.phone_number_1 IS NULL) AND (X_phone_number_1 IS NULL)))
        AND ((tlinfo.phone_number_2 = x_phone_number_2) OR ((tlinfo.phone_number_2 IS NULL) AND (X_phone_number_2 IS NULL)))
        AND ((tlinfo.phone_number_3 = x_phone_number_3) OR ((tlinfo.phone_number_3 IS NULL) AND (X_phone_number_3 IS NULL)))
        AND ((tlinfo.email_address = x_email_address) OR ((tlinfo.email_address IS NULL) AND (X_email_address IS NULL)))
        AND ((tlinfo.citzn_status_code = x_citzn_status_code) OR ((tlinfo.citzn_status_code IS NULL) AND (X_citzn_status_code IS NULL)))
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
    x_rfms_orig_hist_id                 IN     NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_document_id_txt                   IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_fin_award_year                    IN     VARCHAR2,
    x_cps_trans_num                     IN     VARCHAR2,
    x_award_amt                         IN     NUMBER,
    x_coa_amt                           IN     NUMBER,
    x_low_tution_fee                    IN     VARCHAR2,
    x_incarc_flag                       IN     VARCHAR2,
    x_ver_status_code                   IN     VARCHAR2,
    x_enrollment_date                   IN     DATE,
    x_sec_efc_code                      IN     VARCHAR2,
    x_ytd_disb_amt                      IN     NUMBER,
    x_tot_elig_used                     IN     NUMBER,
    x_schd_pell_amt                     IN     NUMBER,
    x_neg_pend_amt                      IN     NUMBER,
    x_cps_verif_flag                    IN     VARCHAR2,
    x_high_cps_trans_num                IN     VARCHAR2,
    x_note_message                      IN     VARCHAR2,
    x_full_resp_code                    IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_source_entity_id_txt              IN     VARCHAR2,
    x_pell_status                       IN     VARCHAR2,
    x_pell_status_date                  IN     DATE,
    x_s_chg_ssn                         IN     VARCHAR2,
    x_driver_lic_state                  IN     VARCHAR2,
    x_driver_lic_number                 IN     VARCHAR2,
    x_s_chg_date_of_birth               IN     DATE,
    x_first_name                        IN     VARCHAR2,
    x_middle_name                       IN     VARCHAR2,
    x_s_chg_last_name                   IN     VARCHAR2,
    x_s_date_of_birth                   IN     DATE,
    x_s_ssn                             IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_permt_addr_foreign_flag           IN     VARCHAR2,
    x_addr_type_code                    IN     VARCHAR2,
    x_permt_addr_line_1                 IN     VARCHAR2,
    x_permt_addr_line_2                 IN     VARCHAR2,
    x_permt_addr_line_3                 IN     VARCHAR2,
    x_permt_addr_city                   IN     VARCHAR2,
    x_permt_addr_state_code             IN     VARCHAR2,
    x_permt_addr_post_code              IN     VARCHAR2,
    x_permt_addr_county                 IN     VARCHAR2,
    x_permt_addr_country                IN     VARCHAR2,
    x_phone_number_1                    IN     VARCHAR2,
    x_phone_number_2                    IN     VARCHAR2,
    x_phone_number_3                    IN     VARCHAR2,
    x_email_address                     IN     VARCHAR2,
    x_citzn_status_code                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 02-NOV-2004
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
      fnd_message.set_token ('ROUTINE', 'IGF_GR_COD_HISTORY_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_rfms_orig_hist_id                 => x_rfms_orig_hist_id,
      x_origination_id                    => x_origination_id,
      x_award_id                          => x_award_id,
      x_document_id_txt                   => x_document_id_txt,
      x_base_id                           => x_base_id,
      x_fin_award_year                    => x_fin_award_year,
      x_cps_trans_num                     => x_cps_trans_num,
      x_award_amt                         => x_award_amt,
      x_coa_amt                           => x_coa_amt,
      x_low_tution_fee                    => x_low_tution_fee,
      x_incarc_flag                       => x_incarc_flag,
      x_ver_status_code                   => x_ver_status_code,
      x_enrollment_date                   => x_enrollment_date,
      x_sec_efc_code                      => x_sec_efc_code,
      x_ytd_disb_amt                      => x_ytd_disb_amt,
      x_tot_elig_used                     => x_tot_elig_used,
      x_schd_pell_amt                     => x_schd_pell_amt,
      x_neg_pend_amt                      => x_neg_pend_amt,
      x_cps_verif_flag                    => x_cps_verif_flag,
      x_high_cps_trans_num                => x_high_cps_trans_num,
      x_note_message                      => x_note_message,
      x_full_resp_code                    => x_full_resp_code,
      x_atd_entity_id_txt                 => x_atd_entity_id_txt,
      x_rep_entity_id_txt                 => x_rep_entity_id_txt,
      x_source_entity_id_txt              => x_source_entity_id_txt,
      x_pell_status                       => x_pell_status,
      x_pell_status_date                  => x_pell_status_date,
      x_s_chg_ssn                         => x_s_chg_ssn,
      x_driver_lic_state                  => x_driver_lic_state,
      x_driver_lic_number                 => x_driver_lic_number,
      x_s_chg_date_of_birth               => x_s_chg_date_of_birth,
      x_first_name                        => x_first_name,
      x_middle_name                       => x_middle_name,
      x_s_chg_last_name                   => x_s_chg_last_name,
      x_s_date_of_birth                   => x_s_date_of_birth,
      x_s_ssn                             => x_s_ssn,
      x_s_last_name                       => x_s_last_name,
      x_permt_addr_foreign_flag           => x_permt_addr_foreign_flag,
      x_addr_type_code                    => x_addr_type_code,
      x_permt_addr_line_1                 => x_permt_addr_line_1,
      x_permt_addr_line_2                 => x_permt_addr_line_2,
      x_permt_addr_line_3                 => x_permt_addr_line_3,
      x_permt_addr_city                   => x_permt_addr_city,
      x_permt_addr_state_code             => x_permt_addr_state_code,
      x_permt_addr_post_code              => x_permt_addr_post_code,
      x_permt_addr_county                 => x_permt_addr_county,
      x_permt_addr_country                => x_permt_addr_country,
      x_phone_number_1                    => x_phone_number_1,
      x_phone_number_2                    => x_phone_number_2,
      x_phone_number_3                    => x_phone_number_3,
      x_email_address                     => x_email_address,
      x_citzn_status_code                 => x_citzn_status_code,
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

    UPDATE igf_gr_cod_history
      SET
        rfms_orig_hist_id                 = new_references.rfms_orig_hist_id,
        origination_id                    = new_references.origination_id,
        award_id                          = new_references.award_id,
        document_id_txt                   = new_references.document_id_txt,
        base_id                           = new_references.base_id,
        fin_award_year                    = new_references.fin_award_year,
        cps_trans_num                     = new_references.cps_trans_num,
        award_amt                         = new_references.award_amt,
        coa_amt                           = new_references.coa_amt,
        low_tution_fee                    = new_references.low_tution_fee,
        incarc_flag                       = new_references.incarc_flag,
        ver_status_code                   = new_references.ver_status_code,
        enrollment_date                   = new_references.enrollment_date,
        sec_efc_code                      = new_references.sec_efc_code,
        ytd_disb_amt                      = new_references.ytd_disb_amt,
        tot_elig_used                     = new_references.tot_elig_used,
        schd_pell_amt                     = new_references.schd_pell_amt,
        neg_pend_amt                      = new_references.neg_pend_amt,
        cps_verif_flag                    = new_references.cps_verif_flag,
        high_cps_trans_num                = new_references.high_cps_trans_num,
        note_message                      = new_references.note_message,
        full_resp_code                    = new_references.full_resp_code,
        atd_entity_id_txt                 = new_references.atd_entity_id_txt,
        rep_entity_id_txt                 = new_references.rep_entity_id_txt,
        source_entity_id_txt              = new_references.source_entity_id_txt,
        pell_status                       = new_references.pell_status,
        pell_status_date                  = new_references.pell_status_date,
        s_chg_ssn                         = new_references.s_chg_ssn,
        driver_lic_state                  = new_references.driver_lic_state,
        driver_lic_number                 = new_references.driver_lic_number,
        s_chg_date_of_birth               = new_references.s_chg_date_of_birth,
        first_name                        = new_references.first_name,
        middle_name                       = new_references.middle_name,
        s_chg_last_name                   = new_references.s_chg_last_name,
        s_date_of_birth                   = new_references.s_date_of_birth,
        s_ssn                             = new_references.s_ssn,
        s_last_name                       = new_references.s_last_name,
        permt_addr_foreign_flag           = new_references.permt_addr_foreign_flag,
        addr_type_code                    = new_references.addr_type_code,
        permt_addr_line_1                 = new_references.permt_addr_line_1,
        permt_addr_line_2                 = new_references.permt_addr_line_2,
        permt_addr_line_3                 = new_references.permt_addr_line_3,
        permt_addr_city                   = new_references.permt_addr_city,
        permt_addr_state_code             = new_references.permt_addr_state_code,
        permt_addr_post_code              = new_references.permt_addr_post_code,
        permt_addr_county                 = new_references.permt_addr_county,
        permt_addr_country                = new_references.permt_addr_country,
        phone_number_1                    = new_references.phone_number_1,
        phone_number_2                    = new_references.phone_number_2,
        phone_number_3                    = new_references.phone_number_3,
        email_address                     = new_references.email_address,
        citzn_status_code                 = new_references.citzn_status_code,
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

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rfms_orig_hist_id                 IN OUT NOCOPY NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_document_id_txt                   IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_fin_award_year                    IN     VARCHAR2,
    x_cps_trans_num                     IN     VARCHAR2,
    x_award_amt                         IN     NUMBER,
    x_coa_amt                           IN     NUMBER,
    x_low_tution_fee                    IN     VARCHAR2,
    x_incarc_flag                       IN     VARCHAR2,
    x_ver_status_code                   IN     VARCHAR2,
    x_enrollment_date                   IN     DATE,
    x_sec_efc_code                      IN     VARCHAR2,
    x_ytd_disb_amt                      IN     NUMBER,
    x_tot_elig_used                     IN     NUMBER,
    x_schd_pell_amt                     IN     NUMBER,
    x_neg_pend_amt                      IN     NUMBER,
    x_cps_verif_flag                    IN     VARCHAR2,
    x_high_cps_trans_num                IN     VARCHAR2,
    x_note_message                      IN     VARCHAR2,
    x_full_resp_code                    IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_source_entity_id_txt              IN     VARCHAR2,
    x_pell_status                       IN     VARCHAR2,
    x_pell_status_date                  IN     DATE,
    x_s_chg_ssn                         IN     VARCHAR2,
    x_driver_lic_state                  IN     VARCHAR2,
    x_driver_lic_number                 IN     VARCHAR2,
    x_s_chg_date_of_birth               IN     DATE,
    x_first_name                        IN     VARCHAR2,
    x_middle_name                       IN     VARCHAR2,
    x_s_chg_last_name                   IN     VARCHAR2,
    x_s_date_of_birth                   IN     DATE,
    x_s_ssn                             IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_permt_addr_foreign_flag           IN     VARCHAR2,
    x_addr_type_code                    IN     VARCHAR2,
    x_permt_addr_line_1                 IN     VARCHAR2,
    x_permt_addr_line_2                 IN     VARCHAR2,
    x_permt_addr_line_3                 IN     VARCHAR2,
    x_permt_addr_city                   IN     VARCHAR2,
    x_permt_addr_state_code             IN     VARCHAR2,
    x_permt_addr_post_code              IN     VARCHAR2,
    x_permt_addr_county                 IN     VARCHAR2,
    x_permt_addr_country                IN     VARCHAR2,
    x_phone_number_1                    IN     VARCHAR2,
    x_phone_number_2                    IN     VARCHAR2,
    x_phone_number_3                    IN     VARCHAR2,
    x_email_address                     IN     VARCHAR2,
    x_citzn_status_code                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 02-NOV-2004
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_gr_cod_history
      WHERE    rfms_orig_hist_id                    = x_rfms_orig_hist_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_rfms_orig_hist_id,
        x_origination_id,
        x_award_id,
        x_document_id_txt,
        x_base_id,
        x_fin_award_year,
        x_cps_trans_num,
        x_award_amt,
        x_coa_amt,
        x_low_tution_fee,
        x_incarc_flag,
        x_ver_status_code,
        x_enrollment_date,
        x_sec_efc_code,
        x_ytd_disb_amt,
        x_tot_elig_used,
        x_schd_pell_amt,
        x_neg_pend_amt,
        x_cps_verif_flag,
        x_high_cps_trans_num,
        x_note_message,
        x_full_resp_code,
        x_atd_entity_id_txt,
        x_rep_entity_id_txt,
        x_source_entity_id_txt,
        x_pell_status,
        x_pell_status_date,
        x_s_chg_ssn,
        x_driver_lic_state,
        x_driver_lic_number,
        x_s_chg_date_of_birth,
        x_first_name,
        x_middle_name,
        x_s_chg_last_name,
        x_s_date_of_birth,
        x_s_ssn,
        x_s_last_name,
        x_permt_addr_foreign_flag,
        x_addr_type_code,
        x_permt_addr_line_1,
        x_permt_addr_line_2,
        x_permt_addr_line_3,
        x_permt_addr_city,
        x_permt_addr_state_code,
        x_permt_addr_post_code,
        x_permt_addr_county,
        x_permt_addr_country,
        x_phone_number_1,
        x_phone_number_2,
        x_phone_number_3,
        x_email_address,
        x_citzn_status_code,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_rfms_orig_hist_id,
      x_origination_id,
      x_award_id,
      x_document_id_txt,
      x_base_id,
      x_fin_award_year,
      x_cps_trans_num,
      x_award_amt,
      x_coa_amt,
      x_low_tution_fee,
      x_incarc_flag,
      x_ver_status_code,
      x_enrollment_date,
      x_sec_efc_code,
      x_ytd_disb_amt,
      x_tot_elig_used,
      x_schd_pell_amt,
      x_neg_pend_amt,
      x_cps_verif_flag,
      x_high_cps_trans_num,
      x_note_message,
      x_full_resp_code,
      x_atd_entity_id_txt,
      x_rep_entity_id_txt,
      x_source_entity_id_txt,
      x_pell_status,
      x_pell_status_date,
      x_s_chg_ssn,
      x_driver_lic_state,
      x_driver_lic_number,
      x_s_chg_date_of_birth,
      x_first_name,
      x_middle_name,
      x_s_chg_last_name,
      x_s_date_of_birth,
      x_s_ssn,
      x_s_last_name,
      x_permt_addr_foreign_flag,
      x_addr_type_code,
      x_permt_addr_line_1,
      x_permt_addr_line_2,
      x_permt_addr_line_3,
      x_permt_addr_city,
      x_permt_addr_state_code,
      x_permt_addr_post_code,
      x_permt_addr_county,
      x_permt_addr_country,
      x_phone_number_1,
      x_phone_number_2,
      x_phone_number_3,
      x_email_address,
      x_citzn_status_code,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 02-NOV-2004
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

    DELETE FROM igf_gr_cod_history
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_gr_cod_history_pkg;

/
