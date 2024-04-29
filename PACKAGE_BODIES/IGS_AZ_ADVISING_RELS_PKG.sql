--------------------------------------------------------
--  DDL for Package Body IGS_AZ_ADVISING_RELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AZ_ADVISING_RELS_PKG" AS
/* $Header: IGSHI04B.pls 115.2 2003/06/16 09:56:50 anilk noship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_AZ_ADVISING_RELS%ROWTYPE;
  new_references IGS_AZ_ADVISING_RELS%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_group_advising_rel_id             IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_group_advisor_id                  IN     NUMBER,
    x_group_student_id                  IN     NUMBER,
    x_START_DATE                          IN     DATE,
    x_END_DATE                            IN     DATE,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AZ_ADVISING_RELS
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
    new_references.group_advising_rel_id             := x_group_advising_rel_id;
    new_references.group_name                        := x_group_name;
    new_references.group_advisor_id                  := x_group_advisor_id;
    new_references.group_student_id                  := x_group_student_id;
    new_references.START_DATE                          := TRUNC(x_START_DATE);
    new_references.END_DATE                            := TRUNC(x_END_DATE);

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
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.group_name,
           new_references.group_advisor_id,
           new_references.group_student_id
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.group_name = new_references.group_name)) OR
        ((new_references.group_name IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AZ_GROUPS_pkg.get_pk_for_validation (
                new_references.group_name
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.group_student_id = new_references.group_student_id)) OR
        ((new_references.group_student_id IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AZ_STUDENTS_pkg.get_pk_for_validation (
                new_references.group_student_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.group_advisor_id = new_references.group_advisor_id)) OR
        ((new_references.group_advisor_id IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AZ_ADVISORS_pkg.get_pk_for_validation (
                new_references.group_advisor_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_group_advising_rel_id             IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AZ_ADVISING_RELS
      WHERE    group_advising_rel_id = x_group_advising_rel_id
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
    x_group_name                        IN     VARCHAR2,
    x_group_advisor_id                  IN     NUMBER,
    x_group_student_id                  IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AZ_ADVISING_RELS
      WHERE    group_name = x_group_name
      AND      group_advisor_id = x_group_advisor_id
      AND      group_student_id = x_group_student_id
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


  PROCEDURE get_fk_IGS_AZ_GROUPS (
    x_group_name                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AZ_ADVISING_RELS
      WHERE   ((group_name = x_group_name));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FOREIGN_KEY_REFERENCE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_IGS_AZ_GROUPS;


  PROCEDURE get_fk_IGS_AZ_STUDENTS (
    x_group_student_id                  IN     NUMBER
  ) AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AZ_ADVISING_RELS
      WHERE   ((group_student_id = x_group_student_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FOREIGN_KEY_REFERENCE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_IGS_AZ_STUDENTS;


  PROCEDURE get_fk_IGS_AZ_ADVISORS (
    x_group_advisor_id                  IN     NUMBER
  ) AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AZ_ADVISING_RELS
      WHERE   ((group_advisor_id = x_group_advisor_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FOREIGN_KEY_REFERENCE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_IGS_AZ_ADVISORS;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_group_advising_rel_id             IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_group_advisor_id                  IN     NUMBER,
    x_group_student_id                  IN     NUMBER,
    x_START_DATE                          IN     DATE,
    x_END_DATE                            IN     DATE,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
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
      x_group_advising_rel_id,
      x_group_name,
      x_group_advisor_id,
      x_group_student_id,
      x_START_DATE,
      x_END_DATE,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.group_advising_rel_id
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
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.group_advising_rel_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_group_advising_rel_id             IN OUT NOCOPY NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_group_advisor_id                  IN     NUMBER,
    x_group_student_id                  IN     NUMBER,
    x_START_DATE                          IN     DATE,
    x_END_DATE                            IN     DATE,
    x_mode                              IN     VARCHAR2,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  ) AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
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
   FND_MSG_PUB.initialize;
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
      fnd_message.set_token ('ROUTINE', 'IGS_AZ_ADVISING_RELS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_group_advising_rel_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_group_advising_rel_id             => x_group_advising_rel_id,
      x_group_name                        => x_group_name,
      x_group_advisor_id                  => x_group_advisor_id,
      x_group_student_id                  => x_group_student_id,
      x_START_DATE                          => x_START_DATE,
      x_END_DATE                            => x_END_DATE,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO IGS_AZ_ADVISING_RELS (
      group_advising_rel_id,
      group_name,
      group_advisor_id,
      group_student_id,
      START_DATE,
      END_DATE,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      IGS_AZ_ADVISING_RELS_s.NEXTVAL,
      new_references.group_name,
      new_references.group_advisor_id,
      new_references.group_student_id,
      TRUNC(new_references.START_DATE),
      TRUNC(new_references.END_DATE),
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, group_advising_rel_id INTO x_rowid, x_group_advising_rel_id;
  -- Standard call to get message count and if count is 1, get message
  -- info.
     FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_MSG_COUNT,
                p_data  => X_MSG_DATA);
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get(
                     p_encoded => FND_API.G_FALSE,
                     p_count => x_MSG_COUNT,
                     p_data  => X_MSG_DATA);
     RETURN;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
                    FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_MSG_COUNT,
                        p_data  => X_MSG_DATA);
     RETURN;
        WHEN OTHERS THEN
             X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
             FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
             FND_MESSAGE.SET_TOKEN('NAME','Insert_Row : '||SQLERRM);
             FND_MSG_PUB.ADD;
             FND_MSG_PUB.Count_And_Get(
                               p_encoded => FND_API.G_FALSE,
                               p_count => x_MSG_COUNT,
                               p_data  => X_MSG_DATA);
     RETURN;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_group_advising_rel_id             IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_group_advisor_id                  IN     NUMBER,
    x_group_student_id                  IN     NUMBER,
    x_START_DATE                          IN     DATE,
    x_END_DATE                            IN     DATE,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  ) AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        group_name,
        group_advisor_id,
        group_student_id,
        START_DATE,
        END_DATE
      FROM  IGS_AZ_ADVISING_RELS
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN
    FND_MSG_PUB.initialize;
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
        (tlinfo.group_name = x_group_name)
        AND (tlinfo.group_advisor_id = x_group_advisor_id)
        AND (tlinfo.group_student_id = x_group_student_id)
        AND ((TRUNC(tlinfo.START_DATE) = TRUNC(x_START_DATE)) OR ((tlinfo.START_DATE IS NULL) AND (X_START_DATE IS NULL)))
        AND ((TRUNC(tlinfo.END_DATE) = TRUNC(x_END_DATE)) OR ((tlinfo.END_DATE IS NULL) AND (X_END_DATE IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
  -- Initialize API return status to success.
     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to get message count and if count is 1, get message
  -- info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_MSG_COUNT,
                p_data  => X_MSG_DATA);
     RETURN;
 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                 p_encoded => FND_API.G_FALSE,
                 p_count => x_MSG_COUNT,
                 p_data  => X_MSG_DATA);
 RETURN;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_MSG_COUNT,
                    p_data  => X_MSG_DATA);
 RETURN;
  WHEN OTHERS THEN
         X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
         FND_MESSAGE.SET_TOKEN('NAME','Insert_Row : '||SQLERRM);
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get(
                           p_encoded => FND_API.G_FALSE,
                           p_count => x_MSG_COUNT,
                           p_data  => X_MSG_DATA);
 RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_group_advising_rel_id             IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_group_advisor_id                  IN     NUMBER,
    x_group_student_id                  IN     NUMBER,
    x_START_DATE                          IN     DATE,
    x_END_DATE                            IN     DATE,
    x_mode                              IN     VARCHAR2,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  ) AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
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
    FND_MSG_PUB.initialize;
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
      fnd_message.set_token ('ROUTINE', 'IGS_AZ_ADVISING_RELS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  --  x_group_advising_rel_id := NULL;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_group_advising_rel_id             => X_group_advising_rel_id,
      x_group_name                        => x_group_name,
      x_group_advisor_id                  => x_group_advisor_id,
      x_group_student_id                  => x_group_student_id,
      x_START_DATE                          => x_START_DATE,
      x_END_DATE                            => x_END_DATE,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

--
-- The logic that if the user has de selected a record from being matched, the the row should be deleted from the database.
-- Normally when a record is created for adding the suggested matches, it will be created with start date as null and if..
-- and the null start date records will be displayed to the users for suggested matches. If the user sdeselects them
-- frombeing accepted then delete the record. these may be again created with null start date when job is run.

--IF    new_references.START_DATE IS NULL THEN
 -- DELETE_ROW(x_rowid, X_RETURN_STATUS,  X_MSG_DATA, X_MSG_COUNT);
--ELSE

    UPDATE IGS_AZ_ADVISING_RELS
      SET
        group_name                        = new_references.group_name,
        group_advisor_id                  = new_references.group_advisor_id,
        group_student_id                  = new_references.group_student_id,
        START_DATE                          = TRUNC(new_references.START_DATE),
        END_DATE                            = TRUNC(new_references.END_DATE),
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;
--END IF;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
 -- Initialize API return status to success.
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to get message count and if count is 1, get message
  -- info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_MSG_COUNT,
                p_data  => X_MSG_DATA);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(
                   p_encoded => FND_API.G_FALSE,
                   p_count => x_MSG_COUNT,
                   p_data  => X_MSG_DATA);
   RETURN;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                  X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
                  FND_MSG_PUB.Count_And_Get(
                      p_encoded => FND_API.G_FALSE,
                      p_count => x_MSG_COUNT,
                      p_data  => X_MSG_DATA);
   RETURN;
    WHEN OTHERS THEN
           X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
           FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
           FND_MESSAGE.SET_TOKEN('NAME','Update_Row : '||SQLERRM);
           FND_MSG_PUB.ADD;
           FND_MSG_PUB.Count_And_Get(
                             p_encoded => FND_API.G_FALSE,
                             p_count => x_MSG_COUNT,
                             p_data  => X_MSG_DATA);
   RETURN;
  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_group_advising_rel_id             IN OUT NOCOPY NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_group_advisor_id                  IN     NUMBER,
    x_group_student_id                  IN     NUMBER,
    x_START_DATE                          IN     DATE,
    x_END_DATE                            IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    L_RETURN_STATUS                VARCHAR2(10);
    L_MSG_DATA                     VARCHAR2(2000);
    L_MSG_COUNT                    NUMBER(10);

    CURSOR c1 IS
      SELECT   rowid
      FROM     IGS_AZ_ADVISING_RELS
      WHERE    group_advising_rel_id             = x_group_advising_rel_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_group_advising_rel_id,
        x_group_name,
        x_group_advisor_id,
        x_group_student_id,
        x_START_DATE,
        x_END_DATE,
        x_mode,
        L_RETURN_STATUS,
        L_MSG_DATA,
        L_MSG_COUNT

      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_group_advising_rel_id,
      x_group_name,
      x_group_advisor_id,
      x_group_student_id,
      x_START_DATE,
      x_END_DATE,
      x_mode,
      L_RETURN_STATUS,
      L_MSG_DATA,
      L_MSG_COUNT
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  ) AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
   FND_MSG_PUB.initialize;
    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );

    DELETE FROM IGS_AZ_ADVISING_RELS
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
-- Initialize API return status to success.
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to get message count and if count is 1, get message
  -- info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_MSG_COUNT,
                p_data  => X_MSG_DATA);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(
                   p_encoded => FND_API.G_FALSE,
                   p_count => x_MSG_COUNT,
                   p_data  => X_MSG_DATA);
   RETURN;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                  X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
                  FND_MSG_PUB.Count_And_Get(
                      p_encoded => FND_API.G_FALSE,
                      p_count => x_MSG_COUNT,
                      p_data  => X_MSG_DATA);
   RETURN;
    WHEN OTHERS THEN
           X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
           FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
           FND_MESSAGE.SET_TOKEN('NAME','Insert_Row : '||SQLERRM);
           FND_MSG_PUB.ADD;
           FND_MSG_PUB.Count_And_Get(
                             p_encoded => FND_API.G_FALSE,
                             p_count => x_MSG_COUNT,
                             p_data  => X_MSG_DATA);
   RETURN;
  END delete_row;


END IGS_AZ_ADVISING_RELS_pkg;

/
