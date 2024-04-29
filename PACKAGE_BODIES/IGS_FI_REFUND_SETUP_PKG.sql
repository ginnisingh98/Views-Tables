--------------------------------------------------------
--  DDL for Package Body IGS_FI_REFUND_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_REFUND_SETUP_PKG" AS
/* $Header: IGSSIB3B.pls 115.13 2002/12/19 06:12:32 shtatiko ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_refund_setup%ROWTYPE;
  new_references igs_fi_refund_setup%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_refund_setup_id                   IN     NUMBER      DEFAULT NULL,
    x_start_date                        IN     DATE        DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_amount_high                       IN     NUMBER      DEFAULT NULL,
    x_amount_low                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 26-FEB-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_fi_refund_setup
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
    new_references.refund_setup_id                   := x_refund_setup_id;
    new_references.start_date                        := x_start_date;
    new_references.end_date                          := x_end_date;
    new_references.amount_high                       := x_amount_high;
    new_references.amount_low                        := x_amount_low;

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


  FUNCTION get_pk_for_validation (
    x_refund_setup_id                   IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 26-FEB-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_refund_setup
      WHERE    refund_setup_id = x_refund_setup_id
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

  FUNCTION check_range_overlap(
  p_start_date IN DATE,
  p_end_date  IN DATE,
  p_refund_setup_id IN NUMBER  )
  RETURN BOOLEAN AS
   /*
  ||  Created By : Sadhana.Baliga@oracle.com
  ||  Created On : 27-FEB-2002
  ||  Purpose : To ensure that tolerance limit periods do not overlap
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  	CURSOR  cur_lmt is
  		SELECT start_date ,
  		        end_date
  		FROM  igs_fi_refund_setup
  		WHERE refund_setup_id<>p_refund_setup_id OR
  			p_refund_setup_id IS NULL;
  	l_flag  BOOLEAN :=false;
    BEGIN
       FOR l_lmt IN cur_lmt LOOP
           IF (l_lmt.end_date IS NOT NULL) THEN
             -- a) period overlaps with an existing refunds period(start date is between an
  		--  existing start and end date)
                 IF (p_start_date >= l_lmt.start_date AND
  					p_start_date <= l_lmt.end_date) THEN
  			l_flag:=true;
  			EXIT;
  		 END IF;
  	       -- b) period overlaps with an existing refunds period(end date is between an
  		--  existing start and end date)
  		 IF (p_end_date IS NOT NULL) THEN
                    IF (p_end_date >= l_lmt.start_date AND
  					p_end_date <= l_lmt.end_date) THEN
  			l_flag:=true;
  			EXIT;
  		    END IF;
  		   -- c) period encompasses an existing refunds period
  		     IF (p_start_date <= l_lmt.start_date AND
  					p_end_date >= l_lmt.end_date) THEN
  			l_flag:=true;
  			EXIT;
  		     END IF;
  		 ELSE -- p_end_date is null
  		  --d)period overlaps with existing refunds period.
  		   IF (p_start_date <= l_lmt.start_date OR
  					p_start_date<= l_lmt.end_date) THEN
  			l_flag:=true;
  			EXIT;
  		   END IF;
  		 END IF;
  	   ELSE	-- l_lmt.end_date is null
  	          IF (p_start_date >=l_lmt.start_date OR
  	              NVL(p_end_date,l_lmt.start_date) >= l_lmt.start_date) THEN
  	              l_flag:=true;
  			EXIT;
  		   END IF;
           END IF;
      END LOOP;
      RETURN l_flag;
  END check_range_overlap;

  PROCEDURE  beforerowinsertupdate(
   p_inserting 	 			IN	BOOLEAN    DEFAULT NULL,
   p_updating 				IN	BOOLEAN	   DEFAULT NULL
   ) AS
    /*
  ||  Created By : Sadhana.Baliga@oracle.com
  ||  Created On : 27-FEB-2002
  ||  Purpose : Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before insert or update.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
  l_sysdate	DATE :=trunc(SYSDATE);

  BEGIN
  IF (p_inserting) THEN
    -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.refund_setup_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;

    --Start date should be greater then sysdate date.
    IF new_references.start_date < l_sysdate THEN
	fnd_message.set_name('IGS','IGS_FI_EFF_DATE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

    END IF;

    --End  date should be greater then sysdate date.
   IF new_references.end_date IS NOT NULL THEN
        IF new_references.end_date < l_sysdate THEN
          fnd_message.set_name('IGS','IGS_FI_END_DT_LESS_THAN_SD');
          igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

   --upper limit should be positive.

     IF new_references.amount_high IS NOT NULL THEN
      IF new_references.amount_high < 0 THEN
        fnd_message.set_name('IGS','IGS_FI_REFUND_AMNT_NEGATIVE');
         igs_ge_msg_stack.add;
        app_exception.raise_exception;
     END IF;
    END IF;

   --lower limit should be positive.
    IF new_references.amount_low IS NOT NULL THEN
      IF new_references.amount_low < 0 THEN
        fnd_message.set_name('IGS','IGS_FI_REFUND_AMNT_NEGATIVE');
         igs_ge_msg_stack.add;
        app_exception.raise_exception;
     END IF;
    END IF;

    --start date should be lesser than end date
    IF new_references.end_date IS NOT NULL THEN
      IF new_references.end_date < new_references.start_date THEN
        fnd_message.set_name('IGS','IGS_FI_END_DT_LESS_THAN_ST_DT');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    --Upper and lower limit both should not be null.
     IF new_references.amount_high IS NULL AND new_references.amount_low IS NULL THEN
        fnd_message.set_name('IGS','IGS_FI_REFUND_LMT_NULL');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
     ELSE
     --lower limit should be less than upper limit.
      IF new_references.amount_high IS NOT NULL AND new_references.amount_low IS NOT NULL THEN
        IF new_references.amount_low  > new_references.amount_high THEN

          fnd_message.set_name('IGS','IGS_FI_RFND_AMNT_INVALID');
          igs_ge_msg_stack.add;
        app_exception.raise_exception;
        END IF;
      END IF;
     END IF;

   --The tolerance limit ranges should not overlap
      IF ( check_range_overlap(
              new_references.start_date,
              new_references.end_date,
              new_references.refund_setup_id
           )
         ) THEN
        -- Removed the space after the message name as per Bug# 2684818 by shtatiko
        fnd_message.set_name('IGS','IGS_FI_RFND_TOL_OVERLAP');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;


    ELSIF (p_updating) THEN
      -- Call all the procedures related to Before Update.

      --start date should be lesser than end date
    IF new_references.end_date IS NOT NULL THEN
      IF new_references.end_date < new_references.start_date THEN
        fnd_message.set_name('IGS','IGS_FI_END_DT_LESS_THAN_ST_DT');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;


       --End  date should be greater then sysdate date.
   IF new_references.end_date IS NOT NULL THEN
        IF new_references.end_date < l_sysdate THEN
          fnd_message.set_name('IGS','IGS_FI_END_DT_LESS_THAN_SD');
          igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;


      --The tolerance limit ranges should not overlap
      IF ( check_range_overlap(
              new_references.start_date,
              new_references.end_date,
              new_references.refund_setup_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_FI_RFND_TOL_OVERLAP');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;

  END IF;
  END beforerowinsertupdate;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_refund_setup_id                   IN     NUMBER      DEFAULT NULL,
    x_start_date                        IN     DATE        DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_amount_high                       IN     NUMBER      DEFAULT NULL,
    x_amount_low                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 26-FEB-2002
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sbaliga	    27-feb-2002	     Included code for checking for tolerance periods
  ||				     overlap as part of refunds build#2144600
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_refund_setup_id,
      x_start_date,
      x_end_date,
      x_amount_high,
      x_amount_low,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') OR (p_action= 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
       beforerowinsertupdate(p_inserting => TRUE);
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
        -- Call all the procedures related to Before Update.
      beforerowinsertupdate(p_updating => TRUE);
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_refund_setup_id                   IN OUT NOCOPY NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_amount_high                       IN     NUMBER,
    x_amount_low                        IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 26-FEB-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_fi_refund_setup
      WHERE    refund_setup_id                   = x_refund_setup_id;

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

    SELECT    igs_fi_refund_setup_s.NEXTVAL
    INTO      x_refund_setup_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_refund_setup_id                   => x_refund_setup_id,
      x_start_date                        => x_start_date,
      x_end_date                          => x_end_date,
      x_amount_high                       => x_amount_high,
      x_amount_low                        => x_amount_low,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_refund_setup (
      refund_setup_id,
      start_date,
      end_date,
      amount_high,
      amount_low,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.refund_setup_id,
      new_references.start_date,
      new_references.end_date,
      new_references.amount_high,
      new_references.amount_low,
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

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_refund_setup_id                   IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_amount_high                       IN     NUMBER,
    x_amount_low                        IN     NUMBER
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 26-FEB-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        start_date,
        end_date,
        amount_high,
        amount_low
      FROM  igs_fi_refund_setup
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
        (tlinfo.start_date = x_start_date)
        AND ((tlinfo.end_date = x_end_date) OR ((tlinfo.end_date IS NULL) AND (X_end_date IS NULL)))
        AND ((tlinfo.amount_high = x_amount_high) OR ((tlinfo.amount_high IS NULL) AND (X_amount_high IS NULL)))
        AND ((tlinfo.amount_low = x_amount_low) OR ((tlinfo.amount_low IS NULL) AND (X_amount_low IS NULL)))
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
    x_refund_setup_id                   IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_amount_high                       IN     NUMBER,
    x_amount_low                        IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 26-FEB-2002
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
      x_refund_setup_id                   => x_refund_setup_id,
      x_start_date                        => x_start_date,
      x_end_date                          => x_end_date,
      x_amount_high                       => x_amount_high,
      x_amount_low                        => x_amount_low,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_fi_refund_setup
      SET
        start_date                        = new_references.start_date,
        end_date                          = new_references.end_date,
        amount_high                       = new_references.amount_high,
        amount_low                        = new_references.amount_low,
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
    x_refund_setup_id                   IN OUT NOCOPY NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_amount_high                       IN     NUMBER,
    x_amount_low                        IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 26-FEB-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_refund_setup
      WHERE    refund_setup_id                   = x_refund_setup_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_refund_setup_id,
        x_start_date,
        x_end_date,
        x_amount_high,
        x_amount_low,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_refund_setup_id,
      x_start_date,
      x_end_date,
      x_amount_high,
      x_amount_low,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 26-FEB-2002
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

    DELETE FROM igs_fi_refund_setup
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_refund_setup_pkg;

/
