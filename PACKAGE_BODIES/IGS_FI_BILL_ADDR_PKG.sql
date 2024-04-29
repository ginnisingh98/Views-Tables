--------------------------------------------------------
--  DDL for Package Body IGS_FI_BILL_ADDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_BILL_ADDR_PKG" AS
/* $Header: IGSSIB8B.pls 115.3 2002/11/29 04:05:40 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_bill_addr%ROWTYPE;
  new_references igs_fi_bill_addr%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_bill_addr_id                      IN     NUMBER      DEFAULT NULL,
    x_bill_id                           IN     NUMBER      DEFAULT NULL,
    x_addr_type                         IN     VARCHAR2    DEFAULT NULL,
    x_addr_line_1                       IN     VARCHAR2    DEFAULT NULL,
    x_addr_line_2                       IN     VARCHAR2    DEFAULT NULL,
    x_addr_line_3                       IN     VARCHAR2    DEFAULT NULL,
    x_addr_line_4                       IN     VARCHAR2    DEFAULT NULL,
    x_city                              IN     VARCHAR2    DEFAULT NULL,
    x_state                             IN     VARCHAR2    DEFAULT NULL,
    x_province                          IN     VARCHAR2    DEFAULT NULL,
    x_county                            IN     VARCHAR2    DEFAULT NULL,
    x_country                           IN     VARCHAR2    DEFAULT NULL,
    x_postal_code                       IN     VARCHAR2    DEFAULT NULL,
    x_delivery_point_code               IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_BILL_ADDR
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
    new_references.bill_addr_id                      := x_bill_addr_id;
    new_references.bill_id                           := x_bill_id;
    new_references.addr_type                         := x_addr_type;
    new_references.addr_line_1                       := x_addr_line_1;
    new_references.addr_line_2                       := x_addr_line_2;
    new_references.addr_line_3                       := x_addr_line_3;
    new_references.addr_line_4                       := x_addr_line_4;
    new_references.city                              := x_city;
    new_references.state                             := x_state;
    new_references.province                          := x_province;
    new_references.county                            := x_county;
    new_references.country                           := x_country;
    new_references.postal_code                       := x_postal_code;
    new_references.delivery_point_code               := x_delivery_point_code;

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
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.bill_id = new_references.bill_id)) OR
        ((new_references.bill_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_bill_pkg.get_pk_for_validation (
                new_references.bill_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_bill_addr_id                      IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_bill_addr
      WHERE    bill_addr_id = x_bill_addr_id
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


  PROCEDURE get_fk_igs_fi_bill (
    x_bill_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_bill_addr
      WHERE   ((bill_id = x_bill_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_BILL_ADDR_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_bill;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_bill_addr_id                      IN     NUMBER      DEFAULT NULL,
    x_bill_id                           IN     NUMBER      DEFAULT NULL,
    x_addr_type                         IN     VARCHAR2    DEFAULT NULL,
    x_addr_line_1                       IN     VARCHAR2    DEFAULT NULL,
    x_addr_line_2                       IN     VARCHAR2    DEFAULT NULL,
    x_addr_line_3                       IN     VARCHAR2    DEFAULT NULL,
    x_addr_line_4                       IN     VARCHAR2    DEFAULT NULL,
    x_city                              IN     VARCHAR2    DEFAULT NULL,
    x_state                             IN     VARCHAR2    DEFAULT NULL,
    x_province                          IN     VARCHAR2    DEFAULT NULL,
    x_county                            IN     VARCHAR2    DEFAULT NULL,
    x_country                           IN     VARCHAR2    DEFAULT NULL,
    x_postal_code                       IN     VARCHAR2    DEFAULT NULL,
    x_delivery_point_code               IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
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
      x_bill_addr_id,
      x_bill_id,
      x_addr_type,
      x_addr_line_1,
      x_addr_line_2,
      x_addr_line_3,
      x_addr_line_4,
      x_city,
      x_state,
      x_province,
      x_county,
      x_country,
      x_postal_code,
      x_delivery_point_code,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.bill_addr_id
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
             new_references.bill_addr_id
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
    x_bill_addr_id                      IN OUT NOCOPY NUMBER,
    x_bill_id                           IN     NUMBER,
    x_addr_type                         IN     VARCHAR2,
    x_addr_line_1                       IN     VARCHAR2,
    x_addr_line_2                       IN     VARCHAR2,
    x_addr_line_3                       IN     VARCHAR2,
    x_addr_line_4                       IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_postal_code                       IN     VARCHAR2,
    x_delivery_point_code               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_fi_bill_addr
      WHERE    bill_addr_id                      = x_bill_addr_id;

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

    SELECT    igs_fi_bill_addr_s.NEXTVAL
    INTO      x_bill_addr_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_bill_addr_id                      => x_bill_addr_id,
      x_bill_id                           => x_bill_id,
      x_addr_type                         => x_addr_type,
      x_addr_line_1                       => x_addr_line_1,
      x_addr_line_2                       => x_addr_line_2,
      x_addr_line_3                       => x_addr_line_3,
      x_addr_line_4                       => x_addr_line_4,
      x_city                              => x_city,
      x_state                             => x_state,
      x_province                          => x_province,
      x_county                            => x_county,
      x_country                           => x_country,
      x_postal_code                       => x_postal_code,
      x_delivery_point_code               => x_delivery_point_code,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_bill_addr (
      bill_addr_id,
      bill_id,
      addr_type,
      addr_line_1,
      addr_line_2,
      addr_line_3,
      addr_line_4,
      city,
      state,
      province,
      county,
      country,
      postal_code,
      delivery_point_code,
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
      new_references.bill_addr_id,
      new_references.bill_id,
      new_references.addr_type,
      new_references.addr_line_1,
      new_references.addr_line_2,
      new_references.addr_line_3,
      new_references.addr_line_4,
      new_references.city,
      new_references.state,
      new_references.province,
      new_references.county,
      new_references.country,
      new_references.postal_code,
      new_references.delivery_point_code,
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
    x_bill_addr_id                      IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_addr_type                         IN     VARCHAR2,
    x_addr_line_1                       IN     VARCHAR2,
    x_addr_line_2                       IN     VARCHAR2,
    x_addr_line_3                       IN     VARCHAR2,
    x_addr_line_4                       IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_postal_code                       IN     VARCHAR2,
    x_delivery_point_code               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        bill_id,
        addr_type,
        addr_line_1,
        addr_line_2,
        addr_line_3,
        addr_line_4,
        city,
        state,
        province,
        county,
        country,
        postal_code,
        delivery_point_code
      FROM  igs_fi_bill_addr
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
        (tlinfo.bill_id = x_bill_id)
        AND (tlinfo.addr_type = x_addr_type)
        AND (tlinfo.addr_line_1 = x_addr_line_1)
        AND ((tlinfo.addr_line_2 = x_addr_line_2) OR ((tlinfo.addr_line_2 IS NULL) AND (X_addr_line_2 IS NULL)))
        AND ((tlinfo.addr_line_3 = x_addr_line_3) OR ((tlinfo.addr_line_3 IS NULL) AND (X_addr_line_3 IS NULL)))
        AND ((tlinfo.addr_line_4 = x_addr_line_4) OR ((tlinfo.addr_line_4 IS NULL) AND (X_addr_line_4 IS NULL)))
        AND ((tlinfo.city = x_city) OR ((tlinfo.city IS NULL) AND (X_city IS NULL)))
        AND ((tlinfo.state = x_state) OR ((tlinfo.state IS NULL) AND (X_state IS NULL)))
        AND ((tlinfo.province = x_province) OR ((tlinfo.province IS NULL) AND (X_province IS NULL)))
        AND ((tlinfo.county = x_county) OR ((tlinfo.county IS NULL) AND (X_county IS NULL)))
        AND (tlinfo.country = x_country)
        AND ((tlinfo.postal_code = x_postal_code) OR ((tlinfo.postal_code IS NULL) AND (X_postal_code IS NULL)))
        AND ((tlinfo.delivery_point_code = x_delivery_point_code) OR ((tlinfo.delivery_point_code IS NULL) AND (X_delivery_point_code IS NULL)))
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
    x_bill_addr_id                      IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_addr_type                         IN     VARCHAR2,
    x_addr_line_1                       IN     VARCHAR2,
    x_addr_line_2                       IN     VARCHAR2,
    x_addr_line_3                       IN     VARCHAR2,
    x_addr_line_4                       IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_postal_code                       IN     VARCHAR2,
    x_delivery_point_code               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
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
      x_bill_addr_id                      => x_bill_addr_id,
      x_bill_id                           => x_bill_id,
      x_addr_type                         => x_addr_type,
      x_addr_line_1                       => x_addr_line_1,
      x_addr_line_2                       => x_addr_line_2,
      x_addr_line_3                       => x_addr_line_3,
      x_addr_line_4                       => x_addr_line_4,
      x_city                              => x_city,
      x_state                             => x_state,
      x_province                          => x_province,
      x_county                            => x_county,
      x_country                           => x_country,
      x_postal_code                       => x_postal_code,
      x_delivery_point_code               => x_delivery_point_code,
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

    UPDATE igs_fi_bill_addr
      SET
        bill_id                           = new_references.bill_id,
        addr_type                         = new_references.addr_type,
        addr_line_1                       = new_references.addr_line_1,
        addr_line_2                       = new_references.addr_line_2,
        addr_line_3                       = new_references.addr_line_3,
        addr_line_4                       = new_references.addr_line_4,
        city                              = new_references.city,
        state                             = new_references.state,
        province                          = new_references.province,
        county                            = new_references.county,
        country                           = new_references.country,
        postal_code                       = new_references.postal_code,
        delivery_point_code               = new_references.delivery_point_code,
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
    x_bill_addr_id                      IN OUT NOCOPY NUMBER,
    x_bill_id                           IN     NUMBER,
    x_addr_type                         IN     VARCHAR2,
    x_addr_line_1                       IN     VARCHAR2,
    x_addr_line_2                       IN     VARCHAR2,
    x_addr_line_3                       IN     VARCHAR2,
    x_addr_line_4                       IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_postal_code                       IN     VARCHAR2,
    x_delivery_point_code               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_bill_addr
      WHERE    bill_addr_id                      = x_bill_addr_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_bill_addr_id,
        x_bill_id,
        x_addr_type,
        x_addr_line_1,
        x_addr_line_2,
        x_addr_line_3,
        x_addr_line_4,
        x_city,
        x_state,
        x_province,
        x_county,
        x_country,
        x_postal_code,
        x_delivery_point_code,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_bill_addr_id,
      x_bill_id,
      x_addr_type,
      x_addr_line_1,
      x_addr_line_2,
      x_addr_line_3,
      x_addr_line_4,
      x_city,
      x_state,
      x_province,
      x_county,
      x_country,
      x_postal_code,
      x_delivery_point_code,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
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

    DELETE FROM igs_fi_bill_addr
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_bill_addr_pkg;

/
