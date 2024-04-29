--------------------------------------------------------
--  DDL for Package Body IGS_PE_PERS_ENCUMB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_PERS_ENCUMB_PKG" AS
 /* $Header: IGSNI18B.pls 120.0 2005/06/02 04:27:22 appldev noship $ */

------------------------------------------------------------------
-- Change History
--
-- Bug ID : 2000408
-- who      when          what
-- CDCRUZ   Sep 24,2002   New Col's added for
--                        Person DLD / cal_type , sequence_number added

------------------------------------------------------------------

 -- Bug 1956374 msrinivi Repointed genp_val_prsn_id
  l_rowid VARCHAR2(25);
  old_references IGS_PE_PERS_ENCUMB%RowType;
  new_references IGS_PE_PERS_ENCUMB%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_comments IN VARCHAR2,
    x_person_id IN NUMBER,
    x_encumbrance_type IN VARCHAR2,
    x_start_dt IN DATE,
    x_expiry_dt IN DATE,
    x_authorising_person_id IN NUMBER,
    x_spo_course_cd IN VARCHAR2,
    x_spo_sequence_number IN NUMBER,
    x_cal_type           IN   VARCHAR2,
    x_sequence_number    IN   NUMBER,
    x_auth_resp_id  IN NUMBER,
    x_external_reference IN VARCHAR2,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_pers_encumb
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
    new_references.comments := x_comments;
    new_references.person_id := x_person_id;
    new_references.encumbrance_type  := x_encumbrance_type;
    new_references.start_dt := x_start_dt;
    new_references.expiry_dt := x_expiry_dt;
    new_references.authorising_person_id := x_authorising_person_id;
    new_references.spo_course_cd := x_spo_course_cd;
    new_references.spo_sequence_number := x_spo_sequence_number;
    new_references.cal_type          := x_cal_type ;
    new_references.sequence_number   := x_sequence_number    ;
    new_references.auth_resp_id   := x_auth_resp_id    ;
    new_references.external_reference           := x_external_reference;

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
    ) AS
