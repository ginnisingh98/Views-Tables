--------------------------------------------------------
--  DDL for Package Body IGS_PE_STAT_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_STAT_DETAILS_PKG" AS
/* $Header: IGSNI72B.pls 120.2 2006/02/17 06:52:23 gmaheswa ship $ */

------------------------------------------------------------------
-- Change History
-- npalanis        11-SEP-2002     bug - 2608360
--                                 igs_pe_code_classes is
--                                  removed due to transition of code
--                                   class to lookups , new columns added
--                                   for codes. the  tbh  are  modified accordingly
--
-- Bug ID : 2000408
-- who      when          what
-- CDCRUZ   Sep 24,2002   New Col's added for
--                        Person DLD
--  Columns Obsoleted - CRIMINAL_CONVICT/ACAD_DISMISSAL/NON_ACAD_DISMISSAL/COUNTRY_CD3
--                      RES_STAT_ID/STATE_OF_RESIDENCE
--  Columns Added     - MATR_CAL_TYPE/MATR_SEQUENCE_NUMBER/INIT_CAL_TYPE/INIT_SEQUENCE_NUMBER
--                      RECENT_CAL_TYPE/RECENT_SEQUENCE_NUMBER/CATALOG_CAL_TYPE/CATALOG_SEQUENCE_NUMBER
--   Bayadav  31-Jan-2002  Bug number 2203778 .addded descriptive flexfield columns (IGS_PE_PERS_STAT )
-- ssawhney   2203778
-- added person_id mandatory FK with HZ_PARTIES. removed person_profile_id and all the obsoleted columns
------------------------------------------------------------------

  l_rowid VARCHAR2(25);
  old_references igs_pe_stat_details%ROWTYPE;
  new_references igs_pe_stat_details%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2   ,-- DEFAULT NULL,
    -- x_person_profile_id                 IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER ,--DEFAULT NULL,
    x_effective_start_date              IN     DATE      ,--  DEFAULT NULL,
    x_effective_end_date                IN     DATE       ,-- DEFAULT NULL,
    x_religion_cd                       IN     VARCHAR2    ,--  DEFAULT NULL,
    --x_criminal_convict                  IN     VARCHAR2    DEFAULT NULL,
    --x_acad_dismissal                    IN     VARCHAR2    DEFAULT NULL,
    -- x_non_acad_dismissal                IN     VARCHAR2    DEFAULT NULL,
    --x_country_cd3                       IN     VARCHAR2    DEFAULT NULL,
    --x_state_of_residence                IN     VARCHAR2     DEFAULT NULL,
    -- x_resid_stat_id                     IN     NUMBER      DEFAULT NULL,
    x_socio_eco_cd                      IN     VARCHAR2  ,--    DEFAULT NULL,
    x_next_to_kin                       IN     VARCHAR2  ,--  DEFAULT NULL,
    x_in_state_tuition                  IN     VARCHAR2  ,--  DEFAULT NULL,
    x_tuition_st_date                   IN     DATE      ,--  DEFAULT NULL,
    x_tuition_end_date                  IN     DATE      ,--  DEFAULT NULL,
    x_further_education_cd              IN     VARCHAR2  ,--  DEFAULT NULL,
    X_MATR_CAL_TYPE                     IN     VARCHAR2  ,--  DEFAULT NULL ,
    X_MATR_SEQUENCE_NUMBER              IN     NUMBER    ,--  DEFAULT NULL,
    X_INIT_CAL_TYPE                     IN     VARCHAR2  ,--  DEFAULT NULL ,
    X_INIT_SEQUENCE_NUMBER             IN     NUMBER     ,-- DEFAULT NULL,
    X_RECENT_CAL_TYPE                   IN     VARCHAR2  ,--  DEFAULT NULL ,
    X_RECENT_SEQUENCE_NUMBER           IN     NUMBER     ,-- DEFAULT NULL,
    X_CATALOG_CAL_TYPE                  IN     VARCHAR2  ,--  DEFAULT NULL ,
    X_CATALOG_SEQUENCE_NUMBER          IN     NUMBER     ,-- DEFAULT NULL,
    x_creation_date                     IN     DATE      ,--  DEFAULT NULL,
    x_created_by                        IN     NUMBER    ,--  DEFAULT NULL,
    x_last_update_date                  IN     DATE      ,--  DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER    ,--  DEFAULT NULL,
    x_last_update_login                 IN     NUMBER    ,--  DEFAULT NULL ,
    X_ATTRIBUTE_CATEGORY 		IN VARCHAR2 ,--DEFAULT NULL,
    X_ATTRIBUTE1 			  IN VARCHAR2  ,--DEFAULT NULL,
    X_ATTRIBUTE2 			  IN VARCHAR2 ,--DEFAULT NULL,
    X_ATTRIBUTE3 			  IN VARCHAR2 ,--DEFAULT NULL,
    X_ATTRIBUTE4 			  IN VARCHAR2 ,--DEFAULT NULL,
    X_ATTRIBUTE5  			IN VARCHAR2 ,--DEFAULT NULL,
    X_ATTRIBUTE6  			IN VARCHAR2 ,--DEFAULT NULL,
   	X_ATTRIBUTE7  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE8  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE9 		  	IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE10 			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE11  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE12  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE13  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE14  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE15  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE16  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE17  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE18  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE19  			IN VARCHAR2 ,--DEFAULT NULL,
  	X_ATTRIBUTE20  			IN VARCHAR2, --DEFAULT NULL
	X_BIRTH_CNTRY_RESN_CODE		IN     VARCHAR2 --DEFAULT NULL
  ) AS
  /*
  ||  Created By : bshankar
  ||  Created On : 28-AUG-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_STAT_DETAILS
      WHERE    ROWID = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED 1');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
   -- new_references.person_profile_id                 := x_person_profile_id;
    new_references.person_id                 := x_person_id;
    new_references.effective_start_date              := x_effective_start_date;
    new_references.effective_end_date                := x_effective_end_date;
     new_references.religion_cd                       := x_religion_cd;
   -- new_references.criminal_convict                  := x_criminal_convict;
   -- new_references.acad_dismissal                    := x_acad_dismissal;
   -- new_references.non_acad_dismissal                := x_non_acad_dismissal;
   -- new_references.country_cd3                       := x_country_cd3;
   -- new_references.state_of_residence                := x_state_of_residence;
   -- new_references.resid_stat_id                     := x_resid_stat_id;
    new_references.socio_eco_cd                      := x_socio_eco_cd;
    new_references.next_to_kin                       := x_next_to_kin;
    new_references.in_state_tuition                  := x_in_state_tuition;
    new_references.tuition_st_date                   := x_tuition_st_date;
    new_references.tuition_end_date                  := x_tuition_end_date;
    new_references.further_education_cd                 := x_further_education_cd;
    NEW_REFERENCES.MATR_CAL_TYPE                     := X_MATR_CAL_TYPE ;
    NEW_REFERENCES.MATR_SEQUENCE_NUMBER              := X_MATR_SEQUENCE_NUMBER ;
    NEW_REFERENCES.INIT_CAL_TYPE                     := X_INIT_CAL_TYPE ;
    NEW_REFERENCES.INIT_SEQUENCE_NUMBER             := X_INIT_SEQUENCE_NUMBER ;
    NEW_REFERENCES.RECENT_CAL_TYPE                   := X_RECENT_CAL_TYPE ;
    NEW_REFERENCES.RECENT_SEQUENCE_NUMBER           := X_RECENT_SEQUENCE_NUMBER ;
    NEW_REFERENCES.CATALOG_CAL_TYPE                  := X_CATALOG_CAL_TYPE ;
    NEW_REFERENCES.CATALOG_SEQUENCE_NUMBER          := X_CATALOG_SEQUENCE_NUMBER ;
    new_references.attribute_category := x_attribute_category;
    new_references.attribute1 := x_attribute1;
    new_references.attribute2 := x_attribute2;
    new_references.attribute3 := x_attribute3;
    new_references.attribute4 := x_attribute4;
    new_references.attribute5 := x_attribute5;
    new_references.attribute6 := x_attribute6;
    new_references.attribute7 := x_attribute7;
    new_references.attribute8 := x_attribute8;
    new_references.attribute9 := x_attribute9;
    new_references.attribute10 := x_attribute10;
    new_references.attribute11 := x_attribute11;
    new_references.attribute12 := x_attribute12;
    new_references.attribute13 := x_attribute13;
    new_references.attribute14 := x_attribute14;
    new_references.attribute15 := x_attribute15;
    new_references.attribute16 := x_attribute16;
    new_references.attribute17 := x_attribute17;
    new_references.attribute18 := x_attribute18;
    new_references.attribute19 := x_attribute19;
    new_references.attribute20 := x_attribute20;


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
    new_references.birth_cntry_resn_code := x_birth_cntry_resn_code;

  END set_column_values;


  FUNCTION get_pk_for_validation (
    -- x_person_profile_id                 IN     NUMBER
    x_person_id                     IN NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : bshankar
  ||  Created On : 28-AUG-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_pe_stat_details
      --  WHERE    person_profile_id = x_person_profile_id
      WHERE    person_id = x_person_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%ROWTYPE;

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

  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_STAT_DETAILS
      WHERE   (
                 ( MATR_CAL_TYPE = X_CAL_TYPE AND MATR_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER ) OR
                 ( INIT_CAL_TYPE = X_CAL_TYPE AND INIT_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER ) OR
                 ( RECENT_CAL_TYPE = X_CAL_TYPE AND RECENT_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER ) OR
                 ( CATALOG_CAL_TYPE = X_CAL_TYPE AND CATALOG_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER )
	  );

    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PST_CI_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_CA_INST;

PROCEDURE Check_Parent_Existance AS
       CURSOR cur_rowid IS
         SELECT   ROWID
         FROM     HZ_PARTIES
         WHERE    PARTY_ID = new_references.PERSON_ID ;
       lv_rowid cur_rowid%ROWTYPE;
  /*
  ||  Created By : bshankar
  ||  Created On : 28-AUG-2000
  ||  Purpose : Checks for parent record existance.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  ssawhney        6feb            2203778 person_profile_id is remvoed and person_id PK now
  */
