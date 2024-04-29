--------------------------------------------------------
--  DDL for Package Body IGS_AD_APPL_EVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_APPL_EVAL_PKG" AS
/* $Header: IGSAIA4B.pls 120.4 2006/07/31 13:28:15 rbezawad ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ad_appl_eval%RowType;
  new_references igs_ad_appl_eval%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_appl_eval_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_evaluator_id IN NUMBER DEFAULT NULL,
    x_assign_type IN VARCHAR2 DEFAULT NULL,
    x_assign_date IN DATE DEFAULT NULL,
    x_evaluation_date IN DATE DEFAULT NULL,
    x_rating_type_id IN NUMBER DEFAULT NULL,
    x_rating_values_id IN NUMBER DEFAULT NULL,
    x_rating_notes IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_evaluation_sequence IN NUMBER DEFAULT NULL,
    x_rating_scale_id IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2
  ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_APPL_EVAL
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
    new_references.appl_eval_id := x_appl_eval_id;
    new_references.person_id := x_person_id;
    new_references.admission_appl_number := x_admission_appl_number;
    new_references.nominated_course_cd := x_nominated_course_cd;
    new_references.sequence_number := x_sequence_number;
    new_references.evaluator_id := x_evaluator_id;
    new_references.assign_type := x_assign_type;
    new_references.assign_date := TRUNC(x_assign_date);
    new_references.evaluation_date := TRUNC(x_evaluation_date);
    new_references.rating_type_id := x_rating_type_id;
    new_references.rating_values_id := x_rating_values_id;
    new_references.rating_notes := x_rating_notes;
    new_references.evaluation_sequence := x_evaluation_sequence;
    new_references.rating_scale_id := x_rating_scale_id;
    new_references.closed_ind := x_closed_ind;
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

  PROCEDURE Check_Constraints (
                 Column_Name IN VARCHAR2  DEFAULT NULL,
                 Column_Value IN VARCHAR2  DEFAULT NULL ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'ASSIGN_TYPE'  THEN
        new_references.assign_type := column_value;
        NULL;
      END IF;



    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'ASSIGN_TYPE' OR
        Column_Name IS NULL THEN
        IF NOT (new_references.assign_type IN ('M','A'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;


  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.rating_values_id = new_references.rating_values_id)) OR
        ((new_references.rating_values_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Rs_Values_Pkg.Get_PK_For_Validation (
              new_references.rating_values_id ,
              'N' )  THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.rating_type_id = new_references.rating_type_id)) OR
        ((new_references.rating_type_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
              new_references.rating_type_id,
              'RATING_TYPE',
              'N' )  THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.admission_appl_number = new_references.admission_appl_number) AND
         (old_references.nominated_course_cd = new_references.nominated_course_cd) AND
         (old_references.sequence_number = new_references.sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.admission_appl_number IS NULL) OR
         (new_references.nominated_course_cd IS NULL) OR
         (new_references.sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Ps_Appl_Inst_Pkg.Get_PKNolock_For_Validation (    -- changed the function call from  Igs_Ad_Ps_Appl_Inst_Pkg.Get_PK_For_Validation to
                         new_references.person_id,                                                                 -- Igs_Ad_Ps_Appl_Inst_Pkg.Get_PKNolock_For_Validation (For Bug 2760811 - ADCR061
                         new_references.admission_appl_number,                                    -- locking issues -- rghosh )
                         new_references.nominated_course_cd,
                         new_references.sequence_number
        )  THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.evaluator_id = new_references.evaluator_id)) OR
        ((new_references.evaluator_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Pe_Person_Pkg.Get_PK_For_Validation (
                        new_references.evaluator_id
        )  THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_appl_eval_id IN NUMBER,
    x_closed_ind IN VARCHAR2
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_appl_eval
      WHERE    appl_eval_id = x_appl_eval_id AND
               NVL(closed_ind,'N') = DECODE(closed_ind,NULL,'N',NVL(x_closed_ind,closed_ind))
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

  PROCEDURE Get_FK_Igs_Ad_Rs_Values (
    x_rating_values_id IN NUMBER
    ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_appl_eval
      WHERE    rating_values_id = x_rating_values_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AAE_ARV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Rs_Values;

  PROCEDURE Get_FK_Igs_Ad_Code_Classes (
    x_code_id IN NUMBER
    ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_appl_eval
      WHERE    rating_type_id = x_code_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AAE_ACDC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Code_Classes;

  PROCEDURE Get_FK_Igs_Ad_Ps_Appl_Inst (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_appl_eval
      WHERE    person_id = x_person_id
      AND      admission_appl_number = x_admission_appl_number
      AND      nominated_course_cd = x_nominated_course_cd
      AND      sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AAE_ACAI_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Ps_Appl_Inst;

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

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_appl_eval
      WHERE    evaluator_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AAE_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Pe_Person;

  PROCEDURE Get_FK_Igs_Ad_Rating_Scales (
    x_rating_scale_id IN NUMBER
    ) AS

  /*************************************************************
  Created By : rboddu
  Date Created By : 16-NOV-2001
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_appl_eval
      WHERE    rating_scale_id = x_rating_scale_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AAE_ARS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Rating_Scales;

  PROCEDURE Check_Outcome_Status (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) IS
     /*************************************************************
  Created By : rghosh
  Date Created By : 20-Feb-2003
  Purpose : Insert and Update is not allowed if  system outcome status is in
                     ('VOIDED','WITHDRAWN','NO-QUOTA','OFFER','OFFER-FUTURE-TERM')
		     or the system outcome status  is REJECTED and the
		     req_for_reconsideration_ind is set to 'N'
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR c_get_outcome_status ( p_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
                                                                    p_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
								    p_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
								    p_sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE ) IS
      SELECT a.adm_outcome_status, b.req_for_reconsideration_ind
      FROM igs_ad_ps_appl_inst_all a, igs_ad_ps_appl b
      WHERE a.person_id = p_person_id
      AND a.admission_appl_number = p_admission_appl_number
      AND a.nominated_course_cd = p_nominated_course_cd
      AND a.sequence_number = p_sequence_number
      AND a.person_id = b.person_id
      AND a.admission_appl_number = b.admission_appl_number
      AND a.nominated_course_cd = b.nominated_course_cd;

     c_get_outcome_status_rec c_get_outcome_status%ROWTYPE;

   BEGIN

     OPEN c_get_outcome_status (
                         x_person_id,
                         x_admission_appl_number,
                         x_nominated_course_cd,
                         x_sequence_number  );
     FETCH c_get_outcome_status INTO c_get_outcome_status_rec;
     IF IGS_AD_GEN_008.ADMP_GET_SAOS(c_get_outcome_status_rec.adm_outcome_status) IN ('VOIDED','WITHDRAWN','NO-QUOTA','OFFER','OFFER-FUTURE-TERM') THEN
       Fnd_Message.Set_name('IGS','IGS_AD_NOT_INS_UPD_EVAL_OUT');
       IGS_GE_MSG_STACK.ADD;
       CLOSE c_get_outcome_status;
       App_Exception.Raise_Exception;
     ELSIF IGS_AD_GEN_008.ADMP_GET_SAOS(c_get_outcome_status_rec.adm_outcome_status) = 'REJECTED' AND c_get_outcome_status_rec.req_for_reconsideration_ind = 'N' THEN
       Fnd_Message.Set_name('IGS','IGS_AD_NOT_INS_UPD_EVAL_REQ');
       IGS_GE_MSG_STACK.ADD;
       CLOSE c_get_outcome_status;
       App_Exception.Raise_Exception;
     END IF;
     CLOSE c_get_outcome_status;

  END Check_Outcome_Status;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_appl_eval_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_evaluator_id IN NUMBER DEFAULT NULL,
    x_assign_type IN VARCHAR2 DEFAULT NULL,
    x_assign_date IN DATE DEFAULT NULL,
    x_evaluation_date IN DATE DEFAULT NULL,
    x_rating_type_id IN NUMBER DEFAULT NULL,
    x_rating_values_id IN NUMBER DEFAULT NULL,
    x_rating_notes IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_evaluation_sequence IN NUMBER DEFAULT NULL,
    x_rating_scale_id IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_appl_eval_id,
      x_person_id,
      x_admission_appl_number,
      x_nominated_course_cd,
      x_sequence_number,
      x_evaluator_id,
      x_assign_type,
      x_assign_date,
      x_evaluation_date,
      x_rating_type_id,
      x_rating_values_id,
      x_rating_notes,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_evaluation_sequence,
      x_rating_scale_id,
      x_closed_ind
    );

    igs_ad_gen_002.check_adm_appl_inst_stat(
      nvl(x_person_id,old_references.person_id),
      nvl(x_admission_appl_number,old_references.admission_appl_number),
      nvl(x_nominated_course_cd,old_references.nominated_course_cd),
      nvl(x_sequence_number,old_references.sequence_number)
      );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
             IF Get_Pk_For_Validation(
                new_references.appl_eval_id)  THEN
               Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
             END IF;
      Check_Constraints;
      Check_Parent_Existance;
      Check_Outcome_Status  (
                         new_references.person_id,
                         new_references.admission_appl_number,
                         new_references.nominated_course_cd,
                         new_references.sequence_number  );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Constraints;
      Check_Parent_Existance;
      Check_Outcome_Status  (
                         new_references.person_id,
                         new_references.admission_appl_number,
                         new_references.nominated_course_cd,
                         new_references.sequence_number  );
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
         -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
                new_references.appl_eval_id)  THEN
               Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
             END IF;
      Check_Constraints;
      Check_Outcome_Status  (
                         new_references.person_id,
                         new_references.admission_appl_number,
                         new_references.nominated_course_cd,
                         new_references.sequence_number  );
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
      Check_Outcome_Status  (
                         new_references.person_id,
                         new_references.admission_appl_number,
                         new_references.nominated_course_cd,
                         new_references.sequence_number  );
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Null;
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

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      Null;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

   l_rowid:=NULL;
   END After_DML;

/* New procedure to findout the person id for the next set of evaluators */

