--------------------------------------------------------
--  DDL for Package Body IGF_AP_FA_BASE_REC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_FA_BASE_REC_PKG" AS
/* $Header: IGFAI03B.pls 120.0 2005/06/02 15:52:58 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_ap_fa_base_rec_all%ROWTYPE;
  new_references igf_ap_fa_base_rec_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2  ,
    x_base_id                           IN     NUMBER    ,
    x_ci_cal_type                       IN     VARCHAR2  ,
    x_person_id                         IN     NUMBER    ,
    x_ci_sequence_number                IN     NUMBER    ,
    x_org_id                            IN     NUMBER    ,
    x_coa_pending                       IN     VARCHAR2  ,
    x_verification_process_run          IN     VARCHAR2  ,
    x_inst_verif_status_date            IN     DATE      ,
    x_manual_verif_flag                 IN     VARCHAR2  ,
    x_fed_verif_status                  IN     VARCHAR2  ,
    x_fed_verif_status_date             IN     DATE      ,
    x_inst_verif_status                 IN     VARCHAR2  ,
    x_nslds_eligible                    IN     VARCHAR2  ,
    x_ede_correction_batch_id           IN     VARCHAR2  , -- Modified by rbezawad on 22-Jun-2001 w.r.t. Bug ID: 1821811
    x_fa_process_status_date            IN     DATE      ,
    x_isir_corr_status                  IN     VARCHAR2  ,
    x_isir_corr_status_date             IN     DATE      ,
    x_isir_status                       IN     VARCHAR2  ,
    x_isir_status_date                  IN     DATE      ,
    x_coa_code_f                        IN     VARCHAR2  ,
    x_coa_code_i                        IN     VARCHAR2  ,
    x_coa_f                             IN     NUMBER    ,
    x_coa_i                             IN     NUMBER    ,
    x_disbursement_hold                 IN     VARCHAR2  ,
    x_fa_process_status                 IN     VARCHAR2  ,
    x_notification_status               IN     VARCHAR2  ,
    x_notification_status_date          IN     DATE      ,
    x_packaging_status                  IN     VARCHAR2  ,
    x_packaging_status_date             IN     DATE      ,
    x_total_package_accepted            IN     NUMBER    ,
    x_total_package_offered             IN     NUMBER    ,
    x_admstruct_id                      IN     VARCHAR2  ,
    x_admsegment_1                      IN     VARCHAR2  ,
    x_admsegment_2                      IN     VARCHAR2  ,
    x_admsegment_3                      IN     VARCHAR2  ,
    x_admsegment_4                      IN     VARCHAR2  ,
    x_admsegment_5                      IN     VARCHAR2  ,
    x_admsegment_6                      IN     VARCHAR2  ,
    x_admsegment_7                      IN     VARCHAR2  ,
    x_admsegment_8                      IN     VARCHAR2  ,
    x_admsegment_9                      IN     VARCHAR2  ,
    x_admsegment_10                     IN     VARCHAR2  ,
    x_admsegment_11                     IN     VARCHAR2  ,
    x_admsegment_12                     IN     VARCHAR2  ,
    x_admsegment_13                     IN     VARCHAR2  ,
    x_admsegment_14                     IN     VARCHAR2  ,
    x_admsegment_15                     IN     VARCHAR2  ,
    x_admsegment_16                     IN     VARCHAR2  ,
    x_admsegment_17                     IN     VARCHAR2  ,
    x_admsegment_18                     IN     VARCHAR2  ,
    x_admsegment_19                     IN     VARCHAR2  ,
    x_admsegment_20                     IN     VARCHAR2  ,
    x_packstruct_id                     IN     VARCHAR2  ,
    x_packsegment_1                     IN     VARCHAR2  ,
    x_packsegment_2                     IN     VARCHAR2  ,
    x_packsegment_3                     IN     VARCHAR2  ,
    x_packsegment_4                     IN     VARCHAR2  ,
    x_packsegment_5                     IN     VARCHAR2  ,
    x_packsegment_6                     IN     VARCHAR2  ,
    x_packsegment_7                     IN     VARCHAR2  ,
    x_packsegment_8                     IN     VARCHAR2  ,
    x_packsegment_9                     IN     VARCHAR2  ,
    x_packsegment_10                    IN     VARCHAR2  ,
    x_packsegment_11                    IN     VARCHAR2  ,
    x_packsegment_12                    IN     VARCHAR2  ,
    x_packsegment_13                    IN     VARCHAR2  ,
    x_packsegment_14                    IN     VARCHAR2  ,
    x_packsegment_15                    IN     VARCHAR2  ,
    x_packsegment_16                    IN     VARCHAR2  ,
    x_packsegment_17                    IN     VARCHAR2  ,
    x_packsegment_18                    IN     VARCHAR2  ,
    x_packsegment_19                    IN     VARCHAR2  ,
    x_packsegment_20                    IN     VARCHAR2  ,
    x_miscstruct_id                     IN     VARCHAR2  ,
    x_miscsegment_1                     IN     VARCHAR2  ,
    x_miscsegment_2                     IN     VARCHAR2  ,
    x_miscsegment_3                     IN     VARCHAR2  ,
    x_miscsegment_4                     IN     VARCHAR2  ,
    x_miscsegment_5                     IN     VARCHAR2  ,
    x_miscsegment_6                     IN     VARCHAR2  ,
    x_miscsegment_7                     IN     VARCHAR2  ,
    x_miscsegment_8                     IN     VARCHAR2  ,
    x_miscsegment_9                     IN     VARCHAR2  ,
    x_miscsegment_10                    IN     VARCHAR2  ,
    x_miscsegment_11                    IN     VARCHAR2  ,
    x_miscsegment_12                    IN     VARCHAR2  ,
    x_miscsegment_13                    IN     VARCHAR2  ,
    x_miscsegment_14                    IN     VARCHAR2  ,
    x_miscsegment_15                    IN     VARCHAR2  ,
    x_miscsegment_16                    IN     VARCHAR2  ,
    x_miscsegment_17                    IN     VARCHAR2  ,
    x_miscsegment_18                    IN     VARCHAR2  ,
    x_miscsegment_19                    IN     VARCHAR2  ,
    x_miscsegment_20                    IN     VARCHAR2  ,
    x_prof_judgement_flg                IN     VARCHAR2  ,
    x_nslds_data_override_flg           IN     VARCHAR2  ,
    x_target_group                      IN     VARCHAR2  ,
    x_coa_fixed                         IN     NUMBER    ,
    x_coa_pell                          IN     NUMBER    ,
    x_profile_status                    IN     VARCHAR2  ,
    x_profile_status_date               IN     DATE      ,
    x_profile_fc                        IN     NUMBER    ,
    x_tolerance_amount                  IN     NUMBER    ,    --Modified by kkillams on 28- June-2001 w.r.t. bug 1794114
    x_creation_date                     IN     DATE      ,
    x_created_by                        IN     NUMBER    ,
    x_last_update_date                  IN     DATE      ,
    x_last_updated_by                   IN     NUMBER    ,
    x_last_update_login                 IN     NUMBER    ,
    x_manual_disb_hold                  IN     VARCHAR2  ,
    x_pell_alt_expense                  IN     NUMBER    ,
    x_assoc_org_num                     IN     NUMBER    ,       --Modified by ugummall on 25-SEP-2003 w.r.t FA 126 - Multiple FA Offices
    x_award_fmly_contribution_type      IN     VARCHAR2  ,          --Modified by rasahoo  on 17-NOV-2003 w.r.t FA 128 ISIR update 20004-05
    x_isir_locked_by                    IN     VARCHAR2  ,
    x_adnl_unsub_loan_elig_flag         IN     VARCHAR2  ,
    x_lock_awd_flag                     IN     VARCHAR2  ,
    x_lock_coa_flag                     IN     VARCHAR2
  ) AS
  /*
  ||  Created By : skoppula
  ||  Created On : 07-DEC-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
       -- removed packaging hold
  ||  masehgal        25-Sep-2002     FA 014 -To Do Enhancements
  ||                                  Added manual_disb_hold checkbox
  ||  rbezawad         22-Jun-2001
  ||                  x_ede_correction_batch_id parameter in procedures is
  ||                  changed to VARCHAR2 Datatype w.r.t. Bug ID: 1821811.
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_ap_fa_base_rec_all
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;
    --Code for the calculation of the Need Based on the Cost of Attendence and the Effective Family Contribution

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.base_id                           := x_base_id;
    new_references.ci_cal_type                       := x_ci_cal_type;
    new_references.person_id                         := x_person_id;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.org_id                            := x_org_id;
    new_references.coa_pending                       := x_coa_pending;
    new_references.verification_process_run          := x_verification_process_run;
    new_references.inst_verif_status_date            := x_inst_verif_status_date;
    new_references.manual_verif_flag                 := x_manual_verif_flag;
    new_references.fed_verif_status                  := x_fed_verif_status;
    new_references.fed_verif_status_date             := x_fed_verif_status_date;
    new_references.inst_verif_status                 := x_inst_verif_status;
    new_references.nslds_eligible                    := x_nslds_eligible;
    new_references.ede_correction_batch_id           := x_ede_correction_batch_id;
    new_references.fa_process_status_date            := x_fa_process_status_date;
    new_references.isir_corr_status                  := x_isir_corr_status;
    new_references.isir_corr_status_date             := x_isir_corr_status_date;
    new_references.isir_status                       := x_isir_status;
    new_references.isir_status_date                  := x_isir_status_date;
    new_references.coa_code_f                        := x_coa_code_f;
    new_references.coa_code_i                        := x_coa_code_i;
    new_references.coa_f                             := x_coa_f;
    new_references.coa_i                             := x_coa_i;
    new_references.disbursement_hold                 := x_disbursement_hold;

    -- The following code is commented bcoz, these columns are no longer used in the OSS_FAM
    -- these columns are getting populated thru either from OSS_interface table or from OSS tables
    -- To avoid the lock row problems and to have data always NULL we have commented the code and passing always


    new_references.fa_process_status                 := x_fa_process_status;
    new_references.notification_status               := x_notification_status;
    new_references.notification_status_date          := x_notification_status_date;
    new_references.packaging_status                  := x_packaging_status;
    new_references.packaging_status_date             := x_packaging_status_date;
    new_references.total_package_accepted            := x_total_package_accepted;
    new_references.total_package_offered             := x_total_package_offered;
    new_references.admstruct_id                      := x_admstruct_id;
    new_references.admsegment_1                      := x_admsegment_1;
    new_references.admsegment_2                      := x_admsegment_2;
    new_references.admsegment_3                      := x_admsegment_3;
    new_references.admsegment_4                      := x_admsegment_4;
    new_references.admsegment_5                      := x_admsegment_5;
    new_references.admsegment_6                      := x_admsegment_6;
    new_references.admsegment_7                      := x_admsegment_7;
    new_references.admsegment_8                      := x_admsegment_8;
    new_references.admsegment_9                      := x_admsegment_9;
    new_references.admsegment_10                     := x_admsegment_10;
    new_references.admsegment_11                     := x_admsegment_11;
    new_references.admsegment_12                     := x_admsegment_12;
    new_references.admsegment_13                     := x_admsegment_13;
    new_references.admsegment_14                     := x_admsegment_14;
    new_references.admsegment_15                     := x_admsegment_15;
    new_references.admsegment_16                     := x_admsegment_16;
    new_references.admsegment_17                     := x_admsegment_17;
    new_references.admsegment_18                     := x_admsegment_18;
    new_references.admsegment_19                     := x_admsegment_19;
    new_references.admsegment_20                     := x_admsegment_20;
    new_references.packstruct_id                     := x_packstruct_id;
    new_references.packsegment_1                     := x_packsegment_1;
    new_references.packsegment_2                     := x_packsegment_2;
    new_references.packsegment_3                     := x_packsegment_3;
    new_references.packsegment_4                     := x_packsegment_4;
    new_references.packsegment_5                     := x_packsegment_5;
    new_references.packsegment_6                     := x_packsegment_6;
    new_references.packsegment_7                     := x_packsegment_7;
    new_references.packsegment_8                     := x_packsegment_8;
    new_references.packsegment_9                     := x_packsegment_9;
    new_references.packsegment_10                    := x_packsegment_10;
    new_references.packsegment_11                    := x_packsegment_11;
    new_references.packsegment_12                    := x_packsegment_12;
    new_references.packsegment_13                    := x_packsegment_13;
    new_references.packsegment_14                    := x_packsegment_14;
    new_references.packsegment_15                    := x_packsegment_15;
    new_references.packsegment_16                    := x_packsegment_16;
    new_references.packsegment_17                    := x_packsegment_17;
    new_references.packsegment_18                    := x_packsegment_18;
    new_references.packsegment_19                    := x_packsegment_19;
    new_references.packsegment_20                    := x_packsegment_20;
    new_references.miscstruct_id                     := x_miscstruct_id;
    new_references.miscsegment_1                     := x_miscsegment_1;
    new_references.miscsegment_2                     := x_miscsegment_2;
    new_references.miscsegment_3                     := x_miscsegment_3;
    new_references.miscsegment_4                     := x_miscsegment_4;
    new_references.miscsegment_5                     := x_miscsegment_5;
    new_references.miscsegment_6                     := x_miscsegment_6;
    new_references.miscsegment_7                     := x_miscsegment_7;
    new_references.miscsegment_8                     := x_miscsegment_8;
    new_references.miscsegment_9                     := x_miscsegment_9;
    new_references.miscsegment_10                    := x_miscsegment_10;
    new_references.miscsegment_11                    := x_miscsegment_11;
    new_references.miscsegment_12                    := x_miscsegment_12;
    new_references.miscsegment_13                    := x_miscsegment_13;
    new_references.miscsegment_14                    := x_miscsegment_14;
    new_references.miscsegment_15                    := x_miscsegment_15;
    new_references.miscsegment_16                    := x_miscsegment_16;
    new_references.miscsegment_17                    := x_miscsegment_17;
    new_references.miscsegment_18                    := x_miscsegment_18;
    new_references.miscsegment_19                    := x_miscsegment_19;
    new_references.miscsegment_20                    := x_miscsegment_20;
    new_references.prof_judgement_flg                := x_prof_judgement_flg;
    new_references.nslds_data_override_flg           := x_nslds_data_override_flg;
    new_references.target_group                      := x_target_group;
    new_references.coa_fixed                         := x_coa_fixed;
    new_references.coa_pell                          := x_coa_pell;
    new_references.profile_status                       := x_profile_status;
    new_references.profile_status_date                     := x_profile_status_date;
    new_references.profile_fc                                    := x_profile_fc;
    new_references.tolerance_amount                  := x_tolerance_amount;
    new_references.manual_disb_hold                  := x_manual_disb_hold;
    new_references.pell_alt_expense                  := x_pell_alt_expense ;
    new_references.assoc_org_num                     := x_assoc_org_num;
    new_references.award_fmly_contribution_type      := x_award_fmly_contribution_type;
    new_references.isir_locked_by                    := x_isir_locked_by;
    new_references.adnl_unsub_loan_elig_flag         := x_adnl_unsub_loan_elig_flag;
    new_references.lock_awd_flag                     := x_lock_awd_flag;
    new_references.lock_coa_flag                     := x_lock_coa_flag;


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
  ||  Created By : skoppula
  ||  Created On : 07-DEC-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    IF NOT igs_ca_inst_pkg.get_pk_for_validation ( new_references.ci_cal_type,
                                                        new_references.ci_sequence_number ) THEN
      FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;

  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : skoppula
  ||  Created On : 07-DEC-2000
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation ( new_references.ci_cal_type,
                                 new_references.person_id,
                                 new_references.ci_sequence_number ) ) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : skoppula
  ||  Created On : 07-DEC-2000
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  brajendr        21-Jul-2003     Bug # 2991359 Legacy Part II
  ||                                  Added check child for igf_gr_rfms
  ||
  ||  smadathi       03-feb-2002      Bug 2154941. Added igf_sp_stdnt_rel_pkg.get_fk_igf_ap_fa_base_rec call.
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igf_ap_st_inst_appl_pkg.get_fk_igf_ap_fa_base_rec ( old_references.base_id );

    igf_ap_td_item_inst_pkg.get_fk_igf_ap_fa_base_rec ( old_references.base_id );

    igf_aw_award_pkg.get_fk_igf_ap_fa_base_rec ( old_references.base_id );

    igf_ap_inst_ver_item_pkg.get_fk_igf_ap_fa_base_rec ( old_references.base_id );

    igf_ap_tax_pkg.get_fk_igf_ap_fa_base_rec ( old_references.base_id );

    igf_ap_pers_note_pkg.get_fk_igf_ap_fa_base_rec ( old_references.base_id );

    igf_sp_stdnt_rel_pkg.get_fk_igf_ap_fa_base_rec ( old_references.base_id );

    igf_gr_rfms_pkg.get_fk_igf_ap_fa_base_rec ( old_references.base_id );

    igf_sl_lor_loc_pkg.get_fk_igf_ap_fa_base_rec (old_references.base_id) ;

  END check_child_existance;


  FUNCTION get_pk_for_validation ( x_base_id     IN     NUMBER ) RETURN BOOLEAN AS
  /*
  ||  Created By : skoppula
  ||  Created On : 07-DEC-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_fa_base_rec_all
      WHERE    base_id = x_base_id
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
    x_person_id                         IN     NUMBER,
    x_ci_sequence_number                IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : skoppula
  ||  Created On : 07-DEC-2000
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_fa_base_rec_all
      WHERE    ci_cal_type = x_ci_cal_type
      AND      person_id   = x_person_id
      AND      ci_sequence_number = x_ci_sequence_number
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
  ||  Created By : skoppula
  ||  Created On : 07-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_fa_base_rec_all
      WHERE   ((ci_cal_type = x_cal_type) AND
               (ci_sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      FND_MESSAGE.SET_NAME ('IGF', 'IGF_AP_FA_DETAIL_CI_FK');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst;



  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2 ,
    x_base_id                           IN     NUMBER   ,
    x_ci_cal_type                       IN     VARCHAR2 ,
    x_person_id                         IN     NUMBER   ,
    x_ci_sequence_number                IN     NUMBER   ,
    x_org_id                            IN     NUMBER   ,
    x_coa_pending                       IN     VARCHAR2 ,
    x_verification_process_run          IN     VARCHAR2 ,
    x_inst_verif_status_date            IN     DATE     ,
    x_manual_verif_flag                 IN     VARCHAR2 ,
    x_fed_verif_status                  IN     VARCHAR2 ,
    x_fed_verif_status_date             IN     DATE     ,
    x_inst_verif_status                 IN     VARCHAR2 ,
    x_nslds_eligible                    IN     VARCHAR2 ,
    x_ede_correction_batch_id           IN     VARCHAR2 , -- Modified by rbezawad on 22-Jun-2001 w.r.t. Bug ID: 1821811
    x_fa_process_status_date            IN     DATE     ,
    x_isir_corr_status                  IN     VARCHAR2 ,
    x_isir_corr_status_date             IN     DATE     ,
    x_isir_status                       IN     VARCHAR2 ,
    x_isir_status_date                  IN     DATE     ,
    x_coa_code_f                        IN     VARCHAR2 ,
    x_coa_code_i                        IN     VARCHAR2 ,
    x_coa_f                             IN     NUMBER   ,
    x_coa_i                             IN     NUMBER   ,
    x_disbursement_hold                 IN     VARCHAR2 ,
    x_fa_process_status                 IN     VARCHAR2 ,
    x_notification_status               IN     VARCHAR2 ,
    x_notification_status_date          IN     DATE     ,
    x_packaging_hold                    IN     VARCHAR2 ,
    x_packaging_status                  IN     VARCHAR2 ,
    x_packaging_status_date             IN     DATE     ,
    x_total_package_accepted            IN     NUMBER   ,
    x_total_package_offered             IN     NUMBER   ,
    x_admstruct_id                      IN     VARCHAR2 ,
    x_admsegment_1                      IN     VARCHAR2 ,
    x_admsegment_2                      IN     VARCHAR2 ,
    x_admsegment_3                      IN     VARCHAR2 ,
    x_admsegment_4                      IN     VARCHAR2 ,
    x_admsegment_5                      IN     VARCHAR2 ,
    x_admsegment_6                      IN     VARCHAR2 ,
    x_admsegment_7                      IN     VARCHAR2 ,
    x_admsegment_8                      IN     VARCHAR2 ,
    x_admsegment_9                      IN     VARCHAR2 ,
    x_admsegment_10                     IN     VARCHAR2 ,
    x_admsegment_11                     IN     VARCHAR2 ,
    x_admsegment_12                     IN     VARCHAR2 ,
    x_admsegment_13                     IN     VARCHAR2 ,
    x_admsegment_14                     IN     VARCHAR2 ,
    x_admsegment_15                     IN     VARCHAR2 ,
    x_admsegment_16                     IN     VARCHAR2 ,
    x_admsegment_17                     IN     VARCHAR2 ,
    x_admsegment_18                     IN     VARCHAR2 ,
    x_admsegment_19                     IN     VARCHAR2 ,
    x_admsegment_20                     IN     VARCHAR2 ,
    x_packstruct_id                     IN     VARCHAR2 ,
    x_packsegment_1                     IN     VARCHAR2 ,
    x_packsegment_2                     IN     VARCHAR2 ,
    x_packsegment_3                     IN     VARCHAR2 ,
    x_packsegment_4                     IN     VARCHAR2 ,
    x_packsegment_5                     IN     VARCHAR2 ,
    x_packsegment_6                     IN     VARCHAR2 ,
    x_packsegment_7                     IN     VARCHAR2 ,
    x_packsegment_8                     IN     VARCHAR2 ,
    x_packsegment_9                     IN     VARCHAR2 ,
    x_packsegment_10                    IN     VARCHAR2 ,
    x_packsegment_11                    IN     VARCHAR2 ,
    x_packsegment_12                    IN     VARCHAR2 ,
    x_packsegment_13                    IN     VARCHAR2 ,
    x_packsegment_14                    IN     VARCHAR2 ,
    x_packsegment_15                    IN     VARCHAR2 ,
    x_packsegment_16                    IN     VARCHAR2 ,
    x_packsegment_17                    IN     VARCHAR2 ,
    x_packsegment_18                    IN     VARCHAR2 ,
    x_packsegment_19                    IN     VARCHAR2 ,
    x_packsegment_20                    IN     VARCHAR2 ,
    x_miscstruct_id                     IN     VARCHAR2 ,
    x_miscsegment_1                     IN     VARCHAR2 ,
    x_miscsegment_2                     IN     VARCHAR2 ,
    x_miscsegment_3                     IN     VARCHAR2 ,
    x_miscsegment_4                     IN     VARCHAR2 ,
    x_miscsegment_5                     IN     VARCHAR2 ,
    x_miscsegment_6                     IN     VARCHAR2 ,
    x_miscsegment_7                     IN     VARCHAR2 ,
    x_miscsegment_8                     IN     VARCHAR2 ,
    x_miscsegment_9                     IN     VARCHAR2 ,
    x_miscsegment_10                    IN     VARCHAR2 ,
    x_miscsegment_11                    IN     VARCHAR2 ,
    x_miscsegment_12                    IN     VARCHAR2 ,
    x_miscsegment_13                    IN     VARCHAR2 ,
    x_miscsegment_14                    IN     VARCHAR2 ,
    x_miscsegment_15                    IN     VARCHAR2 ,
    x_miscsegment_16                    IN     VARCHAR2 ,
    x_miscsegment_17                    IN     VARCHAR2 ,
    x_miscsegment_18                    IN     VARCHAR2 ,
    x_miscsegment_19                    IN     VARCHAR2 ,
    x_miscsegment_20                    IN     VARCHAR2 ,
    x_prof_judgement_flg                IN     VARCHAR2 ,
    x_nslds_data_override_flg           IN     VARCHAR2 ,
    x_target_group                      IN     VARCHAR2 ,
    x_coa_fixed                         IN     NUMBER   ,
    x_coa_pell                          IN     NUMBER   ,
    x_profile_status                    IN     VARCHAR2 ,
    x_profile_status_date               IN     DATE     ,
    x_profile_fc                        IN     NUMBER   ,
    x_tolerance_amount                  IN     NUMBER   ,    --Modified by kkillams on 28- June-2001 w.r.t. bug 1794114
    x_creation_date                     IN     DATE     ,
    x_created_by                        IN     NUMBER   ,
    x_last_update_date                  IN     DATE     ,
    x_last_updated_by                   IN     NUMBER   ,
    x_last_update_login                 IN     NUMBER   ,
    x_manual_disb_hold                  IN     VARCHAR2 ,
    x_pell_alt_expense                  IN     NUMBER   ,
    x_assoc_org_num                     IN     NUMBER   ,    --Modified by ugummall on 25-SEP-2003 w.r.t. FA 126 - Multiple FA Offices
    x_award_fmly_contribution_type      IN     VARCHAR2 ,     --Modified by rasahoo  on 17-NOV-2003 w.r.t FA 128 ISIR update 20004-05
    x_isir_locked_by                    IN     VARCHAR2 ,
    x_adnl_unsub_loan_elig_flag         IN     VARCHAR2 ,
    x_lock_awd_flag                     IN     VARCHAR2 ,
    x_lock_coa_flag                     IN     VARCHAR2

  ) AS
  /*
  ||  Created By : skoppula
  ||  Created On : 07-DEC-2000
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  -- removed packaging hold
  ||  masehgal        25-Sep-2002     FA 014 -To Do Enhancements
  ||                                  Added manual_disb_hold checkbox
  ||  rbezawad         22-Jun-2001
  ||                  x_ede_correction_batch_id parameter in procedures is
  ||                  changed to VARCHAR2 Datatype w.r.t. Bug ID: 1821811.
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_base_id,
      x_ci_cal_type,
      x_person_id,
      x_ci_sequence_number,
      x_org_id,
      x_coa_pending,
      x_verification_process_run,
      TRUNC(x_inst_verif_status_date),
      x_manual_verif_flag,
      x_fed_verif_status,
      TRUNC(x_fed_verif_status_date),
      x_inst_verif_status,
      x_nslds_eligible,
      x_ede_correction_batch_id,
      TRUNC(x_fa_process_status_date),
      x_isir_corr_status,
      TRUNC(x_isir_corr_status_date),
      x_isir_status,
      TRUNC(x_isir_status_date),
      x_coa_code_f,
      x_coa_code_i,
      x_coa_f,
      x_coa_i,
      x_disbursement_hold,
      x_fa_process_status,
      x_notification_status,
      TRUNC(x_notification_status_date),
      x_packaging_status,
      TRUNC(x_packaging_status_date),
      x_total_package_accepted,
      x_total_package_offered,
      x_admstruct_id,
      x_admsegment_1,
      x_admsegment_2,
      x_admsegment_3,
      x_admsegment_4,
      x_admsegment_5,
      x_admsegment_6,
      x_admsegment_7,
      x_admsegment_8,
      x_admsegment_9,
      x_admsegment_10,
      x_admsegment_11,
      x_admsegment_12,
      x_admsegment_13,
      x_admsegment_14,
      x_admsegment_15,
      x_admsegment_16,
      x_admsegment_17,
      x_admsegment_18,
      x_admsegment_19,
      x_admsegment_20,
      x_packstruct_id,
      x_packsegment_1,
      x_packsegment_2,
      x_packsegment_3,
      x_packsegment_4,
      x_packsegment_5,
      x_packsegment_6,
      x_packsegment_7,
      x_packsegment_8,
      x_packsegment_9,
      x_packsegment_10,
      x_packsegment_11,
      x_packsegment_12,
      x_packsegment_13,
      x_packsegment_14,
      x_packsegment_15,
      x_packsegment_16,
      x_packsegment_17,
      x_packsegment_18,
      x_packsegment_19,
      x_packsegment_20,
      x_miscstruct_id,
      x_miscsegment_1,
      x_miscsegment_2,
      x_miscsegment_3,
      x_miscsegment_4,
      x_miscsegment_5,
      x_miscsegment_6,
      x_miscsegment_7,
      x_miscsegment_8,
      x_miscsegment_9,
      x_miscsegment_10,
      x_miscsegment_11,
      x_miscsegment_12,
      x_miscsegment_13,
      x_miscsegment_14,
      x_miscsegment_15,
      x_miscsegment_16,
      x_miscsegment_17,
      x_miscsegment_18,
      x_miscsegment_19,
      x_miscsegment_20,
      x_prof_judgement_flg,
      x_nslds_data_override_flg,
      x_target_group,
      x_coa_fixed,
      x_coa_pell,
      x_profile_status,
      x_profile_status_date,
      x_profile_fc,
      x_tolerance_amount,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_manual_disb_hold,
      x_pell_alt_expense,
      x_assoc_org_num,
      x_award_fmly_contribution_type,
      x_isir_locked_by,
      x_adnl_unsub_loan_elig_flag,
      x_lock_awd_flag,
      x_lock_coa_flag

    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation( new_references.base_id ) ) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation ( new_references.base_id ) ) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_base_id                           IN OUT NOCOPY NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_ci_sequence_number                IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_coa_pending                       IN     VARCHAR2,
    x_verification_process_run          IN     VARCHAR2,
    x_inst_verif_status_date            IN     DATE,
    x_manual_verif_flag                 IN     VARCHAR2,
    x_fed_verif_status                  IN     VARCHAR2,
    x_fed_verif_status_date             IN     DATE,
    x_inst_verif_status                 IN     VARCHAR2,
    x_nslds_eligible                    IN     VARCHAR2,
    x_ede_correction_batch_id           IN     VARCHAR2, -- Modified by rbezawad on 22-Jun-2001 w.r.t. Bug ID: 1821811
    x_fa_process_status_date            IN     DATE,
    x_isir_corr_status                  IN     VARCHAR2,
    x_isir_corr_status_date             IN     DATE,
    x_isir_status                       IN     VARCHAR2,
    x_isir_status_date                  IN     DATE,
    x_coa_code_f                        IN     VARCHAR2,
    x_coa_code_i                        IN     VARCHAR2,
    x_coa_f                             IN     NUMBER,
    x_coa_i                             IN     NUMBER,
    x_disbursement_hold                 IN     VARCHAR2,
    x_fa_process_status                 IN     VARCHAR2,
    x_notification_status               IN     VARCHAR2,
    x_notification_status_date          IN     DATE,
    x_packaging_hold                    IN     VARCHAR2,
    x_packaging_status                  IN     VARCHAR2,
    x_packaging_status_date             IN     DATE,
    x_total_package_accepted            IN     NUMBER,
    x_total_package_offered             IN     NUMBER,
    x_admstruct_id                      IN     VARCHAR2,
    x_admsegment_1                      IN     VARCHAR2,
    x_admsegment_2                      IN     VARCHAR2,
    x_admsegment_3                      IN     VARCHAR2,
    x_admsegment_4                      IN     VARCHAR2,
    x_admsegment_5                      IN     VARCHAR2,
    x_admsegment_6                      IN     VARCHAR2,
    x_admsegment_7                      IN     VARCHAR2,
    x_admsegment_8                      IN     VARCHAR2,
    x_admsegment_9                      IN     VARCHAR2,
    x_admsegment_10                     IN     VARCHAR2,
    x_admsegment_11                     IN     VARCHAR2,
    x_admsegment_12                     IN     VARCHAR2,
    x_admsegment_13                     IN     VARCHAR2,
    x_admsegment_14                     IN     VARCHAR2,
    x_admsegment_15                     IN     VARCHAR2,
    x_admsegment_16                     IN     VARCHAR2,
    x_admsegment_17                     IN     VARCHAR2,
    x_admsegment_18                     IN     VARCHAR2,
    x_admsegment_19                     IN     VARCHAR2,
    x_admsegment_20                     IN     VARCHAR2,
    x_packstruct_id                     IN     VARCHAR2,
    x_packsegment_1                     IN     VARCHAR2,
    x_packsegment_2                     IN     VARCHAR2,
    x_packsegment_3                     IN     VARCHAR2,
    x_packsegment_4                     IN     VARCHAR2,
    x_packsegment_5                     IN     VARCHAR2,
    x_packsegment_6                     IN     VARCHAR2,
    x_packsegment_7                     IN     VARCHAR2,
    x_packsegment_8                     IN     VARCHAR2,
    x_packsegment_9                     IN     VARCHAR2,
    x_packsegment_10                    IN     VARCHAR2,
    x_packsegment_11                    IN     VARCHAR2,
    x_packsegment_12                    IN     VARCHAR2,
    x_packsegment_13                    IN     VARCHAR2,
    x_packsegment_14                    IN     VARCHAR2,
    x_packsegment_15                    IN     VARCHAR2,
    x_packsegment_16                    IN     VARCHAR2,
    x_packsegment_17                    IN     VARCHAR2,
    x_packsegment_18                    IN     VARCHAR2,
    x_packsegment_19                    IN     VARCHAR2,
    x_packsegment_20                    IN     VARCHAR2,
    x_miscstruct_id                     IN     VARCHAR2,
    x_miscsegment_1                     IN     VARCHAR2,
    x_miscsegment_2                     IN     VARCHAR2,
    x_miscsegment_3                     IN     VARCHAR2,
    x_miscsegment_4                     IN     VARCHAR2,
    x_miscsegment_5                     IN     VARCHAR2,
    x_miscsegment_6                     IN     VARCHAR2,
    x_miscsegment_7                     IN     VARCHAR2,
    x_miscsegment_8                     IN     VARCHAR2,
    x_miscsegment_9                     IN     VARCHAR2,
    x_miscsegment_10                    IN     VARCHAR2,
    x_miscsegment_11                    IN     VARCHAR2,
    x_miscsegment_12                    IN     VARCHAR2,
    x_miscsegment_13                    IN     VARCHAR2,
    x_miscsegment_14                    IN     VARCHAR2,
    x_miscsegment_15                    IN     VARCHAR2,
    x_miscsegment_16                    IN     VARCHAR2,
    x_miscsegment_17                    IN     VARCHAR2,
    x_miscsegment_18                    IN     VARCHAR2,
    x_miscsegment_19                    IN     VARCHAR2,
    x_miscsegment_20                    IN     VARCHAR2,
    x_prof_judgement_flg                IN     VARCHAR2,
    x_nslds_data_override_flg           IN     VARCHAR2,
    x_target_group                      IN     VARCHAR2,
    x_coa_fixed                         IN     NUMBER,
    x_coa_pell                          IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_profile_status                    IN     VARCHAR2,
    x_profile_status_date               IN     DATE,
    x_profile_fc                        IN     NUMBER,
    x_tolerance_amount                  IN     NUMBER,    --Modified by kkillams on 28- June-2001 w.r.t. bug 1794114
    x_manual_disb_hold                  IN     VARCHAR2,
    x_pell_alt_expense                  IN     NUMBER,
    x_assoc_org_num                     IN     NUMBER,    --Modified by ugummall on 25-SEP-2003 w.r.t. FA 126 - Multiple FA Offices
    x_award_fmly_contribution_type      IN     VARCHAR2,   --Modified by rasahoo  on 17-NOV-2003 w.r.t FA 128 ISIR update 20004-05
    x_isir_locked_by                    IN     VARCHAR2,
    x_adnl_unsub_loan_elig_flag         IN     VARCHAR2,
    x_lock_awd_flag                     IN     VARCHAR2,
    x_lock_coa_flag                     IN     VARCHAR2

  ) AS
  /*
  ||  Created By : skoppula
  ||  Created On : 07-DEC-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  rasahoo         27-Aug-2003     Removed call to IGF_AP_OSS_PROCESS.PROCESS_FA_BASE_HIST
  ||                                  as part of obsoletion of FA base record history
  ||  masehgal        25-Sep-2002     FA 014 -To Do Enhancements
  ||                                  Added manual_disb_hold checkbox
  ||  vvutukur       16-feb-2002    removed l_org_id part and passed igf_aw_gen.get_org_id to before_dml instead of x_org_id bug:2222272
  ||  rbezawad         22-Jun-2001
  ||                  x_ede_correction_batch_id parameter in procedures is
  ||                  changed to VARCHAR2 Datatype w.r.t. Bug ID: 1821811.
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_ap_fa_base_rec_all
      WHERE    base_id  = x_base_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_return_val_pe_hz           BOOLEAN;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := FND_GLOBAL.USER_ID;
      IF (x_last_updated_by IS NULL) THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := FND_GLOBAL.LOGIN_ID;
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
      app_exception.raise_exception;
    END IF;


    SELECT igf_ap_fa_base_rec_s.NEXTVAL INTO x_base_id FROM dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_base_id                           => x_base_id,
      x_ci_cal_type                       => x_ci_cal_type,
      x_person_id                         => x_person_id,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_org_id                            => igf_aw_gen.get_org_id,
      x_coa_pending                       => x_coa_pending,
      x_verification_process_run          => x_verification_process_run,
      x_inst_verif_status_date            => x_inst_verif_status_date,
      x_manual_verif_flag                 => x_manual_verif_flag,
      x_fed_verif_status                  => x_fed_verif_status,
      x_fed_verif_status_date             => x_fed_verif_status_date,
      x_inst_verif_status                 => x_inst_verif_status,
      x_nslds_eligible                    => x_nslds_eligible,
      x_ede_correction_batch_id           => x_ede_correction_batch_id,
      x_fa_process_status_date            => x_fa_process_status_date,
      x_isir_corr_status                  => x_isir_corr_status,
      x_isir_corr_status_date             => x_isir_corr_status_date,
      x_isir_status                       => x_isir_status,
      x_isir_status_date                  => x_isir_status_date,
      x_coa_code_f                        => x_coa_code_f,
      x_coa_code_i                        => x_coa_code_i,
      x_coa_f                             => x_coa_f,
      x_coa_i                             => x_coa_i,
      x_disbursement_hold                 => x_disbursement_hold,
      x_fa_process_status                 => x_fa_process_status,
      x_notification_status               => x_notification_status,
      x_notification_status_date          => x_notification_status_date,
      x_packaging_status                  => x_packaging_status,
      x_packaging_status_date             => x_packaging_status_date,
      x_total_package_accepted            => x_total_package_accepted,
      x_total_package_offered             => x_total_package_offered,
      x_admstruct_id                      => x_admstruct_id,
      x_admsegment_1                      => x_admsegment_1,
      x_admsegment_2                      => x_admsegment_2,
      x_admsegment_3                      => x_admsegment_3,
      x_admsegment_4                      => x_admsegment_4,
      x_admsegment_5                      => x_admsegment_5,
      x_admsegment_6                      => x_admsegment_6,
      x_admsegment_7                      => x_admsegment_7,
      x_admsegment_8                      => x_admsegment_8,
      x_admsegment_9                      => x_admsegment_9,
      x_admsegment_10                     => x_admsegment_10,
      x_admsegment_11                     => x_admsegment_11,
      x_admsegment_12                     => x_admsegment_12,
      x_admsegment_13                     => x_admsegment_13,
      x_admsegment_14                     => x_admsegment_14,
      x_admsegment_15                     => x_admsegment_15,
      x_admsegment_16                     => x_admsegment_16,
      x_admsegment_17                     => x_admsegment_17,
      x_admsegment_18                     => x_admsegment_18,
      x_admsegment_19                     => x_admsegment_19,
      x_admsegment_20                     => x_admsegment_20,
      x_packstruct_id                     => x_packstruct_id,
      x_packsegment_1                     => x_packsegment_1,
      x_packsegment_2                     => x_packsegment_2,
      x_packsegment_3                     => x_packsegment_3,
      x_packsegment_4                     => x_packsegment_4,
      x_packsegment_5                     => x_packsegment_5,
      x_packsegment_6                     => x_packsegment_6,
      x_packsegment_7                     => x_packsegment_7,
      x_packsegment_8                     => x_packsegment_8,
      x_packsegment_9                     => x_packsegment_9,
      x_packsegment_10                    => x_packsegment_10,
      x_packsegment_11                    => x_packsegment_11,
      x_packsegment_12                    => x_packsegment_12,
      x_packsegment_13                    => x_packsegment_13,
      x_packsegment_14                    => x_packsegment_14,
      x_packsegment_15                    => x_packsegment_15,
      x_packsegment_16                    => x_packsegment_16,
      x_packsegment_17                    => x_packsegment_17,
      x_packsegment_18                    => x_packsegment_18,
      x_packsegment_19                    => x_packsegment_19,
      x_packsegment_20                    => x_packsegment_20,
      x_miscstruct_id                     => x_miscstruct_id,
      x_miscsegment_1                     => x_miscsegment_1,
      x_miscsegment_2                     => x_miscsegment_2,
      x_miscsegment_3                     => x_miscsegment_3,
      x_miscsegment_4                     => x_miscsegment_4,
      x_miscsegment_5                     => x_miscsegment_5,
      x_miscsegment_6                     => x_miscsegment_6,
      x_miscsegment_7                     => x_miscsegment_7,
      x_miscsegment_8                     => x_miscsegment_8,
      x_miscsegment_9                     => x_miscsegment_9,
      x_miscsegment_10                    => x_miscsegment_10,
      x_miscsegment_11                    => x_miscsegment_11,
      x_miscsegment_12                    => x_miscsegment_12,
      x_miscsegment_13                    => x_miscsegment_13,
      x_miscsegment_14                    => x_miscsegment_14,
      x_miscsegment_15                    => x_miscsegment_15,
      x_miscsegment_16                    => x_miscsegment_16,
      x_miscsegment_17                    => x_miscsegment_17,
      x_miscsegment_18                    => x_miscsegment_18,
      x_miscsegment_19                    => x_miscsegment_19,
      x_miscsegment_20                    => x_miscsegment_20,
      x_prof_judgement_flg                => x_prof_judgement_flg,
      x_nslds_data_override_flg           => x_nslds_data_override_flg,
      x_target_group                      => x_target_group,
      x_coa_fixed                         => x_coa_fixed,
      x_coa_pell                          => x_coa_pell,
      x_profile_status                    => x_profile_status,
      x_profile_status_date               => x_profile_status_date,
      x_profile_fc                        => x_profile_fc,
      x_tolerance_amount                  => x_tolerance_amount,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_manual_disb_hold                  => x_manual_disb_hold,
      x_pell_alt_expense                  => x_pell_alt_expense,
      x_assoc_org_num                     => x_assoc_org_num,
      x_award_fmly_contribution_type      => x_award_fmly_contribution_type,
      x_isir_locked_by                    => x_isir_locked_by,
      x_adnl_unsub_loan_elig_flag         => x_adnl_unsub_loan_elig_flag,
      x_lock_awd_flag                     => x_lock_awd_flag,
      x_lock_coa_flag                     => x_lock_coa_flag

    );

    -- Bug 3700586 : Person data missing in OSS if peson is created thru HRMS
    -- Added the call to check whether HZ information is present in the IGS_PE_HZ_PARTIES table, if not it will add
    l_return_val_pe_hz := igs_pe_person_pkg.get_pk_for_validation(new_references.person_id);

    INSERT INTO igf_ap_fa_base_rec_all (
      base_id,
      ci_cal_type,
      person_id,
      ci_sequence_number,
      org_id,
      coa_pending,
      verification_process_run,
      inst_verif_status_date,
      manual_verif_flag,
      fed_verif_status,
      fed_verif_status_date,
      inst_verif_status,
      nslds_eligible,
      ede_correction_batch_id,
      fa_process_status_date,
      isir_corr_status,
      isir_corr_status_date,
      isir_status,
      isir_status_date,
      coa_code_f,
      coa_code_i,
      coa_f,
      coa_i,
      disbursement_hold,
      fa_process_status,
      notification_status,
      notification_status_date,
      packaging_status,
      packaging_status_date,
      total_package_accepted,
      total_package_offered,
      admstruct_id,
      admsegment_1,
      admsegment_2,
      admsegment_3,
      admsegment_4,
      admsegment_5,
      admsegment_6,
      admsegment_7,
      admsegment_8,
      admsegment_9,
      admsegment_10,
      admsegment_11,
      admsegment_12,
      admsegment_13,
      admsegment_14,
      admsegment_15,
      admsegment_16,
      admsegment_17,
      admsegment_18,
      admsegment_19,
      admsegment_20,
      packstruct_id,
      packsegment_1,
      packsegment_2,
      packsegment_3,
      packsegment_4,
      packsegment_5,
      packsegment_6,
      packsegment_7,
      packsegment_8,
      packsegment_9,
      packsegment_10,
      packsegment_11,
      packsegment_12,
      packsegment_13,
      packsegment_14,
      packsegment_15,
      packsegment_16,
      packsegment_17,
      packsegment_18,
      packsegment_19,
      packsegment_20,
      miscstruct_id,
      miscsegment_1,
      miscsegment_2,
      miscsegment_3,
      miscsegment_4,
      miscsegment_5,
      miscsegment_6,
      miscsegment_7,
      miscsegment_8,
      miscsegment_9,
      miscsegment_10,
      miscsegment_11,
      miscsegment_12,
      miscsegment_13,
      miscsegment_14,
      miscsegment_15,
      miscsegment_16,
      miscsegment_17,
      miscsegment_18,
      miscsegment_19,
      miscsegment_20,
      prof_judgement_flg,
      nslds_data_override_flg,
      target_group,
      coa_fixed,
      coa_pell,
      profile_status,
      profile_status_date,
      profile_fc,
      tolerance_amount,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      manual_disb_hold,
      pell_alt_expense,
      assoc_org_num,
      award_fmly_contribution_type,
      isir_locked_by,
      adnl_unsub_loan_elig_flag,
      lock_awd_flag,
      lock_coa_flag
    ) VALUES (
      new_references.base_id,
      new_references.ci_cal_type,
      new_references.person_id,
      new_references.ci_sequence_number,
      new_references.org_id,
      new_references.coa_pending,
      new_references.verification_process_run,
      new_references.inst_verif_status_date,
      new_references.manual_verif_flag,
      new_references.fed_verif_status,
      new_references.fed_verif_status_date,
      new_references.inst_verif_status,
      new_references.nslds_eligible,
      new_references.ede_correction_batch_id,
      new_references.fa_process_status_date,
      new_references.isir_corr_status,
      new_references.isir_corr_status_date,
      new_references.isir_status,
      new_references.isir_status_date,
      new_references.coa_code_f,
      new_references.coa_code_i,
      new_references.coa_f,
      new_references.coa_i,
      new_references.disbursement_hold,
      new_references.fa_process_status,
      new_references.notification_status,
      new_references.notification_status_date,
      new_references.packaging_status,
      new_references.packaging_status_date,
      new_references.total_package_accepted,
      new_references.total_package_offered,
      new_references.admstruct_id,
      new_references.admsegment_1,
      new_references.admsegment_2,
      new_references.admsegment_3,
      new_references.admsegment_4,
      new_references.admsegment_5,
      new_references.admsegment_6,
      new_references.admsegment_7,
      new_references.admsegment_8,
      new_references.admsegment_9,
      new_references.admsegment_10,
      new_references.admsegment_11,
      new_references.admsegment_12,
      new_references.admsegment_13,
      new_references.admsegment_14,
      new_references.admsegment_15,
      new_references.admsegment_16,
      new_references.admsegment_17,
      new_references.admsegment_18,
      new_references.admsegment_19,
      new_references.admsegment_20,
      new_references.packstruct_id,
      new_references.packsegment_1,
      new_references.packsegment_2,
      new_references.packsegment_3,
      new_references.packsegment_4,
      new_references.packsegment_5,
      new_references.packsegment_6,
      new_references.packsegment_7,
      new_references.packsegment_8,
      new_references.packsegment_9,
      new_references.packsegment_10,
      new_references.packsegment_11,
      new_references.packsegment_12,
      new_references.packsegment_13,
      new_references.packsegment_14,
      new_references.packsegment_15,
      new_references.packsegment_16,
      new_references.packsegment_17,
      new_references.packsegment_18,
      new_references.packsegment_19,
      new_references.packsegment_20,
      new_references.miscstruct_id,
      new_references.miscsegment_1,
      new_references.miscsegment_2,
      new_references.miscsegment_3,
      new_references.miscsegment_4,
      new_references.miscsegment_5,
      new_references.miscsegment_6,
      new_references.miscsegment_7,
      new_references.miscsegment_8,
      new_references.miscsegment_9,
      new_references.miscsegment_10,
      new_references.miscsegment_11,
      new_references.miscsegment_12,
      new_references.miscsegment_13,
      new_references.miscsegment_14,
      new_references.miscsegment_15,
      new_references.miscsegment_16,
      new_references.miscsegment_17,
      new_references.miscsegment_18,
      new_references.miscsegment_19,
      new_references.miscsegment_20,
      new_references.prof_judgement_flg,
      new_references.nslds_data_override_flg,
      new_references.target_group,
      new_references.coa_fixed,
      new_references.coa_pell,
      new_references.profile_status,
      new_references.profile_status_date,
      new_references.profile_fc,
      new_references.tolerance_amount,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
      new_references.manual_disb_hold,
      new_references.pell_alt_expense,
      new_references.assoc_org_num,
      new_references.award_fmly_contribution_type,
      new_references.isir_locked_by,
      new_references.adnl_unsub_loan_elig_flag,
      new_references.lock_awd_flag,
      new_references.lock_coa_flag

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
    x_base_id                           IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_ci_sequence_number                IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_coa_pending                       IN     VARCHAR2,
    x_verification_process_run          IN     VARCHAR2,
    x_inst_verif_status_date            IN     DATE,
    x_manual_verif_flag                 IN     VARCHAR2,
    x_fed_verif_status                  IN     VARCHAR2,
    x_fed_verif_status_date             IN     DATE,
    x_inst_verif_status                 IN     VARCHAR2,
    x_nslds_eligible                    IN     VARCHAR2,
    x_ede_correction_batch_id           IN     VARCHAR2, -- Modified by rbezawad on 22-Jun-2001 w.r.t. Bug ID: 1821811
    x_fa_process_status_date            IN     DATE,
    x_isir_corr_status                  IN     VARCHAR2,
    x_isir_corr_status_date             IN     DATE,
    x_isir_status                       IN     VARCHAR2,
    x_isir_status_date                  IN     DATE,
    x_coa_code_f                        IN     VARCHAR2,
    x_coa_code_i                        IN     VARCHAR2,
    x_coa_f                             IN     NUMBER,
    x_coa_i                             IN     NUMBER,
    x_disbursement_hold                 IN     VARCHAR2,
    x_fa_process_status                 IN     VARCHAR2,
    x_notification_status               IN     VARCHAR2,
    x_notification_status_date          IN     DATE,
    x_packaging_hold                    IN     VARCHAR2,
    x_packaging_status                  IN     VARCHAR2,
    x_packaging_status_date             IN     DATE,
    x_total_package_accepted            IN     NUMBER,
    x_total_package_offered             IN     NUMBER,
    x_admstruct_id                      IN     VARCHAR2,
    x_admsegment_1                      IN     VARCHAR2,
    x_admsegment_2                      IN     VARCHAR2,
    x_admsegment_3                      IN     VARCHAR2,
    x_admsegment_4                      IN     VARCHAR2,
    x_admsegment_5                      IN     VARCHAR2,
    x_admsegment_6                      IN     VARCHAR2,
    x_admsegment_7                      IN     VARCHAR2,
    x_admsegment_8                      IN     VARCHAR2,
    x_admsegment_9                      IN     VARCHAR2,
    x_admsegment_10                     IN     VARCHAR2,
    x_admsegment_11                     IN     VARCHAR2,
    x_admsegment_12                     IN     VARCHAR2,
    x_admsegment_13                     IN     VARCHAR2,
    x_admsegment_14                     IN     VARCHAR2,
    x_admsegment_15                     IN     VARCHAR2,
    x_admsegment_16                     IN     VARCHAR2,
    x_admsegment_17                     IN     VARCHAR2,
    x_admsegment_18                     IN     VARCHAR2,
    x_admsegment_19                     IN     VARCHAR2,
    x_admsegment_20                     IN     VARCHAR2,
    x_packstruct_id                     IN     VARCHAR2,
    x_packsegment_1                     IN     VARCHAR2,
    x_packsegment_2                     IN     VARCHAR2,
    x_packsegment_3                     IN     VARCHAR2,
    x_packsegment_4                     IN     VARCHAR2,
    x_packsegment_5                     IN     VARCHAR2,
    x_packsegment_6                     IN     VARCHAR2,
    x_packsegment_7                     IN     VARCHAR2,
    x_packsegment_8                     IN     VARCHAR2,
    x_packsegment_9                     IN     VARCHAR2,
    x_packsegment_10                    IN     VARCHAR2,
    x_packsegment_11                    IN     VARCHAR2,
    x_packsegment_12                    IN     VARCHAR2,
    x_packsegment_13                    IN     VARCHAR2,
    x_packsegment_14                    IN     VARCHAR2,
    x_packsegment_15                    IN     VARCHAR2,
    x_packsegment_16                    IN     VARCHAR2,
    x_packsegment_17                    IN     VARCHAR2,
    x_packsegment_18                    IN     VARCHAR2,
    x_packsegment_19                    IN     VARCHAR2,
    x_packsegment_20                    IN     VARCHAR2,
    x_miscstruct_id                     IN     VARCHAR2,
    x_miscsegment_1                     IN     VARCHAR2,
    x_miscsegment_2                     IN     VARCHAR2,
    x_miscsegment_3                     IN     VARCHAR2,
    x_miscsegment_4                     IN     VARCHAR2,
    x_miscsegment_5                     IN     VARCHAR2,
    x_miscsegment_6                     IN     VARCHAR2,
    x_miscsegment_7                     IN     VARCHAR2,
    x_miscsegment_8                     IN     VARCHAR2,
    x_miscsegment_9                     IN     VARCHAR2,
    x_miscsegment_10                    IN     VARCHAR2,
    x_miscsegment_11                    IN     VARCHAR2,
    x_miscsegment_12                    IN     VARCHAR2,
    x_miscsegment_13                    IN     VARCHAR2,
    x_miscsegment_14                    IN     VARCHAR2,
    x_miscsegment_15                    IN     VARCHAR2,
    x_miscsegment_16                    IN     VARCHAR2,
    x_miscsegment_17                    IN     VARCHAR2,
    x_miscsegment_18                    IN     VARCHAR2,
    x_miscsegment_19                    IN     VARCHAR2,
    x_miscsegment_20                    IN     VARCHAR2,
    x_prof_judgement_flg                IN     VARCHAR2,
    x_nslds_data_override_flg           IN     VARCHAR2,
    x_target_group                      IN     VARCHAR2,
    x_coa_fixed                         IN     NUMBER,
    x_coa_pell                          IN     NUMBER,
    x_profile_status                    IN     VARCHAR2,
    x_profile_status_date               IN     DATE,
    x_profile_fc                        IN     NUMBER,
    x_tolerance_amount                  IN     NUMBER,    --Modified by kkillams on 28- June-2001 w.r.t. bug 1794114
    x_manual_disb_hold                  IN     VARCHAR2,
    x_pell_alt_expense                  IN     NUMBER,
    x_assoc_org_num                     IN     NUMBER,    --Modified by ugummall on 25-SEP-2003 w.r.t FA 126 - Multiple FA Offices
    x_award_fmly_contribution_type      IN     VARCHAR2,   --Modified by rasahoo  on 17-NOV-2003 w.r.t FA 128 ISIR update 20004-05
    x_isir_locked_by                    IN     VARCHAR2,
    x_adnl_unsub_loan_elig_flag         IN     VARCHAR2,
    x_lock_awd_flag                     IN     VARCHAR2,
    x_lock_coa_flag                     IN     VARCHAR2
  ) AS
  /*
  ||  Created By : skoppula
  ||  Created On : 07-DEC-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  masehgal        25-Sep-2002     FA 014 -To Do Enhancements
  ||                                  Added manual_disb_hold checkbox
  ||  rbezawad         22-Jun-2001
  ||                  x_ede_correction_batch_id parameter in procedures is
  ||                  changed to VARCHAR2 Datatype w.r.t. Bug ID: 1821811.
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        ci_cal_type,
        person_id,
        ci_sequence_number,
        org_id,
        coa_pending,
        verification_process_run,
        inst_verif_status_date,
        manual_verif_flag,
        fed_verif_status,
        fed_verif_status_date,
        inst_verif_status,
        nslds_eligible,
        ede_correction_batch_id,
        fa_process_status_date,
        isir_corr_status,
        isir_corr_status_date,
        isir_status,
        isir_status_date,
        coa_code_f,
        coa_code_i,
        coa_f,
        coa_i,
        disbursement_hold,
        fa_process_status,
        notification_status,
        notification_status_date,
        packaging_status,
        packaging_status_date,
        total_package_accepted,
        total_package_offered,
        admstruct_id,
        admsegment_1,
        admsegment_2,
        admsegment_3,
        admsegment_4,
        admsegment_5,
        admsegment_6,
        admsegment_7,
        admsegment_8,
        admsegment_9,
        admsegment_10,
        admsegment_11,
        admsegment_12,
        admsegment_13,
        admsegment_14,
        admsegment_15,
        admsegment_16,
        admsegment_17,
        admsegment_18,
        admsegment_19,
        admsegment_20,
        packstruct_id,
        packsegment_1,
        packsegment_2,
        packsegment_3,
        packsegment_4,
        packsegment_5,
        packsegment_6,
        packsegment_7,
        packsegment_8,
        packsegment_9,
        packsegment_10,
        packsegment_11,
        packsegment_12,
        packsegment_13,
        packsegment_14,
        packsegment_15,
        packsegment_16,
        packsegment_17,
        packsegment_18,
        packsegment_19,
        packsegment_20,
        miscstruct_id,
        miscsegment_1,
        miscsegment_2,
        miscsegment_3,
        miscsegment_4,
        miscsegment_5,
        miscsegment_6,
        miscsegment_7,
        miscsegment_8,
        miscsegment_9,
        miscsegment_10,
        miscsegment_11,
        miscsegment_12,
        miscsegment_13,
        miscsegment_14,
        miscsegment_15,
        miscsegment_16,
        miscsegment_17,
        miscsegment_18,
        miscsegment_19,
        miscsegment_20,
        prof_judgement_flg,
        nslds_data_override_flg,
        target_group,
        coa_fixed,
        coa_pell,
        profile_status,
        profile_status_date,
        profile_fc,
        tolerance_amount,
              manual_disb_hold,
        pell_alt_expense,
        assoc_org_num,
        award_fmly_contribution_type,
        isir_locked_by,
	       adnl_unsub_loan_elig_flag,
        lock_awd_flag,
        lock_coa_flag
      FROM  igf_ap_fa_base_rec_all
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
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.ci_cal_type = x_ci_cal_type)
        AND (tlinfo.person_id = x_person_id)
        AND (tlinfo.ci_sequence_number = x_ci_sequence_number)
        AND ((tlinfo.coa_pending = x_coa_pending) OR ((tlinfo.coa_pending IS NULL) AND (X_coa_pending IS NULL)))
        AND ((tlinfo.verification_process_run = x_verification_process_run) OR ((tlinfo.verification_process_run IS NULL) AND (X_verification_process_run IS NULL)))
        AND ((tlinfo.inst_verif_status_date = x_inst_verif_status_date) OR ((tlinfo.inst_verif_status_date IS NULL) AND (X_inst_verif_status_date IS NULL)))
        AND ((tlinfo.manual_verif_flag = x_manual_verif_flag) OR ((tlinfo.manual_verif_flag IS NULL) AND (X_manual_verif_flag IS NULL)))
        AND ((tlinfo.fed_verif_status = x_fed_verif_status) OR ((tlinfo.fed_verif_status IS NULL) AND (X_fed_verif_status IS NULL)))
        AND ((tlinfo.fed_verif_status_date = x_fed_verif_status_date) OR ((tlinfo.fed_verif_status_date IS NULL) AND (X_fed_verif_status_date IS NULL)))
        AND ((tlinfo.inst_verif_status = x_inst_verif_status) OR ((tlinfo.inst_verif_status IS NULL) AND (X_inst_verif_status IS NULL)))
        AND ((tlinfo.nslds_eligible = x_nslds_eligible) OR ((tlinfo.nslds_eligible IS NULL) AND (X_nslds_eligible IS NULL)))
        AND ((tlinfo.ede_correction_batch_id = x_ede_correction_batch_id) OR ((tlinfo.ede_correction_batch_id IS NULL) AND (X_ede_correction_batch_id IS NULL)))
        AND ((tlinfo.fa_process_status_date = x_fa_process_status_date) OR ((tlinfo.fa_process_status_date IS NULL) AND (X_fa_process_status_date IS NULL)))
        AND ((tlinfo.isir_corr_status = x_isir_corr_status) OR ((tlinfo.isir_corr_status IS NULL) AND (X_isir_corr_status IS NULL)))
        AND ((tlinfo.isir_corr_status_date = x_isir_corr_status_date) OR ((tlinfo.isir_corr_status_date IS NULL) AND (X_isir_corr_status_date IS NULL)))
        AND ((tlinfo.isir_status = x_isir_status) OR ((tlinfo.isir_status IS NULL) AND (X_isir_status IS NULL)))
        AND ((tlinfo.isir_status_date = x_isir_status_date) OR ((tlinfo.isir_status_date IS NULL) AND (X_isir_status_date IS NULL)))
        AND ((tlinfo.coa_code_f = x_coa_code_f) OR ((tlinfo.coa_code_f IS NULL) AND (X_coa_code_f IS NULL)))
        AND ((tlinfo.coa_code_i = x_coa_code_i) OR ((tlinfo.coa_code_i IS NULL) AND (X_coa_code_i IS NULL)))
        AND ((tlinfo.coa_f = x_coa_f) OR ((tlinfo.coa_f IS NULL) AND (X_coa_f IS NULL)))
        AND ((tlinfo.coa_i = x_coa_i) OR ((tlinfo.coa_i IS NULL) AND (X_coa_i IS NULL)))
        AND ((tlinfo.disbursement_hold = x_disbursement_hold) OR ((tlinfo.disbursement_hold IS NULL) AND (X_disbursement_hold IS NULL)))

        -- Commented by brajendr 15-May-2001, Columns are getting populated thru OSS tables

        AND ((tlinfo.fa_process_status = x_fa_process_status) OR ((tlinfo.fa_process_status IS NULL) AND (X_fa_process_status IS NULL)))

        -- Commented by brajendr 15-May-2001, Columns are getting populated thru OSS tables

        AND ((tlinfo.notification_status = x_notification_status) OR ((tlinfo.notification_status IS NULL) AND (X_notification_status IS NULL)))
        AND ((tlinfo.notification_status_date = x_notification_status_date) OR ((tlinfo.notification_status_date IS NULL) AND (X_notification_status_date IS NULL)))
        AND ((tlinfo.packaging_status = x_packaging_status) OR ((tlinfo.packaging_status IS NULL) AND (X_packaging_status IS NULL)))
        AND ((tlinfo.packaging_status_date = x_packaging_status_date) OR ((tlinfo.packaging_status_date IS NULL) AND (X_packaging_status_date IS NULL)))
        AND ((tlinfo.total_package_accepted = x_total_package_accepted) OR ((tlinfo.total_package_accepted IS NULL) AND (X_total_package_accepted IS NULL)))
        AND ((tlinfo.total_package_offered = x_total_package_offered) OR ((tlinfo.total_package_offered IS NULL) AND (X_total_package_offered IS NULL)))
        AND ((tlinfo.admstruct_id = x_admstruct_id) OR ((tlinfo.admstruct_id IS NULL) AND (X_admstruct_id IS NULL)))
        AND ((tlinfo.admsegment_1 = x_admsegment_1) OR ((tlinfo.admsegment_1 IS NULL) AND (X_admsegment_1 IS NULL)))
        AND ((tlinfo.admsegment_2 = x_admsegment_2) OR ((tlinfo.admsegment_2 IS NULL) AND (X_admsegment_2 IS NULL)))
        AND ((tlinfo.admsegment_3 = x_admsegment_3) OR ((tlinfo.admsegment_3 IS NULL) AND (X_admsegment_3 IS NULL)))
        AND ((tlinfo.admsegment_4 = x_admsegment_4) OR ((tlinfo.admsegment_4 IS NULL) AND (X_admsegment_4 IS NULL)))
        AND ((tlinfo.admsegment_5 = x_admsegment_5) OR ((tlinfo.admsegment_5 IS NULL) AND (X_admsegment_5 IS NULL)))
        AND ((tlinfo.admsegment_6 = x_admsegment_6) OR ((tlinfo.admsegment_6 IS NULL) AND (X_admsegment_6 IS NULL)))
        AND ((tlinfo.admsegment_7 = x_admsegment_7) OR ((tlinfo.admsegment_7 IS NULL) AND (X_admsegment_7 IS NULL)))
        AND ((tlinfo.admsegment_8 = x_admsegment_8) OR ((tlinfo.admsegment_8 IS NULL) AND (X_admsegment_8 IS NULL)))
        AND ((tlinfo.admsegment_9 = x_admsegment_9) OR ((tlinfo.admsegment_9 IS NULL) AND (X_admsegment_9 IS NULL)))
        AND ((tlinfo.admsegment_10 = x_admsegment_10) OR ((tlinfo.admsegment_10 IS NULL) AND (X_admsegment_10 IS NULL)))
        AND ((tlinfo.admsegment_11 = x_admsegment_11) OR ((tlinfo.admsegment_11 IS NULL) AND (X_admsegment_11 IS NULL)))
        AND ((tlinfo.admsegment_12 = x_admsegment_12) OR ((tlinfo.admsegment_12 IS NULL) AND (X_admsegment_12 IS NULL)))
        AND ((tlinfo.admsegment_13 = x_admsegment_13) OR ((tlinfo.admsegment_13 IS NULL) AND (X_admsegment_13 IS NULL)))
        AND ((tlinfo.admsegment_14 = x_admsegment_14) OR ((tlinfo.admsegment_14 IS NULL) AND (X_admsegment_14 IS NULL)))
        AND ((tlinfo.admsegment_15 = x_admsegment_15) OR ((tlinfo.admsegment_15 IS NULL) AND (X_admsegment_15 IS NULL)))
        AND ((tlinfo.admsegment_16 = x_admsegment_16) OR ((tlinfo.admsegment_16 IS NULL) AND (X_admsegment_16 IS NULL)))
        AND ((tlinfo.admsegment_17 = x_admsegment_17) OR ((tlinfo.admsegment_17 IS NULL) AND (X_admsegment_17 IS NULL)))
        AND ((tlinfo.admsegment_18 = x_admsegment_18) OR ((tlinfo.admsegment_18 IS NULL) AND (X_admsegment_18 IS NULL)))
        AND ((tlinfo.admsegment_19 = x_admsegment_19) OR ((tlinfo.admsegment_19 IS NULL) AND (X_admsegment_19 IS NULL)))
        AND ((tlinfo.admsegment_20 = x_admsegment_20) OR ((tlinfo.admsegment_20 IS NULL) AND (X_admsegment_20 IS NULL)))
        AND ((tlinfo.packstruct_id = x_packstruct_id) OR ((tlinfo.packstruct_id IS NULL) AND (X_packstruct_id IS NULL)))
        AND ((tlinfo.packsegment_1 = x_packsegment_1) OR ((tlinfo.packsegment_1 IS NULL) AND (X_packsegment_1 IS NULL)))
        AND ((tlinfo.packsegment_2 = x_packsegment_2) OR ((tlinfo.packsegment_2 IS NULL) AND (X_packsegment_2 IS NULL)))
        AND ((tlinfo.packsegment_3 = x_packsegment_3) OR ((tlinfo.packsegment_3 IS NULL) AND (X_packsegment_3 IS NULL)))
        AND ((tlinfo.packsegment_4 = x_packsegment_4) OR ((tlinfo.packsegment_4 IS NULL) AND (X_packsegment_4 IS NULL)))
        AND ((tlinfo.packsegment_5 = x_packsegment_5) OR ((tlinfo.packsegment_5 IS NULL) AND (X_packsegment_5 IS NULL)))
        AND ((tlinfo.packsegment_6 = x_packsegment_6) OR ((tlinfo.packsegment_6 IS NULL) AND (X_packsegment_6 IS NULL)))
        AND ((tlinfo.packsegment_7 = x_packsegment_7) OR ((tlinfo.packsegment_7 IS NULL) AND (X_packsegment_7 IS NULL)))
        AND ((tlinfo.packsegment_8 = x_packsegment_8) OR ((tlinfo.packsegment_8 IS NULL) AND (X_packsegment_8 IS NULL)))
        AND ((tlinfo.packsegment_9 = x_packsegment_9) OR ((tlinfo.packsegment_9 IS NULL) AND (X_packsegment_9 IS NULL)))
        AND ((tlinfo.packsegment_10 = x_packsegment_10) OR ((tlinfo.packsegment_10 IS NULL) AND (X_packsegment_10 IS NULL)))
        AND ((tlinfo.packsegment_11 = x_packsegment_11) OR ((tlinfo.packsegment_11 IS NULL) AND (X_packsegment_11 IS NULL)))
        AND ((tlinfo.packsegment_12 = x_packsegment_12) OR ((tlinfo.packsegment_12 IS NULL) AND (X_packsegment_12 IS NULL)))
        AND ((tlinfo.packsegment_13 = x_packsegment_13) OR ((tlinfo.packsegment_13 IS NULL) AND (X_packsegment_13 IS NULL)))
        AND ((tlinfo.packsegment_14 = x_packsegment_14) OR ((tlinfo.packsegment_14 IS NULL) AND (X_packsegment_14 IS NULL)))
        AND ((tlinfo.packsegment_15 = x_packsegment_15) OR ((tlinfo.packsegment_15 IS NULL) AND (X_packsegment_15 IS NULL)))
        AND ((tlinfo.packsegment_16 = x_packsegment_16) OR ((tlinfo.packsegment_16 IS NULL) AND (X_packsegment_16 IS NULL)))
        AND ((tlinfo.packsegment_17 = x_packsegment_17) OR ((tlinfo.packsegment_17 IS NULL) AND (X_packsegment_17 IS NULL)))
        AND ((tlinfo.packsegment_18 = x_packsegment_18) OR ((tlinfo.packsegment_18 IS NULL) AND (X_packsegment_18 IS NULL)))
        AND ((tlinfo.packsegment_19 = x_packsegment_19) OR ((tlinfo.packsegment_19 IS NULL) AND (X_packsegment_19 IS NULL)))
        AND ((tlinfo.packsegment_20 = x_packsegment_20) OR ((tlinfo.packsegment_20 IS NULL) AND (X_packsegment_20 IS NULL)))
        AND ((tlinfo.miscstruct_id = x_miscstruct_id) OR ((tlinfo.miscstruct_id IS NULL) AND (X_miscstruct_id IS NULL)))
        AND ((tlinfo.miscsegment_1 = x_miscsegment_1) OR ((tlinfo.miscsegment_1 IS NULL) AND (X_miscsegment_1 IS NULL)))
        AND ((tlinfo.miscsegment_2 = x_miscsegment_2) OR ((tlinfo.miscsegment_2 IS NULL) AND (X_miscsegment_2 IS NULL)))
        AND ((tlinfo.miscsegment_3 = x_miscsegment_3) OR ((tlinfo.miscsegment_3 IS NULL) AND (X_miscsegment_3 IS NULL)))
        AND ((tlinfo.miscsegment_4 = x_miscsegment_4) OR ((tlinfo.miscsegment_4 IS NULL) AND (X_miscsegment_4 IS NULL)))
        AND ((tlinfo.miscsegment_5 = x_miscsegment_5) OR ((tlinfo.miscsegment_5 IS NULL) AND (X_miscsegment_5 IS NULL)))
        AND ((tlinfo.miscsegment_6 = x_miscsegment_6) OR ((tlinfo.miscsegment_6 IS NULL) AND (X_miscsegment_6 IS NULL)))
        AND ((tlinfo.miscsegment_7 = x_miscsegment_7) OR ((tlinfo.miscsegment_7 IS NULL) AND (X_miscsegment_7 IS NULL)))
        AND ((tlinfo.miscsegment_8 = x_miscsegment_8) OR ((tlinfo.miscsegment_8 IS NULL) AND (X_miscsegment_8 IS NULL)))
        AND ((tlinfo.miscsegment_9 = x_miscsegment_9) OR ((tlinfo.miscsegment_9 IS NULL) AND (X_miscsegment_9 IS NULL)))
        AND ((tlinfo.miscsegment_10 = x_miscsegment_10) OR ((tlinfo.miscsegment_10 IS NULL) AND (X_miscsegment_10 IS NULL)))
        AND ((tlinfo.miscsegment_11 = x_miscsegment_11) OR ((tlinfo.miscsegment_11 IS NULL) AND (X_miscsegment_11 IS NULL)))
        AND ((tlinfo.miscsegment_12 = x_miscsegment_12) OR ((tlinfo.miscsegment_12 IS NULL) AND (X_miscsegment_12 IS NULL)))
        AND ((tlinfo.miscsegment_13 = x_miscsegment_13) OR ((tlinfo.miscsegment_13 IS NULL) AND (X_miscsegment_13 IS NULL)))
        AND ((tlinfo.miscsegment_14 = x_miscsegment_14) OR ((tlinfo.miscsegment_14 IS NULL) AND (X_miscsegment_14 IS NULL)))
        AND ((tlinfo.miscsegment_15 = x_miscsegment_15) OR ((tlinfo.miscsegment_15 IS NULL) AND (X_miscsegment_15 IS NULL)))
        AND ((tlinfo.miscsegment_16 = x_miscsegment_16) OR ((tlinfo.miscsegment_16 IS NULL) AND (X_miscsegment_16 IS NULL)))
        AND ((tlinfo.miscsegment_17 = x_miscsegment_17) OR ((tlinfo.miscsegment_17 IS NULL) AND (X_miscsegment_17 IS NULL)))
        AND ((tlinfo.miscsegment_18 = x_miscsegment_18) OR ((tlinfo.miscsegment_18 IS NULL) AND (X_miscsegment_18 IS NULL)))
        AND ((tlinfo.miscsegment_19 = x_miscsegment_19) OR ((tlinfo.miscsegment_19 IS NULL) AND (X_miscsegment_19 IS NULL)))
        AND ((tlinfo.miscsegment_20 = x_miscsegment_20) OR ((tlinfo.miscsegment_20 IS NULL) AND (X_miscsegment_20 IS NULL)))
        AND ((tlinfo.prof_judgement_flg = x_prof_judgement_flg) OR ((tlinfo.prof_judgement_flg IS NULL) AND (X_prof_judgement_flg IS NULL)))
        AND ((tlinfo.nslds_data_override_flg = x_nslds_data_override_flg) OR ((tlinfo.nslds_data_override_flg IS NULL) AND (X_nslds_data_override_flg IS NULL)))
        AND ((tlinfo.target_group = x_target_group) OR ((tlinfo.target_group IS NULL) AND (X_target_group IS NULL)))

        AND ((tlinfo.coa_fixed = x_coa_fixed) OR ((tlinfo.coa_fixed IS NULL) AND (X_coa_fixed IS NULL)))
        AND ((tlinfo.coa_pell = x_coa_pell) OR ((tlinfo.coa_pell IS NULL) AND (X_coa_pell IS NULL)))
        AND ((tlinfo.profile_status = x_profile_status) OR ((tlinfo.profile_status IS NULL) AND (x_profile_status IS NULL)))
        AND ((tlinfo.profile_status_date = x_profile_status_date) OR ((tlinfo.profile_status_date IS NULL) AND (x_profile_status_date IS NULL)))
        AND ((tlinfo.profile_fc = x_profile_fc) OR ((tlinfo.profile_fc IS NULL) AND (x_profile_fc IS NULL)))

        AND ((tlinfo.tolerance_amount = x_tolerance_amount) OR ((tlinfo.tolerance_amount IS NULL) AND (x_tolerance_amount IS NULL)))
        AND ((tlinfo.manual_disb_hold = x_manual_disb_hold) OR ((tlinfo.manual_disb_hold IS NULL) AND (x_manual_disb_hold IS NULL)))
        AND ((tlinfo.pell_alt_expense = x_pell_alt_expense) OR ((tlinfo.pell_alt_expense IS NULL) AND (x_pell_alt_expense IS NULL)))
        AND ((tlinfo.assoc_org_num = x_assoc_org_num) OR ((tlinfo.assoc_org_num IS NULL) AND (x_assoc_org_num IS NULL)))    --Modified by ugummall on 25-SEP-2003 w.r.t FA 126 - Multiple FA Offices
        AND ((tlinfo.award_fmly_contribution_type = x_award_fmly_contribution_type) OR ((tlinfo.award_fmly_contribution_type IS NULL) AND (x_award_fmly_contribution_type IS NULL)))

        AND ((tlinfo.isir_locked_by = x_isir_locked_by) OR ((tlinfo.isir_locked_by IS NULL) AND (x_isir_locked_by IS NULL)))
        AND ((tlinfo.adnl_unsub_loan_elig_flag = x_adnl_unsub_loan_elig_flag) OR ((tlinfo.adnl_unsub_loan_elig_flag IS NULL) AND (x_adnl_unsub_loan_elig_flag IS NULL)))
        AND ((tlinfo.lock_awd_flag = x_lock_awd_flag) OR ((tlinfo.lock_awd_flag IS NULL) AND (x_lock_awd_flag IS NULL)))
        AND ((tlinfo.lock_coa_flag = x_lock_coa_flag) OR ((tlinfo.lock_coa_flag IS NULL) AND (x_lock_coa_flag IS NULL)))

       ) THEN
      NULL;
    ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_ci_sequence_number                IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_coa_pending                       IN     VARCHAR2,
    x_verification_process_run          IN     VARCHAR2,
    x_inst_verif_status_date            IN     DATE,
    x_manual_verif_flag                 IN     VARCHAR2,
    x_fed_verif_status                  IN     VARCHAR2,
    x_fed_verif_status_date             IN     DATE,
    x_inst_verif_status                 IN     VARCHAR2,
    x_nslds_eligible                    IN     VARCHAR2,
    x_ede_correction_batch_id           IN     VARCHAR2, -- Modified by rbezawad on 22-Jun-2001 w.r.t. Bug ID: 1821811
    x_fa_process_status_date            IN     DATE,
    x_isir_corr_status                  IN     VARCHAR2,
    x_isir_corr_status_date             IN     DATE,
    x_isir_status                       IN     VARCHAR2,
    x_isir_status_date                  IN     DATE,
    x_coa_code_f                        IN     VARCHAR2,
    x_coa_code_i                        IN     VARCHAR2,
    x_coa_f                             IN     NUMBER,
    x_coa_i                             IN     NUMBER,
    x_disbursement_hold                 IN     VARCHAR2,
    x_fa_process_status                 IN     VARCHAR2,
    x_notification_status               IN     VARCHAR2,
    x_notification_status_date          IN     DATE,
    x_packaging_hold                    IN     VARCHAR2,
    x_packaging_status                  IN     VARCHAR2,
    x_packaging_status_date             IN     DATE,
    x_total_package_accepted            IN     NUMBER,
    x_total_package_offered             IN     NUMBER,
    x_admstruct_id                      IN     VARCHAR2,
    x_admsegment_1                      IN     VARCHAR2,
    x_admsegment_2                      IN     VARCHAR2,
    x_admsegment_3                      IN     VARCHAR2,
    x_admsegment_4                      IN     VARCHAR2,
    x_admsegment_5                      IN     VARCHAR2,
    x_admsegment_6                      IN     VARCHAR2,
    x_admsegment_7                      IN     VARCHAR2,
    x_admsegment_8                      IN     VARCHAR2,
    x_admsegment_9                      IN     VARCHAR2,
    x_admsegment_10                     IN     VARCHAR2,
    x_admsegment_11                     IN     VARCHAR2,
    x_admsegment_12                     IN     VARCHAR2,
    x_admsegment_13                     IN     VARCHAR2,
    x_admsegment_14                     IN     VARCHAR2,
    x_admsegment_15                     IN     VARCHAR2,
    x_admsegment_16                     IN     VARCHAR2,
    x_admsegment_17                     IN     VARCHAR2,
    x_admsegment_18                     IN     VARCHAR2,
    x_admsegment_19                     IN     VARCHAR2,
    x_admsegment_20                     IN     VARCHAR2,
    x_packstruct_id                     IN     VARCHAR2,
    x_packsegment_1                     IN     VARCHAR2,
    x_packsegment_2                     IN     VARCHAR2,
    x_packsegment_3                     IN     VARCHAR2,
    x_packsegment_4                     IN     VARCHAR2,
    x_packsegment_5                     IN     VARCHAR2,
    x_packsegment_6                     IN     VARCHAR2,
    x_packsegment_7                     IN     VARCHAR2,
    x_packsegment_8                     IN     VARCHAR2,
    x_packsegment_9                     IN     VARCHAR2,
    x_packsegment_10                    IN     VARCHAR2,
    x_packsegment_11                    IN     VARCHAR2,
    x_packsegment_12                    IN     VARCHAR2,
    x_packsegment_13                    IN     VARCHAR2,
    x_packsegment_14                    IN     VARCHAR2,
    x_packsegment_15                    IN     VARCHAR2,
    x_packsegment_16                    IN     VARCHAR2,
    x_packsegment_17                    IN     VARCHAR2,
    x_packsegment_18                    IN     VARCHAR2,
    x_packsegment_19                    IN     VARCHAR2,
    x_packsegment_20                    IN     VARCHAR2,
    x_miscstruct_id                     IN     VARCHAR2,
    x_miscsegment_1                     IN     VARCHAR2,
    x_miscsegment_2                     IN     VARCHAR2,
    x_miscsegment_3                     IN     VARCHAR2,
    x_miscsegment_4                     IN     VARCHAR2,
    x_miscsegment_5                     IN     VARCHAR2,
    x_miscsegment_6                     IN     VARCHAR2,
    x_miscsegment_7                     IN     VARCHAR2,
    x_miscsegment_8                     IN     VARCHAR2,
    x_miscsegment_9                     IN     VARCHAR2,
    x_miscsegment_10                    IN     VARCHAR2,
    x_miscsegment_11                    IN     VARCHAR2,
    x_miscsegment_12                    IN     VARCHAR2,
    x_miscsegment_13                    IN     VARCHAR2,
    x_miscsegment_14                    IN     VARCHAR2,
    x_miscsegment_15                    IN     VARCHAR2,
    x_miscsegment_16                    IN     VARCHAR2,
    x_miscsegment_17                    IN     VARCHAR2,
    x_miscsegment_18                    IN     VARCHAR2,
    x_miscsegment_19                    IN     VARCHAR2,
    x_miscsegment_20                    IN     VARCHAR2,
    x_prof_judgement_flg                IN     VARCHAR2,
    x_nslds_data_override_flg           IN     VARCHAR2,
    x_target_group                      IN     VARCHAR2,
    x_coa_fixed                         IN     NUMBER,
    x_coa_pell                          IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_profile_status                    IN     VARCHAR2,
    x_profile_status_date               IN     DATE,
    x_profile_fc                        IN     NUMBER,
    x_tolerance_amount                  IN     NUMBER,    --Modified by kkillams on 28- June-2001 w.r.t. bug 1794114
    x_manual_disb_hold                  IN     VARCHAR2,
    x_pell_alt_expense                  IN     NUMBER,
    x_assoc_org_num                     IN     NUMBER,    --Modified by ugummall on 25-SEP-2003 w.r.t. FA 126 - Multiple FA Offices
    x_award_fmly_contribution_type      IN     VARCHAR2,   --Modified by rasahoo  on 17-NOV-2003 w.r.t FA 128 ISIR update 20004-05
    x_isir_locked_by                    IN     VARCHAR2,
    x_adnl_unsub_loan_elig_flag         IN     VARCHAR2,
    x_lock_awd_flag                     IN     VARCHAR2,
    x_lock_coa_flag                     IN     VARCHAR2

  ) AS
  /*
  ||  Created By : skoppula
  ||  Created On : 07-DEC-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  masehgal        25-Sep-2002     FA 014 -To Do Enhancements
  ||                                  Added manual_disb_hold checkbox
  ||  vvutukur        16-feb-2002     passed igf_aw_gen.get_org_id to before_dml call instead of x_org_id bug:2222272.
  ||  rbezawad        22-Jun-2001     x_ede_correction_batch_id parameter in procedures is
  ||                                  changed to VARCHAR2 Datatype w.r.t. Bug ID: 1821811.
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
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_base_id                           => x_base_id,
      x_ci_cal_type                       => x_ci_cal_type,
      x_person_id                         => x_person_id,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_org_id                            => igf_aw_gen.get_org_id,
      x_coa_pending                       => x_coa_pending,
      x_verification_process_run          => x_verification_process_run,
      x_inst_verif_status_date            => x_inst_verif_status_date,
      x_manual_verif_flag                 => x_manual_verif_flag,
      x_fed_verif_status                  => x_fed_verif_status,
      x_fed_verif_status_date             => x_fed_verif_status_date,
      x_inst_verif_status                 => x_inst_verif_status,
      x_nslds_eligible                    => x_nslds_eligible,
      x_ede_correction_batch_id           => x_ede_correction_batch_id,
      x_fa_process_status_date            => x_fa_process_status_date,
      x_isir_corr_status                  => x_isir_corr_status,
      x_isir_corr_status_date             => x_isir_corr_status_date,
      x_isir_status                       => x_isir_status,
      x_isir_status_date                  => x_isir_status_date,
      x_coa_code_f                        => x_coa_code_f,
      x_coa_code_i                        => x_coa_code_i,
      x_coa_f                             => x_coa_f,
      x_coa_i                             => x_coa_i,
      x_disbursement_hold                 => x_disbursement_hold,
      x_fa_process_status                 => x_fa_process_status,
      x_notification_status               => x_notification_status,
      x_notification_status_date          => x_notification_status_date,
      x_packaging_status                  => x_packaging_status,
      x_packaging_status_date             => x_packaging_status_date,
      x_total_package_accepted            => x_total_package_accepted,
      x_total_package_offered             => x_total_package_offered,
      x_admstruct_id                      => x_admstruct_id,
      x_admsegment_1                      => x_admsegment_1,
      x_admsegment_2                      => x_admsegment_2,
      x_admsegment_3                      => x_admsegment_3,
      x_admsegment_4                      => x_admsegment_4,
      x_admsegment_5                      => x_admsegment_5,
      x_admsegment_6                      => x_admsegment_6,
      x_admsegment_7                      => x_admsegment_7,
      x_admsegment_8                      => x_admsegment_8,
      x_admsegment_9                      => x_admsegment_9,
      x_admsegment_10                     => x_admsegment_10,
      x_admsegment_11                     => x_admsegment_11,
      x_admsegment_12                     => x_admsegment_12,
      x_admsegment_13                     => x_admsegment_13,
      x_admsegment_14                     => x_admsegment_14,
      x_admsegment_15                     => x_admsegment_15,
      x_admsegment_16                     => x_admsegment_16,
      x_admsegment_17                     => x_admsegment_17,
      x_admsegment_18                     => x_admsegment_18,
      x_admsegment_19                     => x_admsegment_19,
      x_admsegment_20                     => x_admsegment_20,
      x_packstruct_id                     => x_packstruct_id,
      x_packsegment_1                     => x_packsegment_1,
      x_packsegment_2                     => x_packsegment_2,
      x_packsegment_3                     => x_packsegment_3,
      x_packsegment_4                     => x_packsegment_4,
      x_packsegment_5                     => x_packsegment_5,
      x_packsegment_6                     => x_packsegment_6,
      x_packsegment_7                     => x_packsegment_7,
      x_packsegment_8                     => x_packsegment_8,
      x_packsegment_9                     => x_packsegment_9,
      x_packsegment_10                    => x_packsegment_10,
      x_packsegment_11                    => x_packsegment_11,
      x_packsegment_12                    => x_packsegment_12,
      x_packsegment_13                    => x_packsegment_13,
      x_packsegment_14                    => x_packsegment_14,
      x_packsegment_15                    => x_packsegment_15,
      x_packsegment_16                    => x_packsegment_16,
      x_packsegment_17                    => x_packsegment_17,
      x_packsegment_18                    => x_packsegment_18,
      x_packsegment_19                    => x_packsegment_19,
      x_packsegment_20                    => x_packsegment_20,
      x_miscstruct_id                     => x_miscstruct_id,
      x_miscsegment_1                     => x_miscsegment_1,
      x_miscsegment_2                     => x_miscsegment_2,
      x_miscsegment_3                     => x_miscsegment_3,
      x_miscsegment_4                     => x_miscsegment_4,
      x_miscsegment_5                     => x_miscsegment_5,
      x_miscsegment_6                     => x_miscsegment_6,
      x_miscsegment_7                     => x_miscsegment_7,
      x_miscsegment_8                     => x_miscsegment_8,
      x_miscsegment_9                     => x_miscsegment_9,
      x_miscsegment_10                    => x_miscsegment_10,
      x_miscsegment_11                    => x_miscsegment_11,
      x_miscsegment_12                    => x_miscsegment_12,
      x_miscsegment_13                    => x_miscsegment_13,
      x_miscsegment_14                    => x_miscsegment_14,
      x_miscsegment_15                    => x_miscsegment_15,
      x_miscsegment_16                    => x_miscsegment_16,
      x_miscsegment_17                    => x_miscsegment_17,
      x_miscsegment_18                    => x_miscsegment_18,
      x_miscsegment_19                    => x_miscsegment_19,
      x_miscsegment_20                    => x_miscsegment_20,
      x_prof_judgement_flg                => x_prof_judgement_flg,
      x_nslds_data_override_flg           => x_nslds_data_override_flg,
      x_target_group                      => x_target_group,
      x_coa_fixed                         => x_coa_fixed,
      x_coa_pell                          => x_coa_pell,
      x_profile_status                    => x_profile_status,
      x_profile_status_date               => x_profile_status_date,
      x_profile_fc                        => x_profile_fc,
      x_tolerance_amount                  => x_tolerance_amount,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_manual_disb_hold                  => x_manual_disb_hold,
      x_pell_alt_expense                  => x_pell_alt_expense,
      x_assoc_org_num                     => x_assoc_org_num,        --Modified by ugummall on 25-SEP-2003 w.r.t FA 126 - Multiple FA Offices
      x_award_fmly_contribution_type      => x_award_fmly_contribution_type,
      x_isir_locked_by                    => x_isir_locked_by,
      x_adnl_unsub_loan_elig_flag         => x_adnl_unsub_loan_elig_flag,
      x_lock_awd_flag                     => x_lock_awd_flag,
      x_lock_coa_flag                     => x_lock_coa_flag

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

    UPDATE igf_ap_fa_base_rec_all
      SET
        ci_cal_type                       = new_references.ci_cal_type,
        person_id                         = new_references.person_id,
        ci_sequence_number                = new_references.ci_sequence_number,
        coa_pending                       = new_references.coa_pending,
        verification_process_run          = new_references.verification_process_run,
        inst_verif_status_date            = new_references.inst_verif_status_date,
        manual_verif_flag                 = new_references.manual_verif_flag,
        fed_verif_status                  = new_references.fed_verif_status,
        fed_verif_status_date             = new_references.fed_verif_status_date,
        inst_verif_status                 = new_references.inst_verif_status,
        nslds_eligible                    = new_references.nslds_eligible,
        ede_correction_batch_id           = new_references.ede_correction_batch_id,
        fa_process_status_date            = new_references.fa_process_status_date,
        isir_corr_status                  = new_references.isir_corr_status,
        isir_corr_status_date             = new_references.isir_corr_status_date,
        isir_status                       = new_references.isir_status,
        isir_status_date                  = new_references.isir_status_date,
        coa_code_f                        = new_references.coa_code_f,
        coa_code_i                        = new_references.coa_code_i,
        coa_f                             = new_references.coa_f,
        coa_i                             = new_references.coa_i,
        disbursement_hold                 = new_references.disbursement_hold,
        fa_process_status                 = new_references.fa_process_status,
        notification_status               = new_references.notification_status,
        notification_status_date          = new_references.notification_status_date,
        packaging_status                  = new_references.packaging_status,
        packaging_status_date             = new_references.packaging_status_date,
        total_package_accepted            = new_references.total_package_accepted,
        total_package_offered             = new_references.total_package_offered,
        admstruct_id                      = new_references.admstruct_id,
        admsegment_1                      = new_references.admsegment_1,
        admsegment_2                      = new_references.admsegment_2,
        admsegment_3                      = new_references.admsegment_3,
        admsegment_4                      = new_references.admsegment_4,
        admsegment_5                      = new_references.admsegment_5,
        admsegment_6                      = new_references.admsegment_6,
        admsegment_7                      = new_references.admsegment_7,
        admsegment_8                      = new_references.admsegment_8,
        admsegment_9                      = new_references.admsegment_9,
        admsegment_10                     = new_references.admsegment_10,
        admsegment_11                     = new_references.admsegment_11,
        admsegment_12                     = new_references.admsegment_12,
        admsegment_13                     = new_references.admsegment_13,
        admsegment_14                     = new_references.admsegment_14,
        admsegment_15                     = new_references.admsegment_15,
        admsegment_16                     = new_references.admsegment_16,
        admsegment_17                     = new_references.admsegment_17,
        admsegment_18                     = new_references.admsegment_18,
        admsegment_19                     = new_references.admsegment_19,
        admsegment_20                     = new_references.admsegment_20,
        packstruct_id                     = new_references.packstruct_id,
        packsegment_1                     = new_references.packsegment_1,
        packsegment_2                     = new_references.packsegment_2,
        packsegment_3                     = new_references.packsegment_3,
        packsegment_4                     = new_references.packsegment_4,
        packsegment_5                     = new_references.packsegment_5,
        packsegment_6                     = new_references.packsegment_6,
        packsegment_7                     = new_references.packsegment_7,
        packsegment_8                     = new_references.packsegment_8,
        packsegment_9                     = new_references.packsegment_9,
        packsegment_10                    = new_references.packsegment_10,
        packsegment_11                    = new_references.packsegment_11,
        packsegment_12                    = new_references.packsegment_12,
        packsegment_13                    = new_references.packsegment_13,
        packsegment_14                    = new_references.packsegment_14,
        packsegment_15                    = new_references.packsegment_15,
        packsegment_16                    = new_references.packsegment_16,
        packsegment_17                    = new_references.packsegment_17,
        packsegment_18                    = new_references.packsegment_18,
        packsegment_19                    = new_references.packsegment_19,
        packsegment_20                    = new_references.packsegment_20,
        miscstruct_id                     = new_references.miscstruct_id,
        miscsegment_1                     = new_references.miscsegment_1,
        miscsegment_2                     = new_references.miscsegment_2,
        miscsegment_3                     = new_references.miscsegment_3,
        miscsegment_4                     = new_references.miscsegment_4,
        miscsegment_5                     = new_references.miscsegment_5,
        miscsegment_6                     = new_references.miscsegment_6,
        miscsegment_7                     = new_references.miscsegment_7,
        miscsegment_8                     = new_references.miscsegment_8,
        miscsegment_9                     = new_references.miscsegment_9,
        miscsegment_10                    = new_references.miscsegment_10,
        miscsegment_11                    = new_references.miscsegment_11,
        miscsegment_12                    = new_references.miscsegment_12,
        miscsegment_13                    = new_references.miscsegment_13,
        miscsegment_14                    = new_references.miscsegment_14,
        miscsegment_15                    = new_references.miscsegment_15,
        miscsegment_16                    = new_references.miscsegment_16,
        miscsegment_17                    = new_references.miscsegment_17,
        miscsegment_18                    = new_references.miscsegment_18,
        miscsegment_19                    = new_references.miscsegment_19,
        miscsegment_20                    = new_references.miscsegment_20,
        prof_judgement_flg                = new_references.prof_judgement_flg,
        nslds_data_override_flg           = new_references.nslds_data_override_flg,
        target_group                      = new_references.target_group,
        coa_fixed                         = new_references.coa_fixed,
        coa_pell                          = new_references.coa_pell,
        profile_status                    = new_references.profile_status,
        profile_status_date               = new_references.profile_status_date,
        profile_fc                        = new_references.profile_fc,
        tolerance_amount                  = new_references.tolerance_amount,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        manual_disb_hold                  = new_references.manual_disb_hold,
        pell_alt_expense                  = new_references.pell_alt_expense,
        assoc_org_num                     = new_references.assoc_org_num,          --Modified by ugummall on 25-SEP-2003 w.r.t FA 126 - Multiple FA Offices
        award_fmly_contribution_type      = new_references.award_fmly_contribution_type,
        isir_locked_by                    = new_references.isir_locked_by,
        adnl_unsub_loan_elig_flag         = new_references.adnl_unsub_loan_elig_flag,
        lock_awd_flag                     = new_references.lock_awd_flag,
        lock_coa_flag                     = new_references.lock_coa_flag

      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_base_id                           IN OUT NOCOPY NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_ci_sequence_number                IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_coa_pending                       IN     VARCHAR2,
    x_verification_process_run          IN     VARCHAR2,
    x_inst_verif_status_date            IN     DATE,
    x_manual_verif_flag                 IN     VARCHAR2,
    x_fed_verif_status                  IN     VARCHAR2,
    x_fed_verif_status_date             IN     DATE,
    x_inst_verif_status                 IN     VARCHAR2,
    x_nslds_eligible                    IN     VARCHAR2,
    x_ede_correction_batch_id           IN     VARCHAR2, -- Modified by rbezawad on 22-Jun-2001 w.r.t. Bug ID: 1821811
    x_fa_process_status_date            IN     DATE,
    x_isir_corr_status                  IN     VARCHAR2,
    x_isir_corr_status_date             IN     DATE,
    x_isir_status                       IN     VARCHAR2,
    x_isir_status_date                  IN     DATE,
    x_coa_code_f                        IN     VARCHAR2,
    x_coa_code_i                        IN     VARCHAR2,
    x_coa_f                             IN     NUMBER,
    x_coa_i                             IN     NUMBER,
    x_disbursement_hold                 IN     VARCHAR2,
    x_fa_process_status                 IN     VARCHAR2,
    x_notification_status               IN     VARCHAR2,
    x_notification_status_date          IN     DATE,
    x_packaging_hold                    IN     VARCHAR2,
    x_packaging_status                  IN     VARCHAR2,
    x_packaging_status_date             IN     DATE,
    x_total_package_accepted            IN     NUMBER,
    x_total_package_offered             IN     NUMBER,
    x_admstruct_id                      IN     VARCHAR2,
    x_admsegment_1                      IN     VARCHAR2,
    x_admsegment_2                      IN     VARCHAR2,
    x_admsegment_3                      IN     VARCHAR2,
    x_admsegment_4                      IN     VARCHAR2,
    x_admsegment_5                      IN     VARCHAR2,
    x_admsegment_6                      IN     VARCHAR2,
    x_admsegment_7                      IN     VARCHAR2,
    x_admsegment_8                      IN     VARCHAR2,
    x_admsegment_9                      IN     VARCHAR2,
    x_admsegment_10                     IN     VARCHAR2,
    x_admsegment_11                     IN     VARCHAR2,
    x_admsegment_12                     IN     VARCHAR2,
    x_admsegment_13                     IN     VARCHAR2,
    x_admsegment_14                     IN     VARCHAR2,
    x_admsegment_15                     IN     VARCHAR2,
    x_admsegment_16                     IN     VARCHAR2,
    x_admsegment_17                     IN     VARCHAR2,
    x_admsegment_18                     IN     VARCHAR2,
    x_admsegment_19                     IN     VARCHAR2,
    x_admsegment_20                     IN     VARCHAR2,
    x_packstruct_id                     IN     VARCHAR2,
    x_packsegment_1                     IN     VARCHAR2,
    x_packsegment_2                     IN     VARCHAR2,
    x_packsegment_3                     IN     VARCHAR2,
    x_packsegment_4                     IN     VARCHAR2,
    x_packsegment_5                     IN     VARCHAR2,
    x_packsegment_6                     IN     VARCHAR2,
    x_packsegment_7                     IN     VARCHAR2,
    x_packsegment_8                     IN     VARCHAR2,
    x_packsegment_9                     IN     VARCHAR2,
    x_packsegment_10                    IN     VARCHAR2,
    x_packsegment_11                    IN     VARCHAR2,
    x_packsegment_12                    IN     VARCHAR2,
    x_packsegment_13                    IN     VARCHAR2,
    x_packsegment_14                    IN     VARCHAR2,
    x_packsegment_15                    IN     VARCHAR2,
    x_packsegment_16                    IN     VARCHAR2,
    x_packsegment_17                    IN     VARCHAR2,
    x_packsegment_18                    IN     VARCHAR2,
    x_packsegment_19                    IN     VARCHAR2,
    x_packsegment_20                    IN     VARCHAR2,
    x_miscstruct_id                     IN     VARCHAR2,
    x_miscsegment_1                     IN     VARCHAR2,
    x_miscsegment_2                     IN     VARCHAR2,
    x_miscsegment_3                     IN     VARCHAR2,
    x_miscsegment_4                     IN     VARCHAR2,
    x_miscsegment_5                     IN     VARCHAR2,
    x_miscsegment_6                     IN     VARCHAR2,
    x_miscsegment_7                     IN     VARCHAR2,
    x_miscsegment_8                     IN     VARCHAR2,
    x_miscsegment_9                     IN     VARCHAR2,
    x_miscsegment_10                    IN     VARCHAR2,
    x_miscsegment_11                    IN     VARCHAR2,
    x_miscsegment_12                    IN     VARCHAR2,
    x_miscsegment_13                    IN     VARCHAR2,
    x_miscsegment_14                    IN     VARCHAR2,
    x_miscsegment_15                    IN     VARCHAR2,
    x_miscsegment_16                    IN     VARCHAR2,
    x_miscsegment_17                    IN     VARCHAR2,
    x_miscsegment_18                    IN     VARCHAR2,
    x_miscsegment_19                    IN     VARCHAR2,
    x_miscsegment_20                    IN     VARCHAR2,
    x_prof_judgement_flg                IN     VARCHAR2,
    x_nslds_data_override_flg           IN     VARCHAR2,
    x_target_group                      IN     VARCHAR2,
    x_coa_fixed                         IN     NUMBER,
    x_coa_pell                          IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_profile_status                    IN     VARCHAR2,
    x_profile_status_date               IN     DATE,
    x_profile_fc                        IN     NUMBER,
    x_tolerance_amount                  IN     NUMBER,    --Modified by kkillams on 28- June-2001 w.r.t. bug 1794114
    x_manual_disb_hold                  IN     VARCHAR2,
    x_pell_alt_expense                  IN     NUMBER,
    x_assoc_org_num                     IN     NUMBER,   --Modified by ugummall on 25-SEP-2003 w.r.t FA 126 - Multiple FA Offices
    x_award_fmly_contribution_type      IN     VARCHAR2,  --Modified by rasahoo  on 17-NOV-2003 w.r.t FA 128 ISIR update 20004-05
    x_isir_locked_by                    IN     VARCHAR2,
    x_adnl_unsub_loan_elig_flag         IN     VARCHAR2,
    x_lock_awd_flag                     IN     VARCHAR2,
    x_lock_coa_flag                     IN     VARCHAR2

  ) AS
  /*
  ||  Created By : skoppula
  ||  Created On : 07-DEC-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  masehgal        25-Sep-2002     FA 014 -To Do Enhancements
  ||                                  Added manual_disb_hold checkbox
  ||  rbezawad        22-Jun-2001     x_ede_correction_batch_id parameter in procedures is
  ||                                  changed to VARCHAR2 Datatype w.r.t. Bug ID: 1821811.
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_ap_fa_base_rec_all
      WHERE    base_id = x_base_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_base_id,
        x_ci_cal_type,
        x_person_id,
        x_ci_sequence_number,
        x_org_id,
        x_coa_pending,
        x_verification_process_run,
        x_inst_verif_status_date,
        x_manual_verif_flag,
        x_fed_verif_status,
        x_fed_verif_status_date,
        x_inst_verif_status,
        x_nslds_eligible,
        x_ede_correction_batch_id,
        x_fa_process_status_date,
        x_isir_corr_status,
        x_isir_corr_status_date,
        x_isir_status,
        x_isir_status_date,
        x_coa_code_f,
        x_coa_code_i,
        x_coa_f,
        x_coa_i,
        x_disbursement_hold,
        x_fa_process_status,
        x_notification_status,
        x_notification_status_date,
        NULL ,  -- Obsoletion under FA 101 (SAP)
        x_packaging_status,
        x_packaging_status_date,
        x_total_package_accepted,
        x_total_package_offered,
        x_admstruct_id,
        x_admsegment_1,
        x_admsegment_2,
        x_admsegment_3,
        x_admsegment_4,
        x_admsegment_5,
        x_admsegment_6,
        x_admsegment_7,
        x_admsegment_8,
        x_admsegment_9,
        x_admsegment_10,
        x_admsegment_11,
        x_admsegment_12,
        x_admsegment_13,
        x_admsegment_14,
        x_admsegment_15,
        x_admsegment_16,
        x_admsegment_17,
        x_admsegment_18,
        x_admsegment_19,
        x_admsegment_20,
        x_packstruct_id,
        x_packsegment_1,
        x_packsegment_2,
        x_packsegment_3,
        x_packsegment_4,
        x_packsegment_5,
        x_packsegment_6,
        x_packsegment_7,
        x_packsegment_8,
        x_packsegment_9,
        x_packsegment_10,
        x_packsegment_11,
        x_packsegment_12,
        x_packsegment_13,
        x_packsegment_14,
        x_packsegment_15,
        x_packsegment_16,
        x_packsegment_17,
        x_packsegment_18,
        x_packsegment_19,
        x_packsegment_20,
        x_miscstruct_id,
        x_miscsegment_1,
        x_miscsegment_2,
        x_miscsegment_3,
        x_miscsegment_4,
        x_miscsegment_5,
        x_miscsegment_6,
        x_miscsegment_7,
        x_miscsegment_8,
        x_miscsegment_9,
        x_miscsegment_10,
        x_miscsegment_11,
        x_miscsegment_12,
        x_miscsegment_13,
        x_miscsegment_14,
        x_miscsegment_15,
        x_miscsegment_16,
        x_miscsegment_17,
        x_miscsegment_18,
        x_miscsegment_19,
        x_miscsegment_20,
        x_prof_judgement_flg,
        x_nslds_data_override_flg,
        x_target_group,
        x_coa_fixed,
        x_coa_pell,
        x_mode ,
        x_profile_status,
        x_profile_status_date,
        x_profile_fc,
        x_tolerance_amount,
        x_manual_disb_hold,
        x_pell_alt_expense,
        x_assoc_org_num,       --Modified by ugummall on 25-SEP-2003 w.r.t FA 126 - Multiple FA Offices
        x_award_fmly_contribution_type,
        x_isir_locked_by,
	       x_adnl_unsub_loan_elig_flag,
        x_lock_awd_flag,
        x_lock_coa_flag

      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_base_id,
      x_ci_cal_type,
      x_person_id,
      x_ci_sequence_number,
      x_org_id,
      x_coa_pending,
      x_verification_process_run,
      x_inst_verif_status_date,
      x_manual_verif_flag,
      x_fed_verif_status,
      x_fed_verif_status_date,
      x_inst_verif_status,
      x_nslds_eligible,
      x_ede_correction_batch_id,
      x_fa_process_status_date,
      x_isir_corr_status,
      x_isir_corr_status_date,
      x_isir_status,
      x_isir_status_date,
      x_coa_code_f,
      x_coa_code_i,
      x_coa_f,
      x_coa_i,
      x_disbursement_hold,
      x_fa_process_status,
      x_notification_status,
      x_notification_status_date,
      NULL , --  -- Obsoletion under FA 101 (SAP)
      x_packaging_status,
      x_packaging_status_date,
      x_total_package_accepted,
      x_total_package_offered,
      x_admstruct_id,
      x_admsegment_1,
      x_admsegment_2,
      x_admsegment_3,
      x_admsegment_4,
      x_admsegment_5,
      x_admsegment_6,
      x_admsegment_7,
      x_admsegment_8,
      x_admsegment_9,
      x_admsegment_10,
      x_admsegment_11,
      x_admsegment_12,
      x_admsegment_13,
      x_admsegment_14,
      x_admsegment_15,
      x_admsegment_16,
      x_admsegment_17,
      x_admsegment_18,
      x_admsegment_19,
      x_admsegment_20,
      x_packstruct_id,
      x_packsegment_1,
      x_packsegment_2,
      x_packsegment_3,
      x_packsegment_4,
      x_packsegment_5,
      x_packsegment_6,
      x_packsegment_7,
      x_packsegment_8,
      x_packsegment_9,
      x_packsegment_10,
      x_packsegment_11,
      x_packsegment_12,
      x_packsegment_13,
      x_packsegment_14,
      x_packsegment_15,
      x_packsegment_16,
      x_packsegment_17,
      x_packsegment_18,
      x_packsegment_19,
      x_packsegment_20,
      x_miscstruct_id,
      x_miscsegment_1,
      x_miscsegment_2,
      x_miscsegment_3,
      x_miscsegment_4,
      x_miscsegment_5,
      x_miscsegment_6,
      x_miscsegment_7,
      x_miscsegment_8,
      x_miscsegment_9,
      x_miscsegment_10,
      x_miscsegment_11,
      x_miscsegment_12,
      x_miscsegment_13,
      x_miscsegment_14,
      x_miscsegment_15,
      x_miscsegment_16,
      x_miscsegment_17,
      x_miscsegment_18,
      x_miscsegment_19,
      x_miscsegment_20,
      x_prof_judgement_flg,
      x_nslds_data_override_flg,
      x_target_group,
      x_coa_fixed,
      x_coa_pell,
      x_mode,
      x_profile_status,
      x_profile_status_date,
      x_profile_fc,
      x_tolerance_amount,
      x_manual_disb_hold,
      x_pell_alt_expense,
      x_assoc_org_num,        --Modified by ugummall on 25-SEP-2003 w.r.t FA 126 - Multiple FA Offices
      x_award_fmly_contribution_type,
      x_isir_locked_by,
      x_adnl_unsub_loan_elig_flag,
      x_lock_awd_flag,
      x_lock_coa_flag

    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : skoppula
  ||  Created On : 07-DEC-2000
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

    DELETE FROM igf_ap_fa_base_rec_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_ap_fa_base_rec_pkg;

/
