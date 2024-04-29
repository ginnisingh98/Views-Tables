--------------------------------------------------------
--  DDL for Package Body IGF_AW_COA_GROUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_COA_GROUP_PKG" AS
/* $Header: IGFWI05B.pls 115.17 2002/11/28 14:37:26 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igf_aw_coa_group_all%ROWTYPE;
  new_references igf_aw_coa_group_all%ROWTYPE;

PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_rule_order                        IN     NUMBER,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_pell_coa                          IN     NUMBER,
    x_pell_alt_exp                      IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_coa_grp_desc                      IN     VARCHAR2
  ) AS
--
--    Created By : adhawan
--    Created On : 30-NOV-2000
--    Purpose : Initialises the Old and New references for the columns of the table.
--    Known limitations, enhancements or remarks :
--    Change History :
--    Who             When            What
--    (reverse chronological order - newest change first)
--

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AW_COA_GROUP_ALL
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
    new_references.coa_code                          := x_coa_code;
    new_references.ci_cal_type                       := x_ci_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.rule_order                        := x_rule_order;
    new_references.s_rule_call_cd                    := x_s_rule_call_cd;
    new_references.rul_sequence_number               := x_rul_sequence_number;
    new_references.pell_coa                          := x_pell_coa;
    new_references.pell_alt_exp                      := x_pell_alt_exp;
    new_references.coa_grp_desc                      := x_coa_grp_desc;

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
--
--    Created By : adhawan
--    Created On : 30-NOV-2000
--    Purpose : Initialises the Old and New references for the columns of the table.
--    Known limitations, enhancements or remarks :
--    Change History :
--    Who             When            What
--    (reverse chronological order - newest change first)
--
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

END check_parent_existance;


PROCEDURE check_child_existance IS
--
--    Created By : adhawan
--    Created On : 30-NOV-2000
--    Purpose : Initialises the Old and New references for the columns of the table.
--    Known limitations, enhancements or remarks :
--    Change History :
--    Who             When            What
--    (reverse chronological order - newest change first)
--

BEGIN

    igf_aw_coa_grp_item_pkg.get_fk_igf_aw_coa_group (
      old_references.coa_code,
      old_references.ci_cal_type,
      old_references.ci_sequence_number
    );

   igf_aw_coa_ld_pkg.get_fk_igf_aw_coa_group (
      old_references.coa_code,
      old_references.ci_cal_type,
      old_references.ci_sequence_number
    );
END check_child_existance;


FUNCTION get_pk_for_validation (
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER
  ) RETURN BOOLEAN AS
--
--    Created By : adhawan
--    Created On : 30-NOV-2000
--    Purpose : Initialises the Old and New references for the columns of the table.
--    Known limitations, enhancements or remarks :
--    Change History :
--    Who             When            What
--    (reverse chronological order - newest change first)
--

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_coa_group_all
      WHERE    upper(coa_code) = upper(x_coa_code)
      AND      ci_cal_type = x_ci_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
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



PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) AS
--
--    Created By : adhawan
--    Created On : 30-NOV-2000
--    Purpose : Initialises the Old and New references for the columns of the table.
--    Known limitations, enhancements or remarks :
--    Change History :
--    Who             When            What
--    (reverse chronological order - newest change first)
--
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_coa_group_all
      WHERE   ((ci_cal_type = x_cal_type) AND
               (ci_sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_COAG_CI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

END get_fk_igs_ca_inst;


PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_rule_order                        IN     NUMBER,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_pell_coa                          IN     NUMBER,
    x_pell_alt_exp                      IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_coa_grp_desc                      IN     VARCHAR2
  ) AS

--
--    Created By : adhawan
--    Created On : 30-NOV-2000
--    Purpose : Initialises the Old and New references for the columns of the table.
--    Known limitations, enhancements or remarks :
--    Change History :
--    Who             When            What
--    (reverse chronological order - newest change first)
--

BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_coa_code,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_rule_order,
      x_s_rule_call_cd,
      x_rul_sequence_number,
      x_pell_coa,
      x_pell_alt_exp,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_coa_grp_desc
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.coa_code,
             new_references.ci_cal_type,
             new_references.ci_sequence_number
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
             new_references.coa_code,
             new_references.ci_cal_type,
             new_references.ci_sequence_number
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
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_rule_order                        IN     NUMBER,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_pell_coa                          IN     NUMBER,
    x_pell_alt_exp                      IN     NUMBER,
    x_coa_grp_desc                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS

--
--    Created By : adhawan
--    Created On : 30-NOV-2000
--    Purpose : Initialises the Old and New references for the columns of the table.
--    Known limitations, enhancements or remarks :
--    Change History :
--    Who             When            What
--    (reverse chronological order - newest change first)
--

    CURSOR c IS
      SELECT   rowid
      FROM     igf_aw_coa_group_all
      WHERE    coa_code                          = x_coa_code
      AND      ci_cal_type                       = x_ci_cal_type
      AND      ci_sequence_number                = x_ci_sequence_number;

    x_last_update_date      DATE;
    x_last_updated_by       NUMBER;
    x_last_update_login     NUMBER;
    l_org_id                igf_aw_coa_group_all.org_id%TYPE;

BEGIN

    l_org_id                := igf_aw_gen.get_org_id;

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
      x_coa_code                          => x_coa_code,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_rule_order                        => x_rule_order,
      x_s_rule_call_cd                    => x_s_rule_call_cd,
      x_rul_sequence_number               => x_rul_sequence_number,
      x_pell_coa                          => x_pell_coa,
      x_pell_alt_exp                      => x_pell_alt_exp,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_coa_grp_desc                      => x_coa_grp_desc
    );

    INSERT INTO igf_aw_coa_group(
      coa_code,
      ci_cal_type,
      ci_sequence_number,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      org_id,
      coa_grp_desc
    ) VALUES (
      new_references.coa_code,
      new_references.ci_cal_type,
      new_references.ci_sequence_number,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      l_org_id,
      new_references.coa_grp_desc
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
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_rule_order                        IN     NUMBER,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_pell_coa                          IN     NUMBER,
    x_pell_alt_exp                      IN     NUMBER,
    x_coa_grp_desc                      IN     VARCHAR2
  ) AS

--
--    Created By : adhawan
--    Created On : 30-NOV-2000
--    Purpose : Initialises the Old and New references for the columns of the table.
--    Known limitations, enhancements or remarks :
--    Change History :
--    Who             When            What
--    (reverse chronological order - newest change first)
--

    CURSOR c1 IS
      SELECT
        coa_grp_desc
      FROM  igf_aw_coa_group_all
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
        ((tlinfo.coa_grp_desc = x_coa_grp_desc) OR ((tlinfo.coa_grp_desc IS NULL) AND (x_coa_grp_desc IS NULL)))
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
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_rule_order                        IN     NUMBER,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_pell_coa                          IN     NUMBER,
    x_pell_alt_exp                      IN     NUMBER,
    x_coa_grp_desc                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS

--
--    Created By : adhawan
--    Created On : 30-NOV-2000
--    Purpose : Initialises the Old and New references for the columns of the table.
--    Known limitations, enhancements or remarks :
--    Change History :
--    Who             When            What
--    (reverse chronological order - newest change first)
--

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
      x_coa_code                          => x_coa_code,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_rule_order                        => x_rule_order,
      x_s_rule_call_cd                    => x_s_rule_call_cd,
      x_rul_sequence_number               => x_rul_sequence_number,
      x_pell_coa                          => x_pell_coa,
      x_pell_alt_exp                      => x_pell_alt_exp,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_coa_grp_desc                      => x_coa_grp_desc
    );

    UPDATE igf_aw_coa_group_all
      SET
        coa_grp_desc                      = new_references.coa_grp_desc,
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
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_rule_order                        IN     NUMBER,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_pell_coa                          IN     NUMBER,
    x_pell_alt_exp                      IN     NUMBER,
    x_coa_grp_desc                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS

--
--    Created By : adhawan
--    Created On : 30-NOV-2000
--    Purpose : Initialises the Old and New references for the columns of the table.
--    Known limitations, enhancements or remarks :
--    Change History :
--    Who             When            What
--    (reverse chronological order - newest change first)
--

    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_aw_coa_group_all
      WHERE    coa_code                          = x_coa_code
      AND      ci_cal_type                       = x_ci_cal_type
      AND      ci_sequence_number                = x_ci_sequence_number;

BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_coa_code,
        x_ci_cal_type,
        x_ci_sequence_number,
        x_rule_order,
        x_s_rule_call_cd,
        x_rul_sequence_number,
        x_pell_coa,
        x_pell_alt_exp,
        x_coa_grp_desc,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
        x_rowid,
        x_coa_code,
        x_ci_cal_type,
        x_ci_sequence_number,
        x_rule_order,
        x_s_rule_call_cd,
        x_rul_sequence_number,
        x_pell_coa,
        x_pell_alt_exp,
        x_coa_grp_desc,
        x_mode
      );

END add_row;


PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS

--
--    Created By : adhawan
--    Created On : 30-NOV-2000
--    Purpose : Initialises the Old and New references for the columns of the table.
--    Known limitations, enhancements or remarks :
--    Change History :
--    Who             When            What
--    (reverse chronological order - newest change first)
--

BEGIN

    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );

    DELETE FROM igf_aw_coa_group_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END delete_row;


END igf_aw_coa_group_pkg;

/
