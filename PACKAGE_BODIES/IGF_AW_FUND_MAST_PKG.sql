--------------------------------------------------------
--  DDL for Package Body IGF_AW_FUND_MAST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_FUND_MAST_PKG" AS
/* $Header: IGFWI11B.pls 120.3 2005/07/15 09:58:43 appldev ship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: IGF_AW_FUND_MAST_PKG
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
 | WHO        WHEN         WHAT                                          |
 | museshad   14-Jul-2005  Build FA 140.                                 |
 |                         Modified TBH procs for the new columns        |
 |                                                                       |
 | museshad   25-May-2005  Build# FA157 - Bug# 4382371.                  |
 |                         New column 'DISB_ROUNDING_CODE' has been added|
 |                         to the table 'IGF_AW_FUND_MAST_ALL'. Added    |
 |                         this to all TBH procs.                        |
 |                                                                       |
 | brajendr   14-Oct-2004  Added the new columns for FA152 - Repackaging |
 |                         and COA Build.                                |
 |                                                                       |
 | veramach   July 2004    FA 151 HR Integration(bug#3709292)            |
 |                         Obsoletes min_hr_rate,max_hr_rate,salary_based|
 |                         govt_share_perct                              |
 | veramach   3-NOV-2003   FA 125 Multiple Distr Methods                 |
 |                         Removed elig_criteria from all assginments,   |
 |                         select,insert,update statements               |
 | pathipat   12-Feb-2003  Enh 2747325 - Locking Issues build            |
 |                         Removed proc get_fk_igs_fi_fee_types()        |
 | SMVK       09-Feb-2003  Bug # 2758812. Added send_without_doc column. |
 | adhawan  10-dec-2002  #Bug Id 2676394                                 |
 |                        fm_fc_meth has been obsoleted , removed it from|
 |                        lock_row.                                      |
 | adhawan  06-nov-2002  #Bug id 2613536                                 |
 |                        Obsoletion of SAP_TYPE                         |
 | ADHAWAN  31-OCT-2002 #Bug 2613546 added gift_aid to the Tbh calls     |
 | PROCEDURE get_fk_igs_ca_inst  was referrring to igf_aw_pkg_run_all    |
 |                                 changed it to igf_aw_fund_mast_all    |
 | vchappid  02-Apr-2002  Enh# bug2293676, modified check child          |
 | vvutukur  19-feb-2002  modification done in check_parent_existance    |
 |                        reg. org_id for bug:2222272 as part of SWSCR006|
 *=======================================================================*/

  l_rowid VARCHAR2(25);
  old_references igf_aw_fund_mast_all%ROWTYPE;
  new_references igf_aw_fund_mast_all%ROWTYPE;

   PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_fund_id                           IN     NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_discontinue_fund                  IN     VARCHAR2,
    x_entitlement                       IN     VARCHAR2,
    x_auto_pkg                          IN     VARCHAR2,
    x_self_help                         IN     VARCHAR2,
    x_allow_man_pkg                     IN     VARCHAR2,
    x_update_need                       IN     VARCHAR2,
    x_disburse_fund                     IN     VARCHAR2,
    x_available_amt                     IN     NUMBER,
    x_offered_amt                       IN     NUMBER,
    x_pending_amt                       IN     NUMBER,
    x_accepted_amt                      IN     NUMBER,
    x_declined_amt                      IN     NUMBER,
    x_cancelled_amt                     IN     NUMBER,
    x_remaining_amt                     IN     NUMBER,
    x_enrollment_status                 IN     VARCHAR2,
    x_prn_award_letter                  IN     VARCHAR2,
    x_over_award_amt                    IN     NUMBER,
    x_over_award_perct                  IN     NUMBER,
    x_min_award_amt                     IN     NUMBER,
    x_max_award_amt                     IN     NUMBER,
    x_max_yearly_amt                    IN     NUMBER,
    x_max_life_amt                      IN     NUMBER,
    x_max_life_term                     IN     NUMBER,
    x_fm_fc_methd                       IN     VARCHAR2,
    x_roundoff_fact                     IN     VARCHAR2,
    x_replace_fc                        IN     VARCHAR2,
    x_allow_overaward                   IN     VARCHAR2,
    x_pckg_awd_stat                     IN     VARCHAR2,
    x_org_record_req                    IN     VARCHAR2,
    x_disb_record_req                   IN     VARCHAR2,
    x_prom_note_req                     IN     VARCHAR2,
    x_min_num_disb                      IN     NUMBER,
    x_max_num_disb                      IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_total_offered                     IN     NUMBER,
    x_total_accepted                    IN     NUMBER,
    x_total_declined                    IN     NUMBER,
    x_total_revoked                     IN     NUMBER,
    x_total_cancelled                   IN     NUMBER,
    x_total_disbursed                   IN     NUMBER,
    x_total_committed                   IN     NUMBER,
    x_committed_amt                     IN     NUMBER,
    x_disbursed_amt                     IN     NUMBER,
    x_awd_notice_txt                    IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_disb_verf_da                      IN     VARCHAR2,
    x_fund_exp_da                       IN     VARCHAR2,
    x_nslds_disb_da                     IN     VARCHAR2,
    x_disb_exp_da                       IN     VARCHAR2,
    x_fund_recv_reqd                    IN     VARCHAR2,
    x_show_on_bill                      IN     VARCHAR2,
    x_bill_desc                         IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER,
    x_spnsr_ref_num                     IN     VARCHAR2,
    x_party_id                          IN     VARCHAR2,
    x_spnsr_fee_type                    IN     VARCHAR2,
    x_min_credit_points                 IN     NUMBER,
    x_group_id                          IN     NUMBER,
    x_spnsr_attribute_category          IN     VARCHAR2,
    x_spnsr_attribute1                  IN     VARCHAR2,
    x_spnsr_attribute2                  IN     VARCHAR2,
    x_spnsr_attribute3                  IN     VARCHAR2,
    x_spnsr_attribute4                  IN     VARCHAR2,
    x_spnsr_attribute5                  IN     VARCHAR2,
    x_spnsr_attribute6                  IN     VARCHAR2,
    x_spnsr_attribute7                  IN     VARCHAR2,
    x_spnsr_attribute8                  IN     VARCHAR2,
    x_spnsr_attribute9                  IN     VARCHAR2,
    x_spnsr_attribute10                 IN     VARCHAR2,
    x_spnsr_attribute11                 IN     VARCHAR2,
    x_spnsr_attribute12                 IN     VARCHAR2,
    x_spnsr_attribute13                 IN     VARCHAR2,
    x_spnsr_attribute14                 IN     VARCHAR2,
    x_spnsr_attribute15                 IN     VARCHAR2,
    x_spnsr_attribute16                 IN     VARCHAR2,
    x_spnsr_attribute17                 IN     VARCHAR2,
    x_spnsr_attribute18                 IN     VARCHAR2,
    x_spnsr_attribute19                 IN     VARCHAR2,
    x_spnsr_attribute20                 IN     VARCHAR2,
    x_threshold_perct                   IN     NUMBER,
    x_threshold_value                   IN     NUMBER,
    x_ver_app_stat_override             IN     VARCHAR2 ,
    x_gift_aid                          IN     VARCHAR2,
    x_send_without_doc                  IN     VARCHAR2,   -- Added as part of Bug # 2758812
    x_re_pkg_verif_flag                 IN     VARCHAR2,
    x_donot_repkg_if_code               IN     VARCHAR2,
    x_lock_award_flag                   IN     VARCHAR2,
    x_disb_rounding_code                IN     VARCHAR2   DEFAULT NULL,
    x_view_only_flag                    IN     VARCHAR2   DEFAULT NULL,
    x_accept_less_amt_flag              IN     VARCHAR2   DEFAULT NULL,
    x_allow_inc_post_accept_flag        IN     VARCHAR2   DEFAULT NULL,
    x_min_increase_amt                  IN     NUMBER     DEFAULT NULL,
    x_allow_dec_post_accept_flag        IN     VARCHAR2   DEFAULT NULL,
    x_min_decrease_amt                  IN     NUMBER     DEFAULT NULL,
    x_allow_decln_post_accept_flag      IN     VARCHAR2   DEFAULT NULL,
    x_status_after_decline              IN     VARCHAR2   DEFAULT NULL,
    x_fund_information_txt              IN     VARCHAR2   DEFAULT NULL
  ) AS  /*
  ||  Created By : cdcruz
  ||  Created On : 14-NOV-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  museshad        14-Jul-2005     Build FA 140.
  ||                                  Changes relating to the addition of new
  ||                                  columns.
  ||  museshad        25-May-2005     Build# FA157 - Bug# 4382371.
  ||                                  New column 'DISB_ROUNDING_CODE' has been added
  ||                                  to the table 'IGF_AW_FUND_MAST_ALL'.
  ||                                  Modified the TBH to include this.
  ||  veramach        1-NOV-2003      FA 125 - Removed elig_criteria from assigments
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AW_FUND_MAST_ALL
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
    new_references.fund_id                           := x_fund_id;
    new_references.fund_code                         := x_fund_code;
    new_references.ci_cal_type                       := x_ci_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.description                       := x_description;
    new_references.discontinue_fund                  := x_discontinue_fund;
    new_references.entitlement                       := x_entitlement;
    new_references.auto_pkg                          := x_auto_pkg;
    new_references.self_help                         := x_self_help;
    new_references.allow_man_pkg                     := x_allow_man_pkg;
    new_references.update_need                       := x_update_need;
    new_references.disburse_fund                     := x_disburse_fund;
    new_references.available_amt                     := x_available_amt;
    new_references.offered_amt                       := x_offered_amt;
    new_references.pending_amt                       := x_pending_amt;
    new_references.accepted_amt                      := x_accepted_amt;
    new_references.declined_amt                      := x_declined_amt;
    new_references.cancelled_amt                     := x_cancelled_amt;
    new_references.remaining_amt                     := x_remaining_amt;
    new_references.enrollment_status                 := x_enrollment_status;
    new_references.prn_award_letter                  := x_prn_award_letter;
    new_references.over_award_amt                    := x_over_award_amt;
    new_references.over_award_perct                  := x_over_award_perct;
    new_references.min_award_amt                     := x_min_award_amt;
    new_references.max_award_amt                     := x_max_award_amt;
    new_references.max_yearly_amt                    := x_max_yearly_amt;
    new_references.max_life_amt                      := x_max_life_amt;
    new_references.max_life_term                     := x_max_life_term;
    new_references.fm_fc_methd                       := x_fm_fc_methd;
    new_references.roundoff_fact                     := x_roundoff_fact;
    new_references.replace_fc                        := x_replace_fc;
    new_references.allow_overaward                   := x_allow_overaward;
    new_references.pckg_awd_stat                     := x_pckg_awd_stat;
    new_references.org_record_req                    := x_org_record_req;
    new_references.disb_record_req                   := x_disb_record_req;
    new_references.prom_note_req                     := x_prom_note_req;
    new_references.min_num_disb                      := x_min_num_disb;
    new_references.max_num_disb                      := x_max_num_disb;
    new_references.fee_type                          := x_fee_type;
    new_references.total_offered                     := x_total_offered;
    new_references.total_accepted                    := x_total_accepted;
    new_references.total_declined                    := x_total_declined;
    new_references.total_revoked                     := x_total_revoked;
    new_references.total_cancelled                   := x_total_cancelled;
    new_references.total_disbursed                   := x_total_disbursed;
    new_references.total_committed                   := x_total_committed;
    new_references.committed_amt                     := x_committed_amt;
    new_references.disbursed_amt                     := x_disbursed_amt;
    new_references.awd_notice_txt                    := x_awd_notice_txt;
    new_references.attribute_category                := x_attribute_category;
    new_references.attribute1                        := x_attribute1;
    new_references.attribute2                        := x_attribute2;
    new_references.attribute3                        := x_attribute3;
    new_references.attribute4                        := x_attribute4;
    new_references.attribute5                        := x_attribute5;
    new_references.attribute6                        := x_attribute6;
    new_references.attribute7                        := x_attribute7;
    new_references.attribute8                        := x_attribute8;
    new_references.attribute9                        := x_attribute9;
    new_references.attribute10                       := x_attribute10;
    new_references.attribute11                       := x_attribute11;
    new_references.attribute12                       := x_attribute12;
    new_references.attribute13                       := x_attribute13;
    new_references.attribute14                       := x_attribute14;
    new_references.attribute15                       := x_attribute15;
    new_references.attribute16                       := x_attribute16;
    new_references.attribute17                       := x_attribute17;
    new_references.attribute18                       := x_attribute18;
    new_references.attribute19                       := x_attribute19;
    new_references.attribute20                       := x_attribute20;
    new_references.disb_verf_da                      := x_disb_verf_da;
    new_references.fund_exp_da                       := x_fund_exp_da;
    new_references.nslds_disb_da                     := x_nslds_disb_da;
    new_references.disb_exp_da                       := x_disb_exp_da;
    new_references.fund_recv_reqd                    := x_fund_recv_reqd;
    new_references.show_on_bill                      := x_show_on_bill;
    new_references.bill_desc                         := x_bill_desc;
    new_references.credit_type_id                    := x_credit_type_id;
    new_references.spnsr_ref_num                     := x_spnsr_ref_num;
    new_references.party_id                          := x_party_id;
    new_references.spnsr_fee_type                    := x_spnsr_fee_type;
    new_references.min_credit_points                 := x_min_credit_points;
    new_references.group_id                          := x_group_id;
    new_references.spnsr_attribute_category           := x_spnsr_attribute_category;
    new_references.spnsr_attribute1                   := x_spnsr_attribute1;
    new_references.spnsr_attribute2                   := x_spnsr_attribute2;
    new_references.spnsr_attribute3                   := x_spnsr_attribute3;
    new_references.spnsr_attribute4                   := x_spnsr_attribute4;
    new_references.spnsr_attribute5                   := x_spnsr_attribute5;
    new_references.spnsr_attribute6                   := x_spnsr_attribute6;
    new_references.spnsr_attribute7                   := x_spnsr_attribute7;
    new_references.spnsr_attribute8                   := x_spnsr_attribute8;
    new_references.spnsr_attribute9                   := x_spnsr_attribute9;
    new_references.spnsr_attribute10                  := x_spnsr_attribute10;
    new_references.spnsr_attribute11                  := x_spnsr_attribute11;
    new_references.spnsr_attribute12                  := x_spnsr_attribute12;
    new_references.spnsr_attribute13                  := x_spnsr_attribute13;
    new_references.spnsr_attribute14                  := x_spnsr_attribute14;
    new_references.spnsr_attribute15                  := x_spnsr_attribute15;
    new_references.spnsr_attribute16                  := x_spnsr_attribute16;
    new_references.spnsr_attribute17                  := x_spnsr_attribute17;
    new_references.spnsr_attribute18                  := x_spnsr_attribute18;
    new_references.spnsr_attribute19                  := x_spnsr_attribute19;
    new_references.spnsr_attribute20                  := x_spnsr_attribute20;
    new_references.threshold_perct                    := x_threshold_perct ;
    new_references.threshold_value                    := x_threshold_value  ;
    new_references.ver_app_stat_override              := x_ver_app_stat_override;
    new_references.gift_aid                           := x_gift_aid;
    new_references.send_without_doc                   := x_send_without_doc;
    new_references.re_pkg_verif_flag                  := x_re_pkg_verif_flag;
    new_references.donot_repkg_if_code                := x_donot_repkg_if_code;
    new_references.lock_award_flag                    := x_lock_award_flag;
    new_references.disb_rounding_code                 := x_disb_rounding_code;
    new_references.view_only_flag                     := x_view_only_flag;
    new_references.accept_less_amt_flag               := x_accept_less_amt_flag;
    new_references.allow_inc_post_accept_flag         := x_allow_inc_post_accept_flag;
    new_references.min_increase_amt                   := x_min_increase_amt;
    new_references.allow_dec_post_accept_flag         := x_allow_dec_post_accept_flag;
    new_references.min_decrease_amt                   := x_min_decrease_amt;
    new_references.allow_decln_post_accept_flag       := x_allow_decln_post_accept_flag;
    new_references.status_after_decline               := x_status_after_decline;
    new_references.fund_information_txt               := x_fund_information_txt;

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

  FUNCTION get_uk_for_validation (
    x_fund_code                         IN     VARCHAR2,
    x_ci_cal_type          IN     VARCHAR2,
    x_ci_sequence_number         IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 28-DEC-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
        FROM     igf_aw_fund_mast_all
       WHERE    fund_code = x_fund_code
         AND     ci_cal_type = x_ci_cal_type
         AND     ci_sequence_number = x_ci_sequence_number
         AND     ((l_rowid IS NULL) OR (rowid <> l_rowid));

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

  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : rasingh
  ||  Created On : 28-DEC-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.fund_code,
           new_references.ci_cal_type,
           new_references.ci_sequence_number
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 14-NOV-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  vvutukur       19-feb-2002     created new local variable l_org_id and modified the check with old_references.org_id
  ||                                 for bug:2222272 as part of SWSCR006(MO).
  ||  (reverse chronological order - newest change first)
  */

    l_org_id     igf_aw_fund_mast_all.org_id%TYPE   := igf_aw_gen.get_org_id;  --bug:2222272

  BEGIN

    IF (((old_references.fund_code = new_references.fund_code) AND
         (NVL(old_references.org_id,-99) = NVL(l_org_id,-99)) AND  --bug : 2222272
   (old_references.ci_cal_type = new_references.ci_cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.fund_code IS NULL) OR
         (l_org_id IS NULL) OR --bug 2222272
         (new_references.ci_cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_fund_cat_pkg.get_uk_for_validation (
                new_references.fund_code
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

--
-- Added Get PK Calls for Person ID Groups
--
     IF ((old_references.group_id = new_references.group_id )
         OR
         (new_references.group_id IS NULL)) THEN
      NULL;
     ELSIF NOT igs_pe_persid_group_pkg.get_pk_for_validation (
                new_references.group_id) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

--
-- Added Get PK Calls for Fee Types
--
     IF ((old_references.fee_type = new_references.fee_type)
         OR
         (new_references.fee_type IS NULL)) THEN
      NULL;
     ELSIF NOT igs_fi_fee_type_pkg.get_pk_for_validation (
                new_references.fee_type) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

     IF ((old_references.spnsr_fee_type = new_references.spnsr_fee_type)
         OR
         (new_references.spnsr_fee_type IS NULL)) THEN
      NULL;
     ELSIF NOT igs_fi_fee_type_pkg.get_pk_for_validation (
                new_references.spnsr_fee_type) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : cdcruz
  ||  Created On : 14-NOV-2000
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  veramach        3-NOV-2003      removed call to igf_aw_fund_tp_pkg.get_fk_igf_aw_fund_mast
  ||  vchappid        02-Apr-2002     Enh# 2293676, Added igs_fi_bill_pln_crd_pkg.get_fk_igf_aw_fund_mast
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igf_aw_award_pkg.get_fk_igf_aw_fund_mast (
      old_references.fund_id );

    igf_aw_fund_excl_pkg.get_fk_igf_aw_fund_mast (
      old_references.fund_id );

    igf_aw_fund_incl_pkg.get_fk_igf_aw_fund_mast (
      old_references.fund_id );


--
-- added fk checks for sponsor setups
--
   igf_sp_fc_pkg.get_fk_igf_aw_fund_mast(
      old_references.fund_id);

   igf_sp_stdnt_rel_pkg.get_fk_igf_aw_fund_mast(
      old_references.fund_id);

   igs_fi_bill_pln_crd_pkg.get_fk_igf_aw_fund_mast(
      old_references.fund_id);

   igf_aw_fund_feeclas_pkg.get_fk_igf_aw_fund_mast(
      old_references.fund_id);

   igf_aw_fund_unit_pkg.get_fk_igf_aw_fund_mast(
      old_references.fund_id);

   igf_aw_fund_prg_pkg.get_fk_igf_aw_fund_mast(
      old_references.fund_id);

   igf_aw_fund_td_map_pkg.get_fk_igf_aw_fund_mast(
      old_references.fund_id);

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_fund_id                           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 14-NOV-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
       FROM     igf_aw_fund_mast_all
      WHERE    fund_id = x_fund_id
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

  PROCEDURE get_ufk_igf_aw_fund_cat (
    x_fund_code                         IN     VARCHAR2,
    x_org_id                            IN     NUMBER
    ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 14-NOV-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
     l_org_id                igf_aw_fund_mast_all.org_id%TYPE  := igf_aw_gen.get_org_id;
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_fund_mast_all
      WHERE   fund_code = x_fund_code
        AND   NVL(org_id, NVL(l_org_id, -99)) = NVL(l_org_id, -99);

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_FMAST_FCAT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igf_aw_fund_cat;

  PROCEDURE get_fk_igs_ca_inst (
    x_ci_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 14-NOV-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_fund_mast_all
      WHERE   ((ci_cal_type = x_ci_cal_type) AND
               (ci_sequence_number = x_ci_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_CI_FMAST_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst;

  PROCEDURE get_fk_igs_fi_cr_types (
      x_credit_type_id                  IN     NUMBER
    ) AS
      /*
  ||  Created By : cdcruz
  ||  Created On : 14-NOV-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_fund_mast
      WHERE   ((credit_type_id = x_credit_type_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_FMAST_CT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

 END get_fk_igs_fi_cr_types ;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_fund_id                           IN     NUMBER  ,
    x_fund_code                         IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER  ,
    x_description                       IN     VARCHAR2,
    x_discontinue_fund                  IN     VARCHAR2,
    x_entitlement                       IN     VARCHAR2,
    x_auto_pkg                          IN     VARCHAR2,
    x_self_help                         IN     VARCHAR2,
    x_allow_man_pkg                     IN     VARCHAR2,
    x_update_need                       IN     VARCHAR2,
    x_disburse_fund                     IN     VARCHAR2,
    x_available_amt                     IN     NUMBER  ,
    x_offered_amt                       IN     NUMBER  ,
    x_pending_amt                       IN     NUMBER  ,
    x_accepted_amt                      IN     NUMBER  ,
    x_declined_amt                      IN     NUMBER  ,
    x_cancelled_amt                     IN     NUMBER  ,
    x_remaining_amt                     IN     NUMBER  ,
    x_enrollment_status                 IN     VARCHAR2,
    x_prn_award_letter                  IN     VARCHAR2,
    x_over_award_amt                    IN     NUMBER  ,
    x_over_award_perct                  IN     NUMBER  ,
    x_min_award_amt                     IN     NUMBER  ,
    x_max_award_amt                     IN     NUMBER  ,
    x_max_yearly_amt                    IN     NUMBER  ,
    x_max_life_amt                      IN     NUMBER  ,
    x_max_life_term                     IN     NUMBER  ,
    x_fm_fc_methd                       IN     VARCHAR2,
    x_roundoff_fact                     IN     VARCHAR2,
    x_replace_fc                        IN     VARCHAR2,
    x_allow_overaward                   IN     VARCHAR2,
    x_pckg_awd_stat                     IN     VARCHAR2,
    x_org_record_req                    IN     VARCHAR2,
    x_disb_record_req                   IN     VARCHAR2,
    x_prom_note_req                     IN     VARCHAR2,
    x_min_num_disb                      IN     NUMBER  ,
    x_max_num_disb                      IN     NUMBER  ,
    x_fee_type                          IN     VARCHAR2,
    x_total_offered                     IN     NUMBER  ,
    x_total_accepted                    IN     NUMBER  ,
    x_total_declined                    IN     NUMBER  ,
    x_total_revoked                     IN     NUMBER  ,
    x_total_cancelled                   IN     NUMBER  ,
    x_total_disbursed                   IN     NUMBER  ,
    x_total_committed                   IN     NUMBER  ,
    x_committed_amt                     IN     NUMBER  ,
    x_disbursed_amt                     IN     NUMBER  ,
    x_awd_notice_txt                    IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_disb_verf_da                      IN     VARCHAR2,
    x_fund_exp_da                       IN     VARCHAR2,
    x_nslds_disb_da                     IN     VARCHAR2,
    x_disb_exp_da                       IN     VARCHAR2,
    x_fund_recv_reqd                    IN     VARCHAR2,
    x_show_on_bill                      IN     VARCHAR2,
    x_bill_desc                         IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER  ,
    x_spnsr_ref_num                     IN     VARCHAR2,
    x_party_id                          IN     VARCHAR2,
    x_spnsr_fee_type                    IN     VARCHAR2,
    x_min_credit_points                 IN     NUMBER  ,
    x_group_id                          IN     NUMBER  ,
    x_spnsr_attribute_category          IN     VARCHAR2,
    x_spnsr_attribute1                  IN     VARCHAR2,
    x_spnsr_attribute2                  IN     VARCHAR2,
    x_spnsr_attribute3                  IN     VARCHAR2,
    x_spnsr_attribute4                  IN     VARCHAR2,
    x_spnsr_attribute5                  IN     VARCHAR2,
    x_spnsr_attribute6                  IN     VARCHAR2,
    x_spnsr_attribute7                  IN     VARCHAR2,
    x_spnsr_attribute8                  IN     VARCHAR2,
    x_spnsr_attribute9                  IN     VARCHAR2,
    x_spnsr_attribute10                 IN     VARCHAR2,
    x_spnsr_attribute11                 IN     VARCHAR2,
    x_spnsr_attribute12                 IN     VARCHAR2,
    x_spnsr_attribute13                 IN     VARCHAR2,
    x_spnsr_attribute14                 IN     VARCHAR2,
    x_spnsr_attribute15                 IN     VARCHAR2,
    x_spnsr_attribute16                 IN     VARCHAR2,
    x_spnsr_attribute17                 IN     VARCHAR2,
    x_spnsr_attribute18                 IN     VARCHAR2,
    x_spnsr_attribute19                 IN     VARCHAR2,
    x_spnsr_attribute20                 IN     VARCHAR2,
    x_threshold_perct                   IN     NUMBER  ,
    x_threshold_value                   IN     NUMBER  ,
    x_ver_app_stat_override             IN     VARCHAR2,
    x_gift_aid                          IN     VARCHAR2,
    x_send_without_doc                  IN     VARCHAR2,   -- Added as part of Bug # 2758812
    x_re_pkg_verif_flag                 IN     VARCHAR2,
    x_donot_repkg_if_code               IN     VARCHAR2,
    x_lock_award_flag                   IN     VARCHAR2,
    x_disb_rounding_code                IN     VARCHAR2  DEFAULT NULL,
    x_view_only_flag                    IN     VARCHAR2  DEFAULT NULL,
    x_accept_less_amt_flag              IN     VARCHAR2  DEFAULT NULL,
    x_allow_inc_post_accept_flag        IN     VARCHAR2  DEFAULT NULL,
    x_min_increase_amt                  IN     NUMBER    DEFAULT NULL,
    x_allow_dec_post_accept_flag        IN     VARCHAR2  DEFAULT NULL,
    x_min_decrease_amt                  IN     NUMBER    DEFAULT NULL,
    x_allow_decln_post_accept_flag      IN     VARCHAR2  DEFAULT NULL,
    x_status_after_decline              IN     VARCHAR2  DEFAULT NULL,
    x_fund_information_txt              IN     VARCHAR2  DEFAULT NULL

  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 01-JUN-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  museshad        14-Jul-2005     Build FA 140 - Changes relating to the
  ||                                  addition of new columns.
  ||  museshad        25-May-2005     Build# FA157 - Bug# 4382371.
  ||                                  New column 'DISB_ROUNDING_CODE' has been added
  ||                                  to the table 'IGF_AW_FUND_MAST_ALL'.
  ||                                  Modified the TBH to include this.
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_fund_id,
      x_fund_code,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_description,
      x_discontinue_fund,
      x_entitlement,
      x_auto_pkg,
      x_self_help,
      x_allow_man_pkg,
      x_update_need,
      x_disburse_fund,
      x_available_amt,
      x_offered_amt,
      x_pending_amt,
      x_accepted_amt,
      x_declined_amt,
      x_cancelled_amt,
      x_remaining_amt,
      x_enrollment_status,
      x_prn_award_letter,
      x_over_award_amt,
      x_over_award_perct,
      x_min_award_amt,
      x_max_award_amt,
      x_max_yearly_amt,
      x_max_life_amt,
      x_max_life_term,
      x_fm_fc_methd,
      x_roundoff_fact,
      x_replace_fc,
      x_allow_overaward,
      x_pckg_awd_stat,
      x_org_record_req,
      x_disb_record_req,
      x_prom_note_req,
      x_min_num_disb,
      x_max_num_disb,
      x_fee_type,
      x_total_offered,
      x_total_accepted,
      x_total_declined,
      x_total_revoked,
      x_total_cancelled,
      x_total_disbursed,
      x_total_committed,
      x_committed_amt,
      x_disbursed_amt,
      x_awd_notice_txt,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_disb_verf_da,
      x_fund_exp_da,
      x_nslds_disb_da,
      x_disb_exp_da,
      x_fund_recv_reqd,
      x_show_on_bill,
      x_bill_desc,
      x_credit_type_id,
      x_spnsr_ref_num,
      x_party_id,
      x_spnsr_fee_type,
      x_min_credit_points,
      x_group_id,
      x_spnsr_attribute_category,
      x_spnsr_attribute1,
      x_spnsr_attribute2,
      x_spnsr_attribute3,
      x_spnsr_attribute4,
      x_spnsr_attribute5,
      x_spnsr_attribute6,
      x_spnsr_attribute7,
      x_spnsr_attribute8,
      x_spnsr_attribute9,
      x_spnsr_attribute10,
      x_spnsr_attribute11,
      x_spnsr_attribute12,
      x_spnsr_attribute13,
      x_spnsr_attribute14,
      x_spnsr_attribute15,
      x_spnsr_attribute16,
      x_spnsr_attribute17,
      x_spnsr_attribute18,
      x_spnsr_attribute19,
      x_spnsr_attribute20,
      x_threshold_perct,
      x_threshold_value,
      x_ver_app_stat_override,
      x_gift_aid,
      x_send_without_doc,
      x_re_pkg_verif_flag,
      x_donot_repkg_if_code,
      x_lock_award_flag,
      x_disb_rounding_code,
      x_view_only_flag,
      x_accept_less_amt_flag,
      x_allow_inc_post_accept_flag,
      x_min_increase_amt,
      x_allow_dec_post_accept_flag,
      x_min_decrease_amt,
      x_allow_decln_post_accept_flag,
      x_status_after_decline,
      x_fund_information_txt
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.fund_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
      check_uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
      check_uniqueness;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.fund_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fund_id                           IN OUT NOCOPY NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_discontinue_fund                  IN     VARCHAR2,
    x_entitlement                       IN     VARCHAR2,
    x_auto_pkg                          IN     VARCHAR2,
    x_self_help                         IN     VARCHAR2,
    x_allow_man_pkg                     IN     VARCHAR2,
    x_update_need                       IN     VARCHAR2,
    x_disburse_fund                     IN     VARCHAR2,
    x_available_amt                     IN     NUMBER,
    x_offered_amt                       IN     NUMBER,
    x_pending_amt                       IN     NUMBER,
    x_accepted_amt                      IN     NUMBER,
    x_declined_amt                      IN     NUMBER,
    x_cancelled_amt                     IN     NUMBER,
    x_remaining_amt                     IN     NUMBER,
    x_enrollment_status                 IN     VARCHAR2,
    x_prn_award_letter                  IN     VARCHAR2,
    x_over_award_amt                    IN     NUMBER,
    x_over_award_perct                  IN     NUMBER,
    x_min_award_amt                     IN     NUMBER,
    x_max_award_amt                     IN     NUMBER,
    x_max_yearly_amt                    IN     NUMBER,
    x_max_life_amt                      IN     NUMBER,
    x_max_life_term                     IN     NUMBER,
    x_fm_fc_methd                       IN     VARCHAR2,
    x_roundoff_fact                     IN     VARCHAR2,
    x_replace_fc                        IN     VARCHAR2,
    x_allow_overaward                   IN     VARCHAR2,
    x_pckg_awd_stat                     IN     VARCHAR2,
    x_org_record_req                    IN     VARCHAR2,
    x_disb_record_req                   IN     VARCHAR2,
    x_prom_note_req                     IN     VARCHAR2,
    x_min_num_disb                      IN     NUMBER,
    x_max_num_disb                      IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_total_offered                     IN     NUMBER,
    x_total_accepted                    IN     NUMBER,
    x_total_declined                    IN     NUMBER,
    x_total_revoked                     IN     NUMBER,
    x_total_cancelled                   IN     NUMBER,
    x_total_disbursed                   IN     NUMBER,
    x_total_committed                   IN     NUMBER,
    x_committed_amt                     IN     NUMBER,
    x_disbursed_amt                     IN     NUMBER,
    x_awd_notice_txt                    IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_disb_verf_da                      IN     VARCHAR2,
    x_fund_exp_da                       IN     VARCHAR2,
    x_nslds_disb_da                     IN     VARCHAR2,
    x_disb_exp_da                       IN     VARCHAR2,
    x_fund_recv_reqd                    IN     VARCHAR2,
    x_show_on_bill                      IN     VARCHAR2,
    x_bill_desc                         IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER,
    x_spnsr_ref_num                     IN     VARCHAR2,
    x_party_id                          IN     VARCHAR2,
    x_spnsr_fee_type                    IN     VARCHAR2,
    x_min_credit_points                 IN     NUMBER,
    x_group_id                          IN     NUMBER,
    x_spnsr_attribute_category          IN     VARCHAR2,
    x_spnsr_attribute1                  IN     VARCHAR2,
    x_spnsr_attribute2                  IN     VARCHAR2,
    x_spnsr_attribute3                  IN     VARCHAR2,
    x_spnsr_attribute4                  IN     VARCHAR2,
    x_spnsr_attribute5                  IN     VARCHAR2,
    x_spnsr_attribute6                  IN     VARCHAR2,
    x_spnsr_attribute7                  IN     VARCHAR2,
    x_spnsr_attribute8                  IN     VARCHAR2,
    x_spnsr_attribute9                  IN     VARCHAR2,
    x_spnsr_attribute10                 IN     VARCHAR2,
    x_spnsr_attribute11                 IN     VARCHAR2,
    x_spnsr_attribute12                 IN     VARCHAR2,
    x_spnsr_attribute13                 IN     VARCHAR2,
    x_spnsr_attribute14                 IN     VARCHAR2,
    x_spnsr_attribute15                 IN     VARCHAR2,
    x_spnsr_attribute16                 IN     VARCHAR2,
    x_spnsr_attribute17                 IN     VARCHAR2,
    x_spnsr_attribute18                 IN     VARCHAR2,
    x_spnsr_attribute19                 IN     VARCHAR2,
    x_spnsr_attribute20                 IN     VARCHAR2,
    x_threshold_perct                   IN     NUMBER,
    x_threshold_value                   IN     NUMBER,
    x_ver_app_stat_override             IN     VARCHAR2,
    x_gift_aid                          IN     VARCHAR2,
    x_send_without_doc                  IN     VARCHAR2,   -- Added as part of Bug # 2758812
    x_mode                              IN     VARCHAR2,
    x_re_pkg_verif_flag                 IN     VARCHAR2,
    x_donot_repkg_if_code               IN     VARCHAR2,
    x_lock_award_flag                   IN     VARCHAR2,
    x_disb_rounding_code                IN     VARCHAR2  DEFAULT NULL,
    x_view_only_flag                    IN     VARCHAR2  DEFAULT NULL,
    x_accept_less_amt_flag              IN     VARCHAR2  DEFAULT NULL,
    x_allow_inc_post_accept_flag        IN     VARCHAR2  DEFAULT NULL,
    x_min_increase_amt                  IN     NUMBER    DEFAULT NULL,
    x_allow_dec_post_accept_flag        IN     VARCHAR2  DEFAULT NULL,
    x_min_decrease_amt                  IN     NUMBER    DEFAULT NULL,
    x_allow_decln_post_accept_flag      IN     VARCHAR2  DEFAULT NULL,
    x_status_after_decline              IN     VARCHAR2  DEFAULT NULL,
    x_fund_information_txt              IN     VARCHAR2  DEFAULT NULL
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 14-NOV-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  museshad        14-Jul-2005     FA 140 - Changes relating to the addition of new columns
  ||  museshad        25-May-2005     Build# FA157 - Bug# 4382371.
  ||                                  New column 'DISB_ROUNDING_CODE' has been added
  ||                                  to the table 'IGF_AW_FUND_MAST_ALL'.
  ||                                  Modified the TBH to include this.
  ||  veramach        1-NOV-2003      FA 125 - Removed elig_criteria from assigments,insert statements
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_aw_fund_mast_all
      WHERE    fund_id                           = x_fund_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_org_id                igf_aw_fund_mast_all.org_id%TYPE  DEFAULT igf_aw_gen.get_org_id;

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

     select IGF_AW_FUND_MAST_S.NEXTVAL into x_fund_id from dual ;


   before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_fund_id                           => x_fund_id,
      x_fund_code                         => x_fund_code,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_description                       => x_description,
      x_discontinue_fund                  => x_discontinue_fund,
      x_entitlement                       => x_entitlement,
      x_auto_pkg                          => x_auto_pkg,
      x_self_help                         => x_self_help,
      x_allow_man_pkg                     => x_allow_man_pkg,
      x_update_need                       => x_update_need,
      x_disburse_fund                     => x_disburse_fund,
      x_available_amt                     => x_available_amt,
      x_offered_amt                       => x_offered_amt,
      x_pending_amt                       => x_pending_amt,
      x_accepted_amt                      => x_accepted_amt,
      x_declined_amt                      => x_declined_amt,
      x_cancelled_amt                     => x_cancelled_amt,
      x_remaining_amt                     => x_remaining_amt,
      x_enrollment_status                 => x_enrollment_status,
      x_prn_award_letter                  => x_prn_award_letter,
      x_over_award_amt                    => x_over_award_amt,
      x_over_award_perct                  => x_over_award_perct,
      x_min_award_amt                     => x_min_award_amt,
      x_max_award_amt                     => x_max_award_amt,
      x_max_yearly_amt                    => x_max_yearly_amt,
      x_max_life_amt                      => x_max_life_amt,
      x_max_life_term                     => x_max_life_term,
      x_fm_fc_methd                       => x_fm_fc_methd,
      x_roundoff_fact                     => x_roundoff_fact,
      x_replace_fc                        => x_replace_fc,
      x_allow_overaward                   => x_allow_overaward,
      x_pckg_awd_stat                     => x_pckg_awd_stat,
      x_org_record_req                    => x_org_record_req,
      x_disb_record_req                   => x_disb_record_req,
      x_prom_note_req                     => x_prom_note_req,
      x_min_num_disb                      => x_min_num_disb,
      x_max_num_disb                      => x_max_num_disb,
      x_fee_type                          => x_fee_type,
      x_total_offered                     => x_total_offered,
      x_total_accepted                    => x_total_accepted,
      x_total_declined                    => x_total_declined,
      x_total_revoked                     => x_total_revoked,
      x_total_cancelled                   => x_total_cancelled,
      x_total_disbursed                   => x_total_disbursed,
      x_total_committed                   => x_total_committed,
      x_committed_amt                     => x_committed_amt,
      x_disbursed_amt                     => x_disbursed_amt,
      x_awd_notice_txt                    => x_awd_notice_txt,
      x_attribute_category                => x_attribute_category,
      x_attribute1                        => x_attribute1,
      x_attribute2                        => x_attribute2,
      x_attribute3                        => x_attribute3,
      x_attribute4                        => x_attribute4,
      x_attribute5                        => x_attribute5,
      x_attribute6                        => x_attribute6,
      x_attribute7                        => x_attribute7,
      x_attribute8                        => x_attribute8,
      x_attribute9                        => x_attribute9,
      x_attribute10                       => x_attribute10,
      x_attribute11                       => x_attribute11,
      x_attribute12                       => x_attribute12,
      x_attribute13                       => x_attribute13,
      x_attribute14                       => x_attribute14,
      x_attribute15                       => x_attribute15,
      x_attribute16                       => x_attribute16,
      x_attribute17                       => x_attribute17,
      x_attribute18                       => x_attribute18,
      x_attribute19                       => x_attribute19,
      x_attribute20                       => x_attribute20,
      x_disb_verf_da                      => x_disb_verf_da,
      x_fund_exp_da                       => x_fund_exp_da,
      x_nslds_disb_da                     => x_nslds_disb_da,
      x_disb_exp_da                       => x_disb_exp_da,
      x_fund_recv_reqd                    => x_fund_recv_reqd,
      x_show_on_bill                      => x_show_on_bill,
      x_bill_desc                         => x_bill_desc,
      x_credit_type_id                    => x_credit_type_id,
      x_spnsr_ref_num                     => x_spnsr_ref_num,
      x_party_id                          => x_party_id,
      x_spnsr_fee_type                    => x_spnsr_fee_type,
      x_min_credit_points                 => x_min_credit_points,
      x_group_id                          => x_group_id,
      x_spnsr_attribute_category          => x_spnsr_attribute_category,
      x_spnsr_attribute1                  => x_spnsr_attribute1,
      x_spnsr_attribute2                  => x_spnsr_attribute2,
      x_spnsr_attribute3                  => x_spnsr_attribute3,
      x_spnsr_attribute4                  => x_spnsr_attribute4,
      x_spnsr_attribute5                  => x_spnsr_attribute5,
      x_spnsr_attribute6                  => x_spnsr_attribute6,
      x_spnsr_attribute7                  => x_spnsr_attribute7,
      x_spnsr_attribute8                  => x_spnsr_attribute8,
      x_spnsr_attribute9                  => x_spnsr_attribute9,
      x_spnsr_attribute10                 => x_spnsr_attribute10,
      x_spnsr_attribute11                 => x_spnsr_attribute11,
      x_spnsr_attribute12                 => x_spnsr_attribute12,
      x_spnsr_attribute13                 => x_spnsr_attribute13,
      x_spnsr_attribute14                 => x_spnsr_attribute14,
      x_spnsr_attribute15                 => x_spnsr_attribute15,
      x_spnsr_attribute16                 => x_spnsr_attribute16,
      x_spnsr_attribute17                 => x_spnsr_attribute17,
      x_spnsr_attribute18                 => x_spnsr_attribute18,
      x_spnsr_attribute19                 => x_spnsr_attribute19,
      x_spnsr_attribute20                 => x_spnsr_attribute20,
      x_threshold_perct                   => x_threshold_perct ,
      x_threshold_value                   => x_threshold_value,
      x_ver_app_stat_override             => x_ver_app_stat_override,
      x_gift_aid                          => x_gift_aid ,
      x_send_without_doc                  => x_send_without_doc,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_re_pkg_verif_flag                 => x_re_pkg_verif_flag,
      x_donot_repkg_if_code               => x_donot_repkg_if_code,
      x_lock_award_flag                   => x_lock_award_flag,
      x_disb_rounding_code                => x_disb_rounding_code,
      x_view_only_flag                    => x_view_only_flag,
      x_accept_less_amt_flag              => x_accept_less_amt_flag,
      x_allow_inc_post_accept_flag        => x_allow_inc_post_accept_flag,
      x_min_increase_amt                  => x_min_increase_amt,
      x_allow_dec_post_accept_flag        => x_allow_dec_post_accept_flag,
      x_min_decrease_amt                  => x_min_decrease_amt,
      x_allow_decln_post_accept_flag      => x_allow_decln_post_accept_flag,
      x_status_after_decline              => x_status_after_decline,
      x_fund_information_txt              => x_fund_information_txt
    );

     INSERT INTO igf_aw_fund_mast_all (
      fund_id,
      fund_code,
      ci_cal_type,
      ci_sequence_number,
      description,
      discontinue_fund,
      entitlement,
      auto_pkg,
      self_help,
      allow_man_pkg,
      update_need,
      disburse_fund,
      available_amt,
      offered_amt,
      pending_amt,
      accepted_amt,
      declined_amt,
      cancelled_amt,
      remaining_amt,
      enrollment_status,
      prn_award_letter,
      over_award_amt,
      over_award_perct,
      min_award_amt,
      max_award_amt,
      max_yearly_amt,
      max_life_amt,
      max_life_term,
      fm_fc_methd,
      roundoff_fact,
      replace_fc,
      allow_overaward,
      pckg_awd_stat,
      org_record_req,
      disb_record_req,
      prom_note_req,
      min_num_disb,
      max_num_disb,
      fee_type,
      total_offered,
      total_accepted,
      total_declined,
      total_revoked,
      total_cancelled,
      total_disbursed,
      total_committed,
      committed_amt,
      disbursed_amt,
      awd_notice_txt,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      disb_verf_da,
      fund_exp_da,
      nslds_disb_da,
      disb_exp_da,
      fund_recv_reqd,
      show_on_bill,
      bill_desc,
      credit_type_id,
      spnsr_ref_num,
      party_id,
      spnsr_fee_type,
      min_credit_points,
      group_id,
      spnsr_attribute_category,
      spnsr_attribute1 ,
      spnsr_attribute2 ,
      spnsr_attribute3 ,
      spnsr_attribute4 ,
      spnsr_attribute5 ,
      spnsr_attribute6 ,
      spnsr_attribute7 ,
      spnsr_attribute8 ,
      spnsr_attribute9 ,
      spnsr_attribute10 ,
      spnsr_attribute11 ,
      spnsr_attribute12 ,
      spnsr_attribute13 ,
      spnsr_attribute14 ,
      spnsr_attribute15 ,
      spnsr_attribute16 ,
      spnsr_attribute17 ,
      spnsr_attribute18 ,
      spnsr_attribute19 ,
      spnsr_attribute20 ,
      threshold_perct,
      threshold_value,
      ver_app_stat_override,
      gift_aid,
      send_without_doc,
      re_pkg_verif_flag,
      donot_repkg_if_code,
      lock_award_flag,
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
      disb_rounding_code,
      view_only_flag,
      accept_less_amt_flag,
      allow_inc_post_accept_flag,
      min_increase_amt,
      allow_dec_post_accept_flag,
      min_decrease_amt,
      allow_decln_post_accept_flag,
      status_after_decline,
      fund_information_txt
    ) VALUES (
      new_references.fund_id,
      new_references.fund_code,
      new_references.ci_cal_type,
      new_references.ci_sequence_number,
      new_references.description,
      new_references.discontinue_fund,
      new_references.entitlement,
      new_references.auto_pkg,
      new_references.self_help,
      new_references.allow_man_pkg,
      new_references.update_need,
      new_references.disburse_fund,
      new_references.available_amt,
      new_references.offered_amt,
      new_references.pending_amt,
      new_references.accepted_amt,
      new_references.declined_amt,
      new_references.cancelled_amt,
      new_references.remaining_amt,
      new_references.enrollment_status,
      new_references.prn_award_letter,
      new_references.over_award_amt,
      new_references.over_award_perct,
      new_references.min_award_amt,
      new_references.max_award_amt,
      new_references.max_yearly_amt,
      new_references.max_life_amt,
      new_references.max_life_term,
      new_references.fm_fc_methd,
      new_references.roundoff_fact,
      new_references.replace_fc,
      new_references.allow_overaward,
      new_references.pckg_awd_stat,
      new_references.org_record_req,
      new_references.disb_record_req,
      new_references.prom_note_req,
      new_references.min_num_disb,
      new_references.max_num_disb,
      new_references.fee_type,
      new_references.total_offered,
      new_references.total_accepted,
      new_references.total_declined,
      new_references.total_revoked,
      new_references.total_cancelled,
      new_references.total_disbursed,
      new_references.total_committed,
      new_references.committed_amt,
      new_references.disbursed_amt,
      new_references.awd_notice_txt,
      new_references.attribute_category,
      new_references.attribute1,
      new_references.attribute2,
      new_references.attribute3,
      new_references.attribute4,
      new_references.attribute5,
      new_references.attribute6,
      new_references.attribute7,
      new_references.attribute8,
      new_references.attribute9,
      new_references.attribute10,
      new_references.attribute11,
      new_references.attribute12,
      new_references.attribute13,
      new_references.attribute14,
      new_references.attribute15,
      new_references.attribute16,
      new_references.attribute17,
      new_references.attribute18,
      new_references.attribute19,
      new_references.attribute20,
      new_references.disb_verf_da,
      new_references.fund_exp_da,
      new_references.nslds_disb_da,
      new_references.disb_exp_da,
      new_references.fund_recv_reqd,
      new_references.show_on_bill,
      new_references.bill_desc,
      new_references.credit_type_id,

      new_references.spnsr_ref_num,
      new_references.party_id,
      new_references.spnsr_fee_type,
      new_references.min_credit_points,
      new_references.group_id,
      new_references.spnsr_attribute_category,
      new_references.spnsr_attribute1,
      new_references.spnsr_attribute2,
      new_references.spnsr_attribute3,
      new_references.spnsr_attribute4,
      new_references.spnsr_attribute5,
      new_references.spnsr_attribute6,
      new_references.spnsr_attribute7,
      new_references.spnsr_attribute8,
      new_references.spnsr_attribute9,
      new_references.spnsr_attribute10,
      new_references.spnsr_attribute11,
      new_references.spnsr_attribute12,
      new_references.spnsr_attribute13,
      new_references.spnsr_attribute14,
      new_references.spnsr_attribute15,
      new_references.spnsr_attribute16,
      new_references.spnsr_attribute17,
      new_references.spnsr_attribute18,
      new_references.spnsr_attribute19,
      new_references.spnsr_attribute20,
      new_references.threshold_perct,
      new_references.threshold_value,
      new_references.ver_app_stat_override,
      new_references.gift_aid,
      new_references.send_without_doc,
      new_references.re_pkg_verif_flag,
      new_references.donot_repkg_if_code,
      new_references.lock_award_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date ,
      l_org_id,
      new_references.disb_rounding_code,
      new_references.view_only_flag,
      new_references.accept_less_amt_flag,
      new_references.allow_inc_post_accept_flag,
      new_references.min_increase_amt,
      new_references.allow_dec_post_accept_flag,
      new_references.min_decrease_amt,
      new_references.allow_decln_post_accept_flag,
      new_references.status_after_decline,
      new_references.fund_information_txt
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
    x_fund_id                           IN     NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_discontinue_fund                  IN     VARCHAR2,
    x_entitlement                       IN     VARCHAR2,
    x_auto_pkg                          IN     VARCHAR2,
    x_self_help                         IN     VARCHAR2,
    x_allow_man_pkg                     IN     VARCHAR2,
    x_update_need                       IN     VARCHAR2,
    x_disburse_fund                     IN     VARCHAR2,
    x_available_amt                     IN     NUMBER,
    x_offered_amt                       IN     NUMBER,
    x_pending_amt                       IN     NUMBER,
    x_accepted_amt                      IN     NUMBER,
    x_declined_amt                      IN     NUMBER,
    x_cancelled_amt                     IN     NUMBER,
    x_remaining_amt                     IN     NUMBER,
    x_enrollment_status                 IN     VARCHAR2,
    x_prn_award_letter                  IN     VARCHAR2,
    x_over_award_amt                    IN     NUMBER,
    x_over_award_perct                  IN     NUMBER,
    x_min_award_amt                     IN     NUMBER,
    x_max_award_amt                     IN     NUMBER,
    x_max_yearly_amt                    IN     NUMBER,
    x_max_life_amt                      IN     NUMBER,
    x_max_life_term                     IN     NUMBER,
    x_fm_fc_methd                       IN     VARCHAR2,
    x_roundoff_fact                     IN     VARCHAR2,
    x_replace_fc                        IN     VARCHAR2,
    x_allow_overaward                   IN     VARCHAR2,
    x_pckg_awd_stat                     IN     VARCHAR2,
    x_org_record_req                    IN     VARCHAR2,
    x_disb_record_req                   IN     VARCHAR2,
    x_prom_note_req                     IN     VARCHAR2,
    x_min_num_disb                      IN     NUMBER,
    x_max_num_disb                      IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_total_offered                     IN     NUMBER,
    x_total_accepted                    IN     NUMBER,
    x_total_declined                    IN     NUMBER,
    x_total_revoked                     IN     NUMBER,
    x_total_cancelled                   IN     NUMBER,
    x_total_disbursed                   IN     NUMBER,
    x_total_committed                   IN     NUMBER,
    x_committed_amt                     IN     NUMBER,
    x_disbursed_amt                     IN     NUMBER,
    x_awd_notice_txt                    IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_disb_verf_da                      IN     VARCHAR2,
    x_fund_exp_da                       IN     VARCHAR2,
    x_nslds_disb_da                     IN     VARCHAR2,
    x_disb_exp_da                       IN     VARCHAR2,
    x_fund_recv_reqd                    IN     VARCHAR2,
    x_show_on_bill                      IN     VARCHAR2,
    x_bill_desc                         IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER  ,
    x_spnsr_ref_num                     IN     VARCHAR2,
    x_party_id                          IN     VARCHAR2,
    x_spnsr_fee_type                    IN     VARCHAR2,
    x_min_credit_points                 IN     NUMBER  ,
    x_group_id                          IN     NUMBER  ,
    x_spnsr_attribute_category          IN     VARCHAR2,
    x_spnsr_attribute1                  IN     VARCHAR2,
    x_spnsr_attribute2                  IN     VARCHAR2,
    x_spnsr_attribute3                  IN     VARCHAR2,
    x_spnsr_attribute4                  IN     VARCHAR2,
    x_spnsr_attribute5                  IN     VARCHAR2,
    x_spnsr_attribute6                  IN     VARCHAR2,
    x_spnsr_attribute7                  IN     VARCHAR2,
    x_spnsr_attribute8                  IN     VARCHAR2,
    x_spnsr_attribute9                  IN     VARCHAR2,
    x_spnsr_attribute10                 IN     VARCHAR2,
    x_spnsr_attribute11                 IN     VARCHAR2,
    x_spnsr_attribute12                 IN     VARCHAR2,
    x_spnsr_attribute13                 IN     VARCHAR2,
    x_spnsr_attribute14                 IN     VARCHAR2,
    x_spnsr_attribute15                 IN     VARCHAR2,
    x_spnsr_attribute16                 IN     VARCHAR2,
    x_spnsr_attribute17                 IN     VARCHAR2,
    x_spnsr_attribute18                 IN     VARCHAR2,
    x_spnsr_attribute19                 IN     VARCHAR2,
    x_spnsr_attribute20                 IN     VARCHAR2,
    x_threshold_perct                   IN     NUMBER,
    x_threshold_value                   IN     NUMBER,
    x_ver_app_stat_override             IN     VARCHAR2,
    x_gift_aid                          IN     VARCHAR2,
    x_send_without_doc                  IN     VARCHAR2,   -- Added as part of Bug # 2758812
    x_re_pkg_verif_flag                 IN     VARCHAR2,
    x_donot_repkg_if_code               IN     VARCHAR2,
    x_lock_award_flag                   IN     VARCHAR2,
    x_disb_rounding_code                IN     VARCHAR2  DEFAULT NULL,
    x_view_only_flag                    IN     VARCHAR2  DEFAULT NULL,
    x_accept_less_amt_flag              IN     VARCHAR2  DEFAULT NULL,
    x_allow_inc_post_accept_flag        IN     VARCHAR2  DEFAULT NULL,
    x_min_increase_amt                  IN     NUMBER    DEFAULT NULL,
    x_allow_dec_post_accept_flag        IN     VARCHAR2  DEFAULT NULL,
    x_min_decrease_amt                  IN     NUMBER    DEFAULT NULL,
    x_allow_decln_post_accept_flag      IN     VARCHAR2  DEFAULT NULL,
    x_status_after_decline              IN     VARCHAR2  DEFAULT NULL,
    x_fund_information_txt              IN     VARCHAR2  DEFAULT NULL

  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 14-NOV-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  museshad        14-Jul-2005     Build FA 140 - Changes relating to the addition
  ||                                  of new columns
  ||  museshad        25-May-2005     Build# FA157 - Bug# 4382371.
  ||                                  New column 'DISB_ROUNDING_CODE' has been added
  ||                                  to the table 'IGF_AW_FUND_MAST_ALL'.
  ||                                  Modified the TBH to include this.
  ||  veramach        1-NOV-2003      FA 125 - Removed elig_criteria from assigments,select statements
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        fund_code,
        ci_cal_type,
        ci_sequence_number,
        description,
        discontinue_fund,
        entitlement,
        auto_pkg,
        self_help,
        allow_man_pkg,
        update_need,
        disburse_fund,
        available_amt,
        offered_amt,
        pending_amt,
        accepted_amt,
        declined_amt,
        cancelled_amt,
        remaining_amt,
        enrollment_status,
        prn_award_letter,
        over_award_amt,
        over_award_perct,
        min_award_amt,
        max_award_amt,
        max_yearly_amt,
        max_life_amt,
        max_life_term,
        fm_fc_methd,
        roundoff_fact,
        replace_fc,
        allow_overaward,
        pckg_awd_stat,
        org_record_req,
        disb_record_req,
        prom_note_req,
        min_num_disb,
        max_num_disb,
        fee_type,
        total_offered,
        total_accepted,
        total_declined,
        total_revoked,
        total_cancelled,
        total_disbursed,
        total_committed,
        committed_amt,
        disbursed_amt,
        awd_notice_txt,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute16,
        attribute17,
        attribute18,
        attribute19,
        attribute20,
        disb_verf_da,
        fund_exp_da,
        nslds_disb_da,
        disb_exp_da,
        fund_recv_reqd,
        show_on_bill,
        bill_desc,
        credit_type_id,
        spnsr_ref_num,
        party_id,
        spnsr_fee_type,
        min_credit_points,
        group_id,
        spnsr_attribute_category,
        spnsr_attribute1 ,
        spnsr_attribute2 ,
        spnsr_attribute3 ,
        spnsr_attribute4 ,
        spnsr_attribute5 ,
        spnsr_attribute6 ,
        spnsr_attribute7 ,
        spnsr_attribute8 ,
        spnsr_attribute9 ,
        spnsr_attribute10 ,
        spnsr_attribute11 ,
        spnsr_attribute12 ,
        spnsr_attribute13 ,
        spnsr_attribute14 ,
        spnsr_attribute15 ,
        spnsr_attribute16 ,
        spnsr_attribute17 ,
        spnsr_attribute18 ,
        spnsr_attribute19 ,
        spnsr_attribute20 ,
        threshold_perct,
        threshold_value,
        ver_app_stat_override ,
        gift_aid,
        send_without_doc,
        re_pkg_verif_flag,
        donot_repkg_if_code,
        lock_award_flag,
        disb_rounding_code,
        view_only_flag,
        accept_less_amt_flag,
        allow_inc_post_accept_flag,
        min_increase_amt,
        allow_dec_post_accept_flag,
        min_decrease_amt,
        allow_decln_post_accept_flag,
        status_after_decline,
        fund_information_txt
      FROM  igf_aw_fund_mast_all
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
        (tlinfo.fund_code = x_fund_code)
        AND (tlinfo.ci_cal_type = x_ci_cal_type)
        AND (tlinfo.ci_sequence_number = x_ci_sequence_number)
        AND ((tlinfo.description = x_description) OR ((tlinfo.description IS NULL) AND (X_description IS NULL)))
        AND (tlinfo.discontinue_fund = x_discontinue_fund)
        AND ((tlinfo.entitlement = x_entitlement) OR ((tlinfo.entitlement IS NULL) AND (X_entitlement IS NULL)))
        AND (tlinfo.auto_pkg = x_auto_pkg)
        AND ((tlinfo.self_help = x_self_help) OR ((tlinfo.self_help IS NULL) AND (X_self_help IS NULL)))
        AND (tlinfo.allow_man_pkg = x_allow_man_pkg)
        AND (tlinfo.update_need = x_update_need)
        AND (tlinfo.disburse_fund = x_disburse_fund)
        AND ((tlinfo.available_amt = x_available_amt) OR ((tlinfo.available_amt IS NULL) AND (X_available_amt IS NULL)))
        AND ((tlinfo.offered_amt = x_offered_amt) OR ((tlinfo.offered_amt IS NULL) AND (X_offered_amt IS NULL)))
        AND ((tlinfo.pending_amt = x_pending_amt) OR ((tlinfo.pending_amt IS NULL) AND (X_pending_amt IS NULL)))
        AND ((tlinfo.accepted_amt = x_accepted_amt) OR ((tlinfo.accepted_amt IS NULL) AND (X_accepted_amt IS NULL)))
        AND ((tlinfo.declined_amt = x_declined_amt) OR ((tlinfo.declined_amt IS NULL) AND (X_declined_amt IS NULL)))
        AND ((tlinfo.cancelled_amt = x_cancelled_amt) OR ((tlinfo.cancelled_amt IS NULL) AND (X_cancelled_amt IS NULL)))
        AND ((tlinfo.remaining_amt = x_remaining_amt) OR ((tlinfo.remaining_amt IS NULL) AND (X_remaining_amt IS NULL)))
        AND ((tlinfo.enrollment_status = x_enrollment_status) OR ((tlinfo.enrollment_status IS NULL) AND (X_enrollment_status IS NULL)))
        AND ((tlinfo.prn_award_letter = x_prn_award_letter) OR ((tlinfo.prn_award_letter IS NULL) AND (X_prn_award_letter IS NULL)))
        AND ((tlinfo.over_award_amt = x_over_award_amt) OR ((tlinfo.over_award_amt IS NULL) AND (X_over_award_amt IS NULL)))
        AND ((tlinfo.over_award_perct = x_over_award_perct) OR ((tlinfo.over_award_perct IS NULL) AND (X_over_award_perct IS NULL)))
        AND ((tlinfo.min_award_amt = x_min_award_amt) OR ((tlinfo.min_award_amt IS NULL) AND (X_min_award_amt IS NULL)))
        AND ((tlinfo.max_award_amt = x_max_award_amt) OR ((tlinfo.max_award_amt IS NULL) AND (X_max_award_amt IS NULL)))
        AND ((tlinfo.max_yearly_amt = x_max_yearly_amt) OR ((tlinfo.max_yearly_amt IS NULL) AND (X_max_yearly_amt IS NULL)))
        AND ((tlinfo.max_life_amt = x_max_life_amt) OR ((tlinfo.max_life_amt IS NULL) AND (X_max_life_amt IS NULL)))
        AND ((tlinfo.max_life_term = x_max_life_term) OR ((tlinfo.max_life_term IS NULL) AND (X_max_life_term IS NULL)))
        AND ((tlinfo.roundoff_fact = x_roundoff_fact) OR ((tlinfo.roundoff_fact IS NULL) AND (X_roundoff_fact IS NULL)))
        AND ((tlinfo.replace_fc = x_replace_fc) OR ((tlinfo.replace_fc IS NULL) AND (X_replace_fc IS NULL)))
        AND ((tlinfo.allow_overaward = x_allow_overaward) OR ((tlinfo.allow_overaward IS NULL) AND (X_allow_overaward IS NULL)))
        AND ((tlinfo.pckg_awd_stat = x_pckg_awd_stat) OR ((tlinfo.pckg_awd_stat IS NULL) AND (X_pckg_awd_stat IS NULL)))
        AND ((tlinfo.org_record_req = x_org_record_req) OR ((tlinfo.org_record_req IS NULL) AND (X_org_record_req IS NULL)))
        AND ((tlinfo.disb_record_req = x_disb_record_req) OR ((tlinfo.disb_record_req IS NULL) AND (X_disb_record_req IS NULL)))
        AND ((tlinfo.prom_note_req = x_prom_note_req) OR ((tlinfo.prom_note_req IS NULL) AND (X_prom_note_req IS NULL)))
        AND ((tlinfo.min_num_disb = x_min_num_disb) OR ((tlinfo.min_num_disb IS NULL) AND (X_min_num_disb IS NULL)))
        AND ((tlinfo.max_num_disb = x_max_num_disb) OR ((tlinfo.max_num_disb IS NULL) AND (X_max_num_disb IS NULL)))
        AND ((tlinfo.fee_type = x_fee_type) OR ((tlinfo.fee_type IS NULL) AND (X_fee_type IS NULL)))
        AND ((tlinfo.total_offered = x_total_offered) OR ((tlinfo.total_offered IS NULL) AND (X_total_offered IS NULL)))
        AND ((tlinfo.total_accepted = x_total_accepted) OR ((tlinfo.total_accepted IS NULL) AND (X_total_accepted IS NULL)))
        AND ((tlinfo.total_declined = x_total_declined) OR ((tlinfo.total_declined IS NULL) AND (X_total_declined IS NULL)))
        AND ((tlinfo.total_revoked = x_total_revoked) OR ((tlinfo.total_revoked IS NULL) AND (X_total_revoked IS NULL)))
        AND ((tlinfo.total_cancelled = x_total_cancelled) OR ((tlinfo.total_cancelled IS NULL) AND (X_total_cancelled IS NULL)))
        AND ((tlinfo.total_disbursed = x_total_disbursed) OR ((tlinfo.total_disbursed IS NULL) AND (X_total_disbursed IS NULL)))
        AND ((tlinfo.total_committed = x_total_committed) OR ((tlinfo.total_committed IS NULL) AND (X_total_committed IS NULL)))
        AND ((tlinfo.committed_amt = x_committed_amt) OR ((tlinfo.committed_amt IS NULL) AND (X_committed_amt IS NULL)))
        AND ((tlinfo.disbursed_amt = x_disbursed_amt) OR ((tlinfo.disbursed_amt IS NULL) AND (X_disbursed_amt IS NULL)))
        AND ((tlinfo.awd_notice_txt = x_awd_notice_txt) OR ((tlinfo.awd_notice_txt IS NULL) AND (X_awd_notice_txt IS NULL)))
        AND ((tlinfo.attribute_category = x_attribute_category) OR ((tlinfo.attribute_category IS NULL) AND (X_attribute_category IS NULL)))
        AND ((tlinfo.attribute1 = x_attribute1) OR ((tlinfo.attribute1 IS NULL) AND (X_attribute1 IS NULL)))
        AND ((tlinfo.attribute2 = x_attribute2) OR ((tlinfo.attribute2 IS NULL) AND (X_attribute2 IS NULL)))
        AND ((tlinfo.attribute3 = x_attribute3) OR ((tlinfo.attribute3 IS NULL) AND (X_attribute3 IS NULL)))
        AND ((tlinfo.attribute4 = x_attribute4) OR ((tlinfo.attribute4 IS NULL) AND (X_attribute4 IS NULL)))
        AND ((tlinfo.attribute5 = x_attribute5) OR ((tlinfo.attribute5 IS NULL) AND (X_attribute5 IS NULL)))
        AND ((tlinfo.attribute6 = x_attribute6) OR ((tlinfo.attribute6 IS NULL) AND (X_attribute6 IS NULL)))
        AND ((tlinfo.attribute7 = x_attribute7) OR ((tlinfo.attribute7 IS NULL) AND (X_attribute7 IS NULL)))
        AND ((tlinfo.attribute8 = x_attribute8) OR ((tlinfo.attribute8 IS NULL) AND (X_attribute8 IS NULL)))
        AND ((tlinfo.attribute9 = x_attribute9) OR ((tlinfo.attribute9 IS NULL) AND (X_attribute9 IS NULL)))
        AND ((tlinfo.attribute10 = x_attribute10) OR ((tlinfo.attribute10 IS NULL) AND (X_attribute10 IS NULL)))
        AND ((tlinfo.attribute11 = x_attribute11) OR ((tlinfo.attribute11 IS NULL) AND (X_attribute11 IS NULL)))
        AND ((tlinfo.attribute12 = x_attribute12) OR ((tlinfo.attribute12 IS NULL) AND (X_attribute12 IS NULL)))
        AND ((tlinfo.attribute13 = x_attribute13) OR ((tlinfo.attribute13 IS NULL) AND (X_attribute13 IS NULL)))
        AND ((tlinfo.attribute14 = x_attribute14) OR ((tlinfo.attribute14 IS NULL) AND (X_attribute14 IS NULL)))
        AND ((tlinfo.attribute15 = x_attribute15) OR ((tlinfo.attribute15 IS NULL) AND (X_attribute15 IS NULL)))
        AND ((tlinfo.attribute16 = x_attribute16) OR ((tlinfo.attribute16 IS NULL) AND (X_attribute16 IS NULL)))
        AND ((tlinfo.attribute17 = x_attribute17) OR ((tlinfo.attribute17 IS NULL) AND (X_attribute17 IS NULL)))
        AND ((tlinfo.attribute18 = x_attribute18) OR ((tlinfo.attribute18 IS NULL) AND (X_attribute18 IS NULL)))
        AND ((tlinfo.attribute19 = x_attribute19) OR ((tlinfo.attribute19 IS NULL) AND (X_attribute19 IS NULL)))
        AND ((tlinfo.attribute20 = x_attribute20) OR ((tlinfo.attribute20 IS NULL) AND (X_attribute20 IS NULL)))
        AND ((tlinfo.disb_verf_da   = x_disb_verf_da) OR ((tlinfo.disb_verf_da IS NULL) AND (x_disb_verf_da IS NULL)))
        AND ((tlinfo.fund_exp_da   = x_fund_exp_da) OR ((tlinfo.fund_exp_da IS NULL) AND (x_fund_exp_da IS NULL)))
        AND ((tlinfo.nslds_disb_da   = x_nslds_disb_da) OR ((tlinfo.nslds_disb_da IS NULL) AND (x_nslds_disb_da IS NULL)))
        AND ((tlinfo.disb_exp_da   = x_disb_exp_da) OR ((tlinfo.disb_exp_da IS NULL) AND (x_disb_exp_da IS NULL)))
        AND ((tlinfo.fund_recv_reqd   = x_fund_recv_reqd) OR ((tlinfo.fund_recv_reqd IS NULL) AND (x_fund_recv_reqd IS NULL)))
        AND ((tlinfo.show_on_bill   = x_show_on_bill) OR ((tlinfo.show_on_bill IS NULL) AND (x_show_on_bill IS NULL)))
        AND ((tlinfo.bill_desc   = x_bill_desc) OR ((tlinfo.bill_desc IS NULL) AND (x_bill_desc IS NULL)))
        AND ((tlinfo.credit_type_id   = x_credit_type_id) OR ((tlinfo.credit_type_id IS NULL) AND (x_credit_type_id IS NULL)))
        AND ((tlinfo.spnsr_ref_num = x_spnsr_ref_num) OR ((tlinfo.spnsr_ref_num IS NULL) AND (x_spnsr_ref_num IS NULL)))
        AND ((tlinfo.party_id = x_party_id) OR ((tlinfo.party_id IS NULL) AND (x_party_id IS NULL)))
        AND ((tlinfo.spnsr_fee_type = x_spnsr_fee_type) OR ((tlinfo.spnsr_fee_type IS NULL) AND (x_spnsr_fee_type IS NULL)))
        AND ((tlinfo.min_credit_points = x_min_credit_points) OR ((tlinfo.min_credit_points IS NULL) AND (x_min_credit_points IS NULL)))
        AND ((tlinfo.group_id = x_group_id) OR ((tlinfo.group_id IS NULL) AND (x_group_id IS NULL)))
        AND ((tlinfo.spnsr_attribute_category = x_spnsr_attribute_category) OR ((tlinfo.spnsr_attribute_category IS NULL) AND (X_spnsr_attribute_category IS NULL)))
        AND ((tlinfo.spnsr_attribute1 = x_spnsr_attribute1) OR ((tlinfo.spnsr_attribute1 IS NULL) AND (X_spnsr_attribute1 IS NULL)))
        AND ((tlinfo.spnsr_attribute2 = x_spnsr_attribute2) OR ((tlinfo.spnsr_attribute2 IS NULL) AND (X_spnsr_attribute2 IS NULL)))
        AND ((tlinfo.spnsr_attribute3 = x_spnsr_attribute3) OR ((tlinfo.spnsr_attribute3 IS NULL) AND (X_spnsr_attribute3 IS NULL)))
        AND ((tlinfo.spnsr_attribute4 = x_spnsr_attribute4) OR ((tlinfo.spnsr_attribute4 IS NULL) AND (X_spnsr_attribute4 IS NULL)))
        AND ((tlinfo.spnsr_attribute5 = x_spnsr_attribute5) OR ((tlinfo.spnsr_attribute5 IS NULL) AND (X_spnsr_attribute5 IS NULL)))
        AND ((tlinfo.spnsr_attribute6 = x_spnsr_attribute6) OR ((tlinfo.spnsr_attribute6 IS NULL) AND (X_spnsr_attribute6 IS NULL)))
        AND ((tlinfo.spnsr_attribute7 = x_spnsr_attribute7) OR ((tlinfo.spnsr_attribute7 IS NULL) AND (X_spnsr_attribute7 IS NULL)))
        AND ((tlinfo.spnsr_attribute8 = x_spnsr_attribute8) OR ((tlinfo.spnsr_attribute8 IS NULL) AND (X_spnsr_attribute8 IS NULL)))
        AND ((tlinfo.spnsr_attribute9 = x_spnsr_attribute9) OR ((tlinfo.spnsr_attribute9 IS NULL) AND (X_spnsr_attribute9 IS NULL)))
        AND ((tlinfo.spnsr_attribute10 = x_spnsr_attribute10) OR ((tlinfo.spnsr_attribute10 IS NULL) AND (X_spnsr_attribute10 IS NULL)))
        AND ((tlinfo.spnsr_attribute11 = x_spnsr_attribute11) OR ((tlinfo.spnsr_attribute11 IS NULL) AND (X_spnsr_attribute11 IS NULL)))
        AND ((tlinfo.spnsr_attribute12 = x_spnsr_attribute12) OR ((tlinfo.spnsr_attribute12 IS NULL) AND (X_spnsr_attribute12 IS NULL)))
        AND ((tlinfo.spnsr_attribute13 = x_spnsr_attribute13) OR ((tlinfo.spnsr_attribute13 IS NULL) AND (X_spnsr_attribute13 IS NULL)))
        AND ((tlinfo.spnsr_attribute14 = x_spnsr_attribute14) OR ((tlinfo.spnsr_attribute14 IS NULL) AND (X_spnsr_attribute14 IS NULL)))
        AND ((tlinfo.spnsr_attribute15 = x_spnsr_attribute15) OR ((tlinfo.spnsr_attribute15 IS NULL) AND (X_spnsr_attribute15 IS NULL)))
        AND ((tlinfo.spnsr_attribute16 = x_spnsr_attribute16) OR ((tlinfo.spnsr_attribute16 IS NULL) AND (X_spnsr_attribute16 IS NULL)))
        AND ((tlinfo.spnsr_attribute17 = x_spnsr_attribute17) OR ((tlinfo.spnsr_attribute17 IS NULL) AND (X_spnsr_attribute17 IS NULL)))
        AND ((tlinfo.spnsr_attribute18 = x_spnsr_attribute18) OR ((tlinfo.spnsr_attribute18 IS NULL) AND (X_spnsr_attribute18 IS NULL)))
        AND ((tlinfo.spnsr_attribute19 = x_spnsr_attribute19) OR ((tlinfo.spnsr_attribute19 IS NULL) AND (X_spnsr_attribute19 IS NULL)))
        AND ((tlinfo.spnsr_attribute20 = x_spnsr_attribute20) OR ((tlinfo.spnsr_attribute20 IS NULL) AND (X_spnsr_attribute20 IS NULL)))
        AND ((tlinfo.threshold_perct = x_threshold_perct) OR ((tlinfo.threshold_perct IS NULL) AND (x_threshold_perct IS NULL)))
        AND ((tlinfo.threshold_value = x_threshold_value) OR ((tlinfo.threshold_value IS NULL) AND (x_threshold_value IS NULL)))
        AND ((tlinfo.ver_app_stat_override = x_ver_app_stat_override) OR ((tlinfo.ver_app_stat_override IS NULL) AND (x_ver_app_stat_override IS NULL)))
        AND ((tlinfo.gift_aid = x_gift_aid) OR ((tlinfo.gift_aid IS NULL) AND (x_gift_aid IS NULL)))
        AND ((tlinfo.send_without_doc = x_send_without_doc) OR ((tlinfo.send_without_doc IS NULL) AND (x_send_without_doc IS NULL)))
        AND ((tlinfo.re_pkg_verif_flag = x_re_pkg_verif_flag) OR ((tlinfo.re_pkg_verif_flag IS NULL) AND (x_re_pkg_verif_flag IS NULL)))
        AND ((tlinfo.donot_repkg_if_code = x_donot_repkg_if_code) OR ((tlinfo.donot_repkg_if_code IS NULL) AND (x_donot_repkg_if_code IS NULL)))
        AND ((tlinfo.lock_award_flag = x_lock_award_flag) OR ((tlinfo.lock_award_flag IS NULL) AND (x_lock_award_flag IS NULL)))
        AND ((tlinfo.disb_rounding_code = x_disb_rounding_code) OR ((tlinfo.disb_rounding_code IS NULL) AND (x_disb_rounding_code IS NULL)))
        AND ((tlinfo.view_only_flag = x_view_only_flag) OR ((tlinfo.view_only_flag IS NULL) AND (x_view_only_flag IS NULL)))
        AND ((tlinfo.accept_less_amt_flag = x_accept_less_amt_flag) OR ((tlinfo.accept_less_amt_flag IS NULL) AND (x_accept_less_amt_flag IS NULL)))
        AND ((tlinfo.allow_inc_post_accept_flag = x_allow_inc_post_accept_flag) OR ((tlinfo.allow_inc_post_accept_flag IS NULL) AND (x_allow_inc_post_accept_flag IS NULL)))
        AND ((tlinfo.min_increase_amt = x_min_increase_amt) OR ((tlinfo.min_increase_amt IS NULL) AND (x_min_increase_amt IS NULL)))
        AND ((tlinfo.allow_dec_post_accept_flag = x_allow_dec_post_accept_flag) OR ((tlinfo.allow_dec_post_accept_flag IS NULL) AND (x_allow_dec_post_accept_flag IS NULL)))
        AND ((tlinfo.min_decrease_amt = x_min_decrease_amt) OR ((tlinfo.min_decrease_amt IS NULL) AND (x_min_decrease_amt IS NULL)))
        AND ((tlinfo.allow_decln_post_accept_flag = x_allow_decln_post_accept_flag) OR ((tlinfo.allow_decln_post_accept_flag IS NULL) AND (x_allow_decln_post_accept_flag IS NULL)))
        AND ((tlinfo.status_after_decline = x_status_after_decline) OR ((tlinfo.status_after_decline IS NULL) AND (x_status_after_decline IS NULL)))
        AND ((tlinfo.fund_information_txt = x_fund_information_txt) OR ((tlinfo.fund_information_txt IS NULL) AND (x_fund_information_txt IS NULL)))
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
    x_fund_id                           IN     NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_discontinue_fund                  IN     VARCHAR2,
    x_entitlement                       IN     VARCHAR2,
    x_auto_pkg                          IN     VARCHAR2,
    x_self_help                         IN     VARCHAR2,
    x_allow_man_pkg                     IN     VARCHAR2,
    x_update_need                       IN     VARCHAR2,
    x_disburse_fund                     IN     VARCHAR2,
    x_available_amt                     IN     NUMBER,
    x_offered_amt                       IN     NUMBER,
    x_pending_amt                       IN     NUMBER,
    x_accepted_amt                      IN     NUMBER,
    x_declined_amt                      IN     NUMBER,
    x_cancelled_amt                     IN     NUMBER,
    x_remaining_amt                     IN     NUMBER,
    x_enrollment_status                 IN     VARCHAR2,
    x_prn_award_letter                  IN     VARCHAR2,
    x_over_award_amt                    IN     NUMBER,
    x_over_award_perct                  IN     NUMBER,
    x_min_award_amt                     IN     NUMBER,
    x_max_award_amt                     IN     NUMBER,
    x_max_yearly_amt                    IN     NUMBER,
    x_max_life_amt                      IN     NUMBER,
    x_max_life_term                     IN     NUMBER,
    x_fm_fc_methd                       IN     VARCHAR2,
    x_roundoff_fact                     IN     VARCHAR2,
    x_replace_fc                        IN     VARCHAR2,
    x_allow_overaward                   IN     VARCHAR2,
    x_pckg_awd_stat                     IN     VARCHAR2,
    x_org_record_req                    IN     VARCHAR2,
    x_disb_record_req                   IN     VARCHAR2,
    x_prom_note_req                     IN     VARCHAR2,
    x_min_num_disb                      IN     NUMBER,
    x_max_num_disb                      IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_total_offered                     IN     NUMBER,
    x_total_accepted                    IN     NUMBER,
    x_total_declined                    IN     NUMBER,
    x_total_revoked                     IN     NUMBER,
    x_total_cancelled                   IN     NUMBER,
    x_total_disbursed                   IN     NUMBER,
    x_total_committed                   IN     NUMBER,
    x_committed_amt                     IN     NUMBER,
    x_disbursed_amt                     IN     NUMBER,
    x_awd_notice_txt                    IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_disb_verf_da                      IN     VARCHAR2,
    x_fund_exp_da                       IN     VARCHAR2,
    x_nslds_disb_da                     IN     VARCHAR2,
    x_disb_exp_da                       IN     VARCHAR2,
    x_fund_recv_reqd                    IN     VARCHAR2,
    x_show_on_bill                      IN     VARCHAR2,
    x_bill_desc                         IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER,
    x_spnsr_ref_num                     IN     VARCHAR2,
    x_party_id                          IN     VARCHAR2,
    x_spnsr_fee_type                    IN     VARCHAR2,
    x_min_credit_points                 IN     NUMBER,
    x_group_id                          IN     NUMBER,
    x_spnsr_attribute_category          IN     VARCHAR2,
    x_spnsr_attribute1                  IN     VARCHAR2,
    x_spnsr_attribute2                  IN     VARCHAR2,
    x_spnsr_attribute3                  IN     VARCHAR2,
    x_spnsr_attribute4                  IN     VARCHAR2,
    x_spnsr_attribute5                  IN     VARCHAR2,
    x_spnsr_attribute6                  IN     VARCHAR2,
    x_spnsr_attribute7                  IN     VARCHAR2,
    x_spnsr_attribute8                  IN     VARCHAR2,
    x_spnsr_attribute9                  IN     VARCHAR2,
    x_spnsr_attribute10                 IN     VARCHAR2,
    x_spnsr_attribute11                 IN     VARCHAR2,
    x_spnsr_attribute12                 IN     VARCHAR2,
    x_spnsr_attribute13                 IN     VARCHAR2,
    x_spnsr_attribute14                 IN     VARCHAR2,
    x_spnsr_attribute15                 IN     VARCHAR2,
    x_spnsr_attribute16                 IN     VARCHAR2,
    x_spnsr_attribute17                 IN     VARCHAR2,
    x_spnsr_attribute18                 IN     VARCHAR2,
    x_spnsr_attribute19                 IN     VARCHAR2,
    x_spnsr_attribute20                 IN     VARCHAR2,
    x_threshold_perct                   IN     NUMBER,
    x_threshold_value                   IN     NUMBER,
    x_ver_app_stat_override             IN     VARCHAR2,
    x_gift_aid                          IN     VARCHAR2,
    x_send_without_doc                  IN     VARCHAR2,   -- Added as part of Bug # 2758812
    x_mode                              IN     VARCHAR2,
    x_re_pkg_verif_flag                 IN     VARCHAR2,
    x_donot_repkg_if_code               IN     VARCHAR2,
    x_lock_award_flag                   IN     VARCHAR2,
    x_disb_rounding_code                IN     VARCHAR2  DEFAULT NULL,
    x_view_only_flag                    IN     VARCHAR2  DEFAULT NULL,
    x_accept_less_amt_flag              IN     VARCHAR2  DEFAULT NULL,
    x_allow_inc_post_accept_flag        IN     VARCHAR2  DEFAULT NULL,
    x_min_increase_amt                  IN     NUMBER    DEFAULT NULL,
    x_allow_dec_post_accept_flag        IN     VARCHAR2  DEFAULT NULL,
    x_min_decrease_amt                  IN     NUMBER    DEFAULT NULL,
    x_allow_decln_post_accept_flag      IN     VARCHAR2  DEFAULT NULL,
    x_status_after_decline              IN     VARCHAR2  DEFAULT NULL,
    x_fund_information_txt              IN     VARCHAR2  DEFAULT NULL

  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 14-NOV-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  museshad        14-Jul-2005     Build FA 140 - Changes relating to the
  ||                                  addition of new columns
  ||  museshad        25-May-2005     Build# FA157 - Bug# 4382371.
  ||                                  New column 'DISB_ROUNDING_CODE' has been added
  ||                                  to the table 'IGF_AW_FUND_MAST_ALL'.
  ||                                  Modified the TBH to include this.
  ||  veramach        1-NOV-2003      FA 125 - Removed elig_criteria from assigments,update statements
  ||  mesriniv        06-JUL-2001     Added code to calculate the
  ||                                  Committed Amount
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
      x_fund_id                           => x_fund_id,
      x_fund_code                         => x_fund_code,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_description                       => x_description,
      x_discontinue_fund                  => x_discontinue_fund,
      x_entitlement                       => x_entitlement,
      x_auto_pkg                          => x_auto_pkg,
      x_self_help                         => x_self_help,
      x_allow_man_pkg                     => x_allow_man_pkg,
      x_update_need                       => x_update_need,
      x_disburse_fund                     => x_disburse_fund,
      x_available_amt                     => x_available_amt,
      x_offered_amt                       => x_offered_amt,
      x_pending_amt                       => x_pending_amt,
      x_accepted_amt                      => x_accepted_amt,
      x_declined_amt                      => x_declined_amt,
      x_cancelled_amt                     => x_cancelled_amt,
      x_remaining_amt                     => x_remaining_amt,
      x_enrollment_status                 => x_enrollment_status,
      x_prn_award_letter                  => x_prn_award_letter,
      x_over_award_amt                    => x_over_award_amt,
      x_over_award_perct                  => x_over_award_perct,
      x_min_award_amt                     => x_min_award_amt,
      x_max_award_amt                     => x_max_award_amt,
      x_max_yearly_amt                    => x_max_yearly_amt,
      x_max_life_amt                      => x_max_life_amt,
      x_max_life_term                     => x_max_life_term,
      x_fm_fc_methd                       => x_fm_fc_methd,
      x_roundoff_fact                     => x_roundoff_fact,
      x_replace_fc                        => x_replace_fc,
      x_allow_overaward                   => x_allow_overaward,
      x_pckg_awd_stat                     => x_pckg_awd_stat,
      x_org_record_req                    => x_org_record_req,
      x_disb_record_req                   => x_disb_record_req,
      x_prom_note_req                     => x_prom_note_req,
      x_min_num_disb                      => x_min_num_disb,
      x_max_num_disb                      => x_max_num_disb,
      x_fee_type                          => x_fee_type,
      x_total_offered                     => x_total_offered,
      x_total_accepted                    => x_total_accepted,
      x_total_declined                    => x_total_declined,
      x_total_revoked                     => x_total_revoked,
      x_total_cancelled                   => x_total_cancelled,
      x_total_disbursed                   => x_total_disbursed,
      x_total_committed                   => x_total_committed,
      x_committed_amt                     => x_committed_amt,
      x_disbursed_amt                     => x_disbursed_amt,
      x_awd_notice_txt                    => x_awd_notice_txt,
      x_attribute_category                => x_attribute_category,
      x_attribute1                        => x_attribute1,
      x_attribute2                        => x_attribute2,
      x_attribute3                        => x_attribute3,
      x_attribute4                        => x_attribute4,
      x_attribute5                        => x_attribute5,
      x_attribute6                        => x_attribute6,
      x_attribute7                        => x_attribute7,
      x_attribute8                        => x_attribute8,
      x_attribute9                        => x_attribute9,
      x_attribute10                       => x_attribute10,
      x_attribute11                       => x_attribute11,
      x_attribute12                       => x_attribute12,
      x_attribute13                       => x_attribute13,
      x_attribute14                       => x_attribute14,
      x_attribute15                       => x_attribute15,
      x_attribute16                       => x_attribute16,
      x_attribute17                       => x_attribute17,
      x_attribute18                       => x_attribute18,
      x_attribute19                       => x_attribute19,
      x_attribute20                       => x_attribute20,
      x_disb_verf_da                      => x_disb_verf_da,
      x_fund_exp_da                       => x_fund_exp_da,
      x_nslds_disb_da                     => x_nslds_disb_da,
      x_disb_exp_da                       => x_disb_exp_da,
      x_fund_recv_reqd                    => x_fund_recv_reqd,
      x_show_on_bill                      => x_show_on_bill,
      x_bill_desc                         => x_bill_desc,
      x_credit_type_id                    => x_credit_type_id,
      x_spnsr_ref_num                     => x_spnsr_ref_num,
      x_party_id                          => x_party_id ,
      x_spnsr_fee_type                    => x_spnsr_fee_type,
      x_min_credit_points                 => x_min_credit_points,
      x_group_id                          => x_group_id,
      x_spnsr_attribute_category          => x_spnsr_attribute_category,
      x_spnsr_attribute1                  => x_spnsr_attribute1,
      x_spnsr_attribute2                  => x_spnsr_attribute2,
      x_spnsr_attribute3                  => x_spnsr_attribute3,
      x_spnsr_attribute4                  => x_spnsr_attribute4,
      x_spnsr_attribute5                  => x_spnsr_attribute5,
      x_spnsr_attribute6                  => x_spnsr_attribute6,
      x_spnsr_attribute7                  => x_spnsr_attribute7,
      x_spnsr_attribute8                  => x_spnsr_attribute8,
      x_spnsr_attribute9                  => x_spnsr_attribute9,
      x_spnsr_attribute10                 => x_spnsr_attribute10,
      x_spnsr_attribute11                 => x_spnsr_attribute11,
      x_spnsr_attribute12                 => x_spnsr_attribute12,
      x_spnsr_attribute13                 => x_spnsr_attribute13,
      x_spnsr_attribute14                 => x_spnsr_attribute14,
      x_spnsr_attribute15                 => x_spnsr_attribute15,
      x_spnsr_attribute16                 => x_spnsr_attribute16,
      x_spnsr_attribute17                 => x_spnsr_attribute17,
      x_spnsr_attribute18                 => x_spnsr_attribute18,
      x_spnsr_attribute19                 => x_spnsr_attribute19,
      x_spnsr_attribute20                 => x_spnsr_attribute20,
      x_threshold_perct                   => x_threshold_perct ,
      x_threshold_value                   => x_threshold_value,
       x_ver_app_stat_override            => x_ver_app_stat_override,
       x_gift_aid                         => x_gift_aid ,
       x_send_without_doc                 => x_send_without_doc, -- Added as part of Bug # 2758812
       x_creation_date                    => x_last_update_date,
       x_created_by                       => x_last_updated_by,
       x_last_update_date                 => x_last_update_date,
       x_last_updated_by                  => x_last_updated_by,
       x_last_update_login                => x_last_update_login,
       x_re_pkg_verif_flag                => x_re_pkg_verif_flag,
       x_donot_repkg_if_code              => x_donot_repkg_if_code,
       x_lock_award_flag                  => x_lock_award_flag,
       x_disb_rounding_code               => x_disb_rounding_code,
      x_view_only_flag                    => x_view_only_flag,
      x_accept_less_amt_flag              => x_accept_less_amt_flag,
      x_allow_inc_post_accept_flag        => x_allow_inc_post_accept_flag,
      x_min_increase_amt                  => x_min_increase_amt,
      x_allow_dec_post_accept_flag        => x_allow_dec_post_accept_flag,
      x_min_decrease_amt                  => x_min_decrease_amt,
      x_allow_decln_post_accept_flag      => x_allow_decln_post_accept_flag,
      x_status_after_decline              => x_status_after_decline,
      x_fund_information_txt              => x_fund_information_txt

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

    -- Update the remaining amt

      new_references.remaining_amt  := NVL(new_references.available_amt,0 )
                                     - NVL(new_references.offered_amt,0 )
                                     + NVL(new_references.declined_amt,0 )
                                     + NVL(new_references.cancelled_amt,0 ) ;

 -- Update the Committed amt
 -- Corrected wrt. Bug 2310222

      new_references.committed_amt  := NVL(new_references.accepted_amt,0)
                                     - NVL(new_references.disbursed_amt,0) ;



    UPDATE igf_aw_fund_mast_all
      SET
        fund_code                         = new_references.fund_code,
        ci_cal_type                       = new_references.ci_cal_type,
        ci_sequence_number                = new_references.ci_sequence_number,
        description                       = new_references.description,
        discontinue_fund                  = new_references.discontinue_fund,
        entitlement                       = new_references.entitlement,
        auto_pkg                          = new_references.auto_pkg,
        self_help                         = new_references.self_help,
        allow_man_pkg                     = new_references.allow_man_pkg,
        update_need                       = new_references.update_need,
        disburse_fund                     = new_references.disburse_fund,
        available_amt                     = new_references.available_amt,
        offered_amt                       = new_references.offered_amt,
        pending_amt                       = new_references.pending_amt,
        accepted_amt                      = new_references.accepted_amt,
        declined_amt                      = new_references.declined_amt,
        cancelled_amt                     = new_references.cancelled_amt,
        remaining_amt                     = new_references.remaining_amt,
        enrollment_status                 = new_references.enrollment_status,
        prn_award_letter                  = new_references.prn_award_letter,
        over_award_amt                    = new_references.over_award_amt,
        over_award_perct                  = new_references.over_award_perct,
        min_award_amt                     = new_references.min_award_amt,
        max_award_amt                     = new_references.max_award_amt,
        max_yearly_amt                    = new_references.max_yearly_amt,
        max_life_amt                      = new_references.max_life_amt,
        max_life_term                     = new_references.max_life_term,
        fm_fc_methd                       = new_references.fm_fc_methd,
        roundoff_fact                     = new_references.roundoff_fact,
        replace_fc                        = new_references.replace_fc,
        allow_overaward                   = new_references.allow_overaward,
        pckg_awd_stat                     = new_references.pckg_awd_stat,
        org_record_req                    = new_references.org_record_req,
        disb_record_req                   = new_references.disb_record_req,
        prom_note_req                     = new_references.prom_note_req,
        min_num_disb                      = new_references.min_num_disb,
        max_num_disb                      = new_references.max_num_disb,
        fee_type                          = new_references.fee_type,
        total_offered                     = new_references.total_offered,
        total_accepted                    = new_references.total_accepted,
        total_declined                    = new_references.total_declined,
        total_revoked                     = new_references.total_revoked,
        total_cancelled                   = new_references.total_cancelled,
        total_disbursed                   = new_references.total_disbursed,
        total_committed                   = new_references.total_committed,
        committed_amt                     = new_references.committed_amt,
        disbursed_amt                     = new_references.disbursed_amt,
        awd_notice_txt                    = new_references.awd_notice_txt,
        attribute_category                = new_references.attribute_category,
        attribute1                        = new_references.attribute1,
        attribute2                        = new_references.attribute2,
        attribute3                        = new_references.attribute3,
        attribute4                        = new_references.attribute4,
        attribute5                        = new_references.attribute5,
        attribute6                        = new_references.attribute6,
        attribute7                        = new_references.attribute7,
        attribute8                        = new_references.attribute8,
        attribute9                        = new_references.attribute9,
        attribute10                       = new_references.attribute10,
        attribute11                       = new_references.attribute11,
        attribute12                       = new_references.attribute12,
        attribute13                       = new_references.attribute13,
        attribute14                       = new_references.attribute14,
        attribute15                       = new_references.attribute15,
        attribute16                       = new_references.attribute16,
        attribute17                       = new_references.attribute17,
        attribute18                       = new_references.attribute18,
        attribute19                       = new_references.attribute19,
        attribute20                       = new_references.attribute20,
        disb_verf_da                      = new_references.disb_verf_da,
        fund_exp_da                       = new_references.fund_exp_da,
        nslds_disb_da                     = new_references.nslds_disb_da,
        disb_exp_da                       = new_references.disb_exp_da,
        fund_recv_reqd                    = new_references.fund_recv_reqd,
        show_on_bill                      = new_references.show_on_bill,
        bill_desc                         = new_references.bill_desc,
        credit_type_id                    = new_references.credit_type_id,
        spnsr_ref_num                     = new_references.spnsr_ref_num,
        party_id                          = new_references.party_id,
        spnsr_fee_type                    = new_references.spnsr_fee_type,
        min_credit_points                 = new_references.min_credit_points,
        group_id                          =  new_references.group_id,
        spnsr_attribute_category          =  new_references.spnsr_attribute_category,
        spnsr_attribute1                  = new_references.spnsr_attribute1,
        spnsr_attribute2                  = new_references.spnsr_attribute2,
        spnsr_attribute3                  = new_references.spnsr_attribute3,
        spnsr_attribute4                  = new_references.spnsr_attribute4,
        spnsr_attribute5                  = new_references.spnsr_attribute5,
        spnsr_attribute6                  = new_references.spnsr_attribute6,
        spnsr_attribute7                  = new_references.spnsr_attribute7,
        spnsr_attribute8                  = new_references.spnsr_attribute8,
        spnsr_attribute9                  = new_references.spnsr_attribute9,
        spnsr_attribute10                 = new_references.spnsr_attribute10,
        spnsr_attribute11                 = new_references.spnsr_attribute11,
        spnsr_attribute12                 = new_references.spnsr_attribute12,
        spnsr_attribute13                 = new_references.spnsr_attribute13,
        spnsr_attribute14                 = new_references.spnsr_attribute14,
        spnsr_attribute15                 = new_references.spnsr_attribute15,
        spnsr_attribute16                 = new_references.spnsr_attribute16,
        spnsr_attribute17                 = new_references.spnsr_attribute17,
        spnsr_attribute18                 = new_references.spnsr_attribute18,
        spnsr_attribute19                 = new_references.spnsr_attribute19,
        spnsr_attribute20                 = new_references.spnsr_attribute20,
        threshold_perct                   = new_references.threshold_perct,
        threshold_value                   = new_references.threshold_value,
        ver_app_stat_override             = new_references.ver_app_stat_override,
        gift_aid                          = new_references.gift_aid ,
        send_without_doc                  = new_references.send_without_doc,
        re_pkg_verif_flag                 = new_references.re_pkg_verif_flag,
        donot_repkg_if_code               = new_references.donot_repkg_if_code,
        lock_award_flag                   = new_references.lock_award_flag,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        disb_rounding_code                = new_references.disb_rounding_code,
        view_only_flag                    = new_references.view_only_flag,
        accept_less_amt_flag              = new_references.accept_less_amt_flag,
        allow_inc_post_accept_flag        = new_references.allow_inc_post_accept_flag,
        min_increase_amt                  = new_references.min_increase_amt,
        allow_dec_post_accept_flag        = new_references.allow_dec_post_accept_flag,
        min_decrease_amt                  = new_references.min_decrease_amt,
        allow_decln_post_accept_flag      = new_references.allow_decln_post_accept_flag,
        status_after_decline              = new_references.status_after_decline,
        fund_information_txt              = new_references.fund_information_txt

      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


 PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fund_id                           IN OUT NOCOPY NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_discontinue_fund                  IN     VARCHAR2,
    x_entitlement                       IN     VARCHAR2,
    x_auto_pkg                          IN     VARCHAR2,
    x_self_help                         IN     VARCHAR2,
    x_allow_man_pkg                     IN     VARCHAR2,
    x_update_need                       IN     VARCHAR2,
    x_disburse_fund                     IN     VARCHAR2,
    x_available_amt                     IN     NUMBER,
    x_offered_amt                       IN     NUMBER,
    x_pending_amt                       IN     NUMBER,
    x_accepted_amt                      IN     NUMBER,
    x_declined_amt                      IN     NUMBER,
    x_cancelled_amt                     IN     NUMBER,
    x_remaining_amt                     IN     NUMBER,
    x_enrollment_status                 IN     VARCHAR2,
    x_prn_award_letter                  IN     VARCHAR2,
    x_over_award_amt                    IN     NUMBER,
    x_over_award_perct                  IN     NUMBER,
    x_min_award_amt                     IN     NUMBER,
    x_max_award_amt                     IN     NUMBER,
    x_max_yearly_amt                    IN     NUMBER,
    x_max_life_amt                      IN     NUMBER,
    x_max_life_term                     IN     NUMBER,
    x_fm_fc_methd                       IN     VARCHAR2,
    x_roundoff_fact                     IN     VARCHAR2,
    x_replace_fc                        IN     VARCHAR2,
    x_allow_overaward                   IN     VARCHAR2,
    x_pckg_awd_stat                     IN     VARCHAR2,
    x_org_record_req                    IN     VARCHAR2,
    x_disb_record_req                   IN     VARCHAR2,
    x_prom_note_req                     IN     VARCHAR2,
    x_min_num_disb                      IN     NUMBER,
    x_max_num_disb                      IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_total_offered                     IN     NUMBER,
    x_total_accepted                    IN     NUMBER,
    x_total_declined                    IN     NUMBER,
    x_total_revoked                     IN     NUMBER,
    x_total_cancelled                   IN     NUMBER,
    x_total_disbursed                   IN     NUMBER,
    x_total_committed                   IN     NUMBER,
    x_committed_amt                     IN     NUMBER,
    x_disbursed_amt                     IN     NUMBER,
    x_awd_notice_txt                    IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_disb_verf_da                      IN     VARCHAR2,
    x_fund_exp_da                       IN     VARCHAR2,
    x_nslds_disb_da                     IN     VARCHAR2,
    x_disb_exp_da                       IN     VARCHAR2,
    x_fund_recv_reqd                    IN     VARCHAR2,
    x_show_on_bill                      IN     VARCHAR2,
    x_bill_desc                         IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER,
    x_spnsr_ref_num                     IN     VARCHAR2,
    x_party_id                          IN     VARCHAR2,
    x_spnsr_fee_type                    IN     VARCHAR2,
    x_min_credit_points                 IN     NUMBER,
    x_group_id                          IN     NUMBER,
    x_spnsr_attribute_category          IN     VARCHAR2,
    x_spnsr_attribute1                  IN     VARCHAR2,
    x_spnsr_attribute2                  IN     VARCHAR2,
    x_spnsr_attribute3                  IN     VARCHAR2,
    x_spnsr_attribute4                  IN     VARCHAR2,
    x_spnsr_attribute5                  IN     VARCHAR2,
    x_spnsr_attribute6                  IN     VARCHAR2,
    x_spnsr_attribute7                  IN     VARCHAR2,
    x_spnsr_attribute8                  IN     VARCHAR2,
    x_spnsr_attribute9                  IN     VARCHAR2,
    x_spnsr_attribute10                 IN     VARCHAR2,
    x_spnsr_attribute11                 IN     VARCHAR2,
    x_spnsr_attribute12                 IN     VARCHAR2,
    x_spnsr_attribute13                 IN     VARCHAR2,
    x_spnsr_attribute14                 IN     VARCHAR2,
    x_spnsr_attribute15                 IN     VARCHAR2,
    x_spnsr_attribute16                 IN     VARCHAR2,
    x_spnsr_attribute17                 IN     VARCHAR2,
    x_spnsr_attribute18                 IN     VARCHAR2,
    x_spnsr_attribute19                 IN     VARCHAR2,
    x_spnsr_attribute20                 IN     VARCHAR2,
    x_threshold_perct                   IN     NUMBER,
    x_threshold_value                   IN     NUMBER,
    x_ver_app_stat_override             IN     VARCHAR2,
    x_gift_aid                          IN     VARCHAR2,
    x_send_without_doc                  IN     VARCHAR2,   -- Added as part of Bug # 2758812
    x_mode                              IN     VARCHAR2,
    x_re_pkg_verif_flag                 IN     VARCHAR2,
    x_donot_repkg_if_code               IN     VARCHAR2,
    x_lock_award_flag                   IN     VARCHAR2,
    x_disb_rounding_code                IN     VARCHAR2  DEFAULT NULL,
    x_view_only_flag                    IN     VARCHAR2  DEFAULT NULL,
    x_accept_less_amt_flag              IN     VARCHAR2  DEFAULT NULL,
    x_allow_inc_post_accept_flag        IN     VARCHAR2  DEFAULT NULL,
    x_min_increase_amt                  IN     NUMBER    DEFAULT NULL,
    x_allow_dec_post_accept_flag        IN     VARCHAR2  DEFAULT NULL,
    x_min_decrease_amt                  IN     NUMBER    DEFAULT NULL,
    x_allow_decln_post_accept_flag      IN     VARCHAR2  DEFAULT NULL,
    x_status_after_decline              IN     VARCHAR2  DEFAULT NULL,
    x_fund_information_txt              IN     VARCHAR2  DEFAULT NULL

  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 14-NOV-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  museshad        14-Jul-2005     FA 140 - Changes relating to the addition of new columns
  ||  museshad        25-May-2005     The order of the parameters in the call to update_row()
  ||                                  procedure was incorrect. Corrected this.
  ||  veramach        1-NOV-2003      FA 125 - Removed elig_criteria from assigments
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_aw_fund_mast_all
      WHERE    fund_id                           = x_fund_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

       insert_row (
        x_rowid,
        x_fund_id,
        x_fund_code,
        x_ci_cal_type,
        x_ci_sequence_number,
        x_description,
        x_discontinue_fund,
        x_entitlement,
        x_auto_pkg,
        x_self_help,
        x_allow_man_pkg,
        x_update_need,
        x_disburse_fund,
        x_available_amt,
        x_offered_amt,
        x_pending_amt,
        x_accepted_amt,
        x_declined_amt,
        x_cancelled_amt,
        x_remaining_amt,
        x_enrollment_status,
        x_prn_award_letter,
        x_over_award_amt,
        x_over_award_perct,
        x_min_award_amt,
        x_max_award_amt,
        x_max_yearly_amt,
        x_max_life_amt,
        x_max_life_term,
        x_fm_fc_methd,
        x_roundoff_fact,
        x_replace_fc,
        x_allow_overaward,
        x_pckg_awd_stat,
        x_org_record_req,
        x_disb_record_req,
        x_prom_note_req,
        x_min_num_disb,
        x_max_num_disb,
        x_fee_type,
        x_total_offered,
        x_total_accepted,
        x_total_declined,
        x_total_revoked,
        x_total_cancelled,
        x_total_disbursed,
        x_total_committed,
        x_committed_amt,
        x_disbursed_amt,
        x_awd_notice_txt,
        x_attribute_category,
        x_attribute1,
        x_attribute2,
        x_attribute3,
        x_attribute4,
        x_attribute5,
        x_attribute6,
        x_attribute7,
        x_attribute8,
        x_attribute9,
        x_attribute10,
        x_attribute11,
        x_attribute12,
        x_attribute13,
        x_attribute14,
        x_attribute15,
        x_attribute16,
        x_attribute17,
        x_attribute18,
        x_attribute19,
        x_attribute20,
         x_disb_verf_da,
         x_fund_exp_da,
         x_nslds_disb_da,
         x_disb_exp_da,
         x_fund_recv_reqd,
         x_show_on_bill,
         x_bill_desc,
         x_credit_type_id,
         x_spnsr_ref_num,
         x_party_id,
         x_spnsr_fee_type,
         x_min_credit_points,
         x_group_id,
         x_spnsr_attribute_category,
         x_spnsr_attribute1,
         x_spnsr_attribute2,
         x_spnsr_attribute3,
         x_spnsr_attribute4,
         x_spnsr_attribute5,
         x_spnsr_attribute6,
         x_spnsr_attribute7,
         x_spnsr_attribute8,
         x_spnsr_attribute9,
         x_spnsr_attribute10,
         x_spnsr_attribute11,
         x_spnsr_attribute12,
         x_spnsr_attribute13,
         x_spnsr_attribute14,
         x_spnsr_attribute15,
         x_spnsr_attribute16,
         x_spnsr_attribute17,
         x_spnsr_attribute18,
         x_spnsr_attribute19,
         x_spnsr_attribute20,
         x_threshold_perct,
         x_threshold_value,
         x_ver_app_stat_override,
         x_gift_aid,
         x_send_without_doc,
         x_mode,
         x_re_pkg_verif_flag,
         x_donot_repkg_if_code,
         x_lock_award_flag,
         x_disb_rounding_code,
         x_view_only_flag,
         x_accept_less_amt_flag,
         x_allow_inc_post_accept_flag,
         x_min_increase_amt,
         x_allow_dec_post_accept_flag,
         x_min_decrease_amt,
         x_allow_decln_post_accept_flag,
         x_status_after_decline,
         x_fund_information_txt
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_fund_id,
      x_fund_code,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_description,
      x_discontinue_fund,
      x_entitlement,
      x_auto_pkg,
      x_self_help,
      x_allow_man_pkg,
      x_update_need,
      x_disburse_fund,
      x_available_amt,
      x_offered_amt,
      x_pending_amt,
      x_accepted_amt,
      x_declined_amt,
      x_cancelled_amt,
      x_remaining_amt,
      x_enrollment_status,
      x_prn_award_letter,
      x_over_award_amt,
      x_over_award_perct,
      x_min_award_amt,
      x_max_award_amt,
      x_max_yearly_amt,
      x_max_life_amt,
      x_max_life_term,
      x_fm_fc_methd,
      x_roundoff_fact,
      x_replace_fc,
      x_allow_overaward,
      x_pckg_awd_stat,
      x_org_record_req,
      x_disb_record_req,
      x_prom_note_req,
      x_min_num_disb,
      x_max_num_disb,
      x_fee_type,
      x_total_offered,
      x_total_accepted,
      x_total_declined,
      x_total_revoked,
      x_total_cancelled,
      x_total_disbursed,
      x_total_committed,
      x_committed_amt,
      x_disbursed_amt,
      x_awd_notice_txt,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_disb_verf_da,
      x_fund_exp_da,
      x_nslds_disb_da,
      x_disb_exp_da,
      x_fund_recv_reqd,
      x_show_on_bill,
      x_bill_desc,
      x_credit_type_id,
      x_spnsr_ref_num,
      x_party_id,
      x_spnsr_fee_type,
      x_min_credit_points,
      x_group_id,
      x_spnsr_attribute_category,
      x_spnsr_attribute1,
      x_spnsr_attribute2,
      x_spnsr_attribute3,
      x_spnsr_attribute4,
      x_spnsr_attribute5,
      x_spnsr_attribute6,
      x_spnsr_attribute7,
      x_spnsr_attribute8,
      x_spnsr_attribute9,
      x_spnsr_attribute10,
      x_spnsr_attribute11,
      x_spnsr_attribute12,
      x_spnsr_attribute13,
      x_spnsr_attribute14,
      x_spnsr_attribute15,
      x_spnsr_attribute16,
      x_spnsr_attribute17,
      x_spnsr_attribute18,
      x_spnsr_attribute19,
      x_spnsr_attribute20,
      x_threshold_perct ,
      x_threshold_value  ,
      x_ver_app_stat_override,
      x_gift_aid,
      x_send_without_doc,
      x_mode,
      x_re_pkg_verif_flag,
      x_donot_repkg_if_code,
      x_lock_award_flag,
      x_disb_rounding_code,
      x_view_only_flag,
      x_accept_less_amt_flag,
      x_allow_inc_post_accept_flag,
      x_min_increase_amt,
      x_allow_dec_post_accept_flag,
      x_min_decrease_amt,
      x_allow_decln_post_accept_flag,
      x_status_after_decline,
      x_fund_information_txt
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 14-NOV-2000
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

    DELETE FROM igf_aw_fund_mast_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_aw_fund_mast_pkg;

/
