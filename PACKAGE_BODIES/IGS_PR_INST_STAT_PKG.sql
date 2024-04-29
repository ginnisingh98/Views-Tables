--------------------------------------------------------
--  DDL for Package Body IGS_PR_INST_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_INST_STAT_PKG" AS
/* $Header: IGSQI34B.pls 115.6 2003/05/16 12:46:26 kdande noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pr_inst_stat%ROWTYPE;
  new_references igs_pr_inst_stat%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_display_order                     IN     NUMBER,
    x_timeframe                         IN     VARCHAR2,
    x_standard_ind                      IN     VARCHAR2,
    x_display_ind                       IN     VARCHAR2,
    x_include_standard_ind              IN     VARCHAR2,
    x_include_local_ind                 IN     VARCHAR2,
    x_include_other_ind                 IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : nbehera
  ||  Created On : 02-NOV-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pr_inst_stat
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
    new_references.stat_type                         := x_stat_type;
    new_references.display_order                     := x_display_order;
    new_references.timeframe                         := x_timeframe;
    new_references.standard_ind                      := x_standard_ind;
    new_references.display_ind                       := x_display_ind;
    new_references.include_standard_ind              := x_include_standard_ind;
    new_references.include_local_ind                 := x_include_local_ind;
    new_references.include_other_ind                 := x_include_other_ind;

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

  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : nbehera
  ||  Created On : 22-NOV-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
	||  Nalin Kumar     27-Dec-2002     Changed the message from 'IGS_GE_RECORD_ALREADY_EXISTS'
	||                                  to 'IGS_PR_DUP_DIS_ORD'. This is to fix Bug# 2547513.
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.display_order
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_PR_DUP_DIS_ORD');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : nbehera
  ||  Created On : 02-NOV-2001
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

  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : nbehera
  ||  Created On : 02-NOV-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

     igs_pr_inst_sta_ref_pkg.get_fk_igs_pr_inst_stat (
      old_references.stat_type
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_stat_type                         IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : nbehera
  ||  Created On : 02-NOV-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_inst_stat
      WHERE    stat_type = x_stat_type
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
    x_display_order                     IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : nbehera
  ||  Created On : 22-NOV-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_inst_stat
      WHERE    display_order = x_display_order
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

  PROCEDURE get_fk_igs_pr_stat_type (
    x_stat_type                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : nbehera
  ||  Created On : 02-NOV-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_inst_stat
      WHERE   ((stat_type = x_stat_type));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PR_INST_STTY_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pr_stat_type;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_display_order                     IN     NUMBER,
    x_timeframe                         IN     VARCHAR2,
    x_standard_ind                      IN     VARCHAR2,
    x_display_ind                       IN     VARCHAR2,
    x_include_standard_ind              IN     VARCHAR2,
    x_include_local_ind                 IN     VARCHAR2,
    x_include_other_ind                 IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : nbehera
  ||  Created On : 02-NOV-2001
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
      x_stat_type,
      x_display_order,
      x_timeframe,
      x_standard_ind,
      x_display_ind,
      x_include_standard_ind,
      x_include_local_ind,
      x_include_other_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.stat_type
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
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
      IF ( get_pk_for_validation (
             new_references.stat_type
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

/*
The (L_ROWID := null) was added by ijeddy on the 12-apr-2003 as
part of the bug fix for bug no 2868726, (Uniqueness Check at Item Level)
*/

