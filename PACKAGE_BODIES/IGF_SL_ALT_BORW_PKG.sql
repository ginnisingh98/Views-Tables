--------------------------------------------------------
--  DDL for Package Body IGF_SL_ALT_BORW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_ALT_BORW_PKG" AS
/* $Header: IGFLI32B.pls 120.1 2005/06/08 00:48:35 appldev  $ */

  l_rowid VARCHAR2(25);
  old_references igf_sl_alt_borw_all%ROWTYPE;
  new_references igf_sl_alt_borw_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2 ,
    x_rowid                             IN     VARCHAR2 ,
    x_albw_id                           IN     NUMBER   ,
    x_loan_id                           IN     NUMBER   ,
    x_fed_stafford_loan_debt            IN     NUMBER   ,
    x_fed_sls_debt                      IN     NUMBER   ,
    x_heal_debt                         IN     NUMBER   ,
    x_perkins_debt                      IN     NUMBER   ,
    x_other_debt                        IN     NUMBER   ,
    x_crdt_undr_difft_name              IN     VARCHAR2 ,
    x_borw_gross_annual_sal             IN     NUMBER   ,
    x_borw_other_income                 IN     NUMBER   ,
    x_student_major                     IN     VARCHAR2 ,
    x_int_rate_opt                      IN     VARCHAR2 ,
    x_repayment_opt_code                IN     VARCHAR2 ,
    x_stud_mth_housing_pymt             IN     NUMBER   ,
    x_stud_mth_crdtcard_pymt            IN     NUMBER   ,
    x_stud_mth_auto_pymt                IN     NUMBER   ,
    x_stud_mth_ed_loan_pymt             IN     NUMBER   ,
    x_stud_mth_other_pymt               IN     NUMBER   ,
    x_creation_date                     IN     DATE     ,
    x_created_by                        IN     NUMBER   ,
    x_last_update_date                  IN     DATE     ,
    x_last_updated_by                   IN     NUMBER   ,
    x_last_update_login                 IN     NUMBER    ,
    x_other_loan_amt                    IN     NUMBER,
    x_cs1_lname                         IN     VARCHAR2,
    x_cs1_fname                         IN     VARCHAR2,
    x_cs1_mi_txt                        IN     VARCHAR2,
    x_cs1_ssn_txt                       IN     VARCHAR2,
    x_cs1_citizenship_status            IN     VARCHAR2,
    x_cs1_address_line_1_txt            IN     VARCHAR2,
    x_cs1_address_line_2_txt            IN     VARCHAR2,
    x_cs1_city_txt                      IN     VARCHAR2,
    x_cs1_state_txt                     IN     VARCHAR2,
    x_cs1_zip_txt                       IN     VARCHAR2,
    x_cs1_zip_suffix_txt                IN     VARCHAR2,
    x_cs1_telephone_number_txt          IN     VARCHAR2,
    x_cs1_signature_code_txt            IN     VARCHAR2,
    x_cs2_lname                         IN     VARCHAR2,
    x_cs2_fname                         IN     VARCHAR2,
    x_cs2_mi_txt                        IN     VARCHAR2,
    x_cs2_ssn_txt                       IN     VARCHAR2,
    x_cs2_citizenship_status            IN     VARCHAR2,
    x_cs2_address_line_1_txt            IN     VARCHAR2,
    x_cs2_address_line_2_txt            IN     VARCHAR2,
    x_cs2_city_txt                      IN     VARCHAR2,
    x_cs2_state_txt                     IN     VARCHAR2,
    x_cs2_zip_txt                       IN     VARCHAR2,
    x_cs2_zip_suffix_txt                IN     VARCHAR2,
    x_cs2_telephone_number_txt          IN     VARCHAR2,
    x_cs2_signature_code_txt            IN     VARCHAR2,
    x_cs1_credit_auth_code_txt          IN     VARCHAR2,
    x_cs1_birth_date                    IN     Date    ,
    x_cs1_drv_license_num_txt           IN     VARCHAR2,
    x_cs1_drv_license_state_txt         IN     VARCHAR2,
    x_cs1_elect_sig_ind_code_txt        IN     VARCHAR2,
    x_cs1_frgn_postal_code_txt          IN     VARCHAR2,
    x_cs1_frgn_tel_num_prefix_txt       IN     VARCHAR2,
    x_cs1_gross_annual_sal_num          IN     NUMBER  ,
    x_cs1_mthl_auto_pay_txt             IN     VARCHAR2,
    x_cs1_mthl_cc_pay_txt               IN     VARCHAR2,
    x_cs1_mthl_edu_loan_pay_txt         IN     VARCHAR2,
    x_cs1_mthl_housing_pay_txt          IN     VARCHAR2,
    x_cs1_mthl_other_pay_txt            IN     VARCHAR2,
    x_cs1_other_income_amt              IN     NUMBER  ,
    x_cs1_rel_to_student_flag           IN     VARCHAR2,
    x_cs1_suffix_txt                    IN     VARCHAR2,
    x_cs1_years_at_address_txt          IN     NUMBER  ,
    x_cs2_credit_auth_code_txt          IN     VARCHAR2,
    x_cs2_birth_date                    IN     Date    ,
    x_cs2_drv_license_num_txt           IN     VARCHAR2,
    x_cs2_drv_license_state_txt         IN     VARCHAR2,
    x_cs2_elect_sig_ind_code_txt        IN     VARCHAR2,
    x_cs2_frgn_postal_code_txt          IN     VARCHAR2,
    x_cs2_frgn_tel_num_prefix_txt       IN     VARCHAR2,
    x_cs2_gross_annual_sal_num          IN     NUMBER  ,
    x_cs2_mthl_auto_pay_txt             IN     VARCHAR2,
    x_cs2_mthl_cc_pay_txt               IN     VARCHAR2,
    x_cs2_mthl_edu_loan_pay_txt         IN     VARCHAR2,
    x_cs2_mthl_housing_pay_txt          IN     VARCHAR2,
    x_cs2_mthl_other_pay_txt            IN     VARCHAR2,
    x_cs2_other_income_amt              IN     NUMBER  ,
    x_cs2_rel_to_student_flag           IN     VARCHAR2,
    x_cs2_suffix_txt                    IN     VARCHAR2,
    x_cs2_years_at_address_txt          IN     NUMBER
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
       SELECT *
       FROM   igf_sl_alt_borw_all
       WHERE  rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.albw_id                           := x_albw_id;
    new_references.loan_id                           := x_loan_id;
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
    new_references.other_loan_amt                    := x_other_loan_amt;

    new_references.cs1_lname                         := x_cs1_lname;
    new_references.cs1_fname                         := x_cs1_fname;
    new_references.cs1_mi_txt                        := x_cs1_mi_txt;
    new_references.cs1_ssn_txt                       := x_cs1_ssn_txt;
    new_references.cs1_citizenship_status            := x_cs1_citizenship_status;
    new_references.cs1_address_line_1_txt            := x_cs1_address_line_1_txt;
    new_references.cs1_address_line_2_txt            := x_cs1_address_line_2_txt;
    new_references.cs1_city_txt                      := x_cs1_city_txt;
    new_references.cs1_state_txt                     := x_cs1_state_txt;
    new_references.cs1_zip_txt                       := x_cs1_zip_txt;
    new_references.cs1_zip_suffix_txt                := x_cs1_zip_suffix_txt;
    new_references.cs1_telephone_number_txt          := x_cs1_telephone_number_txt;
    new_references.cs1_signature_code_txt            := x_cs1_signature_code_txt;
    new_references.cs2_lname                         := x_cs2_lname;
    new_references.cs2_fname                         := x_cs2_fname;
    new_references.cs2_mi_txt                        := x_cs2_mi_txt;
    new_references.cs2_ssn_txt                       := x_cs2_ssn_txt;
    new_references.cs2_citizenship_status            := x_cs2_citizenship_status;
    new_references.cs2_address_line_1_txt            := x_cs2_address_line_1_txt;
    new_references.cs2_address_line_2_txt            := x_cs2_address_line_2_txt;
    new_references.cs2_city_txt                      := x_cs2_city_txt;
    new_references.cs2_state_txt                     := x_cs2_state_txt;
    new_references.cs2_zip_txt                       := x_cs2_zip_txt;
    new_references.cs2_zip_suffix_txt                := x_cs2_zip_suffix_txt;
    new_references.cs2_telephone_number_txt          := x_cs2_telephone_number_txt;
    new_references.cs2_signature_code_txt            := x_cs2_signature_code_txt;
    new_references.cs1_credit_auth_code_txt          := x_cs1_credit_auth_code_txt;
    new_references.cs1_birth_date                    := x_cs1_birth_date;
    new_references.cs1_drv_license_num_txt           := x_cs1_drv_license_num_txt;
    new_references.cs1_drv_license_state_txt         := x_cs1_drv_license_state_txt;
    new_references.cs1_elect_sig_ind_code_txt        := x_cs1_elect_sig_ind_code_txt;
    new_references.cs1_frgn_postal_code_txt          := x_cs1_frgn_postal_code_txt;
    new_references.cs1_frgn_tel_num_prefix_txt       := x_cs1_frgn_tel_num_prefix_txt;
    new_references.cs1_gross_annual_sal_num          := x_cs1_gross_annual_sal_num;
    new_references.cs1_mthl_auto_pay_txt             := x_cs1_mthl_auto_pay_txt;
    new_references.cs1_mthl_cc_pay_txt               := x_cs1_mthl_cc_pay_txt;
    new_references.cs1_mthl_edu_loan_pay_txt         := x_cs1_mthl_edu_loan_pay_txt;
    new_references.cs1_mthl_housing_pay_txt          := x_cs1_mthl_housing_pay_txt;
    new_references.cs1_mthl_other_pay_txt            := x_cs1_mthl_other_pay_txt;
    new_references.cs1_other_income_amt              := x_cs1_other_income_amt;
    new_references.cs1_rel_to_student_flag           := x_cs1_rel_to_student_flag;
    new_references.cs1_suffix_txt                    := x_cs1_suffix_txt;
    new_references.cs1_years_at_address_txt          := x_cs1_years_at_address_txt;
    new_references.cs2_credit_auth_code_txt          := x_cs2_credit_auth_code_txt;
    new_references.cs2_birth_date                    := x_cs2_birth_date;
    new_references.cs2_drv_license_num_txt           := x_cs2_drv_license_num_txt;
    new_references.cs2_drv_license_state_txt         := x_cs2_drv_license_state_txt;
    new_references.cs2_elect_sig_ind_code_txt        := x_cs2_elect_sig_ind_code_txt;
    new_references.cs2_frgn_postal_code_txt          := x_cs2_frgn_postal_code_txt;
    new_references.cs2_frgn_tel_num_prefix_txt       := x_cs2_frgn_tel_num_prefix_txt;
    new_references.cs2_gross_annual_sal_num          := x_cs2_gross_annual_sal_num;
    new_references.cs2_mthl_auto_pay_txt             := x_cs2_mthl_auto_pay_txt;
    new_references.cs2_mthl_cc_pay_txt               := x_cs2_mthl_cc_pay_txt;
    new_references.cs2_mthl_edu_loan_pay_txt         := x_cs2_mthl_edu_loan_pay_txt;
    new_references.cs2_mthl_housing_pay_txt          := x_cs2_mthl_housing_pay_txt;
    new_references.cs2_mthl_other_pay_txt            := x_cs2_mthl_other_pay_txt;
    new_references.cs2_other_income_amt              := x_cs2_other_income_amt;
    new_references.cs2_rel_to_student_flag           := x_cs2_rel_to_student_flag;
    new_references.cs2_suffix_txt                    := x_cs2_suffix_txt;
    new_references.cs2_years_at_address_txt          := x_cs2_years_at_address_txt;

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

    IF (((old_references.loan_id = new_references.loan_id)) OR
        ((new_references.loan_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_sl_loans_pkg.get_pk_for_validation ( new_references.loan_id ) THEN
      FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_albw_id                           IN     NUMBER
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
       SELECT rowid
       FROM   igf_sl_alt_borw_all
       WHERE  albw_id = x_albw_id
       FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%ROWTYPE;

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


  PROCEDURE get_fk_igf_sl_loans ( x_loan_id    IN     NUMBER ) AS
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
       SELECT rowid
       FROM   igf_sl_alt_borw_all
       WHERE  ((loan_id = x_loan_id));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      FND_MESSAGE.SET_NAME ('IGF', 'IGF_SL_ALBW_LAR_FK');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_sl_loans;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2 ,
    x_rowid                             IN     VARCHAR2 ,
    x_albw_id                           IN     NUMBER   ,
    x_loan_id                           IN     NUMBER   ,
    x_fed_stafford_loan_debt            IN     NUMBER   ,
    x_fed_sls_debt                      IN     NUMBER   ,
    x_heal_debt                         IN     NUMBER   ,
    x_perkins_debt                      IN     NUMBER   ,
    x_other_debt                        IN     NUMBER   ,
    x_crdt_undr_difft_name              IN     VARCHAR2 ,
    x_borw_gross_annual_sal             IN     NUMBER   ,
    x_borw_other_income                 IN     NUMBER   ,
    x_student_major                     IN     VARCHAR2 ,
    x_int_rate_opt                      IN     VARCHAR2 ,
    x_repayment_opt_code                IN     VARCHAR2 ,
    x_stud_mth_housing_pymt             IN     NUMBER   ,
    x_stud_mth_crdtcard_pymt            IN     NUMBER   ,
    x_stud_mth_auto_pymt                IN     NUMBER   ,
    x_stud_mth_ed_loan_pymt             IN     NUMBER   ,
    x_stud_mth_other_pymt               IN     NUMBER   ,
    x_creation_date                     IN     DATE     ,
    x_created_by                        IN     NUMBER   ,
    x_last_update_date                  IN     DATE     ,
    x_last_updated_by                   IN     NUMBER   ,
    x_last_update_login                 IN     NUMBER  ,
    x_other_loan_amt                    IN     NUMBER,
    x_cs1_lname                         IN     VARCHAR2,
    x_cs1_fname                         IN     VARCHAR2,
    x_cs1_mi_txt                        IN     VARCHAR2,
    x_cs1_ssn_txt                       IN     VARCHAR2,
    x_cs1_citizenship_status            IN     VARCHAR2,
    x_cs1_address_line_1_txt            IN     VARCHAR2,
    x_cs1_address_line_2_txt            IN     VARCHAR2,
    x_cs1_city_txt                      IN     VARCHAR2,
    x_cs1_state_txt                     IN     VARCHAR2,
    x_cs1_zip_txt                       IN     VARCHAR2,
    x_cs1_zip_suffix_txt                IN     VARCHAR2,
    x_cs1_telephone_number_txt          IN     VARCHAR2,
    x_cs1_signature_code_txt            IN     VARCHAR2,
    x_cs2_lname                         IN     VARCHAR2,
    x_cs2_fname                         IN     VARCHAR2,
    x_cs2_mi_txt                        IN     VARCHAR2,
    x_cs2_ssn_txt                       IN     VARCHAR2,
    x_cs2_citizenship_status            IN     VARCHAR2,
    x_cs2_address_line_1_txt            IN     VARCHAR2,
    x_cs2_address_line_2_txt            IN     VARCHAR2,
    x_cs2_city_txt                      IN     VARCHAR2,
    x_cs2_state_txt                     IN     VARCHAR2,
    x_cs2_zip_txt                       IN     VARCHAR2,
    x_cs2_zip_suffix_txt                IN     VARCHAR2,
    x_cs2_telephone_number_txt          IN     VARCHAR2,
    x_cs2_signature_code_txt            IN     VARCHAR2,
    x_cs1_credit_auth_code_txt          IN     VARCHAR2,
    x_cs1_birth_date                    IN     Date    ,
    x_cs1_drv_license_num_txt           IN     VARCHAR2,
    x_cs1_drv_license_state_txt         IN     VARCHAR2,
    x_cs1_elect_sig_ind_code_txt        IN     VARCHAR2,
    x_cs1_frgn_postal_code_txt          IN     VARCHAR2,
    x_cs1_frgn_tel_num_prefix_txt       IN     VARCHAR2,
    x_cs1_gross_annual_sal_num          IN     NUMBER  ,
    x_cs1_mthl_auto_pay_txt             IN     VARCHAR2,
    x_cs1_mthl_cc_pay_txt               IN     VARCHAR2,
    x_cs1_mthl_edu_loan_pay_txt         IN     VARCHAR2,
    x_cs1_mthl_housing_pay_txt          IN     VARCHAR2,
    x_cs1_mthl_other_pay_txt            IN     VARCHAR2,
    x_cs1_other_income_amt              IN     NUMBER  ,
    x_cs1_rel_to_student_flag           IN     VARCHAR2,
    x_cs1_suffix_txt                    IN     VARCHAR2,
    x_cs1_years_at_address_txt          IN     NUMBER  ,
    x_cs2_credit_auth_code_txt          IN     VARCHAR2,
    x_cs2_birth_date                    IN     Date    ,
    x_cs2_drv_license_num_txt           IN     VARCHAR2,
    x_cs2_drv_license_state_txt         IN     VARCHAR2,
    x_cs2_elect_sig_ind_code_txt        IN     VARCHAR2,
    x_cs2_frgn_postal_code_txt          IN     VARCHAR2,
    x_cs2_frgn_tel_num_prefix_txt       IN     VARCHAR2,
    x_cs2_gross_annual_sal_num          IN     NUMBER  ,
    x_cs2_mthl_auto_pay_txt             IN     VARCHAR2,
    x_cs2_mthl_cc_pay_txt               IN     VARCHAR2,
    x_cs2_mthl_edu_loan_pay_txt         IN     VARCHAR2,
    x_cs2_mthl_housing_pay_txt          IN     VARCHAR2,
    x_cs2_mthl_other_pay_txt            IN     VARCHAR2,
    x_cs2_other_income_amt              IN     NUMBER  ,
    x_cs2_rel_to_student_flag           IN     VARCHAR2,
    x_cs2_suffix_txt                    IN     VARCHAR2,
    x_cs2_years_at_address_txt          IN     NUMBER
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
      x_albw_id,
      x_loan_id,
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
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_other_loan_amt,
      x_cs1_lname,
      x_cs1_fname,
      x_cs1_mi_txt,
      x_cs1_ssn_txt,
      x_cs1_citizenship_status,
      x_cs1_address_line_1_txt,
      x_cs1_address_line_2_txt,
      x_cs1_city_txt,
      x_cs1_state_txt,
      x_cs1_zip_txt,
      x_cs1_zip_suffix_txt,
      x_cs1_telephone_number_txt,
      x_cs1_signature_code_txt,
      x_cs2_lname,
      x_cs2_fname,
      x_cs2_mi_txt,
      x_cs2_ssn_txt,
      x_cs2_citizenship_status,
      x_cs2_address_line_1_txt,
      x_cs2_address_line_2_txt,
      x_cs2_city_txt,
      x_cs2_state_txt,
      x_cs2_zip_txt,
      x_cs2_zip_suffix_txt,
      x_cs2_telephone_number_txt,
      x_cs2_signature_code_txt,
      x_cs1_credit_auth_code_txt,
      x_cs1_birth_date,
      x_cs1_drv_license_num_txt,
      x_cs1_drv_license_state_txt,
      x_cs1_elect_sig_ind_code_txt,
      x_cs1_frgn_postal_code_txt,
      x_cs1_frgn_tel_num_prefix_txt,
      x_cs1_gross_annual_sal_num,
      x_cs1_mthl_auto_pay_txt,
      x_cs1_mthl_cc_pay_txt,
      x_cs1_mthl_edu_loan_pay_txt,
      x_cs1_mthl_housing_pay_txt,
      x_cs1_mthl_other_pay_txt,
      x_cs1_other_income_amt,
      x_cs1_rel_to_student_flag,
      x_cs1_suffix_txt,
      x_cs1_years_at_address_txt,
      x_cs2_credit_auth_code_txt,
      x_cs2_birth_date,
      x_cs2_drv_license_num_txt,
      x_cs2_drv_license_state_txt,
      x_cs2_elect_sig_ind_code_txt,
      x_cs2_frgn_postal_code_txt,
      x_cs2_frgn_tel_num_prefix_txt,
      x_cs2_gross_annual_sal_num,
      x_cs2_mthl_auto_pay_txt,
      x_cs2_mthl_cc_pay_txt,
      x_cs2_mthl_edu_loan_pay_txt,
      x_cs2_mthl_housing_pay_txt,
      x_cs2_mthl_other_pay_txt,
      x_cs2_other_income_amt,
      x_cs2_rel_to_student_flag,
      x_cs2_suffix_txt,
      x_cs2_years_at_address_txt
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation( new_references.albw_id ) ) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation ( new_references.albw_id ) ) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_albw_id                           IN OUT NOCOPY NUMBER,
    x_loan_id                           IN     NUMBER,
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
    x_mode                              IN     VARCHAR2,
    x_other_loan_amt                    IN     NUMBER,
    x_cs1_lname                         IN     VARCHAR2,
    x_cs1_fname                         IN     VARCHAR2,
    x_cs1_mi_txt                        IN     VARCHAR2,
    x_cs1_ssn_txt                       IN     VARCHAR2,
    x_cs1_citizenship_status            IN     VARCHAR2,
    x_cs1_address_line_1_txt            IN     VARCHAR2,
    x_cs1_address_line_2_txt            IN     VARCHAR2,
    x_cs1_city_txt                      IN     VARCHAR2,
    x_cs1_state_txt                     IN     VARCHAR2,
    x_cs1_zip_txt                       IN     VARCHAR2,
    x_cs1_zip_suffix_txt                IN     VARCHAR2,
    x_cs1_telephone_number_txt          IN     VARCHAR2,
    x_cs1_signature_code_txt            IN     VARCHAR2,
    x_cs2_lname                         IN     VARCHAR2,
    x_cs2_fname                         IN     VARCHAR2,
    x_cs2_mi_txt                        IN     VARCHAR2,
    x_cs2_ssn_txt                       IN     VARCHAR2,
    x_cs2_citizenship_status            IN     VARCHAR2,
    x_cs2_address_line_1_txt            IN     VARCHAR2,
    x_cs2_address_line_2_txt            IN     VARCHAR2,
    x_cs2_city_txt                      IN     VARCHAR2,
    x_cs2_state_txt                     IN     VARCHAR2,
    x_cs2_zip_txt                       IN     VARCHAR2,
    x_cs2_zip_suffix_txt                IN     VARCHAR2,
    x_cs2_telephone_number_txt          IN     VARCHAR2,
    x_cs2_signature_code_txt            IN     VARCHAR2,
    x_cs1_credit_auth_code_txt          IN     VARCHAR2,
    x_cs1_birth_date                    IN     Date    ,
    x_cs1_drv_license_num_txt           IN     VARCHAR2,
    x_cs1_drv_license_state_txt         IN     VARCHAR2,
    x_cs1_elect_sig_ind_code_txt        IN     VARCHAR2,
    x_cs1_frgn_postal_code_txt          IN     VARCHAR2,
    x_cs1_frgn_tel_num_prefix_txt       IN     VARCHAR2,
    x_cs1_gross_annual_sal_num          IN     NUMBER  ,
    x_cs1_mthl_auto_pay_txt             IN     VARCHAR2,
    x_cs1_mthl_cc_pay_txt               IN     VARCHAR2,
    x_cs1_mthl_edu_loan_pay_txt         IN     VARCHAR2,
    x_cs1_mthl_housing_pay_txt          IN     VARCHAR2,
    x_cs1_mthl_other_pay_txt            IN     VARCHAR2,
    x_cs1_other_income_amt              IN     NUMBER  ,
    x_cs1_rel_to_student_flag           IN     VARCHAR2,
    x_cs1_suffix_txt                    IN     VARCHAR2,
    x_cs1_years_at_address_txt          IN     NUMBER  ,
    x_cs2_credit_auth_code_txt          IN     VARCHAR2,
    x_cs2_birth_date                    IN     Date    ,
    x_cs2_drv_license_num_txt           IN     VARCHAR2,
    x_cs2_drv_license_state_txt         IN     VARCHAR2,
    x_cs2_elect_sig_ind_code_txt        IN     VARCHAR2,
    x_cs2_frgn_postal_code_txt          IN     VARCHAR2,
    x_cs2_frgn_tel_num_prefix_txt       IN     VARCHAR2,
    x_cs2_gross_annual_sal_num          IN     NUMBER  ,
    x_cs2_mthl_auto_pay_txt             IN     VARCHAR2,
    x_cs2_mthl_cc_pay_txt               IN     VARCHAR2,
    x_cs2_mthl_edu_loan_pay_txt         IN     VARCHAR2,
    x_cs2_mthl_housing_pay_txt          IN     VARCHAR2,
    x_cs2_mthl_other_pay_txt            IN     VARCHAR2,
    x_cs2_other_income_amt              IN     NUMBER  ,
    x_cs2_rel_to_student_flag           IN     VARCHAR2,
    x_cs2_suffix_txt                    IN     VARCHAR2,
    x_cs2_years_at_address_txt          IN     NUMBER
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
       SELECT rowid
       FROM   igf_sl_alt_borw_all
       WHERE  albw_id  = x_albw_id;

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
      x_request_id             := FND_GLOBAL.CONC_REQUEST_ID;
      x_program_id             := FND_GLOBAL.CONC_PROGRAM_ID;
      x_program_application_id := FND_GLOBAL.PROG_APPL_ID;

      IF (x_request_id = -1) THEN
        x_request_id             := NULL;
        x_program_id             := NULL;
        x_program_application_id := NULL;
        x_program_update_date    := NULL;
      ELSE
        x_program_update_date    := SYSDATE;
      END IF;
    ELSE
      FND_MESSAGE.SET_NAME ('FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    SELECT    igf_sl_alt_borw_all_s.NEXTVAL
    INTO      x_albw_id
    FROM      dual;

    new_references.org_id := igs_ge_gen_003.get_org_id;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_albw_id                           => x_albw_id,
      x_loan_id                           => x_loan_id,
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
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_other_loan_amt                    => x_other_loan_amt,
      x_cs1_lname                         => x_cs1_lname                                       ,
      x_cs1_fname                         => x_cs1_fname                                       ,
      x_cs1_mi_txt                        => x_cs1_mi_txt                                      ,
      x_cs1_ssn_txt                       => x_cs1_ssn_txt                                     ,
      x_cs1_citizenship_status            => x_cs1_citizenship_status                          ,
      x_cs1_address_line_1_txt            => x_cs1_address_line_1_txt                          ,
      x_cs1_address_line_2_txt            => x_cs1_address_line_2_txt                          ,
      x_cs1_city_txt                      => x_cs1_city_txt                                    ,
      x_cs1_state_txt                     => x_cs1_state_txt                                   ,
      x_cs1_zip_txt                       => x_cs1_zip_txt                                     ,
      x_cs1_zip_suffix_txt                => x_cs1_zip_suffix_txt                              ,
      x_cs1_telephone_number_txt          => x_cs1_telephone_number_txt                        ,
      x_cs1_signature_code_txt            => x_cs1_signature_code_txt                          ,
      x_cs2_lname                         => x_cs2_lname                                       ,
      x_cs2_fname                         => x_cs2_fname                                       ,
      x_cs2_mi_txt                        => x_cs2_mi_txt                                      ,
      x_cs2_ssn_txt                       => x_cs2_ssn_txt                                     ,
      x_cs2_citizenship_status            => x_cs2_citizenship_status                          ,
      x_cs2_address_line_1_txt            => x_cs2_address_line_1_txt                          ,
      x_cs2_address_line_2_txt            => x_cs2_address_line_2_txt                          ,
      x_cs2_city_txt                      => x_cs2_city_txt                                    ,
      x_cs2_state_txt                     => x_cs2_state_txt                                   ,
      x_cs2_zip_txt                       => x_cs2_zip_txt                                     ,
      x_cs2_zip_suffix_txt                => x_cs2_zip_suffix_txt                              ,
      x_cs2_telephone_number_txt          => x_cs2_telephone_number_txt                        ,
      x_cs2_signature_code_txt            => x_cs2_signature_code_txt                          ,
      x_cs1_credit_auth_code_txt          => x_cs1_credit_auth_code_txt                        ,
      x_cs1_birth_date                    => x_cs1_birth_date                                  ,
      x_cs1_drv_license_num_txt           => x_cs1_drv_license_num_txt                         ,
      x_cs1_drv_license_state_txt         => x_cs1_drv_license_state_txt                       ,
      x_cs1_elect_sig_ind_code_txt        => x_cs1_elect_sig_ind_code_txt                      ,
      x_cs1_frgn_postal_code_txt          => x_cs1_frgn_postal_code_txt                        ,
      x_cs1_frgn_tel_num_prefix_txt       => x_cs1_frgn_tel_num_prefix_txt                     ,
      x_cs1_gross_annual_sal_num          => x_cs1_gross_annual_sal_num                        ,
      x_cs1_mthl_auto_pay_txt             => x_cs1_mthl_auto_pay_txt                           ,
      x_cs1_mthl_cc_pay_txt               => x_cs1_mthl_cc_pay_txt                             ,
      x_cs1_mthl_edu_loan_pay_txt         => x_cs1_mthl_edu_loan_pay_txt                       ,
      x_cs1_mthl_housing_pay_txt          => x_cs1_mthl_housing_pay_txt                        ,
      x_cs1_mthl_other_pay_txt            => x_cs1_mthl_other_pay_txt                          ,
      x_cs1_other_income_amt              => x_cs1_other_income_amt                            ,
      x_cs1_rel_to_student_flag           => x_cs1_rel_to_student_flag                         ,
      x_cs1_suffix_txt                    => x_cs1_suffix_txt                                  ,
      x_cs1_years_at_address_txt          => x_cs1_years_at_address_txt                        ,
      x_cs2_credit_auth_code_txt          => x_cs2_credit_auth_code_txt                        ,
      x_cs2_birth_date                    => x_cs2_birth_date                                  ,
      x_cs2_drv_license_num_txt           => x_cs2_drv_license_num_txt                         ,
      x_cs2_drv_license_state_txt         => x_cs2_drv_license_state_txt                       ,
      x_cs2_elect_sig_ind_code_txt        => x_cs2_elect_sig_ind_code_txt                      ,
      x_cs2_frgn_postal_code_txt          => x_cs2_frgn_postal_code_txt                        ,
      x_cs2_frgn_tel_num_prefix_txt       => x_cs2_frgn_tel_num_prefix_txt                     ,
      x_cs2_gross_annual_sal_num          => x_cs2_gross_annual_sal_num                        ,
      x_cs2_mthl_auto_pay_txt             => x_cs2_mthl_auto_pay_txt                           ,
      x_cs2_mthl_cc_pay_txt               => x_cs2_mthl_cc_pay_txt                             ,
      x_cs2_mthl_edu_loan_pay_txt         => x_cs2_mthl_edu_loan_pay_txt                       ,
      x_cs2_mthl_housing_pay_txt          => x_cs2_mthl_housing_pay_txt                        ,
      x_cs2_mthl_other_pay_txt            => x_cs2_mthl_other_pay_txt                          ,
      x_cs2_other_income_amt              => x_cs2_other_income_amt                            ,
      x_cs2_rel_to_student_flag           => x_cs2_rel_to_student_flag                         ,
      x_cs2_suffix_txt                    => x_cs2_suffix_txt                                  ,
      x_cs2_years_at_address_txt          => x_cs2_years_at_address_txt
    );

    INSERT INTO igf_sl_alt_borw_all (
      albw_id,
      loan_id,
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
      org_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      other_loan_amt,
      cs1_lname,
      cs1_fname,
      cs1_mi_txt,
      cs1_ssn_txt,
      cs1_citizenship_status,
      cs1_address_line_1_txt,
      cs1_address_line_2_txt,
      cs1_city_txt,
      cs1_state_txt,
      cs1_zip_txt,
      cs1_zip_suffix_txt,
      cs1_telephone_number_txt,
      cs1_signature_code_txt,
      cs2_lname,
      cs2_fname,
      cs2_mi_txt,
      cs2_ssn_txt,
      cs2_citizenship_status,
      cs2_address_line_1_txt,
      cs2_address_line_2_txt,
      cs2_city_txt,
      cs2_state_txt,
      cs2_zip_txt,
      cs2_zip_suffix_txt,
      cs2_telephone_number_txt,
      cs2_signature_code_txt,
      cs1_credit_auth_code_txt,
      cs1_birth_date,
      cs1_drv_license_num_txt,
      cs1_drv_license_state_txt,
      cs1_elect_sig_ind_code_txt,
      cs1_frgn_postal_code_txt,
      cs1_frgn_tel_num_prefix_txt,
      cs1_gross_annual_sal_num,
      cs1_mthl_auto_pay_txt,
      cs1_mthl_cc_pay_txt,
      cs1_mthl_edu_loan_pay_txt,
      cs1_mthl_housing_pay_txt,
      cs1_mthl_other_pay_txt,
      cs1_other_income_amt,
      cs1_rel_to_student_flag,
      cs1_suffix_txt,
      cs1_years_at_address_txt,
      cs2_credit_auth_code_txt,
      cs2_birth_date,
      cs2_drv_license_num_txt,
      cs2_drv_license_state_txt,
      cs2_elect_sig_ind_code_txt,
      cs2_frgn_postal_code_txt,
      cs2_frgn_tel_num_prefix_txt,
      cs2_gross_annual_sal_num,
      cs2_mthl_auto_pay_txt,
      cs2_mthl_cc_pay_txt,
      cs2_mthl_edu_loan_pay_txt,
      cs2_mthl_housing_pay_txt,
      cs2_mthl_other_pay_txt,
      cs2_other_income_amt,
      cs2_rel_to_student_flag,
      cs2_suffix_txt,
      cs2_years_at_address_txt
    ) VALUES (
      new_references.albw_id,
      new_references.loan_id,
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
      new_references.org_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
      new_references.other_loan_amt,
      new_references.cs1_lname,
      new_references.cs1_fname,
      new_references.cs1_mi_txt,
      new_references.cs1_ssn_txt,
      new_references.cs1_citizenship_status,
      new_references.cs1_address_line_1_txt,
      new_references.cs1_address_line_2_txt,
      new_references.cs1_city_txt,
      new_references.cs1_state_txt,
      new_references.cs1_zip_txt,
      new_references.cs1_zip_suffix_txt,
      new_references.cs1_telephone_number_txt,
      new_references.cs1_signature_code_txt,
      new_references.cs2_lname,
      new_references.cs2_fname,
      new_references.cs2_mi_txt,
      new_references.cs2_ssn_txt,
      new_references.cs2_citizenship_status,
      new_references.cs2_address_line_1_txt,
      new_references.cs2_address_line_2_txt,
      new_references.cs2_city_txt,
      new_references.cs2_state_txt,
      new_references.cs2_zip_txt,
      new_references.cs2_zip_suffix_txt,
      new_references.cs2_telephone_number_txt,
      new_references.cs2_signature_code_txt,
      new_references.cs1_credit_auth_code_txt,
      new_references.cs1_birth_date,
      new_references.cs1_drv_license_num_txt,
      new_references.cs1_drv_license_state_txt,
      new_references.cs1_elect_sig_ind_code_txt,
      new_references.cs1_frgn_postal_code_txt,
      new_references.cs1_frgn_tel_num_prefix_txt,
      new_references.cs1_gross_annual_sal_num,
      new_references.cs1_mthl_auto_pay_txt,
      new_references.cs1_mthl_cc_pay_txt,
      new_references.cs1_mthl_edu_loan_pay_txt,
      new_references.cs1_mthl_housing_pay_txt,
      new_references.cs1_mthl_other_pay_txt,
      new_references.cs1_other_income_amt,
      new_references.cs1_rel_to_student_flag,
      new_references.cs1_suffix_txt,
      new_references.cs1_years_at_address_txt,
      new_references.cs2_credit_auth_code_txt,
      new_references.cs2_birth_date,
      new_references.cs2_drv_license_num_txt,
      new_references.cs2_drv_license_state_txt,
      new_references.cs2_elect_sig_ind_code_txt,
      new_references.cs2_frgn_postal_code_txt,
      new_references.cs2_frgn_tel_num_prefix_txt,
      new_references.cs2_gross_annual_sal_num,
      new_references.cs2_mthl_auto_pay_txt,
      new_references.cs2_mthl_cc_pay_txt,
      new_references.cs2_mthl_edu_loan_pay_txt,
      new_references.cs2_mthl_housing_pay_txt,
      new_references.cs2_mthl_other_pay_txt,
      new_references.cs2_other_income_amt,
      new_references.cs2_rel_to_student_flag,
      new_references.cs2_suffix_txt,
      new_references.cs2_years_at_address_txt
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
    x_albw_id                           IN     NUMBER,
    x_loan_id                           IN     NUMBER,
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
    x_other_loan_amt                    IN     NUMBER,
    x_cs1_lname                         IN     VARCHAR2,
    x_cs1_fname                         IN     VARCHAR2,
    x_cs1_mi_txt                        IN     VARCHAR2,
    x_cs1_ssn_txt                       IN     VARCHAR2,
    x_cs1_citizenship_status            IN     VARCHAR2,
    x_cs1_address_line_1_txt            IN     VARCHAR2,
    x_cs1_address_line_2_txt            IN     VARCHAR2,
    x_cs1_city_txt                      IN     VARCHAR2,
    x_cs1_state_txt                     IN     VARCHAR2,
    x_cs1_zip_txt                       IN     VARCHAR2,
    x_cs1_zip_suffix_txt                IN     VARCHAR2,
    x_cs1_telephone_number_txt          IN     VARCHAR2,
    x_cs1_signature_code_txt            IN     VARCHAR2,
    x_cs2_lname                         IN     VARCHAR2,
    x_cs2_fname                         IN     VARCHAR2,
    x_cs2_mi_txt                        IN     VARCHAR2,
    x_cs2_ssn_txt                       IN     VARCHAR2,
    x_cs2_citizenship_status            IN     VARCHAR2,
    x_cs2_address_line_1_txt            IN     VARCHAR2,
    x_cs2_address_line_2_txt            IN     VARCHAR2,
    x_cs2_city_txt                      IN     VARCHAR2,
    x_cs2_state_txt                     IN     VARCHAR2,
    x_cs2_zip_txt                       IN     VARCHAR2,
    x_cs2_zip_suffix_txt                IN     VARCHAR2,
    x_cs2_telephone_number_txt          IN     VARCHAR2,
    x_cs2_signature_code_txt            IN     VARCHAR2,
    x_cs1_credit_auth_code_txt          IN     VARCHAR2,
    x_cs1_birth_date                    IN     Date    ,
    x_cs1_drv_license_num_txt           IN     VARCHAR2,
    x_cs1_drv_license_state_txt         IN     VARCHAR2,
    x_cs1_elect_sig_ind_code_txt        IN     VARCHAR2,
    x_cs1_frgn_postal_code_txt          IN     VARCHAR2,
    x_cs1_frgn_tel_num_prefix_txt       IN     VARCHAR2,
    x_cs1_gross_annual_sal_num          IN     NUMBER  ,
    x_cs1_mthl_auto_pay_txt             IN     VARCHAR2,
    x_cs1_mthl_cc_pay_txt               IN     VARCHAR2,
    x_cs1_mthl_edu_loan_pay_txt         IN     VARCHAR2,
    x_cs1_mthl_housing_pay_txt          IN     VARCHAR2,
    x_cs1_mthl_other_pay_txt            IN     VARCHAR2,
    x_cs1_other_income_amt              IN     NUMBER  ,
    x_cs1_rel_to_student_flag           IN     VARCHAR2,
    x_cs1_suffix_txt                    IN     VARCHAR2,
    x_cs1_years_at_address_txt          IN     NUMBER  ,
    x_cs2_credit_auth_code_txt          IN     VARCHAR2,
    x_cs2_birth_date                    IN     Date    ,
    x_cs2_drv_license_num_txt           IN     VARCHAR2,
    x_cs2_drv_license_state_txt         IN     VARCHAR2,
    x_cs2_elect_sig_ind_code_txt        IN     VARCHAR2,
    x_cs2_frgn_postal_code_txt          IN     VARCHAR2,
    x_cs2_frgn_tel_num_prefix_txt       IN     VARCHAR2,
    x_cs2_gross_annual_sal_num          IN     NUMBER  ,
    x_cs2_mthl_auto_pay_txt             IN     VARCHAR2,
    x_cs2_mthl_cc_pay_txt               IN     VARCHAR2,
    x_cs2_mthl_edu_loan_pay_txt         IN     VARCHAR2,
    x_cs2_mthl_housing_pay_txt          IN     VARCHAR2,
    x_cs2_mthl_other_pay_txt            IN     VARCHAR2,
    x_cs2_other_income_amt              IN     NUMBER  ,
    x_cs2_rel_to_student_flag           IN     VARCHAR2,
    x_cs2_suffix_txt                    IN     VARCHAR2,
    x_cs2_years_at_address_txt          IN     NUMBER
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
        loan_id,
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
        other_loan_amt,
        cs1_lname,
        cs1_fname,
        cs1_mi_txt,
        cs1_ssn_txt,
        cs1_citizenship_status,
        cs1_address_line_1_txt,
        cs1_address_line_2_txt,
        cs1_city_txt,
        cs1_state_txt,
        cs1_zip_txt,
        cs1_zip_suffix_txt,
        cs1_telephone_number_txt,
        cs1_signature_code_txt,
        cs2_lname,
        cs2_fname,
        cs2_mi_txt,
        cs2_ssn_txt,
        cs2_citizenship_status,
        cs2_address_line_1_txt,
        cs2_address_line_2_txt,
        cs2_city_txt,
        cs2_state_txt,
        cs2_zip_txt,
        cs2_zip_suffix_txt,
        cs2_telephone_number_txt,
        cs2_signature_code_txt,
        cs1_credit_auth_code_txt,
        cs1_birth_date,
        cs1_drv_license_num_txt,
        cs1_drv_license_state_txt,
        cs1_elect_sig_ind_code_txt,
        cs1_frgn_postal_code_txt,
        cs1_frgn_tel_num_prefix_txt,
        cs1_gross_annual_sal_num,
        cs1_mthl_auto_pay_txt,
        cs1_mthl_cc_pay_txt,
        cs1_mthl_edu_loan_pay_txt,
        cs1_mthl_housing_pay_txt,
        cs1_mthl_other_pay_txt,
        cs1_other_income_amt,
        cs1_rel_to_student_flag,
        cs1_suffix_txt,
        cs1_years_at_address_txt,
        cs2_credit_auth_code_txt,
        cs2_birth_date,
        cs2_drv_license_num_txt,
        cs2_drv_license_state_txt,
        cs2_elect_sig_ind_code_txt,
        cs2_frgn_postal_code_txt,
        cs2_frgn_tel_num_prefix_txt,
        cs2_gross_annual_sal_num,
        cs2_mthl_auto_pay_txt,
        cs2_mthl_cc_pay_txt,
        cs2_mthl_edu_loan_pay_txt,
        cs2_mthl_housing_pay_txt,
        cs2_mthl_other_pay_txt,
        cs2_other_income_amt,
        cs2_rel_to_student_flag,
        cs2_suffix_txt,
        cs2_years_at_address_txt
      FROM  igf_sl_alt_borw_all
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      CLOSE c1;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.loan_id = x_loan_id)
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
        AND ((tlinfo.other_loan_amt = x_other_loan_amt) OR ((tlinfo.other_loan_amt IS NULL) AND (x_other_loan_amt IS NULL)))
        AND ((tlinfo.cs1_lname = x_cs1_lname) OR ((tlinfo.cs1_lname IS NULL) AND (x_cs1_lname IS NULL)))
        AND ((tlinfo.cs1_fname = x_cs1_fname) OR ((tlinfo.cs1_fname IS NULL) AND (x_cs1_fname IS NULL)))
        AND ((tlinfo.cs1_mi_txt = x_cs1_mi_txt) OR ((tlinfo.cs1_mi_txt IS NULL) AND (x_cs1_mi_txt IS NULL)))
        AND ((tlinfo.cs1_ssn_txt = x_cs1_ssn_txt) OR ((tlinfo.cs1_ssn_txt IS NULL) AND (x_cs1_ssn_txt IS NULL)))
        AND ((tlinfo.cs1_citizenship_status = x_cs1_citizenship_status) OR ((tlinfo.cs1_citizenship_status IS NULL) AND (x_cs1_citizenship_status IS NULL)))
        AND ((tlinfo.cs1_address_line_1_txt = x_cs1_address_line_1_txt) OR ((tlinfo.cs1_address_line_1_txt IS NULL) AND (x_cs1_address_line_1_txt IS NULL)))
        AND ((tlinfo.cs1_address_line_2_txt = x_cs1_address_line_2_txt) OR ((tlinfo.cs1_address_line_2_txt IS NULL) AND (x_cs1_address_line_2_txt IS NULL)))
        AND ((tlinfo.cs1_city_txt = x_cs1_city_txt) OR ((tlinfo.cs1_city_txt IS NULL) AND (x_cs1_city_txt IS NULL)))
        AND ((tlinfo.cs1_state_txt = x_cs1_state_txt) OR ((tlinfo.cs1_state_txt IS NULL) AND (x_cs1_state_txt IS NULL)))
        AND ((tlinfo.cs1_zip_txt = x_cs1_zip_txt) OR ((tlinfo.cs1_zip_txt IS NULL) AND (x_cs1_zip_txt IS NULL)))
        AND ((tlinfo.cs1_zip_suffix_txt = x_cs1_zip_suffix_txt) OR ((tlinfo.cs1_zip_suffix_txt IS NULL) AND (x_cs1_zip_suffix_txt IS NULL)))
        AND ((tlinfo.cs1_telephone_number_txt = x_cs1_telephone_number_txt) OR ((tlinfo.cs1_telephone_number_txt IS NULL) AND (x_cs1_telephone_number_txt IS NULL)))
        AND ((tlinfo.cs1_signature_code_txt = x_cs1_signature_code_txt) OR ((tlinfo.cs1_signature_code_txt IS NULL) AND (x_cs1_signature_code_txt IS NULL)))
        AND ((tlinfo.cs2_lname = x_cs2_lname) OR ((tlinfo.cs2_lname IS NULL) AND (x_cs2_lname IS NULL)))
        AND ((tlinfo.cs2_fname = x_cs2_fname) OR ((tlinfo.cs2_fname IS NULL) AND (x_cs2_fname IS NULL)))
        AND ((tlinfo.cs2_mi_txt = x_cs2_mi_txt) OR ((tlinfo.cs2_mi_txt IS NULL) AND (x_cs2_mi_txt IS NULL)))
        AND ((tlinfo.cs2_ssn_txt = x_cs2_ssn_txt) OR ((tlinfo.cs2_ssn_txt IS NULL) AND (x_cs2_ssn_txt IS NULL)))
        AND ((tlinfo.cs2_citizenship_status = x_cs2_citizenship_status) OR ((tlinfo.cs2_citizenship_status IS NULL) AND (x_cs2_citizenship_status IS NULL)))
        AND ((tlinfo.cs2_address_line_1_txt = x_cs2_address_line_1_txt) OR ((tlinfo.cs2_address_line_1_txt IS NULL) AND (x_cs2_address_line_1_txt IS NULL)))
        AND ((tlinfo.cs2_address_line_2_txt = x_cs2_address_line_2_txt) OR ((tlinfo.cs2_address_line_2_txt IS NULL) AND (x_cs2_address_line_2_txt IS NULL)))
        AND ((tlinfo.cs2_city_txt = x_cs2_city_txt) OR ((tlinfo.cs2_city_txt IS NULL) AND (x_cs2_city_txt IS NULL)))
        AND ((tlinfo.cs2_state_txt = x_cs2_state_txt) OR ((tlinfo.cs2_state_txt IS NULL) AND (x_cs2_state_txt IS NULL)))
        AND ((tlinfo.cs2_zip_txt = x_cs2_zip_txt) OR ((tlinfo.cs2_zip_txt IS NULL) AND (x_cs2_zip_txt IS NULL)))
        AND ((tlinfo.cs2_zip_suffix_txt = x_cs2_zip_suffix_txt) OR ((tlinfo.cs2_zip_suffix_txt IS NULL) AND (x_cs2_zip_suffix_txt IS NULL)))
        AND ((tlinfo.cs2_telephone_number_txt = x_cs2_telephone_number_txt) OR ((tlinfo.cs2_telephone_number_txt IS NULL) AND (x_cs2_telephone_number_txt IS NULL)))
        AND ((tlinfo.cs2_signature_code_txt = x_cs2_signature_code_txt) OR ((tlinfo.cs2_signature_code_txt IS NULL) AND (x_cs2_signature_code_txt IS NULL)))
        AND ((tlinfo.cs1_credit_auth_code_txt = x_cs1_credit_auth_code_txt) OR ((tlinfo.cs1_credit_auth_code_txt IS NULL) AND (x_cs1_credit_auth_code_txt IS NULL)))
        AND ((tlinfo.cs1_birth_date = x_cs1_birth_date) OR ((tlinfo.cs1_birth_date IS NULL) AND (x_cs1_birth_date IS NULL)))
        AND ((tlinfo.cs1_drv_license_num_txt = x_cs1_drv_license_num_txt) OR ((tlinfo.cs1_drv_license_num_txt IS NULL) AND (x_cs1_drv_license_num_txt IS NULL)))
        AND ((tlinfo.cs1_drv_license_state_txt = x_cs1_drv_license_state_txt) OR ((tlinfo.cs1_drv_license_state_txt IS NULL) AND (x_cs1_drv_license_state_txt IS NULL)))
        AND ((tlinfo.cs1_elect_sig_ind_code_txt = x_cs1_elect_sig_ind_code_txt) OR ((tlinfo.cs1_elect_sig_ind_code_txt IS NULL) AND (x_cs1_elect_sig_ind_code_txt IS NULL)))
        AND ((tlinfo.cs1_frgn_postal_code_txt = x_cs1_frgn_postal_code_txt) OR ((tlinfo.cs1_frgn_postal_code_txt IS NULL) AND (x_cs1_frgn_postal_code_txt IS NULL)))
        AND ((tlinfo.cs1_frgn_tel_num_prefix_txt = x_cs1_frgn_tel_num_prefix_txt) OR ((tlinfo.cs1_frgn_tel_num_prefix_txt IS NULL) AND (x_cs1_frgn_tel_num_prefix_txt IS NULL)))
        AND ((tlinfo.cs1_gross_annual_sal_num = x_cs1_gross_annual_sal_num) OR ((tlinfo.cs1_gross_annual_sal_num IS NULL) AND (x_cs1_gross_annual_sal_num IS NULL)))
        AND ((tlinfo.cs1_mthl_auto_pay_txt = x_cs1_mthl_auto_pay_txt) OR ((tlinfo.cs1_mthl_auto_pay_txt IS NULL) AND (x_cs1_mthl_auto_pay_txt IS NULL)))
        AND ((tlinfo.cs1_mthl_cc_pay_txt = x_cs1_mthl_cc_pay_txt) OR ((tlinfo.cs1_mthl_cc_pay_txt IS NULL) AND (x_cs1_mthl_cc_pay_txt IS NULL)))
        AND ((tlinfo.cs1_mthl_edu_loan_pay_txt = x_cs1_mthl_edu_loan_pay_txt) OR ((tlinfo.cs1_mthl_edu_loan_pay_txt IS NULL) AND (x_cs1_mthl_edu_loan_pay_txt IS NULL)))
        AND ((tlinfo.cs1_mthl_housing_pay_txt = x_cs1_mthl_housing_pay_txt) OR ((tlinfo.cs1_mthl_housing_pay_txt IS NULL) AND (x_cs1_mthl_housing_pay_txt IS NULL)))
        AND ((tlinfo.cs1_mthl_other_pay_txt = x_cs1_mthl_other_pay_txt) OR ((tlinfo.cs1_mthl_other_pay_txt IS NULL) AND (x_cs1_mthl_other_pay_txt IS NULL)))
        AND ((tlinfo.cs1_other_income_amt = x_cs1_other_income_amt) OR ((tlinfo.cs1_other_income_amt IS NULL) AND (x_cs1_other_income_amt IS NULL)))
        AND ((tlinfo.cs1_rel_to_student_flag = x_cs1_rel_to_student_flag) OR ((tlinfo.cs1_rel_to_student_flag IS NULL) AND (x_cs1_rel_to_student_flag IS NULL)))
        AND ((tlinfo.cs1_suffix_txt = x_cs1_suffix_txt) OR ((tlinfo.cs1_suffix_txt IS NULL) AND (x_cs1_suffix_txt IS NULL)))
        AND ((tlinfo.cs1_years_at_address_txt = x_cs1_years_at_address_txt) OR ((tlinfo.cs1_years_at_address_txt IS NULL) AND (x_cs1_years_at_address_txt IS NULL)))
        AND ((tlinfo.cs2_credit_auth_code_txt = x_cs2_credit_auth_code_txt) OR ((tlinfo.cs2_credit_auth_code_txt IS NULL) AND (x_cs2_credit_auth_code_txt IS NULL)))
        AND ((tlinfo.cs2_birth_date = x_cs2_birth_date) OR ((tlinfo.cs2_birth_date IS NULL) AND (x_cs2_birth_date IS NULL)))
        AND ((tlinfo.cs2_drv_license_num_txt = x_cs2_drv_license_num_txt) OR ((tlinfo.cs2_drv_license_num_txt IS NULL) AND (x_cs2_drv_license_num_txt IS NULL)))
        AND ((tlinfo.cs2_drv_license_state_txt = x_cs2_drv_license_state_txt) OR ((tlinfo.cs2_drv_license_state_txt IS NULL) AND (x_cs2_drv_license_state_txt IS NULL)))
        AND ((tlinfo.cs2_elect_sig_ind_code_txt = x_cs2_elect_sig_ind_code_txt) OR ((tlinfo.cs2_elect_sig_ind_code_txt IS NULL) AND (x_cs2_elect_sig_ind_code_txt IS NULL)))
        AND ((tlinfo.cs2_frgn_postal_code_txt = x_cs2_frgn_postal_code_txt) OR ((tlinfo.cs2_frgn_postal_code_txt IS NULL) AND (x_cs2_frgn_postal_code_txt IS NULL)))
        AND ((tlinfo.cs2_frgn_tel_num_prefix_txt = x_cs2_frgn_tel_num_prefix_txt) OR ((tlinfo.cs2_frgn_tel_num_prefix_txt IS NULL) AND (x_cs2_frgn_tel_num_prefix_txt IS NULL)))
        AND ((tlinfo.cs2_gross_annual_sal_num = x_cs2_gross_annual_sal_num) OR ((tlinfo.cs2_gross_annual_sal_num IS NULL) AND (x_cs2_gross_annual_sal_num IS NULL)))
        AND ((tlinfo.cs2_mthl_auto_pay_txt = x_cs2_mthl_auto_pay_txt) OR ((tlinfo.cs2_mthl_auto_pay_txt IS NULL) AND (x_cs2_mthl_auto_pay_txt IS NULL)))
        AND ((tlinfo.cs2_mthl_cc_pay_txt = x_cs2_mthl_cc_pay_txt) OR ((tlinfo.cs2_mthl_cc_pay_txt IS NULL) AND (x_cs2_mthl_cc_pay_txt IS NULL)))
        AND ((tlinfo.cs2_mthl_edu_loan_pay_txt = x_cs2_mthl_edu_loan_pay_txt) OR ((tlinfo.cs2_mthl_edu_loan_pay_txt IS NULL) AND (x_cs2_mthl_edu_loan_pay_txt IS NULL)))
        AND ((tlinfo.cs2_mthl_housing_pay_txt = x_cs2_mthl_housing_pay_txt) OR ((tlinfo.cs2_mthl_housing_pay_txt IS NULL) AND (x_cs2_mthl_housing_pay_txt IS NULL)))
        AND ((tlinfo.cs2_mthl_other_pay_txt = x_cs2_mthl_other_pay_txt) OR ((tlinfo.cs2_mthl_other_pay_txt IS NULL) AND (x_cs2_mthl_other_pay_txt IS NULL)))
        AND ((tlinfo.cs2_other_income_amt = x_cs2_other_income_amt) OR ((tlinfo.cs2_other_income_amt IS NULL) AND (x_cs2_other_income_amt IS NULL)))
        AND ((tlinfo.cs2_rel_to_student_flag = x_cs2_rel_to_student_flag) OR ((tlinfo.cs2_rel_to_student_flag IS NULL) AND (x_cs2_rel_to_student_flag IS NULL)))
        AND ((tlinfo.cs2_suffix_txt = x_cs2_suffix_txt) OR ((tlinfo.cs2_suffix_txt IS NULL) AND (x_cs2_suffix_txt IS NULL)))
        AND ((tlinfo.cs2_years_at_address_txt = x_cs2_years_at_address_txt) OR ((tlinfo.cs2_years_at_address_txt IS NULL) AND (x_cs2_years_at_address_txt IS NULL)))
    ) THEN
      NULL;
    ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_albw_id                           IN     NUMBER,
    x_loan_id                           IN     NUMBER,
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
    x_mode                              IN     VARCHAR2,
    x_other_loan_amt                    IN     NUMBER,
    x_cs1_lname                         IN     VARCHAR2,
    x_cs1_fname                         IN     VARCHAR2,
    x_cs1_mi_txt                        IN     VARCHAR2,
    x_cs1_ssn_txt                       IN     VARCHAR2,
    x_cs1_citizenship_status            IN     VARCHAR2,
    x_cs1_address_line_1_txt            IN     VARCHAR2,
    x_cs1_address_line_2_txt            IN     VARCHAR2,
    x_cs1_city_txt                      IN     VARCHAR2,
    x_cs1_state_txt                     IN     VARCHAR2,
    x_cs1_zip_txt                       IN     VARCHAR2,
    x_cs1_zip_suffix_txt                IN     VARCHAR2,
    x_cs1_telephone_number_txt          IN     VARCHAR2,
    x_cs1_signature_code_txt            IN     VARCHAR2,
    x_cs2_lname                         IN     VARCHAR2,
    x_cs2_fname                         IN     VARCHAR2,
    x_cs2_mi_txt                        IN     VARCHAR2,
    x_cs2_ssn_txt                       IN     VARCHAR2,
    x_cs2_citizenship_status            IN     VARCHAR2,
    x_cs2_address_line_1_txt            IN     VARCHAR2,
    x_cs2_address_line_2_txt            IN     VARCHAR2,
    x_cs2_city_txt                      IN     VARCHAR2,
    x_cs2_state_txt                     IN     VARCHAR2,
    x_cs2_zip_txt                       IN     VARCHAR2,
    x_cs2_zip_suffix_txt                IN     VARCHAR2,
    x_cs2_telephone_number_txt          IN     VARCHAR2,
    x_cs2_signature_code_txt            IN     VARCHAR2,
    x_cs1_credit_auth_code_txt          IN     VARCHAR2,
    x_cs1_birth_date                    IN     Date    ,
    x_cs1_drv_license_num_txt           IN     VARCHAR2,
    x_cs1_drv_license_state_txt         IN     VARCHAR2,
    x_cs1_elect_sig_ind_code_txt        IN     VARCHAR2,
    x_cs1_frgn_postal_code_txt          IN     VARCHAR2,
    x_cs1_frgn_tel_num_prefix_txt       IN     VARCHAR2,
    x_cs1_gross_annual_sal_num          IN     NUMBER  ,
    x_cs1_mthl_auto_pay_txt             IN     VARCHAR2,
    x_cs1_mthl_cc_pay_txt               IN     VARCHAR2,
    x_cs1_mthl_edu_loan_pay_txt         IN     VARCHAR2,
    x_cs1_mthl_housing_pay_txt          IN     VARCHAR2,
    x_cs1_mthl_other_pay_txt            IN     VARCHAR2,
    x_cs1_other_income_amt              IN     NUMBER  ,
    x_cs1_rel_to_student_flag           IN     VARCHAR2,
    x_cs1_suffix_txt                    IN     VARCHAR2,
    x_cs1_years_at_address_txt          IN     NUMBER  ,
    x_cs2_credit_auth_code_txt          IN     VARCHAR2,
    x_cs2_birth_date                    IN     Date    ,
    x_cs2_drv_license_num_txt           IN     VARCHAR2,
    x_cs2_drv_license_state_txt         IN     VARCHAR2,
    x_cs2_elect_sig_ind_code_txt        IN     VARCHAR2,
    x_cs2_frgn_postal_code_txt          IN     VARCHAR2,
    x_cs2_frgn_tel_num_prefix_txt       IN     VARCHAR2,
    x_cs2_gross_annual_sal_num          IN     NUMBER  ,
    x_cs2_mthl_auto_pay_txt             IN     VARCHAR2,
    x_cs2_mthl_cc_pay_txt               IN     VARCHAR2,
    x_cs2_mthl_edu_loan_pay_txt         IN     VARCHAR2,
    x_cs2_mthl_housing_pay_txt          IN     VARCHAR2,
    x_cs2_mthl_other_pay_txt            IN     VARCHAR2,
    x_cs2_other_income_amt              IN     NUMBER  ,
    x_cs2_rel_to_student_flag           IN     VARCHAR2,
    x_cs2_suffix_txt                    IN     VARCHAR2,
    x_cs2_years_at_address_txt          IN     NUMBER
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
      FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_albw_id                           => x_albw_id,
      x_loan_id                           => x_loan_id,
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
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_other_loan_amt                    => x_other_loan_amt,
      x_cs1_lname                         => x_cs1_lname                                       ,
      x_cs1_fname                         => x_cs1_fname                                       ,
      x_cs1_mi_txt                        => x_cs1_mi_txt                                      ,
      x_cs1_ssn_txt                       => x_cs1_ssn_txt                                     ,
      x_cs1_citizenship_status            => x_cs1_citizenship_status                          ,
      x_cs1_address_line_1_txt            => x_cs1_address_line_1_txt                          ,
      x_cs1_address_line_2_txt            => x_cs1_address_line_2_txt                          ,
      x_cs1_city_txt                      => x_cs1_city_txt                                    ,
      x_cs1_state_txt                     => x_cs1_state_txt                                   ,
      x_cs1_zip_txt                       => x_cs1_zip_txt                                     ,
      x_cs1_zip_suffix_txt                => x_cs1_zip_suffix_txt                              ,
      x_cs1_telephone_number_txt          => x_cs1_telephone_number_txt                        ,
      x_cs1_signature_code_txt            => x_cs1_signature_code_txt                          ,
      x_cs2_lname                         => x_cs2_lname                                       ,
      x_cs2_fname                         => x_cs2_fname                                       ,
      x_cs2_mi_txt                        => x_cs2_mi_txt                                      ,
      x_cs2_ssn_txt                       => x_cs2_ssn_txt                                     ,
      x_cs2_citizenship_status            => x_cs2_citizenship_status                          ,
      x_cs2_address_line_1_txt            => x_cs2_address_line_1_txt                          ,
      x_cs2_address_line_2_txt            => x_cs2_address_line_2_txt                          ,
      x_cs2_city_txt                      => x_cs2_city_txt                                    ,
      x_cs2_state_txt                     => x_cs2_state_txt                                   ,
      x_cs2_zip_txt                       => x_cs2_zip_txt                                     ,
      x_cs2_zip_suffix_txt                => x_cs2_zip_suffix_txt                              ,
      x_cs2_telephone_number_txt          => x_cs2_telephone_number_txt                        ,
      x_cs2_signature_code_txt            => x_cs2_signature_code_txt                          ,
      x_cs1_credit_auth_code_txt          => x_cs1_credit_auth_code_txt                        ,
      x_cs1_birth_date                    => x_cs1_birth_date                                  ,
      x_cs1_drv_license_num_txt           => x_cs1_drv_license_num_txt                         ,
      x_cs1_drv_license_state_txt         => x_cs1_drv_license_state_txt                       ,
      x_cs1_elect_sig_ind_code_txt        => x_cs1_elect_sig_ind_code_txt                      ,
      x_cs1_frgn_postal_code_txt          => x_cs1_frgn_postal_code_txt                        ,
      x_cs1_frgn_tel_num_prefix_txt       => x_cs1_frgn_tel_num_prefix_txt                     ,
      x_cs1_gross_annual_sal_num          => x_cs1_gross_annual_sal_num                        ,
      x_cs1_mthl_auto_pay_txt             => x_cs1_mthl_auto_pay_txt                           ,
      x_cs1_mthl_cc_pay_txt               => x_cs1_mthl_cc_pay_txt                             ,
      x_cs1_mthl_edu_loan_pay_txt         => x_cs1_mthl_edu_loan_pay_txt                       ,
      x_cs1_mthl_housing_pay_txt          => x_cs1_mthl_housing_pay_txt                        ,
      x_cs1_mthl_other_pay_txt            => x_cs1_mthl_other_pay_txt                          ,
      x_cs1_other_income_amt              => x_cs1_other_income_amt                            ,
      x_cs1_rel_to_student_flag           => x_cs1_rel_to_student_flag                         ,
      x_cs1_suffix_txt                    => x_cs1_suffix_txt                                  ,
      x_cs1_years_at_address_txt          => x_cs1_years_at_address_txt                        ,
      x_cs2_credit_auth_code_txt          => x_cs2_credit_auth_code_txt                        ,
      x_cs2_birth_date                    => x_cs2_birth_date                                  ,
      x_cs2_drv_license_num_txt           => x_cs2_drv_license_num_txt                         ,
      x_cs2_drv_license_state_txt         => x_cs2_drv_license_state_txt                       ,
      x_cs2_elect_sig_ind_code_txt        => x_cs2_elect_sig_ind_code_txt                      ,
      x_cs2_frgn_postal_code_txt          => x_cs2_frgn_postal_code_txt                        ,
      x_cs2_frgn_tel_num_prefix_txt       => x_cs2_frgn_tel_num_prefix_txt                     ,
      x_cs2_gross_annual_sal_num          => x_cs2_gross_annual_sal_num                        ,
      x_cs2_mthl_auto_pay_txt             => x_cs2_mthl_auto_pay_txt                           ,
      x_cs2_mthl_cc_pay_txt               => x_cs2_mthl_cc_pay_txt                             ,
      x_cs2_mthl_edu_loan_pay_txt         => x_cs2_mthl_edu_loan_pay_txt                       ,
      x_cs2_mthl_housing_pay_txt          => x_cs2_mthl_housing_pay_txt                        ,
      x_cs2_mthl_other_pay_txt            => x_cs2_mthl_other_pay_txt                          ,
      x_cs2_other_income_amt              => x_cs2_other_income_amt                            ,
      x_cs2_rel_to_student_flag           => x_cs2_rel_to_student_flag                         ,
      x_cs2_suffix_txt                    => x_cs2_suffix_txt                                  ,
      x_cs2_years_at_address_txt          => x_cs2_years_at_address_txt
    );

    IF (x_mode = 'R') THEN
      x_request_id := FND_GLOBAL.CONC_REQUEST_ID;
      x_program_id := FND_GLOBAL.CONC_PROGRAM_ID;
      x_program_application_id := FND_GLOBAL.PROG_APPL_ID;
      IF (x_request_id =  -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
        x_program_update_date := old_references.program_update_date;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    END IF;

    UPDATE igf_sl_alt_borw_all
      SET
        loan_id                           = new_references.loan_id,
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
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        other_loan_amt                    = new_references.other_loan_amt, -- mnade 5/30/2005 - Correcting this to use the new valud instead of passed parameter x_other_loan_amt
        cs1_lname                         = new_references.cs1_lname                   ,
        cs1_fname                         = new_references.cs1_fname                   ,
        cs1_mi_txt                        = new_references.cs1_mi_txt                  ,
        cs1_ssn_txt                       = new_references.cs1_ssn_txt                 ,
        cs1_citizenship_status            = new_references.cs1_citizenship_status      ,
        cs1_address_line_1_txt            = new_references.cs1_address_line_1_txt      ,
        cs1_address_line_2_txt            = new_references.cs1_address_line_2_txt      ,
        cs1_city_txt                      = new_references.cs1_city_txt                ,
        cs1_state_txt                     = new_references.cs1_state_txt               ,
        cs1_zip_txt                       = new_references.cs1_zip_txt                 ,
        cs1_zip_suffix_txt                = new_references.cs1_zip_suffix_txt          ,
        cs1_telephone_number_txt          = new_references.cs1_telephone_number_txt    ,
        cs1_signature_code_txt            = new_references.cs1_signature_code_txt      ,
        cs2_lname                         = new_references.cs2_lname                   ,
        cs2_fname                         = new_references.cs2_fname                   ,
        cs2_mi_txt                        = new_references.cs2_mi_txt                  ,
        cs2_ssn_txt                       = new_references.cs2_ssn_txt                 ,
        cs2_citizenship_status            = new_references.cs2_citizenship_status      ,
        cs2_address_line_1_txt            = new_references.cs2_address_line_1_txt      ,
        cs2_address_line_2_txt            = new_references.cs2_address_line_2_txt      ,
        cs2_city_txt                      = new_references.cs2_city_txt                ,
        cs2_state_txt                     = new_references.cs2_state_txt               ,
        cs2_zip_txt                       = new_references.cs2_zip_txt                 ,
        cs2_zip_suffix_txt                = new_references.cs2_zip_suffix_txt          ,
        cs2_telephone_number_txt          = new_references.cs2_telephone_number_txt    ,
        cs2_signature_code_txt            = new_references.cs2_signature_code_txt      ,
        cs1_credit_auth_code_txt          = new_references.cs1_credit_auth_code_txt    ,
        cs1_birth_date                    = new_references.cs1_birth_date              ,
        cs1_drv_license_num_txt           = new_references.cs1_drv_license_num_txt     ,
        cs1_drv_license_state_txt         = new_references.cs1_drv_license_state_txt   ,
        cs1_elect_sig_ind_code_txt        = new_references.cs1_elect_sig_ind_code_txt  ,
        cs1_frgn_postal_code_txt          = new_references.cs1_frgn_postal_code_txt    ,
        cs1_frgn_tel_num_prefix_txt       = new_references.cs1_frgn_tel_num_prefix_txt ,
        cs1_gross_annual_sal_num          = new_references.cs1_gross_annual_sal_num    ,
        cs1_mthl_auto_pay_txt             = new_references.cs1_mthl_auto_pay_txt       ,
        cs1_mthl_cc_pay_txt               = new_references.cs1_mthl_cc_pay_txt         ,
        cs1_mthl_edu_loan_pay_txt         = new_references.cs1_mthl_edu_loan_pay_txt   ,
        cs1_mthl_housing_pay_txt          = new_references.cs1_mthl_housing_pay_txt    ,
        cs1_mthl_other_pay_txt            = new_references.cs1_mthl_other_pay_txt      ,
        cs1_other_income_amt              = new_references.cs1_other_income_amt        ,
        cs1_rel_to_student_flag           = new_references.cs1_rel_to_student_flag     ,
        cs1_suffix_txt                    = new_references.cs1_suffix_txt              ,
        cs1_years_at_address_txt          = new_references.cs1_years_at_address_txt    ,
        cs2_credit_auth_code_txt          = new_references.cs2_credit_auth_code_txt    ,
        cs2_birth_date                    = new_references.cs2_birth_date              ,
        cs2_drv_license_num_txt           = new_references.cs2_drv_license_num_txt     ,
        cs2_drv_license_state_txt         = new_references.cs2_drv_license_state_txt   ,
        cs2_elect_sig_ind_code_txt        = new_references.cs2_elect_sig_ind_code_txt  ,
        cs2_frgn_postal_code_txt          = new_references.cs2_frgn_postal_code_txt    ,
        cs2_frgn_tel_num_prefix_txt       = new_references.cs2_frgn_tel_num_prefix_txt ,
        cs2_gross_annual_sal_num          = new_references.cs2_gross_annual_sal_num    ,
        cs2_mthl_auto_pay_txt             = new_references.cs2_mthl_auto_pay_txt       ,
        cs2_mthl_cc_pay_txt               = new_references.cs2_mthl_cc_pay_txt         ,
        cs2_mthl_edu_loan_pay_txt         = new_references.cs2_mthl_edu_loan_pay_txt   ,
        cs2_mthl_housing_pay_txt          = new_references.cs2_mthl_housing_pay_txt    ,
        cs2_mthl_other_pay_txt            = new_references.cs2_mthl_other_pay_txt      ,
        cs2_other_income_amt              = new_references.cs2_other_income_amt        ,
        cs2_rel_to_student_flag           = new_references.cs2_rel_to_student_flag     ,
        cs2_suffix_txt                    = new_references.cs2_suffix_txt              ,
        cs2_years_at_address_txt          = new_references.cs2_years_at_address_txt
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_albw_id                           IN OUT NOCOPY NUMBER,
    x_loan_id                           IN     NUMBER,
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
    x_mode                              IN     VARCHAR2,
    x_other_loan_amt                    IN     NUMBER,
    x_cs1_lname                         IN     VARCHAR2,
    x_cs1_fname                         IN     VARCHAR2,
    x_cs1_mi_txt                        IN     VARCHAR2,
    x_cs1_ssn_txt                       IN     VARCHAR2,
    x_cs1_citizenship_status            IN     VARCHAR2,
    x_cs1_address_line_1_txt            IN     VARCHAR2,
    x_cs1_address_line_2_txt            IN     VARCHAR2,
    x_cs1_city_txt                      IN     VARCHAR2,
    x_cs1_state_txt                     IN     VARCHAR2,
    x_cs1_zip_txt                       IN     VARCHAR2,
    x_cs1_zip_suffix_txt                IN     VARCHAR2,
    x_cs1_telephone_number_txt          IN     VARCHAR2,
    x_cs1_signature_code_txt            IN     VARCHAR2,
    x_cs2_lname                         IN     VARCHAR2,
    x_cs2_fname                         IN     VARCHAR2,
    x_cs2_mi_txt                        IN     VARCHAR2,
    x_cs2_ssn_txt                       IN     VARCHAR2,
    x_cs2_citizenship_status            IN     VARCHAR2,
    x_cs2_address_line_1_txt            IN     VARCHAR2,
    x_cs2_address_line_2_txt            IN     VARCHAR2,
    x_cs2_city_txt                      IN     VARCHAR2,
    x_cs2_state_txt                     IN     VARCHAR2,
    x_cs2_zip_txt                       IN     VARCHAR2,
    x_cs2_zip_suffix_txt                IN     VARCHAR2,
    x_cs2_telephone_number_txt          IN     VARCHAR2,
    x_cs2_signature_code_txt            IN     VARCHAR2,
    x_cs1_credit_auth_code_txt          IN     VARCHAR2,
    x_cs1_birth_date                    IN     Date    ,
    x_cs1_drv_license_num_txt           IN     VARCHAR2,
    x_cs1_drv_license_state_txt         IN     VARCHAR2,
    x_cs1_elect_sig_ind_code_txt        IN     VARCHAR2,
    x_cs1_frgn_postal_code_txt          IN     VARCHAR2,
    x_cs1_frgn_tel_num_prefix_txt       IN     VARCHAR2,
    x_cs1_gross_annual_sal_num          IN     NUMBER  ,
    x_cs1_mthl_auto_pay_txt             IN     VARCHAR2,
    x_cs1_mthl_cc_pay_txt               IN     VARCHAR2,
    x_cs1_mthl_edu_loan_pay_txt         IN     VARCHAR2,
    x_cs1_mthl_housing_pay_txt          IN     VARCHAR2,
    x_cs1_mthl_other_pay_txt            IN     VARCHAR2,
    x_cs1_other_income_amt              IN     NUMBER  ,
    x_cs1_rel_to_student_flag           IN     VARCHAR2,
    x_cs1_suffix_txt                    IN     VARCHAR2,
    x_cs1_years_at_address_txt          IN     NUMBER  ,
    x_cs2_credit_auth_code_txt          IN     VARCHAR2,
    x_cs2_birth_date                    IN     Date    ,
    x_cs2_drv_license_num_txt           IN     VARCHAR2,
    x_cs2_drv_license_state_txt         IN     VARCHAR2,
    x_cs2_elect_sig_ind_code_txt        IN     VARCHAR2,
    x_cs2_frgn_postal_code_txt          IN     VARCHAR2,
    x_cs2_frgn_tel_num_prefix_txt       IN     VARCHAR2,
    x_cs2_gross_annual_sal_num          IN     NUMBER  ,
    x_cs2_mthl_auto_pay_txt             IN     VARCHAR2,
    x_cs2_mthl_cc_pay_txt               IN     VARCHAR2,
    x_cs2_mthl_edu_loan_pay_txt         IN     VARCHAR2,
    x_cs2_mthl_housing_pay_txt          IN     VARCHAR2,
    x_cs2_mthl_other_pay_txt            IN     VARCHAR2,
    x_cs2_other_income_amt              IN     NUMBER  ,
    x_cs2_rel_to_student_flag           IN     VARCHAR2,
    x_cs2_suffix_txt                    IN     VARCHAR2,
    x_cs2_years_at_address_txt          IN     NUMBER
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
      FROM     igf_sl_alt_borw_all
      WHERE    albw_id                           = x_albw_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
        CLOSE c1;

      insert_row (
        x_rowid,
        x_albw_id,
        x_loan_id,
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
        x_mode,
        x_other_loan_amt,
        x_cs1_lname,
        x_cs1_fname,
        x_cs1_mi_txt,
        x_cs1_ssn_txt,
        x_cs1_citizenship_status,
        x_cs1_address_line_1_txt,
        x_cs1_address_line_2_txt,
        x_cs1_city_txt,
        x_cs1_state_txt,
        x_cs1_zip_txt,
        x_cs1_zip_suffix_txt,
        x_cs1_telephone_number_txt,
        x_cs1_signature_code_txt,
        x_cs2_lname,
        x_cs2_fname,
        x_cs2_mi_txt,
        x_cs2_ssn_txt,
        x_cs2_citizenship_status,
        x_cs2_address_line_1_txt,
        x_cs2_address_line_2_txt,
        x_cs2_city_txt,
        x_cs2_state_txt,
        x_cs2_zip_txt,
        x_cs2_zip_suffix_txt,
        x_cs2_telephone_number_txt,
        x_cs2_signature_code_txt,
        x_cs1_credit_auth_code_txt,
        x_cs1_birth_date,
        x_cs1_drv_license_num_txt,
        x_cs1_drv_license_state_txt,
        x_cs1_elect_sig_ind_code_txt,
        x_cs1_frgn_postal_code_txt,
        x_cs1_frgn_tel_num_prefix_txt,
        x_cs1_gross_annual_sal_num,
        x_cs1_mthl_auto_pay_txt,
        x_cs1_mthl_cc_pay_txt,
        x_cs1_mthl_edu_loan_pay_txt,
        x_cs1_mthl_housing_pay_txt,
        x_cs1_mthl_other_pay_txt,
        x_cs1_other_income_amt,
        x_cs1_rel_to_student_flag,
        x_cs1_suffix_txt,
        x_cs1_years_at_address_txt,
        x_cs2_credit_auth_code_txt,
        x_cs2_birth_date,
        x_cs2_drv_license_num_txt,
        x_cs2_drv_license_state_txt,
        x_cs2_elect_sig_ind_code_txt,
        x_cs2_frgn_postal_code_txt,
        x_cs2_frgn_tel_num_prefix_txt,
        x_cs2_gross_annual_sal_num,
        x_cs2_mthl_auto_pay_txt,
        x_cs2_mthl_cc_pay_txt,
        x_cs2_mthl_edu_loan_pay_txt,
        x_cs2_mthl_housing_pay_txt,
        x_cs2_mthl_other_pay_txt,
        x_cs2_other_income_amt,
        x_cs2_rel_to_student_flag,
        x_cs2_suffix_txt,
        x_cs2_years_at_address_txt
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_albw_id,
      x_loan_id,
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
      x_mode,
      x_other_loan_amt,
      x_cs1_lname,
      x_cs1_fname,
      x_cs1_mi_txt,
      x_cs1_ssn_txt,
      x_cs1_citizenship_status,
      x_cs1_address_line_1_txt,
      x_cs1_address_line_2_txt,
      x_cs1_city_txt,
      x_cs1_state_txt,
      x_cs1_zip_txt,
      x_cs1_zip_suffix_txt,
      x_cs1_telephone_number_txt,
      x_cs1_signature_code_txt,
      x_cs2_lname,
      x_cs2_fname,
      x_cs2_mi_txt,
      x_cs2_ssn_txt,
      x_cs2_citizenship_status,
      x_cs2_address_line_1_txt,
      x_cs2_address_line_2_txt,
      x_cs2_city_txt,
      x_cs2_state_txt,
      x_cs2_zip_txt,
      x_cs2_zip_suffix_txt,
      x_cs2_telephone_number_txt,
      x_cs2_signature_code_txt,
      x_cs1_credit_auth_code_txt,
      x_cs1_birth_date,
      x_cs1_drv_license_num_txt,
      x_cs1_drv_license_state_txt,
      x_cs1_elect_sig_ind_code_txt,
      x_cs1_frgn_postal_code_txt,
      x_cs1_frgn_tel_num_prefix_txt,
      x_cs1_gross_annual_sal_num,
      x_cs1_mthl_auto_pay_txt,
      x_cs1_mthl_cc_pay_txt,
      x_cs1_mthl_edu_loan_pay_txt,
      x_cs1_mthl_housing_pay_txt,
      x_cs1_mthl_other_pay_txt,
      x_cs1_other_income_amt,
      x_cs1_rel_to_student_flag,
      x_cs1_suffix_txt,
      x_cs1_years_at_address_txt,
      x_cs2_credit_auth_code_txt,
      x_cs2_birth_date,
      x_cs2_drv_license_num_txt,
      x_cs2_drv_license_state_txt,
      x_cs2_elect_sig_ind_code_txt,
      x_cs2_frgn_postal_code_txt,
      x_cs2_frgn_tel_num_prefix_txt,
      x_cs2_gross_annual_sal_num,
      x_cs2_mthl_auto_pay_txt,
      x_cs2_mthl_cc_pay_txt,
      x_cs2_mthl_edu_loan_pay_txt,
      x_cs2_mthl_housing_pay_txt,
      x_cs2_mthl_other_pay_txt,
      x_cs2_other_income_amt,
      x_cs2_rel_to_student_flag,
      x_cs2_suffix_txt,
      x_cs2_years_at_address_txt
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

    before_dml ( p_action => 'DELETE', x_rowid => x_rowid );

    DELETE FROM igf_sl_alt_borw_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
       RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_sl_alt_borw_pkg;

/
