--------------------------------------------------------
--  DDL for Package Body IGF_GR_RFMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_GR_RFMS_PKG" AS
/* $Header: IGFGI05B.pls 120.0 2005/06/01 14:27:31 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_gr_rfms_all%ROWTYPE;
  new_references igf_gr_rfms_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_origination_id                    IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER  ,
    x_base_id                           IN     NUMBER  ,
    x_award_id                          IN     NUMBER  ,
    x_rfmb_id                           IN     NUMBER  ,
    x_sys_orig_ssn                      IN     VARCHAR2,
    x_sys_orig_name_cd                  IN     VARCHAR2,
    x_transaction_num                   IN     VARCHAR2,
    x_efc                               IN     NUMBER  ,
    x_ver_status_code                   IN     VARCHAR2,
    x_secondary_efc                     IN     NUMBER  ,
    x_secondary_efc_cd                  IN     VARCHAR2,
    x_pell_amount                       IN     NUMBER  ,
    x_enrollment_status                 IN     VARCHAR2,
    x_enrollment_dt                     IN     DATE    ,
    x_coa_amount                        IN     NUMBER  ,
    x_academic_calendar                 IN     VARCHAR2,
    x_payment_method                    IN     VARCHAR2,
    x_total_pymt_prds                   IN     NUMBER  ,
    x_incrcd_fed_pell_rcp_cd            IN     VARCHAR2,
    x_attending_campus_id               IN     VARCHAR2,
    x_est_disb_dt1                      IN     DATE    ,
    x_orig_action_code                  IN     VARCHAR2,
    x_orig_status_dt                    IN     DATE    ,
    x_orig_ed_use_flags                 IN     VARCHAR2,
    x_ft_pell_amount                    IN     NUMBER  ,
    x_prev_accpt_efc                    IN     NUMBER  ,
    x_prev_accpt_tran_no                IN     VARCHAR2,
    x_prev_accpt_sec_efc_cd             IN     VARCHAR2,
    x_prev_accpt_coa                    IN     NUMBER  ,
    x_orig_reject_code                  IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER  ,
    x_wk_int_time_prg_def_yr            IN     NUMBER  ,
    x_cr_clk_hrs_prds_sch_yr            IN     NUMBER  ,
    x_cr_clk_hrs_acad_yr                IN     NUMBER  ,
    x_inst_cross_ref_cd                 IN     VARCHAR2,
    x_low_tution_fee                    IN     VARCHAR2,
    x_rec_source                        IN     VARCHAR2,
    x_pending_amount			     IN     NUMBER,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_birth_dt                          IN     DATE    ,
    x_last_name                         IN     VARCHAR2,
    x_first_name                        IN     VARCHAR2,
    x_middle_name                       IN     VARCHAR2,
    x_current_ssn                       IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2   DEFAULT NULL,
    x_reporting_pell_cd                 IN     VARCHAR2   DEFAULT NULL,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_note_message                      IN     VARCHAR2,
    x_full_resp_code                    IN     VARCHAR2,
    x_document_id_txt                   IN     VARCHAR2

  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 15-JAN-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_GR_RFMS_ALL
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
    new_references.origination_id                    := x_origination_id;
    new_references.ci_cal_type                       := x_ci_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.base_id                           := x_base_id;
    new_references.award_id                          := x_award_id;
    new_references.rfmb_id                           := x_rfmb_id;
    new_references.sys_orig_ssn                      := x_sys_orig_ssn;
    new_references.sys_orig_name_cd                  := x_sys_orig_name_cd;
    new_references.transaction_num                   := x_transaction_num;
    new_references.efc                               := x_efc;
    new_references.ver_status_code                   := x_ver_status_code;
    new_references.secondary_efc                     := x_secondary_efc;
    new_references.secondary_efc_cd                  := x_secondary_efc_cd;
    new_references.pell_amount                       := x_pell_amount;
    new_references.enrollment_status                 := x_enrollment_status;
    new_references.enrollment_dt                     := x_enrollment_dt;
    new_references.coa_amount                        := x_coa_amount;
    new_references.academic_calendar                 := x_academic_calendar;
    new_references.payment_method                    := x_payment_method;
    new_references.total_pymt_prds                   := x_total_pymt_prds;
    new_references.incrcd_fed_pell_rcp_cd            := x_incrcd_fed_pell_rcp_cd;
    new_references.attending_campus_id               := x_attending_campus_id;
    new_references.est_disb_dt1                      := x_est_disb_dt1;
    new_references.orig_action_code                  := x_orig_action_code;
    new_references.orig_status_dt                    := x_orig_status_dt;
    new_references.orig_ed_use_flags                 := x_orig_ed_use_flags;
    new_references.ft_pell_amount                    := x_ft_pell_amount;
    new_references.prev_accpt_efc                    := x_prev_accpt_efc;
    new_references.prev_accpt_tran_no                := x_prev_accpt_tran_no;
    new_references.prev_accpt_sec_efc_cd             := x_prev_accpt_sec_efc_cd;
    new_references.prev_accpt_coa                    := x_prev_accpt_coa;
    new_references.orig_reject_code                  := x_orig_reject_code;
    new_references.wk_inst_time_calc_pymt            := x_wk_inst_time_calc_pymt;
    new_references.wk_int_time_prg_def_yr            := x_wk_int_time_prg_def_yr;
    new_references.cr_clk_hrs_prds_sch_yr            := x_cr_clk_hrs_prds_sch_yr;
    new_references.cr_clk_hrs_acad_yr                := x_cr_clk_hrs_acad_yr;
    new_references.inst_cross_ref_cd                 := x_inst_cross_ref_cd;
    new_references.low_tution_fee                    := x_low_tution_fee;
    new_references.rec_source                        := x_rec_source;
    new_references.pending_amount                        := x_pending_amount;

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
    new_references.birth_dt                          := x_birth_dt;
    new_references.last_name                         := x_last_name;
    new_references.first_name                        := x_first_name;
    new_references.middle_name                       := x_middle_name;
    new_references.current_ssn                       := x_current_ssn;
    new_references.legacy_record_flag                := x_legacy_record_flag;
    new_references.reporting_pell_cd                 := x_reporting_pell_cd;
    new_references.rep_entity_id_txt                 := x_rep_entity_id_txt;
    new_references.atd_entity_id_txt                 := x_atd_entity_id_txt;
    new_references.note_message                      := x_note_message;
    new_references.full_resp_code                    := x_full_resp_code;
    new_references.document_id_txt                   := x_document_id_txt;


  END set_column_values;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : adhawan
  ||  Created On : 15-JAN-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  brajendr        21-Jul-2003     Added the check pk to awards table
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.rfmb_id = new_references.rfmb_id)) OR
        ((new_references.rfmb_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_gr_rfms_batch_pkg.get_pk_for_validation (
                new_references.rfmb_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

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

    -- check for parent key existance for Awards table
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

    -- check for parent key existance for FA Base Rec table
    IF (((old_references.base_id = new_references.base_id)) OR
        ((new_references.base_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_ap_fa_base_rec_pkg.get_pk_for_validation (
                new_references.base_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : adhawan
  ||  Created On : 15-JAN-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igf_gr_rfms_disb_pkg.get_fk_igf_gr_rfms (
      old_references.origination_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_origination_id                    IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : adhawan
  ||  Created On : 15-JAN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_gr_rfms_all
      WHERE    origination_id = x_origination_id
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


  PROCEDURE get_fk_igf_gr_rfms_batch (
    x_rfmb_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 15-JAN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_gr_rfms_all
      WHERE   ((rfmb_id = x_rfmb_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_GR_RFMS_RFMB_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_gr_rfms_batch;


  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 15-JAN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_gr_rfms_all
      WHERE   ((ci_cal_type = x_cal_type) AND
               (ci_sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_GR_RFMS_CI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst;


  PROCEDURE get_fk_igf_aw_award (
    x_award_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : brajendr
  ||  Created On : 21-Jul-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_gr_rfms_all
      WHERE   ((award_id = x_award_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_GR_RFMS_AWD_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_award;


  PROCEDURE get_fk_igf_ap_fa_base_rec (
    x_base_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : brajendr
  ||  Created On : 21-Jul-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_gr_rfms_all
      WHERE   ((base_id = x_base_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_GR_RFMS_FA_DETAIL_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_ap_fa_base_rec;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_origination_id                    IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER  ,
    x_base_id                           IN     NUMBER  ,
    x_award_id                          IN     NUMBER  ,
    x_rfmb_id                           IN     NUMBER  ,
    x_sys_orig_ssn                      IN     VARCHAR2,
    x_sys_orig_name_cd                  IN     VARCHAR2,
    x_transaction_num                   IN     VARCHAR2,
    x_efc                               IN     NUMBER  ,
    x_ver_status_code                   IN     VARCHAR2,
    x_secondary_efc                     IN     NUMBER  ,
    x_secondary_efc_cd                  IN     VARCHAR2,
    x_pell_amount                       IN     NUMBER  ,
    x_pell_profile                      IN     VARCHAR2,
    x_enrollment_status                 IN     VARCHAR2,
    x_enrollment_dt                     IN     DATE    ,
    x_coa_amount                        IN     NUMBER  ,
    x_academic_calendar                 IN     VARCHAR2,
    x_payment_method                    IN     VARCHAR2,
    x_total_pymt_prds                   IN     NUMBER  ,
    x_incrcd_fed_pell_rcp_cd            IN     VARCHAR2,
    x_attending_campus_id               IN     VARCHAR2,
    x_est_disb_dt1                      IN     DATE    ,
    x_orig_action_code                  IN     VARCHAR2,
    x_orig_status_dt                    IN     DATE    ,
    x_orig_ed_use_flags                 IN     VARCHAR2,
    x_ft_pell_amount                    IN     NUMBER  ,
    x_prev_accpt_efc                    IN     NUMBER  ,
    x_prev_accpt_tran_no                IN     VARCHAR2,
    x_prev_accpt_sec_efc_cd             IN     VARCHAR2,
    x_prev_accpt_coa                    IN     NUMBER  ,
    x_orig_reject_code                  IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER  ,
    x_wk_int_time_prg_def_yr            IN     NUMBER  ,
    x_cr_clk_hrs_prds_sch_yr            IN     NUMBER  ,
    x_cr_clk_hrs_acad_yr                IN     NUMBER  ,
    x_inst_cross_ref_cd                 IN     VARCHAR2,
    x_low_tution_fee                    IN     VARCHAR2,
    x_rec_source                        IN     VARCHAR2,
    x_pending_amount	                IN     NUMBER,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_birth_dt                          IN     DATE    ,
    x_last_name                         IN     VARCHAR2,
    x_first_name                        IN     VARCHAR2,
    x_middle_name                       IN     VARCHAR2,
    x_current_ssn                       IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2,
    x_reporting_pell_cd                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_note_message                      IN     VARCHAR2,
    x_full_resp_code                    IN     VARCHAR2,
    x_document_id_txt                   IN     VARCHAR2


  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 15-JAN-2001
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
      x_origination_id,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_base_id,
      x_award_id,
      x_rfmb_id,
      x_sys_orig_ssn,
      x_sys_orig_name_cd,
      x_transaction_num,
      x_efc,
      x_ver_status_code,
      x_secondary_efc,
      x_secondary_efc_cd,
      x_pell_amount,
      x_enrollment_status,
      x_enrollment_dt,
      x_coa_amount,
      x_academic_calendar,
      x_payment_method,
      x_total_pymt_prds,
      x_incrcd_fed_pell_rcp_cd,
      x_attending_campus_id,
      x_est_disb_dt1,
      x_orig_action_code,
      x_orig_status_dt,
      x_orig_ed_use_flags,
      x_ft_pell_amount,
      x_prev_accpt_efc,
      x_prev_accpt_tran_no,
      x_prev_accpt_sec_efc_cd,
      x_prev_accpt_coa,
      x_orig_reject_code,
      x_wk_inst_time_calc_pymt,
      x_wk_int_time_prg_def_yr,
      x_cr_clk_hrs_prds_sch_yr,
      x_cr_clk_hrs_acad_yr,
      x_inst_cross_ref_cd,
      x_low_tution_fee,
      x_rec_source,
      x_pending_amount,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_birth_dt,
      x_last_name,
      x_first_name,
      x_middle_name,
      x_current_ssn,
      x_legacy_record_flag,
      x_reporting_pell_cd,
      x_rep_entity_id_txt,
      x_atd_entity_id_txt,
      x_note_message,
      x_full_resp_code,
      x_document_id_txt

    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.origination_id
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
             new_references.origination_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_origination_id                    IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_rfmb_id                           IN     NUMBER,
    x_sys_orig_ssn                      IN     VARCHAR2,
    x_sys_orig_name_cd                  IN     VARCHAR2,
    x_transaction_num                   IN     VARCHAR2,
    x_efc                               IN     NUMBER,
    x_ver_status_code                   IN     VARCHAR2,
    x_secondary_efc                     IN     NUMBER,
    x_secondary_efc_cd                  IN     VARCHAR2,
    x_pell_amount                       IN     NUMBER,
    x_pell_profile                      IN     VARCHAR2,
    x_enrollment_status                 IN     VARCHAR2,
    x_enrollment_dt                     IN     DATE,
    x_coa_amount                        IN     NUMBER,
    x_academic_calendar                 IN     VARCHAR2,
    x_payment_method                    IN     VARCHAR2,
    x_total_pymt_prds                   IN     NUMBER,
    x_incrcd_fed_pell_rcp_cd            IN     VARCHAR2,
    x_attending_campus_id               IN     VARCHAR2,
    x_est_disb_dt1                      IN     DATE,
    x_orig_action_code                  IN     VARCHAR2,
    x_orig_status_dt                    IN     DATE,
    x_orig_ed_use_flags                 IN     VARCHAR2,
    x_ft_pell_amount                    IN     NUMBER,
    x_prev_accpt_efc                    IN     NUMBER,
    x_prev_accpt_tran_no                IN     VARCHAR2,
    x_prev_accpt_sec_efc_cd             IN     VARCHAR2,
    x_prev_accpt_coa                    IN     NUMBER,
    x_orig_reject_code                  IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER,
    x_wk_int_time_prg_def_yr            IN     NUMBER,
    x_cr_clk_hrs_prds_sch_yr            IN     NUMBER,
    x_cr_clk_hrs_acad_yr                IN     NUMBER,
    x_inst_cross_ref_cd                 IN     VARCHAR2,
    x_low_tution_fee                    IN     VARCHAR2,
    x_rec_source                        IN     VARCHAR2,
    x_pending_amount			     IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_last_name                         IN     VARCHAR2,
    x_first_name                        IN     VARCHAR2,
    x_middle_name                       IN     VARCHAR2,
    x_current_ssn                       IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2,
    x_reporting_pell_cd                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_note_message                      IN     VARCHAR2,
    x_full_resp_code                    IN     VARCHAR2,
    x_document_id_txt                   IN     VARCHAR2

  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 15-JAN-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_gr_rfms_all
      WHERE    origination_id                    = x_origination_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_org_id			 igf_gr_rfms_all.org_id%TYPE;

  BEGIN

    l_org_id			 := igf_aw_gen.get_org_id;

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
      x_origination_id                    => x_origination_id,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_base_id                           => x_base_id,
      x_award_id                          => x_award_id,
      x_rfmb_id                           => x_rfmb_id,
      x_sys_orig_ssn                      => x_sys_orig_ssn,
      x_sys_orig_name_cd                  => x_sys_orig_name_cd,
      x_transaction_num                   => x_transaction_num,
      x_efc                               => x_efc,
      x_ver_status_code                   => x_ver_status_code,
      x_secondary_efc                     => x_secondary_efc,
      x_secondary_efc_cd                  => x_secondary_efc_cd,
      x_pell_amount                       => x_pell_amount,
      x_pell_profile                      => x_pell_profile,
      x_enrollment_status                 => x_enrollment_status,
      x_enrollment_dt                     => x_enrollment_dt,
      x_coa_amount                        => x_coa_amount,
      x_academic_calendar                 => x_academic_calendar,
      x_payment_method                    => x_payment_method,
      x_total_pymt_prds                   => x_total_pymt_prds,
      x_incrcd_fed_pell_rcp_cd            => x_incrcd_fed_pell_rcp_cd,
      x_attending_campus_id               => x_attending_campus_id,
      x_est_disb_dt1                      => x_est_disb_dt1,
      x_orig_action_code                  => x_orig_action_code,
      x_orig_status_dt                    => x_orig_status_dt,
      x_orig_ed_use_flags                 => x_orig_ed_use_flags,
      x_ft_pell_amount                    => x_ft_pell_amount,
      x_prev_accpt_efc                    => x_prev_accpt_efc,
      x_prev_accpt_tran_no                => x_prev_accpt_tran_no,
      x_prev_accpt_sec_efc_cd             => x_prev_accpt_sec_efc_cd,
      x_prev_accpt_coa                    => x_prev_accpt_coa,
      x_orig_reject_code                  => x_orig_reject_code,
      x_wk_inst_time_calc_pymt            => x_wk_inst_time_calc_pymt,
      x_wk_int_time_prg_def_yr            => x_wk_int_time_prg_def_yr,
      x_cr_clk_hrs_prds_sch_yr            => x_cr_clk_hrs_prds_sch_yr,
      x_cr_clk_hrs_acad_yr                => x_cr_clk_hrs_acad_yr,
      x_inst_cross_ref_cd                 => x_inst_cross_ref_cd,
      x_low_tution_fee                    => x_low_tution_fee,
      x_rec_source                        => x_rec_source,
      x_pending_amount	                  => x_pending_amount,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_birth_dt                          => x_birth_dt,
      x_last_name                         => x_last_name,
      x_first_name                        => x_first_name,
      x_middle_name                       => x_middle_name,
      x_current_ssn                       => x_current_ssn,
      x_legacy_record_flag                => x_legacy_record_flag,
      x_reporting_pell_cd                 => x_reporting_pell_cd,
      x_rep_entity_id_txt                 => x_rep_entity_id_txt,
      x_atd_entity_id_txt                 => x_atd_entity_id_txt,
      x_note_message                      => x_note_message ,
      x_full_resp_code                    => x_full_resp_code,
      x_document_id_txt                   => x_document_id_txt

    );

    INSERT INTO igf_gr_rfms_all (
      origination_id,
      ci_cal_type,
      ci_sequence_number,
      base_id,
      award_id,
      rfmb_id,
      sys_orig_ssn,
      sys_orig_name_cd,
      transaction_num,
      efc,
      ver_status_code,
      secondary_efc,
      secondary_efc_cd,
      pell_amount,
      enrollment_status,
      enrollment_dt,
      coa_amount,
      academic_calendar,
      payment_method,
      total_pymt_prds,
      incrcd_fed_pell_rcp_cd,
      attending_campus_id,
      est_disb_dt1,
      orig_action_code,
      orig_status_dt,
      orig_ed_use_flags,
      ft_pell_amount,
      prev_accpt_efc,
      prev_accpt_tran_no,
      prev_accpt_sec_efc_cd,
      prev_accpt_coa,
      orig_reject_code,
      wk_inst_time_calc_pymt,
      wk_int_time_prg_def_yr,
      cr_clk_hrs_prds_sch_yr,
      cr_clk_hrs_acad_yr,
      inst_cross_ref_cd,
      low_tution_fee,
      rec_source,
      pending_amount,
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
      birth_dt,
      last_name,
      first_name,
      middle_name,
      current_ssn,
      legacy_record_flag,
      reporting_pell_cd,
      rep_entity_id_txt,
      atd_entity_id_txt,
      note_message,
      full_resp_code,
      document_id_txt

    ) VALUES (
      new_references.origination_id,
      new_references.ci_cal_type,
      new_references.ci_sequence_number,
      new_references.base_id,
      new_references.award_id,
      new_references.rfmb_id,
      new_references.sys_orig_ssn,
      new_references.sys_orig_name_cd,
      new_references.transaction_num,
      new_references.efc,
      new_references.ver_status_code,
      new_references.secondary_efc,
      new_references.secondary_efc_cd,
      new_references.pell_amount,
      new_references.enrollment_status,
      new_references.enrollment_dt,
      new_references.coa_amount,
      new_references.academic_calendar,
      new_references.payment_method,
      new_references.total_pymt_prds,
      new_references.incrcd_fed_pell_rcp_cd,
      new_references.attending_campus_id,
      new_references.est_disb_dt1,
      new_references.orig_action_code,
      new_references.orig_status_dt,
      new_references.orig_ed_use_flags,
      new_references.ft_pell_amount,
      new_references.prev_accpt_efc,
      new_references.prev_accpt_tran_no,
      new_references.prev_accpt_sec_efc_cd,
      new_references.prev_accpt_coa,
      new_references.orig_reject_code,
      new_references.wk_inst_time_calc_pymt,
      new_references.wk_int_time_prg_def_yr,
      new_references.cr_clk_hrs_prds_sch_yr,
      new_references.cr_clk_hrs_acad_yr,
      new_references.inst_cross_ref_cd,
      new_references.low_tution_fee,
      new_references.rec_source,
      new_references.pending_amount,
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
      new_references.birth_dt,
      new_references.last_name,
      new_references.first_name,
      new_references.middle_name,
      new_references.current_ssn,
      new_references.legacy_record_flag,
      new_references.reporting_pell_cd,
      new_references.rep_entity_id_txt,
      new_references.atd_entity_id_txt,
      new_references.note_message,
      new_references.full_resp_code,
      new_references.document_id_txt

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
    x_origination_id                    IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_rfmb_id                           IN     NUMBER,
    x_sys_orig_ssn                      IN     VARCHAR2,
    x_sys_orig_name_cd                  IN     VARCHAR2,
    x_transaction_num                   IN     VARCHAR2,
    x_efc                               IN     NUMBER,
    x_ver_status_code                   IN     VARCHAR2,
    x_secondary_efc                     IN     NUMBER,
    x_secondary_efc_cd                  IN     VARCHAR2,
    x_pell_amount                       IN     NUMBER,
    x_pell_profile                      IN     VARCHAR2,
    x_enrollment_status                 IN     VARCHAR2,
    x_enrollment_dt                     IN     DATE,
    x_coa_amount                        IN     NUMBER,
    x_academic_calendar                 IN     VARCHAR2,
    x_payment_method                    IN     VARCHAR2,
    x_total_pymt_prds                   IN     NUMBER,
    x_incrcd_fed_pell_rcp_cd            IN     VARCHAR2,
    x_attending_campus_id               IN     VARCHAR2,
    x_est_disb_dt1                      IN     DATE,
    x_orig_action_code                  IN     VARCHAR2,
    x_orig_status_dt                    IN     DATE,
    x_orig_ed_use_flags                 IN     VARCHAR2,
    x_ft_pell_amount                    IN     NUMBER,
    x_prev_accpt_efc                    IN     NUMBER,
    x_prev_accpt_tran_no                IN     VARCHAR2,
    x_prev_accpt_sec_efc_cd             IN     VARCHAR2,
    x_prev_accpt_coa                    IN     NUMBER,
    x_orig_reject_code                  IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER,
    x_wk_int_time_prg_def_yr            IN     NUMBER,
    x_cr_clk_hrs_prds_sch_yr            IN     NUMBER,
    x_cr_clk_hrs_acad_yr                IN     NUMBER,
    x_inst_cross_ref_cd                 IN     VARCHAR2,
    x_low_tution_fee                    IN     VARCHAR2,
    x_rec_source                        IN     VARCHAR2,
    x_pending_amount			IN     NUMBER,
    x_birth_dt                          IN     DATE,
    x_last_name                         IN     VARCHAR2,
    x_first_name                        IN     VARCHAR2,
    x_middle_name                       IN     VARCHAR2,
    x_current_ssn                       IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2,
    x_reporting_pell_cd                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_note_message                      IN     VARCHAR2,
    x_full_resp_code                    IN     VARCHAR2,
    x_document_id_txt                   IN     VARCHAR2


  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 15-JAN-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        ci_cal_type,
        ci_sequence_number,
        base_id,
        award_id,
        rfmb_id,
        sys_orig_ssn,
        sys_orig_name_cd,
        transaction_num,
        efc,
        ver_status_code,
        secondary_efc,
        secondary_efc_cd,
        pell_amount,
        enrollment_status,
        enrollment_dt,
        coa_amount,
        academic_calendar,
        payment_method,
        total_pymt_prds,
        incrcd_fed_pell_rcp_cd,
        attending_campus_id,
        est_disb_dt1,
        orig_action_code,
        orig_status_dt,
        orig_ed_use_flags,
        ft_pell_amount,
        prev_accpt_efc,
        prev_accpt_tran_no,
        prev_accpt_sec_efc_cd,
        prev_accpt_coa,
        orig_reject_code,
        wk_inst_time_calc_pymt,
        wk_int_time_prg_def_yr,
        cr_clk_hrs_prds_sch_yr,
        cr_clk_hrs_acad_yr,
        inst_cross_ref_cd,
        low_tution_fee,
        rec_source,
	pending_amount,
        birth_dt,
        last_name,
        first_name,
        middle_name,
        current_ssn,
        legacy_record_flag,
        reporting_pell_cd,
        rep_entity_id_txt,
        atd_entity_id_txt,
        note_message,
        full_resp_code,
        document_id_txt

      FROM  igf_gr_rfms_all
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
        AND (tlinfo.base_id = x_base_id)
        AND (tlinfo.award_id = x_award_id)
        AND ((tlinfo.rfmb_id = x_rfmb_id) OR ((tlinfo.rfmb_id IS NULL) AND (X_rfmb_id IS NULL)))
        AND ((tlinfo.sys_orig_ssn = x_sys_orig_ssn) OR ((tlinfo.sys_orig_ssn IS NULL) AND (X_sys_orig_ssn IS NULL)))
        AND ((tlinfo.sys_orig_name_cd = x_sys_orig_name_cd) OR ((tlinfo.sys_orig_name_cd IS NULL) AND (X_sys_orig_name_cd IS NULL)))
        AND ((tlinfo.transaction_num = x_transaction_num) OR ((tlinfo.transaction_num IS NULL) AND (X_transaction_num IS NULL)))
        AND ((tlinfo.efc = x_efc) OR ((tlinfo.efc IS NULL) AND (X_efc IS NULL)))
        AND ((tlinfo.ver_status_code = x_ver_status_code) OR ((tlinfo.ver_status_code IS NULL) AND (X_ver_status_code IS NULL)))
        AND ((tlinfo.secondary_efc = x_secondary_efc) OR ((tlinfo.secondary_efc IS NULL) AND (X_secondary_efc IS NULL)))
        AND ((tlinfo.secondary_efc_cd = x_secondary_efc_cd) OR ((tlinfo.secondary_efc_cd IS NULL) AND (X_secondary_efc_cd IS NULL)))
        AND (tlinfo.pell_amount = x_pell_amount)
        AND ((tlinfo.enrollment_status = x_enrollment_status) OR ((tlinfo.enrollment_status IS NULL) AND (X_enrollment_status IS NULL)))
        AND ((tlinfo.enrollment_dt = x_enrollment_dt) OR ((tlinfo.enrollment_dt IS NULL) AND (X_enrollment_dt IS NULL)))
        AND ((tlinfo.coa_amount = x_coa_amount) OR ((tlinfo.coa_amount IS NULL) AND (X_coa_amount IS NULL)))
        AND ((tlinfo.academic_calendar = x_academic_calendar) OR ((tlinfo.academic_calendar IS NULL) AND (X_academic_calendar IS NULL)))
        AND ((tlinfo.payment_method = x_payment_method) OR ((tlinfo.payment_method IS NULL) AND (X_payment_method IS NULL)))
        AND ((tlinfo.total_pymt_prds = x_total_pymt_prds) OR ((tlinfo.total_pymt_prds IS NULL) AND (X_total_pymt_prds IS NULL)))
        AND ((tlinfo.incrcd_fed_pell_rcp_cd = x_incrcd_fed_pell_rcp_cd) OR ((tlinfo.incrcd_fed_pell_rcp_cd IS NULL) AND (X_incrcd_fed_pell_rcp_cd IS NULL)))
        AND ((tlinfo.attending_campus_id = x_attending_campus_id) OR ((tlinfo.attending_campus_id IS NULL) AND (X_attending_campus_id IS NULL)))
        AND ((tlinfo.est_disb_dt1 = x_est_disb_dt1) OR ((tlinfo.est_disb_dt1 IS NULL) AND (X_est_disb_dt1 IS NULL)))
        AND ((tlinfo.orig_action_code = x_orig_action_code) OR ((tlinfo.orig_action_code IS NULL) AND (X_orig_action_code IS NULL)))
        AND ((tlinfo.orig_status_dt = x_orig_status_dt) OR ((tlinfo.orig_status_dt IS NULL) AND (X_orig_status_dt IS NULL)))
        AND ((tlinfo.orig_ed_use_flags = x_orig_ed_use_flags) OR ((tlinfo.orig_ed_use_flags IS NULL) AND (X_orig_ed_use_flags IS NULL)))
        AND ((tlinfo.ft_pell_amount = x_ft_pell_amount) OR ((tlinfo.ft_pell_amount IS NULL) AND (X_ft_pell_amount IS NULL)))
        AND ((tlinfo.prev_accpt_efc = x_prev_accpt_efc) OR ((tlinfo.prev_accpt_efc IS NULL) AND (X_prev_accpt_efc IS NULL)))
        AND ((tlinfo.prev_accpt_tran_no = x_prev_accpt_tran_no) OR ((tlinfo.prev_accpt_tran_no IS NULL) AND (X_prev_accpt_tran_no IS NULL)))
        AND ((tlinfo.prev_accpt_sec_efc_cd = x_prev_accpt_sec_efc_cd) OR ((tlinfo.prev_accpt_sec_efc_cd IS NULL) AND (X_prev_accpt_sec_efc_cd IS NULL)))
        AND ((tlinfo.prev_accpt_coa = x_prev_accpt_coa) OR ((tlinfo.prev_accpt_coa IS NULL) AND (X_prev_accpt_coa IS NULL)))
        AND ((tlinfo.orig_reject_code = x_orig_reject_code) OR ((tlinfo.orig_reject_code IS NULL) AND (X_orig_reject_code IS NULL)))
        AND ((tlinfo.wk_inst_time_calc_pymt = x_wk_inst_time_calc_pymt) OR ((tlinfo.wk_inst_time_calc_pymt IS NULL) AND (X_wk_inst_time_calc_pymt IS NULL)))
        AND ((tlinfo.wk_int_time_prg_def_yr = x_wk_int_time_prg_def_yr) OR ((tlinfo.wk_int_time_prg_def_yr IS NULL) AND (X_wk_int_time_prg_def_yr IS NULL)))
        AND ((tlinfo.cr_clk_hrs_prds_sch_yr = x_cr_clk_hrs_prds_sch_yr) OR ((tlinfo.cr_clk_hrs_prds_sch_yr IS NULL) AND (X_cr_clk_hrs_prds_sch_yr IS NULL)))
        AND ((tlinfo.cr_clk_hrs_acad_yr = x_cr_clk_hrs_acad_yr) OR ((tlinfo.cr_clk_hrs_acad_yr IS NULL) AND (X_cr_clk_hrs_acad_yr IS NULL)))
        AND ((tlinfo.inst_cross_ref_cd = x_inst_cross_ref_cd) OR ((tlinfo.inst_cross_ref_cd IS NULL) AND (X_inst_cross_ref_cd IS NULL)))
        AND ((tlinfo.low_tution_fee = x_low_tution_fee) OR ((tlinfo.low_tution_fee IS NULL) AND (X_low_tution_fee IS NULL)))
        AND ((tlinfo.rec_source = x_rec_source) OR ((tlinfo.rec_source IS NULL) AND (X_rec_source IS NULL)))
        AND ((tlinfo.pending_amount = x_pending_amount) OR ((tlinfo.pending_amount IS NULL) AND (x_pending_amount IS NULL)))
        AND ((tlinfo.birth_dt = x_birth_dt) OR ((tlinfo.birth_dt IS NULL) AND (x_birth_dt IS NULL)))
        AND ((tlinfo.last_name = x_last_name) OR ((tlinfo.last_name IS NULL) AND (x_last_name IS NULL)))
        AND ((tlinfo.first_name = x_first_name) OR ((tlinfo.first_name IS NULL) AND (x_first_name IS NULL)))
        AND ((tlinfo.middle_name = x_middle_name) OR ((tlinfo.middle_name IS NULL) AND (x_middle_name IS NULL)))
        AND ((tlinfo.current_ssn = x_current_ssn) OR ((tlinfo.current_ssn IS NULL) AND (x_current_ssn IS NULL)))
        AND ((tlinfo.legacy_record_flag = x_legacy_record_flag) OR ((tlinfo.legacy_record_flag IS NULL) AND (x_legacy_record_flag IS NULL)))
        AND ((tlinfo.reporting_pell_cd = x_reporting_pell_cd) OR ((tlinfo.reporting_pell_cd IS NULL) AND (x_reporting_pell_cd IS NULL)))
        AND ((tlinfo.rep_entity_id_txt = x_rep_entity_id_txt) OR ((tlinfo.rep_entity_id_txt IS NULL) AND (x_rep_entity_id_txt IS NULL)))
        AND ((tlinfo.atd_entity_id_txt = x_atd_entity_id_txt) OR ((tlinfo.atd_entity_id_txt IS NULL) AND (x_atd_entity_id_txt IS NULL)))
        AND ((tlinfo.note_message = x_note_message) OR ((tlinfo.note_message IS NULL) AND (x_note_message IS NULL)))
        AND ((tlinfo.full_resp_code = x_full_resp_code) OR ((tlinfo.full_resp_code IS NULL) AND (x_full_resp_code IS NULL)))
        AND ((tlinfo.document_id_txt = x_document_id_txt) OR ((tlinfo.document_id_txt IS NULL) AND (x_document_id_txt IS NULL)))

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
    x_origination_id                    IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_rfmb_id                           IN     NUMBER,
    x_sys_orig_ssn                      IN     VARCHAR2,
    x_sys_orig_name_cd                  IN     VARCHAR2,
    x_transaction_num                   IN     VARCHAR2,
    x_efc                               IN     NUMBER,
    x_ver_status_code                   IN     VARCHAR2,
    x_secondary_efc                     IN     NUMBER,
    x_secondary_efc_cd                  IN     VARCHAR2,
    x_pell_amount                       IN     NUMBER,
    x_pell_profile                      IN     VARCHAR2,
    x_enrollment_status                 IN     VARCHAR2,
    x_enrollment_dt                     IN     DATE,
    x_coa_amount                        IN     NUMBER,
    x_academic_calendar                 IN     VARCHAR2,
    x_payment_method                    IN     VARCHAR2,
    x_total_pymt_prds                   IN     NUMBER,
    x_incrcd_fed_pell_rcp_cd            IN     VARCHAR2,
    x_attending_campus_id               IN     VARCHAR2,
    x_est_disb_dt1                      IN     DATE,
    x_orig_action_code                  IN     VARCHAR2,
    x_orig_status_dt                    IN     DATE,
    x_orig_ed_use_flags                 IN     VARCHAR2,
    x_ft_pell_amount                    IN     NUMBER,
    x_prev_accpt_efc                    IN     NUMBER,
    x_prev_accpt_tran_no                IN     VARCHAR2,
    x_prev_accpt_sec_efc_cd             IN     VARCHAR2,
    x_prev_accpt_coa                    IN     NUMBER,
    x_orig_reject_code                  IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER,
    x_wk_int_time_prg_def_yr            IN     NUMBER,
    x_cr_clk_hrs_prds_sch_yr            IN     NUMBER,
    x_cr_clk_hrs_acad_yr                IN     NUMBER,
    x_inst_cross_ref_cd                 IN     VARCHAR2,
    x_low_tution_fee                    IN     VARCHAR2,
    x_rec_source                        IN     VARCHAR2,
    x_pending_amount			     IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_last_name                         IN     VARCHAR2,
    x_first_name                        IN     VARCHAR2,
    x_middle_name                       IN     VARCHAR2,
    x_current_ssn                       IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2,
    x_reporting_pell_cd                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_note_message                      IN     VARCHAR2,
    x_full_resp_code                    IN     VARCHAR2,
    x_document_id_txt                   IN     VARCHAR2

  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 15-JAN-2001
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
      x_origination_id                    => x_origination_id,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_base_id                           => x_base_id,
      x_award_id                          => x_award_id,
      x_rfmb_id                           => x_rfmb_id,
      x_sys_orig_ssn                      => x_sys_orig_ssn,
      x_sys_orig_name_cd                  => x_sys_orig_name_cd,
      x_transaction_num                   => x_transaction_num,
      x_efc                               => x_efc,
      x_ver_status_code                   => x_ver_status_code,
      x_secondary_efc                     => x_secondary_efc,
      x_secondary_efc_cd                  => x_secondary_efc_cd,
      x_pell_amount                       => x_pell_amount,
      x_pell_profile                      => x_pell_profile,
      x_enrollment_status                 => x_enrollment_status,
      x_enrollment_dt                     => x_enrollment_dt,
      x_coa_amount                        => x_coa_amount,
      x_academic_calendar                 => x_academic_calendar,
      x_payment_method                    => x_payment_method,
      x_total_pymt_prds                   => x_total_pymt_prds,
      x_incrcd_fed_pell_rcp_cd            => x_incrcd_fed_pell_rcp_cd,
      x_attending_campus_id               => x_attending_campus_id,
      x_est_disb_dt1                      => x_est_disb_dt1,
      x_orig_action_code                  => x_orig_action_code,
      x_orig_status_dt                    => x_orig_status_dt,
      x_orig_ed_use_flags                 => x_orig_ed_use_flags,
      x_ft_pell_amount                    => x_ft_pell_amount,
      x_prev_accpt_efc                    => x_prev_accpt_efc,
      x_prev_accpt_tran_no                => x_prev_accpt_tran_no,
      x_prev_accpt_sec_efc_cd             => x_prev_accpt_sec_efc_cd,
      x_prev_accpt_coa                    => x_prev_accpt_coa,
      x_orig_reject_code                  => x_orig_reject_code,
      x_wk_inst_time_calc_pymt            => x_wk_inst_time_calc_pymt,
      x_wk_int_time_prg_def_yr            => x_wk_int_time_prg_def_yr,
      x_cr_clk_hrs_prds_sch_yr            => x_cr_clk_hrs_prds_sch_yr,
      x_cr_clk_hrs_acad_yr                => x_cr_clk_hrs_acad_yr,
      x_inst_cross_ref_cd                 => x_inst_cross_ref_cd,
      x_low_tution_fee                    => x_low_tution_fee,
      x_rec_source                        => x_rec_source,
      x_pending_amount                    => x_pending_amount,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_birth_dt                          => x_birth_dt,
      x_last_name                         => x_last_name,
      x_first_name                        => x_first_name,
      x_middle_name                       => x_middle_name,
      x_current_ssn                       => x_current_ssn,
      x_legacy_record_flag                => x_legacy_record_flag,
      x_reporting_pell_cd                 => x_reporting_pell_cd,
      x_rep_entity_id_txt                 => x_rep_entity_id_txt,
      x_atd_entity_id_txt                 => x_atd_entity_id_txt,
      x_note_message                      => x_note_message,
      x_full_resp_code                    => x_full_resp_code,
      x_document_id_txt                   => x_document_id_txt

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

    UPDATE igf_gr_rfms_all
      SET
        ci_cal_type                       = new_references.ci_cal_type,
        ci_sequence_number                = new_references.ci_sequence_number,
        base_id                           = new_references.base_id,
        award_id                          = new_references.award_id,
        rfmb_id                           = new_references.rfmb_id,
        sys_orig_ssn                      = new_references.sys_orig_ssn,
        sys_orig_name_cd                  = new_references.sys_orig_name_cd,
        transaction_num                   = new_references.transaction_num,
        efc                               = new_references.efc,
        ver_status_code                   = new_references.ver_status_code,
        secondary_efc                     = new_references.secondary_efc,
        secondary_efc_cd                  = new_references.secondary_efc_cd,
        pell_amount                       = new_references.pell_amount,
        enrollment_status                 = new_references.enrollment_status,
        enrollment_dt                     = new_references.enrollment_dt,
        coa_amount                        = new_references.coa_amount,
        academic_calendar                 = new_references.academic_calendar,
        payment_method                    = new_references.payment_method,
        total_pymt_prds                   = new_references.total_pymt_prds,
        incrcd_fed_pell_rcp_cd            = new_references.incrcd_fed_pell_rcp_cd,
        attending_campus_id               = new_references.attending_campus_id,
        est_disb_dt1                      = new_references.est_disb_dt1,
        orig_action_code                  = new_references.orig_action_code,
        orig_status_dt                    = new_references.orig_status_dt,
        orig_ed_use_flags                 = new_references.orig_ed_use_flags,
        ft_pell_amount                    = new_references.ft_pell_amount,
        prev_accpt_efc                    = new_references.prev_accpt_efc,
        prev_accpt_tran_no                = new_references.prev_accpt_tran_no,
        prev_accpt_sec_efc_cd             = new_references.prev_accpt_sec_efc_cd,
        prev_accpt_coa                    = new_references.prev_accpt_coa,
        orig_reject_code                  = new_references.orig_reject_code,
        wk_inst_time_calc_pymt            = new_references.wk_inst_time_calc_pymt,
        wk_int_time_prg_def_yr            = new_references.wk_int_time_prg_def_yr,
        cr_clk_hrs_prds_sch_yr            = new_references.cr_clk_hrs_prds_sch_yr,
        cr_clk_hrs_acad_yr                = new_references.cr_clk_hrs_acad_yr,
        inst_cross_ref_cd                 = new_references.inst_cross_ref_cd,
        low_tution_fee                    = new_references.low_tution_fee,
        rec_source                        = new_references.rec_source,
	pending_amount			  = new_references.pending_amount,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        birth_dt                          = new_references.birth_dt,
        last_name                         = new_references.last_name,
        first_name                        = new_references.first_name,
        middle_name                       = new_references.middle_name,
        current_ssn                       = new_references.current_ssn,
        legacy_record_flag                = new_references.legacy_record_flag,
        reporting_pell_cd                 = new_references.reporting_pell_cd,
        rep_entity_id_txt                 = new_references.rep_entity_id_txt,
        atd_entity_id_txt                 = new_references.atd_entity_id_txt,
        note_message                      = new_references.note_message,
        full_resp_code                    = new_references.full_resp_code,
        document_id_txt                   = new_references.document_id_txt

      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_origination_id                    IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_rfmb_id                           IN     NUMBER,
    x_sys_orig_ssn                      IN     VARCHAR2,
    x_sys_orig_name_cd                  IN     VARCHAR2,
    x_transaction_num                   IN     VARCHAR2,
    x_efc                               IN     NUMBER,
    x_ver_status_code                   IN     VARCHAR2,
    x_secondary_efc                     IN     NUMBER,
    x_secondary_efc_cd                  IN     VARCHAR2,
    x_pell_amount                       IN     NUMBER,
    x_pell_profile                      IN     VARCHAR2,
    x_enrollment_status                 IN     VARCHAR2,
    x_enrollment_dt                     IN     DATE,
    x_coa_amount                        IN     NUMBER,
    x_academic_calendar                 IN     VARCHAR2,
    x_payment_method                    IN     VARCHAR2,
    x_total_pymt_prds                   IN     NUMBER,
    x_incrcd_fed_pell_rcp_cd            IN     VARCHAR2,
    x_attending_campus_id               IN     VARCHAR2,
    x_est_disb_dt1                      IN     DATE,
    x_orig_action_code                  IN     VARCHAR2,
    x_orig_status_dt                    IN     DATE,
    x_orig_ed_use_flags                 IN     VARCHAR2,
    x_ft_pell_amount                    IN     NUMBER,
    x_prev_accpt_efc                    IN     NUMBER,
    x_prev_accpt_tran_no                IN     VARCHAR2,
    x_prev_accpt_sec_efc_cd             IN     VARCHAR2,
    x_prev_accpt_coa                    IN     NUMBER,
    x_orig_reject_code                  IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER,
    x_wk_int_time_prg_def_yr            IN     NUMBER,
    x_cr_clk_hrs_prds_sch_yr            IN     NUMBER,
    x_cr_clk_hrs_acad_yr                IN     NUMBER,
    x_inst_cross_ref_cd                 IN     VARCHAR2,
    x_low_tution_fee                    IN     VARCHAR2,
    x_rec_source                        IN     VARCHAR2,
    x_pending_amount			     IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_last_name                         IN     VARCHAR2,
    x_first_name                        IN     VARCHAR2,
    x_middle_name                       IN     VARCHAR2,
    x_current_ssn                       IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2,
    x_reporting_pell_cd                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_note_message                      IN     VARCHAR2,
    x_full_resp_code                    IN     VARCHAR2,
    x_document_id_txt                   IN     VARCHAR2

  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 15-JAN-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_gr_rfms_all
      WHERE    origination_id                    = x_origination_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_origination_id,
        x_ci_cal_type,
        x_ci_sequence_number,
        x_base_id,
        x_award_id,
        x_rfmb_id,
        x_sys_orig_ssn,
        x_sys_orig_name_cd,
        x_transaction_num,
        x_efc,
        x_ver_status_code,
        x_secondary_efc,
        x_secondary_efc_cd,
        x_pell_amount,
        x_pell_profile,
        x_enrollment_status,
        x_enrollment_dt,
        x_coa_amount,
        x_academic_calendar,
        x_payment_method,
        x_total_pymt_prds,
        x_incrcd_fed_pell_rcp_cd,
        x_attending_campus_id,
        x_est_disb_dt1,
        x_orig_action_code,
        x_orig_status_dt,
        x_orig_ed_use_flags,
        x_ft_pell_amount,
        x_prev_accpt_efc,
        x_prev_accpt_tran_no,
        x_prev_accpt_sec_efc_cd,
        x_prev_accpt_coa,
        x_orig_reject_code,
        x_wk_inst_time_calc_pymt,
        x_wk_int_time_prg_def_yr,
        x_cr_clk_hrs_prds_sch_yr,
        x_cr_clk_hrs_acad_yr,
        x_inst_cross_ref_cd,
        x_low_tution_fee,
        x_rec_source,
        x_pending_amount,
        x_mode,
        x_birth_dt,
        x_last_name,
        x_first_name,
        x_middle_name,
        x_current_ssn,
        x_legacy_record_flag,
        x_reporting_pell_cd,
        x_rep_entity_id_txt,
        x_atd_entity_id_txt,
        x_note_message,
        x_full_resp_code,
        x_document_id_txt

        );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_origination_id,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_base_id,
      x_award_id,
      x_rfmb_id,
      x_sys_orig_ssn,
      x_sys_orig_name_cd,
      x_transaction_num,
      x_efc,
      x_ver_status_code,
      x_secondary_efc,
      x_secondary_efc_cd,
      x_pell_amount,
      x_pell_profile,
      x_enrollment_status,
      x_enrollment_dt,
      x_coa_amount,
      x_academic_calendar,
      x_payment_method,
      x_total_pymt_prds,
      x_incrcd_fed_pell_rcp_cd,
      x_attending_campus_id,
      x_est_disb_dt1,
      x_orig_action_code,
      x_orig_status_dt,
      x_orig_ed_use_flags,
      x_ft_pell_amount,
      x_prev_accpt_efc,
      x_prev_accpt_tran_no,
      x_prev_accpt_sec_efc_cd,
      x_prev_accpt_coa,
      x_orig_reject_code,
      x_wk_inst_time_calc_pymt,
      x_wk_int_time_prg_def_yr,
      x_cr_clk_hrs_prds_sch_yr,
      x_cr_clk_hrs_acad_yr,
      x_inst_cross_ref_cd,
      x_low_tution_fee,
      x_rec_source,
      x_pending_amount,
      x_mode,
      x_birth_dt,
      x_last_name,
      x_first_name,
      x_middle_name,
      x_current_ssn,
      x_legacy_record_flag,
      x_reporting_pell_cd,
      x_rep_entity_id_txt,
      x_atd_entity_id_txt,
      x_note_message,
      x_full_resp_code,
      x_document_id_txt

    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 15-JAN-2001
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

    DELETE FROM igf_gr_rfms_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_gr_rfms_pkg;

/
