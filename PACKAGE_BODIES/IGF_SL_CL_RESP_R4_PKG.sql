--------------------------------------------------------
--  DDL for Package Body IGF_SL_CL_RESP_R4_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_CL_RESP_R4_PKG" AS
/* $Header: IGFLI33B.pls 120.0 2005/06/02 15:53:38 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_sl_cl_resp_r4_all%ROWTYPE;
  new_references igf_sl_cl_resp_r4_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_clrp1_id                          IN     NUMBER      DEFAULT NULL,
    x_loan_number                       IN     VARCHAR2    DEFAULT NULL,
    x_fed_stafford_loan_debt            IN     NUMBER      DEFAULT NULL,
    x_fed_sls_debt                      IN     NUMBER      DEFAULT NULL,
    x_heal_debt                         IN     NUMBER      DEFAULT NULL,
    x_perkins_debt                      IN     NUMBER      DEFAULT NULL,
    x_other_debt                        IN     NUMBER      DEFAULT NULL,
    x_crdt_undr_difft_name              IN     VARCHAR2    DEFAULT NULL,
    x_borw_gross_annual_sal             IN     NUMBER      DEFAULT NULL,
    x_borw_other_income                 IN     NUMBER      DEFAULT NULL,
    x_student_major                     IN     VARCHAR2    DEFAULT NULL,
    x_int_rate_opt                      IN     VARCHAR2    DEFAULT NULL,
    x_repayment_opt_code                IN     VARCHAR2    DEFAULT NULL,
    x_stud_mth_housing_pymt             IN     NUMBER      DEFAULT NULL,
    x_stud_mth_crdtcard_pymt            IN     NUMBER      DEFAULT NULL,
    x_stud_mth_auto_pymt                IN     NUMBER      DEFAULT NULL,
    x_stud_mth_ed_loan_pymt             IN     NUMBER      DEFAULT NULL,
    x_stud_mth_other_pymt               IN     NUMBER      DEFAULT NULL,
    x_cosnr_1_last_name                 IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_first_name                IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_middle_name               IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_ssn                       IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_citizenship               IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_addr_line1                IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_addr_line2                IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_city                      IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_state                     IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_zip                       IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_zip_suffix                IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_phone                     IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_sig_code                  IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_gross_anl_sal             IN     NUMBER      DEFAULT NULL,
    x_cosnr_1_other_income              IN     NUMBER      DEFAULT NULL,
    x_cosnr_1_forn_postal_code          IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_forn_phone_prefix         IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_dob                       IN     DATE        DEFAULT NULL,
    x_cosnr_1_license_state             IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_license_num               IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_relationship_to           IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_years_at_addr             IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_mth_housing_pymt          IN     NUMBER      DEFAULT NULL,
    x_cosnr_1_mth_crdtcard_pymt         IN     NUMBER      DEFAULT NULL,
    x_cosnr_1_mth_auto_pymt             IN     NUMBER      DEFAULT NULL,
    x_cosnr_1_mth_ed_loan_pymt          IN     NUMBER      DEFAULT NULL,
    x_cosnr_1_mth_other_pymt            IN     NUMBER      DEFAULT NULL,
    x_cosnr_1_crdt_auth_code            IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_last_name                 IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_first_name                IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_middle_name               IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_ssn                       IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_citizenship               IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_addr_line1                IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_addr_line2                IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_city                      IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_state                     IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_zip                       IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_zip_suffix                IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_phone                     IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_sig_code                  IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_gross_anl_sal             IN     NUMBER      DEFAULT NULL,
    x_cosnr_2_other_income              IN     NUMBER      DEFAULT NULL,
    x_cosnr_2_forn_postal_code          IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_forn_phone_prefix         IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_dob                       IN     DATE        DEFAULT NULL,
    x_cosnr_2_license_state             IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_license_num               IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_relationship_to           IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_years_at_addr             IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_mth_housing_pymt          IN     NUMBER      DEFAULT NULL,
    x_cosnr_2_mth_crdtcard_pymt         IN     NUMBER      DEFAULT NULL,
    x_cosnr_2_mth_auto_pymt             IN     NUMBER      DEFAULT NULL,
    x_cosnr_2_mth_ed_loan_pymt          IN     NUMBER      DEFAULT NULL,
    x_cosnr_2_mth_other_pymt            IN     NUMBER      DEFAULT NULL,
    x_cosnr_2_crdt_auth_code            IN     VARCHAR2    DEFAULT NULL,
    x_other_loan_amt                    IN     NUMBER      DEFAULT NULL,
    x_alt_layout_owner_code_txt         IN     VARCHAR2    DEFAULT NULL,
    x_alt_layout_identi_code_txt        IN     VARCHAR2    DEFAULT NULL,
    x_student_school_phone_txt          IN     VARCHAR2    DEFAULT NULL,
    x_first_csgnr_elec_sign_flag        IN     VARCHAR2    DEFAULT NULL,
    x_second_csgnr_elec_sign_flag       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : viramali
  ||  Created On : 10-MAY-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_SL_CL_RESP_R4_ALL
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
    new_references.clrp1_id                          := x_clrp1_id;
    new_references.loan_number                       := x_loan_number;
    new_references.fed_stafford_loan_debt            := x_fed_stafford_loan_debt;
    new_references.fed_sls_debt                      := x_fed_sls_debt;
    new_references.heal_debt                         := x_heal_debt;
    new_references.perkins_debt                      := x_perkins_debt;
    new_references.other_debt                        := x_other_debt;
    new_references.crdt_undr_difft_name              := x_crdt_undr_difft_name;
    new_references.borw_gross_annual_sal             := x_borw_gross_annual_sal;
    new_references.borw_other_income                 := x_borw_other_income;
    new_references.student_major                     := x_student_major;
    new_references.int_rate_opt                      := x_int_rate_opt;
    new_references.repayment_opt_code                := x_repayment_opt_code;
    new_references.stud_mth_housing_pymt             := x_stud_mth_housing_pymt;
    new_references.stud_mth_crdtcard_pymt            := x_stud_mth_crdtcard_pymt;
    new_references.stud_mth_auto_pymt                := x_stud_mth_auto_pymt;
    new_references.stud_mth_ed_loan_pymt             := x_stud_mth_ed_loan_pymt;
    new_references.stud_mth_other_pymt               := x_stud_mth_other_pymt;
    new_references.cosnr_1_last_name                 := x_cosnr_1_last_name;
    new_references.cosnr_1_first_name                := x_cosnr_1_first_name;
    new_references.cosnr_1_middle_name               := x_cosnr_1_middle_name;
    new_references.cosnr_1_ssn                       := x_cosnr_1_ssn;
    new_references.cosnr_1_citizenship               := x_cosnr_1_citizenship;
    new_references.cosnr_1_addr_line1                := x_cosnr_1_addr_line1;
    new_references.cosnr_1_addr_line2                := x_cosnr_1_addr_line2;
    new_references.cosnr_1_city                      := x_cosnr_1_city;
    new_references.cosnr_1_state                     := x_cosnr_1_state;
    new_references.cosnr_1_zip                       := x_cosnr_1_zip;
    new_references.cosnr_1_zip_suffix                := x_cosnr_1_zip_suffix;
    new_references.cosnr_1_phone                     := x_cosnr_1_phone;
    new_references.cosnr_1_sig_code                  := x_cosnr_1_sig_code;
    new_references.cosnr_1_gross_anl_sal             := x_cosnr_1_gross_anl_sal;
    new_references.cosnr_1_other_income              := x_cosnr_1_other_income;
    new_references.cosnr_1_forn_postal_code          := x_cosnr_1_forn_postal_code;
    new_references.cosnr_1_forn_phone_prefix         := x_cosnr_1_forn_phone_prefix;
    new_references.cosnr_1_dob                       := x_cosnr_1_dob;
    new_references.cosnr_1_license_state             := x_cosnr_1_license_state;
    new_references.cosnr_1_license_num               := x_cosnr_1_license_num;
    new_references.cosnr_1_relationship_to           := x_cosnr_1_relationship_to;
    new_references.cosnr_1_years_at_addr             := x_cosnr_1_years_at_addr;
    new_references.cosnr_1_mth_housing_pymt          := x_cosnr_1_mth_housing_pymt;
    new_references.cosnr_1_mth_crdtcard_pymt         := x_cosnr_1_mth_crdtcard_pymt;
    new_references.cosnr_1_mth_auto_pymt             := x_cosnr_1_mth_auto_pymt;
    new_references.cosnr_1_mth_ed_loan_pymt          := x_cosnr_1_mth_ed_loan_pymt;
    new_references.cosnr_1_mth_other_pymt            := x_cosnr_1_mth_other_pymt;
    new_references.cosnr_1_crdt_auth_code            := x_cosnr_1_crdt_auth_code;
    new_references.cosnr_2_last_name                 := x_cosnr_2_last_name;
    new_references.cosnr_2_first_name                := x_cosnr_2_first_name;
    new_references.cosnr_2_middle_name               := x_cosnr_2_middle_name;
    new_references.cosnr_2_ssn                       := x_cosnr_2_ssn;
    new_references.cosnr_2_citizenship               := x_cosnr_2_citizenship;
    new_references.cosnr_2_addr_line1                := x_cosnr_2_addr_line1;
    new_references.cosnr_2_addr_line2                := x_cosnr_2_addr_line2;
    new_references.cosnr_2_city                      := x_cosnr_2_city;
    new_references.cosnr_2_state                     := x_cosnr_2_state;
    new_references.cosnr_2_zip                       := x_cosnr_2_zip;
    new_references.cosnr_2_zip_suffix                := x_cosnr_2_zip_suffix;
    new_references.cosnr_2_phone                     := x_cosnr_2_phone;
    new_references.cosnr_2_sig_code                  := x_cosnr_2_sig_code;
    new_references.cosnr_2_gross_anl_sal             := x_cosnr_2_gross_anl_sal;
    new_references.cosnr_2_other_income              := x_cosnr_2_other_income;
    new_references.cosnr_2_forn_postal_code          := x_cosnr_2_forn_postal_code;
    new_references.cosnr_2_forn_phone_prefix         := x_cosnr_2_forn_phone_prefix;
    new_references.cosnr_2_dob                       := x_cosnr_2_dob;
    new_references.cosnr_2_license_state             := x_cosnr_2_license_state;
    new_references.cosnr_2_license_num               := x_cosnr_2_license_num;
    new_references.cosnr_2_relationship_to           := x_cosnr_2_relationship_to;
    new_references.cosnr_2_years_at_addr             := x_cosnr_2_years_at_addr;
    new_references.cosnr_2_mth_housing_pymt          := x_cosnr_2_mth_housing_pymt;
    new_references.cosnr_2_mth_crdtcard_pymt         := x_cosnr_2_mth_crdtcard_pymt;
    new_references.cosnr_2_mth_auto_pymt             := x_cosnr_2_mth_auto_pymt;
    new_references.cosnr_2_mth_ed_loan_pymt          := x_cosnr_2_mth_ed_loan_pymt;
    new_references.cosnr_2_mth_other_pymt            := x_cosnr_2_mth_other_pymt;
    new_references.cosnr_2_crdt_auth_code            := x_cosnr_2_crdt_auth_code;
    new_references.other_loan_amt                    := x_other_loan_amt ;
    new_references.alt_layout_owner_code_txt         := x_alt_layout_owner_code_txt;
    new_references.alt_layout_identi_code_txt        := x_alt_layout_identi_code_txt;
    new_references.student_school_phone_txt          := x_student_school_phone_txt;
    new_references.first_csgnr_elec_sign_flag        := x_first_csgnr_elec_sign_flag;
    new_references.second_csgnr_elec_sign_flag       := x_second_csgnr_elec_sign_flag;



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
  ||  Created By : viramali
  ||  Created On : 10-MAY-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.clrp1_id = new_references.clrp1_id)) OR
        ((new_references.clrp1_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_sl_cl_resp_r1_pkg.get_pk_for_validation (
                new_references.clrp1_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;

  PROCEDURE check_child_existance IS

  BEGIN
    igf_sl_cl_resp_r7_dtls_pkg.get_fk_igf_sl_cl_resp_r4 (
       old_references.clrp1_id
       );
  END check_child_existance;

  FUNCTION get_pk_for_validation (
    x_clrp1_id                          IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : viramali
  ||  Created On : 10-MAY-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_cl_resp_r4_all
      WHERE    clrp1_id = x_clrp1_id
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


  PROCEDURE get_fk_igf_sl_cl_resp_r1 (
    x_clrp1_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : viramali
  ||  Created On : 10-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_cl_resp_r4_all
      WHERE   ((clrp1_id = x_clrp1_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_SL_CLRP4_CLRP1_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_sl_cl_resp_r1;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_clrp1_id                          IN     NUMBER      DEFAULT NULL,
    x_loan_number                       IN     VARCHAR2    DEFAULT NULL,
    x_fed_stafford_loan_debt            IN     NUMBER      DEFAULT NULL,
    x_fed_sls_debt                      IN     NUMBER      DEFAULT NULL,
    x_heal_debt                         IN     NUMBER      DEFAULT NULL,
    x_perkins_debt                      IN     NUMBER      DEFAULT NULL,
    x_other_debt                        IN     NUMBER      DEFAULT NULL,
    x_crdt_undr_difft_name              IN     VARCHAR2    DEFAULT NULL,
    x_borw_gross_annual_sal             IN     NUMBER      DEFAULT NULL,
    x_borw_other_income                 IN     NUMBER      DEFAULT NULL,
    x_student_major                     IN     VARCHAR2    DEFAULT NULL,
    x_int_rate_opt                      IN     VARCHAR2    DEFAULT NULL,
    x_repayment_opt_code                IN     VARCHAR2    DEFAULT NULL,
    x_stud_mth_housing_pymt             IN     NUMBER      DEFAULT NULL,
    x_stud_mth_crdtcard_pymt            IN     NUMBER      DEFAULT NULL,
    x_stud_mth_auto_pymt                IN     NUMBER      DEFAULT NULL,
    x_stud_mth_ed_loan_pymt             IN     NUMBER      DEFAULT NULL,
    x_stud_mth_other_pymt               IN     NUMBER      DEFAULT NULL,
    x_cosnr_1_last_name                 IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_first_name                IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_middle_name               IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_ssn                       IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_citizenship               IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_addr_line1                IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_addr_line2                IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_city                      IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_state                     IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_zip                       IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_zip_suffix                IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_phone                     IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_sig_code                  IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_gross_anl_sal             IN     NUMBER      DEFAULT NULL,
    x_cosnr_1_other_income              IN     NUMBER      DEFAULT NULL,
    x_cosnr_1_forn_postal_code          IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_forn_phone_prefix         IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_dob                       IN     DATE        DEFAULT NULL,
    x_cosnr_1_license_state             IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_license_num               IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_relationship_to           IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_years_at_addr             IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_1_mth_housing_pymt          IN     NUMBER      DEFAULT NULL,
    x_cosnr_1_mth_crdtcard_pymt         IN     NUMBER      DEFAULT NULL,
    x_cosnr_1_mth_auto_pymt             IN     NUMBER      DEFAULT NULL,
    x_cosnr_1_mth_ed_loan_pymt          IN     NUMBER      DEFAULT NULL,
    x_cosnr_1_mth_other_pymt            IN     NUMBER      DEFAULT NULL,
    x_cosnr_1_crdt_auth_code            IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_last_name                 IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_first_name                IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_middle_name               IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_ssn                       IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_citizenship               IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_addr_line1                IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_addr_line2                IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_city                      IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_state                     IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_zip                       IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_zip_suffix                IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_phone                     IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_sig_code                  IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_gross_anl_sal             IN     NUMBER      DEFAULT NULL,
    x_cosnr_2_other_income              IN     NUMBER      DEFAULT NULL,
    x_cosnr_2_forn_postal_code          IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_forn_phone_prefix         IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_dob                       IN     DATE        DEFAULT NULL,
    x_cosnr_2_license_state             IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_license_num               IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_relationship_to           IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_years_at_addr             IN     VARCHAR2    DEFAULT NULL,
    x_cosnr_2_mth_housing_pymt          IN     NUMBER      DEFAULT NULL,
    x_cosnr_2_mth_crdtcard_pymt         IN     NUMBER      DEFAULT NULL,
    x_cosnr_2_mth_auto_pymt             IN     NUMBER      DEFAULT NULL,
    x_cosnr_2_mth_ed_loan_pymt          IN     NUMBER      DEFAULT NULL,
    x_cosnr_2_mth_other_pymt            IN     NUMBER      DEFAULT NULL,
    x_cosnr_2_crdt_auth_code            IN     VARCHAR2    DEFAULT NULL,
    x_other_loan_amt                    IN     NUMBER      DEFAULT NULL,
    x_alt_layout_owner_code_txt         IN     VARCHAR2    DEFAULT NULL,
    x_alt_layout_identi_code_txt        IN     VARCHAR2    DEFAULT NULL,
    x_student_school_phone_txt          IN     VARCHAR2    DEFAULT NULL,
    x_first_csgnr_elec_sign_flag        IN     VARCHAR2    DEFAULT NULL,
    x_second_csgnr_elec_sign_flag       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : viramali
  ||  Created On : 10-MAY-2001
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
      x_clrp1_id,
      x_loan_number,
      x_fed_stafford_loan_debt,
      x_fed_sls_debt,
      x_heal_debt,
      x_perkins_debt,
      x_other_debt,
      x_crdt_undr_difft_name,
      x_borw_gross_annual_sal,
      x_borw_other_income,
      x_student_major,
      x_int_rate_opt,
      x_repayment_opt_code,
      x_stud_mth_housing_pymt,
      x_stud_mth_crdtcard_pymt,
      x_stud_mth_auto_pymt,
      x_stud_mth_ed_loan_pymt,
      x_stud_mth_other_pymt,
      x_cosnr_1_last_name,
      x_cosnr_1_first_name,
      x_cosnr_1_middle_name,
      x_cosnr_1_ssn,
      x_cosnr_1_citizenship,
      x_cosnr_1_addr_line1,
      x_cosnr_1_addr_line2,
      x_cosnr_1_city,
      x_cosnr_1_state,
      x_cosnr_1_zip,
      x_cosnr_1_zip_suffix,
      x_cosnr_1_phone,
      x_cosnr_1_sig_code,
      x_cosnr_1_gross_anl_sal,
      x_cosnr_1_other_income,
      x_cosnr_1_forn_postal_code,
      x_cosnr_1_forn_phone_prefix,
      x_cosnr_1_dob,
      x_cosnr_1_license_state,
      x_cosnr_1_license_num,
      x_cosnr_1_relationship_to,
      x_cosnr_1_years_at_addr,
      x_cosnr_1_mth_housing_pymt,
      x_cosnr_1_mth_crdtcard_pymt,
      x_cosnr_1_mth_auto_pymt,
      x_cosnr_1_mth_ed_loan_pymt,
      x_cosnr_1_mth_other_pymt,
      x_cosnr_1_crdt_auth_code,
      x_cosnr_2_last_name,
      x_cosnr_2_first_name,
      x_cosnr_2_middle_name,
      x_cosnr_2_ssn,
      x_cosnr_2_citizenship,
      x_cosnr_2_addr_line1,
      x_cosnr_2_addr_line2,
      x_cosnr_2_city,
      x_cosnr_2_state,
      x_cosnr_2_zip,
      x_cosnr_2_zip_suffix,
      x_cosnr_2_phone,
      x_cosnr_2_sig_code,
      x_cosnr_2_gross_anl_sal,
      x_cosnr_2_other_income,
      x_cosnr_2_forn_postal_code,
      x_cosnr_2_forn_phone_prefix,
      x_cosnr_2_dob,
      x_cosnr_2_license_state,
      x_cosnr_2_license_num,
      x_cosnr_2_relationship_to,
      x_cosnr_2_years_at_addr,
      x_cosnr_2_mth_housing_pymt,
      x_cosnr_2_mth_crdtcard_pymt,
      x_cosnr_2_mth_auto_pymt,
      x_cosnr_2_mth_ed_loan_pymt,
      x_cosnr_2_mth_other_pymt,
      x_cosnr_2_crdt_auth_code,
      x_other_loan_amt,
      x_alt_layout_owner_code_txt,
      x_alt_layout_identi_code_txt,
      x_student_school_phone_txt,
      x_first_csgnr_elec_sign_flag,
      x_second_csgnr_elec_sign_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.clrp1_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;

    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.clrp1_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;

     ELSIF p_action IN ('DELETE','VALIDATE_DELETE') THEN
         check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_clrp1_id                          IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_fed_stafford_loan_debt            IN     NUMBER,
    x_fed_sls_debt                      IN     NUMBER,
    x_heal_debt                         IN     NUMBER,
    x_perkins_debt                      IN     NUMBER,
    x_other_debt                        IN     NUMBER,
    x_crdt_undr_difft_name              IN     VARCHAR2,
    x_borw_gross_annual_sal             IN     NUMBER,
    x_borw_other_income                 IN     NUMBER,
    x_student_major                     IN     VARCHAR2,
    x_int_rate_opt                      IN     VARCHAR2,
    x_repayment_opt_code                IN     VARCHAR2,
    x_stud_mth_housing_pymt             IN     NUMBER,
    x_stud_mth_crdtcard_pymt            IN     NUMBER,
    x_stud_mth_auto_pymt                IN     NUMBER,
    x_stud_mth_ed_loan_pymt             IN     NUMBER,
    x_stud_mth_other_pymt               IN     NUMBER,
    x_cosnr_1_last_name                 IN     VARCHAR2,
    x_cosnr_1_first_name                IN     VARCHAR2,
    x_cosnr_1_middle_name               IN     VARCHAR2,
    x_cosnr_1_ssn                       IN     VARCHAR2,
    x_cosnr_1_citizenship               IN     VARCHAR2,
    x_cosnr_1_addr_line1                IN     VARCHAR2,
    x_cosnr_1_addr_line2                IN     VARCHAR2,
    x_cosnr_1_city                      IN     VARCHAR2,
    x_cosnr_1_state                     IN     VARCHAR2,
    x_cosnr_1_zip                       IN     VARCHAR2,
    x_cosnr_1_zip_suffix                IN     VARCHAR2,
    x_cosnr_1_phone                     IN     VARCHAR2,
    x_cosnr_1_sig_code                  IN     VARCHAR2,
    x_cosnr_1_gross_anl_sal             IN     NUMBER,
    x_cosnr_1_other_income              IN     NUMBER,
    x_cosnr_1_forn_postal_code          IN     VARCHAR2,
    x_cosnr_1_forn_phone_prefix         IN     VARCHAR2,
    x_cosnr_1_dob                       IN     DATE,
    x_cosnr_1_license_state             IN     VARCHAR2,
    x_cosnr_1_license_num               IN     VARCHAR2,
    x_cosnr_1_relationship_to           IN     VARCHAR2,
    x_cosnr_1_years_at_addr             IN     VARCHAR2,
    x_cosnr_1_mth_housing_pymt          IN     NUMBER,
    x_cosnr_1_mth_crdtcard_pymt         IN     NUMBER,
    x_cosnr_1_mth_auto_pymt             IN     NUMBER,
    x_cosnr_1_mth_ed_loan_pymt          IN     NUMBER,
    x_cosnr_1_mth_other_pymt            IN     NUMBER,
    x_cosnr_1_crdt_auth_code            IN     VARCHAR2,
    x_cosnr_2_last_name                 IN     VARCHAR2,
    x_cosnr_2_first_name                IN     VARCHAR2,
    x_cosnr_2_middle_name               IN     VARCHAR2,
    x_cosnr_2_ssn                       IN     VARCHAR2,
    x_cosnr_2_citizenship               IN     VARCHAR2,
    x_cosnr_2_addr_line1                IN     VARCHAR2,
    x_cosnr_2_addr_line2                IN     VARCHAR2,
    x_cosnr_2_city                      IN     VARCHAR2,
    x_cosnr_2_state                     IN     VARCHAR2,
    x_cosnr_2_zip                       IN     VARCHAR2,
    x_cosnr_2_zip_suffix                IN     VARCHAR2,
    x_cosnr_2_phone                     IN     VARCHAR2,
    x_cosnr_2_sig_code                  IN     VARCHAR2,
    x_cosnr_2_gross_anl_sal             IN     NUMBER,
    x_cosnr_2_other_income              IN     NUMBER,
    x_cosnr_2_forn_postal_code          IN     VARCHAR2,
    x_cosnr_2_forn_phone_prefix         IN     VARCHAR2,
    x_cosnr_2_dob                       IN     DATE,
    x_cosnr_2_license_state             IN     VARCHAR2,
    x_cosnr_2_license_num               IN     VARCHAR2,
    x_cosnr_2_relationship_to           IN     VARCHAR2,
    x_cosnr_2_years_at_addr             IN     VARCHAR2,
    x_cosnr_2_mth_housing_pymt          IN     NUMBER,
    x_cosnr_2_mth_crdtcard_pymt         IN     NUMBER,
    x_cosnr_2_mth_auto_pymt             IN     NUMBER,
    x_cosnr_2_mth_ed_loan_pymt          IN     NUMBER,
    x_cosnr_2_mth_other_pymt            IN     NUMBER,
    x_cosnr_2_crdt_auth_code            IN     VARCHAR2,
    x_other_loan_amt                    IN     NUMBER  ,
    x_alt_layout_owner_code_txt         IN     VARCHAR2,
    x_alt_layout_identi_code_txt        IN     VARCHAR2,
    x_student_school_phone_txt          IN     VARCHAR2,
    x_first_csgnr_elec_sign_flag        IN     VARCHAR2,
    x_second_csgnr_elec_sign_flag       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : viramali
  ||  Created On : 10-MAY-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_sl_cl_resp_r4_all
      WHERE    clrp1_id                          = x_clrp1_id;

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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    new_references.org_id := igs_ge_gen_003.get_org_id;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_clrp1_id                          => x_clrp1_id,
      x_loan_number                       => x_loan_number,
      x_fed_stafford_loan_debt            => x_fed_stafford_loan_debt,
      x_fed_sls_debt                      => x_fed_sls_debt,
      x_heal_debt                         => x_heal_debt,
      x_perkins_debt                      => x_perkins_debt,
      x_other_debt                        => x_other_debt,
      x_crdt_undr_difft_name              => x_crdt_undr_difft_name,
      x_borw_gross_annual_sal             => x_borw_gross_annual_sal,
      x_borw_other_income                 => x_borw_other_income,
      x_student_major                     => x_student_major,
      x_int_rate_opt                      => x_int_rate_opt,
      x_repayment_opt_code                => x_repayment_opt_code,
      x_stud_mth_housing_pymt             => x_stud_mth_housing_pymt,
      x_stud_mth_crdtcard_pymt            => x_stud_mth_crdtcard_pymt,
      x_stud_mth_auto_pymt                => x_stud_mth_auto_pymt,
      x_stud_mth_ed_loan_pymt             => x_stud_mth_ed_loan_pymt,
      x_stud_mth_other_pymt               => x_stud_mth_other_pymt,
      x_cosnr_1_last_name                 => x_cosnr_1_last_name,
      x_cosnr_1_first_name                => x_cosnr_1_first_name,
      x_cosnr_1_middle_name               => x_cosnr_1_middle_name,
      x_cosnr_1_ssn                       => x_cosnr_1_ssn,
      x_cosnr_1_citizenship               => x_cosnr_1_citizenship,
      x_cosnr_1_addr_line1                => x_cosnr_1_addr_line1,
      x_cosnr_1_addr_line2                => x_cosnr_1_addr_line2,
      x_cosnr_1_city                      => x_cosnr_1_city,
      x_cosnr_1_state                     => x_cosnr_1_state,
      x_cosnr_1_zip                       => x_cosnr_1_zip,
      x_cosnr_1_zip_suffix                => x_cosnr_1_zip_suffix,
      x_cosnr_1_phone                     => x_cosnr_1_phone,
      x_cosnr_1_sig_code                  => x_cosnr_1_sig_code,
      x_cosnr_1_gross_anl_sal             => x_cosnr_1_gross_anl_sal,
      x_cosnr_1_other_income              => x_cosnr_1_other_income,
      x_cosnr_1_forn_postal_code          => x_cosnr_1_forn_postal_code,
      x_cosnr_1_forn_phone_prefix         => x_cosnr_1_forn_phone_prefix,
      x_cosnr_1_dob                       => x_cosnr_1_dob,
      x_cosnr_1_license_state             => x_cosnr_1_license_state,
      x_cosnr_1_license_num               => x_cosnr_1_license_num,
      x_cosnr_1_relationship_to           => x_cosnr_1_relationship_to,
      x_cosnr_1_years_at_addr             => x_cosnr_1_years_at_addr,
      x_cosnr_1_mth_housing_pymt          => x_cosnr_1_mth_housing_pymt,
      x_cosnr_1_mth_crdtcard_pymt         => x_cosnr_1_mth_crdtcard_pymt,
      x_cosnr_1_mth_auto_pymt             => x_cosnr_1_mth_auto_pymt,
      x_cosnr_1_mth_ed_loan_pymt          => x_cosnr_1_mth_ed_loan_pymt,
      x_cosnr_1_mth_other_pymt            => x_cosnr_1_mth_other_pymt,
      x_cosnr_1_crdt_auth_code            => x_cosnr_1_crdt_auth_code,
      x_cosnr_2_last_name                 => x_cosnr_2_last_name,
      x_cosnr_2_first_name                => x_cosnr_2_first_name,
      x_cosnr_2_middle_name               => x_cosnr_2_middle_name,
      x_cosnr_2_ssn                       => x_cosnr_2_ssn,
      x_cosnr_2_citizenship               => x_cosnr_2_citizenship,
      x_cosnr_2_addr_line1                => x_cosnr_2_addr_line1,
      x_cosnr_2_addr_line2                => x_cosnr_2_addr_line2,
      x_cosnr_2_city                      => x_cosnr_2_city,
      x_cosnr_2_state                     => x_cosnr_2_state,
      x_cosnr_2_zip                       => x_cosnr_2_zip,
      x_cosnr_2_zip_suffix                => x_cosnr_2_zip_suffix,
      x_cosnr_2_phone                     => x_cosnr_2_phone,
      x_cosnr_2_sig_code                  => x_cosnr_2_sig_code,
      x_cosnr_2_gross_anl_sal             => x_cosnr_2_gross_anl_sal,
      x_cosnr_2_other_income              => x_cosnr_2_other_income,
      x_cosnr_2_forn_postal_code          => x_cosnr_2_forn_postal_code,
      x_cosnr_2_forn_phone_prefix         => x_cosnr_2_forn_phone_prefix,
      x_cosnr_2_dob                       => x_cosnr_2_dob,
      x_cosnr_2_license_state             => x_cosnr_2_license_state,
      x_cosnr_2_license_num               => x_cosnr_2_license_num,
      x_cosnr_2_relationship_to           => x_cosnr_2_relationship_to,
      x_cosnr_2_years_at_addr             => x_cosnr_2_years_at_addr,
      x_cosnr_2_mth_housing_pymt          => x_cosnr_2_mth_housing_pymt,
      x_cosnr_2_mth_crdtcard_pymt         => x_cosnr_2_mth_crdtcard_pymt,
      x_cosnr_2_mth_auto_pymt             => x_cosnr_2_mth_auto_pymt,
      x_cosnr_2_mth_ed_loan_pymt          => x_cosnr_2_mth_ed_loan_pymt,
      x_cosnr_2_mth_other_pymt            => x_cosnr_2_mth_other_pymt,
      x_cosnr_2_crdt_auth_code            => x_cosnr_2_crdt_auth_code,
      x_other_loan_amt                    => x_other_loan_amt,
      x_alt_layout_owner_code_txt         => x_alt_layout_owner_code_txt,
      x_alt_layout_identi_code_txt        => x_alt_layout_identi_code_txt,
      x_student_school_phone_txt          => x_student_school_phone_txt,
      x_first_csgnr_elec_sign_flag        => x_first_csgnr_elec_sign_flag,
      x_second_csgnr_elec_sign_flag       => x_second_csgnr_elec_sign_flag,

      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_sl_cl_resp_r4_all (
      clrp1_id,
      loan_number,
      fed_stafford_loan_debt,
      fed_sls_debt,
      heal_debt,
      perkins_debt,
      other_debt,
      crdt_undr_difft_name,
      borw_gross_annual_sal,
      borw_other_income,
      student_major,
      int_rate_opt,
      repayment_opt_code,
      stud_mth_housing_pymt,
      stud_mth_crdtcard_pymt,
      stud_mth_auto_pymt,
      stud_mth_ed_loan_pymt,
      stud_mth_other_pymt,
      cosnr_1_last_name,
      cosnr_1_first_name,
      cosnr_1_middle_name,
      cosnr_1_ssn,
      cosnr_1_citizenship,
      cosnr_1_addr_line1,
      cosnr_1_addr_line2,
      cosnr_1_city,
      cosnr_1_state,
      cosnr_1_zip,
      cosnr_1_zip_suffix,
      cosnr_1_phone,
      cosnr_1_sig_code,
      cosnr_1_gross_anl_sal,
      cosnr_1_other_income,
      cosnr_1_forn_postal_code,
      cosnr_1_forn_phone_prefix,
      cosnr_1_dob,
      cosnr_1_license_state,
      cosnr_1_license_num,
      cosnr_1_relationship_to,
      cosnr_1_years_at_addr,
      cosnr_1_mth_housing_pymt,
      cosnr_1_mth_crdtcard_pymt,
      cosnr_1_mth_auto_pymt,
      cosnr_1_mth_ed_loan_pymt,
      cosnr_1_mth_other_pymt,
      cosnr_1_crdt_auth_code,
      cosnr_2_last_name,
      cosnr_2_first_name,
      cosnr_2_middle_name,
      cosnr_2_ssn,
      cosnr_2_citizenship,
      cosnr_2_addr_line1,
      cosnr_2_addr_line2,
      cosnr_2_city,
      cosnr_2_state,
      cosnr_2_zip,
      cosnr_2_zip_suffix,
      cosnr_2_phone,
      cosnr_2_sig_code,
      cosnr_2_gross_anl_sal,
      cosnr_2_other_income,
      cosnr_2_forn_postal_code,
      cosnr_2_forn_phone_prefix,
      cosnr_2_dob,
      cosnr_2_license_state,
      cosnr_2_license_num,
      cosnr_2_relationship_to,
      cosnr_2_years_at_addr,
      cosnr_2_mth_housing_pymt,
      cosnr_2_mth_crdtcard_pymt,
      cosnr_2_mth_auto_pymt,
      cosnr_2_mth_ed_loan_pymt,
      cosnr_2_mth_other_pymt,
      cosnr_2_crdt_auth_code,
      other_loan_amt,
      alt_layout_owner_code_txt,
      alt_layout_identi_code_txt,
      student_school_phone_txt,
      first_csgnr_elec_sign_flag,
      second_csgnr_elec_sign_flag,
      org_id,
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
      new_references.clrp1_id,
      new_references.loan_number,
      new_references.fed_stafford_loan_debt,
      new_references.fed_sls_debt,
      new_references.heal_debt,
      new_references.perkins_debt,
      new_references.other_debt,
      new_references.crdt_undr_difft_name,
      new_references.borw_gross_annual_sal,
      new_references.borw_other_income,
      new_references.student_major,
      new_references.int_rate_opt,
      new_references.repayment_opt_code,
      new_references.stud_mth_housing_pymt,
      new_references.stud_mth_crdtcard_pymt,
      new_references.stud_mth_auto_pymt,
      new_references.stud_mth_ed_loan_pymt,
      new_references.stud_mth_other_pymt,
      new_references.cosnr_1_last_name,
      new_references.cosnr_1_first_name,
      new_references.cosnr_1_middle_name,
      new_references.cosnr_1_ssn,
      new_references.cosnr_1_citizenship,
      new_references.cosnr_1_addr_line1,
      new_references.cosnr_1_addr_line2,
      new_references.cosnr_1_city,
      new_references.cosnr_1_state,
      new_references.cosnr_1_zip,
      new_references.cosnr_1_zip_suffix,
      new_references.cosnr_1_phone,
      new_references.cosnr_1_sig_code,
      new_references.cosnr_1_gross_anl_sal,
      new_references.cosnr_1_other_income,
      new_references.cosnr_1_forn_postal_code,
      new_references.cosnr_1_forn_phone_prefix,
      new_references.cosnr_1_dob,
      new_references.cosnr_1_license_state,
      new_references.cosnr_1_license_num,
      new_references.cosnr_1_relationship_to,
      new_references.cosnr_1_years_at_addr,
      new_references.cosnr_1_mth_housing_pymt,
      new_references.cosnr_1_mth_crdtcard_pymt,
      new_references.cosnr_1_mth_auto_pymt,
      new_references.cosnr_1_mth_ed_loan_pymt,
      new_references.cosnr_1_mth_other_pymt,
      new_references.cosnr_1_crdt_auth_code,
      new_references.cosnr_2_last_name,
      new_references.cosnr_2_first_name,
      new_references.cosnr_2_middle_name,
      new_references.cosnr_2_ssn,
      new_references.cosnr_2_citizenship,
      new_references.cosnr_2_addr_line1,
      new_references.cosnr_2_addr_line2,
      new_references.cosnr_2_city,
      new_references.cosnr_2_state,
      new_references.cosnr_2_zip,
      new_references.cosnr_2_zip_suffix,
      new_references.cosnr_2_phone,
      new_references.cosnr_2_sig_code,
      new_references.cosnr_2_gross_anl_sal,
      new_references.cosnr_2_other_income,
      new_references.cosnr_2_forn_postal_code,
      new_references.cosnr_2_forn_phone_prefix,
      new_references.cosnr_2_dob,
      new_references.cosnr_2_license_state,
      new_references.cosnr_2_license_num,
      new_references.cosnr_2_relationship_to,
      new_references.cosnr_2_years_at_addr,
      new_references.cosnr_2_mth_housing_pymt,
      new_references.cosnr_2_mth_crdtcard_pymt,
      new_references.cosnr_2_mth_auto_pymt,
      new_references.cosnr_2_mth_ed_loan_pymt,
      new_references.cosnr_2_mth_other_pymt,
      new_references.cosnr_2_crdt_auth_code,
      new_references.other_loan_amt,
      new_references.alt_layout_owner_code_txt,
      new_references.alt_layout_identi_code_txt,
      new_references.student_school_phone_txt,
      new_references.first_csgnr_elec_sign_flag,
      new_references.second_csgnr_elec_sign_flag,
      new_references.org_id,
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

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_clrp1_id                          IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_fed_stafford_loan_debt            IN     NUMBER,
    x_fed_sls_debt                      IN     NUMBER,
    x_heal_debt                         IN     NUMBER,
    x_perkins_debt                      IN     NUMBER,
    x_other_debt                        IN     NUMBER,
    x_crdt_undr_difft_name              IN     VARCHAR2,
    x_borw_gross_annual_sal             IN     NUMBER,
    x_borw_other_income                 IN     NUMBER,
    x_student_major                     IN     VARCHAR2,
    x_int_rate_opt                      IN     VARCHAR2,
    x_repayment_opt_code                IN     VARCHAR2,
    x_stud_mth_housing_pymt             IN     NUMBER,
    x_stud_mth_crdtcard_pymt            IN     NUMBER,
    x_stud_mth_auto_pymt                IN     NUMBER,
    x_stud_mth_ed_loan_pymt             IN     NUMBER,
    x_stud_mth_other_pymt               IN     NUMBER,
    x_cosnr_1_last_name                 IN     VARCHAR2,
    x_cosnr_1_first_name                IN     VARCHAR2,
    x_cosnr_1_middle_name               IN     VARCHAR2,
    x_cosnr_1_ssn                       IN     VARCHAR2,
    x_cosnr_1_citizenship               IN     VARCHAR2,
    x_cosnr_1_addr_line1                IN     VARCHAR2,
    x_cosnr_1_addr_line2                IN     VARCHAR2,
    x_cosnr_1_city                      IN     VARCHAR2,
    x_cosnr_1_state                     IN     VARCHAR2,
    x_cosnr_1_zip                       IN     VARCHAR2,
    x_cosnr_1_zip_suffix                IN     VARCHAR2,
    x_cosnr_1_phone                     IN     VARCHAR2,
    x_cosnr_1_sig_code                  IN     VARCHAR2,
    x_cosnr_1_gross_anl_sal             IN     NUMBER,
    x_cosnr_1_other_income              IN     NUMBER,
    x_cosnr_1_forn_postal_code          IN     VARCHAR2,
    x_cosnr_1_forn_phone_prefix         IN     VARCHAR2,
    x_cosnr_1_dob                       IN     DATE,
    x_cosnr_1_license_state             IN     VARCHAR2,
    x_cosnr_1_license_num               IN     VARCHAR2,
    x_cosnr_1_relationship_to           IN     VARCHAR2,
    x_cosnr_1_years_at_addr             IN     VARCHAR2,
    x_cosnr_1_mth_housing_pymt          IN     NUMBER,
    x_cosnr_1_mth_crdtcard_pymt         IN     NUMBER,
    x_cosnr_1_mth_auto_pymt             IN     NUMBER,
    x_cosnr_1_mth_ed_loan_pymt          IN     NUMBER,
    x_cosnr_1_mth_other_pymt            IN     NUMBER,
    x_cosnr_1_crdt_auth_code            IN     VARCHAR2,
    x_cosnr_2_last_name                 IN     VARCHAR2,
    x_cosnr_2_first_name                IN     VARCHAR2,
    x_cosnr_2_middle_name               IN     VARCHAR2,
    x_cosnr_2_ssn                       IN     VARCHAR2,
    x_cosnr_2_citizenship               IN     VARCHAR2,
    x_cosnr_2_addr_line1                IN     VARCHAR2,
    x_cosnr_2_addr_line2                IN     VARCHAR2,
    x_cosnr_2_city                      IN     VARCHAR2,
    x_cosnr_2_state                     IN     VARCHAR2,
    x_cosnr_2_zip                       IN     VARCHAR2,
    x_cosnr_2_zip_suffix                IN     VARCHAR2,
    x_cosnr_2_phone                     IN     VARCHAR2,
    x_cosnr_2_sig_code                  IN     VARCHAR2,
    x_cosnr_2_gross_anl_sal             IN     NUMBER,
    x_cosnr_2_other_income              IN     NUMBER,
    x_cosnr_2_forn_postal_code          IN     VARCHAR2,
    x_cosnr_2_forn_phone_prefix         IN     VARCHAR2,
    x_cosnr_2_dob                       IN     DATE,
    x_cosnr_2_license_state             IN     VARCHAR2,
    x_cosnr_2_license_num               IN     VARCHAR2,
    x_cosnr_2_relationship_to           IN     VARCHAR2,
    x_cosnr_2_years_at_addr             IN     VARCHAR2,
    x_cosnr_2_mth_housing_pymt          IN     NUMBER,
    x_cosnr_2_mth_crdtcard_pymt         IN     NUMBER,
    x_cosnr_2_mth_auto_pymt             IN     NUMBER,
    x_cosnr_2_mth_ed_loan_pymt          IN     NUMBER,
    x_cosnr_2_mth_other_pymt            IN     NUMBER,
    x_cosnr_2_crdt_auth_code            IN     VARCHAR2,
    x_other_loan_amt                    IN     NUMBER  ,
    x_alt_layout_owner_code_txt         IN     VARCHAR2,
    x_alt_layout_identi_code_txt        IN     VARCHAR2,
    x_student_school_phone_txt          IN     VARCHAR2,
    x_first_csgnr_elec_sign_flag        IN     VARCHAR2,
    x_second_csgnr_elec_sign_flag       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : viramali
  ||  Created On : 10-MAY-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        loan_number,
        fed_stafford_loan_debt,
        fed_sls_debt,
        heal_debt,
        perkins_debt,
        other_debt,
        crdt_undr_difft_name,
        borw_gross_annual_sal,
        borw_other_income,
        student_major,
        int_rate_opt,
        repayment_opt_code,
        stud_mth_housing_pymt,
        stud_mth_crdtcard_pymt,
        stud_mth_auto_pymt,
        stud_mth_ed_loan_pymt,
        stud_mth_other_pymt,
        cosnr_1_last_name,
        cosnr_1_first_name,
        cosnr_1_middle_name,
        cosnr_1_ssn,
        cosnr_1_citizenship,
        cosnr_1_addr_line1,
        cosnr_1_addr_line2,
        cosnr_1_city,
        cosnr_1_state,
        cosnr_1_zip,
        cosnr_1_zip_suffix,
        cosnr_1_phone,
        cosnr_1_sig_code,
        cosnr_1_gross_anl_sal,
        cosnr_1_other_income,
        cosnr_1_forn_postal_code,
        cosnr_1_forn_phone_prefix,
        cosnr_1_dob,
        cosnr_1_license_state,
        cosnr_1_license_num,
        cosnr_1_relationship_to,
        cosnr_1_years_at_addr,
        cosnr_1_mth_housing_pymt,
        cosnr_1_mth_crdtcard_pymt,
        cosnr_1_mth_auto_pymt,
        cosnr_1_mth_ed_loan_pymt,
        cosnr_1_mth_other_pymt,
        cosnr_1_crdt_auth_code,
        cosnr_2_last_name,
        cosnr_2_first_name,
        cosnr_2_middle_name,
        cosnr_2_ssn,
        cosnr_2_citizenship,
        cosnr_2_addr_line1,
        cosnr_2_addr_line2,
        cosnr_2_city,
        cosnr_2_state,
        cosnr_2_zip,
        cosnr_2_zip_suffix,
        cosnr_2_phone,
        cosnr_2_sig_code,
        cosnr_2_gross_anl_sal,
        cosnr_2_other_income,
        cosnr_2_forn_postal_code,
        cosnr_2_forn_phone_prefix,
        cosnr_2_dob,
        cosnr_2_license_state,
        cosnr_2_license_num,
        cosnr_2_relationship_to,
        cosnr_2_years_at_addr,
        cosnr_2_mth_housing_pymt,
        cosnr_2_mth_crdtcard_pymt,
        cosnr_2_mth_auto_pymt,
        cosnr_2_mth_ed_loan_pymt,
        cosnr_2_mth_other_pymt,
        cosnr_2_crdt_auth_code,
        other_loan_amt,
        alt_layout_owner_code_txt,
        alt_layout_identi_code_txt,
        student_school_phone_txt,
        first_csgnr_elec_sign_flag,
        second_csgnr_elec_sign_flag

      FROM  igf_sl_cl_resp_r4_all
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
        (tlinfo.loan_number = x_loan_number)
        AND ((tlinfo.fed_stafford_loan_debt = x_fed_stafford_loan_debt) OR ((tlinfo.fed_stafford_loan_debt IS NULL) AND (X_fed_stafford_loan_debt IS NULL)))
        AND ((tlinfo.fed_sls_debt = x_fed_sls_debt) OR ((tlinfo.fed_sls_debt IS NULL) AND (X_fed_sls_debt IS NULL)))
        AND ((tlinfo.heal_debt = x_heal_debt) OR ((tlinfo.heal_debt IS NULL) AND (X_heal_debt IS NULL)))
        AND ((tlinfo.perkins_debt = x_perkins_debt) OR ((tlinfo.perkins_debt IS NULL) AND (X_perkins_debt IS NULL)))
        AND ((tlinfo.other_debt = x_other_debt) OR ((tlinfo.other_debt IS NULL) AND (X_other_debt IS NULL)))
        AND ((tlinfo.crdt_undr_difft_name = x_crdt_undr_difft_name) OR ((tlinfo.crdt_undr_difft_name IS NULL) AND (X_crdt_undr_difft_name IS NULL)))
        AND ((tlinfo.borw_gross_annual_sal = x_borw_gross_annual_sal) OR ((tlinfo.borw_gross_annual_sal IS NULL) AND (X_borw_gross_annual_sal IS NULL)))
        AND ((tlinfo.borw_other_income = x_borw_other_income) OR ((tlinfo.borw_other_income IS NULL) AND (X_borw_other_income IS NULL)))
        AND ((tlinfo.student_major = x_student_major) OR ((tlinfo.student_major IS NULL) AND (X_student_major IS NULL)))
        AND ((tlinfo.int_rate_opt = x_int_rate_opt) OR ((tlinfo.int_rate_opt IS NULL) AND (X_int_rate_opt IS NULL)))
        AND ((tlinfo.repayment_opt_code = x_repayment_opt_code) OR ((tlinfo.repayment_opt_code IS NULL) AND (X_repayment_opt_code IS NULL)))
        AND ((tlinfo.stud_mth_housing_pymt = x_stud_mth_housing_pymt) OR ((tlinfo.stud_mth_housing_pymt IS NULL) AND (X_stud_mth_housing_pymt IS NULL)))
        AND ((tlinfo.stud_mth_crdtcard_pymt = x_stud_mth_crdtcard_pymt) OR ((tlinfo.stud_mth_crdtcard_pymt IS NULL) AND (X_stud_mth_crdtcard_pymt IS NULL)))
        AND ((tlinfo.stud_mth_auto_pymt = x_stud_mth_auto_pymt) OR ((tlinfo.stud_mth_auto_pymt IS NULL) AND (X_stud_mth_auto_pymt IS NULL)))
        AND ((tlinfo.stud_mth_ed_loan_pymt = x_stud_mth_ed_loan_pymt) OR ((tlinfo.stud_mth_ed_loan_pymt IS NULL) AND (X_stud_mth_ed_loan_pymt IS NULL)))
        AND ((tlinfo.stud_mth_other_pymt = x_stud_mth_other_pymt) OR ((tlinfo.stud_mth_other_pymt IS NULL) AND (X_stud_mth_other_pymt IS NULL)))
        AND ((tlinfo.cosnr_1_last_name = x_cosnr_1_last_name) OR ((tlinfo.cosnr_1_last_name IS NULL) AND (X_cosnr_1_last_name IS NULL)))
        AND ((tlinfo.cosnr_1_first_name = x_cosnr_1_first_name) OR ((tlinfo.cosnr_1_first_name IS NULL) AND (X_cosnr_1_first_name IS NULL)))
        AND ((tlinfo.cosnr_1_middle_name = x_cosnr_1_middle_name) OR ((tlinfo.cosnr_1_middle_name IS NULL) AND (X_cosnr_1_middle_name IS NULL)))
        AND ((tlinfo.cosnr_1_ssn = x_cosnr_1_ssn) OR ((tlinfo.cosnr_1_ssn IS NULL) AND (X_cosnr_1_ssn IS NULL)))
        AND ((tlinfo.cosnr_1_citizenship = x_cosnr_1_citizenship) OR ((tlinfo.cosnr_1_citizenship IS NULL) AND (X_cosnr_1_citizenship IS NULL)))
        AND ((tlinfo.cosnr_1_addr_line1 = x_cosnr_1_addr_line1) OR ((tlinfo.cosnr_1_addr_line1 IS NULL) AND (X_cosnr_1_addr_line1 IS NULL)))
        AND ((tlinfo.cosnr_1_addr_line2 = x_cosnr_1_addr_line2) OR ((tlinfo.cosnr_1_addr_line2 IS NULL) AND (X_cosnr_1_addr_line2 IS NULL)))
        AND ((tlinfo.cosnr_1_city = x_cosnr_1_city) OR ((tlinfo.cosnr_1_city IS NULL) AND (X_cosnr_1_city IS NULL)))
        AND ((tlinfo.cosnr_1_state = x_cosnr_1_state) OR ((tlinfo.cosnr_1_state IS NULL) AND (X_cosnr_1_state IS NULL)))
        AND ((tlinfo.cosnr_1_zip = x_cosnr_1_zip) OR ((tlinfo.cosnr_1_zip IS NULL) AND (X_cosnr_1_zip IS NULL)))
        AND ((tlinfo.cosnr_1_zip_suffix = x_cosnr_1_zip_suffix) OR ((tlinfo.cosnr_1_zip_suffix IS NULL) AND (X_cosnr_1_zip_suffix IS NULL)))
        AND ((tlinfo.cosnr_1_phone = x_cosnr_1_phone) OR ((tlinfo.cosnr_1_phone IS NULL) AND (X_cosnr_1_phone IS NULL)))
        AND ((tlinfo.cosnr_1_sig_code = x_cosnr_1_sig_code) OR ((tlinfo.cosnr_1_sig_code IS NULL) AND (X_cosnr_1_sig_code IS NULL)))
        AND ((tlinfo.cosnr_1_gross_anl_sal = x_cosnr_1_gross_anl_sal) OR ((tlinfo.cosnr_1_gross_anl_sal IS NULL) AND (X_cosnr_1_gross_anl_sal IS NULL)))
        AND ((tlinfo.cosnr_1_other_income = x_cosnr_1_other_income) OR ((tlinfo.cosnr_1_other_income IS NULL) AND (X_cosnr_1_other_income IS NULL)))
        AND ((tlinfo.cosnr_1_forn_postal_code = x_cosnr_1_forn_postal_code) OR ((tlinfo.cosnr_1_forn_postal_code IS NULL) AND (X_cosnr_1_forn_postal_code IS NULL)))
        AND ((tlinfo.cosnr_1_forn_phone_prefix = x_cosnr_1_forn_phone_prefix) OR ((tlinfo.cosnr_1_forn_phone_prefix IS NULL) AND (X_cosnr_1_forn_phone_prefix IS NULL)))
        AND ((tlinfo.cosnr_1_dob = x_cosnr_1_dob) OR ((tlinfo.cosnr_1_dob IS NULL) AND (X_cosnr_1_dob IS NULL)))
        AND ((tlinfo.cosnr_1_license_state = x_cosnr_1_license_state) OR ((tlinfo.cosnr_1_license_state IS NULL) AND (X_cosnr_1_license_state IS NULL)))
        AND ((tlinfo.cosnr_1_license_num = x_cosnr_1_license_num) OR ((tlinfo.cosnr_1_license_num IS NULL) AND (X_cosnr_1_license_num IS NULL)))
        AND ((tlinfo.cosnr_1_relationship_to = x_cosnr_1_relationship_to) OR ((tlinfo.cosnr_1_relationship_to IS NULL) AND (X_cosnr_1_relationship_to IS NULL)))
        AND ((tlinfo.cosnr_1_years_at_addr = x_cosnr_1_years_at_addr) OR ((tlinfo.cosnr_1_years_at_addr IS NULL) AND (X_cosnr_1_years_at_addr IS NULL)))
        AND ((tlinfo.cosnr_1_mth_housing_pymt = x_cosnr_1_mth_housing_pymt) OR ((tlinfo.cosnr_1_mth_housing_pymt IS NULL) AND (X_cosnr_1_mth_housing_pymt IS NULL)))
        AND ((tlinfo.cosnr_1_mth_crdtcard_pymt = x_cosnr_1_mth_crdtcard_pymt) OR ((tlinfo.cosnr_1_mth_crdtcard_pymt IS NULL) AND (X_cosnr_1_mth_crdtcard_pymt IS NULL)))
        AND ((tlinfo.cosnr_1_mth_auto_pymt = x_cosnr_1_mth_auto_pymt) OR ((tlinfo.cosnr_1_mth_auto_pymt IS NULL) AND (X_cosnr_1_mth_auto_pymt IS NULL)))
        AND ((tlinfo.cosnr_1_mth_ed_loan_pymt = x_cosnr_1_mth_ed_loan_pymt) OR ((tlinfo.cosnr_1_mth_ed_loan_pymt IS NULL) AND (X_cosnr_1_mth_ed_loan_pymt IS NULL)))
        AND ((tlinfo.cosnr_1_mth_other_pymt = x_cosnr_1_mth_other_pymt) OR ((tlinfo.cosnr_1_mth_other_pymt IS NULL) AND (X_cosnr_1_mth_other_pymt IS NULL)))
        AND ((tlinfo.cosnr_1_crdt_auth_code = x_cosnr_1_crdt_auth_code) OR ((tlinfo.cosnr_1_crdt_auth_code IS NULL) AND (X_cosnr_1_crdt_auth_code IS NULL)))
        AND ((tlinfo.cosnr_2_last_name = x_cosnr_2_last_name) OR ((tlinfo.cosnr_2_last_name IS NULL) AND (X_cosnr_2_last_name IS NULL)))
        AND ((tlinfo.cosnr_2_first_name = x_cosnr_2_first_name) OR ((tlinfo.cosnr_2_first_name IS NULL) AND (X_cosnr_2_first_name IS NULL)))
        AND ((tlinfo.cosnr_2_middle_name = x_cosnr_2_middle_name) OR ((tlinfo.cosnr_2_middle_name IS NULL) AND (X_cosnr_2_middle_name IS NULL)))
        AND ((tlinfo.cosnr_2_ssn = x_cosnr_2_ssn) OR ((tlinfo.cosnr_2_ssn IS NULL) AND (X_cosnr_2_ssn IS NULL)))
        AND ((tlinfo.cosnr_2_citizenship = x_cosnr_2_citizenship) OR ((tlinfo.cosnr_2_citizenship IS NULL) AND (X_cosnr_2_citizenship IS NULL)))
        AND ((tlinfo.cosnr_2_addr_line1 = x_cosnr_2_addr_line1) OR ((tlinfo.cosnr_2_addr_line1 IS NULL) AND (X_cosnr_2_addr_line1 IS NULL)))
        AND ((tlinfo.cosnr_2_addr_line2 = x_cosnr_2_addr_line2) OR ((tlinfo.cosnr_2_addr_line2 IS NULL) AND (X_cosnr_2_addr_line2 IS NULL)))
        AND ((tlinfo.cosnr_2_city = x_cosnr_2_city) OR ((tlinfo.cosnr_2_city IS NULL) AND (X_cosnr_2_city IS NULL)))
        AND ((tlinfo.cosnr_2_state = x_cosnr_2_state) OR ((tlinfo.cosnr_2_state IS NULL) AND (X_cosnr_2_state IS NULL)))
        AND ((tlinfo.cosnr_2_zip = x_cosnr_2_zip) OR ((tlinfo.cosnr_2_zip IS NULL) AND (X_cosnr_2_zip IS NULL)))
        AND ((tlinfo.cosnr_2_zip_suffix = x_cosnr_2_zip_suffix) OR ((tlinfo.cosnr_2_zip_suffix IS NULL) AND (X_cosnr_2_zip_suffix IS NULL)))
        AND ((tlinfo.cosnr_2_phone = x_cosnr_2_phone) OR ((tlinfo.cosnr_2_phone IS NULL) AND (X_cosnr_2_phone IS NULL)))
        AND ((tlinfo.cosnr_2_sig_code = x_cosnr_2_sig_code) OR ((tlinfo.cosnr_2_sig_code IS NULL) AND (X_cosnr_2_sig_code IS NULL)))
        AND ((tlinfo.cosnr_2_gross_anl_sal = x_cosnr_2_gross_anl_sal) OR ((tlinfo.cosnr_2_gross_anl_sal IS NULL) AND (X_cosnr_2_gross_anl_sal IS NULL)))
        AND ((tlinfo.cosnr_2_other_income = x_cosnr_2_other_income) OR ((tlinfo.cosnr_2_other_income IS NULL) AND (X_cosnr_2_other_income IS NULL)))
        AND ((tlinfo.cosnr_2_forn_postal_code = x_cosnr_2_forn_postal_code) OR ((tlinfo.cosnr_2_forn_postal_code IS NULL) AND (X_cosnr_2_forn_postal_code IS NULL)))
        AND ((tlinfo.cosnr_2_forn_phone_prefix = x_cosnr_2_forn_phone_prefix) OR ((tlinfo.cosnr_2_forn_phone_prefix IS NULL) AND (X_cosnr_2_forn_phone_prefix IS NULL)))
        AND ((tlinfo.cosnr_2_dob = x_cosnr_2_dob) OR ((tlinfo.cosnr_2_dob IS NULL) AND (X_cosnr_2_dob IS NULL)))
        AND ((tlinfo.cosnr_2_license_state = x_cosnr_2_license_state) OR ((tlinfo.cosnr_2_license_state IS NULL) AND (X_cosnr_2_license_state IS NULL)))
        AND ((tlinfo.cosnr_2_license_num = x_cosnr_2_license_num) OR ((tlinfo.cosnr_2_license_num IS NULL) AND (X_cosnr_2_license_num IS NULL)))
        AND ((tlinfo.cosnr_2_relationship_to = x_cosnr_2_relationship_to) OR ((tlinfo.cosnr_2_relationship_to IS NULL) AND (X_cosnr_2_relationship_to IS NULL)))
        AND ((tlinfo.cosnr_2_years_at_addr = x_cosnr_2_years_at_addr) OR ((tlinfo.cosnr_2_years_at_addr IS NULL) AND (X_cosnr_2_years_at_addr IS NULL)))
        AND ((tlinfo.cosnr_2_mth_housing_pymt = x_cosnr_2_mth_housing_pymt) OR ((tlinfo.cosnr_2_mth_housing_pymt IS NULL) AND (X_cosnr_2_mth_housing_pymt IS NULL)))
        AND ((tlinfo.cosnr_2_mth_crdtcard_pymt = x_cosnr_2_mth_crdtcard_pymt) OR ((tlinfo.cosnr_2_mth_crdtcard_pymt IS NULL) AND (X_cosnr_2_mth_crdtcard_pymt IS NULL)))
        AND ((tlinfo.cosnr_2_mth_auto_pymt = x_cosnr_2_mth_auto_pymt) OR ((tlinfo.cosnr_2_mth_auto_pymt IS NULL) AND (X_cosnr_2_mth_auto_pymt IS NULL)))
        AND ((tlinfo.cosnr_2_mth_ed_loan_pymt = x_cosnr_2_mth_ed_loan_pymt) OR ((tlinfo.cosnr_2_mth_ed_loan_pymt IS NULL) AND (X_cosnr_2_mth_ed_loan_pymt IS NULL)))
        AND ((tlinfo.cosnr_2_mth_other_pymt = x_cosnr_2_mth_other_pymt) OR ((tlinfo.cosnr_2_mth_other_pymt IS NULL) AND (X_cosnr_2_mth_other_pymt IS NULL)))
        AND ((tlinfo.cosnr_2_crdt_auth_code = x_cosnr_2_crdt_auth_code) OR ((tlinfo.cosnr_2_crdt_auth_code IS NULL) AND (X_cosnr_2_crdt_auth_code IS NULL)))
        AND ((tlinfo.other_loan_amt = x_other_loan_amt) OR ((tlinfo.other_loan_amt IS NULL) AND (X_other_loan_amt IS NULL)))
        AND ((tlinfo.alt_layout_owner_code_txt = x_alt_layout_owner_code_txt) OR ((tlinfo.alt_layout_owner_code_txt IS NULL) AND (X_alt_layout_owner_code_txt IS NULL)))
        AND ((tlinfo.student_school_phone_txt = x_student_school_phone_txt) OR ((tlinfo.student_school_phone_txt IS NULL) AND (X_student_school_phone_txt IS NULL)))
        AND ((tlinfo.first_csgnr_elec_sign_flag = x_first_csgnr_elec_sign_flag) OR ((tlinfo.first_csgnr_elec_sign_flag IS NULL) AND (X_first_csgnr_elec_sign_flag IS NULL)))
        AND ((tlinfo.second_csgnr_elec_sign_flag = x_second_csgnr_elec_sign_flag) OR ((tlinfo.second_csgnr_elec_sign_flag IS NULL) AND (X_second_csgnr_elec_sign_flag IS NULL)))

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
    x_clrp1_id                          IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_fed_stafford_loan_debt            IN     NUMBER,
    x_fed_sls_debt                      IN     NUMBER,
    x_heal_debt                         IN     NUMBER,
    x_perkins_debt                      IN     NUMBER,
    x_other_debt                        IN     NUMBER,
    x_crdt_undr_difft_name              IN     VARCHAR2,
    x_borw_gross_annual_sal             IN     NUMBER,
    x_borw_other_income                 IN     NUMBER,
    x_student_major                     IN     VARCHAR2,
    x_int_rate_opt                      IN     VARCHAR2,
    x_repayment_opt_code                IN     VARCHAR2,
    x_stud_mth_housing_pymt             IN     NUMBER,
    x_stud_mth_crdtcard_pymt            IN     NUMBER,
    x_stud_mth_auto_pymt                IN     NUMBER,
    x_stud_mth_ed_loan_pymt             IN     NUMBER,
    x_stud_mth_other_pymt               IN     NUMBER,
    x_cosnr_1_last_name                 IN     VARCHAR2,
    x_cosnr_1_first_name                IN     VARCHAR2,
    x_cosnr_1_middle_name               IN     VARCHAR2,
    x_cosnr_1_ssn                       IN     VARCHAR2,
    x_cosnr_1_citizenship               IN     VARCHAR2,
    x_cosnr_1_addr_line1                IN     VARCHAR2,
    x_cosnr_1_addr_line2                IN     VARCHAR2,
    x_cosnr_1_city                      IN     VARCHAR2,
    x_cosnr_1_state                     IN     VARCHAR2,
    x_cosnr_1_zip                       IN     VARCHAR2,
    x_cosnr_1_zip_suffix                IN     VARCHAR2,
    x_cosnr_1_phone                     IN     VARCHAR2,
    x_cosnr_1_sig_code                  IN     VARCHAR2,
    x_cosnr_1_gross_anl_sal             IN     NUMBER,
    x_cosnr_1_other_income              IN     NUMBER,
    x_cosnr_1_forn_postal_code          IN     VARCHAR2,
    x_cosnr_1_forn_phone_prefix         IN     VARCHAR2,
    x_cosnr_1_dob                       IN     DATE,
    x_cosnr_1_license_state             IN     VARCHAR2,
    x_cosnr_1_license_num               IN     VARCHAR2,
    x_cosnr_1_relationship_to           IN     VARCHAR2,
    x_cosnr_1_years_at_addr             IN     VARCHAR2,
    x_cosnr_1_mth_housing_pymt          IN     NUMBER,
    x_cosnr_1_mth_crdtcard_pymt         IN     NUMBER,
    x_cosnr_1_mth_auto_pymt             IN     NUMBER,
    x_cosnr_1_mth_ed_loan_pymt          IN     NUMBER,
    x_cosnr_1_mth_other_pymt            IN     NUMBER,
    x_cosnr_1_crdt_auth_code            IN     VARCHAR2,
    x_cosnr_2_last_name                 IN     VARCHAR2,
    x_cosnr_2_first_name                IN     VARCHAR2,
    x_cosnr_2_middle_name               IN     VARCHAR2,
    x_cosnr_2_ssn                       IN     VARCHAR2,
    x_cosnr_2_citizenship               IN     VARCHAR2,
    x_cosnr_2_addr_line1                IN     VARCHAR2,
    x_cosnr_2_addr_line2                IN     VARCHAR2,
    x_cosnr_2_city                      IN     VARCHAR2,
    x_cosnr_2_state                     IN     VARCHAR2,
    x_cosnr_2_zip                       IN     VARCHAR2,
    x_cosnr_2_zip_suffix                IN     VARCHAR2,
    x_cosnr_2_phone                     IN     VARCHAR2,
    x_cosnr_2_sig_code                  IN     VARCHAR2,
    x_cosnr_2_gross_anl_sal             IN     NUMBER,
    x_cosnr_2_other_income              IN     NUMBER,
    x_cosnr_2_forn_postal_code          IN     VARCHAR2,
    x_cosnr_2_forn_phone_prefix         IN     VARCHAR2,
    x_cosnr_2_dob                       IN     DATE,
    x_cosnr_2_license_state             IN     VARCHAR2,
    x_cosnr_2_license_num               IN     VARCHAR2,
    x_cosnr_2_relationship_to           IN     VARCHAR2,
    x_cosnr_2_years_at_addr             IN     VARCHAR2,
    x_cosnr_2_mth_housing_pymt          IN     NUMBER,
    x_cosnr_2_mth_crdtcard_pymt         IN     NUMBER,
    x_cosnr_2_mth_auto_pymt             IN     NUMBER,
    x_cosnr_2_mth_ed_loan_pymt          IN     NUMBER,
    x_cosnr_2_mth_other_pymt            IN     NUMBER,
    x_cosnr_2_crdt_auth_code            IN     VARCHAR2,
    x_other_loan_amt                    IN     NUMBER   ,
    x_alt_layout_owner_code_txt         IN     VARCHAR2 ,
    x_alt_layout_identi_code_txt        IN     VARCHAR2 ,
    x_student_school_phone_txt          IN     VARCHAR2 ,
    x_first_csgnr_elec_sign_flag        IN     VARCHAR2 ,
    x_second_csgnr_elec_sign_flag       IN     VARCHAR2 ,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : viramali
  ||  Created On : 10-MAY-2001
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
      x_clrp1_id                          => x_clrp1_id,
      x_loan_number                       => x_loan_number,
      x_fed_stafford_loan_debt            => x_fed_stafford_loan_debt,
      x_fed_sls_debt                      => x_fed_sls_debt,
      x_heal_debt                         => x_heal_debt,
      x_perkins_debt                      => x_perkins_debt,
      x_other_debt                        => x_other_debt,
      x_crdt_undr_difft_name              => x_crdt_undr_difft_name,
      x_borw_gross_annual_sal             => x_borw_gross_annual_sal,
      x_borw_other_income                 => x_borw_other_income,
      x_student_major                     => x_student_major,
      x_int_rate_opt                      => x_int_rate_opt,
      x_repayment_opt_code                => x_repayment_opt_code,
      x_stud_mth_housing_pymt             => x_stud_mth_housing_pymt,
      x_stud_mth_crdtcard_pymt            => x_stud_mth_crdtcard_pymt,
      x_stud_mth_auto_pymt                => x_stud_mth_auto_pymt,
      x_stud_mth_ed_loan_pymt             => x_stud_mth_ed_loan_pymt,
      x_stud_mth_other_pymt               => x_stud_mth_other_pymt,
      x_cosnr_1_last_name                 => x_cosnr_1_last_name,
      x_cosnr_1_first_name                => x_cosnr_1_first_name,
      x_cosnr_1_middle_name               => x_cosnr_1_middle_name,
      x_cosnr_1_ssn                       => x_cosnr_1_ssn,
      x_cosnr_1_citizenship               => x_cosnr_1_citizenship,
      x_cosnr_1_addr_line1                => x_cosnr_1_addr_line1,
      x_cosnr_1_addr_line2                => x_cosnr_1_addr_line2,
      x_cosnr_1_city                      => x_cosnr_1_city,
      x_cosnr_1_state                     => x_cosnr_1_state,
      x_cosnr_1_zip                       => x_cosnr_1_zip,
      x_cosnr_1_zip_suffix                => x_cosnr_1_zip_suffix,
      x_cosnr_1_phone                     => x_cosnr_1_phone,
      x_cosnr_1_sig_code                  => x_cosnr_1_sig_code,
      x_cosnr_1_gross_anl_sal             => x_cosnr_1_gross_anl_sal,
      x_cosnr_1_other_income              => x_cosnr_1_other_income,
      x_cosnr_1_forn_postal_code          => x_cosnr_1_forn_postal_code,
      x_cosnr_1_forn_phone_prefix         => x_cosnr_1_forn_phone_prefix,
      x_cosnr_1_dob                       => x_cosnr_1_dob,
      x_cosnr_1_license_state             => x_cosnr_1_license_state,
      x_cosnr_1_license_num               => x_cosnr_1_license_num,
      x_cosnr_1_relationship_to           => x_cosnr_1_relationship_to,
      x_cosnr_1_years_at_addr             => x_cosnr_1_years_at_addr,
      x_cosnr_1_mth_housing_pymt          => x_cosnr_1_mth_housing_pymt,
      x_cosnr_1_mth_crdtcard_pymt         => x_cosnr_1_mth_crdtcard_pymt,
      x_cosnr_1_mth_auto_pymt             => x_cosnr_1_mth_auto_pymt,
      x_cosnr_1_mth_ed_loan_pymt          => x_cosnr_1_mth_ed_loan_pymt,
      x_cosnr_1_mth_other_pymt            => x_cosnr_1_mth_other_pymt,
      x_cosnr_1_crdt_auth_code            => x_cosnr_1_crdt_auth_code,
      x_cosnr_2_last_name                 => x_cosnr_2_last_name,
      x_cosnr_2_first_name                => x_cosnr_2_first_name,
      x_cosnr_2_middle_name               => x_cosnr_2_middle_name,
      x_cosnr_2_ssn                       => x_cosnr_2_ssn,
      x_cosnr_2_citizenship               => x_cosnr_2_citizenship,
      x_cosnr_2_addr_line1                => x_cosnr_2_addr_line1,
      x_cosnr_2_addr_line2                => x_cosnr_2_addr_line2,
      x_cosnr_2_city                      => x_cosnr_2_city,
      x_cosnr_2_state                     => x_cosnr_2_state,
      x_cosnr_2_zip                       => x_cosnr_2_zip,
      x_cosnr_2_zip_suffix                => x_cosnr_2_zip_suffix,
      x_cosnr_2_phone                     => x_cosnr_2_phone,
      x_cosnr_2_sig_code                  => x_cosnr_2_sig_code,
      x_cosnr_2_gross_anl_sal             => x_cosnr_2_gross_anl_sal,
      x_cosnr_2_other_income              => x_cosnr_2_other_income,
      x_cosnr_2_forn_postal_code          => x_cosnr_2_forn_postal_code,
      x_cosnr_2_forn_phone_prefix         => x_cosnr_2_forn_phone_prefix,
      x_cosnr_2_dob                       => x_cosnr_2_dob,
      x_cosnr_2_license_state             => x_cosnr_2_license_state,
      x_cosnr_2_license_num               => x_cosnr_2_license_num,
      x_cosnr_2_relationship_to           => x_cosnr_2_relationship_to,
      x_cosnr_2_years_at_addr             => x_cosnr_2_years_at_addr,
      x_cosnr_2_mth_housing_pymt          => x_cosnr_2_mth_housing_pymt,
      x_cosnr_2_mth_crdtcard_pymt         => x_cosnr_2_mth_crdtcard_pymt,
      x_cosnr_2_mth_auto_pymt             => x_cosnr_2_mth_auto_pymt,
      x_cosnr_2_mth_ed_loan_pymt          => x_cosnr_2_mth_ed_loan_pymt,
      x_cosnr_2_mth_other_pymt            => x_cosnr_2_mth_other_pymt,
      x_cosnr_2_crdt_auth_code            => x_cosnr_2_crdt_auth_code,
      x_other_loan_amt                    => x_other_loan_amt,
      x_alt_layout_owner_code_txt         => x_alt_layout_owner_code_txt,
      x_alt_layout_identi_code_txt        => x_alt_layout_identi_code_txt,
      x_student_school_phone_txt          => x_student_school_phone_txt,
      x_first_csgnr_elec_sign_flag        => x_first_csgnr_elec_sign_flag,
      x_second_csgnr_elec_sign_flag       => x_second_csgnr_elec_sign_flag,

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

    UPDATE igf_sl_cl_resp_r4_all
      SET
        loan_number                       = new_references.loan_number,
        fed_stafford_loan_debt            = new_references.fed_stafford_loan_debt,
        fed_sls_debt                      = new_references.fed_sls_debt,
        heal_debt                         = new_references.heal_debt,
        perkins_debt                      = new_references.perkins_debt,
        other_debt                        = new_references.other_debt,
        crdt_undr_difft_name              = new_references.crdt_undr_difft_name,
        borw_gross_annual_sal             = new_references.borw_gross_annual_sal,
        borw_other_income                 = new_references.borw_other_income,
        student_major                     = new_references.student_major,
        int_rate_opt                      = new_references.int_rate_opt,
        repayment_opt_code                = new_references.repayment_opt_code,
        stud_mth_housing_pymt             = new_references.stud_mth_housing_pymt,
        stud_mth_crdtcard_pymt            = new_references.stud_mth_crdtcard_pymt,
        stud_mth_auto_pymt                = new_references.stud_mth_auto_pymt,
        stud_mth_ed_loan_pymt             = new_references.stud_mth_ed_loan_pymt,
        stud_mth_other_pymt               = new_references.stud_mth_other_pymt,
        cosnr_1_last_name                 = new_references.cosnr_1_last_name,
        cosnr_1_first_name                = new_references.cosnr_1_first_name,
        cosnr_1_middle_name               = new_references.cosnr_1_middle_name,
        cosnr_1_ssn                       = new_references.cosnr_1_ssn,
        cosnr_1_citizenship               = new_references.cosnr_1_citizenship,
        cosnr_1_addr_line1                = new_references.cosnr_1_addr_line1,
        cosnr_1_addr_line2                = new_references.cosnr_1_addr_line2,
        cosnr_1_city                      = new_references.cosnr_1_city,
        cosnr_1_state                     = new_references.cosnr_1_state,
        cosnr_1_zip                       = new_references.cosnr_1_zip,
        cosnr_1_zip_suffix                = new_references.cosnr_1_zip_suffix,
        cosnr_1_phone                     = new_references.cosnr_1_phone,
        cosnr_1_sig_code                  = new_references.cosnr_1_sig_code,
        cosnr_1_gross_anl_sal             = new_references.cosnr_1_gross_anl_sal,
        cosnr_1_other_income              = new_references.cosnr_1_other_income,
        cosnr_1_forn_postal_code          = new_references.cosnr_1_forn_postal_code,
        cosnr_1_forn_phone_prefix         = new_references.cosnr_1_forn_phone_prefix,
        cosnr_1_dob                       = new_references.cosnr_1_dob,
        cosnr_1_license_state             = new_references.cosnr_1_license_state,
        cosnr_1_license_num               = new_references.cosnr_1_license_num,
        cosnr_1_relationship_to           = new_references.cosnr_1_relationship_to,
        cosnr_1_years_at_addr             = new_references.cosnr_1_years_at_addr,
        cosnr_1_mth_housing_pymt          = new_references.cosnr_1_mth_housing_pymt,
        cosnr_1_mth_crdtcard_pymt         = new_references.cosnr_1_mth_crdtcard_pymt,
        cosnr_1_mth_auto_pymt             = new_references.cosnr_1_mth_auto_pymt,
        cosnr_1_mth_ed_loan_pymt          = new_references.cosnr_1_mth_ed_loan_pymt,
        cosnr_1_mth_other_pymt            = new_references.cosnr_1_mth_other_pymt,
        cosnr_1_crdt_auth_code            = new_references.cosnr_1_crdt_auth_code,
        cosnr_2_last_name                 = new_references.cosnr_2_last_name,
        cosnr_2_first_name                = new_references.cosnr_2_first_name,
        cosnr_2_middle_name               = new_references.cosnr_2_middle_name,
        cosnr_2_ssn                       = new_references.cosnr_2_ssn,
        cosnr_2_citizenship               = new_references.cosnr_2_citizenship,
        cosnr_2_addr_line1                = new_references.cosnr_2_addr_line1,
        cosnr_2_addr_line2                = new_references.cosnr_2_addr_line2,
        cosnr_2_city                      = new_references.cosnr_2_city,
        cosnr_2_state                     = new_references.cosnr_2_state,
        cosnr_2_zip                       = new_references.cosnr_2_zip,
        cosnr_2_zip_suffix                = new_references.cosnr_2_zip_suffix,
        cosnr_2_phone                     = new_references.cosnr_2_phone,
        cosnr_2_sig_code                  = new_references.cosnr_2_sig_code,
        cosnr_2_gross_anl_sal             = new_references.cosnr_2_gross_anl_sal,
        cosnr_2_other_income              = new_references.cosnr_2_other_income,
        cosnr_2_forn_postal_code          = new_references.cosnr_2_forn_postal_code,
        cosnr_2_forn_phone_prefix         = new_references.cosnr_2_forn_phone_prefix,
        cosnr_2_dob                       = new_references.cosnr_2_dob,
        cosnr_2_license_state             = new_references.cosnr_2_license_state,
        cosnr_2_license_num               = new_references.cosnr_2_license_num,
        cosnr_2_relationship_to           = new_references.cosnr_2_relationship_to,
        cosnr_2_years_at_addr             = new_references.cosnr_2_years_at_addr,
        cosnr_2_mth_housing_pymt          = new_references.cosnr_2_mth_housing_pymt,
        cosnr_2_mth_crdtcard_pymt         = new_references.cosnr_2_mth_crdtcard_pymt,
        cosnr_2_mth_auto_pymt             = new_references.cosnr_2_mth_auto_pymt,
        cosnr_2_mth_ed_loan_pymt          = new_references.cosnr_2_mth_ed_loan_pymt,
        cosnr_2_mth_other_pymt            = new_references.cosnr_2_mth_other_pymt,
        cosnr_2_crdt_auth_code            = new_references.cosnr_2_crdt_auth_code,

        other_loan_amt                    = new_references.other_loan_amt,
        alt_layout_owner_code_txt         = new_references.alt_layout_owner_code_txt,
        alt_layout_identi_code_txt        = new_references.alt_layout_identi_code_txt,
        student_school_phone_txt          = new_references.student_school_phone_txt,
        first_csgnr_elec_sign_flag        = new_references.first_csgnr_elec_sign_flag,
        second_csgnr_elec_sign_flag       = new_references.second_csgnr_elec_sign_flag,

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
    x_clrp1_id                          IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_fed_stafford_loan_debt            IN     NUMBER,
    x_fed_sls_debt                      IN     NUMBER,
    x_heal_debt                         IN     NUMBER,
    x_perkins_debt                      IN     NUMBER,
    x_other_debt                        IN     NUMBER,
    x_crdt_undr_difft_name              IN     VARCHAR2,
    x_borw_gross_annual_sal             IN     NUMBER,
    x_borw_other_income                 IN     NUMBER,
    x_student_major                     IN     VARCHAR2,
    x_int_rate_opt                      IN     VARCHAR2,
    x_repayment_opt_code                IN     VARCHAR2,
    x_stud_mth_housing_pymt             IN     NUMBER,
    x_stud_mth_crdtcard_pymt            IN     NUMBER,
    x_stud_mth_auto_pymt                IN     NUMBER,
    x_stud_mth_ed_loan_pymt             IN     NUMBER,
    x_stud_mth_other_pymt               IN     NUMBER,
    x_cosnr_1_last_name                 IN     VARCHAR2,
    x_cosnr_1_first_name                IN     VARCHAR2,
    x_cosnr_1_middle_name               IN     VARCHAR2,
    x_cosnr_1_ssn                       IN     VARCHAR2,
    x_cosnr_1_citizenship               IN     VARCHAR2,
    x_cosnr_1_addr_line1                IN     VARCHAR2,
    x_cosnr_1_addr_line2                IN     VARCHAR2,
    x_cosnr_1_city                      IN     VARCHAR2,
    x_cosnr_1_state                     IN     VARCHAR2,
    x_cosnr_1_zip                       IN     VARCHAR2,
    x_cosnr_1_zip_suffix                IN     VARCHAR2,
    x_cosnr_1_phone                     IN     VARCHAR2,
    x_cosnr_1_sig_code                  IN     VARCHAR2,
    x_cosnr_1_gross_anl_sal             IN     NUMBER,
    x_cosnr_1_other_income              IN     NUMBER,
    x_cosnr_1_forn_postal_code          IN     VARCHAR2,
    x_cosnr_1_forn_phone_prefix         IN     VARCHAR2,
    x_cosnr_1_dob                       IN     DATE,
    x_cosnr_1_license_state             IN     VARCHAR2,
    x_cosnr_1_license_num               IN     VARCHAR2,
    x_cosnr_1_relationship_to           IN     VARCHAR2,
    x_cosnr_1_years_at_addr             IN     VARCHAR2,
    x_cosnr_1_mth_housing_pymt          IN     NUMBER,
    x_cosnr_1_mth_crdtcard_pymt         IN     NUMBER,
    x_cosnr_1_mth_auto_pymt             IN     NUMBER,
    x_cosnr_1_mth_ed_loan_pymt          IN     NUMBER,
    x_cosnr_1_mth_other_pymt            IN     NUMBER,
    x_cosnr_1_crdt_auth_code            IN     VARCHAR2,
    x_cosnr_2_last_name                 IN     VARCHAR2,
    x_cosnr_2_first_name                IN     VARCHAR2,
    x_cosnr_2_middle_name               IN     VARCHAR2,
    x_cosnr_2_ssn                       IN     VARCHAR2,
    x_cosnr_2_citizenship               IN     VARCHAR2,
    x_cosnr_2_addr_line1                IN     VARCHAR2,
    x_cosnr_2_addr_line2                IN     VARCHAR2,
    x_cosnr_2_city                      IN     VARCHAR2,
    x_cosnr_2_state                     IN     VARCHAR2,
    x_cosnr_2_zip                       IN     VARCHAR2,
    x_cosnr_2_zip_suffix                IN     VARCHAR2,
    x_cosnr_2_phone                     IN     VARCHAR2,
    x_cosnr_2_sig_code                  IN     VARCHAR2,
    x_cosnr_2_gross_anl_sal             IN     NUMBER,
    x_cosnr_2_other_income              IN     NUMBER,
    x_cosnr_2_forn_postal_code          IN     VARCHAR2,
    x_cosnr_2_forn_phone_prefix         IN     VARCHAR2,
    x_cosnr_2_dob                       IN     DATE,
    x_cosnr_2_license_state             IN     VARCHAR2,
    x_cosnr_2_license_num               IN     VARCHAR2,
    x_cosnr_2_relationship_to           IN     VARCHAR2,
    x_cosnr_2_years_at_addr             IN     VARCHAR2,
    x_cosnr_2_mth_housing_pymt          IN     NUMBER,
    x_cosnr_2_mth_crdtcard_pymt         IN     NUMBER,
    x_cosnr_2_mth_auto_pymt             IN     NUMBER,
    x_cosnr_2_mth_ed_loan_pymt          IN     NUMBER,
    x_cosnr_2_mth_other_pymt            IN     NUMBER,
    x_cosnr_2_crdt_auth_code            IN     VARCHAR2,
    x_other_loan_amt                    IN     NUMBER   ,
    x_alt_layout_owner_code_txt         IN     VARCHAR2 ,
    x_alt_layout_identi_code_txt        IN     VARCHAR2 ,
    x_student_school_phone_txt          IN     VARCHAR2 ,
    x_first_csgnr_elec_sign_flag        IN     VARCHAR2 ,
    x_second_csgnr_elec_sign_flag       IN     VARCHAR2 ,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : viramali
  ||  Created On : 10-MAY-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_sl_cl_resp_r4_all
      WHERE    clrp1_id                          = x_clrp1_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_clrp1_id,
        x_loan_number,
        x_fed_stafford_loan_debt,
        x_fed_sls_debt,
        x_heal_debt,
        x_perkins_debt,
        x_other_debt,
        x_crdt_undr_difft_name,
        x_borw_gross_annual_sal,
        x_borw_other_income,
        x_student_major,
        x_int_rate_opt,
        x_repayment_opt_code,
        x_stud_mth_housing_pymt,
        x_stud_mth_crdtcard_pymt,
        x_stud_mth_auto_pymt,
        x_stud_mth_ed_loan_pymt,
        x_stud_mth_other_pymt,
        x_cosnr_1_last_name,
        x_cosnr_1_first_name,
        x_cosnr_1_middle_name,
        x_cosnr_1_ssn,
        x_cosnr_1_citizenship,
        x_cosnr_1_addr_line1,
        x_cosnr_1_addr_line2,
        x_cosnr_1_city,
        x_cosnr_1_state,
        x_cosnr_1_zip,
        x_cosnr_1_zip_suffix,
        x_cosnr_1_phone,
        x_cosnr_1_sig_code,
        x_cosnr_1_gross_anl_sal,
        x_cosnr_1_other_income,
        x_cosnr_1_forn_postal_code,
        x_cosnr_1_forn_phone_prefix,
        x_cosnr_1_dob,
        x_cosnr_1_license_state,
        x_cosnr_1_license_num,
        x_cosnr_1_relationship_to,
        x_cosnr_1_years_at_addr,
        x_cosnr_1_mth_housing_pymt,
        x_cosnr_1_mth_crdtcard_pymt,
        x_cosnr_1_mth_auto_pymt,
        x_cosnr_1_mth_ed_loan_pymt,
        x_cosnr_1_mth_other_pymt,
        x_cosnr_1_crdt_auth_code,
        x_cosnr_2_last_name,
        x_cosnr_2_first_name,
        x_cosnr_2_middle_name,
        x_cosnr_2_ssn,
        x_cosnr_2_citizenship,
        x_cosnr_2_addr_line1,
        x_cosnr_2_addr_line2,
        x_cosnr_2_city,
        x_cosnr_2_state,
        x_cosnr_2_zip,
        x_cosnr_2_zip_suffix,
        x_cosnr_2_phone,
        x_cosnr_2_sig_code,
        x_cosnr_2_gross_anl_sal,
        x_cosnr_2_other_income,
        x_cosnr_2_forn_postal_code,
        x_cosnr_2_forn_phone_prefix,
        x_cosnr_2_dob,
        x_cosnr_2_license_state,
        x_cosnr_2_license_num,
        x_cosnr_2_relationship_to,
        x_cosnr_2_years_at_addr,
        x_cosnr_2_mth_housing_pymt,
        x_cosnr_2_mth_crdtcard_pymt,
        x_cosnr_2_mth_auto_pymt,
        x_cosnr_2_mth_ed_loan_pymt,
        x_cosnr_2_mth_other_pymt,
        x_cosnr_2_crdt_auth_code,
        x_other_loan_amt,
        x_alt_layout_owner_code_txt,
        x_alt_layout_identi_code_txt,
        x_student_school_phone_txt  ,
        x_first_csgnr_elec_sign_flag ,
        x_second_csgnr_elec_sign_flag,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_clrp1_id,
      x_loan_number,
      x_fed_stafford_loan_debt,
      x_fed_sls_debt,
      x_heal_debt,
      x_perkins_debt,
      x_other_debt,
      x_crdt_undr_difft_name,
      x_borw_gross_annual_sal,
      x_borw_other_income,
      x_student_major,
      x_int_rate_opt,
      x_repayment_opt_code,
      x_stud_mth_housing_pymt,
      x_stud_mth_crdtcard_pymt,
      x_stud_mth_auto_pymt,
      x_stud_mth_ed_loan_pymt,
      x_stud_mth_other_pymt,
      x_cosnr_1_last_name,
      x_cosnr_1_first_name,
      x_cosnr_1_middle_name,
      x_cosnr_1_ssn,
      x_cosnr_1_citizenship,
      x_cosnr_1_addr_line1,
      x_cosnr_1_addr_line2,
      x_cosnr_1_city,
      x_cosnr_1_state,
      x_cosnr_1_zip,
      x_cosnr_1_zip_suffix,
      x_cosnr_1_phone,
      x_cosnr_1_sig_code,
      x_cosnr_1_gross_anl_sal,
      x_cosnr_1_other_income,
      x_cosnr_1_forn_postal_code,
      x_cosnr_1_forn_phone_prefix,
      x_cosnr_1_dob,
      x_cosnr_1_license_state,
      x_cosnr_1_license_num,
      x_cosnr_1_relationship_to,
      x_cosnr_1_years_at_addr,
      x_cosnr_1_mth_housing_pymt,
      x_cosnr_1_mth_crdtcard_pymt,
      x_cosnr_1_mth_auto_pymt,
      x_cosnr_1_mth_ed_loan_pymt,
      x_cosnr_1_mth_other_pymt,
      x_cosnr_1_crdt_auth_code,
      x_cosnr_2_last_name,
      x_cosnr_2_first_name,
      x_cosnr_2_middle_name,
      x_cosnr_2_ssn,
      x_cosnr_2_citizenship,
      x_cosnr_2_addr_line1,
      x_cosnr_2_addr_line2,
      x_cosnr_2_city,
      x_cosnr_2_state,
      x_cosnr_2_zip,
      x_cosnr_2_zip_suffix,
      x_cosnr_2_phone,
      x_cosnr_2_sig_code,
      x_cosnr_2_gross_anl_sal,
      x_cosnr_2_other_income,
      x_cosnr_2_forn_postal_code,
      x_cosnr_2_forn_phone_prefix,
      x_cosnr_2_dob,
      x_cosnr_2_license_state,
      x_cosnr_2_license_num,
      x_cosnr_2_relationship_to,
      x_cosnr_2_years_at_addr,
      x_cosnr_2_mth_housing_pymt,
      x_cosnr_2_mth_crdtcard_pymt,
      x_cosnr_2_mth_auto_pymt,
      x_cosnr_2_mth_ed_loan_pymt,
      x_cosnr_2_mth_other_pymt,
      x_cosnr_2_crdt_auth_code,
      x_other_loan_amt,
      x_alt_layout_owner_code_txt,
      x_alt_layout_identi_code_txt,
      x_student_school_phone_txt  ,
      x_first_csgnr_elec_sign_flag ,
      x_second_csgnr_elec_sign_flag,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : viramali
  ||  Created On : 10-MAY-2001
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

    DELETE FROM igf_sl_cl_resp_r4_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_sl_cl_resp_r4_pkg;

/
