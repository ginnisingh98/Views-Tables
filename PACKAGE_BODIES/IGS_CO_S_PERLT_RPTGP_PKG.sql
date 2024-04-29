--------------------------------------------------------
--  DDL for Package Body IGS_CO_S_PERLT_RPTGP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_S_PERLT_RPTGP_PKG" AS
/* $Header: IGSLI27B.pls 115.2 2002/11/29 01:08:45 nsidana noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_co_s_perlt_rptgp_all%ROWTYPE;
  new_references igs_co_s_perlt_rptgp_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_correspondence_type               IN     VARCHAR2    DEFAULT NULL,
    x_letter_reference_number           IN     NUMBER      DEFAULT NULL,
    x_spl_sequence_number               IN     NUMBER      DEFAULT NULL,
    x_letter_repeating_group_cd         IN     VARCHAR2    DEFAULT NULL,
    x_sequence_number                   IN     NUMBER      DEFAULT NULL,
    x_sup_repeating_group_cd            IN     VARCHAR2    DEFAULT NULL,
    x_sup_splrg_sequence_number         IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_CO_S_PERLT_RPTGP_ALL
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
    new_references.org_id                            := x_org_id;
    new_references.person_id                         := x_person_id;
    new_references.correspondence_type               := x_correspondence_type;
    new_references.letter_reference_number           := x_letter_reference_number;
    new_references.spl_sequence_number               := x_spl_sequence_number;
    new_references.letter_repeating_group_cd         := x_letter_repeating_group_cd;
    new_references.sequence_number                   := x_sequence_number;
    new_references.sup_repeating_group_cd            := x_sup_repeating_group_cd;
    new_references.sup_splrg_sequence_number         := x_sup_splrg_sequence_number;

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
    column_name    IN     VARCHAR2    DEFAULT NULL,
    column_value   IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the Check Constraint logic for the the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (column_name IS NULL) THEN
      NULL;
    ELSIF (UPPER(column_name) = 'SPL_SEQUENCE_NUMBER') THEN
      new_references.spl_sequence_number := igs_ge_number.to_num (column_value);
    ELSIF (UPPER(column_name) = 'SUP_SPLRG_SEQUENCE_NUMBER') THEN
      new_references.sup_splrg_sequence_number := igs_ge_number.to_num (column_value);
    END IF;

    IF (UPPER(column_name) = 'SPL_SEQUENCE_NUMBER' OR column_name IS NULL) THEN
      IF NOT (new_references.spl_sequence_number BETWEEN 1
              AND 9999999999)  THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF (UPPER(column_name) = 'SEQUENCE_NUMBER' OR column_name IS NULL) THEN
      IF NOT (new_references.sequence_number BETWEEN 1
              AND 9999999999)  THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF (UPPER(column_name) = 'SUP_SPLRG_SEQUENCE_NUMBER' OR column_name IS NULL) THEN
      IF NOT (new_references.sup_splrg_sequence_number BETWEEN 1
              AND 9999999999)  THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END check_constraints;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.correspondence_type = new_references.correspondence_type) AND
         (old_references.letter_reference_number = new_references.letter_reference_number) AND
         (old_references.spl_sequence_number = new_references.spl_sequence_number) AND
         (old_references.sup_repeating_group_cd = new_references.sup_repeating_group_cd) AND
         (old_references.sup_splrg_sequence_number = new_references.sup_splrg_sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.correspondence_type IS NULL) OR
         (new_references.letter_reference_number IS NULL) OR
         (new_references.spl_sequence_number IS NULL) OR
         (new_references.sup_repeating_group_cd IS NULL) OR
         (new_references.sup_splrg_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_co_s_perlt_rptgp_pkg.get_pk_for_validation (
                new_references.person_id,
                new_references.correspondence_type,
                new_references.letter_reference_number,
                new_references.spl_sequence_number,
                new_references.sup_repeating_group_cd,
                new_references.sup_splrg_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.correspondence_type = new_references.correspondence_type) AND
         (old_references.letter_reference_number = new_references.letter_reference_number) AND
         (old_references.spl_sequence_number = new_references.spl_sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.correspondence_type IS NULL) OR
         (new_references.letter_reference_number IS NULL) OR
         (new_references.spl_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_co_s_per_ltr_pkg.get_pk_for_validation (
                new_references.person_id,
                new_references.correspondence_type,
                new_references.letter_reference_number,
                new_references.spl_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.correspondence_type = new_references.correspondence_type) AND
         (old_references.letter_reference_number = new_references.letter_reference_number) AND
         (old_references.letter_repeating_group_cd = new_references.letter_repeating_group_cd)) OR
        ((new_references.correspondence_type IS NULL) OR
         (new_references.letter_reference_number IS NULL) OR
         (new_references.letter_repeating_group_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_co_ltr_rpt_grp_pkg.get_pk_for_validation (
                new_references.correspondence_type,
                new_references.letter_reference_number,
                new_references.letter_repeating_group_cd
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_co_s_perlt_rptgp_pkg.get_fk_igs_co_s_perlt_rptgp (
      old_references.person_id,
      old_references.correspondence_type,
      old_references.letter_reference_number,
      old_references.spl_sequence_number,
      old_references.letter_repeating_group_cd,
      old_references.sequence_number
    );

    igs_co_s_per_lt_parm_pkg.get_fk_igs_co_s_perlt_rptgp (
      old_references.person_id,
      old_references.correspondence_type,
      old_references.letter_reference_number,
      old_references.spl_sequence_number,
      old_references.letter_repeating_group_cd,
      old_references.sequence_number
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_spl_sequence_number               IN     NUMBER,
    x_letter_repeating_group_cd         IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_co_s_perlt_rptgp_all
      WHERE    person_id = x_person_id
      AND      correspondence_type = x_correspondence_type
      AND      letter_reference_number = x_letter_reference_number
      AND      spl_sequence_number = x_spl_sequence_number
      AND      letter_repeating_group_cd = x_letter_repeating_group_cd
      AND      sequence_number = x_sequence_number
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


  PROCEDURE get_fk_igs_co_s_perlt_rptgp (
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_spl_sequence_number               IN     NUMBER,
    x_letter_repeating_group_cd         IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_co_s_perlt_rptgp_all
      WHERE   ((person_id = x_person_id) AND
               (correspondence_type = x_correspondence_type) AND
               (letter_reference_number = x_letter_reference_number) AND
               (spl_sequence_number = x_spl_sequence_number) AND
               (sup_repeating_group_cd = x_letter_repeating_group_cd) AND
               (sup_splrg_sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_co_s_perlt_rptgp;


  PROCEDURE get_fk_igs_co_s_per_ltr (
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_co_s_perlt_rptgp_all
      WHERE   ((person_id = x_person_id) AND
               (correspondence_type = x_correspondence_type) AND
               (letter_reference_number = x_letter_reference_number) AND
               (spl_sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_co_s_per_ltr;


  PROCEDURE get_fk_igs_co_ltr_rpt_grp (
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_letter_repeating_group_cd         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_co_s_perlt_rptgp_all
      WHERE   ((correspondence_type = x_correspondence_type) AND
               (letter_reference_number = x_letter_reference_number) AND
               (letter_repeating_group_cd = x_letter_repeating_group_cd));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_co_ltr_rpt_grp;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_correspondence_type               IN     VARCHAR2    DEFAULT NULL,
    x_letter_reference_number           IN     NUMBER      DEFAULT NULL,
    x_spl_sequence_number               IN     NUMBER      DEFAULT NULL,
    x_letter_repeating_group_cd         IN     VARCHAR2    DEFAULT NULL,
    x_sequence_number                   IN     NUMBER      DEFAULT NULL,
    x_sup_repeating_group_cd            IN     VARCHAR2    DEFAULT NULL,
    x_sup_splrg_sequence_number         IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
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
      x_org_id,
      x_person_id,
      x_correspondence_type,
      x_letter_reference_number,
      x_spl_sequence_number,
      x_letter_repeating_group_cd,
      x_sequence_number,
      x_sup_repeating_group_cd,
      x_sup_splrg_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.person_id,
             new_references.correspondence_type,
             new_references.letter_reference_number,
             new_references.spl_sequence_number,
             new_references.letter_repeating_group_cd,
             new_references.sequence_number
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
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
             new_references.person_id,
             new_references.correspondence_type,
             new_references.letter_reference_number,
             new_references.spl_sequence_number,
             new_references.letter_repeating_group_cd,
             new_references.sequence_number
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
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
    x_org_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_spl_sequence_number               IN     NUMBER,
    x_letter_repeating_group_cd         IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_sup_repeating_group_cd            IN     VARCHAR2,
    x_sup_splrg_sequence_number         IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_co_s_perlt_rptgp_all
      WHERE    person_id                         = x_person_id
      AND      correspondence_type               = x_correspondence_type
      AND      letter_reference_number           = x_letter_reference_number
      AND      spl_sequence_number               = x_spl_sequence_number
      AND      letter_repeating_group_cd         = x_letter_repeating_group_cd
      AND      sequence_number                   = x_sequence_number;

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

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_org_id                            => igs_ge_gen_003.get_org_id,
      x_person_id                         => x_person_id,
      x_correspondence_type               => x_correspondence_type,
      x_letter_reference_number           => x_letter_reference_number,
      x_spl_sequence_number               => x_spl_sequence_number,
      x_letter_repeating_group_cd         => x_letter_repeating_group_cd,
      x_sequence_number                   => x_sequence_number,
      x_sup_repeating_group_cd            => x_sup_repeating_group_cd,
      x_sup_splrg_sequence_number         => x_sup_splrg_sequence_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_co_s_perlt_rptgp_all (
      org_id,
      person_id,
      correspondence_type,
      letter_reference_number,
      spl_sequence_number,
      letter_repeating_group_cd,
      sequence_number,
      sup_repeating_group_cd,
      sup_splrg_sequence_number,
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
      new_references.org_id,
      new_references.person_id,
      new_references.correspondence_type,
      new_references.letter_reference_number,
      new_references.spl_sequence_number,
      new_references.letter_repeating_group_cd,
      new_references.sequence_number,
      new_references.sup_repeating_group_cd,
      new_references.sup_splrg_sequence_number,
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
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_spl_sequence_number               IN     NUMBER,
    x_letter_repeating_group_cd         IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_sup_repeating_group_cd            IN     VARCHAR2,
    x_sup_splrg_sequence_number         IN     NUMBER
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
       sup_repeating_group_cd,
        sup_splrg_sequence_number
      FROM  igs_co_s_perlt_rptgp_all
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
         ((tlinfo.sup_repeating_group_cd = x_sup_repeating_group_cd) OR ((tlinfo.sup_repeating_group_cd IS NULL) AND (X_sup_repeating_group_cd IS NULL)))
        AND ((tlinfo.sup_splrg_sequence_number = x_sup_splrg_sequence_number) OR ((tlinfo.sup_splrg_sequence_number IS NULL) AND (X_sup_splrg_sequence_number IS NULL)))
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
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_spl_sequence_number               IN     NUMBER,
    x_letter_repeating_group_cd         IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_sup_repeating_group_cd            IN     VARCHAR2,
    x_sup_splrg_sequence_number         IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
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
      x_person_id                         => x_person_id,
      x_correspondence_type               => x_correspondence_type,
      x_letter_reference_number           => x_letter_reference_number,
      x_spl_sequence_number               => x_spl_sequence_number,
      x_letter_repeating_group_cd         => x_letter_repeating_group_cd,
      x_sequence_number                   => x_sequence_number,
      x_sup_repeating_group_cd            => x_sup_repeating_group_cd,
      x_sup_splrg_sequence_number         => x_sup_splrg_sequence_number,
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

    UPDATE igs_co_s_perlt_rptgp_all
      SET
        sup_repeating_group_cd            = new_references.sup_repeating_group_cd,
        sup_splrg_sequence_number         = new_references.sup_splrg_sequence_number,
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
    x_org_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_spl_sequence_number               IN     NUMBER,
    x_letter_repeating_group_cd         IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_sup_repeating_group_cd            IN     VARCHAR2,
    x_sup_splrg_sequence_number         IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_co_s_perlt_rptgp_all
      WHERE    person_id                         = x_person_id
      AND      correspondence_type               = x_correspondence_type
      AND      letter_reference_number           = x_letter_reference_number
      AND      spl_sequence_number               = x_spl_sequence_number
      AND      letter_repeating_group_cd         = x_letter_repeating_group_cd
      AND      sequence_number                   = x_sequence_number;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_org_id,
        x_person_id,
        x_correspondence_type,
        x_letter_reference_number,
        x_spl_sequence_number,
        x_letter_repeating_group_cd,
        x_sequence_number,
        x_sup_repeating_group_cd,
        x_sup_splrg_sequence_number,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_person_id,
      x_correspondence_type,
      x_letter_reference_number,
      x_spl_sequence_number,
      x_letter_repeating_group_cd,
      x_sequence_number,
      x_sup_repeating_group_cd,
      x_sup_splrg_sequence_number,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
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

    DELETE FROM igs_co_s_perlt_rptgp_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_co_s_perlt_rptgp_pkg;

/
