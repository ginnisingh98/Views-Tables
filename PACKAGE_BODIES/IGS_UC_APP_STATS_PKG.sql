--------------------------------------------------------
--  DDL for Package Body IGS_UC_APP_STATS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_APP_STATS_PKG" AS
/* $Header: IGSXI07B.pls 115.10 2003/06/11 10:29:43 smaddali noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_app_stats%ROWTYPE;
  new_references igs_uc_app_stats%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_app_stat_id                       IN     NUMBER      ,
    x_app_id                            IN     NUMBER      ,
    x_app_no                            IN     NUMBER      ,
    x_starh_ethnic                      IN     NUMBER      ,
    x_starh_social_class                IN     VARCHAR2    ,
    x_starh_pocc_edu_chg_dt             IN     DATE        ,
    x_starh_pocc                        IN     VARCHAR2    ,
    x_starh_pocc_text                   IN     VARCHAR2    ,
    x_starh_last_edu_inst               IN     NUMBER      ,
    x_starh_edu_leave_date              IN     NUMBER      ,
    x_starh_lea                         IN     NUMBER      ,
    x_starx_ethnic                      IN     NUMBER      ,
    x_starx_pocc_edu_chg                IN     DATE        ,
    x_starx_pocc                        IN     VARCHAR2    ,
    x_starx_pocc_text                   IN     VARCHAR2    ,
    x_sent_to_hesa                      IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    -- Added following 3 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_starh_socio_economic              IN     NUMBER      ,
    x_starx_socio_economic              IN     NUMBER      ,
    x_starx_occ_background              IN     VARCHAR2    ,
     -- Added following  Columns as part of UCFD102Build. Bug NO: 2643048 by bayadav
    x_ivstarh_dependants	            	IN		 NUMBER		   ,
    x_ivstarh_married		                IN		 VARCHAR2	   ,
    x_ivstarx_religion		              IN		 NUMBER		   ,
    x_ivstarx_dependants		            IN		 NUMBER		   ,
    x_ivstarx_married		                IN		 VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali    10-jun-03    obsoleting timestamp columns for ucfd203 - multiple cycles build , bug#2669208 |
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_UC_APP_STATS
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
    new_references.app_stat_id                       := x_app_stat_id;
    new_references.app_id                            := x_app_id;
    new_references.app_no                            := x_app_no;
    new_references.starh_ethnic                      := x_starh_ethnic;
    new_references.starh_social_class                := x_starh_social_class;
    new_references.starh_pocc_edu_chg_dt             := x_starh_pocc_edu_chg_dt;
    new_references.starh_pocc                        := x_starh_pocc;
    new_references.starh_pocc_text                   := x_starh_pocc_text;
    new_references.starh_last_edu_inst               := x_starh_last_edu_inst;
    new_references.starh_edu_leave_date              := x_starh_edu_leave_date;
    new_references.starh_lea                         := x_starh_lea;
    new_references.starx_ethnic                      := x_starx_ethnic;
    new_references.starx_pocc_edu_chg                := x_starx_pocc_edu_chg;
    new_references.starx_pocc                        := x_starx_pocc;
    new_references.starx_pocc_text                   := x_starx_pocc_text;
    new_references.sent_to_hesa                      := x_sent_to_hesa;
    new_references.starh_socio_economic              := x_starh_socio_economic;
    new_references.starx_socio_economic              := x_starx_socio_economic;
    new_references.starx_occ_background              := x_starx_occ_background;
    new_references.ivstarh_dependants	            	 := x_ivstarh_dependants;
    new_references.ivstarh_married		               := x_ivstarh_married;
    new_references.ivstarx_religion		               := x_ivstarx_religion;
    new_references.ivstarx_dependants		           := x_ivstarx_dependants;
    new_references.ivstarx_married		               := x_ivstarx_married;


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
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.app_no
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.app_id = new_references.app_id)) OR
        ((new_references.app_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_uc_applicants_pkg.get_pk_for_validation (
                new_references.app_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_app_stat_id                       IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_app_stats
      WHERE    app_stat_id = x_app_stat_id ;

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
    x_app_no                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_app_stats
      WHERE    app_no = x_app_no
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


  PROCEDURE get_fk_igs_uc_applicants (
    x_app_id                            IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_app_stats
      WHERE   ((app_id = x_app_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UCAPST_UCAP_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_uc_applicants;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_app_stat_id                       IN     NUMBER      ,
    x_app_id                            IN     NUMBER      ,
    x_app_no                            IN     NUMBER      ,
    x_starh_ethnic                      IN     NUMBER      ,
    x_starh_social_class                IN     VARCHAR2    ,
    x_starh_pocc_edu_chg_dt             IN     DATE        ,
    x_starh_pocc                        IN     VARCHAR2    ,
    x_starh_pocc_text                   IN     VARCHAR2    ,
    x_starh_last_edu_inst               IN     NUMBER      ,
    x_starh_edu_leave_date              IN     NUMBER      ,
    x_starh_lea                         IN     NUMBER      ,
    x_starx_ethnic                      IN     NUMBER      ,
    x_starx_pocc_edu_chg                IN     DATE        ,
    x_starx_pocc                        IN     VARCHAR2    ,
    x_starx_pocc_text                   IN     VARCHAR2    ,
    x_sent_to_hesa                      IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    -- Added following 3 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_starh_socio_economic              IN     NUMBER      ,
    x_starx_socio_economic              IN     NUMBER      ,
    x_starx_occ_background              IN     VARCHAR2    ,
     -- Added following  Columns as part of UCFD102Build. Bug NO: 2643048 by bayadav
    x_ivstarh_dependants	            	IN		 NUMBER		   ,
    x_ivstarh_married		                IN		 VARCHAR2	   ,
    x_ivstarx_religion		              IN		 NUMBER		   ,
    x_ivstarx_dependants		            IN		 NUMBER		   ,
    x_ivstarx_married		                IN		 VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali    10-jun-03    obsoleting timestamp columns for ucfd203 - multiple cycles build , bug#2669208 |
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_app_stat_id,
      x_app_id,
      x_app_no,
      x_starh_ethnic,
      x_starh_social_class,
      x_starh_pocc_edu_chg_dt,
      x_starh_pocc,
      x_starh_pocc_text,
      x_starh_last_edu_inst,
      x_starh_edu_leave_date,
      x_starh_lea,
      x_starx_ethnic,
      x_starx_pocc_edu_chg,
      x_starx_pocc,
      x_starx_pocc_text,
      x_sent_to_hesa,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_starh_socio_economic,
      x_starx_socio_economic,
      x_starx_occ_background,
      x_ivstarh_dependants,
      x_ivstarh_married,
      x_ivstarx_religion,
      x_ivstarx_dependants,
      x_ivstarx_married
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.app_stat_id
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
             new_references.app_stat_id
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
    x_app_stat_id                       IN OUT NOCOPY NUMBER,
    x_app_id                            IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_starh_ethnic                      IN     NUMBER,
    x_starh_social_class                IN     VARCHAR2,
    x_starh_pocc_edu_chg_dt             IN     DATE,
    x_starh_pocc                        IN     VARCHAR2,
    x_starh_pocc_text                   IN     VARCHAR2,
    x_starh_last_edu_inst               IN     NUMBER,
    x_starh_edu_leave_date              IN     NUMBER,
    x_starh_lea                         IN     NUMBER,
    x_starx_ethnic                      IN     NUMBER,
    x_starx_pocc_edu_chg                IN     DATE,
    x_starx_pocc                        IN     VARCHAR2,
    x_starx_pocc_text                   IN     VARCHAR2,
    x_sent_to_hesa                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    -- Added following 3 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_starh_socio_economic              IN     NUMBER      ,
    x_starx_socio_economic              IN     NUMBER      ,
    x_starx_occ_background              IN     VARCHAR2    ,
     -- Added following  Columns as part of UCFD102Build. Bug NO: 2643048 by bayadav
    x_ivstarh_dependants	            	IN		 NUMBER		   ,
    x_ivstarh_married		                IN		 VARCHAR2	   ,
    x_ivstarx_religion		              IN		 NUMBER		   ,
    x_ivstarx_dependants		            IN		 NUMBER		   ,
    x_ivstarx_married		                IN		 VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali    10-jun-03    obsoleting timestamp columns for ucfd203 - multiple cycles build , bug#2669208 |
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_uc_app_stats
      WHERE    app_stat_id                       = x_app_stat_id;

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

    SELECT    igs_uc_app_stats_s.NEXTVAL
    INTO      x_app_stat_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_app_stat_id                       => x_app_stat_id,
      x_app_id                            => x_app_id,
      x_app_no                            => x_app_no,
      x_starh_ethnic                      => x_starh_ethnic,
      x_starh_social_class                => x_starh_social_class,
      x_starh_pocc_edu_chg_dt             => x_starh_pocc_edu_chg_dt,
      x_starh_pocc                        => x_starh_pocc,
      x_starh_pocc_text                   => x_starh_pocc_text,
      x_starh_last_edu_inst               => x_starh_last_edu_inst,
      x_starh_edu_leave_date              => x_starh_edu_leave_date,
      x_starh_lea                         => x_starh_lea,
      x_starx_ethnic                      => x_starx_ethnic,
      x_starx_pocc_edu_chg                => x_starx_pocc_edu_chg,
      x_starx_pocc                        => x_starx_pocc,
      x_starx_pocc_text                   => x_starx_pocc_text,
      x_sent_to_hesa                      => x_sent_to_hesa,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_starh_socio_economic              => x_starh_socio_economic,
      x_starx_socio_economic              => x_starx_socio_economic,
      x_starx_occ_background              => x_starx_occ_background,
       x_ivstarh_dependants	            	=> x_ivstarh_dependants,
      x_ivstarh_married		                => x_ivstarh_married,
      x_ivstarx_religion		              => x_ivstarx_religion,
      x_ivstarx_dependants		            => x_ivstarx_dependants,
      x_ivstarx_married		                => x_ivstarx_married
    );

    INSERT INTO igs_uc_app_stats (
      app_stat_id,
      app_id,
      app_no,
      starh_ethnic,
      starh_social_class,
      starh_pocc_edu_chg_dt,
      starh_pocc,
      starh_pocc_text,
      starh_last_edu_inst,
      starh_edu_leave_date,
      starh_lea,
      starx_ethnic,
      starx_pocc_edu_chg,
      starx_pocc,
      starx_pocc_text,
      sent_to_hesa,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      starh_socio_economic,
      starx_socio_economic,
      starx_occ_background,
      ivstarh_dependants,
      ivstarh_married,
      ivstarx_religion,
      ivstarx_dependants,
      ivstarx_married
    ) VALUES (
      new_references.app_stat_id,
      new_references.app_id,
      new_references.app_no,
      new_references.starh_ethnic,
      new_references.starh_social_class,
      new_references.starh_pocc_edu_chg_dt,
      new_references.starh_pocc,
      new_references.starh_pocc_text,
      new_references.starh_last_edu_inst,
      new_references.starh_edu_leave_date,
      new_references.starh_lea,
      new_references.starx_ethnic,
      new_references.starx_pocc_edu_chg,
      new_references.starx_pocc,
      new_references.starx_pocc_text,
      new_references.sent_to_hesa,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.starh_socio_economic,
      new_references.starx_socio_economic,
      new_references.starx_occ_background,
      new_references.ivstarh_dependants,
      new_references.ivstarh_married,
      new_references.ivstarx_religion,
      new_references.ivstarx_dependants,
      new_references.ivstarx_married
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
    x_app_stat_id                       IN     NUMBER,
    x_app_id                            IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_starh_ethnic                      IN     NUMBER,
    x_starh_social_class                IN     VARCHAR2,
    x_starh_pocc_edu_chg_dt             IN     DATE,
    x_starh_pocc                        IN     VARCHAR2,
    x_starh_pocc_text                   IN     VARCHAR2,
    x_starh_last_edu_inst               IN     NUMBER,
    x_starh_edu_leave_date              IN     NUMBER,
    x_starh_lea                         IN     NUMBER,
    x_starx_ethnic                      IN     NUMBER,
    x_starx_pocc_edu_chg                IN     DATE,
    x_starx_pocc                        IN     VARCHAR2,
    x_starx_pocc_text                   IN     VARCHAR2,
    x_sent_to_hesa                      IN     VARCHAR2,
    -- Added following 3 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_starh_socio_economic              IN     NUMBER      ,
    x_starx_socio_economic              IN     NUMBER      ,
    x_starx_occ_background              IN     VARCHAR2    ,
     -- Added following  Columns as part of UCFD102Build. Bug NO: 2643048 by bayadav
    x_ivstarh_dependants	            	IN		 NUMBER		   ,
    x_ivstarh_married		                IN		 VARCHAR2	   ,
    x_ivstarx_religion		              IN		 NUMBER		   ,
    x_ivstarx_dependants		            IN		 NUMBER		   ,
    x_ivstarx_married		                IN		 VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali    10-jun-03    obsoleting timestamp columns for ucfd203 - multiple cycles build , bug#2669208 |
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        app_id,
        app_no,
        starh_ethnic,
        starh_social_class,
        starh_pocc_edu_chg_dt,
        starh_pocc,
        starh_pocc_text,
        starh_last_edu_inst,
        starh_edu_leave_date,
        starh_lea,
        starx_ethnic,
        starx_pocc_edu_chg,
        starx_pocc,
        starx_pocc_text,
        sent_to_hesa,
        starh_socio_economic,
        starx_socio_economic,
        starx_occ_background,
        ivstarh_dependants,
        ivstarh_married,
        ivstarx_religion,
        ivstarx_dependants,
        ivstarx_married
      FROM  igs_uc_app_stats
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
        (tlinfo.app_id = x_app_id)
        AND (tlinfo.app_no = x_app_no)
        AND ((tlinfo.starh_ethnic = x_starh_ethnic) OR ((tlinfo.starh_ethnic IS NULL) AND (X_starh_ethnic IS NULL)))
        AND ((tlinfo.starh_social_class = x_starh_social_class) OR ((tlinfo.starh_social_class IS NULL) AND (X_starh_social_class IS NULL)))
        AND ((tlinfo.starh_pocc_edu_chg_dt = x_starh_pocc_edu_chg_dt) OR ((tlinfo.starh_pocc_edu_chg_dt IS NULL) AND (X_starh_pocc_edu_chg_dt IS NULL)))
        AND ((tlinfo.starh_pocc = x_starh_pocc) OR ((tlinfo.starh_pocc IS NULL) AND (X_starh_pocc IS NULL)))
        AND ((tlinfo.starh_pocc_text = x_starh_pocc_text) OR ((tlinfo.starh_pocc_text IS NULL) AND (X_starh_pocc_text IS NULL)))
        AND ((tlinfo.starh_last_edu_inst = x_starh_last_edu_inst) OR ((tlinfo.starh_last_edu_inst IS NULL) AND (X_starh_last_edu_inst IS NULL)))
        AND ((tlinfo.starh_edu_leave_date = x_starh_edu_leave_date) OR ((tlinfo.starh_edu_leave_date IS NULL) AND (X_starh_edu_leave_date IS NULL)))
        AND ((tlinfo.starh_lea = x_starh_lea) OR ((tlinfo.starh_lea IS NULL) AND (X_starh_lea IS NULL)))
        AND ((tlinfo.starx_ethnic = x_starx_ethnic) OR ((tlinfo.starx_ethnic IS NULL) AND (X_starx_ethnic IS NULL)))
        AND ((tlinfo.starx_pocc_edu_chg = x_starx_pocc_edu_chg) OR ((tlinfo.starx_pocc_edu_chg IS NULL) AND (X_starx_pocc_edu_chg IS NULL)))
        AND ((tlinfo.starx_pocc = x_starx_pocc) OR ((tlinfo.starx_pocc IS NULL) AND (X_starx_pocc IS NULL)))
        AND ((tlinfo.starx_pocc_text = x_starx_pocc_text) OR ((tlinfo.starx_pocc_text IS NULL) AND (X_starx_pocc_text IS NULL)))
        AND (tlinfo.sent_to_hesa = x_sent_to_hesa)
        AND ((tlinfo.starh_socio_economic = x_starh_socio_economic) OR ((tlinfo.starh_socio_economic IS NULL) AND ( x_starh_socio_economic IS NULL)))
        AND ((tlinfo.starx_socio_economic = x_starx_socio_economic) OR ((tlinfo.starx_socio_economic IS NULL) AND ( x_starx_socio_economic IS NULL)))
        AND ((tlinfo.starx_occ_background = x_starx_occ_background) OR ((tlinfo.starx_occ_background IS NULL) AND ( x_starx_occ_background IS NULL)))
        AND ((tlinfo.ivstarh_dependants = x_ivstarh_dependants) OR ((tlinfo.ivstarh_dependants IS NULL) AND ( x_ivstarh_dependants IS NULL)))
        AND ((tlinfo.ivstarh_married = x_ivstarh_married) OR ((tlinfo.ivstarh_married IS NULL) AND ( x_ivstarh_married IS NULL)))
        AND ((tlinfo.ivstarx_religion = x_ivstarx_religion) OR ((tlinfo.ivstarx_religion IS NULL) AND ( x_ivstarx_religion IS NULL)))
        AND ((tlinfo.ivstarx_dependants = x_ivstarx_dependants) OR ((tlinfo.ivstarx_dependants IS NULL) AND ( x_ivstarx_dependants IS NULL)))
        AND ((tlinfo.ivstarx_married = x_ivstarx_married) OR ((tlinfo.ivstarx_married IS NULL) AND ( x_ivstarx_married IS NULL)))
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
    x_app_stat_id                       IN     NUMBER,
    x_app_id                            IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_starh_ethnic                      IN     NUMBER,
    x_starh_social_class                IN     VARCHAR2,
    x_starh_pocc_edu_chg_dt             IN     DATE,
    x_starh_pocc                        IN     VARCHAR2,
    x_starh_pocc_text                   IN     VARCHAR2,
    x_starh_last_edu_inst               IN     NUMBER,
    x_starh_edu_leave_date              IN     NUMBER,
    x_starh_lea                         IN     NUMBER,
    x_starx_ethnic                      IN     NUMBER,
    x_starx_pocc_edu_chg                IN     DATE,
    x_starx_pocc                        IN     VARCHAR2,
    x_starx_pocc_text                   IN     VARCHAR2,
    x_sent_to_hesa                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    -- Added following 3 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_starh_socio_economic              IN     NUMBER      ,
    x_starx_socio_economic              IN     NUMBER      ,
    x_starx_occ_background              IN     VARCHAR2    ,
     -- Added following  Columns as part of UCFD102Build. Bug NO: 2643048 by bayadav
    x_ivstarh_dependants	            	IN		 NUMBER		   ,
    x_ivstarh_married		                IN		 VARCHAR2	   ,
    x_ivstarx_religion		              IN		 NUMBER		   ,
    x_ivstarx_dependants		            IN		 NUMBER		   ,
    x_ivstarx_married		                IN		 VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali    10-jun-03    obsoleting timestamp columns for ucfd203 - multiple cycles build , bug#2669208 |
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
      x_app_stat_id                       => x_app_stat_id,
      x_app_id                            => x_app_id,
      x_app_no                            => x_app_no,
      x_starh_ethnic                      => x_starh_ethnic,
      x_starh_social_class                => x_starh_social_class,
      x_starh_pocc_edu_chg_dt             => x_starh_pocc_edu_chg_dt,
      x_starh_pocc                        => x_starh_pocc,
      x_starh_pocc_text                   => x_starh_pocc_text,
      x_starh_last_edu_inst               => x_starh_last_edu_inst,
      x_starh_edu_leave_date              => x_starh_edu_leave_date,
      x_starh_lea                         => x_starh_lea,
      x_starx_ethnic                      => x_starx_ethnic,
      x_starx_pocc_edu_chg                => x_starx_pocc_edu_chg,
      x_starx_pocc                        => x_starx_pocc,
      x_starx_pocc_text                   => x_starx_pocc_text,
      x_sent_to_hesa                      => x_sent_to_hesa,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_starh_socio_economic              => x_starh_socio_economic,
      x_starx_socio_economic              => x_starx_socio_economic,
      x_starx_occ_background              => x_starx_occ_background,
      x_ivstarh_dependants	            	=> x_ivstarh_dependants,
      x_ivstarh_married		                => x_ivstarh_married,
      x_ivstarx_religion		              => x_ivstarx_religion,
      x_ivstarx_dependants		            => x_ivstarx_dependants,
      x_ivstarx_married		                => x_ivstarx_married
    );

    UPDATE igs_uc_app_stats
      SET
        app_id                            = new_references.app_id,
        app_no                            = new_references.app_no,
        starh_ethnic                      = new_references.starh_ethnic,
        starh_social_class                = new_references.starh_social_class,
        starh_pocc_edu_chg_dt             = new_references.starh_pocc_edu_chg_dt,
        starh_pocc                        = new_references.starh_pocc,
        starh_pocc_text                   = new_references.starh_pocc_text,
        starh_last_edu_inst               = new_references.starh_last_edu_inst,
        starh_edu_leave_date              = new_references.starh_edu_leave_date,
        starh_lea                         = new_references.starh_lea,
        starx_ethnic                      = new_references.starx_ethnic,
        starx_pocc_edu_chg                = new_references.starx_pocc_edu_chg,
        starx_pocc                        = new_references.starx_pocc,
        starx_pocc_text                   = new_references.starx_pocc_text,
        sent_to_hesa                      = new_references.sent_to_hesa,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        starh_socio_economic              = new_references.starh_socio_economic,
        starx_socio_economic              = new_references.starx_socio_economic,
        starx_occ_background              = new_references.starx_occ_background,
          -- Added following  Columns as part of UCFD102Build. Bug NO: 2643048 by bayadav
        ivstarh_dependants	            	= new_references.ivstarh_dependants,
        ivstarh_married		                = new_references.ivstarh_married,
        ivstarx_religion		              = new_references.ivstarx_religion,
        ivstarx_dependants		            = new_references.ivstarx_dependants,
        ivstarx_married		                = new_references.ivstarx_married
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_stat_id                       IN OUT NOCOPY NUMBER,
    x_app_id                            IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_starh_ethnic                      IN     NUMBER,
    x_starh_social_class                IN     VARCHAR2,
    x_starh_pocc_edu_chg_dt             IN     DATE,
    x_starh_pocc                        IN     VARCHAR2,
    x_starh_pocc_text                   IN     VARCHAR2,
    x_starh_last_edu_inst               IN     NUMBER,
    x_starh_edu_leave_date              IN     NUMBER,
    x_starh_lea                         IN     NUMBER,
    x_starx_ethnic                      IN     NUMBER,
    x_starx_pocc_edu_chg                IN     DATE,
    x_starx_pocc                        IN     VARCHAR2,
    x_starx_pocc_text                   IN     VARCHAR2,
    x_sent_to_hesa                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    -- Added following 3 Columns as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_starh_socio_economic              IN     NUMBER      ,
    x_starx_socio_economic              IN     NUMBER      ,
    x_starx_occ_background              IN     VARCHAR2    ,
     -- Added following  Columns as part of UCFD102Build. Bug NO: 2643048 by bayadav
    x_ivstarh_dependants	            	IN		 NUMBER		   ,
    x_ivstarh_married		                IN		 VARCHAR2	   ,
    x_ivstarx_religion		              IN		 NUMBER		   ,
    x_ivstarx_dependants		            IN		 NUMBER		   ,
    x_ivstarx_married		                IN		 VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali    10-jun-03    obsoleting timestamp columns for ucfd203 - multiple cycles build , bug#2669208 |
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_app_stats
      WHERE    app_stat_id  = x_app_stat_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_app_stat_id,
        x_app_id,
        x_app_no,
        x_starh_ethnic,
        x_starh_social_class,
        x_starh_pocc_edu_chg_dt,
        x_starh_pocc,
        x_starh_pocc_text,
        x_starh_last_edu_inst,
        x_starh_edu_leave_date,
        x_starh_lea,
        x_starx_ethnic,
        x_starx_pocc_edu_chg,
        x_starx_pocc,
        x_starx_pocc_text,
        x_sent_to_hesa,
        x_mode,
        x_starh_socio_economic,
        x_starx_socio_economic,
        x_starx_occ_background,
        x_ivstarh_dependants,
        x_ivstarh_married,
        x_ivstarx_religion,
        x_ivstarx_dependants,
        x_ivstarx_married
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_app_stat_id,
      x_app_id,
      x_app_no,
      x_starh_ethnic,
      x_starh_social_class,
      x_starh_pocc_edu_chg_dt,
      x_starh_pocc,
      x_starh_pocc_text,
      x_starh_last_edu_inst,
      x_starh_edu_leave_date,
      x_starh_lea,
      x_starx_ethnic,
      x_starx_pocc_edu_chg,
      x_starx_pocc,
      x_starx_pocc_text,
      x_sent_to_hesa,
      x_mode,
      x_starh_socio_economic,
      x_starx_socio_economic,
      x_starx_occ_background ,
      x_ivstarh_dependants,
      x_ivstarh_married,
      x_ivstarx_religion,
      x_ivstarx_dependants,
      x_ivstarx_married
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
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

    DELETE FROM igs_uc_app_stats
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_app_stats_pkg;

/
