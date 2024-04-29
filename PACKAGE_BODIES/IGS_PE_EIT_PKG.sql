--------------------------------------------------------
--  DDL for Package Body IGS_PE_EIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_EIT_PKG" AS
/* $Header: IGSNI87B.pls 120.4 2005/10/17 02:21:58 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pe_eit%ROWTYPE;
  new_references igs_pe_eit%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_pe_eit_id                         IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_information_type                  IN     VARCHAR2    DEFAULT NULL,
    x_pei_information1                  IN     VARCHAR2    DEFAULT NULL,
    x_pei_information2                  IN     VARCHAR2    DEFAULT NULL,
    x_pei_information3                  IN     VARCHAR2    DEFAULT NULL,
    x_pei_information4                  IN     VARCHAR2    DEFAULT NULL,
    x_pei_information5                  IN     VARCHAR2    DEFAULT NULL,
    x_start_date                        IN     DATE        DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_eit
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
    new_references.pe_eit_id                         := x_pe_eit_id;
    new_references.person_id                         := x_person_id;
    new_references.information_type                  := x_information_type;
    new_references.pei_information1                  := x_pei_information1;
    new_references.pei_information2                  := x_pei_information2;
    new_references.pei_information3                  := x_pei_information3;
    new_references.pei_information4                  := x_pei_information4;
    new_references.pei_information5                  := x_pei_information5;
    new_references.start_date                        := x_start_date;
    new_references.end_date                          := x_end_date;

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
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.person_id,
           new_references.information_type,
           new_references.start_date
         )
       ) THEN
	      IF new_references.information_type = 'PE_STAT_RES_STATE' THEN
		 FND_MESSAGE.SET_NAME ('IGS','IGS_PE_STATE_DUP_EXISTS');
		 igs_ge_msg_stack.add;
                 app_exception.raise_exception;
	      ELSIF new_references.information_type = 'PE_STAT_RES_COUNTRY' THEN
		 FND_MESSAGE.SET_NAME ('IGS','IGS_PE_COUNTRY_DUP_EXISTS');
		 igs_ge_msg_stack.add;
                 app_exception.raise_exception;
	      ELSE
		    fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
		    igs_ge_msg_stack.add;
		    app_exception.raise_exception;
	     END IF;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pe_person_pkg.get_pk_for_validation (
                new_references.person_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_pe_eit_id                         IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_eit
      WHERE    pe_eit_id = x_pe_eit_id
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
    x_information_type                  IN     VARCHAR2,
    x_start_date                        IN     DATE
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_eit
      WHERE    person_id = x_person_id
      AND      information_type = x_information_type
      AND      start_date = x_start_date
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


  PROCEDURE get_fk_hz_parties (
    x_party_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_eit
      WHERE   ((person_id = x_party_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PE_PEIT_HZ_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_hz_parties;



 PROCEDURE BeforeRowInsertUpdate(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) as
  ------------------------------------------------------------------------------------------
  --Created by  : vredkar
  --Date created: 18-JUL-2005
  --
  --Purpose:
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ----------------------------------------------------------------------------------------------

  l_bth_dt IGS_PE_PERSON_BASE_V.birth_date%TYPE;
  l_default_date DATE := TO_DATE('4712/12/31','YYYY/MM/DD');
  v_st_res    VARCHAR2(60) ;

  CURSOR validate_brth_dt(cp_person_id NUMBER) IS
  SELECT birth_date
  FROM  IGS_PE_PERSON_BASE_V
  WHERE person_id = cp_person_id ;

  CURSOR validate_dt_overlap(cp_person_id NUMBER, cp_pe_eit_id NUMBER, cp_information_type VARCHAR2,
                             cp_start_date DATE, cp_end_date DATE) IS
  SELECT 'X'
  FROM igs_pe_eit
  WHERE person_id= cp_person_id
  AND information_type = cp_information_type
  AND cp_pe_eit_id <> pe_eit_id
  AND (cp_start_date between start_date AND NVL(end_date,l_default_date)
  OR cp_end_date between start_date AND NVL(end_date,l_default_date)
  OR (cp_start_date <= START_DATE
       AND NVL(cp_end_date,l_default_date) >= NVL(END_DATE,l_default_date)) );

  l_Overlap_check VARCHAR2(1);
  l_inf_type VARCHAR2(100);
  BEGIN


       IF p_inserting OR p_updating THEN
	  OPEN validate_brth_dt(new_references.person_id);
	  FETCH validate_brth_dt INTO  l_bth_dt;
	  CLOSE validate_brth_dt;

	  IF new_references.END_DATE IS NOT NULL AND new_references.END_DATE <  new_references.START_DATE  THEN
	     FND_MESSAGE.SET_NAME('IGS','IGS_FI_ST_DT_LE_END_DT');
	     IGS_GE_MSG_STACK.ADD;
	     APP_EXCEPTION.RAISE_EXCEPTION;

	  ELSIF l_bth_dt IS NOT NULL AND l_bth_dt >  new_references.START_DATE  THEN
	     FND_MESSAGE.SET_NAME('IGS','IGS_PE_DREC_GT_BTDT');
	     IGS_GE_MSG_STACK.ADD;
	     APP_EXCEPTION.RAISE_EXCEPTION;
	  END IF;


	  OPEN validate_dt_overlap(new_references.person_id, new_references.pe_eit_id, new_references.information_type,
	                           new_references.start_date, new_references.end_date);
          FETCH validate_dt_overlap INTO l_Overlap_check;
          IF (validate_dt_overlap%FOUND) THEN
    	     CLOSE validate_dt_overlap;
	     IF new_references.information_type = 'PE_STAT_RES_STATE' THEN
    	         FND_MESSAGE.SET_NAME ('IGS','IGS_PE_ST_RES');
        	 l_inf_type  := FND_MESSAGE.GET;
             ELSIF new_references.information_type = 'PE_STAT_RES_COUNTRY' THEN
    	         FND_MESSAGE.SET_NAME ('IGS','IGS_PE_CON_PHY');
        	 l_inf_type  := FND_MESSAGE.GET;
             ELSIF new_references.information_type = 'PE_INT_PERM_RES' THEN
                 l_inf_type  := NULL;
             ELSIF new_references.information_type = 'PE_STAT_RES_STATUS' THEN
    	         FND_MESSAGE.SET_NAME ('IGS','IGS_PE_CIT');
        	 l_inf_type  := FND_MESSAGE.GET;
    	     END IF;

    	     IF l_inf_type IS NOT NULL THEN
     	       FND_MESSAGE.SET_NAME('IGS','IGS_PE_DT_RANGE_OVLP');
	       FND_MESSAGE.SET_TOKEN('TOKEN',l_inf_type);
   	     ELSE
     	       FND_MESSAGE.SET_NAME('IGS','IGS_PE_PRDS_OVERLAP');
      	     END IF;

     	     IGS_GE_MSG_STACK.ADD;
             APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;
          CLOSE validate_dt_overlap;
       END IF;

 END BeforeRowInsertUpdate;

PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_pe_eit_id                         IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_information_type                  IN     VARCHAR2    DEFAULT NULL,
    x_pei_information1                  IN     VARCHAR2    DEFAULT NULL,
    x_pei_information2                  IN     VARCHAR2    DEFAULT NULL,
    x_pei_information3                  IN     VARCHAR2    DEFAULT NULL,
    x_pei_information4                  IN     VARCHAR2    DEFAULT NULL,
    x_pei_information5                  IN     VARCHAR2    DEFAULT NULL,
    x_start_date                        IN     DATE        DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
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
      x_pe_eit_id,
      x_person_id,
      x_information_type,
      x_pei_information1,
      x_pei_information2,
      x_pei_information3,
      x_pei_information4,
      x_pei_information5,
      x_start_date,
      x_end_date,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate( TRUE, FALSE,FALSE );
      IF ( get_pk_for_validation(
             new_references.pe_eit_id
           )
         ) THEN
        	 fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
		 igs_ge_msg_stack.add;
		 app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate( FALSE,TRUE,FALSE );
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.pe_eit_id
           )
         ) THEN
		  fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
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
    x_pe_eit_id                         IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_information_type                  IN     VARCHAR2,
    x_pei_information1                  IN     VARCHAR2,
    x_pei_information2                  IN     VARCHAR2,
    x_pei_information3                  IN     VARCHAR2,
    x_pei_information4                  IN     VARCHAR2,
    x_pei_information5                  IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_pe_eit
      WHERE    pe_eit_id                         = x_pe_eit_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  BEGIN

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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT    igs_pe_eit_s.NEXTVAL
    INTO      x_pe_eit_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_pe_eit_id                         => x_pe_eit_id,
      x_person_id                         => x_person_id,
      x_information_type                  => x_information_type,
      x_pei_information1                  => x_pei_information1,
      x_pei_information2                  => x_pei_information2,
      x_pei_information3                  => x_pei_information3,
      x_pei_information4                  => x_pei_information4,
      x_pei_information5                  => x_pei_information5,
      x_start_date                        => x_start_date,
      x_end_date                          => x_end_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_pe_eit (
      pe_eit_id,
      person_id,
      information_type,
      pei_information1,
      pei_information2,
      pei_information3,
      pei_information4,
      pei_information5,
      start_date,
      end_date,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.pe_eit_id,
      new_references.person_id,
      new_references.information_type,
      new_references.pei_information1,
      new_references.pei_information2,
      new_references.pei_information3,
      new_references.pei_information4,
      new_references.pei_information5,
      new_references.start_date,
      new_references.end_date,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;
 END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_pe_eit_id                         IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_information_type                  IN     VARCHAR2,
    x_pei_information1                  IN     VARCHAR2,
    x_pei_information2                  IN     VARCHAR2,
    x_pei_information3                  IN     VARCHAR2,
    x_pei_information4                  IN     VARCHAR2,
    x_pei_information5                  IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        information_type,
        pei_information1,
        pei_information2,
        pei_information3,
        pei_information4,
        pei_information5,
        start_date,
        end_date
      FROM  igs_pe_eit
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
        AND (tlinfo.information_type = x_information_type)
        AND ((tlinfo.pei_information1 = x_pei_information1) OR ((tlinfo.pei_information1 IS NULL) AND (X_pei_information1 IS NULL)))
        AND ((tlinfo.pei_information2 = x_pei_information2) OR ((tlinfo.pei_information2 IS NULL) AND (X_pei_information2 IS NULL)))
        AND ((tlinfo.pei_information3 = x_pei_information3) OR ((tlinfo.pei_information3 IS NULL) AND (X_pei_information3 IS NULL)))
        AND ((tlinfo.pei_information4 = x_pei_information4) OR ((tlinfo.pei_information4 IS NULL) AND (X_pei_information4 IS NULL)))
        AND ((tlinfo.pei_information5 = x_pei_information5) OR ((tlinfo.pei_information5 IS NULL) AND (X_pei_information5 IS NULL)))
        AND (tlinfo.start_date = x_start_date)
        AND ((tlinfo.end_date = x_end_date) OR ((tlinfo.end_date IS NULL) AND (X_end_date IS NULL)))
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
    x_pe_eit_id                         IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_information_type                  IN     VARCHAR2,
    x_pei_information1                  IN     VARCHAR2,
    x_pei_information2                  IN     VARCHAR2,
    x_pei_information3                  IN     VARCHAR2,
    x_pei_information4                  IN     VARCHAR2,
    x_pei_information5                  IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_pe_eit_id                         => x_pe_eit_id,
      x_person_id                         => x_person_id,
      x_information_type                  => x_information_type,
      x_pei_information1                  => x_pei_information1,
      x_pei_information2                  => x_pei_information2,
      x_pei_information3                  => x_pei_information3,
      x_pei_information4                  => x_pei_information4,
      x_pei_information5                  => x_pei_information5,
      x_start_date                        => x_start_date,
      x_end_date                          => x_end_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_pe_eit
      SET
        person_id                         = new_references.person_id,
        information_type                  = new_references.information_type,
        pei_information1                  = new_references.pei_information1,
        pei_information2                  = new_references.pei_information2,
        pei_information3                  = new_references.pei_information3,
        pei_information4                  = new_references.pei_information4,
        pei_information5                  = new_references.pei_information5,
        start_date                        = new_references.start_date,
        end_date                          = new_references.end_date,
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



EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = (-28115)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;
 END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_pe_eit_id                         IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_information_type                  IN     VARCHAR2,
    x_pei_information1                  IN     VARCHAR2,
    x_pei_information2                  IN     VARCHAR2,
    x_pei_information3                  IN     VARCHAR2,
    x_pei_information4                  IN     VARCHAR2,
    x_pei_information5                  IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pe_eit
      WHERE    pe_eit_id                         = x_pe_eit_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_pe_eit_id,
        x_person_id,
        x_information_type,
        x_pei_information1,
        x_pei_information2,
        x_pei_information3,
        x_pei_information4,
        x_pei_information5,
        x_start_date,
        x_end_date,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_pe_eit_id,
      x_person_id,
      x_information_type,
      x_pei_information1,
      x_pei_information2,
      x_pei_information3,
      x_pei_information4,
      x_pei_information5,
      x_start_date,
      x_end_date,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
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

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 DELETE FROM igs_pe_eit
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


  END delete_row;


END igs_pe_eit_pkg;

/
