--------------------------------------------------------
--  DDL for Package Body IGS_PE_ALT_PERS_ID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_ALT_PERS_ID_PKG" as
 /* $Header: IGSNI02B.pls 120.4 2005/10/17 02:23:06 appldev ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    09-OCT-2001     Bug No. 2037667 .Comparision in the Lock_row procedure of the Start_dt and End_dt has been changed to compare only the date part.
  --smadathi    28-AUG-2001     Bug No. 1956374 .The Call to igs_en_val_api.genp_val_strt_end_dt
  --                            is replaced by igs_ad_val_edtl.genp_val_strt_end_dt
  --smadathi    24-AUG-2001     Bug No. 1956374 .The call to igs_en_val_api.genp_val_sdtt_sess
  --                            is changed to igs_as_val_suaap.genp_val_sdtt_sess
  --
  -- who	when		what
  -- CDCRUZ	Sep 24,2002	Bug ID : 2000408
  --				New Flex Fld Col's added for Person DLD
  --askapoor	31-JAN-2005     Bug No: 3882788
  --                            saving trunc(start_dt) and trunc(end_dt)
  --skpandey	01-AUG-2005	Bug No:4327807
  --				Added an additional condition for p_action='DELETE' to accomodate Business logic
  -------------------------------------------------------------------------------------------
  l_rowid VARCHAR2(25);
  old_references IGS_PE_ALT_PERS_ID%RowType;
  new_references IGS_PE_ALT_PERS_ID%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_pe_person_id IN NUMBER,
    x_api_person_id IN VARCHAR2,
    X_API_PERSON_ID_UF IN VARCHAR2,
    x_person_id_type IN VARCHAR2,
    x_start_dt IN DATE,
    x_end_dt IN DATE,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
  x_attribute_category  IN VARCHAR2,
  x_attribute1          IN VARCHAR2,
  x_attribute2          IN VARCHAR2,
  x_attribute3          IN VARCHAR2,
  x_attribute4          IN VARCHAR2,
  x_attribute5          IN VARCHAR2,
  x_attribute6          IN VARCHAR2,
  x_attribute7          IN VARCHAR2,
  x_attribute8          IN VARCHAR2,
  x_attribute9          IN VARCHAR2,
  x_attribute10         IN VARCHAR2,
  x_attribute11         IN VARCHAR2,
  x_attribute12         IN VARCHAR2,
  x_attribute13         IN VARCHAR2,
  x_attribute14         IN VARCHAR2,
  x_attribute15         IN VARCHAR2,
  x_attribute16         IN VARCHAR2,
  x_attribute17         IN VARCHAR2,
  x_attribute18         IN VARCHAR2,
  x_attribute19         IN VARCHAR2,
  x_attribute20         IN VARCHAR2,
  x_region_cd           IN VARCHAR2
  ) as
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_ALT_PERS_ID
      WHERE    rowid = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
       IGS_GE_MSG_STACK.ADD;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;
    -- Populate New Values.

    IF p_action = 'DELETE' THEN
      RETURN;
    END IF;

    new_references.pe_person_id := x_pe_person_id;
    new_references.api_person_id := x_api_person_id;
    new_references.api_person_id_uf := igs_en_val_api.unformat_api(x_api_person_id);
    new_references.person_id_type := x_person_id_type;
    new_references.start_dt := trunc(x_start_dt);
    new_references.end_dt := trunc(x_end_dt);
  new_references.attribute_category  := x_attribute_category ;
  new_references.attribute1          := x_attribute1 ;
  new_references.attribute2          := x_attribute2 ;
  new_references.attribute3          := x_attribute3 ;
  new_references.attribute4          := x_attribute4 ;
  new_references.attribute5          := x_attribute5 ;
  new_references.attribute6          := x_attribute6 ;
  new_references.attribute7          := x_attribute7 ;
  new_references.attribute8          := x_attribute8 ;
  new_references.attribute9          := x_attribute9 ;
  new_references.attribute10         := x_attribute10 ;
  new_references.attribute11         := x_attribute11 ;
  new_references.attribute12         := x_attribute12 ;
  new_references.attribute13         := x_attribute13 ;
  new_references.attribute14         := x_attribute14 ;
  new_references.attribute15         := x_attribute15 ;
  new_references.attribute16         := x_attribute16 ;
  new_references.attribute17         := x_attribute17 ;
  new_references.attribute18         := x_attribute18 ;
  new_references.attribute19         := x_attribute19 ;
  new_references.attribute20         := x_attribute20 ;
  new_references.region_cd           := x_region_cd ;

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

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) as
  ------------------------------------------------------------------------------------------
  --Created by  : pkpatel
  --Date created: 06-JUN-2002
  --
  --Purpose:
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --pkpatel    8-JUN-2002       Bug No: 2402077
  --                            Removed the call to igs_as_val_suaap.genp_val_sdtt_sess('IGS_PE_ALT_PERS_ID') and
  --                            all unnecessary check so that the date validation procedures can be called properly.
  --askapoor   31-JAN-2005      Bug No: 3882788
  --                            Removed end_dt < sysdate and added check start_dt = end_dt
  --pkpatel    16-JUL-2005      Bug 4327807 (Person SS Enhancement)
  --                            Validate Format Mask
  ----------------------------------------------------------------------------------------------
	v_message_name  varchar2(30);

	CURSOR birth_date_cur(cp_person_id hz_parties.party_id%TYPE) IS
	SELECT birth_date
	FROM   igs_pe_person_base_v
	WHERE  person_id = cp_person_id;

	CURSOR format_mask_cur (cp_person_id_type VARCHAR2) IS
	SELECT format_mask
	FROM   igs_pe_person_id_typ
	WHERE  person_id_type = cp_person_id_type;

    birth_date_rec  birth_date_cur%ROWTYPE;
    format_mask_rec format_mask_cur%ROWTYPE;

  BEGIN

   IF p_inserting THEN
     OPEN format_mask_cur(new_references.person_id_type);
	 FETCH format_mask_cur INTO format_mask_rec;
	 CLOSE format_mask_cur;

     IF format_mask_rec.format_mask IS NOT NULL THEN
        IF NOT igs_en_val_api.fm_equal(new_references.api_person_id, format_mask_rec.format_mask) THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_PE_PID_MASK');
          FND_MESSAGE.SET_TOKEN('FORMAT',format_mask_rec.format_mask);
		  IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
     END IF;

   END IF;

    -- Validate START DATE AND END DATE.
   IF p_inserting OR p_updating THEN

		-- Validate that if end date is specified, then start date is also specified.
		-- As part of the bug 1956374 changed the following call from IGS_EN_VAL_API.enrp_val_api_end_dt
			IF IGS_EN_VAL_PAL.enrp_val_api_end_dt (
			 		new_references.start_dt,
				 	new_references.end_dt,
			 		v_message_name) = FALSE THEN
				  Fnd_Message.Set_Name('IGS', v_message_name);
				  IGS_GE_MSG_STACK.ADD;
                  App_Exception.Raise_Exception;
			END IF;

 		-- Validate that if both are specified, then end is not greater than start.
		IF (new_references.end_dt IS NOT NULL) 	THEN
			IF igs_ad_val_edtl.genp_val_strt_end_dt (
				 	new_references.start_dt,
				 	new_references.end_dt,
				 	v_message_name) = FALSE THEN
				  FND_MESSAGE.SET_NAME('IGS', v_message_name);
				  IGS_GE_MSG_STACK.ADD;
                  APP_EXCEPTION.RAISE_EXCEPTION;
			END IF;
		END IF;

        OPEN  birth_date_cur(new_references.pe_person_id);
		FETCH birth_date_cur INTO birth_date_rec;
		CLOSE birth_date_cur;

     IF birth_date_rec.birth_date IS NOT NULL THEN
		IF new_references.start_dt < birth_date_rec.birth_date THEN
		  FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_STRT_DT_LESS_BIRTH_DT');
		  IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
     END IF;

  END IF;

      IF (old_references.end_dt IS NOT NULL) AND
         (trunc(new_references.end_dt) <> trunc(old_references.end_dt)) AND
         (trunc(old_references.end_dt) = trunc(old_references.start_dt) ) THEN
		  FND_MESSAGE.SET_NAME('IGS', 'IGS_PE_ALT_END_DT_VAL');
		  IGS_GE_MSG_STACK.ADD;
                  APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

  END BeforeRowInsertUpdate1;

  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) as
  ------------------------------------------------------------------------------------------
  --Created by  : pkpatel
  --Date created: 06-JUN-2002
  --
  --Purpose:
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --pkpatel     8-JUN-2002      Bug No: 2402077
  --                            Added the call igs_en_val_api.val_overlap_api so that there would be only one ACTIVE
  --                            alternate person id exist for a person ID type for a person
  --                            Added the call igs_en_val_api.val_ssn_overlap_api so that there would be only one ACTIVE
  --                            alternate person id exist for Social Security Number for a person
  --ssaleem     17-Sep-2004     Bug 3787210 -- added Closed Ind igs_pe_person_id_typ table
  --gmaheswa    29-Sep-2004     BUG 3787210 removed Closed indicator check for the Alternate Person Id type while end date overlap check.

  ----------------------------------------------------------------------------------------------
	v_message_name varchar2(30);
	v_rowid_saved	BOOLEAN := FALSE;
  	cst_pay_adv_no		CONSTANT	VARCHAR2(10) := 'PAY_ADV_NO';
  	v_dummy			VARCHAR2(1);
  	CURSOR	c_pit (cp_person_id_type	IGS_PE_PERSON_ID_TYP.person_id_type%TYPE) IS
	SELECT 	'x'
  	FROM	IGS_PE_PERSON_ID_TYP		pit
  	WHERE	pit.person_id_type 	= cp_person_id_type AND
    		pit.s_person_id_type 	= cst_pay_adv_no AND
		pit.closed_ind = 'N';

     CURSOR	sys_pit_cur (cp_person_id_type	IGS_PE_PERSON_ID_TYP.person_id_type%TYPE) IS
	 SELECT	pit.s_person_id_type
	 FROM	igs_pe_person_id_typ pit
	 WHERE	pit.person_id_type 	= cp_person_id_type;

	l_s_person_id_type	IGS_PE_PERSON_ID_TYP.s_person_id_type%TYPE;

  BEGIN
	-- Validate the alternate IGS_PE_PERSON id when a 'PAY_ADV_NO' is unique.
	IF p_inserting OR p_updating THEN

	  OPEN sys_pit_cur(new_references.person_id_type);
	  FETCH sys_pit_cur INTO l_s_person_id_type;
	  CLOSE sys_pit_cur;

     IF l_s_person_id_type = 'PAY_ADV_NO' THEN
  		-- Validate the alternate person id when a 'PAY_ADV_NO' is unique.
  		OPEN c_pit (new_references.person_id_type);
  		FETCH c_pit INTO v_dummy;
  		IF (c_pit%FOUND) THEN
  			CLOSE c_pit;
  			IF IGS_EN_VAL_API.enrp_val_api_pan (
  					new_references.pe_person_id,
  					new_references.api_person_id,
  					v_message_name) = FALSE THEN
				 Fnd_Message.Set_Name('IGS', v_message_name);
				 IGS_GE_MSG_STACK.ADD;
                 APP_EXCEPTION.RAISE_EXCEPTION;
  			END IF;
  		ELSE
  			CLOSE c_pit;
  		END IF;
      END IF;


      IF l_s_person_id_type <> 'SSN' THEN
	    IF NOT igs_en_val_api.val_overlap_api(new_references.pe_person_id) THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_PE_PERS_ID_PRD_OVRLP');
  	       IGS_GE_MSG_STACK.ADD;
      	   APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
      ELSE
	    IF NOT igs_en_val_api.val_ssn_overlap_api(new_references.pe_person_id) THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_PE_SSN_PERS_ID_PRD_OVRLP');
  	       IGS_GE_MSG_STACK.ADD;
      	   APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
	  END IF;
	END IF;

  END AfterRowInsertUpdate2;

  PROCEDURE BeforeInsert IS
  ------------------------------------------------------------------------------------------
  --Created by  : pkpatel
  --Date created: 06-JUN-2002
  --
  --Purpose: Bug No: 2402077. Modified to show the message to which person the Alternate Person ID
  --         is associate, whenever the uniqueness is violated for a Person ID Type with unique indicator
  --         checked.
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --pkpatel     13-JAN-2003     Bug 2397876
  --                            Remove the FOR UPDATE NOWAIT
  --pkpatel     3-APR-2003      Bug No: 2859277
  --                            Closed the cursor cptu for cursor%NOTFOUND condition
  --ssawhney    7-sep-2004      Bug No: 3832912
  --                            introduced date check in the uniqueness cursor, cptu. uniqueness of alt id to be checked only for
  --                            active records, for all alt id types other than PAY_ADV_NO, not sure why though, checked no team uses this
  --                            s-alt-persid.
  --askapoor   31-JAN-2005      Bug No: 3882788
  --                            Included condition start_dt <> end_dt or end_dt is null
  --                            Removed condition start_dt < end_dt and end_dt > start_dt
  ----------------------------------------------------------------------------------------------
    CURSOR pt IS
    SELECT unique_ind
    FROM   igs_pe_person_id_typ
    WHERE  person_id_type = new_references.person_id_type AND
           closed_ind = 'N';

    CURSOR cptu IS
    SELECT hz.party_number
    FROM  igs_pe_alt_pers_id alt, hz_parties hz
    WHERE alt.person_id_type = new_references.person_id_type
    AND   alt.api_person_id = new_references.api_person_id
    AND   alt.pe_person_id <> new_references.pe_person_id
    AND   (alt.start_dt <> alt.end_dt OR alt.end_dt IS NULL)
    AND   alt.pe_person_id = hz.party_id;

    lv_UniqueInd VARCHAR2(1);
    l_person_number     hz_parties.party_number%TYPE;

  BEGIN
    FOR pt_rec IN pt LOOP
      lv_UniqueInd := pt_rec.unique_ind;
    END LOOP;

    IF NVL(lv_UniqueInd, 'N')  = 'Y' THEN
      Open cptu;
      FETCH cptu INTO l_person_number;
      IF (cptu%FOUND) THEN
        Close cptu;
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PE_UNIQUE_PID');
        FND_MESSAGE.SET_TOKEN ('PREF_ALTERNATE_ID1', new_references.person_id_type);
        FND_MESSAGE.SET_TOKEN ('PREF_ALTERNATE_ID2', new_references.person_id_type);
        FND_MESSAGE.SET_TOKEN ('PERSON_NUMBER', l_person_number);
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
	  Close cptu;
    END IF;

  END beforeinsert;

  PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2,
 Column_Value 	IN	VARCHAR2
 )
 as
 BEGIN
     IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'API_PERSON_ID' then
     new_references.api_person_id:= column_value;
 ELSIF upper(Column_name) = 'PERSON_ID_TYPE' then
     new_references. person_id_type := column_value;
END IF;

IF upper(column_name) = 'API_PERSON_ID' OR
     column_name is null Then
     IF new_references.api_person_id <> UPPER(new_references.api_person_id) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;

IF upper(column_name) = 'PERSON_ID_TYPE' OR
     column_name is null Then
     IF new_references.person_id_type <>
UPPER(new_references.person_id_type ) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;
 END Check_Constraints;

  PROCEDURE Check_Parent_Existance as
  BEGIN
    IF (((old_references.pe_person_id = new_references.pe_person_id)) OR
        ((new_references.pe_person_id IS NULL))) THEN
      NULL;
    ELSE
         IF  NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
         	 new_references.pe_person_id ) THEN
    		 Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
    		 IGS_GE_MSG_STACK.ADD;
     		App_Exception.Raise_Exception;
        END IF;
    END IF;
    IF (((old_references.person_id_type = new_references.person_id_type)) OR
        ((new_references.person_id_type IS NULL))) THEN
      NULL;
    ELSE
      IF  NOT IGS_PE_PERSON_ID_TYP_PKG.Get_PID_Type_Validation (
             new_references.person_id_type) THEN
             Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
             IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
         END IF;
    END IF;
  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_pe_person_id IN NUMBER,
    x_api_person_id IN VARCHAR2,
    x_person_id_type IN VARCHAR2,
    x_start_dt IN DATE
    )  RETURN BOOLEAN as
  ------------------------------------------------------------------------------------------
  --Created by  : pkpatel
  --Date created: 06-JUN-2002
  --
  --Purpose:
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --kpadiyar    27-JAN-2003     Bug 2726415 - Added start_dt as part of the pk
  ----------------------------------------------------------------------------------------------
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_ALT_PERS_ID
      WHERE    pe_person_id = x_pe_person_id
      AND      api_person_id = x_api_person_id
      AND      person_id_type = x_person_id_type
      AND      trunc(start_dt) = trunc(x_start_dt)
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
     IF (cur_rowid%FOUND) THEN
       Close cur_rowid;
       Return (TRUE);
 ELSE
       Close cur_rowid;
       Return (FALSE);
 END IF;
  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN VARCHAR2
    ) as
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_ALT_PERS_ID
      WHERE    pe_person_id = x_person_id ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_API_PE_FK');
       IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PE_PERSON;

  PROCEDURE Before_DML (
    p_action       IN VARCHAR2,
    x_rowid        IN VARCHAR2,
    x_pe_person_id IN NUMBER,
    x_api_person_id IN VARCHAR2,
    X_API_PERSON_ID_UF IN VARCHAR2,
    x_person_id_type IN VARCHAR2,
    x_start_dt       IN DATE,
    x_end_dt         IN DATE,
  x_attribute_category  IN VARCHAR2,
  x_attribute1          IN VARCHAR2,
  x_attribute2          IN VARCHAR2,
  x_attribute3          IN VARCHAR2,
  x_attribute4          IN VARCHAR2,
  x_attribute5          IN VARCHAR2,
  x_attribute6          IN VARCHAR2,
  x_attribute7          IN VARCHAR2,
  x_attribute8          IN VARCHAR2,
  x_attribute9          IN VARCHAR2,
  x_attribute10         IN VARCHAR2,
  x_attribute11         IN VARCHAR2,
  x_attribute12         IN VARCHAR2,
  x_attribute13         IN VARCHAR2,
  x_attribute14         IN VARCHAR2,
  x_attribute15         IN VARCHAR2,
  x_attribute16         IN VARCHAR2,
  x_attribute17         IN VARCHAR2,
  x_attribute18         IN VARCHAR2,
  x_attribute19         IN VARCHAR2,
  x_attribute20         IN VARCHAR2,
  x_region_cd           IN VARCHAR2,
  x_creation_date       IN DATE,
  x_created_by          IN NUMBER,
  x_last_update_date    IN DATE,
  x_last_updated_by     IN NUMBER,
  x_last_update_login   IN NUMBER
  ) as
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_pe_person_id,
      x_api_person_id,
      x_api_person_id_uf,
      x_person_id_type,
      x_start_dt,
      x_end_dt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
   x_attribute_category,
   x_attribute1  ,
   x_attribute2  ,
   x_attribute3  ,
   x_attribute4  ,
   x_attribute5  ,
   x_attribute6  ,
   x_attribute7  ,
   x_attribute8  ,
   x_attribute9  ,
   x_attribute10 ,
   x_attribute11 ,
   x_attribute12 ,
   x_attribute13 ,
   x_attribute14 ,
   x_attribute15 ,
   x_attribute16 ,
   x_attribute17 ,
   x_attribute18 ,
   x_attribute19 ,
   x_attribute20 ,
   x_region_cd
    );
     IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
	  BeforeRowInsertUpdate1(
      	    p_inserting => TRUE,
            p_updating  => FALSE,
            p_deleting  => FALSE
			);

      IF  Get_PK_For_Validation (
                new_references.pe_person_id ,
                new_references.api_person_id ,
                new_references.person_id_type,
                new_references.start_dt )
            THEN
         FND_MESSAGE.SET_NAME ('IGS', 'IGS_PE_ALT_DUP_EXISTS');
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

      Check_Constraints; -- if procedure present
      Check_Parent_Existance; -- if procedure present
      BeforeInsert;

 ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
       BeforeRowInsertUpdate1(
      	    p_inserting => FALSE,
            p_updating  => TRUE,
            p_deleting  => FALSE
			);

       Check_Constraints; -- if procedure present
       Check_Parent_Existance; -- if procedure present

 ELSIF (p_action = 'DELETE') THEN NULL;
       -- Call all the procedures related to Before Delete.
      NULL;

 ELSIF (p_action = 'VALIDATE_INSERT') THEN

	  BeforeRowInsertUpdate1(
      	    p_inserting => TRUE,
            p_updating  => FALSE,
            p_deleting  => FALSE
			);

      IF  Get_PK_For_Validation (
                new_references.pe_person_id ,
                new_references.api_person_id ,
                new_references.person_id_type,
                new_references.start_dt
          ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_PE_ALT_DUP_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

      Check_Constraints; -- if procedure present
      BeforeInsert;
 ELSIF (p_action = 'VALIDATE_UPDATE') THEN

       BeforeRowInsertUpdate1(
      	    p_inserting => FALSE,
            p_updating  => TRUE,
            p_deleting  => FALSE
			);

       Check_Constraints; -- if procedure present


  ELSIF (p_action = 'VALIDATE_DELETE') THEN
      NULL;
 END IF;
END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) as
  BEGIN
    l_rowid := x_rowid;
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsertUpdate2 (
	      p_inserting => TRUE,
          p_updating  => FALSE,
          p_deleting  => FALSE
         );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate2 (
  	      p_inserting => FALSE,
          p_updating  => TRUE,
          p_deleting  => FALSE
		  );
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      NULL;
    END IF;
  END After_DML;

procedure INSERT_ROW (
  X_ROWID         in out NOCOPY VARCHAR2,
  X_PE_PERSON_ID  in NUMBER,
  X_API_PERSON_ID in VARCHAR2,
  X_API_PERSON_ID_UF IN VARCHAR2,
  X_PERSON_ID_TYPE in VARCHAR2,
  X_START_DT       in DATE,
  X_END_DT         in DATE,
  x_attribute_category  IN VARCHAR2,
  x_attribute1          IN VARCHAR2,
  x_attribute2          IN VARCHAR2,
  x_attribute3          IN VARCHAR2,
  x_attribute4          IN VARCHAR2,
  x_attribute5          IN VARCHAR2,
  x_attribute6          IN VARCHAR2,
  x_attribute7          IN VARCHAR2,
  x_attribute8          IN VARCHAR2,
  x_attribute9          IN VARCHAR2,
  x_attribute10         IN VARCHAR2,
  x_attribute11         IN VARCHAR2,
  x_attribute12         IN VARCHAR2,
  x_attribute13         IN VARCHAR2,
  x_attribute14         IN VARCHAR2,
  x_attribute15         IN VARCHAR2,
  x_attribute16         IN VARCHAR2,
  x_attribute17         IN VARCHAR2,
  x_attribute18         IN VARCHAR2,
  x_attribute19         IN VARCHAR2,
  x_attribute20         IN VARCHAR2,
  x_region_cd           IN VARCHAR2,
  X_MODE                IN VARCHAR2
  ) as
    cursor C is select ROWID from IGS_PE_ALT_PERS_ID
      where PE_PERSON_ID = X_PE_PERSON_ID
      and API_PERSON_ID = X_API_PERSON_ID
      and PERSON_ID_TYPE = X_PERSON_ID_TYPE
      and start_dt       = x_start_dt;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
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
   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
  if (X_REQUEST_ID = -1) then
     X_REQUEST_ID := NULL;
     X_PROGRAM_ID := NULL;
     X_PROGRAM_APPLICATION_ID := NULL;
     X_PROGRAM_UPDATE_DATE := NULL;
 else
     X_PROGRAM_UPDATE_DATE := SYSDATE;
 end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
Before_DML(
 p_action=>'INSERT',
 x_rowid=>X_ROWID,
 x_api_person_id=>X_API_PERSON_ID,
 x_api_person_id_uf=>X_API_PERSON_ID_UF,
 x_end_dt=>X_END_DT,
 x_pe_person_id=>X_PE_PERSON_ID,
 x_person_id_type=>X_PERSON_ID_TYPE,
 x_start_dt=>X_START_DT,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN,
  x_attribute_category => X_ATTRIBUTE_CATEGORY,
  x_attribute1         => X_ATTRIBUTE1,
  x_attribute2         => X_ATTRIBUTE2,
  x_attribute3         => X_ATTRIBUTE3,
  x_attribute4         => X_ATTRIBUTE4,
  x_attribute5         => X_ATTRIBUTE5,
  x_attribute6         => X_ATTRIBUTE6,
  x_attribute7         => X_ATTRIBUTE7,
  x_attribute8         => X_ATTRIBUTE8,
  x_attribute9         => X_ATTRIBUTE9,
  x_attribute10        => X_ATTRIBUTE10,
  x_attribute11        => X_ATTRIBUTE11,
  x_attribute12        => X_ATTRIBUTE12,
  x_attribute13        => X_ATTRIBUTE13,
  x_attribute14        => X_ATTRIBUTE14,
  x_attribute15        => X_ATTRIBUTE15,
  x_attribute16        => X_ATTRIBUTE16,
  x_attribute17        => X_ATTRIBUTE17,
  x_attribute18        => X_ATTRIBUTE18,
  x_attribute19        => X_ATTRIBUTE19,
  x_attribute20        => X_ATTRIBUTE20,
  x_region_cd          => X_region_cd
   );
   IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_PE_ALT_PERS_ID (
    PE_PERSON_ID,
    API_PERSON_ID,
    API_PERSON_ID_UF,
    PERSON_ID_TYPE,
    START_DT,
    END_DT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE ,
   ATTRIBUTE_CATEGORY,
   ATTRIBUTE1  ,
   ATTRIBUTE2  ,
   ATTRIBUTE3  ,
   ATTRIBUTE4  ,
   ATTRIBUTE5  ,
   ATTRIBUTE6  ,
   ATTRIBUTE7  ,
   ATTRIBUTE8  ,
   ATTRIBUTE9  ,
   ATTRIBUTE10 ,
   ATTRIBUTE11 ,
   ATTRIBUTE12 ,
   ATTRIBUTE13 ,
   ATTRIBUTE14 ,
   ATTRIBUTE15 ,
   ATTRIBUTE16 ,
   ATTRIBUTE17 ,
   ATTRIBUTE18 ,
   ATTRIBUTE19 ,
   ATTRIBUTE20 ,
   REGION_CD
  ) values (
    NEW_REFERENCES.PE_PERSON_ID,
    NEW_REFERENCES.API_PERSON_ID,
    NEW_REFERENCES.API_PERSON_ID_UF,
    NEW_REFERENCES.PERSON_ID_TYPE,
    NEW_REFERENCES.START_DT,
    NEW_REFERENCES.END_DT,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE,
    NEW_REFERENCES.ATTRIBUTE_CATEGORY,
    NEW_REFERENCES.ATTRIBUTE1  ,
    NEW_REFERENCES.ATTRIBUTE2  ,
    NEW_REFERENCES.ATTRIBUTE3  ,
    NEW_REFERENCES.ATTRIBUTE4  ,
    NEW_REFERENCES.ATTRIBUTE5  ,
    NEW_REFERENCES.ATTRIBUTE6  ,
    NEW_REFERENCES.ATTRIBUTE7  ,
    NEW_REFERENCES.ATTRIBUTE8  ,
    NEW_REFERENCES.ATTRIBUTE9  ,
    NEW_REFERENCES.ATTRIBUTE10 ,
    NEW_REFERENCES.ATTRIBUTE11 ,
    NEW_REFERENCES.ATTRIBUTE12 ,
    NEW_REFERENCES.ATTRIBUTE13 ,
    NEW_REFERENCES.ATTRIBUTE14 ,
    NEW_REFERENCES.ATTRIBUTE15 ,
    NEW_REFERENCES.ATTRIBUTE16 ,
    NEW_REFERENCES.ATTRIBUTE17 ,
    NEW_REFERENCES.ATTRIBUTE18 ,
    NEW_REFERENCES.ATTRIBUTE19 ,
    NEW_REFERENCES.ATTRIBUTE20 ,
    NEW_REFERENCES.REGION_CD
  )RETURNING ROWID INTO X_ROWID;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;
 -- Adding the returning clause for bug 4188189
  -- Commenting out the following cursor fetch lines for bug 4188189
  --open c;
  --fetch c into X_ROWID;
  --if (c%notfound) then
  --  close c;
  --  raise no_data_found;
  --end if;
  --close c;
 After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );
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
  X_ROWID            in VARCHAR2,
  X_PE_PERSON_ID     in NUMBER,
  X_API_PERSON_ID    in VARCHAR2,
  X_API_PERSON_ID_UF IN VARCHAR2,
  X_PERSON_ID_TYPE   in VARCHAR2,
  X_START_DT         in DATE,
  X_END_DT           in DATE,
  x_attribute_category  IN VARCHAR2,
  x_attribute1          IN VARCHAR2,
  x_attribute2          IN VARCHAR2,
  x_attribute3          IN VARCHAR2,
  x_attribute4          IN VARCHAR2,
  x_attribute5          IN VARCHAR2,
  x_attribute6          IN VARCHAR2,
  x_attribute7          IN VARCHAR2,
  x_attribute8          IN VARCHAR2,
  x_attribute9          IN VARCHAR2,
  x_attribute10         IN VARCHAR2,
  x_attribute11         IN VARCHAR2,
  x_attribute12         IN VARCHAR2,
  x_attribute13         IN VARCHAR2,
  x_attribute14         IN VARCHAR2,
  x_attribute15         IN VARCHAR2,
  x_attribute16         IN VARCHAR2,
  x_attribute17         IN VARCHAR2,
  x_attribute18         IN VARCHAR2,
  x_attribute19         IN VARCHAR2,
  x_attribute20         IN VARCHAR2,
  x_region_cd           IN VARCHAR2

) as
  cursor c1 is select
      API_PERSON_ID_UF,
      START_DT,
      END_DT,
   ATTRIBUTE_CATEGORY,
   ATTRIBUTE1  ,
   ATTRIBUTE2  ,
   ATTRIBUTE3  ,
   ATTRIBUTE4  ,
   ATTRIBUTE5  ,
   ATTRIBUTE6  ,
   ATTRIBUTE7  ,
   ATTRIBUTE8  ,
   ATTRIBUTE9  ,
   ATTRIBUTE10 ,
   ATTRIBUTE11 ,
   ATTRIBUTE12 ,
   ATTRIBUTE13 ,
   ATTRIBUTE14 ,
   ATTRIBUTE15 ,
   ATTRIBUTE16 ,
   ATTRIBUTE17 ,
   ATTRIBUTE18 ,
   ATTRIBUTE19 ,
   ATTRIBUTE20 ,
   REGION_CD
    from IGS_PE_ALT_PERS_ID
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');

    close c1;
    App_Exception.Raise_Exception;
    return;
  end if;
  close c1;

      if ( ((trunc(tlinfo.START_DT) = trunc(X_START_DT))
           OR ((tlinfo.START_DT is null)
               AND (X_START_DT is null)))
      AND ((trunc(tlinfo.END_DT) = trunc(X_END_DT))
           OR ((tlinfo.END_DT is null)
               AND (X_END_DT is null)))
     AND (( tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY) OR (( tlinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
     AND (( tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1) OR (( tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
     AND (( tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2) OR (( tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
     AND (( tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3) OR (( tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
     AND (( tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4) OR (( tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
     AND (( tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5) OR (( tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
     AND (( tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6) OR (( tlinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
     AND (( tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7) OR (( tlinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
     AND (( tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8) OR (( tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
     AND (( tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9) OR (( tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
     AND (( tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10) OR (( tlinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
     AND (( tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11) OR (( tlinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
     AND (( tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12) OR (( tlinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
     AND (( tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13) OR (( tlinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
     AND (( tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14) OR (( tlinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
     AND (( tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15) OR (( tlinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
     AND (( tlinfo.ATTRIBUTE16 = X_ATTRIBUTE16) OR (( tlinfo.ATTRIBUTE16 is null) AND (X_ATTRIBUTE16 is null)))
     AND (( tlinfo.ATTRIBUTE17 = X_ATTRIBUTE17) OR (( tlinfo.ATTRIBUTE17 is null) AND (X_ATTRIBUTE17 is null)))
     AND (( tlinfo.ATTRIBUTE18 = X_ATTRIBUTE18) OR (( tlinfo.ATTRIBUTE18 is null) AND (X_ATTRIBUTE18 is null)))
     AND (( tlinfo.ATTRIBUTE19 = X_ATTRIBUTE19) OR (( tlinfo.ATTRIBUTE19 is null) AND (X_ATTRIBUTE19 is null)))
     AND (( tlinfo.ATTRIBUTE20 = X_ATTRIBUTE20) OR (( tlinfo.ATTRIBUTE20 is null) AND (X_ATTRIBUTE20 is null)))
     AND (( tlinfo.REGION_CD = X_REGION_CD) OR (( tlinfo.REGION_CD is null) AND (X_REGION_CD is null)))

  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PE_PERSON_ID in NUMBER,
  X_API_PERSON_ID in VARCHAR2,
  X_API_PERSON_ID_UF IN VARCHAR2,
  X_PERSON_ID_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_ATTRIBUTE_CATEGORY  in      VARCHAR2,
  X_ATTRIBUTE1          in      VARCHAR2,
  X_ATTRIBUTE2          in      VARCHAR2,
  X_ATTRIBUTE3          in      VARCHAR2,
  X_ATTRIBUTE4          in      VARCHAR2,
  X_ATTRIBUTE5          in      VARCHAR2,
  X_ATTRIBUTE6          in      VARCHAR2,
  X_ATTRIBUTE7          in      VARCHAR2,
  X_ATTRIBUTE8          in      VARCHAR2,
  X_ATTRIBUTE9          in      VARCHAR2,
  X_ATTRIBUTE10         in      VARCHAR2,
  X_ATTRIBUTE11         in      VARCHAR2,
  X_ATTRIBUTE12         in      VARCHAR2,
  X_ATTRIBUTE13         in      VARCHAR2,
  X_ATTRIBUTE14         in      VARCHAR2,
  X_ATTRIBUTE15         in      VARCHAR2,
  X_ATTRIBUTE16         in      VARCHAR2,
  X_ATTRIBUTE17         in      VARCHAR2,
  X_ATTRIBUTE18         in      VARCHAR2,
  X_ATTRIBUTE19         in      VARCHAR2,
  X_ATTRIBUTE20         in      VARCHAR2,
  x_region_cd           IN      VARCHAR2,
  X_MODE in VARCHAR2
  ) as
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
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
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
Before_DML(
 p_action=>'UPDATE',
 x_rowid=>X_ROWID,
 x_api_person_id=>X_API_PERSON_ID,
 x_api_person_id_uf=>X_API_PERSON_ID_UF,
 x_end_dt=>X_END_DT,
 x_pe_person_id=>X_PE_PERSON_ID,
 x_person_id_type=>X_PERSON_ID_TYPE,
 x_start_dt=>X_START_DT,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN,
   x_attribute_category => X_ATTRIBUTE_CATEGORY,
  x_attribute1         => X_ATTRIBUTE1,
  x_attribute2         => X_ATTRIBUTE2,
  x_attribute3         => X_ATTRIBUTE3,
  x_attribute4         => X_ATTRIBUTE4,
  x_attribute5         => X_ATTRIBUTE5,
  x_attribute6         => X_ATTRIBUTE6,
  x_attribute7         => X_ATTRIBUTE7,
  x_attribute8         => X_ATTRIBUTE8,
  x_attribute9         => X_ATTRIBUTE9,
  x_attribute10        => X_ATTRIBUTE10,
  x_attribute11        => X_ATTRIBUTE11,
  x_attribute12        => X_ATTRIBUTE12,
  x_attribute13        => X_ATTRIBUTE13,
  x_attribute14        => X_ATTRIBUTE14,
  x_attribute15        => X_ATTRIBUTE15,
  x_attribute16        => X_ATTRIBUTE16,
  x_attribute17        => X_ATTRIBUTE17,
  x_attribute18        => X_ATTRIBUTE18,
  x_attribute19        => X_ATTRIBUTE19,
  x_attribute20        => X_ATTRIBUTE20,
  x_region_cd          => X_REGION_CD

 );
   if (X_MODE IN ('R', 'S')) then
   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
  if (X_REQUEST_ID = -1) then
     X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
     X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;
     X_PROGRAM_APPLICATION_ID :=
                OLD_REFERENCES.PROGRAM_APPLICATION_ID;
     X_PROGRAM_UPDATE_DATE :=
                  OLD_REFERENCES.PROGRAM_UPDATE_DATE;
 else
     X_PROGRAM_UPDATE_DATE := SYSDATE;
 end if;
end if;
   IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 update IGS_PE_ALT_PERS_ID set
    API_PERSON_ID_UF = NEW_REFERENCES.API_PERSON_ID_UF,
    START_DT = NEW_REFERENCES.START_DT,
    END_DT = NEW_REFERENCES.END_DT,
    ATTRIBUTE_CATEGORY = NEW_REFERENCES.ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = NEW_REFERENCES.ATTRIBUTE1,
    ATTRIBUTE2 = NEW_REFERENCES.ATTRIBUTE2,
    ATTRIBUTE3 = NEW_REFERENCES.ATTRIBUTE3,
    ATTRIBUTE4 = NEW_REFERENCES.ATTRIBUTE4,
    ATTRIBUTE5 = NEW_REFERENCES.ATTRIBUTE5,
    ATTRIBUTE6 = NEW_REFERENCES.ATTRIBUTE6,
    ATTRIBUTE7 = NEW_REFERENCES.ATTRIBUTE7,
    ATTRIBUTE8 = NEW_REFERENCES.ATTRIBUTE8,
    ATTRIBUTE9 = NEW_REFERENCES.ATTRIBUTE9,
    ATTRIBUTE10 = NEW_REFERENCES.ATTRIBUTE10,
    ATTRIBUTE11 = NEW_REFERENCES.ATTRIBUTE11,
    ATTRIBUTE12 = NEW_REFERENCES.ATTRIBUTE12,
    ATTRIBUTE13 = NEW_REFERENCES.ATTRIBUTE13,
    ATTRIBUTE14 = NEW_REFERENCES.ATTRIBUTE14,
    ATTRIBUTE15 = NEW_REFERENCES.ATTRIBUTE15,
    ATTRIBUTE16 = NEW_REFERENCES.ATTRIBUTE16,
    ATTRIBUTE17 = NEW_REFERENCES.ATTRIBUTE17,
    ATTRIBUTE18 = NEW_REFERENCES.ATTRIBUTE18,
    ATTRIBUTE19 = NEW_REFERENCES.ATTRIBUTE19,
    ATTRIBUTE20 = NEW_REFERENCES.ATTRIBUTE20,
    REGION_CD   = NEW_REFERENCES.REGION_CD,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE

  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

 After_DML(
  p_action => 'UPDATE',
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
  X_ROWID         in out NOCOPY VARCHAR2,
  X_PE_PERSON_ID  in NUMBER,
  X_API_PERSON_ID in VARCHAR2,
  X_API_PERSON_ID_UF IN VARCHAR2,
  X_PERSON_ID_TYPE in VARCHAR2,
  X_START_DT       in DATE,
  X_END_DT         in DATE,
  x_attribute_category  IN VARCHAR2,
  x_attribute1          IN VARCHAR2,
  x_attribute2          IN VARCHAR2,
  x_attribute3          IN VARCHAR2,
  x_attribute4          IN VARCHAR2,
  x_attribute5          IN VARCHAR2,
  x_attribute6          IN VARCHAR2,
  x_attribute7          IN VARCHAR2,
  x_attribute8          IN VARCHAR2,
  x_attribute9          IN VARCHAR2,
  x_attribute10         IN VARCHAR2,
  x_attribute11         IN VARCHAR2,
  x_attribute12         IN VARCHAR2,
  x_attribute13         IN VARCHAR2,
  x_attribute14         IN VARCHAR2,
  x_attribute15         IN VARCHAR2,
  x_attribute16         IN VARCHAR2,
  x_attribute17         IN VARCHAR2,
  x_attribute18         IN VARCHAR2,
  x_attribute19         IN VARCHAR2,
  x_attribute20         IN VARCHAR2,
  x_region_cd           IN VARCHAR2,
  X_MODE in VARCHAR2
  ) as
  cursor c1 is select rowid from IGS_PE_ALT_PERS_ID
     where PE_PERSON_ID = X_PE_PERSON_ID
     and API_PERSON_ID = X_API_PERSON_ID
     and PERSON_ID_TYPE = X_PERSON_ID_TYPE
     and start_dt       = x_start_dt
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PE_PERSON_ID,
     X_API_PERSON_ID,
     X_API_PERSON_ID_UF,
     X_PERSON_ID_TYPE,
     X_START_DT,
     X_END_DT,
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
    X_REGION_CD,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PE_PERSON_ID,
   X_API_PERSON_ID,
   X_API_PERSON_ID_UF,
   X_PERSON_ID_TYPE,
   X_START_DT,
   X_END_DT,
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
    X_REGION_CD,
    X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) as
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
   IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 delete from IGS_PE_ALT_PERS_ID
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

 After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
end DELETE_ROW;
end IGS_PE_ALT_PERS_ID_PKG;

/