/*------------------------------------------------------------------
 Change History

 Bug ID : 2000408
 who      when          what
 PKPATEL  8-APR-2003    Bug No: 2804863, Added the check with igs_pe_gen_001.g_hold_validation for calling
                        igs_pe_gen_001.get_hold_auth
                                                Added system_type_rec.s_encumbrance_cat = 'ACADEMIC' check to validate staff and person ID.
vkarthik		16-Jul-2004  Added validation on hold start date and hold expiry date as part of Bug 3771317
------------------------------------------------------------------*/
        CURSOR cur_hold_ovr IS
        SELECT hold_old_end_dt
        FROM igs_pe_hold_rel_ovr hovr, igs_en_elgb_ovr_all ovr
        WHERE ovr.elgb_override_id =hovr.elgb_override_id  AND
        ovr.person_id = new_references.person_id AND new_references.start_dt = hovr.start_date
        AND new_references.encumbrance_type = hovr.hold_type;

        CURSOR system_type_cur(cp_encumbrance_type igs_fi_encmb_type.encumbrance_type%TYPE) IS
        SELECT s_encumbrance_cat
        FROM   igs_fi_encmb_type
        WHERE  encumbrance_type = cp_encumbrance_type;

        system_type_rec system_type_cur%ROWTYPE;

        l_person_id    hz_parties.party_id%TYPE;
        l_person_number hz_parties.party_number%TYPE;
        l_person_name   hz_person_profiles.person_name%TYPE;
        l_fnd_user_id  fnd_user.user_id%TYPE;

        l_hold_old_end_date DATE;
        v_message_name  VARCHAR2(30);
  BEGIN
        -- Validate ENCUMBRANCE TYPE.
        -- Closed indicator.

	l_fnd_user_id := FND_GLOBAL.USER_ID;
        IF new_references.encumbrance_type  IS NOT NULL AND
                (NVL(old_references.encumbrance_type , 'NULL') <> new_references.encumbrance_type ) THEN

                IF igs_en_val_etde.enrp_val_et_closed (
                                new_references.encumbrance_type ,
                                v_message_name) = FALSE THEN

                         Fnd_Message.Set_Name('IGS', v_message_name);
                         IGS_GE_MSG_STACK.ADD;
                         APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;
        END IF;
	-- expiry dt, start dt validation added as part of Bug 3771317
	IF new_references.start_dt IS NOT NULL AND
	   new_references.expiry_dt IS NOT NULL AND
	   new_references.expiry_dt < new_references.start_dt THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_EXPDT_GE_STDT');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
        IF p_inserting THEN

                IF igs_en_val_pen.enrp_val_prsn_encmb (
                                new_references.person_id,
                                new_references.encumbrance_type ,
                                new_references.start_dt,
                                new_references.expiry_dt,
                                v_message_name) = FALSE THEN

                 FND_MESSAGE.SET_NAME('IGS', v_message_name);
                 IGS_GE_MSG_STACK.ADD;
                 APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;

                OPEN system_type_cur(new_references.encumbrance_type);
                FETCH system_type_cur INTO system_type_rec;
                CLOSE system_type_cur;


           --KUMMA, 2758856, Added the condititon to check for the external_reference also.
           IF system_type_rec.s_encumbrance_cat = 'ADMIN' AND new_references.external_reference IS NULL THEN

                  IF igs_pe_gen_001.g_hold_validation = 'Y' THEN

                         igs_pe_gen_001.get_hold_auth(l_fnd_user_id,
                                                  l_person_id,
                                                  l_person_number,
                                                  l_person_name,
                                                      v_message_name);

              IF v_message_name IS NOT NULL THEN

                      FND_MESSAGE.SET_NAME('IGS',v_message_name);
                      IGS_GE_MSG_STACK.ADD;
                      APP_EXCEPTION.RAISE_EXCEPTION;
              ELSE

                 new_references.authorising_person_id := l_person_id;
                 new_references.auth_resp_id := FND_GLOBAL.RESP_ID;
              END IF;
              END IF;
           END IF;

        END IF;

        -- Validate that start date is not less than the current date.
        IF (new_references.start_dt IS NOT NULL) AND
                (p_inserting OR (p_updating AND
                (NVL(old_references.start_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))
                <> new_references.start_dt)))
                THEN

                IF IGS_EN_VAL_PCE.enrp_val_encmb_dt (
                                new_references.start_dt,
                                v_message_name) = FALSE THEN

                          Fnd_Message.Set_Name('IGS', v_message_name);
                          IGS_GE_MSG_STACK.ADD;
                          App_Exception.Raise_Exception;
                END IF;

        END IF;
        -- Validate that if expiry date is specified, then expiry date  is not
        -- less than the start date or less than the current date.

    OPEN cur_hold_ovr;
    FETCH cur_hold_ovr INTO l_hold_old_end_date;

    IF  cur_hold_ovr%NOTFOUND THEN
      l_hold_old_end_date := new_references.expiry_dt+1;
    END IF;
    CLOSE cur_hold_ovr;
    IF new_references.expiry_dt <>  l_hold_old_end_date THEN
        IF (new_references.expiry_dt IS NOT NULL) AND
                (p_inserting OR (p_updating AND
                (NVL(old_references.expiry_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))
                <> new_references.expiry_dt)))
                THEN
                IF IGS_EN_VAL_PCE.enrp_val_strt_exp_dt (
                                new_references.start_dt,
                                new_references.expiry_dt,
                                v_message_name) = FALSE THEN
                          Fnd_Message.Set_Name('IGS', v_message_name);
                          IGS_GE_MSG_STACK.ADD;
                          App_Exception.Raise_Exception;
                END IF;
                IF IGS_EN_VAL_PCE.enrp_val_encmb_dt (
                                new_references.expiry_dt,
                                v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS', v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
        END IF;
    END IF;

        -- Validate Encumbrance Authorising IGS_PE_PERSON Id.
        -- Validate that the authorising person_id is valid and is a staff member.
        -- Validation is done only for ACADEMIC holds. ADMIN hold this validation is done in the igs_pe_gen_001.get_hold_auth procedure.
        IF system_type_rec.s_encumbrance_cat = 'ACADEMIC' AND
           (new_references.authorising_person_id IS NOT NULL) AND
           (p_inserting OR
            ( p_updating AND (new_references.authorising_person_id <> NVL(old_references.authorising_person_id,-1))))
            THEN

                IF IGS_CO_VAL_OC.genp_val_prsn_id (
                        new_references.authorising_person_id,
                        v_message_name) = FALSE THEN
                          FND_MESSAGE.SET_NAME('IGS', v_message_name);
                          IGS_GE_MSG_STACK.ADD;
                          APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;

                IF igs_ad_val_acai.genp_val_staff_prsn (
                        new_references.authorising_person_id,
                        v_message_name) = FALSE THEN
                         FND_MESSAGE.SET_NAME('IGS', v_message_name);
                         IGS_GE_MSG_STACK.ADD;
                         APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;
        END IF;


  END BeforeRowInsertUpdate1;

  -- Trigger description :-
  -- "OSS_TST".trg_pen_ar_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_PE_PERS_ENCUMB
  -- FOR EACH ROW

  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
        v_message_name  varchar2(30);
        v_rowid_saved   BOOLEAN := FALSE;
        l_message_name varchar2(2000);
        l_app number ;
ln_msg_index number;
  BEGIN
        -- Validate for open ended IGS_PE_PERSON encumbrance records.
        IF new_references.expiry_dt IS NULL THEN

                 -- Save the rowid of the current row.
                v_rowid_saved := TRUE;
                -- Cannot call enrp_val_pen_open because trigger will be mutating.
        END IF;
        IF p_inserting THEN
                -- Cannot call IGS_EN_GEN_009.ENRP_INS_DFLT_EFFECT because trigger will be mutating.
                 -- Save the rowid of the current row.
                IF v_rowid_saved = FALSE THEN

                        v_rowid_saved := TRUE;
                END IF;
        END IF;
        IF p_updating AND
                 (NVL(old_references.expiry_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
                  NVL(new_references.expiry_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))) THEN
                        -- Cannot call enrp_set_expiry_dts because trigger will be mutating.
                         -- Save the rowid of the current row.
                        IF v_rowid_saved = FALSE THEN

                                v_rowid_saved := TRUE;
                        END IF;
        END IF;
            IF v_rowid_saved = TRUE THEN
                --Validate the records
                    -- Validate for open ended IGS_PE_PERS_ENCUMB records.
                IF new_references.expiry_dt IS NULL THEN
                        IF IGS_EN_VAL_PEN.enrp_val_pen_open (
                                        new_references.person_id,
                                        new_references.encumbrance_type,
                                        new_references.start_dt,
                                        v_message_name) = FALSE THEN

                                 Fnd_Message.Set_Name('IGS', v_message_name);
                                 IGS_GE_MSG_STACK.ADD;
                                 App_Exception.Raise_Exception;
                        END IF;
                END IF;
                -- Insert the default effects for the encumbrance type.
                -- Removed as the message needs to be a warning not an error.  ie processing
                -- needs to proceed.

                -- Validate that insert will not cause invalid effect combinations.
                IF p_inserting THEN
                        IF IGS_EN_VAL_PEN.enrp_val_prsn_encmb (new_references.person_id,
                                                new_references.encumbrance_type,
                                                new_references.start_dt,
                                                new_references.expiry_dt,
                                                v_message_name) = FALSE THEN
                                 Fnd_Message.Set_Name('IGS', v_message_name);
                                 IGS_GE_MSG_STACK.ADD;
                                 App_Exception.Raise_Exception;
                        END IF;
                END IF;
                -- Set the expiry date of all child records if the expiry date has been
                -- updated.
                IF p_updating AND
                   (new_references.expiry_dt IS NOT NULL) THEN

                    initialised := 'E';

                        IGS_EN_GEN_012.ENRP_UPD_EXPIRY_DTS (new_references.person_id,
                                             new_references.encumbrance_type,
                                             new_references.start_dt,
                                             new_references.expiry_dt,
                                             v_message_name);

                        initialised := NULL;

                        IF v_message_name <> 0 THEN
                                 FND_MESSAGE.SET_NAME('IGS', v_message_name);
                                 IGS_GE_MSG_STACK.ADD;
                                 APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
          END IF;

  END AfterRowInsertUpdate2;

  -- Trigger description :-
  -- "OSS_TST".trg_pen_as_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_PE_PERS_ENCUMB



   PROCEDURE Check_Constraints (
 Column_Name    IN      VARCHAR2,
 Column_Value   IN      VARCHAR2
 )
 AS
 BEGIN
    IF  column_name is null then
      NULL;
    ELSIF upper(Column_name) = 'ENCUMBRANCE_TYPE' then
      new_references.encumbrance_type:= column_value;
    END IF;
IF upper(column_name) = 'ENCUMBRANCE_TYPE' OR
     column_name is null THEN
     IF new_references.encumbrance_type <>
        UPPER(new_references.encumbrance_type) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
 END IF;

 END Check_Constraints;

 PROCEDURE Check_Parent_Existance AS
-- pkpatel,Bug 4163187 (Modified the cursors to remove the hard cording of application id to 8405/8406)
     CURSOR check_resp_id_cur (cp_appl_id fnd_responsibility.application_id%TYPE,
                               cp_resp_id fnd_responsibility.responsibility_id%TYPE) IS
          SELECT 'X'
          FROM   fnd_responsibility
          WHERE  application_id = cp_appl_id AND
	             responsibility_id = cp_resp_id;

     CURSOR check_applresp_id_cur (cp_resp_id fnd_responsibility.responsibility_id%TYPE) IS
          SELECT 'X'
          FROM   fnd_responsibility resp, fnd_application appl
          WHERE  resp.application_id = appl.application_id AND
	             responsibility_id = cp_resp_id;

     --kumma, 2758856, added the following cursor
     CURSOR check_ext_reference (p_lookup_type fnd_lookup_values_vl.lookup_type%TYPE,
			         p_lookup_code fnd_lookup_values_vl.lookup_code%TYPE,
				 p_view_application_id fnd_lookup_values_vl.view_application_id%TYPE,
			         p_security_group_id fnd_lookup_values_vl.security_group_id%TYPE) IS
          SELECT 'X'
          FROM fnd_lookup_values_vl
          WHERE lookup_code = p_lookup_code AND
	       lookup_type = p_lookup_type AND
	       view_application_id = p_view_application_id AND
	       security_group_id = p_security_group_id  AND
	       NVL(enabled_flag,'Y') = 'Y';

     l_var  VARCHAR2(1);
	 l_appl_id fnd_responsibility.application_id%TYPE;
 BEGIN

     IF (((old_references.auth_resp_id  = new_references.auth_resp_id )) OR
          ((new_references.AUTH_RESP_ID  IS NULL))) THEN
          NULL;
     ELSE
	      l_appl_id := FND_GLOBAL.RESP_APPL_ID;

		  IF l_appl_id <> -1 THEN
			  OPEN check_resp_id_cur(l_appl_id,new_references.auth_resp_id);
			  FETCH check_resp_id_cur INTO l_var;
			  IF check_resp_id_cur%NOTFOUND THEN
				   CLOSE check_resp_id_cur;
				   FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
				   IGS_GE_MSG_STACK.ADD;
				   APP_EXCEPTION.RAISE_EXCEPTION;
			  END IF;
			  CLOSE check_resp_id_cur;
          ELSE
			  OPEN check_applresp_id_cur(new_references.auth_resp_id);
			  FETCH check_applresp_id_cur INTO l_var;
			  IF check_applresp_id_cur%NOTFOUND THEN
				   CLOSE check_applresp_id_cur;
				   FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
				   IGS_GE_MSG_STACK.ADD;
				   APP_EXCEPTION.RAISE_EXCEPTION;
			  END IF;
			  CLOSE check_applresp_id_cur;
		  END IF;
     END IF;

     --kumma, 2758856, added the following cursor
     IF (((old_references.external_reference  = new_references.external_reference)) OR
          ((new_references.external_reference  IS NULL))) THEN
             NULL;
     ELSE
          OPEN check_ext_reference('PE_EXT_REF',new_references.external_reference,8405,0);
          FETCH check_ext_reference INTO l_var;
          IF check_ext_reference%NOTFOUND THEN
               CLOSE check_ext_reference;
               FND_MESSAGE.SET_NAME ('IGS', 'IGS_PE_INVLD_EXT_REF_VAL');
               IGS_GE_MSG_STACK.ADD;
               APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;
          CLOSE check_ext_reference;
     END IF;


     IF (((old_references.encumbrance_type  = new_references.encumbrance_type )) OR
          ((new_references.encumbrance_type  IS NULL))) THEN
          NULL;
     ELSE
          IF  NOT IGS_FI_ENCMB_TYPE_PKG.Get_PK_For_Validation (
               new_references.encumbrance_type  ) THEN
               Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
               IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
          END IF;
     END IF;


     IF (((old_references.authorising_person_id = new_references.authorising_person_id)) OR
          ((new_references.authorising_person_id IS NULL))) THEN
          NULL;
     ELSE
          IF  NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
               new_references.authorising_person_id ) THEN
               Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
               IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
          END IF;
     END IF;

     IF (((old_references.person_id = new_references.person_id)) OR
          ((new_references.person_id IS NULL))) THEN
          NULL;
     ELSE
          IF  NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
               new_references.person_id ) THEN
               Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
               IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
          END IF;
     END IF;

     IF (((old_references.cal_type = new_references.cal_type) AND
          (old_references.sequence_number = new_references.sequence_number)) OR
          ((new_references.cal_type IS NULL) OR
          (new_references.sequence_number IS NULL))) THEN
          NULL;
     ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.cal_type,
                new_references.sequence_number
               ) THEN

               fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
               igs_ge_msg_stack.add;
               app_exception.raise_exception;
     END IF;

     IF ((
          old_references.person_id = new_references.person_id
          AND old_references.spo_course_cd = new_references.spo_course_cd
          AND old_references.spo_sequence_number = new_references.spo_sequence_number   )
          OR ((new_references.cal_type IS NULL) OR (new_references.spo_course_cd IS NULL) OR  (new_references.spo_sequence_number IS NULL))
          )
     THEN
          NULL;
     ELSIF NOT IGS_PR_STDNT_PR_OU_PKG.get_pk_for_validation (
          new_references.person_id ,
          new_references.spo_course_cd,
          new_references.spo_sequence_number
          ) THEN

               fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
               igs_ge_msg_stack.add;
               app_exception.raise_exception;
     END IF;
 END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_PE_PERSENC_EFFCT_PKG.GET_FK_IGS_PE_PERS_ENCUMB (
      old_references.person_id,
      old_references.encumbrance_type ,
      old_references.start_dt
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_encumbrance_type IN VARCHAR2,
    x_start_dt IN DATE
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_PERS_ENCUMB
      WHERE    person_id = x_person_id
      AND      encumbrance_type  = x_encumbrance_type
      AND      start_dt = x_start_dt
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
     IF (cur_rowid%FOUND) THEN
       CLOSE cur_rowid;
       RETURN (TRUE);
         ELSE
       CLOSE cur_rowid;
       RETURN (FALSE);
     END IF;

  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_PERS_ENCUMB
      WHERE   (
                  CAL_TYPE = X_CAL_TYPE AND SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER
          );

    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PEN_CI_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_CA_INST;

  PROCEDURE GET_FK_IGS_FI_ENCMB_TYPE (
    x_encumbrance_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_PERS_ENCUMB
      WHERE    encumbrance_type  = x_encumbrance_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PEN_ET_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_FI_ENCMB_TYPE;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_PERS_ENCUMB
      WHERE    authorising_person_id = x_person_id  OR
               person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_PE_PEN_PE_AUTHORISED_BY_FK');
        IGS_GE_MSG_STACK.ADD;
        CLOSE cur_rowid;
        App_Exception.Raise_Exception;
        RETURN;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2,
    x_comments IN VARCHAR2,
    x_person_id IN NUMBER,
    x_encumbrance_type IN VARCHAR2,
    x_start_dt IN DATE,
    x_expiry_dt IN DATE,
    x_authorising_person_id IN NUMBER,
    x_spo_course_cd IN VARCHAR2,
    x_spo_sequence_number IN NUMBER,
    X_CAL_TYPE           IN   VARCHAR2,
    X_SEQUENCE_NUMBER    IN   NUMBER,
    x_auth_resp_id  IN NUMBER,
    X_EXTERNAL_REFERENCE IN VARCHAR2 ,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER
  ) AS
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_comments,
      x_person_id,
      x_encumbrance_type,
      x_start_dt,
      x_expiry_dt,
      x_authorising_person_id,
      x_spo_course_cd,
      x_spo_sequence_number,
      x_cal_type,
      x_sequence_number,
      x_auth_resp_id,
      x_external_reference,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

     IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.

     BeforeRowInsertUpdate1 (
          p_inserting => TRUE,
      p_updating  => FALSE,
          p_deleting  => FALSE);

          IF  Get_PK_For_Validation (
          new_references.person_id,
          new_references.encumbrance_type ,
          new_references.start_dt) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

      Check_Constraints; -- if procedure present

      Check_Parent_Existance; -- if procedure present

 ELSIF (p_action = 'UPDATE') THEN

       -- Call all the procedures related to Before Update.
       BeforeRowInsertUpdate1 (
          p_inserting => FALSE,
          p_updating  => TRUE,
              p_deleting  => FALSE );

       Check_Constraints; -- if procedure present

       Check_Parent_Existance; -- if procedure present

 ELSIF (p_action = 'DELETE') THEN
       -- Call all the procedures related to Before Delete.

       Check_Child_Existance; -- if procedure present
 ELSIF (p_action = 'VALIDATE_INSERT') THEN

      IF  Get_PK_For_Validation (
          new_references.person_id,
          new_references.encumbrance_type ,
          new_references.start_dt) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

      Check_Constraints; -- if procedure present
 ELSIF (p_action = 'VALIDATE_UPDATE') THEN
       Check_Constraints; -- if procedure present

ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance; -- if procedure present
 END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.

      AfterRowInsertUpdate2 (
          p_inserting => TRUE,
          p_updating  => FALSE,
              p_deleting  => FALSE);


    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate2 (
          p_inserting => FALSE,
          p_updating  => TRUE,
              p_deleting  => FALSE );

    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_AUTHORISING_PERSON_ID in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_SPO_COURSE_CD in VARCHAR2,
  X_SPO_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE           IN   VARCHAR2,
  X_SEQUENCE_NUMBER    IN   NUMBER,
  x_auth_resp_id IN NUMBER,
  x_external_reference IN VARCHAR2 ,
  X_MODE IN VARCHAR2
  ) AS
    CURSOR C (cp_start_dt igs_pe_pers_encumb.start_dt%TYPE) IS
      SELECT ROWID FROM igs_pe_pers_encumb
      WHERE person_id = x_person_id
      AND encumbrance_type = x_encumbrance_type
      AND start_dt = cp_start_dt;

        CURSOR system_type_cur(cp_encumbrance_type igs_fi_encmb_type.encumbrance_type%TYPE) IS
        SELECT s_encumbrance_cat
        FROM   igs_fi_encmb_type
        WHERE  encumbrance_type = cp_encumbrance_type;
    system_type_rec system_type_cur%ROWTYPE;

    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