L_ROWID := null;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_display_order                     IN     NUMBER,
    x_timeframe                         IN     VARCHAR2,
    x_standard_ind                      IN     VARCHAR2,
    x_display_ind                       IN     VARCHAR2,
    x_include_standard_ind              IN     VARCHAR2,
    x_include_local_ind                 IN     VARCHAR2,
    x_include_other_ind                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : nbehera
  ||  Created On : 02-NOV-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_pr_inst_stat
      WHERE    stat_type                         = x_stat_type;

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
      x_stat_type                         => x_stat_type,
      x_display_order                     => x_display_order,
      x_timeframe                         => x_timeframe,
      x_standard_ind                      => x_standard_ind,
      x_display_ind                       => x_display_ind,
      x_include_standard_ind              => x_include_standard_ind,
      x_include_local_ind                 => x_include_local_ind,
      x_include_other_ind                 => x_include_other_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_pr_inst_stat (
      stat_type,
      display_order,
      timeframe,
      standard_ind,
      display_ind,
      include_standard_ind,
      include_local_ind,
      include_other_ind,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.stat_type,
      new_references.display_order,
      new_references.timeframe,
      new_references.standard_ind,
      new_references.display_ind,
      new_references.include_standard_ind,
      new_references.include_local_ind,
      new_references.include_other_ind,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;
    after_dml;
  END insert_row;

  PROCEDURE after_dml AS
  /*
  ||  Created By : nbehera
  ||  Created On : 15-NOV-2001
  ||  Purpose : Checks for more than one statistic Type with the same indicator
  ||    set cannot exist with the same Timeframe or if either has a
  ||    Timeframe 'BOTH'.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  kdande   20-Sep-2002 Removed the references to columns progression_ind and fin_aid_ind
  ||                       from the c1 and removed the cursors c3, c4 and their usage for Bug# 2560160.
  */

  CURSOR c1 IS
  SELECT   inst.timeframe,
           inst.standard_ind
  FROM     igs_pr_inst_stat  inst
  WHERE    inst.standard_ind = 'Y';

  CURSOR c2 IS
  SELECT   inst.timeframe
  FROM     igs_pr_inst_stat  inst
  WHERE    inst.standard_ind = 'Y'
  GROUP BY inst.timeframe
  HAVING   COUNT(inst.timeframe) > 1;

  l_c1_rec c1%ROWTYPE;
  l_std_ind     VARCHAR2(1) :='N';
  dummy         VARCHAR2(50);
  l_both_std_flag   VARCHAR2(1) :='N';

 BEGIN

  FOR l_c1_rec IN c1 LOOP
        IF l_c1_rec.standard_ind = 'Y' THEN
                IF l_std_ind = 'N' THEN
                        l_std_ind := 'Y';
                        IF l_c1_rec.timeframe = 'BOTH' THEN
                                l_both_std_flag := 'Y';
                        END IF;
                ELSIF l_std_ind = 'Y'
                  AND (l_c1_rec.timeframe = 'BOTH'
                       OR l_both_std_flag ='Y' )        THEN
                        fnd_message.set_name ('IGS','IGS_PR_STAT_TYPE_IND');
                        FND_MESSAGE.SET_TOKEN('STATTYPE_IND','Standard');
                        igs_ge_msg_stack.add;
                        app_exception.raise_exception;
                END IF;
        END IF;
  END LOOP;

  OPEN c2;
  FETCH c2 INTO dummy;
  IF c2%FOUND THEN
                fnd_message.set_name ('IGS','IGS_PR_STAT_TYPE_IND');
                FND_MESSAGE.SET_TOKEN('STATTYPE_IND','Standard');
                igs_ge_msg_stack.add;
                app_exception.raise_exception;
  END IF;
  CLOSE c2;

/*
The (L_ROWID := null) was added by ijeddy on the 12-apr-2003 as
part of the bug fix for bug no 2868726, (Uniqueness Check at Item Level)
*/

L_ROWID := null;

  END after_dml;

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_display_order                     IN     NUMBER,
    x_timeframe                         IN     VARCHAR2,
    x_standard_ind                      IN     VARCHAR2,
    x_display_ind                       IN     VARCHAR2,
    x_include_standard_ind              IN     VARCHAR2,
    x_include_local_ind                 IN     VARCHAR2,
    x_include_other_ind                 IN     VARCHAR2
  ) AS
  /*
  ||  Created By : nbehera
  ||  Created On : 02-NOV-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  || Who      When        What
  || (reverse chronological order - newest change first)
  || kdande   23-Sep-2002 Obsoleted the columns progression_ind, fin_aid_ind
  ||                      as per bug# 2560160 and removed the code from locking.
  */
    CURSOR c1 IS
      SELECT
        display_order,
        timeframe,
        standard_ind,
        display_ind,
        include_standard_ind,
        include_local_ind,
        include_other_ind
      FROM  igs_pr_inst_stat
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
        (tlinfo.display_order = x_display_order)
        AND (tlinfo.timeframe = x_timeframe)
        AND (tlinfo.standard_ind = x_standard_ind)
        AND (tlinfo.display_ind = x_display_ind)
        AND (tlinfo.include_standard_ind = x_include_standard_ind)
        AND (tlinfo.include_local_ind = x_include_local_ind)
        AND (tlinfo.include_other_ind = x_include_other_ind)
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
    x_stat_type                         IN     VARCHAR2,
    x_display_order                     IN     NUMBER,
    x_timeframe                         IN     VARCHAR2,
    x_standard_ind                      IN     VARCHAR2,
    x_display_ind                       IN     VARCHAR2,
    x_include_standard_ind              IN     VARCHAR2,
    x_include_local_ind                 IN     VARCHAR2,
    x_include_other_ind                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : nbehera
  ||  Created On : 02-NOV-2001
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
      x_stat_type                         => x_stat_type,
      x_display_order                     => x_display_order,
      x_timeframe                         => x_timeframe,
      x_standard_ind                      => x_standard_ind,
      x_display_ind                       => x_display_ind,
      x_include_standard_ind              => x_include_standard_ind,
      x_include_local_ind                 => x_include_local_ind,
      x_include_other_ind                 => x_include_other_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_pr_inst_stat
      SET
        display_order                     = new_references.display_order,
        timeframe                         = new_references.timeframe,
        standard_ind                      = new_references.standard_ind,
        display_ind                       = new_references.display_ind,
        include_standard_ind              = new_references.include_standard_ind,
        include_local_ind                 = new_references.include_local_ind,
        include_other_ind                 = new_references.include_other_ind,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
    after_dml;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_display_order                     IN     NUMBER,
    x_timeframe                         IN     VARCHAR2,
    x_standard_ind                      IN     VARCHAR2,
    x_display_ind                       IN     VARCHAR2,
    x_include_standard_ind              IN     VARCHAR2,
    x_include_local_ind                 IN     VARCHAR2,
    x_include_other_ind                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : nbehera
  ||  Created On : 02-NOV-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pr_inst_stat
      WHERE    stat_type                         = x_stat_type;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_stat_type,
        x_display_order,
        x_timeframe,
        x_standard_ind,
        x_display_ind,
        x_include_standard_ind,
        x_include_local_ind,
        x_include_other_ind,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_stat_type,
      x_display_order,
      x_timeframe,
      x_standard_ind,
      x_display_ind,
      x_include_standard_ind,
      x_include_local_ind,
      x_include_other_ind,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : nbehera
  ||  Created On : 02-NOV-2001
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

    DELETE FROM igs_pr_inst_stat
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_pr_inst_stat_pkg;

/