FUNCTION find_next_eval (
        x_person_id             IN      NUMBER,
        x_admission_appl_number IN      NUMBER,
        x_NOMINATED_COURSE_CD   IN      VARCHAR2,
        x_SEQUENCE_NUMBER       IN      NUMBER,
        x_eval_seq              IN      NUMBER
        ) RETURN NUMBER AS

/* Given an evaluation sequence this function is used to find out the next evaluator person id */

        cursor c_next_eval IS
        select evaluation_sequence
        from igs_ad_appl_eval
        where person_id = x_person_id
        and admission_appl_number = x_admission_appl_number
        and nominated_course_cd = x_nominated_course_cd
        and sequence_number = x_sequence_number
        and evaluation_sequence > x_eval_seq
        order by evaluation_sequence;

        cursor c_next_person_id(cp_eval_seq number) is
		Select
	        distinct EVALUATOR_ID
                From IGS_AD_APPL_EVAL
                Where EVALUATION_SEQUENCE = cp_eval_seq
		and person_id = x_person_id
		and admission_appl_number = x_admission_appl_number
		and nominated_course_cd = x_nominated_course_cd
		and sequence_number = x_sequence_number;

l_next_eval_seq NUMBER;
l_next_person_id NUMBER;

BEGIN
        OPEN c_next_eval;
        FETCH c_next_eval INTO l_next_eval_seq;
        IF c_next_eval%NOTFOUND THEN
           CLOSE c_next_eval;
           RETURN 0;
        ELSE
           CLOSE c_next_eval;
	END IF;

	OPEN c_next_person_id(l_next_eval_seq);
	FETCH c_next_person_id INTO l_next_person_id;
	CLOSE c_next_person_id;

	RETURN l_next_person_id;
