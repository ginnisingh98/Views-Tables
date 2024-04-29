--------------------------------------------------------
--  DDL for Package Body IGS_AZ_STUDENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AZ_STUDENTS_PKG" AS
/* $Header: IGSHI02B.pls 115.4 2003/06/30 05:37:54 kdande noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_az_students%ROWTYPE;
  new_references igs_az_students%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_group_student_id                  IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_student_person_id                 IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_advising_hold_type                IN     VARCHAR2,
    x_hold_start_date                   IN     DATE,
    x_notified_date                     IN     DATE,
    x_accept_add_flag                   IN     VARCHAR2,
    x_accept_delete_flag                IN     VARCHAR2,
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
      FROM     igs_az_students
      WHERE    ROWID = x_rowid;

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
    new_references.group_student_id                  := x_group_student_id;
    new_references.group_name                        := x_group_name;
    new_references.student_person_id                 := x_student_person_id;
    new_references.start_date                        := TRUNC(x_start_date);
    new_references.end_date                          := TRUNC(x_end_date);
    new_references.advising_hold_type                := x_advising_hold_type;
    new_references.hold_start_date                   := TRUNC(x_hold_start_date);
    new_references.notified_date                     := TRUNC(x_notified_date);
    new_references.accept_add_flag                   := x_accept_add_flag;
    new_references.accept_delete_flag                := x_accept_delete_flag;

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
           new_references.student_person_id,
           new_references.group_name
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      RAISE FND_API.G_EXC_ERROR;
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
    ELSIF NOT igs_az_groups_pkg.get_pk_for_validation (
                new_references.group_name
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_az_advising_rels_pkg.get_fk_igs_az_students (
      old_references.group_student_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_group_student_id                  IN     NUMBER
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
      SELECT   ROWID
      FROM     igs_az_students
      WHERE    group_student_id = x_group_student_id;

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
    x_student_person_id                 IN     NUMBER,
    x_group_name                        IN     VARCHAR2
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
      SELECT   ROWID
      FROM     igs_az_students
      WHERE    student_person_id = x_student_person_id
      AND      group_name = x_group_name
      AND      ((l_rowid IS NULL) OR (ROWID <> l_rowid));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (TRUE);
        ELSE
       CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_uk_for_validation ;


  PROCEDURE get_fk_igs_az_groups (
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
      SELECT   ROWID
      FROM     igs_az_students
      WHERE   ((group_name = x_group_name));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AZ_GRP_STUD_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_az_groups;

  PROCEDURE update_az_advising_rel
  AS
  BEGIN
    IF ((new_references.end_date IS NULL AND old_references.end_date IS NOT NULL) OR
        (new_references.end_date IS NOT NULL AND old_references.end_date IS NULL) OR
          ( NVL(TRUNC(new_references.end_date),TRUNC(SYSDATE)) <> NVL(TRUNC(old_references.end_date),TRUNC(SYSDATE)) )) THEN
       -- call the procedure
       igs_az_gen_001.end_date_student(
         p_group_name        => new_references.group_name,
         p_student_person_id => new_references.student_person_id,
         p_end_date          => new_references.end_date,
         p_calling_mod       => NULL );
    -- If student is being un-end-dated set auto_delete_flag to null
    IF new_references.end_date IS NULL AND old_references.end_date IS NOT NULL THEN
         new_references.accept_delete_flag := NULL;
    END IF;
    END IF;
  END update_az_advising_rel;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_group_student_id                  IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_student_person_id                 IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_advising_hold_type                IN     VARCHAR2,
    x_hold_start_date                   IN     DATE,
    x_notified_date                     IN     DATE,
    x_accept_add_flag                   IN     VARCHAR2,
    x_accept_delete_flag                IN     VARCHAR2,
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
      x_group_student_id,
      x_group_name,
      x_student_person_id,
      x_start_date,
      x_end_date,
      x_advising_hold_type,
      x_hold_start_date,
      x_notified_date,
      x_accept_add_flag,
      x_accept_delete_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.group_student_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      check_uniqueness;
      check_parent_existance;
      update_az_advising_rel;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance;
      update_az_advising_rel;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.group_student_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      update_az_advising_rel;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
      update_az_advising_rel;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_group_student_id                  IN OUT NOCOPY NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_student_person_id                 IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_advising_hold_type                IN     VARCHAR2,
    x_hold_start_date                   IN     DATE,
    x_notified_date                     IN     DATE,
    x_accept_add_flag                   IN     VARCHAR2,
    x_accept_delete_flag                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_return_status                     OUT NOCOPY    VARCHAR2,
    x_msg_data                          OUT NOCOPY    VARCHAR2,
    x_msg_count                         OUT NOCOPY    NUMBER
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
      fnd_message.set_token ('ROUTINE', 'IGS_AZ_STUDENTS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_group_student_id := NULL;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_group_student_id                  => x_group_student_id,
      x_group_name                        => x_group_name,
      x_student_person_id                 => x_student_person_id,
      x_start_date                        => x_start_date,
      x_end_date                          => x_end_date,
      x_advising_hold_type                => x_advising_hold_type,
      x_hold_start_date                   => x_hold_start_date,
      x_notified_date                     => x_notified_date,
      x_accept_add_flag                   => x_accept_add_flag,
      x_accept_delete_flag                => x_accept_delete_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );
    INSERT INTO igs_az_students (
      group_student_id,
      group_name,
      student_person_id,
      start_date,
      end_date,
      advising_hold_type,
      hold_start_date,
      notified_date,
      accept_add_flag,
      accept_delete_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_az_students_s.NEXTVAL,
      new_references.group_name,
      new_references.student_person_id,
      new_references.start_date,
      new_references.end_date,
      new_references.advising_hold_type,
      new_references.hold_start_date,
      new_references.notified_date,
      new_references.accept_add_flag,
      new_references.accept_delete_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, group_student_id INTO x_rowid, x_group_student_id;
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
  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_group_student_id                  IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_student_person_id                 IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_advising_hold_type                IN     VARCHAR2,
    x_hold_start_date                   IN     DATE,
    x_notified_date                     IN     DATE,
    x_accept_add_flag                   IN     VARCHAR2,
    x_accept_delete_flag                IN     VARCHAR2,
    x_return_status                     OUT NOCOPY    VARCHAR2,
    x_msg_data                          OUT NOCOPY    VARCHAR2,
    x_msg_count                         OUT NOCOPY    NUMBER
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
        student_person_id,
        start_date,
        end_date,
        advising_hold_type,
        hold_start_date,
        notified_date,
        accept_add_flag,
        accept_delete_flag
      FROM  igs_az_students
      WHERE ROWID = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN
    FND_MSG_PUB.initialize;
    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%NOTFOUND) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      CLOSE c1;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.group_name = x_group_name)
        AND (tlinfo.student_person_id = x_student_person_id)
        AND ((TRUNC(tlinfo.start_date) = TRUNC(x_start_date)) OR ((tlinfo.start_date IS NULL) AND (x_start_date IS NULL)))
        AND ((TRUNC(tlinfo.end_date) = TRUNC(x_end_date)) OR ((tlinfo.end_date IS NULL) AND (x_end_date IS NULL)))
        AND ((tlinfo.advising_hold_type = x_advising_hold_type) OR ((tlinfo.advising_hold_type IS NULL) AND (x_advising_hold_type IS NULL)))
        AND ((TRUNC(tlinfo.hold_start_date) = TRUNC(x_hold_start_date)) OR ((tlinfo.hold_start_date IS NULL) AND (x_hold_start_date IS NULL)))
        AND ((TRUNC(tlinfo.notified_date) = TRUNC(x_notified_date)) OR ((tlinfo.notified_date IS NULL) AND (x_notified_date IS NULL)))
        AND ((tlinfo.accept_add_flag = x_accept_add_flag) OR ((tlinfo.accept_add_flag IS NULL) AND (x_accept_add_flag IS NULL)))
        AND ((tlinfo.accept_delete_flag = x_accept_delete_flag) OR ((tlinfo.accept_delete_flag IS NULL) AND (x_accept_delete_flag IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      RAISE FND_API.G_EXC_ERROR;
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
    x_group_student_id                  IN OUT NOCOPY NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_student_person_id                 IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_advising_hold_type                IN     VARCHAR2,
    x_hold_start_date                   IN     DATE,
    x_notified_date                     IN     DATE,
    x_accept_add_flag                   IN     VARCHAR2,
    x_accept_delete_flag                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_return_status                     OUT NOCOPY    VARCHAR2,
    x_msg_data                          OUT NOCOPY    VARCHAR2,
    x_msg_count                         OUT NOCOPY    NUMBER
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
      fnd_message.set_token ('ROUTINE', 'IGS_AZ_STUDENTS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_group_student_id                  => x_group_student_id,
      x_group_name                        => x_group_name,
      x_student_person_id                 => x_student_person_id,
      x_start_date                        => x_start_date,
      x_end_date                          => x_end_date,
      x_advising_hold_type                => x_advising_hold_type,
      x_hold_start_date                   => x_hold_start_date,
      x_notified_date                     => x_notified_date,
      x_accept_add_flag                   => x_accept_add_flag,
      x_accept_delete_flag                => x_accept_delete_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );
    UPDATE igs_az_students
      SET
        group_name                        = new_references.group_name,
        student_person_id                 = new_references.student_person_id,
        start_date                        = new_references.start_date,
        end_date                          = new_references.end_date,
        advising_hold_type                = new_references.advising_hold_type,
        hold_start_date                   = new_references.hold_start_date,
        notified_date                     = new_references.notified_date,
        accept_add_flag                   = new_references.accept_add_flag,
        accept_delete_flag                = new_references.accept_delete_flag,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE ROWID = x_rowid;
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
    x_group_student_id                  IN OUT NOCOPY NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_student_person_id                 IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_advising_hold_type                IN     VARCHAR2,
    x_hold_start_date                   IN     DATE,
    x_notified_date                     IN     DATE,
    x_accept_add_flag                   IN     VARCHAR2,
    x_accept_delete_flag                IN     VARCHAR2,
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
    CURSOR c1 IS
      SELECT   ROWID
      FROM     igs_az_students
      WHERE    group_student_id                  = x_group_student_id;
    L_RETURN_STATUS                VARCHAR2(10);
    L_MSG_DATA                     VARCHAR2(2000);
    L_MSG_COUNT                    NUMBER(10);

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_group_student_id,
        x_group_name,
        x_student_person_id,
        x_start_date,
        x_end_date,
        x_advising_hold_type,
        x_hold_start_date,
        x_notified_date,
        x_accept_add_flag,
        x_accept_delete_flag,
        x_mode,
        l_return_status,
        l_msg_data,
        l_msg_count
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_group_student_id,
      x_group_name,
      x_student_person_id,
      x_start_date,
      x_end_date,
      x_advising_hold_type,
      x_hold_start_date,
      x_notified_date,
      x_accept_add_flag,
      x_accept_delete_flag,
      x_mode,
      l_return_status,
      l_msg_data,
      l_msg_count
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid                             IN VARCHAR2,
    x_return_status                     OUT NOCOPY    VARCHAR2,
    x_msg_data                          OUT NOCOPY    VARCHAR2,
    x_msg_count                         OUT NOCOPY    NUMBER
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

    DELETE FROM igs_az_students
    WHERE ROWID = x_rowid;

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


END igs_az_students_pkg;

/