BEGIN

    --IF (((old_references.PERSON_PROFILE_ID = new_references.PERSON_PROFILE_ID)) OR
    --    ((new_references.PERSON_PROFILE_ID IS NULL))) THEN

    --NULL;
    IF (((old_references.PERSON_ID = new_references.PERSON_ID)) OR
        ((new_references.PERSON_ID IS NULL))) THEN
      NULL;
    ELSE

     OPEN cur_rowid;
       FETCH cur_rowid INTO lv_rowid;
       IF (cur_rowid%NOTFOUND) THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED 2');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
       END IF;
     CLOSE cur_rowid;

    END IF;

    IF (((old_references.MATR_CAL_TYPE = new_references.MATR_CAL_TYPE) AND
         (old_references.MATR_SEQUENCE_NUMBER = new_references.MATR_SEQUENCE_NUMBER)) OR
        ((new_references.MATR_CAL_TYPE IS NULL) OR
         (new_references.MATR_SEQUENCE_NUMBER IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.MATR_CAL_TYPE,
                new_references.MATR_SEQUENCE_NUMBER
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED 3');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.INIT_CAL_TYPE = new_references.INIT_CAL_TYPE) AND
         (old_references.INIT_SEQUENCE_NUMBER = new_references.INIT_SEQUENCE_NUMBER)) OR
        ((new_references.INIT_CAL_TYPE IS NULL) OR
         (new_references.INIT_SEQUENCE_NUMBER IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.INIT_CAL_TYPE,
                new_references.INIT_SEQUENCE_NUMBER
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED 4');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.RECENT_CAL_TYPE = new_references.RECENT_CAL_TYPE) AND
         (old_references.RECENT_SEQUENCE_NUMBER = new_references.RECENT_SEQUENCE_NUMBER)) OR
        ((new_references.RECENT_CAL_TYPE IS NULL) OR
         (new_references.RECENT_SEQUENCE_NUMBER IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.RECENT_CAL_TYPE,
                new_references.RECENT_SEQUENCE_NUMBER
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED 5');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.CATALOG_CAL_TYPE = new_references.CATALOG_CAL_TYPE) AND
         (old_references.CATALOG_SEQUENCE_NUMBER = new_references.CATALOG_SEQUENCE_NUMBER)) OR
        ((new_references.CATALOG_CAL_TYPE IS NULL) OR
         (new_references.CATALOG_SEQUENCE_NUMBER IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.CATALOG_CAL_TYPE,
                new_references.CATALOG_SEQUENCE_NUMBER
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED 6');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;


END Check_Parent_Existance;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,--    DEFAULT NULL,
    -- x_person_profile_id                 IN     NUMBER      DEFAULT NULL,
    x_person_id                 IN     NUMBER    ,--  DEFAULT NULL,
    x_effective_start_date              IN     DATE        ,--DEFAULT NULL,
    x_effective_end_date                IN     DATE        ,--DEFAULT NULL,
    x_religion_cd                       IN     VARCHAR2     ,-- DEFAULT NULL,
   -- x_criminal_convict                  IN     VARCHAR2    DEFAULT NULL,
   -- x_acad_dismissal                    IN     VARCHAR2    DEFAULT NULL,
   -- x_non_acad_dismissal                IN     VARCHAR2    DEFAULT NULL,
   -- x_country_cd3                       IN     VARCHAR2    DEFAULT NULL,
   -- x_state_of_residence                IN     VARCHAR2     DEFAULT NULL,
   -- x_resid_stat_id                     IN     NUMBER      DEFAULT NULL,
    x_socio_eco_cd                      IN     VARCHAR2  ,--    DEFAULT NULL,
    x_next_to_kin                       IN     VARCHAR2  ,--  DEFAULT NULL,
    x_in_state_tuition                  IN     VARCHAR2  ,--  DEFAULT NULL,
    x_tuition_st_date                   IN     DATE      ,--  DEFAULT NULL,
    x_tuition_end_date                  IN     DATE      ,--  DEFAULT NULL,
    x_further_education_cd                 IN     VARCHAR2   ,--   DEFAULT NULL,
    X_MATR_CAL_TYPE                     IN     VARCHAR2 ,--   DEFAULT NULL ,
    X_MATR_SEQUENCE_NUMBER              IN     NUMBER    ,--  DEFAULT NULL,
    X_INIT_CAL_TYPE                     IN     VARCHAR2  ,--  DEFAULT NULL ,
    X_INIT_SEQUENCE_NUMBER             IN     NUMBER     ,-- DEFAULT NULL,
    X_RECENT_CAL_TYPE                   IN     VARCHAR2  ,--  DEFAULT NULL ,
    X_RECENT_SEQUENCE_NUMBER           IN     NUMBER     ,-- DEFAULT NULL,
    X_CATALOG_CAL_TYPE                  IN     VARCHAR2  ,--  DEFAULT NULL ,
    X_CATALOG_SEQUENCE_NUMBER          IN     NUMBER     ,-- DEFAULT NULL,
    x_creation_date                     IN     DATE      ,--  DEFAULT NULL,
    x_created_by                        IN     NUMBER    ,--  DEFAULT NULL,
    x_last_update_date                  IN     DATE      ,--  DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER    ,--  DEFAULT NULL,
    x_last_update_login                 IN     NUMBER    ,--  DEFAULT NULL ,
    X_ATTRIBUTE_CATEGORY 		IN VARCHAR2 ,--DEFAULT NULL,
    X_ATTRIBUTE1 			  IN VARCHAR2 ,-- DEFAULT NULL,
    X_ATTRIBUTE2 			  IN VARCHAR2 ,--DEFAULT NULL,
    X_ATTRIBUTE3 			  IN VARCHAR2 ,--DEFAULT NULL,
    X_ATTRIBUTE4 			  IN VARCHAR2 ,--DEFAULT NULL,
    X_ATTRIBUTE5  			IN VARCHAR2 ,--DEFAULT NULL,
    X_ATTRIBUTE6  			IN VARCHAR2 ,--DEFAULT NULL,
   	X_ATTRIBUTE7  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE8  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE9 		  	IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE10 			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE11  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE12  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE13  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE14  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE15  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE16  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE17  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE18  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE19  			IN VARCHAR2 ,--DEFAULT NULL,
  	X_ATTRIBUTE20  			IN VARCHAR2 ,--DEFAULT NULL
	X_BIRTH_CNTRY_RESN_CODE		IN VARCHAR2
  ) AS
  /*
  ||  Created By : bshankar
  ||  Created On : 28-AUG-2000
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  Bayadav  31-Jan-2002  Bug number 2203778 .addded descriptive flexfield columns (IGS_PE_PERS_STAT )
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
     -- x_person_profile_id,
      x_person_id,
      x_effective_start_date,
      x_effective_end_date,
      x_religion_cd,
      --x_criminal_convict,
      --x_acad_dismissal,
      --x_non_acad_dismissal,
      --x_country_cd3,
      --x_state_of_residence,
      --x_resid_stat_id,
      x_socio_eco_cd,
      x_next_to_kin,
      x_in_state_tuition,
      x_tuition_st_date,
      x_tuition_end_date,
      x_further_education_cd,
      X_MATR_CAL_TYPE,
      X_MATR_SEQUENCE_NUMBER,
      X_INIT_CAL_TYPE,
      X_INIT_SEQUENCE_NUMBER,
      X_RECENT_CAL_TYPE,
      X_RECENT_SEQUENCE_NUMBER,
      X_CATALOG_CAL_TYPE,
      X_CATALOG_SEQUENCE_NUMBER,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
       x_ATTRIBUTE_CATEGORY,
      x_ATTRIBUTE1        ,
      x_ATTRIBUTE2        ,
      x_ATTRIBUTE3        ,
      x_ATTRIBUTE4        ,
      x_ATTRIBUTE5        ,
      x_ATTRIBUTE6        ,
      x_ATTRIBUTE7        ,
      x_ATTRIBUTE8        ,
      x_ATTRIBUTE9        ,
      x_ATTRIBUTE10       ,
      x_ATTRIBUTE11       ,
      x_ATTRIBUTE12       ,
      x_ATTRIBUTE13       ,
      x_ATTRIBUTE14       ,
      x_ATTRIBUTE15       ,
      x_ATTRIBUTE16       ,
      x_ATTRIBUTE17       ,
      x_ATTRIBUTE18       ,
      x_ATTRIBUTE19       ,
      x_ATTRIBUTE20	  ,
      X_BIRTH_CNTRY_RESN_CODE
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Check_Parent_Existance;
      IF ( get_pk_for_validation(
             new_references.person_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'UPDATE') THEN
           -- Call all the procedures related to Before Update.
           Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.person_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
   --  x_person_profile_id                 IN     NUMBER,
    x_person_id                         IN NUMBER,
    x_effective_start_date              IN     DATE,
    x_effective_end_date                IN     DATE,
    x_religion_cd                       IN     VARCHAR2,
    --x_criminal_convict                  IN     VARCHAR2 DEFAULT NULL,
    --x_acad_dismissal                    IN     VARCHAR2 DEFAULT NULL,
    -- x_non_acad_dismissal                IN     VARCHAR2 DEFAULT NULL,
    --x_country_cd3                       IN     VARCHAR2 DEFAULT NULL,
    -- x_state_of_residence                IN     VARCHAR2 DEFAULT NULL,
    -- x_resid_stat_id                     IN     NUMBER DEFAULT NULL,
    x_socio_eco_cd                      IN     VARCHAR2,
    x_next_to_kin                       IN     VARCHAR2,
    x_in_state_tuition                  IN     VARCHAR2,
    x_tuition_st_date                   IN     DATE,
    x_tuition_end_date                  IN     DATE,
    x_further_education_cd              IN     VARCHAR2 ,
    X_MATR_CAL_TYPE                     IN     VARCHAR2  ,--  DEFAULT NULL ,
    X_MATR_SEQUENCE_NUMBER              IN     NUMBER    ,--  DEFAULT NULL,
    X_INIT_CAL_TYPE                     IN     VARCHAR2  ,--  DEFAULT NULL ,
    X_INIT_SEQUENCE_NUMBER             IN     NUMBER     ,-- DEFAULT NULL,
    X_RECENT_CAL_TYPE                   IN     VARCHAR2  ,--  DEFAULT NULL ,
    X_RECENT_SEQUENCE_NUMBER           IN     NUMBER     ,-- DEFAULT NULL,
    X_CATALOG_CAL_TYPE                  IN     VARCHAR2  ,--  DEFAULT NULL ,
    X_CATALOG_SEQUENCE_NUMBER          IN     NUMBER     ,-- DEFAULT NULL,
    x_mode                              IN     VARCHAR2,-- DEFAULT 'R' ,
    X_ATTRIBUTE_CATEGORY 		IN VARCHAR2 ,--DEFAULT NULL,
    X_ATTRIBUTE1 			  IN VARCHAR2,--  DEFAULT NULL,
    X_ATTRIBUTE2 			  IN VARCHAR2,-- DEFAULT NULL,
    X_ATTRIBUTE3 			  IN VARCHAR2,-- DEFAULT NULL,
    X_ATTRIBUTE4 			  IN VARCHAR2,-- DEFAULT NULL,
    X_ATTRIBUTE5  			IN VARCHAR2 ,--DEFAULT NULL,
    X_ATTRIBUTE6  			IN VARCHAR2 ,--DEFAULT NULL,
   	X_ATTRIBUTE7  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE8  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE9 		  	IN VARCHAR2,-- DEFAULT NULL,
	  X_ATTRIBUTE10 			IN VARCHAR2,-- DEFAULT NULL,
	  X_ATTRIBUTE11  			IN VARCHAR2,-- DEFAULT NULL,
	  X_ATTRIBUTE12  			IN VARCHAR2,-- DEFAULT NULL,
	  X_ATTRIBUTE13  			IN VARCHAR2,-- DEFAULT NULL,
	  X_ATTRIBUTE14  			IN VARCHAR2,-- DEFAULT NULL,
	  X_ATTRIBUTE15  			IN VARCHAR2,-- DEFAULT NULL,
	  X_ATTRIBUTE16  			IN VARCHAR2,-- DEFAULT NULL,
	  X_ATTRIBUTE17  			IN VARCHAR2,-- DEFAULT NULL,
	  X_ATTRIBUTE18  			IN VARCHAR2,-- DEFAULT NULL,
	  X_ATTRIBUTE19  			IN VARCHAR2,-- DEFAULT NULL,
  	X_ATTRIBUTE20  			IN VARCHAR2, --DEFAULT NULL
	X_BIRTH_CNTRY_RESN_CODE		IN VARCHAR2
  ) AS
  /*
  ||  Created By : bshankar
  ||  Created On : 28-AUG-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  Bayadav  31-Jan-2002  Bug number 2203778 .addded descriptive flexfield columns (IGS_PE_PERS_STAT )
  ||  (reverse chronological order - newest change first)
  ||  ssawhney 2203778    person_id replaces person_profile_id
  */
    CURSOR c IS
      SELECT   ROWID
      FROM     igs_pe_stat_details
      WHERE    person_id                 = x_person_id;

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
    ELSIF (X_MODE IN ('R', 'S')) THEN
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
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
     --x_person_profile_id                 => x_person_profile_id,
      x_person_id                         => x_person_id,
      x_effective_start_date              => x_effective_start_date,
      x_effective_end_date                => x_effective_end_date,
      x_religion_cd                       => x_religion_cd,
      --x_criminal_convict                  => x_criminal_convict,
      --x_acad_dismissal                    => x_acad_dismissal,
      --x_non_acad_dismissal                => x_non_acad_dismissal,
      --x_country_cd3                       => x_country_cd3,
      -- x_state_of_residence                => x_state_of_residence,
      --x_resid_stat_id                     => x_resid_stat_id,
      x_socio_eco_cd                      => x_socio_eco_cd,
      x_next_to_kin                       => x_next_to_kin,
      x_in_state_tuition                  => x_in_state_tuition,
      x_tuition_st_date                   => x_tuition_st_date,
      x_tuition_end_date                  => x_tuition_end_date,
      x_further_education_cd                 => x_further_education_cd,
      X_MATR_CAL_TYPE                     => X_MATR_CAL_TYPE,
      X_MATR_SEQUENCE_NUMBER              => X_MATR_SEQUENCE_NUMBER,
      X_INIT_CAL_TYPE                     => X_INIT_CAL_TYPE,
      X_INIT_SEQUENCE_NUMBER             => X_INIT_SEQUENCE_NUMBER,
      X_RECENT_CAL_TYPE                   => X_RECENT_CAL_TYPE,
      X_RECENT_SEQUENCE_NUMBER           => X_RECENT_SEQUENCE_NUMBER,
      X_CATALOG_CAL_TYPE                  => X_CATALOG_CAL_TYPE,
      X_CATALOG_SEQUENCE_NUMBER          => X_CATALOG_SEQUENCE_NUMBER,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      X_ATTRIBUTE_CATEGORY 		=>X_ATTRIBUTE_CATEGORY,
      X_ATTRIBUTE1 		  	=>X_ATTRIBUTE1,
      X_ATTRIBUTE2 		  	=>X_ATTRIBUTE2,
      X_ATTRIBUTE3 		  	=>X_ATTRIBUTE3,
      X_ATTRIBUTE4 	  		=>X_ATTRIBUTE4,
      X_ATTRIBUTE5  			=>X_ATTRIBUTE5,
      X_ATTRIBUTE6  			=>X_ATTRIBUTE6,
   	  X_ATTRIBUTE7  			=>X_ATTRIBUTE7,
	    X_ATTRIBUTE8  			=>X_ATTRIBUTE8,
	    X_ATTRIBUTE9  			=>X_ATTRIBUTE9,
	    X_ATTRIBUTE10 			=>X_ATTRIBUTE10,
	    X_ATTRIBUTE11  			=>X_ATTRIBUTE11,
	    X_ATTRIBUTE12  			=>X_ATTRIBUTE12,
	    X_ATTRIBUTE13  			=>X_ATTRIBUTE13,
	    X_ATTRIBUTE14  			=>X_ATTRIBUTE14,
	    X_ATTRIBUTE15  			=>X_ATTRIBUTE15,
	    X_ATTRIBUTE16  			=>X_ATTRIBUTE16,
	    X_ATTRIBUTE17  			=>X_ATTRIBUTE17,
	    X_ATTRIBUTE18  			=>X_ATTRIBUTE18,
	    X_ATTRIBUTE19  			=>X_ATTRIBUTE19,
  	  X_ATTRIBUTE20  			=>X_ATTRIBUTE20,
	  X_BIRTH_CNTRY_RESN_CODE		=>X_BIRTH_CNTRY_RESN_CODE
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
   INSERT INTO igs_pe_stat_details (
      -- person_profile_id,
      person_id,
      effective_start_date,
      effective_end_date,
      religion_cd,
      --criminal_convict,
      --acad_dismissal,
      --non_acad_dismissal,
      --country_cd3,
      --state_of_residence,
      --resid_stat_id,
      socio_eco_cd,
      next_to_kin,
      in_state_tuition,
      tuition_st_date,
      tuition_end_date,
      further_education_cd,
      MATR_CAL_TYPE,
      MATR_SEQUENCE_NUMBER,
      INIT_CAL_TYPE,
      INIT_SEQUENCE_NUMBER,
      RECENT_CAL_TYPE,
      RECENT_SEQUENCE_NUMBER,
      CATALOG_CAL_TYPE,
      CATALOG_SEQUENCE_NUMBER,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date ,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20,
      BIRTH_CNTRY_RESN_CODE)
      VALUES
      (
     -- new_references.person_profile_id,
      new_references.person_id,
      new_references.effective_start_date,
      new_references.effective_end_date,
      new_references.religion_cd,
      --new_references.criminal_convict,
      --new_references.acad_dismissal,
      --new_references.non_acad_dismissal,
      --new_references.country_cd3,
      --new_references.state_of_residence,
      --new_references.resid_stat_id,
      new_references.socio_eco_cd,
      new_references.next_to_kin,
      new_references.in_state_tuition,
      new_references.tuition_st_date,
      new_references.tuition_end_date,
      new_references.further_education_cd,
      new_references.MATR_CAL_TYPE,
      new_references.MATR_SEQUENCE_NUMBER,
      new_references.INIT_CAL_TYPE,
      new_references.INIT_SEQUENCE_NUMBER,
      new_references.RECENT_CAL_TYPE,
      new_references.RECENT_SEQUENCE_NUMBER,
      new_references.CATALOG_CAL_TYPE,
      new_references.CATALOG_SEQUENCE_NUMBER,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date ,
      new_references.ATTRIBUTE_CATEGORY,
      new_references.ATTRIBUTE1,
      new_references.ATTRIBUTE2,
      new_references.ATTRIBUTE3,
      new_references.ATTRIBUTE4,
      new_references.ATTRIBUTE5,
      new_references.ATTRIBUTE6,
      new_references.ATTRIBUTE7,
      new_references.ATTRIBUTE8,
      new_references.ATTRIBUTE9,
      new_references.ATTRIBUTE10,
      new_references.ATTRIBUTE11,
      new_references.ATTRIBUTE12,
      new_references.ATTRIBUTE13,
      new_references.ATTRIBUTE14,
      new_references.ATTRIBUTE15,
      new_references.ATTRIBUTE16,
      new_references.ATTRIBUTE17,
      new_references.ATTRIBUTE18,
      new_references.ATTRIBUTE19,
      new_references.ATTRIBUTE20,
      new_references.birth_cntry_resn_code
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
    --x_person_profile_id                 IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_effective_start_date              IN     DATE,
    x_effective_end_date                IN     DATE,
    x_religion_cd                       IN     VARCHAR2,
    --x_criminal_convict                  IN     VARCHAR2,
    --x_acad_dismissal                    IN     VARCHAR2,
    --x_non_acad_dismissal                IN     VARCHAR2,
    --x_country_cd3                       IN     VARCHAR2,
    --x_state_of_residence                IN     VARCHAR2,
    --x_resid_stat_id                     IN     NUMBER,
    x_socio_eco_cd                      IN     VARCHAR2,
    x_next_to_kin                       IN     VARCHAR2,
    x_in_state_tuition                  IN     VARCHAR2,
    x_tuition_st_date                   IN     DATE,
    x_tuition_end_date                  IN     DATE,
    x_further_education_cd                 IN     VARCHAR2,
    X_MATR_CAL_TYPE                     IN     VARCHAR2  ,--  DEFAULT NULL ,
    X_MATR_SEQUENCE_NUMBER              IN     NUMBER    ,--  DEFAULT NULL,
    X_INIT_CAL_TYPE                     IN     VARCHAR2  ,--  DEFAULT NULL ,
    X_INIT_SEQUENCE_NUMBER             IN     NUMBER     ,-- DEFAULT NULL,
    X_RECENT_CAL_TYPE                   IN     VARCHAR2  ,--  DEFAULT NULL ,
    X_RECENT_SEQUENCE_NUMBER           IN     NUMBER     ,-- DEFAULT NULL,
    X_CATALOG_CAL_TYPE                  IN     VARCHAR2  ,--  DEFAULT NULL ,
    X_CATALOG_SEQUENCE_NUMBER          IN     NUMBER     ,-- DEFAULT NULL,
    X_ATTRIBUTE_CATEGORY 		IN VARCHAR2 ,--DEFAULT NULL,
    X_ATTRIBUTE1 			  IN VARCHAR2,--  DEFAULT NULL,
    X_ATTRIBUTE2 			  IN VARCHAR2,-- DEFAULT NULL,
    X_ATTRIBUTE3 			  IN VARCHAR2,-- DEFAULT NULL,
    X_ATTRIBUTE4 			  IN VARCHAR2,-- DEFAULT NULL,
    X_ATTRIBUTE5  			IN VARCHAR2 ,--DEFAULT NULL,
    X_ATTRIBUTE6  			IN VARCHAR2 ,--DEFAULT NULL,
   	X_ATTRIBUTE7  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE8  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE9 		  	IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE10 			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE11  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE12  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE13  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE14  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE15  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE16  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE17  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE18  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE19  			IN VARCHAR2 ,--DEFAULT NULL,
  	X_ATTRIBUTE20  			IN VARCHAR2, --DEFAULT NULL
	X_BIRTH_CNTRY_RESN_CODE		IN VARCHAR2
  ) AS
  /*
  ||  Created By : bshankar
  ||  Created On : 28-AUG-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  Bayadav  31-Jan-2002  Bug number 2203778 .addded descriptive flexfield columns (IGS_PE_PERS_STAT )
  ||  (reverse chronological order - newest change first)
  */

    CURSOR c1 IS
      SELECT
        effective_start_date,
        effective_end_date,
        religion_cd,
        --criminal_convict,
        --acad_dismissal,
        --non_acad_dismissal,
        --country_cd3,
        --state_of_residence,
        --resid_stat_id,
        socio_eco_cd,
        next_to_kin,
        in_state_tuition,
        tuition_st_date,
        tuition_end_date,
        further_education_cd,
        MATR_CAL_TYPE,
        MATR_SEQUENCE_NUMBER,
        INIT_CAL_TYPE,
        INIT_SEQUENCE_NUMBER,
        RECENT_CAL_TYPE,
        RECENT_SEQUENCE_NUMBER,
        CATALOG_CAL_TYPE,
        CATALOG_SEQUENCE_NUMBER,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        ATTRIBUTE16,
        ATTRIBUTE17,
        ATTRIBUTE18,
        ATTRIBUTE19,
        ATTRIBUTE20,
	BIRTH_CNTRY_RESN_CODE
      FROM  igs_pe_stat_details
      WHERE ROWID = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN
    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%NOTFOUND) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED 7');
      igs_ge_msg_stack.ADD;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.effective_start_date = x_effective_start_date)
        AND ((tlinfo.effective_end_date = x_effective_end_date) OR ((tlinfo.effective_end_date IS NULL) AND (X_effective_end_date IS NULL)))
        AND ((tlinfo.religion_cd = x_religion_cd) OR ((tlinfo.religion_cd IS NULL) AND (X_religion_cd IS NULL)))
       -- AND ((tlinfo.criminal_convict = x_criminal_convict) OR ((tlinfo.criminal_convict IS NULL) AND (X_criminal_convict IS NULL)))
       -- AND ((tlinfo.acad_dismissal = x_acad_dismissal) OR ((tlinfo.acad_dismissal IS NULL) AND (X_acad_dismissal IS NULL)))
       -- AND ((tlinfo.non_acad_dismissal = x_non_acad_dismissal) OR ((tlinfo.non_acad_dismissal IS NULL) AND (X_non_acad_dismissal IS NULL)))
       -- AND ((tlinfo.country_cd3 = x_country_cd3) OR ((tlinfo.country_cd3 IS NULL) AND (X_country_cd3 IS NULL)))
      --  AND ((tlinfo.state_of_residence = x_state_of_residence) OR ((tlinfo.state_of_residence IS NULL) AND (X_state_of_residence IS NULL)))
      --  AND ((tlinfo.resid_stat_id = x_resid_stat_id) OR ((tlinfo.resid_stat_id IS NULL) AND (X_resid_stat_id IS NULL)))
        AND ((tlinfo.socio_eco_cd = x_socio_eco_cd) OR ((tlinfo.socio_eco_cd IS NULL) AND (X_socio_eco_cd IS NULL)))
        AND ((tlinfo.next_to_kin = x_next_to_kin) OR ((tlinfo.next_to_kin IS NULL) AND (X_next_to_kin IS NULL)))
        AND ((tlinfo.in_state_tuition = x_in_state_tuition) OR ((tlinfo.in_state_tuition IS NULL) AND (X_in_state_tuition IS NULL)))
        AND ((tlinfo.tuition_st_date = x_tuition_st_date) OR ((tlinfo.tuition_st_date IS NULL) AND (X_tuition_st_date IS NULL)))
        AND ((tlinfo.tuition_end_date = x_tuition_end_date) OR ((tlinfo.tuition_end_date IS NULL) AND (X_tuition_end_date IS NULL)))

        AND ((tlinfo.further_education_cd = x_further_education_cd) OR ((tlinfo.further_education_cd IS NULL) AND (X_further_education_cd IS NULL)))
        AND ((tlinfo.MATR_CAL_TYPE = X_MATR_CAL_TYPE) OR ((tlinfo.MATR_CAL_TYPE IS NULL) AND (X_MATR_CAL_TYPE IS NULL)))
        AND ((tlinfo.MATR_SEQUENCE_NUMBER = X_MATR_SEQUENCE_NUMBER) OR ((tlinfo.MATR_SEQUENCE_NUMBER IS NULL) AND (X_MATR_SEQUENCE_NUMBER IS NULL)))
        AND ((tlinfo.INIT_CAL_TYPE = X_INIT_CAL_TYPE) OR ((tlinfo.INIT_CAL_TYPE IS NULL) AND (X_INIT_CAL_TYPE IS NULL)))
        AND ((tlinfo.INIT_SEQUENCE_NUMBER = X_INIT_SEQUENCE_NUMBER) OR ((tlinfo.INIT_SEQUENCE_NUMBER IS NULL) AND (X_INIT_SEQUENCE_NUMBER IS NULL)))
        AND ((tlinfo.RECENT_CAL_TYPE = X_RECENT_CAL_TYPE) OR ((tlinfo.RECENT_CAL_TYPE IS NULL) AND (X_RECENT_CAL_TYPE IS NULL)))
        AND ((tlinfo.RECENT_SEQUENCE_NUMBER = X_RECENT_SEQUENCE_NUMBER) OR ((tlinfo.RECENT_SEQUENCE_NUMBER IS NULL) AND (X_RECENT_SEQUENCE_NUMBER IS NULL)))
	AND ((tlinfo.BIRTH_CNTRY_RESN_CODE = X_BIRTH_CNTRY_RESN_CODE) OR ((tlinfo.BIRTH_CNTRY_RESN_CODE IS NULL) AND (X_BIRTH_CNTRY_RESN_CODE IS NULL)))
	AND ((tlinfo.CATALOG_CAL_TYPE = X_CATALOG_CAL_TYPE) OR ((tlinfo.CATALOG_CAL_TYPE IS NULL) AND (X_CATALOG_CAL_TYPE IS NULL)))
        AND ((tlinfo.CATALOG_SEQUENCE_NUMBER = X_CATALOG_SEQUENCE_NUMBER) OR ((tlinfo.CATALOG_SEQUENCE_NUMBER IS NULL) AND (X_CATALOG_SEQUENCE_NUMBER IS NULL)))
        AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((tlinfo.ATTRIBUTE_CATEGORY IS NULL)
               AND (X_ATTRIBUTE_CATEGORY IS NULL)))
        AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((tlinfo.ATTRIBUTE1 IS NULL)
               AND (X_ATTRIBUTE1 IS NULL)))
       AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((tlinfo.ATTRIBUTE2 IS NULL)
               AND (X_ATTRIBUTE2 IS NULL)))
       AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((tlinfo.ATTRIBUTE3 IS NULL)
               AND (X_ATTRIBUTE3 IS NULL)))
      AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((tlinfo.ATTRIBUTE4 IS NULL)
               AND (X_ATTRIBUTE4 IS NULL)))
      AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((tlinfo.ATTRIBUTE5 IS NULL)
               AND (X_ATTRIBUTE5 IS NULL)))
      AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((tlinfo.ATTRIBUTE6 IS NULL)
               AND (X_ATTRIBUTE6 IS NULL)))
      AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((tlinfo.ATTRIBUTE7 IS NULL)
               AND (X_ATTRIBUTE7 IS NULL)))
      AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((tlinfo.ATTRIBUTE8 IS NULL)
               AND (X_ATTRIBUTE8 IS NULL)))
      AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((tlinfo.ATTRIBUTE9 IS NULL)
               AND (X_ATTRIBUTE9 IS NULL)))
      AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((tlinfo.ATTRIBUTE10 IS NULL)
               AND (X_ATTRIBUTE10 IS NULL)))
      AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((tlinfo.ATTRIBUTE11 IS NULL)
               AND (X_ATTRIBUTE11 IS NULL)))
      AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((tlinfo.ATTRIBUTE12 IS NULL)
               AND (X_ATTRIBUTE12 IS NULL)))
      AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((tlinfo.ATTRIBUTE13 IS NULL)
               AND (X_ATTRIBUTE13 IS NULL)))
      AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((tlinfo.ATTRIBUTE14 IS NULL)
               AND (X_ATTRIBUTE14 IS NULL)))
      AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((tlinfo.ATTRIBUTE15 IS NULL)
               AND (X_ATTRIBUTE15 IS NULL)))
      AND ((tlinfo.ATTRIBUTE16 = X_ATTRIBUTE16)
           OR ((tlinfo.ATTRIBUTE16 IS NULL)
               AND (X_ATTRIBUTE16 IS NULL)))
      AND ((tlinfo.ATTRIBUTE17 = X_ATTRIBUTE17)
           OR ((tlinfo.ATTRIBUTE17 IS NULL)
               AND (X_ATTRIBUTE17 IS NULL)))
      AND ((tlinfo.ATTRIBUTE18 = X_ATTRIBUTE18)
           OR ((tlinfo.ATTRIBUTE18 IS NULL)
               AND (X_ATTRIBUTE18 IS NULL)))
      AND ((tlinfo.ATTRIBUTE19 = X_ATTRIBUTE19)
           OR ((tlinfo.ATTRIBUTE19 IS NULL)
               AND (X_ATTRIBUTE19 IS NULL)))
      AND ((tlinfo.ATTRIBUTE20 = X_ATTRIBUTE20)
          OR ((tlinfo.ATTRIBUTE20 IS NULL)
               AND (X_ATTRIBUTE20 IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
   -- x_person_profile_id                 IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_effective_start_date              IN     DATE,
    x_effective_end_date                IN     DATE,
    x_religion_cd                       IN     VARCHAR2,
    --x_criminal_convict                  IN     VARCHAR2 DEFAULT NULL,
    --x_acad_dismissal                    IN     VARCHAR2 DEFAULT NULL,
    --x_non_acad_dismissal                IN     VARCHAR2 DEFAULT NULL,
    --x_country_cd3                       IN     VARCHAR2 DEFAULT NULL,
    --x_state_of_residence                IN     VARCHAR2 DEFAULT NULL,
    --x_resid_stat_id                     IN     NUMBER DEFAULT NULL,
    x_socio_eco_cd                      IN     VARCHAR2,
    x_next_to_kin                       IN     VARCHAR2,
    x_in_state_tuition                  IN     VARCHAR2,
    x_tuition_st_date                   IN     DATE,
    x_tuition_end_date                  IN     DATE,
    x_further_education_cd                 IN     VARCHAR2,
    X_MATR_CAL_TYPE                     IN     VARCHAR2 ,--   DEFAULT NULL ,
    X_MATR_SEQUENCE_NUMBER              IN     NUMBER   ,--   DEFAULT NULL,
    X_INIT_CAL_TYPE                     IN     VARCHAR2 ,--   DEFAULT NULL ,
    X_INIT_SEQUENCE_NUMBER             IN     NUMBER    ,--  DEFAULT NULL,
    X_RECENT_CAL_TYPE                   IN     VARCHAR2 ,--   DEFAULT NULL ,
    X_RECENT_SEQUENCE_NUMBER           IN     NUMBER    ,--  DEFAULT NULL,
    X_CATALOG_CAL_TYPE                  IN     VARCHAR2 ,--   DEFAULT NULL ,
    X_CATALOG_SEQUENCE_NUMBER          IN     NUMBER    ,--  DEFAULT NULL,
    x_mode                              IN     VARCHAR2 ,--DEFAULT 'R' ,
    X_ATTRIBUTE_CATEGORY 		IN VARCHAR2 ,--DEFAULT NULL,
    X_ATTRIBUTE1 			  IN VARCHAR2,--  DEFAULT NULL,
    X_ATTRIBUTE2 			  IN VARCHAR2,-- DEFAULT NULL,
    X_ATTRIBUTE3 			  IN VARCHAR2,-- DEFAULT NULL,
    X_ATTRIBUTE4 			  IN VARCHAR2,-- DEFAULT NULL,
    X_ATTRIBUTE5  			IN VARCHAR2 ,--DEFAULT NULL,
    X_ATTRIBUTE6  			IN VARCHAR2 ,--DEFAULT NULL,
   	X_ATTRIBUTE7  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE8  			IN VARCHAR2,-- DEFAULT NULL,
	  X_ATTRIBUTE9 		  	IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE10 			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE11  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE12  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE13  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE14  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE15  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE16  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE17  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE18  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE19  			IN VARCHAR2 ,--DEFAULT NULL,
  	X_ATTRIBUTE20  			IN VARCHAR2, -- DEFAULT NULL
	X_BIRTH_CNTRY_RESN_CODE		IN VARCHAR2
  ) AS
  /*
  ||  Created By : bshankar
  ||  Created On : 28-AUG-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  Bayadav  31-Jan-2002  Bug number 2203778 .addded descriptive flexfield columns (IGS_PE_PERS_STAT )
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
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      --x_person_profile_id                 => x_person_profile_id,
      x_person_id                         => x_person_id,
      x_effective_start_date              => x_effective_start_date,
      x_effective_end_date                => x_effective_end_date,
      x_religion_cd                       => x_religion_cd,
      --x_criminal_convict                  => x_criminal_convict,
      --x_acad_dismissal                    => x_acad_dismissal,
      --x_non_acad_dismissal                => x_non_acad_dismissal,
      --x_country_cd3                       => x_country_cd3,
      --x_state_of_residence                => x_state_of_residence,
      --x_resid_stat_id                     => x_resid_stat_id,
      x_socio_eco_cd                      => x_socio_eco_cd,
      x_next_to_kin                       => x_next_to_kin,
      x_in_state_tuition                  => x_in_state_tuition,
      x_tuition_st_date                   => x_tuition_st_date,
      x_tuition_end_date                  => x_tuition_end_date,
      x_further_education_cd                 => x_further_education_cd,
      X_MATR_CAL_TYPE                     => X_MATR_CAL_TYPE,
      X_MATR_SEQUENCE_NUMBER              => X_MATR_SEQUENCE_NUMBER,
      X_INIT_CAL_TYPE                     => X_INIT_CAL_TYPE,
      X_INIT_SEQUENCE_NUMBER             => X_INIT_SEQUENCE_NUMBER,
      X_RECENT_CAL_TYPE                   => X_RECENT_CAL_TYPE,
      X_RECENT_SEQUENCE_NUMBER           => X_RECENT_SEQUENCE_NUMBER,
      X_CATALOG_CAL_TYPE                  => X_CATALOG_CAL_TYPE,
      X_CATALOG_SEQUENCE_NUMBER          => X_CATALOG_SEQUENCE_NUMBER,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      X_ATTRIBUTE_CATEGORY 		=>X_ATTRIBUTE_CATEGORY,
      X_ATTRIBUTE1 		  	=>X_ATTRIBUTE1,
      X_ATTRIBUTE2 		  	=>X_ATTRIBUTE2,
      X_ATTRIBUTE3 		  	=>X_ATTRIBUTE3,
      X_ATTRIBUTE4 	  		=>X_ATTRIBUTE4,
      X_ATTRIBUTE5  			=>X_ATTRIBUTE5,
      X_ATTRIBUTE6  			=>X_ATTRIBUTE6,
   	  X_ATTRIBUTE7  			=>X_ATTRIBUTE7,
	    X_ATTRIBUTE8  			=>X_ATTRIBUTE8,
	    X_ATTRIBUTE9  			=>X_ATTRIBUTE9,
	    X_ATTRIBUTE10 			=>X_ATTRIBUTE10,
	    X_ATTRIBUTE11  			=>X_ATTRIBUTE11,
	    X_ATTRIBUTE12  			=>X_ATTRIBUTE12,
	    X_ATTRIBUTE13  			=>X_ATTRIBUTE13,
	    X_ATTRIBUTE14  			=>X_ATTRIBUTE14,
	    X_ATTRIBUTE15  			=>X_ATTRIBUTE15,
	    X_ATTRIBUTE16  			=>X_ATTRIBUTE16,
	    X_ATTRIBUTE17  			=>X_ATTRIBUTE17,
	    X_ATTRIBUTE18  			=>X_ATTRIBUTE18,
	    X_ATTRIBUTE19  			=>X_ATTRIBUTE19,
  	  X_ATTRIBUTE20  			=>X_ATTRIBUTE20,
	  X_BIRTH_CNTRY_RESN_CODE		=>X_BIRTH_CNTRY_RESN_CODE
    );

    IF (X_MODE IN ('R', 'S')) THEN
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

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_pe_stat_details
      SET
        effective_start_date              = new_references.effective_start_date,
        effective_end_date                = new_references.effective_end_date,
        religion_cd                       = new_references.religion_cd,
        --criminal_convict                  = new_references.criminal_convict,
        --acad_dismissal                    = new_references.acad_dismissal,
        --non_acad_dismissal                = new_references.non_acad_dismissal,
        --country_cd3                       = new_references.country_cd3,
        --state_of_residence                = new_references.state_of_residence,
        --resid_stat_id                     = new_references.resid_stat_id,
        socio_eco_cd                      = new_references.socio_eco_cd,
        next_to_kin                       = new_references.next_to_kin,
        in_state_tuition                  = new_references.in_state_tuition,
        tuition_st_date                   = new_references.tuition_st_date,
        tuition_end_date                  = new_references.tuition_end_date,
        further_education_cd                 = new_references.further_education_cd,
        MATR_CAL_TYPE                     = NEW_REFERENCES.MATR_CAL_TYPE,
        MATR_SEQUENCE_NUMBER              = NEW_REFERENCES.MATR_SEQUENCE_NUMBER,
        INIT_CAL_TYPE                     = NEW_REFERENCES.INIT_CAL_TYPE,
        INIT_SEQUENCE_NUMBER             = NEW_REFERENCES.INIT_SEQUENCE_NUMBER,
        RECENT_CAL_TYPE                   = NEW_REFERENCES.RECENT_CAL_TYPE,
        RECENT_SEQUENCE_NUMBER           = NEW_REFERENCES.RECENT_SEQUENCE_NUMBER,
        CATALOG_CAL_TYPE                  = NEW_REFERENCES.CATALOG_CAL_TYPE,
        CATALOG_SEQUENCE_NUMBER          = NEW_REFERENCES.CATALOG_SEQUENCE_NUMBER,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date ,
        ATTRIBUTE_CATEGORY 		= new_references.ATTRIBUTE_CATEGORY,
        ATTRIBUTE1 		  	=new_references.ATTRIBUTE1,
        ATTRIBUTE2 		  	=new_references.ATTRIBUTE2,
        ATTRIBUTE3 		  	=new_references.ATTRIBUTE3,
        ATTRIBUTE4 	  		=new_references.ATTRIBUTE4,
        ATTRIBUTE5  			=new_references.ATTRIBUTE5,
        ATTRIBUTE6  			=new_references.ATTRIBUTE6,
   	    ATTRIBUTE7  			=new_references.ATTRIBUTE7,
	      ATTRIBUTE8  			=new_references.ATTRIBUTE8,
	      ATTRIBUTE9  			=new_references.ATTRIBUTE9,
	      ATTRIBUTE10 			=new_references.ATTRIBUTE10,
	      ATTRIBUTE11  			=new_references.ATTRIBUTE11,
	      ATTRIBUTE12  			=new_references.ATTRIBUTE12,
	      ATTRIBUTE13  			=new_references.ATTRIBUTE13,
	      ATTRIBUTE14  			=new_references.ATTRIBUTE14,
	      ATTRIBUTE15  			=new_references.ATTRIBUTE15,
	      ATTRIBUTE16  			=new_references.ATTRIBUTE16,
	      ATTRIBUTE17  			=new_references.ATTRIBUTE17,
	      ATTRIBUTE18  			=new_references.ATTRIBUTE18,
	      ATTRIBUTE19  			=new_references.ATTRIBUTE19,
  	    ATTRIBUTE20  			=new_references.ATTRIBUTE20,
	    BIRTH_CNTRY_RESN_CODE		=new_references.BIRTH_CNTRY_RESN_CODE
      WHERE ROWID = x_rowid;

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
   -- x_person_profile_id                 IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_effective_start_date              IN     DATE,
    x_effective_end_date                IN     DATE,
    x_religion_cd                       IN     VARCHAR2,
    --x_criminal_convict                  IN     VARCHAR2 DEFAULT NULL,
    --x_acad_dismissal                    IN     VARCHAR2 DEFAULT NULL,
    --x_non_acad_dismissal                IN     VARCHAR2 DEFAULT NULL,
    --x_country_cd3                       IN     VARCHAR2 DEFAULT NULL,
    --x_state_of_residence                IN     VARCHAR2 DEFAULT NULL,
    --x_resid_stat_id                     IN     NUMBER DEFAULT NULL,
    x_socio_eco_cd                     IN     VARCHAR2,
    x_next_to_kin                       IN     VARCHAR2,
    x_in_state_tuition                  IN     VARCHAR2,
    x_tuition_st_date                   IN     DATE,
    x_tuition_end_date                  IN     DATE,
    x_further_education_cd                IN     VARCHAR2 ,
    X_MATR_CAL_TYPE                     IN     VARCHAR2 ,--   DEFAULT NULL ,
    X_MATR_SEQUENCE_NUMBER              IN     NUMBER   ,--   DEFAULT NULL,
    X_INIT_CAL_TYPE                     IN     VARCHAR2 ,--   DEFAULT NULL ,
    X_INIT_SEQUENCE_NUMBER             IN     NUMBER    ,--  DEFAULT NULL,
    X_RECENT_CAL_TYPE                   IN     VARCHAR2 ,--   DEFAULT NULL ,
    X_RECENT_SEQUENCE_NUMBER           IN     NUMBER    ,--  DEFAULT NULL,
    X_CATALOG_CAL_TYPE                  IN     VARCHAR2 ,--   DEFAULT NULL ,
    X_CATALOG_SEQUENCE_NUMBER          IN     NUMBER    ,--  DEFAULT NULL,
    x_mode                              IN     VARCHAR2 ,--DEFAULT 'R' ,
    X_ATTRIBUTE_CATEGORY 		IN VARCHAR2 ,--DEFAULT NULL,
    X_ATTRIBUTE1 			  IN VARCHAR2 ,-- DEFAULT NULL,
    X_ATTRIBUTE2 			  IN VARCHAR2 ,--DEFAULT NULL,
    X_ATTRIBUTE3 			  IN VARCHAR2 ,--DEFAULT NULL,
    X_ATTRIBUTE4 			  IN VARCHAR2 ,--DEFAULT NULL,
    X_ATTRIBUTE5  			IN VARCHAR2,-- DEFAULT NULL,
    X_ATTRIBUTE6  			IN VARCHAR2,-- DEFAULT NULL,
   	X_ATTRIBUTE7  			IN VARCHAR2,-- DEFAULT NULL,
	  X_ATTRIBUTE8  			IN VARCHAR2,-- DEFAULT NULL,
	  X_ATTRIBUTE9 		  	IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE10 			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE11  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE12  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE13  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE14  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE15  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE16  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE17  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE18  			IN VARCHAR2 ,--DEFAULT NULL,
	  X_ATTRIBUTE19  			IN VARCHAR2 ,--DEFAULT NULL,
  	X_ATTRIBUTE20  			IN VARCHAR2, --DEFAULT NULL
	X_BIRTH_CNTRY_RESN_CODE		IN VARCHAR2
  ) AS
  /*
  ||  Created By : bshankar
  ||  Created On : 28-AUG-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  Bayadav  31-Jan-2002  Bug number 2203778 .addded descriptive flexfield columns (IGS_PE_PERS_STAT )
  ||  (reverse chronological order - newest change first)
  ||  ssawhney               2203778 : person_id replaces person_profile_id
  */
    CURSOR c1 IS
      SELECT   ROWID
      FROM     igs_pe_stat_details
      WHERE    person_id                 = x_person_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
       -- x_person_profile_id,
        x_person_id,
        x_effective_start_date,
        x_effective_end_date,
        x_religion_cd,
        --x_criminal_convict,
        -- x_acad_dismissal,
        --x_non_acad_dismissal,
        --x_country_cd3,
        --x_state_of_residence,
        --x_resid_stat_id,
        x_socio_eco_cd,
        x_next_to_kin,
        x_in_state_tuition,
        x_tuition_st_date,
        x_tuition_end_date,
        x_further_education_cd,
        X_MATR_CAL_TYPE,
        X_MATR_SEQUENCE_NUMBER,
        X_INIT_CAL_TYPE,
        X_INIT_SEQUENCE_NUMBER,
        X_RECENT_CAL_TYPE,
        X_RECENT_SEQUENCE_NUMBER,
        X_CATALOG_CAL_TYPE,
        X_CATALOG_SEQUENCE_NUMBER,
        x_mode ,
        X_ATTRIBUTE_CATEGORY ,
      X_ATTRIBUTE1 	,
      X_ATTRIBUTE2 	 ,
      X_ATTRIBUTE3 	 ,
      X_ATTRIBUTE4 	 ,
      X_ATTRIBUTE5   ,
      X_ATTRIBUTE6   ,
   	  X_ATTRIBUTE7   ,
	    X_ATTRIBUTE8   ,
	    X_ATTRIBUTE9   ,
	    X_ATTRIBUTE10  ,
	    X_ATTRIBUTE11  ,
	    X_ATTRIBUTE12  ,
	    X_ATTRIBUTE13  ,
	    X_ATTRIBUTE14  ,
	    X_ATTRIBUTE15  ,
	    X_ATTRIBUTE16  ,
	    X_ATTRIBUTE17  ,
	    X_ATTRIBUTE18  ,
	    X_ATTRIBUTE19  ,
  	  X_ATTRIBUTE20 ,
	  X_BIRTH_CNTRY_RESN_CODE
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      --x_person_profile_id,
      x_person_id,
      x_effective_start_date,
      x_effective_end_date,
      x_religion_cd,
      --x_criminal_convict,
      --x_acad_dismissal,
      --x_non_acad_dismissal,
      --x_country_cd3,
      --x_state_of_residence,
      --x_resid_stat_id,
      x_socio_eco_cd,
      x_next_to_kin,
      x_in_state_tuition,
      x_tuition_st_date,
      x_tuition_end_date,
      x_further_education_cd,
      X_MATR_CAL_TYPE,
      X_MATR_SEQUENCE_NUMBER,
      X_INIT_CAL_TYPE,
      X_INIT_SEQUENCE_NUMBER,
      X_RECENT_CAL_TYPE,
      X_RECENT_SEQUENCE_NUMBER,
      X_CATALOG_CAL_TYPE,
      X_CATALOG_SEQUENCE_NUMBER,
      x_mode ,
       X_ATTRIBUTE_CATEGORY ,
      X_ATTRIBUTE1 	,
      X_ATTRIBUTE2 	 ,
      X_ATTRIBUTE3 	 ,
      X_ATTRIBUTE4 	 ,
      X_ATTRIBUTE5   ,
      X_ATTRIBUTE6   ,
   	  X_ATTRIBUTE7   ,
	    X_ATTRIBUTE8   ,
	    X_ATTRIBUTE9   ,
	    X_ATTRIBUTE10  ,
	    X_ATTRIBUTE11  ,
	    X_ATTRIBUTE12  ,
	    X_ATTRIBUTE13  ,
	    X_ATTRIBUTE14  ,
	    X_ATTRIBUTE15  ,
	    X_ATTRIBUTE16  ,
	    X_ATTRIBUTE17  ,
	    X_ATTRIBUTE18  ,
	    X_ATTRIBUTE19  ,
  	  X_ATTRIBUTE20 ,
	  X_BIRTH_CNTRY_RESN_CODE
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : bshankar
  ||  Created On : 28-AUG-2000
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
 DELETE FROM igs_pe_stat_details
    WHERE ROWID = x_rowid;

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


END Igs_Pe_Stat_Details_Pkg;

/