END;



/************** New Procedure for sending notification to evaluators: bug 2864696 ******************/

PROCEDURE wf_evaluator_validation (
        x_person_id             IN      NUMBER,
        x_admission_appl_number IN      NUMBER,
        x_NOMINATED_COURSE_CD   IN      VARCHAR2,
        x_SEQUENCE_NUMBER       IN      NUMBER,
        x_eval_seq              IN      NUMBER
        ) IS

Cursor c_appl_revprof IS
                SELECT
                a.appl_rev_profile_id,
                a.appl_revprof_revgr_id,
                r.SEQUENTIAL_CONCURRENT_IND
                FROM    igs_ad_appl_arp a,  igs_ad_apl_rev_prf_all r
                WHERE   a.person_id = x_person_id
                AND     a.admission_appl_number = x_admission_appl_number
                And     a.nominated_course_cd = x_nominated_course_cd
                And     a.sequence_number = x_sequence_number
                AND     a.appl_rev_profile_id = r.appl_rev_profile_id;

Cursor c_eval_num IS
		SELECT  'X'					--bug 3709285 arvsrini
                FROM    IGS_AD_APPL_EVAL
                WHERE   EVALUATION_SEQUENCE = x_eval_seq
                AND     rating_type_ID is NOT NULL
                AND     rating_scale_id IS NOT NULL
                AND     EVALUATION_DATE IS NULL
                AND     rating_values_id IS NULL
		AND	PERSON_ID = x_person_id
		AND	ADMISSION_APPL_NUMBER = x_admission_appl_number
		AND	NOMINATED_COURSE_CD = x_nominated_course_cd
		AND	SEQUENCE_NUMBER = x_sequence_number;


        /*        SELECT  count(rowid)
                FROM    IGS_AD_APPL_EVAL
                WHERE   EVALUATION_SEQUENCE = x_eval_seq
                AND     rating_type_ID is NOT NULL
                AND     rating_scale_id IS NOT NULL
                AND     EVALUATION_DATE IS NOT NULL
                AND     rating_values_id  IS NOT NULL;
	*/


