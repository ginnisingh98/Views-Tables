--------------------------------------------------------
--  DDL for Package Body IGS_AS_SUA_SES_ATTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_SUA_SES_ATTS_PKG" AS
/* $Header: IGSDI80B.pls 120.0 2005/07/05 11:54:59 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_as_sua_ses_atts%ROWTYPE;
  new_references igs_as_sua_ses_atts%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_session_name                      IN     VARCHAR2,
    x_attendance_flag                   IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 15-OCT-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_as_sua_ses_atts
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
    new_references.person_id                         := x_person_id;
    new_references.course_cd                         := x_course_cd;
    new_references.uoo_id                            := x_uoo_id;
    new_references.session_name                      := x_session_name;
    new_references.attendance_flag                   := x_attendance_flag;

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
  ||  Created By : manu.srinivasan
  ||  Created On : 28-JAN-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

        IF NOT igs_as_usec_sessns_pkg.get_pk_for_validation (
                                    x_session_name     => new_references.session_name,
                                    x_uoo_id           => new_references.uoo_id
              ) THEN
                fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF NOT igs_en_su_Attempt_pkg.get_pk_for_validation(x_person_id => new_references.person_id ,
                                                        x_course_cd     => new_references.course_cd,
                                                        x_uoo_id        => new_references.uoo_id)
         THEN
                fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
         END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_session_name                      IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 15-OCT-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_sua_ses_atts
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      uoo_id = x_uoo_id
      AND      session_name = x_session_name
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
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_session_name                      IN     VARCHAR2,
    x_attendance_flag                   IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 15-OCT-2003
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
      x_person_id,
      x_course_cd,
      x_uoo_id,
      x_session_name,
      x_attendance_flag,
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
             new_references.course_cd,
             new_references.uoo_id,
             new_references.session_name
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.person_id,
             new_references.course_cd,
             new_references.uoo_id,
             new_references.session_name
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'UPDATE') THEN
       check_parent_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_session_name                      IN     VARCHAR2,
    x_attendance_flag                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2 ,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2 ,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 15-OCT-2003
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
    ELSIF (X_MODE IN ('R', 'S')) THEN
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
      fnd_message.set_token ('ROUTINE', 'IGS_AS_SUA_SES_ATTS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_uoo_id                            => x_uoo_id,
      x_session_name                      => x_session_name,
      x_attendance_flag                   => x_attendance_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_as_sua_ses_atts (
      person_id,
      course_cd,
      uoo_id,
      session_name,
      attendance_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.person_id,
      new_references.course_cd,
      new_references.uoo_id,
      new_references.session_name,
      new_references.attendance_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
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
        igs_sc_gen_001.unset_ctx('R');
        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                 p_encoded => FND_API.G_FALSE,
                 p_count => x_MSG_COUNT,
                 p_data  => X_MSG_DATA);
 RETURN;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                igs_sc_gen_001.unset_ctx('R');
                X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_MSG_COUNT,
                    p_data  => X_MSG_DATA);
 RETURN;
  WHEN OTHERS THEN
      igs_sc_gen_001.unset_ctx('R');
      IF (SQLCODE IN (-28115, -28113, -28111)) THEN
              FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_POLICY_EXCEPTION');
              fnd_message.set_token ('ERR_CD', SQLCODE);
              FND_MSG_PUB.ADD;
              FND_MSG_PUB.Count_And_Get(
                                   p_encoded => FND_API.G_FALSE,
                                   p_count => x_MSG_COUNT,
                                   p_data  => X_MSG_DATA);
      ELSE
              X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
              FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
              FND_MESSAGE.SET_TOKEN('NAME','Insert_Row : '||SQLERRM);
              FND_MSG_PUB.ADD;
              FND_MSG_PUB.Count_And_Get(
                                   p_encoded => FND_API.G_FALSE,
                                   p_count => x_MSG_COUNT,
                                   p_data  => X_MSG_DATA);
    END IF;
  RETURN;
 END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_session_name                      IN     VARCHAR2,
    x_attendance_flag                   IN     VARCHAR2,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2 ,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2 ,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 15-OCT-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        attendance_flag
      FROM  igs_as_sua_ses_atts
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
        (tlinfo.attendance_flag = x_attendance_flag)
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
         FND_MESSAGE.SET_TOKEN('NAME','lock_row : '||SQLERRM);
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get(
                           p_encoded => FND_API.G_FALSE,
                           p_count => x_MSG_COUNT,
                           p_data  => X_MSG_DATA);
  RETURN;


  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_session_name                      IN     VARCHAR2,
    x_attendance_flag                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2 ,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2 ,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 15-OCT-2003
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
    ELSIF (X_MODE IN ('R', 'S')) THEN
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
      fnd_message.set_token ('ROUTINE', 'IGS_AS_SUA_SES_ATTS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_uoo_id                            => x_uoo_id,
      x_session_name                      => x_session_name,
      x_attendance_flag                   => x_attendance_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_as_sua_ses_atts
      SET
        attendance_flag                   = new_references.attendance_flag,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
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
      igs_sc_gen_001.unset_ctx('R');
      IF (SQLCODE = (-28115)) THEN
              FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_POLICY_EXCEPTION');
              fnd_message.set_token ('ERR_CD', SQLCODE);
              FND_MSG_PUB.ADD;
              FND_MSG_PUB.Count_And_Get(
                                   p_encoded => FND_API.G_FALSE,
                                   p_count => x_MSG_COUNT,
                                   p_data  => X_MSG_DATA);
      ELSE
         X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
         FND_MESSAGE.SET_TOKEN('NAME','Update_Row : '||SQLERRM);
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get(
                           p_encoded => FND_API.G_FALSE,
                           p_count => x_MSG_COUNT,
                           p_data  => X_MSG_DATA);

    END IF;
  RETURN;
 END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_session_name                      IN     VARCHAR2,
    x_attendance_flag                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2 ,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2 ,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 15-OCT-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_as_sua_ses_atts
      WHERE    person_id                         = x_person_id
      AND      course_cd                         = x_course_cd
      AND      uoo_id                            = x_uoo_id
      AND      session_name                      = x_session_name;

  BEGIN
FND_MSG_PUB.initialize;

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_person_id,
        x_course_cd,
        x_uoo_id,
        x_session_name,
        x_attendance_flag,
        x_mode ,
        x_return_status,
        x_msg_data,
        x_msg_count
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_person_id,
      x_course_cd,
      x_uoo_id,
      x_session_name,
      x_attendance_flag,
      x_mode ,
        x_return_status,
        x_msg_data,
        x_msg_count
    );

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

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2 ,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2 ,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2 ,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 15-OCT-2003
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

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 DELETE FROM igs_as_sua_ses_atts
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
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

PROCEDURE get_fk_igs_as_usec_sessns(
                                        x_session_name   igs_as_usec_sessns.session_name%TYPE,
                                        x_uoo_id         igs_as_usec_sessns.uoo_id%TYPE
          )
AS
  /*
  ||  Created By : manu.srinivasan
  ||  Created On : 28-JAN-2002
  ||  Purpose : Called by the parent table upon delete
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  CURSOR cur_rowid  IS
     SELECT rowid
     FROM igs_as_sua_ses_atts
     WHERE session_name = x_session_name
     AND   uoo_id       = x_uoo_id;
lv_rowid cur_rowid%ROWTYPE;

  BEGIN

   OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SES_ATTS_USEC_SESS_FK');
      IGS_GE_MSG_STACK.ADD;
                CLOSE cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_as_usec_sessns;

PROCEDURE get_fk_igs_en_su_Attempt(
                                        x_person_id igs_en_su_attempt.person_id%TYPE,
                                        x_course_cd igs_en_su_attempt.course_cd%TYPE,
                                        x_uoo_id    igs_en_su_attempt.uoo_id%TYPE
          )
AS
  /*
  ||  Created By : manu.srinivasan
  ||  Created On : 28-JAN-2002
  ||  Purpose : Called by the parent table upon delete
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  CURSOR cur_rowid  IS
     SELECT rowid
     FROM igs_as_sua_ses_atts
     WHERE person_id = x_person_id
     AND   course_cd = x_course_cd
     AND   uoo_id    = x_uoo_id;

lv_rowid cur_rowid%ROWTYPE;

  BEGIN

   OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SES_ATTS_SUA_FK');
      IGS_GE_MSG_STACK.ADD;
                CLOSE cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_su_Attempt;

END igs_as_sua_ses_atts_pkg;

/
