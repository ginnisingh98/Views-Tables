--------------------------------------------------------
--  DDL for Package Body IGS_PE_PERS_DISABLTY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_PERS_DISABLTY_PKG" AS
/* $Header: IGSNI15B.pls 120.3 2005/10/17 02:18:42 appldev ship $ */

------------------------------------------------------------------
-- Change History
--
-- Bug ID : 2000408
-- who      when          what
-- CDCRUZ   Sep 24,2002   New Col's added for
--                        Person DLD / Pk changed to Seq Gen Pk
------------------------------------------------------------------

  l_rowid VARCHAR2(25);
  old_references igs_pe_pers_disablty%RowType;
  new_references igs_pe_pers_disablty%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,--DEFAULT NULL,
    x_IGS_PE_PERS_DISABLTY_ID   IN   NUMBER ,--DEFAULT NULL,
    x_person_id IN NUMBER,-- DEFAULT NULL,
    x_disability_type IN VARCHAR2,-- DEFAULT NULL,
    x_contact_ind IN VARCHAR2 ,--DEFAULT NULL,
    x_special_allow_cd IN VARCHAR2,--DEFAULT NULL,
    x_support_level_cd IN VARCHAR2 ,--DEFAULT NULL,
    x_documented IN VARCHAR2,-- DEFAULT NULL,
    x_special_service_id IN NUMBER ,--DEFAULT NULL,
    x_attribute_category IN VARCHAR2 ,--DEFAULT NULL,
    x_attribute1 IN VARCHAR2 ,--DEFAULT NULL,
    x_attribute2 IN VARCHAR2 ,--DEFAULT NULL,
    x_attribute3 IN VARCHAR2 ,--DEFAULT NULL,
    x_attribute4 IN VARCHAR2 ,--DEFAULT NULL,
    x_attribute5 IN VARCHAR2 ,--DEFAULT NULL,
    x_attribute6 IN VARCHAR2 ,--DEFAULT NULL,
    x_attribute7 IN VARCHAR2 ,--DEFAULT NULL,
    x_attribute8 IN VARCHAR2 ,--DEFAULT NULL,
    x_attribute9 IN VARCHAR2 ,--DEFAULT NULL,
    x_attribute10 IN VARCHAR2,-- DEFAULT NULL,
    x_attribute11 IN VARCHAR2,-- DEFAULT NULL,
    x_attribute12 IN VARCHAR2,-- DEFAULT NULL,
    x_attribute13 IN VARCHAR2,-- DEFAULT NULL,
    x_attribute14 IN VARCHAR2,-- DEFAULT NULL,
    x_attribute15 IN VARCHAR2,-- DEFAULT NULL,
    x_attribute16 IN VARCHAR2,-- DEFAULT NULL,
    x_attribute17 IN VARCHAR2,-- DEFAULT NULL,
    x_attribute18 IN VARCHAR2,-- DEFAULT NULL,
    x_attribute19 IN VARCHAR2,-- DEFAULT NULL,
    x_attribute20 IN VARCHAR2,-- DEFAULT NULL,
    X_ELIG_EARLY_REG_IND        IN   VARCHAR2 ,--DEFAULT NULL,
    X_START_DATE                IN   DATE ,--DEFAULT NULL,
    X_END_DATE                  IN   DATE ,--DEFAULT NULL,
    X_INFO_SOURCE               IN   VARCHAR2,-- DEFAULT NULL,
    X_INTERVIEWER_ID            IN   NUMBER ,--DEFAULT NULL,
    X_INTERVIEWER_DATE          IN   DATE ,--DEFAULT NULL,
    x_creation_date IN DATE ,--DEFAULT NULL,
    x_created_by IN NUMBER ,--DEFAULT NULL,
    x_last_update_date IN DATE,-- DEFAULT NULL,
    x_last_updated_by IN NUMBER ,--DEFAULT NULL,
    x_last_update_login IN NUMBER --DEFAULT NULL
  ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_PERS_DISABLTY
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.person_id := x_person_id;
    NEW_REFERENCES.IGS_PE_PERS_DISABLTY_ID := X_IGS_PE_PERS_DISABLTY_ID ;
    new_references.disability_type := x_disability_type;
    new_references.contact_ind := x_contact_ind;
    new_references.special_allow_cd := x_special_allow_cd;
    new_references.support_level_cd := x_support_level_cd;
    new_references.documented := x_documented;
    new_references.special_service_id := x_special_service_id;
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
    NEW_REFERENCES.ELIG_EARLY_REG_IND      := X_ELIG_EARLY_REG_IND ;
    NEW_REFERENCES.START_DATE              := X_START_DATE    ;
    NEW_REFERENCES.END_DATE                := X_END_DATE       ;
    NEW_REFERENCES.INFO_SOURCE             := X_INFO_SOURCE     ;
    NEW_REFERENCES.INTERVIEWER_ID          := X_INTERVIEWER_ID   ;
    NEW_REFERENCES.INTERVIEWER_DATE        := X_INTERVIEWER_DATE  ;

    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;

  END Set_Column_Values;

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
           new_references.disability_type,
           new_references.start_date
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_PE_SPECIAL_DUP_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

    PROCEDURE BeforeRowInsertUpdate1
    AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
  kumma           06-JUN-2002	  Commented the call to enrp_val_pd_contact,
				  as the validation code is now present in pld, bug 2381245
  (reverse chronological order - newest change first)
  ***************************************************************/


    CURSOR cur_contact IS
      SELECT   'Y' contact_ind
      FROM     igs_pe_sn_contact
      WHERE    disability_id = new_references.igs_pe_pers_disablty_id;
    cur_contact_rec cur_contact%ROWTYPE;
    l_contact_ind VARCHAR2(1);
    -- End of fix

	v_message_name  varchar2(30);

  BEGIN

	-- Validate DISABILITY TYPE.

	-- Closed indicator.

	IF new_references.disability_type IS NOT NULL AND

		(NVL(old_references.disability_type, 'NULL') <> new_references.disability_type) THEN

		IF IGS_EN_VAL_PDI.enrp_val_dit_closed (
				new_references.disability_type,
				v_message_name ) = FALSE THEN

			FND_MESSAGE.SET_NAME('IGS', V_MESSAGE_NAME);
			IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;

		END IF;

	END IF;

  END BeforeRowInsertUpdate1;



  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  ,
		 Column_Value IN VARCHAR2 ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'DOCUMENTED'  THEN
        new_references.documented := column_value;
      ELSIF  UPPER(column_name) = 'DISABILITY_TYPE'  THEN
        new_references.disability_type := column_value;
      END IF;

      IF  UPPER(Column_Name) = 'DISABILITY_TYPE' OR
      		Column_Name IS NULL THEN
        IF new_references.DISABILITY_TYPE <> UPPER(new_references.disability_type) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
        END IF;
      END IF;


  END Check_Constraints;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    igs_pe_sn_contact_pkg.get_fk_igs_pe_pers_disablty (
      old_references.IGS_PE_PERS_DISABLTY_ID
      );

    igs_pe_sn_service_pkg.get_fk_igs_pe_pers_disablty (
      old_references.IGS_PE_PERS_DISABLTY_ID
      );

  END Check_Child_Existance;

  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.special_allow_cd = new_references.special_allow_cd)) OR
        ((new_references.special_allow_cd IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_lookups_view_pkg.Get_PK_For_Validation (
        		'PE_SN_ALLOW',new_references.special_allow_cd
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.support_level_cd = new_references.support_level_cd)) OR
        ((new_references.support_level_cd IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_lookups_view_pkg.Get_PK_For_Validation (
        		'PE_SN_ADD_SUP_LVL',new_references.support_level_cd
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;


    IF (((old_references.disability_type = new_references.disability_type)) OR
        ((new_references.disability_type IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Disbl_Type_Pkg.Get_PK_For_Validation (
        		new_references.disability_type ,
            'N'
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

   IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSE
        IF  NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
         new_references.person_id
         ) THEN
	   Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	   IGS_GE_MSG_STACK.ADD;
	   App_Exception.Raise_Exception;
	 END IF;
    END IF;


   IF (((old_references.interviewer_id = new_references.interviewer_id)) OR
        ((new_references.interviewer_id IS NULL))) THEN
      NULL;
    ELSE
        IF  NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
         new_references.interviewer_id
         ) THEN
	   Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	   IGS_GE_MSG_STACK.ADD;
	   App_Exception.Raise_Exception;
	 END IF;
    END IF;


  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    X_IGS_PE_PERS_DISABLTY_ID   IN   NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_pers_disablty
      WHERE     IGS_PE_PERS_DISABLTY_ID = X_IGS_PE_PERS_DISABLTY_ID
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return(TRUE);
    ELSE
      Close cur_rowid;
      Return(FALSE);
    END IF;
  END Get_PK_For_Validation;

  FUNCTION get_uk_for_validation (
    x_person_id                         IN     NUMBER,
    x_disability_type                  IN     VARCHAR2,
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
      FROM     igs_pe_pers_disablty
      WHERE    person_id = x_person_id
      AND      disability_type = x_disability_type
      AND     ( (start_date = x_start_date) OR (start_date IS NULL and x_start_date IS NULL ))
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

  PROCEDURE Get_FK_Igs_Pe_Person (
    x_person_id IN NUMBER
    ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_pers_disablty
      WHERE    (person_id = x_person_id or INTERVIEWER_ID = x_person_id );

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PD_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Pe_Person;

  PROCEDURE Get_FK_Igs_Ad_Disbl_Type (
    x_disability_type IN VARCHAR2
    ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_pers_disablty
      WHERE    disability_type = x_disability_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PD_DIT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Disbl_Type;

 PROCEDURE beforerowinsertupdate(p_inserting BOOLEAN,p_updating BOOLEAN) AS
  /*
  ||  Created By : pkpatel
  ||  Created On : 30-MAY-2003
  ||  Purpose : Special Needs CCR.
  ||            Other records and None special need records can coexist together, but should not overlap eachother at any time.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel         16-Jul-2005     Bug 4327807 (Person SS Enhancement)
  ||                                  Added validations related to dates
  ||  (reverse chronological order - newest change first)
  */
     l_default_end_date  DATE := TO_DATE('4712/12/31','YYYY/MM/DD');
     l_default_start_date DATE := TO_DATE('1000/01/01','YYYY/MM/DD');
     l_count         NUMBER ;
     l_govt_disability_type igs_ad_disbl_type.govt_disability_type%TYPE;

     CURSOR govt_disability_type_cur(cp_disability_type igs_ad_disbl_type.disability_type%TYPE) IS
  	 SELECT govt_disability_type
	 FROM  igs_ad_disbl_type
	 WHERE disability_type = cp_disability_type;

     CURSOR none_cur (cp_person_id igs_pe_pers_disablty.person_id%TYPE,
	                  cp_start_date igs_pe_pers_disablty.start_date%TYPE,
					  cp_end_date igs_pe_pers_disablty.end_date%TYPE,
					  cp_govt_disability_type igs_ad_disbl_type.govt_disability_type%TYPE)
	 IS
	 SELECT 1
     FROM  igs_pe_pers_disablty pdi,
       	   igs_ad_disbl_type dit
     WHERE person_id        = cp_person_id
     AND   dit.disability_type	= pdi.disability_type
	 AND   dit.govt_disability_type	= cp_govt_disability_type
     AND (
	      NVL(cp_end_date,l_default_end_date) BETWEEN NVL(start_date+1,l_default_start_date) AND NVL(end_date-1,l_default_end_date)
          OR  NVL(cp_start_date,l_default_start_date) BETWEEN NVL(start_date+1,l_default_start_date) AND NVL(end_date-1,l_default_end_date)
          OR ( NVL(cp_start_date,l_default_start_date) <= NVL(start_date,l_default_start_date) AND
          NVL(end_date,l_default_end_date) <= NVL(cp_end_date,l_default_end_date))
	     );


     CURSOR not_none_cur (cp_person_id igs_pe_pers_disablty.person_id%TYPE,
    	                  cp_start_date igs_pe_pers_disablty.start_date%TYPE,
	    				  cp_end_date igs_pe_pers_disablty.end_date%TYPE,
						  cp_govt_disability_type igs_ad_disbl_type.govt_disability_type%TYPE)
	 IS
	 SELECT 1
     FROM  igs_pe_pers_disablty pdi,
       	   igs_ad_disbl_type dit
     WHERE person_id        = cp_person_id
     AND   dit.disability_type	= pdi.disability_type
	 AND   dit.govt_disability_type	<> cp_govt_disability_type
     AND (
	      NVL(cp_end_date,l_default_end_date) BETWEEN NVL(start_date+1,l_default_start_date) AND NVL(end_date-1,l_default_end_date)
          OR  NVL(cp_start_date,l_default_start_date) BETWEEN NVL(start_date+1,l_default_start_date) AND NVL(end_date-1,l_default_end_date)
          OR ( NVL(cp_start_date,l_default_start_date) <= NVL(start_date,l_default_start_date) AND
          NVL(end_date,l_default_end_date) <= NVL(cp_end_date,l_default_end_date))
	     );

      CURSOR get_dob_dt_cur(cp_person_id igs_pe_passport.person_id%TYPE)
      IS
      SELECT birth_date
      FROM  igs_pe_person_base_v
      WHERE person_id = cp_person_id;

      l_birth_dt igs_pe_person_base_v.birth_date%TYPE;
  BEGIN

		IF new_references.start_date > new_references.end_date THEN
		  FND_MESSAGE.SET_NAME ('IGS', 'IGS_PE_FROM_DT_GRT_TO_DATE');
		  IGS_GE_MSG_STACK.ADD;
		  APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;

		 OPEN get_dob_dt_cur(new_references.person_id);
		 FETCH get_dob_dt_cur INTO l_birth_dt;
		 CLOSE get_dob_dt_cur;

		 IF l_birth_dt IS NOT NULL AND new_references.start_date IS NOT NULL THEN
			IF l_birth_dt > new_references.start_date THEN
			  FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_STRT_DT_LESS_BIRTH_DT');
			  IGS_GE_MSG_STACK.ADD;
			  APP_EXCEPTION.RAISE_EXCEPTION;
			END IF;
		 END IF;

       IF new_references.start_date IS NULL AND new_references.end_date IS NOT NULL THEN
           FND_MESSAGE.SET_NAME( 'IGS','IGS_PE_CANT_SPECIFY_FROM_DATE');
		   IGS_GE_MSG_STACK.ADD;
		   APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;

       IF new_references.start_date IS NOT NULL AND new_references.end_date IS NOT NULL THEN
           IF new_references.end_date < new_references.start_date THEN
               FND_MESSAGE.SET_NAME( 'IGS','IGS_PE_FROM_DT_GRT_TO_DATE');
			   IGS_GE_MSG_STACK.ADD;
			   APP_EXCEPTION.RAISE_EXCEPTION;
            END IF;
       END IF;

    IF p_inserting OR (p_updating AND
	                  (NVL(old_references.start_date,l_default_start_date) <> NVL(new_references.start_date,l_default_start_date) OR
  					   NVL(old_references.end_date,l_default_end_date) <> NVL(new_references.end_date,l_default_end_date))
					  ) THEN


       OPEN govt_disability_type_cur(new_references.disability_type);
	   FETCH govt_disability_type_cur INTO l_govt_disability_type;
	   CLOSE govt_disability_type_cur;

	   IF l_govt_disability_type = 'NONE' THEN
	      -- Check whether other special need Records overlapped with the 'None' exists.

		  OPEN not_none_cur(new_references.person_id,
                    	    new_references.start_date,
                  		    new_references.end_date,
                   		    'NONE');
          FETCH not_none_cur INTO l_count;

		    IF not_none_cur%FOUND THEN
			  CLOSE not_none_cur;
              FND_MESSAGE.SET_NAME( 'IGS','IGS_PE_NO_NONE_SN');
              IGS_GE_MSG_STACK.ADD;
              APP_EXCEPTION.RAISE_EXCEPTION;
			END IF;
          CLOSE not_none_cur;

	   ELSE
	      -- Check whether 'None' special need Records overlapped with other record exists.

		  OPEN none_cur(new_references.person_id,
                   	    new_references.start_date,
               		    new_references.end_date,
               		    'NONE');
          FETCH none_cur INTO l_count;

		    IF none_cur%FOUND THEN
			  CLOSE none_cur;
              FND_MESSAGE.SET_NAME( 'IGS','IGS_EN_PRSN_NOTHAVE_DIABREC');
              IGS_GE_MSG_STACK.ADD;
              APP_EXCEPTION.RAISE_EXCEPTION;
			END IF;
          CLOSE none_cur;

	   END IF;
	END IF;
  END beforerowinsertupdate;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,--DEFAULT NULL,
    X_IGS_PE_PERS_DISABLTY_ID   IN   NUMBER ,--DEFAULT NULL,
    x_person_id IN NUMBER ,--DEFAULT NULL,
    x_disability_type IN VARCHAR2,-- DEFAULT NULL,
    x_contact_ind IN VARCHAR2,-- DEFAULT NULL,
    x_special_allow_cd IN VARCHAR2 ,--DEFAULT NULL,
    x_support_level_cd IN VARCHAR2 ,--DEFAULT NULL,
    x_documented IN VARCHAR2 ,--DEFAULT NULL,
    x_special_service_id IN NUMBER,-- DEFAULT NULL,
    x_attribute_category IN VARCHAR2 ,--DEFAULT NULL,
    x_attribute1 IN VARCHAR2 ,--DEFAULT NULL,
    x_attribute2 IN VARCHAR2 ,--DEFAULT NULL,
    x_attribute3 IN VARCHAR2 ,--DEFAULT NULL,
    x_attribute4 IN VARCHAR2 ,--DEFAULT NULL,
    x_attribute5 IN VARCHAR2 ,--DEFAULT NULL,
    x_attribute6 IN VARCHAR2 ,--DEFAULT NULL,
    x_attribute7 IN VARCHAR2 ,--DEFAULT NULL,
    x_attribute8 IN VARCHAR2 ,--DEFAULT NULL,
    x_attribute9 IN VARCHAR2 ,--DEFAULT NULL,
    x_attribute10 IN VARCHAR2,-- DEFAULT NULL,
    x_attribute11 IN VARCHAR2,-- DEFAULT NULL,
    x_attribute12 IN VARCHAR2,-- DEFAULT NULL,
    x_attribute13 IN VARCHAR2,-- DEFAULT NULL,
    x_attribute14 IN VARCHAR2,-- DEFAULT NULL,
    x_attribute15 IN VARCHAR2,-- DEFAULT NULL,
    x_attribute16 IN VARCHAR2,-- DEFAULT NULL,
    x_attribute17 IN VARCHAR2,-- DEFAULT NULL,
    x_attribute18 IN VARCHAR2,-- DEFAULT NULL,
    x_attribute19 IN VARCHAR2,-- DEFAULT NULL,
    x_attribute20 IN VARCHAR2,-- DEFAULT NULL,
    X_ELIG_EARLY_REG_IND        IN   VARCHAR2,-- DEFAULT NULL,
    X_START_DATE                IN   DATE ,--DEFAULT NULL,
    X_END_DATE                  IN   DATE,-- DEFAULT NULL,
    X_INFO_SOURCE               IN   VARCHAR2,-- DEFAULT NULL,
    X_INTERVIEWER_ID            IN   NUMBER,-- DEFAULT NULL,
    X_INTERVIEWER_DATE          IN   DATE ,--DEFAULT NULL,
    x_creation_date IN DATE ,--DEFAULT NULL,
    x_created_by IN NUMBER,-- DEFAULT NULL,
    x_last_update_date IN DATE ,--DEFAULT NULL,
    x_last_updated_by IN NUMBER ,--DEFAULT NULL,
    x_last_update_login IN NUMBER-- DEFAULT NULL
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      X_IGS_PE_PERS_DISABLTY_ID,
      x_person_id,
      x_disability_type,
      x_contact_ind,
      x_special_allow_cd,
      x_support_level_cd,
      x_documented,
      x_special_service_id,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      X_ELIG_EARLY_REG_IND     ,
      X_START_DATE             ,
      X_END_DATE               ,
      X_INFO_SOURCE            ,
      X_INTERVIEWER_ID         ,
      X_INTERVIEWER_DATE       ,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

 IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
     BeforeRowInsertUpdate1 ;
      IF  Get_PK_For_Validation (
          new_references.IGS_PE_PERS_DISABLTY_ID
          ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      check_uniqueness ;
      Check_Constraints; -- if procedure present
      Check_Parent_Existance; -- if procedure present
      beforerowinsertupdate(TRUE,FALSE);

 ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
       BeforeRowInsertUpdate1;

       check_uniqueness       ;
       Check_Constraints; -- if procedure present
       Check_Parent_Existance; -- if procedure present
       beforerowinsertupdate(FALSE,TRUE);

 ELSIF (p_action = 'DELETE') THEN
       -- Call all the procedures related to Before Delete.
       Check_Child_Existance ;

 ELSIF (p_action = 'VALIDATE_INSERT') THEN

      IF  Get_PK_For_Validation (
          new_references.IGS_PE_PERS_DISABLTY_ID
          ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

      check_uniqueness ;
      Check_Constraints; -- if procedure present
 ELSIF (p_action = 'VALIDATE_UPDATE') THEN

       check_uniqueness ;
       Check_Constraints; -- if procedure present

ELSIF (p_action = 'VALIDATE_DELETE') THEN
       Check_Child_Existance ;
 END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
   sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN

      -- Call all the procedures related to After Insert.
      NULL;
    ELSIF (p_action = 'UPDATE') THEN

      -- Call all the procedures related to After Update.
      NULL;

    ELSIF (p_action = 'DELETE') THEN

      -- Call all the procedures related to After Delete.
      NULL;

    END IF;

  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       X_IGS_PE_PERS_DISABLTY_ID   IN  OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_DISABILITY_TYPE IN VARCHAR2,
       x_CONTACT_IND IN VARCHAR2,
       x_SPECIAL_ALLOW_CD IN VARCHAR2,
       x_SUPPORT_LEVEL_CD IN VARCHAR2,
       x_DOCUMENTED IN VARCHAR2,
       x_SPECIAL_SERVICE_ID IN NUMBER,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
       X_ELIG_EARLY_REG_IND        IN   VARCHAR2 ,--DEFAULT NULL,
       X_START_DATE                IN   DATE ,--DEFAULT NULL,
       X_END_DATE                  IN   DATE ,--DEFAULT NULL,
       X_INFO_SOURCE               IN   VARCHAR2 ,--DEFAULT NULL,
       X_INTERVIEWER_ID            IN   NUMBER ,--DEFAULT NULL,
       X_INTERVIEWER_DATE          IN   DATE, --DEFAULT NULL,
      X_MODE in VARCHAR2 --default 'R'
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_PE_PERS_DISABLTY
             where
	     IGS_PE_PERS_DISABLTY_ID = X_IGS_PE_PERS_DISABLTY_ID ;

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;

 begin
     X_LAST_UPDATE_DATE := SYSDATE;
      if(X_MODE = 'I') then
        X_LAST_UPDATED_BY := 1;
        X_LAST_UPDATE_LOGIN := 0;
         elsif (X_MODE IN ('R', 'S')) then
               X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
            if X_LAST_UPDATED_BY is NULL then
                X_LAST_UPDATED_BY := -1;
            end if;
            X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
         if X_LAST_UPDATE_LOGIN is NULL then
            X_LAST_UPDATE_LOGIN := -1;
          end if;
       else
        FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
       end if;

    SELECT    igs_pe_pers_disablty_s.NEXTVAL
    INTO      x_IGS_PE_PERS_DISABLTY_ID
    FROM      dual;

   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
               X_IGS_PE_PERS_DISABLTY_ID => X_IGS_PE_PERS_DISABLTY_ID ,
 	       x_person_id=>X_PERSON_ID,
 	       x_disability_type=>X_DISABILITY_TYPE,
 	       x_contact_ind=>NVL(X_CONTACT_IND,'N' ),
 	       x_special_allow_cd=>X_SPECIAL_ALLOW_CD,
 	       x_support_level_cd=>X_SUPPORT_LEVEL_CD,
 	       x_documented=>X_DOCUMENTED,
 	       x_special_service_id=>X_SPECIAL_SERVICE_ID,
 	       x_attribute_category=>X_ATTRIBUTE_CATEGORY,
 	       x_attribute1=>X_ATTRIBUTE1,
 	       x_attribute2=>X_ATTRIBUTE2,
 	       x_attribute3=>X_ATTRIBUTE3,
 	       x_attribute4=>X_ATTRIBUTE4,
 	       x_attribute5=>X_ATTRIBUTE5,
 	       x_attribute6=>X_ATTRIBUTE6,
 	       x_attribute7=>X_ATTRIBUTE7,
 	       x_attribute8=>X_ATTRIBUTE8,
 	       x_attribute9=>X_ATTRIBUTE9,
 	       x_attribute10=>X_ATTRIBUTE10,
 	       x_attribute11=>X_ATTRIBUTE11,
 	       x_attribute12=>X_ATTRIBUTE12,
 	       x_attribute13=>X_ATTRIBUTE13,
 	       x_attribute14=>X_ATTRIBUTE14,
 	       x_attribute15=>X_ATTRIBUTE15,
 	       x_attribute16=>X_ATTRIBUTE16,
 	       x_attribute17=>X_ATTRIBUTE17,
 	       x_attribute18=>X_ATTRIBUTE18,
 	       x_attribute19=>X_ATTRIBUTE19,
 	       x_attribute20=>X_ATTRIBUTE20,
               X_ELIG_EARLY_REG_IND      => X_ELIG_EARLY_REG_IND ,
               X_START_DATE              => X_START_DATE    ,
               X_END_DATE                => X_END_DATE       ,
               X_INFO_SOURCE             => X_INFO_SOURCE     ,
               X_INTERVIEWER_ID          => X_INTERVIEWER_ID   ,
               X_INTERVIEWER_DATE        => X_INTERVIEWER_DATE  ,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);

      IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_PE_PERS_DISABLTY (
                 IGS_PE_PERS_DISABLTY_ID
		,PERSON_ID
		,DISABILITY_TYPE
		,CONTACT_IND
		,SPECIAL_ALLOW_CD
		,SUPPORT_LEVEL_CD
		,DOCUMENTED
		,SPECIAL_SERVICE_ID
		,ATTRIBUTE_CATEGORY
		,ATTRIBUTE1
		,ATTRIBUTE2
		,ATTRIBUTE3
		,ATTRIBUTE4
		,ATTRIBUTE5
		,ATTRIBUTE6
		,ATTRIBUTE7
		,ATTRIBUTE8
		,ATTRIBUTE9
		,ATTRIBUTE10
		,ATTRIBUTE11
		,ATTRIBUTE12
		,ATTRIBUTE13
		,ATTRIBUTE14
		,ATTRIBUTE15
		,ATTRIBUTE16
		,ATTRIBUTE17
		,ATTRIBUTE18
		,ATTRIBUTE19
		,ATTRIBUTE20
                ,ELIG_EARLY_REG_IND
                ,START_DATE
                ,END_DATE
                ,INFO_SOURCE
                ,INTERVIEWER_ID
                ,INTERVIEWER_DATE
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
        ) values  (
                 NEW_REFERENCES.IGS_PE_PERS_DISABLTY_ID
		,NEW_REFERENCES.PERSON_ID
	        ,NEW_REFERENCES.DISABILITY_TYPE
	        ,NEW_REFERENCES.CONTACT_IND
	        ,NEW_REFERENCES.SPECIAL_ALLOW_CD
	        ,NEW_REFERENCES.SUPPORT_LEVEL_CD
	        ,NEW_REFERENCES.DOCUMENTED
	        ,NEW_REFERENCES.SPECIAL_SERVICE_ID
	        ,NEW_REFERENCES.ATTRIBUTE_CATEGORY
	        ,NEW_REFERENCES.ATTRIBUTE1
	        ,NEW_REFERENCES.ATTRIBUTE2
	        ,NEW_REFERENCES.ATTRIBUTE3
	        ,NEW_REFERENCES.ATTRIBUTE4
	        ,NEW_REFERENCES.ATTRIBUTE5
	        ,NEW_REFERENCES.ATTRIBUTE6
	        ,NEW_REFERENCES.ATTRIBUTE7
	        ,NEW_REFERENCES.ATTRIBUTE8
	        ,NEW_REFERENCES.ATTRIBUTE9
	        ,NEW_REFERENCES.ATTRIBUTE10
	        ,NEW_REFERENCES.ATTRIBUTE11
	        ,NEW_REFERENCES.ATTRIBUTE12
	        ,NEW_REFERENCES.ATTRIBUTE13
	        ,NEW_REFERENCES.ATTRIBUTE14
	        ,NEW_REFERENCES.ATTRIBUTE15
	        ,NEW_REFERENCES.ATTRIBUTE16
	        ,NEW_REFERENCES.ATTRIBUTE17
	        ,NEW_REFERENCES.ATTRIBUTE18
	        ,NEW_REFERENCES.ATTRIBUTE19
	        ,NEW_REFERENCES.ATTRIBUTE20
	        ,NEW_REFERENCES.ELIG_EARLY_REG_IND
	        ,NEW_REFERENCES.START_DATE
	        ,NEW_REFERENCES.END_DATE
	        ,NEW_REFERENCES.INFO_SOURCE
	        ,NEW_REFERENCES.INTERVIEWER_ID
	        ,NEW_REFERENCES.INTERVIEWER_DATE
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
);
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

		open c;
		 fetch c into X_ROWID;
 		if (c%notfound) then
		close c;
 	     raise no_data_found;
		end if;
 		close c;
    After_DML (
		p_action => 'INSERT' ,
		x_rowid => X_ROWID );
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

end INSERT_ROW;

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       X_IGS_PE_PERS_DISABLTY_ID   IN   NUMBER,
       x_PERSON_ID IN NUMBER,
       x_DISABILITY_TYPE IN VARCHAR2,
       x_CONTACT_IND IN VARCHAR2,
       x_SPECIAL_ALLOW_CD IN VARCHAR2,
       x_SUPPORT_LEVEL_CD IN VARCHAR2,
       x_DOCUMENTED IN VARCHAR2,
       x_SPECIAL_SERVICE_ID IN NUMBER,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
       X_ELIG_EARLY_REG_IND        IN   VARCHAR2 ,--DEFAULT NULL,
       X_START_DATE                IN   DATE ,--DEFAULT NULL,
       X_END_DATE                  IN   DATE ,--DEFAULT NULL,
       X_INFO_SOURCE               IN   VARCHAR2 ,--DEFAULT NULL,
       X_INTERVIEWER_ID            IN   NUMBER ,--DEFAULT NULL,
       X_INTERVIEWER_DATE          IN   DATE --DEFAULT NULL

       ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
        IGS_PE_PERS_DISABLTY_ID
,       CONTACT_IND
,      SPECIAL_ALLOW_CD
,      SUPPORT_LEVEL_CD
,      DOCUMENTED
,      SPECIAL_SERVICE_ID
,      ATTRIBUTE_CATEGORY
,      ATTRIBUTE1
,      ATTRIBUTE2
,      ATTRIBUTE3
,      ATTRIBUTE4
,      ATTRIBUTE5
,      ATTRIBUTE6
,      ATTRIBUTE7
,      ATTRIBUTE8
,      ATTRIBUTE9
,      ATTRIBUTE10
,      ATTRIBUTE11
,      ATTRIBUTE12
,      ATTRIBUTE13
,      ATTRIBUTE14
,      ATTRIBUTE15
,      ATTRIBUTE16
,      ATTRIBUTE17
,      ATTRIBUTE18
,      ATTRIBUTE19
,      ATTRIBUTE20
,      ELIG_EARLY_REG_IND
,      START_DATE
,      END_DATE
,      INFO_SOURCE
,      INTERVIEWER_ID
,      INTERVIEWER_DATE
    from IGS_PE_PERS_DISABLTY
    where ROWID = X_ROWID
    for update nowait;
     tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
    close c1;
    app_exception.raise_exception;
    return;
  end if;
  close c1;
if (
   ((tlinfo.SPECIAL_ALLOW_CD = X_SPECIAL_ALLOW_CD)
 	    OR ((tlinfo.SPECIAL_ALLOW_CD is null)
		AND (X_SPECIAL_ALLOW_CD is null)))
  AND ((tlinfo.SUPPORT_LEVEL_CD = X_SUPPORT_LEVEL_CD)
 	    OR ((tlinfo.SUPPORT_LEVEL_CD is null)
		AND (X_SUPPORT_LEVEL_CD is null)))
  AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
 	    OR ((tlinfo.ATTRIBUTE_CATEGORY is null)
		AND (X_ATTRIBUTE_CATEGORY is null)))
  AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
 	    OR ((tlinfo.ATTRIBUTE1 is null)
		AND (X_ATTRIBUTE1 is null)))
  AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
 	    OR ((tlinfo.ATTRIBUTE2 is null)
		AND (X_ATTRIBUTE2 is null)))
  AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
 	    OR ((tlinfo.ATTRIBUTE3 is null)
		AND (X_ATTRIBUTE3 is null)))
  AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
 	    OR ((tlinfo.ATTRIBUTE4 is null)
		AND (X_ATTRIBUTE4 is null)))
  AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
 	    OR ((tlinfo.ATTRIBUTE5 is null)
		AND (X_ATTRIBUTE5 is null)))
  AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
 	    OR ((tlinfo.ATTRIBUTE6 is null)
		AND (X_ATTRIBUTE6 is null)))
  AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
 	    OR ((tlinfo.ATTRIBUTE7 is null)
		AND (X_ATTRIBUTE7 is null)))
  AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
 	    OR ((tlinfo.ATTRIBUTE8 is null)
		AND (X_ATTRIBUTE8 is null)))
  AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
 	    OR ((tlinfo.ATTRIBUTE9 is null)
		AND (X_ATTRIBUTE9 is null)))
  AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
 	    OR ((tlinfo.ATTRIBUTE10 is null)
		AND (X_ATTRIBUTE10 is null)))
  AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
 	    OR ((tlinfo.ATTRIBUTE11 is null)
		AND (X_ATTRIBUTE11 is null)))
  AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
 	    OR ((tlinfo.ATTRIBUTE12 is null)
		AND (X_ATTRIBUTE12 is null)))
  AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
 	    OR ((tlinfo.ATTRIBUTE13 is null)
		AND (X_ATTRIBUTE13 is null)))
  AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
 	    OR ((tlinfo.ATTRIBUTE14 is null)
		AND (X_ATTRIBUTE14 is null)))
  AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
 	    OR ((tlinfo.ATTRIBUTE15 is null)
		AND (X_ATTRIBUTE15 is null)))
  AND ((tlinfo.ATTRIBUTE16 = X_ATTRIBUTE16)
 	    OR ((tlinfo.ATTRIBUTE16 is null)
		AND (X_ATTRIBUTE16 is null)))
  AND ((tlinfo.ATTRIBUTE17 = X_ATTRIBUTE17)
 	    OR ((tlinfo.ATTRIBUTE17 is null)
		AND (X_ATTRIBUTE17 is null)))
  AND ((tlinfo.ATTRIBUTE18 = X_ATTRIBUTE18)
 	    OR ((tlinfo.ATTRIBUTE18 is null)
		AND (X_ATTRIBUTE18 is null)))
  AND ((tlinfo.ATTRIBUTE19 = X_ATTRIBUTE19)
 	    OR ((tlinfo.ATTRIBUTE19 is null)
		AND (X_ATTRIBUTE19 is null)))
  AND ((tlinfo.ATTRIBUTE20 = X_ATTRIBUTE20)   OR ((tlinfo.ATTRIBUTE20 is null)	AND (X_ATTRIBUTE20 is null)))
  AND ((tlinfo.ELIG_EARLY_REG_IND = X_ELIG_EARLY_REG_IND)   OR ((tlinfo.ELIG_EARLY_REG_IND is null)	AND (X_ELIG_EARLY_REG_IND is null)))
  AND ((tlinfo.START_DATE = X_START_DATE)   OR ((tlinfo.START_DATE is null)	AND (X_START_DATE is null)))
  AND ((tlinfo.END_DATE = X_END_DATE)   OR ((tlinfo.END_DATE is null)	AND (X_END_DATE is null)))
  AND ((tlinfo.INFO_SOURCE = X_INFO_SOURCE)   OR ((tlinfo.INFO_SOURCE is null)	AND (X_INFO_SOURCE is null)))
  AND ((tlinfo.INTERVIEWER_ID = X_INTERVIEWER_ID)   OR ((tlinfo.INTERVIEWER_ID is null)	AND (X_INTERVIEWER_ID is null)))
  AND ((tlinfo.INTERVIEWER_DATE = X_INTERVIEWER_DATE)   OR ((tlinfo.INTERVIEWER_DATE is null)	AND (X_INTERVIEWER_DATE is null)))


  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;
 Procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       X_IGS_PE_PERS_DISABLTY_ID   IN   NUMBER,
       x_PERSON_ID IN NUMBER,
       x_DISABILITY_TYPE IN VARCHAR2,
       x_CONTACT_IND IN VARCHAR2,
       x_SPECIAL_ALLOW_CD IN VARCHAR2,
       x_SUPPORT_LEVEL_CD IN VARCHAR2,
       x_DOCUMENTED IN VARCHAR2,
       x_SPECIAL_SERVICE_ID IN NUMBER,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
       X_ELIG_EARLY_REG_IND        IN   VARCHAR2 ,--DEFAULT NULL,
       X_START_DATE                IN   DATE ,--DEFAULT NULL,
       X_END_DATE                  IN   DATE ,--DEFAULT NULL,
       X_INFO_SOURCE               IN   VARCHAR2,-- DEFAULT NULL,
       X_INTERVIEWER_ID            IN   NUMBER,-- DEFAULT NULL,
       X_INTERVIEWER_DATE          IN   DATE ,--DEFAULT NULL,
      X_MODE in VARCHAR2 --  default 'R'
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
 begin
     X_LAST_UPDATE_DATE := SYSDATE;
      if(X_MODE = 'I') then
        X_LAST_UPDATED_BY := 1;
        X_LAST_UPDATE_LOGIN := 0;
         elsif (X_MODE IN ('R', 'S')) then
               X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
            if X_LAST_UPDATED_BY is NULL then
                X_LAST_UPDATED_BY := -1;
            end if;
            X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
         if X_LAST_UPDATE_LOGIN is NULL then
            X_LAST_UPDATE_LOGIN := -1;
          end if;
       else
        FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
       end if;
   Before_DML(
 		p_action=>'UPDATE',
 		x_rowid=>X_ROWID,
               X_IGS_PE_PERS_DISABLTY_ID => X_IGS_PE_PERS_DISABLTY_ID ,
 	       x_person_id=>X_PERSON_ID,
 	       x_disability_type=>X_DISABILITY_TYPE,
 	       x_special_allow_cd=>X_SPECIAL_ALLOW_CD,
 	       x_support_level_cd=>X_SUPPORT_LEVEL_CD,
 	       x_documented=>X_DOCUMENTED,
 	       x_attribute_category=>X_ATTRIBUTE_CATEGORY,
 	       x_attribute1=>X_ATTRIBUTE1,
 	       x_attribute2=>X_ATTRIBUTE2,
 	       x_attribute3=>X_ATTRIBUTE3,
 	       x_attribute4=>X_ATTRIBUTE4,
 	       x_attribute5=>X_ATTRIBUTE5,
 	       x_attribute6=>X_ATTRIBUTE6,
 	       x_attribute7=>X_ATTRIBUTE7,
 	       x_attribute8=>X_ATTRIBUTE8,
 	       x_attribute9=>X_ATTRIBUTE9,
 	       x_attribute10=>X_ATTRIBUTE10,
 	       x_attribute11=>X_ATTRIBUTE11,
 	       x_attribute12=>X_ATTRIBUTE12,
 	       x_attribute13=>X_ATTRIBUTE13,
 	       x_attribute14=>X_ATTRIBUTE14,
 	       x_attribute15=>X_ATTRIBUTE15,
 	       x_attribute16=>X_ATTRIBUTE16,
 	       x_attribute17=>X_ATTRIBUTE17,
 	       x_attribute18=>X_ATTRIBUTE18,
 	       x_attribute19=>X_ATTRIBUTE19,
 	       x_attribute20=>X_ATTRIBUTE20,
               X_ELIG_EARLY_REG_IND      => X_ELIG_EARLY_REG_IND ,
               X_START_DATE              => X_START_DATE    ,
               X_END_DATE                => X_END_DATE       ,
               X_INFO_SOURCE             => X_INFO_SOURCE     ,
               X_INTERVIEWER_ID          => X_INTERVIEWER_ID   ,
               X_INTERVIEWER_DATE        => X_INTERVIEWER_DATE  ,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
    IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 update IGS_PE_PERS_DISABLTY set
      SPECIAL_ALLOW_CD =  NEW_REFERENCES.SPECIAL_ALLOW_CD,
      SUPPORT_LEVEL_CD =  NEW_REFERENCES.SUPPORT_LEVEL_CD,
      ATTRIBUTE_CATEGORY =  NEW_REFERENCES.ATTRIBUTE_CATEGORY,
      ATTRIBUTE1 =  NEW_REFERENCES.ATTRIBUTE1,
      ATTRIBUTE2 =  NEW_REFERENCES.ATTRIBUTE2,
      ATTRIBUTE3 =  NEW_REFERENCES.ATTRIBUTE3,
      ATTRIBUTE4 =  NEW_REFERENCES.ATTRIBUTE4,
      ATTRIBUTE5 =  NEW_REFERENCES.ATTRIBUTE5,
      ATTRIBUTE6 =  NEW_REFERENCES.ATTRIBUTE6,
      ATTRIBUTE7 =  NEW_REFERENCES.ATTRIBUTE7,
      ATTRIBUTE8 =  NEW_REFERENCES.ATTRIBUTE8,
      ATTRIBUTE9 =  NEW_REFERENCES.ATTRIBUTE9,
      ATTRIBUTE10 =  NEW_REFERENCES.ATTRIBUTE10,
      ATTRIBUTE11 =  NEW_REFERENCES.ATTRIBUTE11,
      ATTRIBUTE12 =  NEW_REFERENCES.ATTRIBUTE12,
      ATTRIBUTE13 =  NEW_REFERENCES.ATTRIBUTE13,
      ATTRIBUTE14 =  NEW_REFERENCES.ATTRIBUTE14,
      ATTRIBUTE15 =  NEW_REFERENCES.ATTRIBUTE15,
      ATTRIBUTE16 =  NEW_REFERENCES.ATTRIBUTE16,
      ATTRIBUTE17 =  NEW_REFERENCES.ATTRIBUTE17,
      ATTRIBUTE18 =  NEW_REFERENCES.ATTRIBUTE18,
      ATTRIBUTE19 =  NEW_REFERENCES.ATTRIBUTE19,
      ATTRIBUTE20 =  NEW_REFERENCES.ATTRIBUTE20,
      ELIG_EARLY_REG_IND      = NEW_REFERENCES.ELIG_EARLY_REG_IND ,
      START_DATE              = NEW_REFERENCES.START_DATE    ,
      END_DATE                = NEW_REFERENCES.END_DATE       ,
      INFO_SOURCE             = NEW_REFERENCES.INFO_SOURCE     ,
      INTERVIEWER_ID          = NEW_REFERENCES.INTERVIEWER_ID   ,
      INTERVIEWER_DATE        = NEW_REFERENCES.INTERVIEWER_DATE  ,
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
	  where ROWID = X_ROWID;
	if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
	end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


 After_DML (
	p_action => 'UPDATE' ,
	x_rowid => X_ROWID
	);
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

end UPDATE_ROW;
 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
      X_IGS_PE_PERS_DISABLTY_ID   IN  OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_DISABILITY_TYPE IN VARCHAR2,
       x_CONTACT_IND IN VARCHAR2,
       x_SPECIAL_ALLOW_CD IN VARCHAR2,
       x_SUPPORT_LEVEL_CD IN VARCHAR2,
       x_DOCUMENTED IN VARCHAR2,
       x_SPECIAL_SERVICE_ID IN NUMBER,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
       X_ELIG_EARLY_REG_IND        IN   VARCHAR2 ,--DEFAULT NULL,
       X_START_DATE                IN   DATE ,--DEFAULT NULL,
       X_END_DATE                  IN   DATE ,--DEFAULT NULL,
       X_INFO_SOURCE               IN   VARCHAR2,-- DEFAULT NULL,
       X_INTERVIEWER_ID            IN   NUMBER ,--DEFAULT NULL,
       X_INTERVIEWER_DATE          IN   DATE ,--DEFAULT NULL,
      X_MODE in VARCHAR2 -- default 'R'
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
   sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_PE_PERS_DISABLTY
             where    IGS_PE_PERS_DISABLTY_ID = X_IGS_PE_PERS_DISABLTY_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_IGS_PE_PERS_DISABLTY_ID,
       X_PERSON_ID,
       X_DISABILITY_TYPE,
       X_CONTACT_IND,
       X_SPECIAL_ALLOW_CD,
       X_SUPPORT_LEVEL_CD,
       X_DOCUMENTED,
       X_SPECIAL_SERVICE_ID,
       X_ATTRIBUTE_CATEGORY,
       X_ATTRIBUTE1,
       X_ATTRIBUTE2,
       X_ATTRIBUTE3,
       X_ATTRIBUTE4,
       X_ATTRIBUTE5,
       X_ATTRIBUTE6,
       X_ATTRIBUTE7,
       X_ATTRIBUTE8,
       X_ATTRIBUTE9,
       X_ATTRIBUTE10,
       X_ATTRIBUTE11,
       X_ATTRIBUTE12,
       X_ATTRIBUTE13,
       X_ATTRIBUTE14,
       X_ATTRIBUTE15,
       X_ATTRIBUTE16,
       X_ATTRIBUTE17,
       X_ATTRIBUTE18,
       X_ATTRIBUTE19,
       X_ATTRIBUTE20,
       X_ELIG_EARLY_REG_IND     ,
       X_START_DATE             ,
       X_END_DATE               ,
       X_INFO_SOURCE            ,
       X_INTERVIEWER_ID         ,
       X_INTERVIEWER_DATE       ,
       X_MODE );

     return;

	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_IGS_PE_PERS_DISABLTY_ID,
       X_PERSON_ID,
       X_DISABILITY_TYPE,
       X_CONTACT_IND,
       X_SPECIAL_ALLOW_CD,
       X_SUPPORT_LEVEL_CD,
       X_DOCUMENTED,
       X_SPECIAL_SERVICE_ID,
       X_ATTRIBUTE_CATEGORY,
       X_ATTRIBUTE1,
       X_ATTRIBUTE2,
       X_ATTRIBUTE3,
       X_ATTRIBUTE4,
       X_ATTRIBUTE5,
       X_ATTRIBUTE6,
       X_ATTRIBUTE7,
       X_ATTRIBUTE8,
       X_ATTRIBUTE9,
       X_ATTRIBUTE10,
       X_ATTRIBUTE11,
       X_ATTRIBUTE12,
       X_ATTRIBUTE13,
       X_ATTRIBUTE14,
       X_ATTRIBUTE15,
       X_ATTRIBUTE16,
       X_ATTRIBUTE17,
       X_ATTRIBUTE18,
       X_ATTRIBUTE19,
       X_ATTRIBUTE20,
       X_ELIG_EARLY_REG_IND     ,
       X_START_DATE             ,
       X_END_DATE               ,
       X_INFO_SOURCE            ,
       X_INTERVIEWER_ID         ,
       X_INTERVIEWER_DATE       ,
      X_MODE );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

begin
Before_DML (
p_action => 'DELETE',
x_rowid => X_ROWID
);
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 delete from IGS_PE_PERS_DISABLTY
 where ROWID = X_ROWID;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_pe_pers_disablty_pkg;

/
