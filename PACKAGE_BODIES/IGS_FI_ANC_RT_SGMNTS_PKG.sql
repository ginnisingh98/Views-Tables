--------------------------------------------------------
--  DDL for Package Body IGS_FI_ANC_RT_SGMNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_ANC_RT_SGMNTS_PKG" AS
/* $Header: IGSSI83B.pls 115.9 2003/02/12 07:29:07 pathipat ship $ */

  l_rowid VARCHAR2(25);
  l_record_count  NUMBER(3) := 0;
  old_references igs_fi_anc_rt_sgmnts%ROWTYPE;
  new_references igs_fi_anc_rt_sgmnts%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_anc_rate_segment_id               IN     NUMBER  ,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER  ,
    x_ancillary_attributes              IN     VARCHAR2,
    x_ancillary_segments                IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_ANC_RT_SGMNTS
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
    new_references.anc_rate_segment_id               := x_anc_rate_segment_id;
    new_references.fee_type                          := x_fee_type;
    new_references.fee_cal_type                      := x_fee_cal_type;
    new_references.fee_ci_sequence_number            := x_fee_ci_sequence_number;
    new_references.ancillary_attributes              := x_ancillary_attributes;
    new_references.ancillary_segments                := x_ancillary_segments;
    new_references.enabled_flag                      := x_enabled_flag;

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

  -- This local procedure is implementing the bussiness logic of limiting the number of ancillary segments to 15 and also
  -- populating the ancillary_attributes column of the table with default values like ANCILLARY_ATTRIBUTE1,ANCILLARY_ATTRIBUTE2 etc

  PROCEDURE BeforeRowInsert(x_fee_type IN VARCHAR2,
                            x_fee_cal_type IN VARCHAR2,
                            x_fee_ci_sequence_number IN NUMBER) AS
    CURSOR cur_cnt IS
      SELECT  count(*)
      FROM   IGS_FI_ANC_RT_SGMNTS_V
      WHERE  fee_type               = x_fee_type
      AND    fee_cal_type           = x_fee_cal_type
      AND    fee_ci_sequence_number = x_fee_ci_sequence_number ;


  BEGIN
    Open cur_cnt;
    Fetch cur_cnt INTO l_record_count ;
    Close cur_cnt;

    IF (l_record_count = 15) THEN
      Fnd_Message.Set_Name('IGS','IGS_FI_MAX_15_SEGMENTS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    ELSE
      new_references.ancillary_attributes := 'ANCILLARY_ATTRIBUTE'||To_Char(l_record_count +1);
    END IF;
  END BeforeRowInsert;



  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number) AND
         (old_references.fee_type = new_references.fee_type)) OR
        ((new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL) OR
         (new_references.fee_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_f_typ_ca_inst_pkg.get_pk_for_validation (
                new_references.fee_type,
                new_references.fee_cal_type,
                new_references.fee_ci_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_anc_rate_segment_id               IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_anc_rt_sgmnts
      WHERE    anc_rate_segment_id = x_anc_rate_segment_id
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
    x_anc_rate_segment_id               IN     NUMBER  ,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER  ,
    x_ancillary_attributes              IN     VARCHAR2,
    x_ancillary_segments                IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
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
      x_anc_rate_segment_id,
      x_fee_type,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_ancillary_attributes,
      x_ancillary_segments,
      x_enabled_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsert(x_fee_type                => x_fee_type,
                      x_fee_cal_type            => x_fee_cal_type,
                      x_fee_ci_sequence_number  => x_fee_ci_sequence_number);
      IF ( get_pk_for_validation(
             new_references.anc_rate_segment_id
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
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.anc_rate_segment_id
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
    x_anc_rate_segment_id               IN OUT NOCOPY NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_ancillary_attributes              IN OUT NOCOPY VARCHAR2,
    x_ancillary_segments                IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pathipat        24-Dec-2002     Bug: 2526337 - Copied new_references.ancillary_attributes
  ||                                  to the OUT parameter x_ancillary_attributes
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_fi_anc_rt_sgmnts
      WHERE    anc_rate_segment_id               = x_anc_rate_segment_id;

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

   SELECT IGS_FI_ANC_RT_SGMNTS_S.NEXTVAL INTO x_anc_rate_segment_id FROM DUAL;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_anc_rate_segment_id               => x_anc_rate_segment_id,
      x_fee_type                          => x_fee_type,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
      x_ancillary_attributes              => x_ancillary_attributes,
      x_ancillary_segments                => x_ancillary_segments,
      x_enabled_flag                      => x_enabled_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_anc_rt_sgmnts (
      anc_rate_segment_id,
      fee_type,
      fee_cal_type,
      fee_ci_sequence_number,
      ancillary_attributes,
      ancillary_segments,
      enabled_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.anc_rate_segment_id,
      new_references.fee_type,
      new_references.fee_cal_type,
      new_references.fee_ci_sequence_number,
      new_references.ancillary_attributes,
      new_references.ancillary_segments,
      new_references.enabled_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    -- The ancillary_attributes value has to be copied back to the OUT variable x_ancillary_attributes
    -- Added for bug 2526337
    x_ancillary_attributes := new_references.ancillary_attributes;

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

    l_rowid := NULL;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_anc_rate_segment_id               IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_ancillary_attributes              IN     VARCHAR2,
    x_ancillary_segments                IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        fee_type,
        fee_cal_type,
        fee_ci_sequence_number,
        ancillary_attributes,
        ancillary_segments,
        enabled_flag
      FROM  igs_fi_anc_rt_sgmnts
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
        (tlinfo.fee_type = x_fee_type)
        AND (tlinfo.fee_cal_type = x_fee_cal_type)
        AND (tlinfo.fee_ci_sequence_number = x_fee_ci_sequence_number)
        AND ((tlinfo.ancillary_attributes = x_ancillary_attributes) OR ((tlinfo.ancillary_attributes IS NULL) AND (X_ancillary_attributes IS NULL)))
        AND ((tlinfo.ancillary_segments = x_ancillary_segments) OR ((tlinfo.ancillary_segments IS NULL) AND (X_ancillary_segments IS NULL)))
        AND ((tlinfo.enabled_flag = x_enabled_flag) OR ((tlinfo.enabled_flag IS NULL) AND (X_enabled_flag IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    l_rowid := NULL;
    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_anc_rate_segment_id               IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_ancillary_attributes              IN     VARCHAR2,
    x_ancillary_segments                IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
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
      x_anc_rate_segment_id               => x_anc_rate_segment_id,
      x_fee_type                          => x_fee_type,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
      x_ancillary_attributes              => x_ancillary_attributes,
      x_ancillary_segments                => x_ancillary_segments,
      x_enabled_flag                      => x_enabled_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_fi_anc_rt_sgmnts
      SET
        fee_type                          = new_references.fee_type,
        fee_cal_type                      = new_references.fee_cal_type,
        fee_ci_sequence_number            = new_references.fee_ci_sequence_number,
        ancillary_attributes              = new_references.ancillary_attributes,
        ancillary_segments                = new_references.ancillary_segments,
        enabled_flag                      = new_references.enabled_flag,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    l_rowid := NULL;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_anc_rate_segment_id               IN OUT NOCOPY NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_ancillary_attributes              IN OUT NOCOPY VARCHAR2,
    x_ancillary_segments                IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_anc_rt_sgmnts
      WHERE    anc_rate_segment_id               = x_anc_rate_segment_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_anc_rate_segment_id,
        x_fee_type,
        x_fee_cal_type,
        x_fee_ci_sequence_number,
        x_ancillary_attributes,
        x_ancillary_segments,
        x_enabled_flag,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_anc_rate_segment_id,
      x_fee_type,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_ancillary_attributes,
      x_ancillary_segments,
      x_enabled_flag,
      x_mode
    );

    l_rowid := NULL;

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
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

    DELETE FROM igs_fi_anc_rt_sgmnts
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    l_rowid := NULL;

  END delete_row;


END igs_fi_anc_rt_sgmnts_pkg;

/