l_eval_num  NUMBER := 0;
l_appl_revprof_id igs_ad_apl_rev_prf_all.appl_rev_profile_id%TYPE;
l_appl_revprof_revgr_id igs_ad_appl_arp.APPL_REVPROF_REVGR_ID%TYPE;
l_seq_conc_ind igs_ad_apl_rev_prf_all.SEQUENTIAL_CONCURRENT_IND%TYPE;

l_person_id NUMBER;
l_person_name VARCHAR2(320);
l_full_name VARCHAR2(1000);
l_display_name VARCHAR2(360);


BEGIN

        OPEN c_appl_revprof;
        FETCH c_appl_revprof INTO l_appl_revprof_id, l_appl_revprof_revgr_id, l_seq_conc_ind;
        IF c_appl_revprof%NOTFOUND THEN
                CLOSE c_appl_revprof;
                Return;
        ELSE
             IF l_seq_conc_ind = 'S' THEN
                IF g_dns_ind = 'N' THEN

                        OPEN c_eval_num;

                        FETCH c_eval_num INTO l_eval_num;
	--			IF C_EVAL_NUM%NOTFOUND THEN		-- bug 3709285
				IF C_EVAL_NUM%FOUND THEN		-- If there exists any un eveluated record for this sequence number then do not send notification to next evaluator
                                        RETURN;
                        ELSE

/* Added this function call to take care of evaluation sequence gaps caused by delete on this table */
                                l_person_id := find_next_eval(
                                        x_person_id,
                                        x_admission_appl_number,
                                        x_NOMINATED_COURSE_CD,
                                        x_SEQUENCE_NUMBER,
                                        x_eval_seq );

         /*             Select
	                distinct person_id
                        Into l_person_id
                        From IGS_AD_APPL_EVAL
                        Where EVALUATION_SEQUENCE = x_eval_seq + 1;  */

                        Wf_Directory.GetRoleName('HZ_PARTY', l_person_id, l_person_name, l_full_name);

                                IF l_person_name IS NOT NULL THEN

                                FND_FILE.PUT_LINE (FND_FILE.LOG, '');
                                FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF6');
                                FND_MESSAGE.SET_TOKEN ('PNAME', l_full_name);
                                FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

                                IGS_AD_ASSIGN_EVAL_AI_PKG.Wf_Inform_Evaluator_Appl (l_person_id, l_person_name,l_full_name);

                                ELSE
                                FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF4');
                                FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

                                END IF ; /* l_person_name */

                        END IF; /* c_eval_num */

                END IF; /* p_dns_ind */

            END IF; /* seq_conc_ind */

        END IF; /* c_appl_revprof */

  EXCEPTION
     WHEN OTHERS THEN
       IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

   IF c_appl_revprof%ISOPEN THEN
      CLOSE c_appl_revprof;
   END IF;
   IF c_eval_num%ISOPEN THEN
      CLOSE c_eval_num;
   END IF;

