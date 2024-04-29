--------------------------------------------------------
--  DDL for Package Body IGS_PR_COHORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_COHORT_PKG" AS
/* $Header: IGSQI41B.pls 115.4 2002/11/29 03:25:25 nsidana noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pr_cohort%ROWTYPE;
  new_references igs_pr_cohort%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_cohort_name                       IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_dflt_display_type                 IN     VARCHAR2,
    x_dense_rank_ind                    IN     VARCHAR2,
    x_incl_on_transcript_ind            IN     VARCHAR2,
    x_incl_on_stud_acad_hist_ind        IN     VARCHAR2,
    x_rule_sequence_number              IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pr_cohort
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
    new_references.cohort_name                       := x_cohort_name;
    new_references.description                       := x_description;
    new_references.org_unit_cd                       := x_org_unit_cd;
    new_references.stat_type                         := x_stat_type;
    new_references.timeframe                         := x_timeframe;
    new_references.dflt_display_type                 := x_dflt_display_type;
    new_references.dense_rank_ind                    := x_dense_rank_ind;
    new_references.incl_on_transcript_ind            := x_incl_on_transcript_ind;
    new_references.incl_on_stud_acad_hist_ind        := x_incl_on_stud_acad_hist_ind;
    new_references.rule_sequence_number              := x_rule_sequence_number;
    new_references.closed_ind                        := x_closed_ind;

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


  PROCEDURE check_constraints (
    column_name    IN     VARCHAR2,
    column_value   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
  ||  Purpose : Handles the Check Constraint logic for the the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (column_name IS NULL) THEN
      NULL;
    ELSIF (UPPER(column_name) = 'DENSE_RANK_IND') THEN
      new_references.dense_rank_ind := column_value;
    ELSIF (UPPER(column_name) = 'INCL_ON_TRANSCRIPT_IND') THEN
      new_references.incl_on_transcript_ind := column_value;
    ELSIF (UPPER(column_name) = 'INCL_ON_STUD_ACAD_HIST_IND') THEN
      new_references.incl_on_stud_acad_hist_ind := column_value;
    END IF;

    IF (UPPER(column_name) = 'DENSE_RANK_IND' OR column_name IS NULL) THEN
      IF NOT (new_references.dense_rank_ind  IN ('Y','N'))  THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF (UPPER(column_name) = 'INCL_ON_TRANSCRIPT_IND' OR column_name IS NULL) THEN
      IF NOT (new_references.incl_on_transcript_ind IN ('Y','N'))  THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF (UPPER(column_name) = 'INCL_ON_STUD_ACAD_HIST_IND' OR column_name IS NULL) THEN
      IF NOT (new_references.incl_on_stud_acad_hist_ind IN ('Y','N'))  THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END check_constraints;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.stat_type = new_references.stat_type)) OR
        ((new_references.stat_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pr_stat_type_pkg.get_pk_for_validation (
                new_references.stat_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.rule_sequence_number = new_references.rule_sequence_number)) OR
        ((new_references.rule_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ru_rule_pkg.get_pk_for_validation (
                new_references.rule_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_pr_cohort_inst_pkg.get_fk_igs_pr_cohort (
      old_references.cohort_name
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_cohort_name                       IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_cohort
      WHERE    cohort_name = x_cohort_name
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

  PROCEDURE get_fk_igs_pr_stat_type (
    x_stat_type                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_cohort
      WHERE   ((stat_type = x_stat_type));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PR_COH_STAT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pr_stat_type;


  PROCEDURE get_fk_igs_ru_rule (
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_cohort
      WHERE   ((rule_sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PR_COH_RU_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ru_rule;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_cohort_name                       IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_dflt_display_type                 IN     VARCHAR2,
    x_dense_rank_ind                    IN     VARCHAR2,
    x_incl_on_transcript_ind            IN     VARCHAR2,
    x_incl_on_stud_acad_hist_ind        IN     VARCHAR2,
    x_rule_sequence_number              IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
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
      x_cohort_name,
      x_description,
      x_org_unit_cd,
      x_stat_type,
      x_timeframe,
      x_dflt_display_type,
      x_dense_rank_ind,
      x_incl_on_transcript_ind,
      x_incl_on_stud_acad_hist_ind,
      x_rule_sequence_number,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.cohort_name
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.cohort_name
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cohort_name                       IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_dflt_display_type                 IN     VARCHAR2,
    x_dense_rank_ind                    IN     VARCHAR2,
    x_incl_on_transcript_ind            IN     VARCHAR2,
    x_incl_on_stud_acad_hist_ind        IN     VARCHAR2,
    x_rule_sequence_number              IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

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

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_cohort_name                       => x_cohort_name,
      x_description                       => x_description,
      x_org_unit_cd                       => x_org_unit_cd,
      x_stat_type                         => x_stat_type,
      x_timeframe                         => x_timeframe,
      x_dflt_display_type                 => x_dflt_display_type,
      x_dense_rank_ind                    => x_dense_rank_ind,
      x_incl_on_transcript_ind            => x_incl_on_transcript_ind,
      x_incl_on_stud_acad_hist_ind        => x_incl_on_stud_acad_hist_ind,
      x_rule_sequence_number              => x_rule_sequence_number,
      x_closed_ind                        => x_closed_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_pr_cohort (
      cohort_name,
      description,
      org_unit_cd,
      stat_type,
      timeframe,
      dflt_display_type,
      dense_rank_ind,
      incl_on_transcript_ind,
      incl_on_stud_acad_hist_ind,
      rule_sequence_number,
      closed_ind,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.cohort_name,
      new_references.description,
      new_references.org_unit_cd,
      new_references.stat_type,
      new_references.timeframe,
      new_references.dflt_display_type,
      new_references.dense_rank_ind,
      new_references.incl_on_transcript_ind,
      new_references.incl_on_stud_acad_hist_ind,
      new_references.rule_sequence_number,
      new_references.closed_ind,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_cohort_name                       IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_dflt_display_type                 IN     VARCHAR2,
    x_dense_rank_ind                    IN     VARCHAR2,
    x_incl_on_transcript_ind            IN     VARCHAR2,
    x_incl_on_stud_acad_hist_ind        IN     VARCHAR2,
    x_rule_sequence_number              IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        description,
        org_unit_cd,
        stat_type,
        timeframe,
        dflt_display_type,
        dense_rank_ind,
        incl_on_transcript_ind,
        incl_on_stud_acad_hist_ind,
        rule_sequence_number,
        closed_ind
      FROM  igs_pr_cohort
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
        (tlinfo.description = x_description)
        AND ((tlinfo.org_unit_cd = x_org_unit_cd) OR ((tlinfo.org_unit_cd IS NULL) AND (X_org_unit_cd IS NULL)))
        AND (tlinfo.stat_type = x_stat_type)
        AND (tlinfo.timeframe = x_timeframe)
        AND (tlinfo.dflt_display_type = x_dflt_display_type)
        AND (tlinfo.dense_rank_ind = x_dense_rank_ind)
        AND (tlinfo.incl_on_transcript_ind = x_incl_on_transcript_ind)
        AND (tlinfo.incl_on_stud_acad_hist_ind = x_incl_on_stud_acad_hist_ind)
        AND ((tlinfo.rule_sequence_number = x_rule_sequence_number) OR ((tlinfo.rule_sequence_number IS NULL) AND (X_rule_sequence_number IS NULL)))
        AND (tlinfo.closed_ind = x_closed_ind)
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
    x_cohort_name                       IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_dflt_display_type                 IN     VARCHAR2,
    x_dense_rank_ind                    IN     VARCHAR2,
    x_incl_on_transcript_ind            IN     VARCHAR2,
    x_incl_on_stud_acad_hist_ind        IN     VARCHAR2,
    x_rule_sequence_number              IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
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
      x_cohort_name                       => x_cohort_name,
      x_description                       => x_description,
      x_org_unit_cd                       => x_org_unit_cd,
      x_stat_type                         => x_stat_type,
      x_timeframe                         => x_timeframe,
      x_dflt_display_type                 => x_dflt_display_type,
      x_dense_rank_ind                    => x_dense_rank_ind,
      x_incl_on_transcript_ind            => x_incl_on_transcript_ind,
      x_incl_on_stud_acad_hist_ind        => x_incl_on_stud_acad_hist_ind,
      x_rule_sequence_number              => x_rule_sequence_number,
      x_closed_ind                        => x_closed_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_pr_cohort
      SET
        description                       = new_references.description,
        org_unit_cd                       = new_references.org_unit_cd,
        stat_type                         = new_references.stat_type,
        timeframe                         = new_references.timeframe,
        dflt_display_type                 = new_references.dflt_display_type,
        dense_rank_ind                    = new_references.dense_rank_ind,
        incl_on_transcript_ind            = new_references.incl_on_transcript_ind,
        incl_on_stud_acad_hist_ind        = new_references.incl_on_stud_acad_hist_ind,
        rule_sequence_number              = new_references.rule_sequence_number,
        closed_ind                        = new_references.closed_ind,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cohort_name                       IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_dflt_display_type                 IN     VARCHAR2,
    x_dense_rank_ind                    IN     VARCHAR2,
    x_incl_on_transcript_ind            IN     VARCHAR2,
    x_incl_on_stud_acad_hist_ind        IN     VARCHAR2,
    x_rule_sequence_number              IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pr_cohort
      WHERE    cohort_name                       = x_cohort_name;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_cohort_name,
        x_description,
        x_org_unit_cd,
        x_stat_type,
        x_timeframe,
        x_dflt_display_type,
        x_dense_rank_ind,
        x_incl_on_transcript_ind,
        x_incl_on_stud_acad_hist_ind,
        x_rule_sequence_number,
        x_closed_ind,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_cohort_name,
      x_description,
      x_org_unit_cd,
      x_stat_type,
      x_timeframe,
      x_dflt_display_type,
      x_dense_rank_ind,
      x_incl_on_transcript_ind,
      x_incl_on_stud_acad_hist_ind,
      x_rule_sequence_number,
      x_closed_ind,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
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

    DELETE FROM igs_pr_cohort
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_pr_cohort_pkg;

/
