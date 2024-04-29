--------------------------------------------------------
--  DDL for Package Body IGF_GR_ELEC_STAT_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_GR_ELEC_STAT_SUM_PKG" AS
/* $Header: IGFGI11B.pls 115.6 2002/11/28 14:17:49 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igf_gr_elec_stat_sum_all%ROWTYPE;
  new_references igf_gr_elec_stat_sum_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_ess_id                            IN     NUMBER  ,
    x_rep_pell_id                       IN     VARCHAR2,
    x_duns_id                           IN     VARCHAR2,
    x_gaps_award_num                    IN     VARCHAR2,
    x_acct_schedule_number              IN     VARCHAR2,
    x_acct_schedule_date                IN     DATE    ,
    x_prev_obligation_amt               IN     NUMBER  ,
    x_obligation_adj_amt                IN     NUMBER  ,
    x_curr_obligation_amt               IN     NUMBER  ,
    x_prev_obligation_pymt_amt          IN     NUMBER  ,
    x_obligation_pymt_adj_amt           IN     NUMBER  ,
    x_curr_obligation_pymt_amt          IN     NUMBER  ,
    x_ytd_total_recp                    IN     NUMBER  ,
    x_ytd_accepted_disb_amt             IN     NUMBER  ,
    x_ytd_posted_disb_amt               IN     NUMBER  ,
    x_ytd_admin_cost_allowance          IN     NUMBER  ,
    x_caps_drwn_dn_pymts                IN     NUMBER  ,
    x_gaps_last_date                    IN     DATE    ,
    x_last_pymt_number                  IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 09-JAN-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_gr_elec_stat_sum_all
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
    new_references.ess_id                            := x_ess_id;
    new_references.rep_pell_id                       := x_rep_pell_id;
    new_references.duns_id                           := x_duns_id;
    new_references.gaps_award_num                    := x_gaps_award_num;
    new_references.acct_schedule_number              := x_acct_schedule_number;
    new_references.acct_schedule_date                := x_acct_schedule_date;
    new_references.prev_obligation_amt               := x_prev_obligation_amt;
    new_references.obligation_adj_amt                := x_obligation_adj_amt;
    new_references.curr_obligation_amt               := x_curr_obligation_amt;
    new_references.prev_obligation_pymt_amt          := x_prev_obligation_pymt_amt;
    new_references.obligation_pymt_adj_amt           := x_obligation_pymt_adj_amt;
    new_references.curr_obligation_pymt_amt          := x_curr_obligation_pymt_amt;
    new_references.ytd_total_recp                    := x_ytd_total_recp;
    new_references.ytd_accepted_disb_amt             := x_ytd_accepted_disb_amt;
    new_references.ytd_posted_disb_amt               := x_ytd_posted_disb_amt;
    new_references.ytd_admin_cost_allowance          := x_ytd_admin_cost_allowance;
    new_references.caps_drwn_dn_pymts                := x_caps_drwn_dn_pymts;
    new_references.gaps_last_date                    := x_gaps_last_date;
    new_references.last_pymt_number                  := x_last_pymt_number;

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
    x_ess_id                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : adhawan
  ||  Created On : 09-JAN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_gr_elec_stat_sum_all
      WHERE    ess_id = x_ess_id
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
    x_ess_id                            IN     NUMBER  ,
    x_rep_pell_id                       IN     VARCHAR2,
    x_duns_id                           IN     VARCHAR2,
    x_gaps_award_num                    IN     VARCHAR2,
    x_acct_schedule_number              IN     VARCHAR2,
    x_acct_schedule_date                IN     DATE    ,
    x_prev_obligation_amt               IN     NUMBER  ,
    x_obligation_adj_amt                IN     NUMBER  ,
    x_curr_obligation_amt               IN     NUMBER  ,
    x_prev_obligation_pymt_amt          IN     NUMBER  ,
    x_obligation_pymt_adj_amt           IN     NUMBER  ,
    x_curr_obligation_pymt_amt          IN     NUMBER  ,
    x_ytd_total_recp                    IN     NUMBER  ,
    x_ytd_accepted_disb_amt             IN     NUMBER  ,
    x_ytd_posted_disb_amt               IN     NUMBER  ,
    x_ytd_admin_cost_allowance          IN     NUMBER  ,
    x_caps_drwn_dn_pymts                IN     NUMBER  ,
    x_gaps_last_date                    IN     DATE    ,
    x_last_pymt_number                  IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 09-JAN-2001
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
      x_ess_id,
      x_rep_pell_id,
      x_duns_id,
      x_gaps_award_num,
      x_acct_schedule_number,
      x_acct_schedule_date,
      x_prev_obligation_amt,
      x_obligation_adj_amt,
      x_curr_obligation_amt,
      x_prev_obligation_pymt_amt,
      x_obligation_pymt_adj_amt,
      x_curr_obligation_pymt_amt,
      x_ytd_total_recp,
      x_ytd_accepted_disb_amt,
      x_ytd_posted_disb_amt,
      x_ytd_admin_cost_allowance,
      x_caps_drwn_dn_pymts,
      x_gaps_last_date,
      x_last_pymt_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.ess_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.ess_id
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
    x_ess_id                            IN OUT NOCOPY NUMBER,
    x_rep_pell_id                       IN     VARCHAR2,
    x_duns_id                           IN     VARCHAR2,
    x_gaps_award_num                    IN     VARCHAR2,
    x_acct_schedule_number              IN     VARCHAR2,
    x_acct_schedule_date                IN     DATE,
    x_prev_obligation_amt               IN     NUMBER,
    x_obligation_adj_amt                IN     NUMBER,
    x_curr_obligation_amt               IN     NUMBER,
    x_prev_obligation_pymt_amt          IN     NUMBER,
    x_obligation_pymt_adj_amt           IN     NUMBER,
    x_curr_obligation_pymt_amt          IN     NUMBER,
    x_ytd_total_recp                    IN     NUMBER,
    x_ytd_accepted_disb_amt             IN     NUMBER,
    x_ytd_posted_disb_amt               IN     NUMBER,
    x_ytd_admin_cost_allowance          IN     NUMBER,
    x_caps_drwn_dn_pymts                IN     NUMBER,
    x_gaps_last_date                    IN     DATE,
    x_last_pymt_number                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 09-JAN-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_gr_elec_stat_sum_all
      WHERE    ess_id                            = x_ess_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_org_id                     igf_gr_elec_stat_sum_all.org_id%TYPE;

  BEGIN

    l_org_id                     := igf_aw_gen.get_org_id;

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
    SELECT igf_gr_elec_stat_sum_s.NEXTVAL INTO x_ess_id FROM DUAL;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_ess_id                            => x_ess_id,
      x_rep_pell_id                       => x_rep_pell_id,
      x_duns_id                           => x_duns_id,
      x_gaps_award_num                    => x_gaps_award_num,
      x_acct_schedule_number              => x_acct_schedule_number,
      x_acct_schedule_date                => x_acct_schedule_date,
      x_prev_obligation_amt               => x_prev_obligation_amt,
      x_obligation_adj_amt                => x_obligation_adj_amt,
      x_curr_obligation_amt               => x_curr_obligation_amt,
      x_prev_obligation_pymt_amt          => x_prev_obligation_pymt_amt,
      x_obligation_pymt_adj_amt           => x_obligation_pymt_adj_amt,
      x_curr_obligation_pymt_amt          => x_curr_obligation_pymt_amt,
      x_ytd_total_recp                    => x_ytd_total_recp,
      x_ytd_accepted_disb_amt             => x_ytd_accepted_disb_amt,
      x_ytd_posted_disb_amt               => x_ytd_posted_disb_amt,
      x_ytd_admin_cost_allowance          => x_ytd_admin_cost_allowance,
      x_caps_drwn_dn_pymts                => x_caps_drwn_dn_pymts,
      x_gaps_last_date                    => x_gaps_last_date,
      x_last_pymt_number                  => x_last_pymt_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_gr_elec_stat_sum_all (
      ess_id,
      rep_pell_id,
      duns_id,
      gaps_award_num,
      acct_schedule_number,
      acct_schedule_date,
      prev_obligation_amt,
      obligation_adj_amt,
      curr_obligation_amt,
      prev_obligation_pymt_amt,
      obligation_pymt_adj_amt,
      curr_obligation_pymt_amt,
      ytd_total_recp,
      ytd_accepted_disb_amt,
      ytd_posted_disb_amt,
      ytd_admin_cost_allowance,
      caps_drwn_dn_pymts,
      gaps_last_date,
      last_pymt_number,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      org_id
    ) VALUES (
      new_references.ess_id,
      new_references.rep_pell_id,
      new_references.duns_id,
      new_references.gaps_award_num,
      new_references.acct_schedule_number,
      new_references.acct_schedule_date,
      new_references.prev_obligation_amt,
      new_references.obligation_adj_amt,
      new_references.curr_obligation_amt,
      new_references.prev_obligation_pymt_amt,
      new_references.obligation_pymt_adj_amt,
      new_references.curr_obligation_pymt_amt,
      new_references.ytd_total_recp,
      new_references.ytd_accepted_disb_amt,
      new_references.ytd_posted_disb_amt,
      new_references.ytd_admin_cost_allowance,
      new_references.caps_drwn_dn_pymts,
      new_references.gaps_last_date,
      new_references.last_pymt_number,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
      l_org_id
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
    x_ess_id                            IN     NUMBER,
    x_rep_pell_id                       IN     VARCHAR2,
    x_duns_id                           IN     VARCHAR2,
    x_gaps_award_num                    IN     VARCHAR2,
    x_acct_schedule_number              IN     VARCHAR2,
    x_acct_schedule_date                IN     DATE,
    x_prev_obligation_amt               IN     NUMBER,
    x_obligation_adj_amt                IN     NUMBER,
    x_curr_obligation_amt               IN     NUMBER,
    x_prev_obligation_pymt_amt          IN     NUMBER,
    x_obligation_pymt_adj_amt           IN     NUMBER,
    x_curr_obligation_pymt_amt          IN     NUMBER,
    x_ytd_total_recp                    IN     NUMBER,
    x_ytd_accepted_disb_amt             IN     NUMBER,
    x_ytd_posted_disb_amt               IN     NUMBER,
    x_ytd_admin_cost_allowance          IN     NUMBER,
    x_caps_drwn_dn_pymts                IN     NUMBER,
    x_gaps_last_date                    IN     DATE,
    x_last_pymt_number                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 09-JAN-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        rep_pell_id,
        duns_id,
        gaps_award_num,
        acct_schedule_number,
        acct_schedule_date,
        prev_obligation_amt,
        obligation_adj_amt,
        curr_obligation_amt,
        prev_obligation_pymt_amt,
        obligation_pymt_adj_amt,
        curr_obligation_pymt_amt,
        ytd_total_recp,
        ytd_accepted_disb_amt,
        ytd_posted_disb_amt,
        ytd_admin_cost_allowance,
        caps_drwn_dn_pymts,
        gaps_last_date,
        last_pymt_number
      FROM  igf_gr_elec_stat_sum_all
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
        ((tlinfo.rep_pell_id = x_rep_pell_id) OR ((tlinfo.rep_pell_id IS NULL) AND (X_rep_pell_id IS NULL)))
        AND ((tlinfo.duns_id = x_duns_id) OR ((tlinfo.duns_id IS NULL) AND (X_duns_id IS NULL)))
        AND ((tlinfo.gaps_award_num = x_gaps_award_num) OR ((tlinfo.gaps_award_num IS NULL) AND (X_gaps_award_num IS NULL)))
        AND ((tlinfo.acct_schedule_number = x_acct_schedule_number) OR ((tlinfo.acct_schedule_number IS NULL) AND (X_acct_schedule_number IS NULL)))
        AND ((tlinfo.acct_schedule_date = x_acct_schedule_date) OR ((tlinfo.acct_schedule_date IS NULL) AND (X_acct_schedule_date IS NULL)))
        AND ((tlinfo.prev_obligation_amt = x_prev_obligation_amt) OR ((tlinfo.prev_obligation_amt IS NULL) AND (X_prev_obligation_amt IS NULL)))
        AND ((tlinfo.obligation_adj_amt = x_obligation_adj_amt) OR ((tlinfo.obligation_adj_amt IS NULL) AND (X_obligation_adj_amt IS NULL)))
        AND ((tlinfo.curr_obligation_amt = x_curr_obligation_amt) OR ((tlinfo.curr_obligation_amt IS NULL) AND (X_curr_obligation_amt IS NULL)))
        AND ((tlinfo.prev_obligation_pymt_amt = x_prev_obligation_pymt_amt) OR ((tlinfo.prev_obligation_pymt_amt IS NULL) AND (X_prev_obligation_pymt_amt IS NULL)))
        AND ((tlinfo.obligation_pymt_adj_amt = x_obligation_pymt_adj_amt) OR ((tlinfo.obligation_pymt_adj_amt IS NULL) AND (X_obligation_pymt_adj_amt IS NULL)))
        AND ((tlinfo.curr_obligation_pymt_amt = x_curr_obligation_pymt_amt) OR ((tlinfo.curr_obligation_pymt_amt IS NULL) AND (X_curr_obligation_pymt_amt IS NULL)))
        AND ((tlinfo.ytd_total_recp = x_ytd_total_recp) OR ((tlinfo.ytd_total_recp IS NULL) AND (X_ytd_total_recp IS NULL)))
        AND ((tlinfo.ytd_accepted_disb_amt = x_ytd_accepted_disb_amt) OR ((tlinfo.ytd_accepted_disb_amt IS NULL) AND (X_ytd_accepted_disb_amt IS NULL)))
        AND ((tlinfo.ytd_posted_disb_amt = x_ytd_posted_disb_amt) OR ((tlinfo.ytd_posted_disb_amt IS NULL) AND (X_ytd_posted_disb_amt IS NULL)))
        AND ((tlinfo.ytd_admin_cost_allowance = x_ytd_admin_cost_allowance) OR ((tlinfo.ytd_admin_cost_allowance IS NULL) AND (X_ytd_admin_cost_allowance IS NULL)))
        AND ((tlinfo.caps_drwn_dn_pymts = x_caps_drwn_dn_pymts) OR ((tlinfo.caps_drwn_dn_pymts IS NULL) AND (X_caps_drwn_dn_pymts IS NULL)))
        AND ((tlinfo.gaps_last_date = x_gaps_last_date) OR ((tlinfo.gaps_last_date IS NULL) AND (X_gaps_last_date IS NULL)))
        AND ((tlinfo.last_pymt_number = x_last_pymt_number) OR ((tlinfo.last_pymt_number IS NULL) AND (X_last_pymt_number IS NULL)))
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
    x_ess_id                            IN     NUMBER,
    x_rep_pell_id                       IN     VARCHAR2,
    x_duns_id                           IN     VARCHAR2,
    x_gaps_award_num                    IN     VARCHAR2,
    x_acct_schedule_number              IN     VARCHAR2,
    x_acct_schedule_date                IN     DATE,
    x_prev_obligation_amt               IN     NUMBER,
    x_obligation_adj_amt                IN     NUMBER,
    x_curr_obligation_amt               IN     NUMBER,
    x_prev_obligation_pymt_amt          IN     NUMBER,
    x_obligation_pymt_adj_amt           IN     NUMBER,
    x_curr_obligation_pymt_amt          IN     NUMBER,
    x_ytd_total_recp                    IN     NUMBER,
    x_ytd_accepted_disb_amt             IN     NUMBER,
    x_ytd_posted_disb_amt               IN     NUMBER,
    x_ytd_admin_cost_allowance          IN     NUMBER,
    x_caps_drwn_dn_pymts                IN     NUMBER,
    x_gaps_last_date                    IN     DATE,
    x_last_pymt_number                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 09-JAN-2001
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
      x_ess_id                            => x_ess_id,
      x_rep_pell_id                       => x_rep_pell_id,
      x_duns_id                           => x_duns_id,
      x_gaps_award_num                    => x_gaps_award_num,
      x_acct_schedule_number              => x_acct_schedule_number,
      x_acct_schedule_date                => x_acct_schedule_date,
      x_prev_obligation_amt               => x_prev_obligation_amt,
      x_obligation_adj_amt                => x_obligation_adj_amt,
      x_curr_obligation_amt               => x_curr_obligation_amt,
      x_prev_obligation_pymt_amt          => x_prev_obligation_pymt_amt,
      x_obligation_pymt_adj_amt           => x_obligation_pymt_adj_amt,
      x_curr_obligation_pymt_amt          => x_curr_obligation_pymt_amt,
      x_ytd_total_recp                    => x_ytd_total_recp,
      x_ytd_accepted_disb_amt             => x_ytd_accepted_disb_amt,
      x_ytd_posted_disb_amt               => x_ytd_posted_disb_amt,
      x_ytd_admin_cost_allowance          => x_ytd_admin_cost_allowance,
      x_caps_drwn_dn_pymts                => x_caps_drwn_dn_pymts,
      x_gaps_last_date                    => x_gaps_last_date,
      x_last_pymt_number                  => x_last_pymt_number,
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

    UPDATE igf_gr_elec_stat_sum_all
      SET
        rep_pell_id                       = new_references.rep_pell_id,
        duns_id                           = new_references.duns_id,
        gaps_award_num                    = new_references.gaps_award_num,
        acct_schedule_number              = new_references.acct_schedule_number,
        acct_schedule_date                = new_references.acct_schedule_date,
        prev_obligation_amt               = new_references.prev_obligation_amt,
        obligation_adj_amt                = new_references.obligation_adj_amt,
        curr_obligation_amt               = new_references.curr_obligation_amt,
        prev_obligation_pymt_amt          = new_references.prev_obligation_pymt_amt,
        obligation_pymt_adj_amt           = new_references.obligation_pymt_adj_amt,
        curr_obligation_pymt_amt          = new_references.curr_obligation_pymt_amt,
        ytd_total_recp                    = new_references.ytd_total_recp,
        ytd_accepted_disb_amt             = new_references.ytd_accepted_disb_amt,
        ytd_posted_disb_amt               = new_references.ytd_posted_disb_amt,
        ytd_admin_cost_allowance          = new_references.ytd_admin_cost_allowance,
        caps_drwn_dn_pymts                = new_references.caps_drwn_dn_pymts,
        gaps_last_date                    = new_references.gaps_last_date,
        last_pymt_number                  = new_references.last_pymt_number,
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
    x_ess_id                            IN OUT NOCOPY NUMBER,
    x_rep_pell_id                       IN     VARCHAR2,
    x_duns_id                           IN     VARCHAR2,
    x_gaps_award_num                    IN     VARCHAR2,
    x_acct_schedule_number              IN     VARCHAR2,
    x_acct_schedule_date                IN     DATE,
    x_prev_obligation_amt               IN     NUMBER,
    x_obligation_adj_amt                IN     NUMBER,
    x_curr_obligation_amt               IN     NUMBER,
    x_prev_obligation_pymt_amt          IN     NUMBER,
    x_obligation_pymt_adj_amt           IN     NUMBER,
    x_curr_obligation_pymt_amt          IN     NUMBER,
    x_ytd_total_recp                    IN     NUMBER,
    x_ytd_accepted_disb_amt             IN     NUMBER,
    x_ytd_posted_disb_amt               IN     NUMBER,
    x_ytd_admin_cost_allowance          IN     NUMBER,
    x_caps_drwn_dn_pymts                IN     NUMBER,
    x_gaps_last_date                    IN     DATE,
    x_last_pymt_number                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 09-JAN-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_gr_elec_stat_sum_all
      WHERE    ess_id                            = x_ess_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_ess_id,
        x_rep_pell_id,
        x_duns_id,
        x_gaps_award_num,
        x_acct_schedule_number,
        x_acct_schedule_date,
        x_prev_obligation_amt,
        x_obligation_adj_amt,
        x_curr_obligation_amt,
        x_prev_obligation_pymt_amt,
        x_obligation_pymt_adj_amt,
        x_curr_obligation_pymt_amt,
        x_ytd_total_recp,
        x_ytd_accepted_disb_amt,
        x_ytd_posted_disb_amt,
        x_ytd_admin_cost_allowance,
        x_caps_drwn_dn_pymts,
        x_gaps_last_date,
        x_last_pymt_number,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_ess_id,
      x_rep_pell_id,
      x_duns_id,
      x_gaps_award_num,
      x_acct_schedule_number,
      x_acct_schedule_date,
      x_prev_obligation_amt,
      x_obligation_adj_amt,
      x_curr_obligation_amt,
      x_prev_obligation_pymt_amt,
      x_obligation_pymt_adj_amt,
      x_curr_obligation_pymt_amt,
      x_ytd_total_recp,
      x_ytd_accepted_disb_amt,
      x_ytd_posted_disb_amt,
      x_ytd_admin_cost_allowance,
      x_caps_drwn_dn_pymts,
      x_gaps_last_date,
      x_last_pymt_number,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 09-JAN-2001
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

    DELETE FROM igf_gr_elec_stat_sum_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_gr_elec_stat_sum_pkg;

/
