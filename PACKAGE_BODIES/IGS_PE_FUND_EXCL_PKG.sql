--------------------------------------------------------
--  DDL for Package Body IGS_PE_FUND_EXCL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_FUND_EXCL_PKG" AS
/* $Header: IGSNI98B.pls 115.4 2002/11/29 01:37:42 nsidana noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pe_fund_excl%ROWTYPE;
  new_references igs_pe_fund_excl%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_fund_excl_id                      IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_encumbrance_type                  IN     VARCHAR2,
    x_pen_start_dt                      IN     DATE,
    x_s_encmb_effect_type               IN     VARCHAR2,
    x_pee_start_dt                      IN     DATE,
    x_pee_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_pfe_start_dt                      IN     DATE,
    x_expiry_dt                         IN     DATE,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 09-OCT-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_fund_excl
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
    new_references.fund_excl_id                      := x_fund_excl_id;
    new_references.person_id                         := x_person_id;
    new_references.encumbrance_type                  := x_encumbrance_type;
    new_references.pen_start_dt                      := x_pen_start_dt;
    new_references.s_encmb_effect_type               := x_s_encmb_effect_type;
    new_references.pee_start_dt                      := x_pee_start_dt;
    new_references.pee_sequence_number               := x_pee_sequence_number;
    new_references.fund_code                         := x_fund_code;
    new_references.pfe_start_dt                      := x_pfe_start_dt;
    new_references.expiry_dt                         := x_expiry_dt;

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
  ||  Created By : prabhat.patel
  ||  Created On : 09-OCT-2002
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.person_id,
           new_references.encumbrance_type,
           new_references.pen_start_dt,
           new_references.s_encmb_effect_type,
           new_references.pee_start_dt,
           new_references.pee_sequence_number,
           new_references.fund_code,
           new_references.pfe_start_dt
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 09-OCT-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.fund_code = new_references.fund_code)) OR
        ((new_references.fund_code IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_fund_cat_pkg.get_uk_For_validation (
                new_references.fund_code
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.encumbrance_type = new_references.encumbrance_type) AND
         (old_references.pen_start_dt = new_references.pen_start_dt) AND
         (old_references.s_encmb_effect_type = new_references.s_encmb_effect_type) AND
         (old_references.pee_start_dt = new_references.pee_start_dt) AND
         (old_references.pee_sequence_number = new_references.pee_sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.encumbrance_type IS NULL) OR
         (new_references.pen_start_dt IS NULL) OR
         (new_references.s_encmb_effect_type IS NULL) OR
         (new_references.pee_start_dt IS NULL) OR
         (new_references.pee_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pe_persenc_effct_pkg.get_pk_for_validation (
                new_references.person_id,
                new_references.encumbrance_type,
                new_references.pen_start_dt,
                new_references.s_encmb_effect_type,
                new_references.pee_start_dt,
                new_references.pee_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_fund_excl_id                      IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 09-OCT-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_fund_excl
      WHERE    fund_excl_id = x_fund_excl_id
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
    x_person_id                         IN     NUMBER,
    x_encumbrance_type                  IN     VARCHAR2,
    x_pen_start_dt                      IN     DATE,
    x_s_encmb_effect_type               IN     VARCHAR2,
    x_pee_start_dt                      IN     DATE,
    x_pee_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_pfe_start_dt                      IN     DATE
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 09-OCT-2002
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_fund_excl
      WHERE    person_id = x_person_id
      AND      encumbrance_type = x_encumbrance_type
      AND      pen_start_dt = x_pen_start_dt
      AND      s_encmb_effect_type = x_s_encmb_effect_type
      AND      pee_start_dt = x_pee_start_dt
      AND      pee_sequence_number = x_pee_sequence_number
      AND      fund_code = x_fund_code
      AND      pfe_start_dt = x_pfe_start_dt
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


  PROCEDURE get_ufk_igf_aw_fund_cat (
    x_fund_code                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 09-OCT-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_fund_excl
      WHERE   ((fund_code = x_fund_code));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PE_FCAT_PEE_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igf_aw_fund_cat;


  PROCEDURE get_fk_igs_pe_persenc_effct (
    x_person_id                         IN     NUMBER,
    x_encumbrance_type                  IN     VARCHAR2,
    x_pen_start_dt                      IN     DATE,
    x_s_encmb_effect_type               IN     VARCHAR2,
    x_pee_start_dt                      IN     DATE,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 09-OCT-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_fund_excl
      WHERE   ((encumbrance_type = x_encumbrance_type) AND
               (pee_sequence_number = x_sequence_number) AND
               (pee_start_dt = x_pee_start_dt) AND
               (pen_start_dt = x_pen_start_dt) AND
               (person_id = x_person_id) AND
               (s_encmb_effect_type = x_s_encmb_effect_type));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PE_PFE_PEE_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pe_persenc_effct;

  PROCEDURE BeforeRowInsertUpdate(
     p_inserting IN BOOLEAN,
     p_updating IN BOOLEAN,
     p_deleting IN BOOLEAN
    ) AS

	l_message_name  VARCHAR2(30);

  BEGIN
         -- Validate that start date is not less than the current date.
        IF (new_references.pfe_start_dt IS NOT NULL) AND
                (p_inserting OR (p_updating AND
                (old_references.pfe_start_dt <> new_references.pfe_start_dt)))
                THEN
                IF igs_en_val_pce.enrp_val_encmb_dt (
                                new_references.pfe_start_dt,
                                l_message_name) = FALSE THEN
                       FND_MESSAGE.SET_NAME('IGS', l_message_name);
                       IGS_GE_MSG_STACK.ADD;
                       APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;
        END IF;

        -- Validate that start date is not less than the parent IGS_PE_PERSON
        -- Encumbrance Effect start date.
        IF p_inserting THEN
               IF igs_en_val_pce.enrp_val_encmb_dts (
                                new_references.pee_start_dt,
                                new_references.pfe_start_dt,
                                l_message_name) = FALSE THEN
                      FND_MESSAGE.SET_NAME('IGS', l_message_name);
                      IGS_GE_MSG_STACK.ADD;
                      APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;
        END IF;

        -- Validate that if expiry date is specified, then expiry date  is not
        -- less than the start date.
        IF (new_references.expiry_dt IS NOT NULL) AND
                (p_inserting OR (p_updating AND
                (NVL(old_references.expiry_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))
                <> new_references.expiry_dt)))
                THEN
				IF igs_en_val_pce.enrp_val_strt_exp_dt (
                                new_references.pfe_start_dt,
                                new_references.expiry_dt,
                                l_message_name) = FALSE THEN
                          FND_MESSAGE.SET_NAME('IGS', l_message_name);
                          IGS_GE_MSG_STACK.ADD;
                          APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;

				IF igs_en_val_pce.enrp_val_encmb_dt (
                                new_references.expiry_dt,
                                l_message_name) = FALSE THEN
                         FND_MESSAGE.SET_NAME('IGS', l_message_name);
                         IGS_GE_MSG_STACK.ADD;
                         APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;
        END IF;


        -- Validate that records for this table can be created for the encumbrance
        -- effect type.
        IF p_inserting THEN
                IF new_references.s_encmb_effect_type NOT IN ('EX_AWD','EX_DISB','EX_SP_AWD','EX_SP_DISB') THEN
                      FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_CANT_CREATE_REC_ENCUMB');
                      IGS_GE_MSG_STACK.ADD;
                      APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;
        END IF;

  END BeforeRowInsertUpdate;

  PROCEDURE AfterRowInsertUpdateDelete(
     p_inserting IN BOOLEAN,
     p_updating IN BOOLEAN,
     p_deleting IN BOOLEAN
    ) IS
	 l_check         VARCHAR2(1);

     CURSOR fund_exclusion_cur IS
     SELECT 'X'
     FROM  igs_pe_fund_excl
     WHERE person_id = new_references.person_id AND
           encumbrance_type        = new_references.encumbrance_type    AND
           pen_start_dt            = new_references.pen_start_dt        AND
           s_encmb_effect_type     = new_references.s_encmb_effect_type AND
           pee_start_dt            = new_references.pee_start_dt        AND
           fund_code               = new_references.fund_code     AND
		   expiry_dt IS NULL AND
           pfe_start_dt            <>  new_references.pfe_start_dt;

  BEGIN

     OPEN fund_exclusion_cur;
	 FETCH fund_exclusion_cur INTO l_check;
	   IF fund_exclusion_cur%FOUND THEN
            CLOSE fund_exclusion_cur;
            FND_MESSAGE.SET_NAME('IGS', 'IGS_PE_FUND_EXCL_OPEN');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
	   END IF;
     CLOSE fund_exclusion_cur;

  END AfterRowInsertUpdateDelete;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_fund_excl_id                      IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_encumbrance_type                  IN     VARCHAR2,
    x_pen_start_dt                      IN     DATE,
    x_s_encmb_effect_type               IN     VARCHAR2,
    x_pee_start_dt                      IN     DATE,
    x_pee_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_pfe_start_dt                      IN     DATE,
    x_expiry_dt                         IN     DATE,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 09-OCT-2002
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
      x_fund_excl_id,
      x_person_id,
      x_encumbrance_type,
      x_pen_start_dt,
      x_s_encmb_effect_type,
      x_pee_start_dt,
      x_pee_sequence_number,
      x_fund_code,
      x_pfe_start_dt,
      x_expiry_dt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.

	  	  beforerowinsertupdate(
           p_inserting => TRUE,
           p_updating  => FALSE,
           p_deleting  => FALSE);

      IF ( get_pk_for_validation(
             new_references.fund_excl_id
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
	  	  beforerowinsertupdate(
           p_inserting => FALSE,
           p_updating  => TRUE,
           p_deleting  => FALSE);

      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
	  	  beforerowinsertupdate(
           p_inserting => TRUE,
           p_updating  => FALSE,
           p_deleting  => FALSE);

      IF ( get_pk_for_validation (
             new_references.fund_excl_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN

		  beforerowinsertupdate(
           p_inserting => FALSE,
           p_updating  => TRUE,
           p_deleting  => FALSE);

      check_uniqueness;
    END IF;

  END before_dml;


  PROCEDURE After_DML (
    p_action IN VARCHAR2
  ) AS

  BEGIN

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsertUpdateDelete
	  ( p_inserting => TRUE,
	    p_updating  => FALSE,
		p_deleting  => FALSE);

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdateDelete
	  ( p_inserting => FALSE,
	    p_updating  => TRUE,
		p_deleting  => FALSE);

    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      NULL;
    END IF;

  END After_DML;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fund_excl_id                      IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_encumbrance_type                  IN     VARCHAR2,
    x_pen_start_dt                      IN     DATE,
    x_s_encmb_effect_type               IN     VARCHAR2,
    x_pee_start_dt                      IN     DATE,
    x_pee_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_pfe_start_dt                      IN     DATE,
    x_expiry_dt                         IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 09-OCT-2002
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
      x_fund_excl_id                      => x_fund_excl_id,
      x_person_id                         => x_person_id,
      x_encumbrance_type                  => x_encumbrance_type,
      x_pen_start_dt                      => x_pen_start_dt,
      x_s_encmb_effect_type               => x_s_encmb_effect_type,
      x_pee_start_dt                      => x_pee_start_dt,
      x_pee_sequence_number               => x_pee_sequence_number,
      x_fund_code                         => x_fund_code,
      x_pfe_start_dt                      => x_pfe_start_dt,
      x_expiry_dt                         => x_expiry_dt,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_pe_fund_excl (
      fund_excl_id,
      person_id,
      encumbrance_type,
      pen_start_dt,
      s_encmb_effect_type,
      pee_start_dt,
      pee_sequence_number,
      fund_code,
      pfe_start_dt,
      expiry_dt,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_pe_fund_excl_s.NEXTVAL,
      new_references.person_id,
      new_references.encumbrance_type,
      new_references.pen_start_dt,
      new_references.s_encmb_effect_type,
      new_references.pee_start_dt,
      new_references.pee_sequence_number,
      new_references.fund_code,
      new_references.pfe_start_dt,
      new_references.expiry_dt,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, fund_excl_id INTO x_rowid, x_fund_excl_id;

    IF x_rowid IS NULL THEN
	   RAISE NO_DATA_FOUND;
    END IF;

    After_DML(
      p_action => 'INSERT'
     );

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_fund_excl_id                      IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_encumbrance_type                  IN     VARCHAR2,
    x_pen_start_dt                      IN     DATE,
    x_s_encmb_effect_type               IN     VARCHAR2,
    x_pee_start_dt                      IN     DATE,
    x_pee_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_pfe_start_dt                      IN     DATE,
    x_expiry_dt                         IN     DATE
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 09-OCT-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        encumbrance_type,
        pen_start_dt,
        s_encmb_effect_type,
        pee_start_dt,
        pee_sequence_number,
        fund_code,
        pfe_start_dt,
        expiry_dt
      FROM  igs_pe_fund_excl
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
        (tlinfo.person_id = x_person_id)
        AND (tlinfo.encumbrance_type = x_encumbrance_type)
        AND (tlinfo.pen_start_dt = x_pen_start_dt)
        AND (tlinfo.s_encmb_effect_type = x_s_encmb_effect_type)
        AND (tlinfo.pee_start_dt = x_pee_start_dt)
        AND (tlinfo.pee_sequence_number = x_pee_sequence_number)
        AND (tlinfo.fund_code = x_fund_code)
        AND (tlinfo.pfe_start_dt = x_pfe_start_dt)
        AND ((tlinfo.expiry_dt = x_expiry_dt) OR ((tlinfo.expiry_dt IS NULL) AND (X_expiry_dt IS NULL)))
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
    x_fund_excl_id                      IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_encumbrance_type                  IN     VARCHAR2,
    x_pen_start_dt                      IN     DATE,
    x_s_encmb_effect_type               IN     VARCHAR2,
    x_pee_start_dt                      IN     DATE,
    x_pee_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_pfe_start_dt                      IN     DATE,
    x_expiry_dt                         IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 09-OCT-2002
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
      x_fund_excl_id                      => x_fund_excl_id,
      x_person_id                         => x_person_id,
      x_encumbrance_type                  => x_encumbrance_type,
      x_pen_start_dt                      => x_pen_start_dt,
      x_s_encmb_effect_type               => x_s_encmb_effect_type,
      x_pee_start_dt                      => x_pee_start_dt,
      x_pee_sequence_number               => x_pee_sequence_number,
      x_fund_code                         => x_fund_code,
      x_pfe_start_dt                      => x_pfe_start_dt,
      x_expiry_dt                         => x_expiry_dt,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_pe_fund_excl
      SET
        person_id                         = new_references.person_id,
        encumbrance_type                  = new_references.encumbrance_type,
        pen_start_dt                      = new_references.pen_start_dt,
        s_encmb_effect_type               = new_references.s_encmb_effect_type,
        pee_start_dt                      = new_references.pee_start_dt,
        pee_sequence_number               = new_references.pee_sequence_number,
        fund_code                         = new_references.fund_code,
        pfe_start_dt                      = new_references.pfe_start_dt,
        expiry_dt                         = new_references.expiry_dt,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

	After_DML(
      p_action => 'UPDATE'
     );

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fund_excl_id                      IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_encumbrance_type                  IN     VARCHAR2,
    x_pen_start_dt                      IN     DATE,
    x_s_encmb_effect_type               IN     VARCHAR2,
    x_pee_start_dt                      IN     DATE,
    x_pee_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_pfe_start_dt                      IN     DATE,
    x_expiry_dt                         IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 09-OCT-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pe_fund_excl
      WHERE    fund_excl_id                      = x_fund_excl_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_fund_excl_id,
        x_person_id,
        x_encumbrance_type,
        x_pen_start_dt,
        x_s_encmb_effect_type,
        x_pee_start_dt,
        x_pee_sequence_number,
        x_fund_code,
        x_pfe_start_dt,
        x_expiry_dt,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_fund_excl_id,
      x_person_id,
      x_encumbrance_type,
      x_pen_start_dt,
      x_s_encmb_effect_type,
      x_pee_start_dt,
      x_pee_sequence_number,
      x_fund_code,
      x_pfe_start_dt,
      x_expiry_dt,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 09-OCT-2002
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

    DELETE FROM igs_pe_fund_excl
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_pe_fund_excl_pkg;

/
