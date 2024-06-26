--------------------------------------------------------
--  DDL for Package Body IGS_DA_REQ_WIF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_DA_REQ_WIF_PKG" AS
/* $Header: IGSKI43B.pls 115.1 2003/04/16 05:40:10 smanglm noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_da_req_wif%ROWTYPE;
  new_references igs_da_req_wif%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_wif_id                            IN     NUMBER,
    x_program_code                      IN     VARCHAR2,
    x_catalog_cal_type                  IN     VARCHAR2,
    x_catalog_ci_seq_num                IN     NUMBER,
    x_major_unit_set_cd1                IN     VARCHAR2,
    x_major_unit_set_cd2                IN     VARCHAR2,
    x_major_unit_set_cd3                IN     VARCHAR2,
    x_minor_unit_set_cd1                IN     VARCHAR2,
    x_minor_unit_set_cd2                IN     VARCHAR2,
    x_minor_unit_set_cd3                IN     VARCHAR2,
    x_track_unit_set_cd1                IN     VARCHAR2,
    x_track_unit_set_cd2                IN     VARCHAR2,
    x_track_unit_set_cd3                IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAR-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_da_req_wif
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
    new_references.batch_id                          := x_batch_id;
    new_references.wif_id                            := x_wif_id;
    new_references.program_code                      := x_program_code;
    new_references.catalog_cal_type                  := x_catalog_cal_type;
    new_references.catalog_ci_seq_num                := x_catalog_ci_seq_num;
    new_references.major_unit_set_cd1                := x_major_unit_set_cd1;
    new_references.major_unit_set_cd2                := x_major_unit_set_cd2;
    new_references.major_unit_set_cd3                := x_major_unit_set_cd3;
    new_references.minor_unit_set_cd1                := x_minor_unit_set_cd1;
    new_references.minor_unit_set_cd2                := x_minor_unit_set_cd2;
    new_references.minor_unit_set_cd3                := x_minor_unit_set_cd3;
    new_references.track_unit_set_cd1                := x_track_unit_set_cd1;
    new_references.track_unit_set_cd2                := x_track_unit_set_cd2;
    new_references.track_unit_set_cd3                := x_track_unit_set_cd3;

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
  ||  Created By :
  ||  Created On : 27-MAR-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    IF (((old_references.batch_id = new_references.batch_id)) OR
        ((new_references.batch_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_da_rqst_pkg.get_pk_for_validation (
                new_references.batch_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
IF (((old_references.program_code = new_references.program_code)) OR
        ((new_references.program_code IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_course_pkg.get_pk_for_validation (
                new_references.program_code
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
    IF (((old_references.catalog_cal_type = new_references.catalog_cal_type) AND
         (old_references.catalog_ci_seq_num = new_references.catalog_ci_seq_num)) OR
        ((new_references.catalog_cal_type IS NULL) OR
         (new_references.catalog_ci_seq_num IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.catalog_cal_type,
                new_references.catalog_ci_seq_num
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance AS
  /*
  ||  Created By :
  ||  Created On : 27-MAR-2003
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_da_req_stdnts_pkg.get_fk_igs_da_req_wif (
      old_references.batch_id,
      old_references.wif_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_batch_id                          IN     NUMBER,
    x_wif_id                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 27-MAR-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_da_req_wif
      WHERE    batch_id = x_batch_id
      AND      wif_id = x_wif_id
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


  PROCEDURE get_fk_igs_da_rqst (
    x_batch_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAR-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_da_req_wif
      WHERE   ((batch_id = x_batch_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_DA_RQST_WIF_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_da_rqst;


  PROCEDURE get_fk_igs_ps_course (
    x_course_cd                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAR-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_da_req_wif
      WHERE   ((program_code = x_course_cd));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_DA_PS_WIF_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_course;


  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAR-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_da_req_wif
      WHERE   ((catalog_cal_type = x_cal_type) AND
               (catalog_ci_seq_num = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_DA_CA_WIF_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_wif_id                            IN     NUMBER,
    x_program_code                      IN     VARCHAR2,
    x_catalog_cal_type                  IN     VARCHAR2,
    x_catalog_ci_seq_num                IN     NUMBER,
    x_major_unit_set_cd1                IN     VARCHAR2,
    x_major_unit_set_cd2                IN     VARCHAR2,
    x_major_unit_set_cd3                IN     VARCHAR2,
    x_minor_unit_set_cd1                IN     VARCHAR2,
    x_minor_unit_set_cd2                IN     VARCHAR2,
    x_minor_unit_set_cd3                IN     VARCHAR2,
    x_track_unit_set_cd1                IN     VARCHAR2,
    x_track_unit_set_cd2                IN     VARCHAR2,
    x_track_unit_set_cd3                IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAR-2003
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
      x_batch_id,
      x_wif_id,
      x_program_code,
      x_catalog_cal_type,
      x_catalog_ci_seq_num,
      x_major_unit_set_cd1,
      x_major_unit_set_cd2,
      x_major_unit_set_cd3,
      x_minor_unit_set_cd1,
      x_minor_unit_set_cd2,
      x_minor_unit_set_cd3,
      x_track_unit_set_cd1,
      x_track_unit_set_cd2,
      x_track_unit_set_cd3,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.batch_id,
             new_references.wif_id
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
             new_references.batch_id,
             new_references.wif_id
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
    x_batch_id                          IN     NUMBER,
    x_wif_id                            IN     NUMBER,
    x_program_code                      IN     VARCHAR2,
    x_catalog_cal_type                  IN     VARCHAR2,
    x_catalog_ci_seq_num                IN     NUMBER,
    x_major_unit_set_cd1                IN     VARCHAR2,
    x_major_unit_set_cd2                IN     VARCHAR2,
    x_major_unit_set_cd3                IN     VARCHAR2,
    x_minor_unit_set_cd1                IN     VARCHAR2,
    x_minor_unit_set_cd2                IN     VARCHAR2,
    x_minor_unit_set_cd3                IN     VARCHAR2,
    x_track_unit_set_cd1                IN     VARCHAR2,
    x_track_unit_set_cd2                IN     VARCHAR2,
    x_track_unit_set_cd3                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAR-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_DA_REQ_WIF_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_batch_id                          => x_batch_id,
      x_wif_id                            => x_wif_id,
      x_program_code                      => x_program_code,
      x_catalog_cal_type                  => x_catalog_cal_type,
      x_catalog_ci_seq_num                => x_catalog_ci_seq_num,
      x_major_unit_set_cd1                => x_major_unit_set_cd1,
      x_major_unit_set_cd2                => x_major_unit_set_cd2,
      x_major_unit_set_cd3                => x_major_unit_set_cd3,
      x_minor_unit_set_cd1                => x_minor_unit_set_cd1,
      x_minor_unit_set_cd2                => x_minor_unit_set_cd2,
      x_minor_unit_set_cd3                => x_minor_unit_set_cd3,
      x_track_unit_set_cd1                => x_track_unit_set_cd1,
      x_track_unit_set_cd2                => x_track_unit_set_cd2,
      x_track_unit_set_cd3                => x_track_unit_set_cd3,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );
    INSERT INTO igs_da_req_wif (
      batch_id,
      wif_id,
      program_code,
      catalog_cal_type,
      catalog_ci_seq_num,
      major_unit_set_cd1,
      major_unit_set_cd2,
      major_unit_set_cd3,
      minor_unit_set_cd1,
      minor_unit_set_cd2,
      minor_unit_set_cd3,
      track_unit_set_cd1,
      track_unit_set_cd2,
      track_unit_set_cd3,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.batch_id,
      new_references.wif_id,
      new_references.program_code,
      new_references.catalog_cal_type,
      new_references.catalog_ci_seq_num,
      new_references.major_unit_set_cd1,
      new_references.major_unit_set_cd2,
      new_references.major_unit_set_cd3,
      new_references.minor_unit_set_cd1,
      new_references.minor_unit_set_cd2,
      new_references.minor_unit_set_cd3,
      new_references.track_unit_set_cd1,
      new_references.track_unit_set_cd2,
      new_references.track_unit_set_cd3,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;
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
    x_batch_id                          IN     NUMBER,
    x_wif_id                            IN     NUMBER,
    x_program_code                      IN     VARCHAR2,
    x_catalog_cal_type                  IN     VARCHAR2,
    x_catalog_ci_seq_num                IN     NUMBER,
    x_major_unit_set_cd1                IN     VARCHAR2,
    x_major_unit_set_cd2                IN     VARCHAR2,
    x_major_unit_set_cd3                IN     VARCHAR2,
    x_minor_unit_set_cd1                IN     VARCHAR2,
    x_minor_unit_set_cd2                IN     VARCHAR2,
    x_minor_unit_set_cd3                IN     VARCHAR2,
    x_track_unit_set_cd1                IN     VARCHAR2,
    x_track_unit_set_cd2                IN     VARCHAR2,
    x_track_unit_set_cd3                IN     VARCHAR2,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAR-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        program_code,
        catalog_cal_type,
        catalog_ci_seq_num,
        major_unit_set_cd1,
        major_unit_set_cd2,
        major_unit_set_cd3,
        minor_unit_set_cd1,
        minor_unit_set_cd2,
        minor_unit_set_cd3,
        track_unit_set_cd1,
        track_unit_set_cd2,
        track_unit_set_cd3
      FROM  igs_da_req_wif
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
        (tlinfo.program_code = x_program_code)
        AND ((tlinfo.catalog_cal_type = x_catalog_cal_type) OR ((tlinfo.catalog_cal_type IS NULL) AND (X_catalog_cal_type IS NULL)))
        AND ((tlinfo.catalog_ci_seq_num = x_catalog_ci_seq_num) OR ((tlinfo.catalog_ci_seq_num IS NULL) AND (X_catalog_ci_seq_num IS NULL)))
        AND ((tlinfo.major_unit_set_cd1 = x_major_unit_set_cd1) OR ((tlinfo.major_unit_set_cd1 IS NULL) AND (X_major_unit_set_cd1 IS NULL)))
        AND ((tlinfo.major_unit_set_cd2 = x_major_unit_set_cd2) OR ((tlinfo.major_unit_set_cd2 IS NULL) AND (X_major_unit_set_cd2 IS NULL)))
        AND ((tlinfo.major_unit_set_cd3 = x_major_unit_set_cd3) OR ((tlinfo.major_unit_set_cd3 IS NULL) AND (X_major_unit_set_cd3 IS NULL)))
        AND ((tlinfo.minor_unit_set_cd1 = x_minor_unit_set_cd1) OR ((tlinfo.minor_unit_set_cd1 IS NULL) AND (X_minor_unit_set_cd1 IS NULL)))
        AND ((tlinfo.minor_unit_set_cd2 = x_minor_unit_set_cd2) OR ((tlinfo.minor_unit_set_cd2 IS NULL) AND (X_minor_unit_set_cd2 IS NULL)))
        AND ((tlinfo.minor_unit_set_cd3 = x_minor_unit_set_cd3) OR ((tlinfo.minor_unit_set_cd3 IS NULL) AND (X_minor_unit_set_cd3 IS NULL)))
        AND ((tlinfo.track_unit_set_cd1 = x_track_unit_set_cd1) OR ((tlinfo.track_unit_set_cd1 IS NULL) AND (X_track_unit_set_cd1 IS NULL)))
        AND ((tlinfo.track_unit_set_cd2 = x_track_unit_set_cd2) OR ((tlinfo.track_unit_set_cd2 IS NULL) AND (X_track_unit_set_cd2 IS NULL)))
        AND ((tlinfo.track_unit_set_cd3 = x_track_unit_set_cd3) OR ((tlinfo.track_unit_set_cd3 IS NULL) AND (X_track_unit_set_cd3 IS NULL)))
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
    x_batch_id                          IN     NUMBER,
    x_wif_id                            IN     NUMBER,
    x_program_code                      IN     VARCHAR2,
    x_catalog_cal_type                  IN     VARCHAR2,
    x_catalog_ci_seq_num                IN     NUMBER,
    x_major_unit_set_cd1                IN     VARCHAR2,
    x_major_unit_set_cd2                IN     VARCHAR2,
    x_major_unit_set_cd3                IN     VARCHAR2,
    x_minor_unit_set_cd1                IN     VARCHAR2,
    x_minor_unit_set_cd2                IN     VARCHAR2,
    x_minor_unit_set_cd3                IN     VARCHAR2,
    x_track_unit_set_cd1                IN     VARCHAR2,
    x_track_unit_set_cd2                IN     VARCHAR2,
    x_track_unit_set_cd3                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAR-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_DA_REQ_WIF_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_batch_id                          => x_batch_id,
      x_wif_id                            => x_wif_id,
      x_program_code                      => x_program_code,
      x_catalog_cal_type                  => x_catalog_cal_type,
      x_catalog_ci_seq_num                => x_catalog_ci_seq_num,
      x_major_unit_set_cd1                => x_major_unit_set_cd1,
      x_major_unit_set_cd2                => x_major_unit_set_cd2,
      x_major_unit_set_cd3                => x_major_unit_set_cd3,
      x_minor_unit_set_cd1                => x_minor_unit_set_cd1,
      x_minor_unit_set_cd2                => x_minor_unit_set_cd2,
      x_minor_unit_set_cd3                => x_minor_unit_set_cd3,
      x_track_unit_set_cd1                => x_track_unit_set_cd1,
      x_track_unit_set_cd2                => x_track_unit_set_cd2,
      x_track_unit_set_cd3                => x_track_unit_set_cd3,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_da_req_wif
      SET
        program_code                      = new_references.program_code,
        catalog_cal_type                  = new_references.catalog_cal_type,
        catalog_ci_seq_num                = new_references.catalog_ci_seq_num,
        major_unit_set_cd1                = new_references.major_unit_set_cd1,
        major_unit_set_cd2                = new_references.major_unit_set_cd2,
        major_unit_set_cd3                = new_references.major_unit_set_cd3,
        minor_unit_set_cd1                = new_references.minor_unit_set_cd1,
        minor_unit_set_cd2                = new_references.minor_unit_set_cd2,
        minor_unit_set_cd3                = new_references.minor_unit_set_cd3,
        track_unit_set_cd1                = new_references.track_unit_set_cd1,
        track_unit_set_cd2                = new_references.track_unit_set_cd2,
        track_unit_set_cd3                = new_references.track_unit_set_cd3,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
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
    x_batch_id                          IN     NUMBER,
    x_wif_id                            IN     NUMBER,
    x_program_code                      IN     VARCHAR2,
    x_catalog_cal_type                  IN     VARCHAR2,
    x_catalog_ci_seq_num                IN     NUMBER,
    x_major_unit_set_cd1                IN     VARCHAR2,
    x_major_unit_set_cd2                IN     VARCHAR2,
    x_major_unit_set_cd3                IN     VARCHAR2,
    x_minor_unit_set_cd1                IN     VARCHAR2,
    x_minor_unit_set_cd2                IN     VARCHAR2,
    x_minor_unit_set_cd3                IN     VARCHAR2,
    x_track_unit_set_cd1                IN     VARCHAR2,
    x_track_unit_set_cd2                IN     VARCHAR2,
    x_track_unit_set_cd3                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAR-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_da_req_wif
      WHERE    batch_id                          = x_batch_id
      AND      wif_id                            = x_wif_id;
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
        x_batch_id,
        x_wif_id,
        x_program_code,
        x_catalog_cal_type,
        x_catalog_ci_seq_num,
        x_major_unit_set_cd1,
        x_major_unit_set_cd2,
        x_major_unit_set_cd3,
        x_minor_unit_set_cd1,
        x_minor_unit_set_cd2,
        x_minor_unit_set_cd3,
        x_track_unit_set_cd1,
        x_track_unit_set_cd2,
        x_track_unit_set_cd3,
        x_mode ,
        L_RETURN_STATUS,
	L_MSG_DATA     ,
	L_MSG_COUNT
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_batch_id,
      x_wif_id,
      x_program_code,
      x_catalog_cal_type,
      x_catalog_ci_seq_num,
      x_major_unit_set_cd1,
      x_major_unit_set_cd2,
      x_major_unit_set_cd3,
      x_minor_unit_set_cd1,
      x_minor_unit_set_cd2,
      x_minor_unit_set_cd3,
      x_track_unit_set_cd1,
      x_track_unit_set_cd2,
      x_track_unit_set_cd3,
      x_mode ,
      L_RETURN_STATUS,
      L_MSG_DATA     ,
      L_MSG_COUNT
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2  ,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAR-2003
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

    DELETE FROM igs_da_req_wif
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


END igs_da_req_wif_pkg;

/