BEGIN
  x_last_update_date := SYSDATE;
  IF(x_mode = 'I') THEN
    x_last_updated_by := 1;
    x_last_update_login := 0;
  ELSIF (x_mode = 'R') THEN
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    IF x_last_updated_by IS NULL THEN
      X_LAST_UPDATED_BY := -1;
    END IF;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
OPEN system_type_cur(x_encumbrance_type);
FETCH system_type_cur INTO system_type_rec;
CLOSE system_type_cur;
IF system_type_rec.s_encumbrance_cat = 'ADMIN' THEN
/* asbala: 3446073 - ACAD type holds will have the time component in the start and end dates,
                     ADMIN type holds will not. */
  Before_DML(
  p_action=>'INSERT',
  x_rowid=>X_ROWID,
  x_authorising_person_id=>X_AUTHORISING_PERSON_ID,
  x_comments=>X_COMMENTS,
  x_encumbrance_type=>X_ENCUMBRANCE_TYPE,
  x_expiry_dt=>TRUNC(X_EXPIRY_DT),
  x_person_id=>X_PERSON_ID,
  x_start_dt=>TRUNC(X_START_DT),
  x_spo_course_cd=>X_SPO_COURSE_CD,
  x_spo_sequence_number=>X_SPO_SEQUENCE_NUMBER,
  X_CAL_TYPE           => X_CAL_TYPE ,
  X_SEQUENCE_NUMBER    => X_SEQUENCE_NUMBER    ,
  x_auth_resp_id    => x_auth_resp_id    ,
  x_external_reference =>  x_external_reference,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
ELSE
  Before_DML(
  p_action=>'INSERT',
  x_rowid=>X_ROWID,
  x_authorising_person_id=>X_AUTHORISING_PERSON_ID,
  x_comments=>X_COMMENTS,
  x_encumbrance_type=>X_ENCUMBRANCE_TYPE,
  x_expiry_dt=>X_EXPIRY_DT,
  x_person_id=>X_PERSON_ID,
  x_start_dt=>X_START_DT,
  x_spo_course_cd=>X_SPO_COURSE_CD,
  x_spo_sequence_number=>X_SPO_SEQUENCE_NUMBER,
  X_CAL_TYPE           => X_CAL_TYPE ,
  X_SEQUENCE_NUMBER    => X_SEQUENCE_NUMBER    ,
  x_auth_resp_id    => x_auth_resp_id    ,
  x_external_reference =>  x_external_reference,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
 END IF;
  INSERT INTO igs_pe_pers_encumb (
    person_id,
    encumbrance_type,
    start_dt,
    expiry_dt,
    authorising_person_id,
    comments,
    spo_course_cd,
    spo_sequence_number,
    cal_type     ,
    sequence_number  ,
    auth_resp_id,
    external_reference,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
  ) VALUES (
     new_references.person_id,
     new_references.encumbrance_type,
     new_references.start_dt,
     new_references.expiry_dt,
     new_references.authorising_person_id,
     new_references.comments,
     new_references.spo_course_cd,
     new_references.spo_sequence_number,
     new_references.cal_type,
     new_references.sequence_number ,
     new_references.auth_resp_id ,
     new_references.external_reference,
    x_last_update_date,
    x_last_updated_by,
    x_last_update_date,
    x_last_updated_by,
    x_last_update_login
  );

  OPEN c(new_references.start_dt);
  FETCH c INTO x_rowid;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE no_data_found;
  END IF;
  CLOSE c;

 After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );
END insert_row;

PROCEDURE LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_AUTHORISING_PERSON_ID in NUMBER,
  x_spo_course_cd in VARCHAR2,
  x_spo_sequence_number in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_CAL_TYPE           IN   VARCHAR2,
  X_SEQUENCE_NUMBER    IN   NUMBER,
  x_auth_resp_id IN NUMBER,
  X_EXTERNAL_REFERENCE IN VARCHAR2
) AS

  CURSOR c1 IS SELECT
      expiry_dt,
      authorising_person_id,
      comments
    FROM igs_pe_pers_encumb
    WHERE ROWID = X_ROWID
    FOR UPDATE NOWAIT;
  tlinfo c1%ROWTYPE;