END wf_evaluator_validation;
/***************************/


 PROCEDURE insert_row (
       x_rowid IN OUT NOCOPY VARCHAR2,
       x_appl_eval_id IN OUT NOCOPY NUMBER,
       x_person_id IN NUMBER,
       x_admission_appl_number IN NUMBER,
       x_nominated_course_cd IN VARCHAR2,
       x_sequence_number IN NUMBER,
       x_evaluator_id IN NUMBER,
       x_assign_type IN VARCHAR2,
       x_assign_date IN DATE,
       x_evaluation_date IN DATE,
       x_rating_type_id IN NUMBER,
       x_rating_values_id IN NUMBER,
       x_rating_notes IN VARCHAR2,
       x_mode IN VARCHAR2,
       x_evaluation_sequence IN NUMBER DEFAULT NULL,
       x_rating_scale_id IN NUMBER DEFAULT NULL,
       x_closed_ind IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ravishar      5/30/2005        Security related changes

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_AD_APPL_EVAL
             where                 APPL_EVAL_ID= X_APPL_EVAL_ID
;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
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
      if (X_REQUEST_ID =  -1) then
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

   X_APPL_EVAL_ID := -1;
   Before_DML(
                p_action=>'INSERT',
                x_rowid=>X_ROWID,
               x_appl_eval_id=>X_APPL_EVAL_ID,
               x_person_id=>X_PERSON_ID,
               x_admission_appl_number=>X_ADMISSION_APPL_NUMBER,
               x_nominated_course_cd=>X_NOMINATED_COURSE_CD,
               x_sequence_number=>X_SEQUENCE_NUMBER,
               x_evaluator_id=>X_EVALUATOR_ID,
               x_assign_type=>X_ASSIGN_TYPE,
               x_assign_date=>X_ASSIGN_DATE,
               x_evaluation_date=>X_EVALUATION_DATE,
               x_rating_type_id=>X_RATING_TYPE_ID,
               x_rating_values_id=>X_RATING_VALUES_ID,
               x_rating_notes=>X_RATING_NOTES,
               x_creation_date=>X_LAST_UPDATE_DATE,
               x_created_by=>X_LAST_UPDATED_BY,
               x_last_update_date=>X_LAST_UPDATE_DATE,
               x_last_updated_by=>X_LAST_UPDATED_BY,
               x_last_update_login=>X_LAST_UPDATE_LOGIN,
               x_evaluation_sequence=>X_EVALUATION_SEQUENCE,
               x_rating_scale_id=>X_RATING_SCALE_ID,
	       x_closed_ind => X_CLOSED_IND);
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_ad_appl_eval (
                appl_eval_id
                ,person_id
                ,admission_appl_number
                ,nominated_course_cd
                ,sequence_number
                ,evaluator_id
                ,assign_type
                ,assign_date
                ,evaluation_date
                ,rating_type_id
                ,rating_values_id
                ,rating_notes
                ,creation_date
                ,created_by
                ,last_update_date
                ,last_updated_by
                ,last_update_login
                ,request_id
                ,program_id
                ,program_application_id
                ,program_update_date
                ,evaluation_sequence
                ,rating_scale_id
                ,closed_ind
        ) VALUES  (
                igs_ad_appl_eval_s.NEXTVAL
                ,new_references.person_id
                ,new_references.admission_appl_number
                ,new_references.nominated_course_cd
                ,new_references.sequence_number
                ,new_references.evaluator_id
                ,new_references.assign_type
                ,new_references.assign_date
                ,new_references.evaluation_date
                ,new_references.rating_type_id
                ,new_references.rating_values_id
                ,new_references.rating_notes
                ,x_last_update_date
                ,x_last_updated_by
                ,x_last_update_date
                ,x_last_updated_by
                ,x_last_update_login
                ,x_request_id
                ,x_program_id
                ,x_program_application_id
                ,x_program_update_date
                ,x_evaluation_sequence
                ,x_rating_scale_id
		,x_closed_ind
)RETURNING appl_eval_id INTO x_appl_eval_id;
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

                OPEN c;
                 FETCH c INTO x_rowid;
                IF (c%NOTFOUND) THEN
                  CLOSE c;
                  RAISE no_data_found;
                END IF;
                CLOSE c;
    After_DML (
                p_action => 'INSERT' ,
                x_rowid => X_ROWID );
EXCEPTION
  WHEN OTHERS THEN
    IF (x_mode = 'S') THEN
      igs_sc_gen_001.unset_ctx('R');
    END IF;
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
END insert_row;

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_appl_eval_id                      IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_evaluator_id                      IN     NUMBER,
    x_assign_type                       IN     VARCHAR2,
    x_assign_date                       IN     DATE,
    x_evaluation_date                   IN     DATE,
    x_rating_type_id                    IN     NUMBER,
    x_rating_values_id                  IN     NUMBER,
    x_rating_notes                      IN     VARCHAR2,
    x_evaluation_sequence               IN     NUMBER,
    x_rating_scale_id                   IN     NUMBER,
    x_closed_ind IN VARCHAR2
  ) AS
  /*
  ||  Created By : kamohan
  ||  Created On : 06-FEB-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        admission_appl_number,
        nominated_course_cd,
        sequence_number,
        evaluator_id,
        assign_type,
        assign_date,
        evaluation_date,
        rating_type_id,
        rating_values_id,
        rating_notes,
        evaluation_sequence,
        rating_scale_id,
        closed_ind
      FROM  igs_ad_appl_eval
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
        AND (tlinfo.admission_appl_number = x_admission_appl_number)
        AND (tlinfo.nominated_course_cd = x_nominated_course_cd)
        AND (tlinfo.sequence_number = x_sequence_number)
        AND (tlinfo.evaluator_id = x_evaluator_id)
        AND (tlinfo.assign_type = x_assign_type)
        AND (trunc(tlinfo.assign_date) = trunc(x_assign_date))
        AND ((trunc(tlinfo.evaluation_date) = trunc(x_evaluation_date)) OR ((tlinfo.evaluation_date IS NULL) AND (X_evaluation_date IS NULL)))
        AND ((tlinfo.rating_type_id = x_rating_type_id) OR ((tlinfo.rating_type_id IS NULL) AND (X_rating_type_id IS NULL)))
        AND ((tlinfo.rating_values_id = x_rating_values_id) OR ((tlinfo.rating_values_id IS NULL) AND (X_rating_values_id IS NULL)))
        AND ((tlinfo.rating_notes = x_rating_notes) OR ((tlinfo.rating_notes IS NULL) AND (X_rating_notes IS NULL)))
        AND ((tlinfo.evaluation_sequence = x_evaluation_sequence) OR ((tlinfo.evaluation_sequence IS NULL) AND (X_evaluation_sequence IS NULL)))
        AND ((tlinfo.rating_scale_id = x_rating_scale_id) OR ((tlinfo.rating_scale_id IS NULL) AND (X_rating_scale_id IS NULL)))
	AND ((tlinfo.closed_ind = x_closed_ind) OR ((tlinfo.closed_ind IS NULL) AND (X_closed_ind IS NULL)))
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
       x_rowid IN  VARCHAR2,
       x_appl_eval_id IN NUMBER,
       x_person_id IN NUMBER,
       x_admission_appl_number IN NUMBER,
       x_nominated_course_cd IN VARCHAR2,
       x_sequence_number IN NUMBER,
       x_evaluator_id IN NUMBER,
       x_assign_type IN VARCHAR2,
       x_assign_date IN DATE,
       x_evaluation_date IN DATE,
       x_rating_type_id IN NUMBER,
       x_rating_values_id IN NUMBER,
       x_rating_notes IN VARCHAR2,
       x_mode IN VARCHAR2,
       x_evaluation_sequence IN NUMBER DEFAULT NULL,
       x_rating_scale_id IN NUMBER DEFAULT NULL,
       x_closed_ind IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ravishar      05/27/05        Security related changes

  (reverse chronological order - newest change first)
  ***************************************************************/

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
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
      FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    end if;
   Before_DML(
                p_action=>'UPDATE',
                x_rowid=>X_ROWID,
               x_appl_eval_id=>X_APPL_EVAL_ID,
               x_person_id=>X_PERSON_ID,
               x_admission_appl_number=>X_ADMISSION_APPL_NUMBER,
               x_nominated_course_cd=>X_NOMINATED_COURSE_CD,
               x_sequence_number=>X_SEQUENCE_NUMBER,
               x_evaluator_id=>X_EVALUATOR_ID,
               x_assign_type=>X_ASSIGN_TYPE,
               x_assign_date=>X_ASSIGN_DATE,
               x_evaluation_date=>X_EVALUATION_DATE,
               x_rating_type_id=>X_RATING_TYPE_ID,
               x_rating_values_id=>X_RATING_VALUES_ID,
               x_rating_notes=>X_RATING_NOTES,
               x_creation_date=>X_LAST_UPDATE_DATE,
               x_created_by=>X_LAST_UPDATED_BY,
               x_last_update_date=>X_LAST_UPDATE_DATE,
               x_last_updated_by=>X_LAST_UPDATED_BY,
               x_last_update_login=>X_LAST_UPDATE_LOGIN,
               x_evaluation_sequence=>X_EVALUATION_SEQUENCE,
               x_rating_scale_id=>X_RATING_SCALE_ID,
	       x_closed_ind => X_CLOSED_IND );

    if (X_MODE IN ('R', 'S')) then
      X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
      X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
      if (X_REQUEST_ID = -1) then
        X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
        X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;
        X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
        X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
      else
        X_PROGRAM_UPDATE_DATE := SYSDATE;
      end if;
    end if;

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_ad_appl_eval SET
      person_id =  new_references.person_id,
      admission_appl_number =  new_references.admission_appl_number,
      nominated_course_cd =  new_references.nominated_course_cd,
      sequence_number =  new_references.sequence_number,
      evaluator_id =  new_references.evaluator_id,
      assign_type =  new_references.assign_type,
      assign_date =  new_references.assign_date,
      evaluation_date =  new_references.evaluation_date,
      rating_type_id =  new_references.rating_type_id,
      rating_values_id =  new_references.rating_values_id,
      rating_notes =  new_references.rating_notes,
      evaluation_sequence = new_references.evaluation_sequence,
      rating_scale_id = new_references.rating_scale_id,
      last_update_date = x_last_update_date,
      last_updated_by = x_last_updated_by,
      last_update_login = x_last_update_login,
      request_id = x_request_id,
      program_id = x_program_id,
      program_application_id = program_application_id,
      program_update_date = x_program_update_date,
      closed_ind = x_closed_ind
   WHERE rowid = x_rowid;
   IF (sql%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     IF (x_mode = 'S') THEN
       igs_sc_gen_001.unset_ctx('R');
     END IF;
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
 END IF;


 After_DML (
        p_action => 'UPDATE' ,
        x_rowid => X_ROWID
        );

/* Added this if clause to take of closed indicator */

IF x_closed_ind = 'N' and old_references.evaluation_date IS NULL and
                old_references.rating_values_id IS NULL THEN

wf_evaluator_validation (
        x_person_id             => x_person_id,
        x_admission_appl_number => x_admission_appl_number,
        x_NOMINATED_COURSE_CD   => x_NOMINATED_COURSE_CD,
        x_SEQUENCE_NUMBER       => x_SEQUENCE_NUMBER,
        x_eval_seq              => x_EVALUATION_SEQUENCE
        );
END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (x_mode = 'S') THEN
       igs_sc_gen_001.unset_ctx('R');
    END IF;
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
END update_row;

 PROCEDURE add_row (
       x_rowid IN OUT NOCOPY VARCHAR2,
       x_appl_eval_id IN OUT NOCOPY NUMBER,
       x_person_id IN NUMBER,
       x_admission_appl_number IN NUMBER,
       x_nominated_course_cd IN VARCHAR2,
       x_sequence_number IN NUMBER,
       x_evaluator_id IN NUMBER,
       x_assign_type IN VARCHAR2,
       x_assign_date IN DATE,
       x_evaluation_date IN DATE,
       x_rating_type_id IN NUMBER,
       x_rating_values_id IN NUMBER,
       x_rating_notes IN VARCHAR2,
       x_mode IN VARCHAR2,
       x_evaluation_sequence IN NUMBER DEFAULT NULL,
       x_rating_scale_id IN NUMBER  DEFAULT NULL ,
       x_closed_ind IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR c1 IS
      SELECT rowid FROM igs_ad_appl_eval
      WHERE     appl_eval_id= x_appl_eval_id;

BEGIN
        OPEN c1;
        FETCH c1 INTO x_rowid;
        IF (c1%NOTFOUND) THEN
          CLOSE c1;
          insert_row (
            x_rowid,
             x_appl_eval_id,
             x_person_id,
             x_admission_appl_number,
             x_nominated_course_cd,
             x_sequence_number,
             x_evaluator_id,
             x_assign_type,
             x_assign_date,
             x_evaluation_date,
             x_rating_type_id,
             x_rating_values_id,
             x_rating_notes,
             x_mode,
             x_evaluation_sequence,
             x_rating_scale_id,
             x_closed_ind );
          RETURN;
        END IF;
        CLOSE c1;
update_row (
      x_rowid,
       x_appl_eval_id,
       x_person_id,
       x_admission_appl_number,
       x_nominated_course_cd,
       x_sequence_number,
       x_evaluator_id,
       x_assign_type,
       x_assign_date,
       x_evaluation_date,
       x_rating_type_id,
       x_rating_values_id,
       x_rating_notes,
       x_mode,
       x_evaluation_sequence,
       x_rating_scale_id,
       x_closed_ind );
END add_row;

function find_prev_seq_number(
        x_person_id             IN      NUMBER,
        x_admission_appl_number IN      NUMBER,
        x_NOMINATED_COURSE_CD   IN      VARCHAR2,
        x_SEQUENCE_NUMBER       IN      NUMBER,
        x_eval_seq              IN      NUMBER
) RETURN NUMBER AS

/* Given an evaluation sequence this function is used to find out the previous evaluation sequence number */
        cursor c_prev_eval IS
        select evaluation_sequence
        from igs_ad_appl_eval
        where person_id = x_person_id
        and admission_appl_number = x_admission_appl_number
        and nominated_course_cd = x_nominated_course_cd
        and sequence_number = x_sequence_number
        and evaluation_sequence < x_eval_seq
        order by evaluation_sequence desc;
l_prev_eval_seq NUMBER;

BEGIN
        OPEN c_prev_eval;
        FETCH c_prev_eval INTO l_prev_eval_seq;
        IF c_prev_eval%NOTFOUND THEN
           CLOSE c_prev_eval;
           RETURN 0;
        ELSE
           CLOSE c_prev_eval;
           RETURN  l_prev_eval_seq;
        END IF;

END;

procedure Notification_On_Delete(
        x_person_id             IN      NUMBER,
        x_admission_appl_number IN      NUMBER,
        x_NOMINATED_COURSE_CD   IN      VARCHAR2,
        x_SEQUENCE_NUMBER       IN      NUMBER,
        x_eval_seq              IN      NUMBER
) AS

/* This procedure is used to sent notification to the next personid in the sequence provided all records in the current sequence is del
eted and the evaluation has been completed for the prevous sequence */

/* Cursor to find out if there are still some records for the evaluation sequence that is getting deleted */

        cursor c_seq_exists IS
        SELECT evaluation_sequence
        FROM IGS_AD_APPL_EVAL
        WHERE person_id = x_person_id
        AND admission_appl_number = x_admission_appl_number
        AND nominated_course_cd = x_nominated_course_cd
        AND sequence_number = x_sequence_number
        and evaluation_sequence = x_eval_seq;

/* Cursor to find out if the previous evaluation sequence has been completed or not */

        cursor c_prev_seq_compl (cp_prev_seq_number IN NUMBER) IS
        SELECT evaluation_sequence
        FROM IGS_AD_APPL_EVAL
        WHERE person_id = x_person_id
        AND admission_appl_number = x_admission_appl_number
        AND nominated_course_cd = x_nominated_course_cd
        AND sequence_number = x_sequence_number
        and evaluation_sequence = cp_prev_seq_number
        and evaluation_date IS NULL
        AND rating_values_id IS NULL;

l_seq_exists NUMBER;
l_prev_seq_number NUMBER;
l_prev_seq_compl NUMBER;
l_next_seq_person_id NUMBER;

BEGIN

     OPEN c_seq_exists;
     FETCH c_seq_exists INTO l_seq_exists;
     IF c_seq_exists%FOUND THEN
        CLOSE c_seq_exists;
     ELSE
        CLOSE c_seq_exists;
        l_prev_seq_number := find_prev_seq_number (
                                        x_person_id,
                                        x_admission_appl_number,
                                        x_NOMINATED_COURSE_CD,
                                        x_SEQUENCE_NUMBER,
                                        x_eval_seq );
        IF l_prev_seq_number > 0 THEN
                OPEN c_prev_seq_compl(l_prev_seq_number);
                FETCH c_prev_seq_compl INTO l_prev_seq_compl;
                IF c_prev_seq_compl%NOTFOUND THEN
                        close c_prev_seq_compl;
                        l_next_seq_person_id := find_next_eval(
                                        x_person_id,
                                        x_admission_appl_number,
                                        x_NOMINATED_COURSE_CD,
                                        x_SEQUENCE_NUMBER,
                                        x_eval_seq );
                        IF l_next_seq_person_id <> 0 THEN

                        /*   send notification to this person  */

                        wf_evaluator_validation (
                        x_person_id             => x_person_id,
                        x_admission_appl_number => x_admission_appl_number,
                        x_NOMINATED_COURSE_CD   => x_NOMINATED_COURSE_CD,
                        x_SEQUENCE_NUMBER       => x_SEQUENCE_NUMBER,
                        x_eval_seq              => x_EVAL_SEQ
                        );

                        END IF;
                ELSE
                        CLOSE c_prev_seq_compl;
               END IF;
       END IF; /* l_prev_seq_number */
     END IF;

END;

PROCEDURE delete_row (
  x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ravishar      5/30/2005       Security related changes

  (reverse chronological order - newest change first)
  ***************************************************************/

        cursor c_del_appl_eval IS
        SELECT person_id,
                admission_appl_number,
                nominated_course_cd,
                sequence_number,
                evaluator_id,
                evaluation_sequence
        FROM igs_ad_appl_eval
        WHERE rowid = x_rowid;

l_del_appl_eval c_del_appl_eval%ROWTYPE;
--

BEGIN
Before_DML (
p_action => 'DELETE',
x_rowid => X_ROWID
);

        OPEN c_del_appl_eval;
        FETCH c_del_appl_eval INTO l_del_appl_eval;
        CLOSE c_del_appl_eval;

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 DELETE FROM igs_ad_appl_eval
 WHERE rowid = x_rowid;
  IF (sql%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     IF (x_mode = 'S') THEN
       igs_sc_gen_001.unset_ctx('R');
     END IF;
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
 END IF;

After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);

Notification_On_Delete(
        l_del_appl_eval.person_id,
        l_del_appl_eval.admission_appl_number,
        l_del_appl_eval.NOMINATED_COURSE_CD,
        l_del_appl_eval.SEQUENCE_NUMBER,
        l_del_appl_eval.evaluation_sequence
);

EXCEPTION
  WHEN OTHERS THEN
    IF (x_mode = 'S') THEN
       igs_sc_gen_001.unset_ctx('R');
    END IF;
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
END delete_row;

END igs_ad_appl_eval_pkg;

/