BEGIN
  OPEN c1;
  FETCH c1 INTO tlinfo;
  IF (c1%NOTFOUND) THEN
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    CLOSE c1;
    App_Exception.Raise_Exception;
    RETURN;
  END IF;
  CLOSE c1;

      IF ( ((tlinfo.EXPIRY_DT = X_EXPIRY_DT)
           OR ((tlinfo.EXPIRY_DT IS NULL)
               AND (X_EXPIRY_DT IS NULL)))
      AND ((tlinfo.AUTHORISING_PERSON_ID = X_AUTHORISING_PERSON_ID)
          OR ((tlinfo.AUTHORISING_PERSON_ID IS NULL)
               AND (X_AUTHORISING_PERSON_ID IS NULL)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS IS NULL)
               AND (X_COMMENTS IS NULL)))
  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;
  RETURN;
END lock_row;

PROCEDURE UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_AUTHORISING_PERSON_ID in NUMBER,
  X_COMMENTS in VARCHAR2,
  x_spo_course_cd in VARCHAR2,
  x_spo_sequence_number in NUMBER,
  X_CAL_TYPE           IN   VARCHAR2,
  X_SEQUENCE_NUMBER    IN   NUMBER,
  x_auth_resp_id IN NUMBER,
  X_EXTERNAL_REFERENCE IN VARCHAR2 ,
  X_MODE in VARCHAR2
  ) AS
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    CURSOR system_type_cur(cp_encumbrance_type igs_fi_encmb_type.encumbrance_type%TYPE) IS
    SELECT s_encumbrance_cat
    FROM   igs_fi_encmb_type
    WHERE  encumbrance_type = cp_encumbrance_type;
    system_type_rec system_type_cur%ROWTYPE;

BEGIN
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE = 'R') then
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
OPEN system_type_cur(x_encumbrance_type);
FETCH system_type_cur INTO system_type_rec;
CLOSE system_type_cur;
IF system_type_rec.s_encumbrance_cat = 'ADMIN' THEN
/* asbala: 3446073 - ACAD type holds will have the time component in the start and end dates,
                     ADMIN type holds will not. */
  Before_DML(
  p_action=>'UPDATE',
  x_rowid=>X_ROWID,
  x_authorising_person_id=>X_AUTHORISING_PERSON_ID,
  x_comments=>X_COMMENTS,
  x_encumbrance_type=>X_ENCUMBRANCE_TYPE,
  x_expiry_dt=>TRUNC(X_EXPIRY_DT),
  x_person_id=>X_PERSON_ID,
  x_start_dt=>TRUNC(X_START_DT),
  x_spo_course_cd => x_spo_course_cd,
  x_spo_sequence_number => x_spo_sequence_number,
  X_CAL_TYPE           => X_CAL_TYPE ,
  X_SEQUENCE_NUMBER    => X_SEQUENCE_NUMBER    ,
  x_auth_resp_id    => x_auth_resp_id    ,
  X_EXTERNAL_REFERENCE => X_EXTERNAL_REFERENCE,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
ELSE
  Before_DML(
  p_action=>'UPDATE',
  x_rowid=>X_ROWID,
  x_authorising_person_id=>X_AUTHORISING_PERSON_ID,
  x_comments=>X_COMMENTS,
  x_encumbrance_type=>X_ENCUMBRANCE_TYPE,
  x_expiry_dt=>X_EXPIRY_DT,
  x_person_id=>X_PERSON_ID,
  x_start_dt=>X_START_DT,
  x_spo_course_cd => x_spo_course_cd,
  x_spo_sequence_number => x_spo_sequence_number,
  X_CAL_TYPE           => X_CAL_TYPE ,
  X_SEQUENCE_NUMBER    => X_SEQUENCE_NUMBER    ,
  x_auth_resp_id    => x_auth_resp_id    ,
  X_EXTERNAL_REFERENCE => X_EXTERNAL_REFERENCE,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
END IF;
  UPDATE IGS_PE_PERS_ENCUMB SET
    expiry_dt =  new_references.expiry_dt,
    authorising_person_id =  new_references.authorising_person_id,
    comments =  new_references.comments,
    cal_type               = new_references.cal_type ,
    sequence_number        = new_references.sequence_number    ,
    auth_resp_id        = new_references.auth_resp_id    ,
    external_reference  = new_references.external_reference,
    last_update_date = x_last_update_date,
    last_updated_by = x_last_updated_by,
    last_update_login = x_last_update_login
  WHERE ROWID = x_rowid;
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
 After_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID
  );
END UPDATE_ROW;

PROCEDURE ADD_ROW (
  x_rowid IN OUT NOCOPY VARCHAR2,
  x_person_id IN NUMBER,
  x_encumbrance_type IN VARCHAR2,
  x_start_dt IN DATE,
  x_expiry_dt IN DATE,
  x_authorising_person_id IN NUMBER,
  x_comments IN VARCHAR2,
  x_spo_course_cd IN VARCHAR2,
  x_spo_sequence_number IN NUMBER,
  x_cal_type           IN   VARCHAR2,
  x_sequence_number    IN   NUMBER,
  x_auth_resp_id IN NUMBER,
  x_external_reference IN VARCHAR2 ,
  x_mode IN VARCHAR2
  ) AS
   CURSOR c1(cp_start_dt igs_pe_pers_encumb.start_dt%TYPE) IS
   SELECT ROWID FROM igs_pe_pers_encumb
   WHERE person_id = x_person_id
   AND encumbrance_type = x_encumbrance_type
   AND start_dt = cp_start_dt  ;

   CURSOR system_type_cur(cp_encumbrance_type igs_fi_encmb_type.encumbrance_type%TYPE) IS
   SELECT s_encumbrance_cat
   FROM   igs_fi_encmb_type
   WHERE  encumbrance_type = cp_encumbrance_type;
   system_type_rec system_type_cur%ROWTYPE;
   l_start_dt igs_pe_pers_encumb.start_dt%TYPE;
BEGIN

OPEN system_type_cur(x_encumbrance_type);
FETCH system_type_cur INTO system_type_rec;
CLOSE system_type_cur;
IF system_type_rec.s_encumbrance_cat = 'ADMIN' THEN
/* asbala: 3446073 - ACAD type holds will have the time component in the start and end dates,
                     ADMIN type holds will not. */
  l_start_dt := TRUNC(x_start_dt);
ELSE
  l_start_dt := x_start_dt;
END IF;
  OPEN c1(l_start_dt);
  FETCH c1 INTO x_rowid;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_ENCUMBRANCE_TYPE,
     X_START_DT,
     X_EXPIRY_DT,
     X_AUTHORISING_PERSON_ID,
     X_COMMENTS,
     x_spo_course_cd,
     x_spo_sequence_number,
     X_CAL_TYPE     ,
     X_SEQUENCE_NUMBER   ,
     x_auth_resp_id,
     x_external_reference,
     X_MODE);
    RETURN;
  END IF;
  CLOSE c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_ENCUMBRANCE_TYPE,
   X_START_DT,
   X_EXPIRY_DT,
   X_AUTHORISING_PERSON_ID,
   X_COMMENTS,
   x_spo_course_cd,
   x_spo_sequence_number,
   X_CAL_TYPE     ,
   X_SEQUENCE_NUMBER   ,
   x_auth_resp_id,
   x_external_reference,
   X_MODE);
END ADD_ROW;

procedure DELETE_ROW (
  X_ROWID IN VARCHAR2
) AS
BEGIN
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  DELETE FROM IGS_PE_PERS_ENCUMB
  WHERE ROWID = X_ROWID;
  IF (SQL%NOTFOUND) THEN
    RAISE no_data_found;
  END IF;
 After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
END DELETE_ROW;
END IGS_PE_PERS_ENCUMB_PKG;

/
