--------------------------------------------------------
--  DDL for Package Body IGS_PE_RES_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_RES_DTLS_PKG" AS
/* $Header: IGSNI58B.pls 120.2 2006/04/12 06:42:08 skpandey ship $ */

------------------------------------------------------------------
-- Change History
--
-- Bug ID : 2000408
-- who      when          what
-- CDCRUZ   Sep 24,2002   New Col's added for
--                        Person DLD / START_DT AND END_DT
------------------------------------------------------------------
  l_rowid VARCHAR2(25);
  old_references igs_pe_res_dtls_all%RowType;
  new_references igs_pe_res_dtls_all%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_resident_details_id IN NUMBER ,
    x_person_id IN NUMBER ,
    x_residency_class_cd IN VARCHAR2 ,
    x_residency_status_cd IN VARCHAR2 ,
    x_evaluation_date IN DATE,
    x_evaluator IN VARCHAR2 ,
    x_comments IN VARCHAR2 ,
    x_attribute_category IN VARCHAR2 ,
    x_attribute1 IN VARCHAR2 ,
    x_attribute2 IN VARCHAR2 ,
    x_attribute3 IN VARCHAR2 ,
    x_attribute4 IN VARCHAR2 ,
    x_attribute5 IN VARCHAR2 ,
    x_attribute6 IN VARCHAR2 ,
    x_attribute7 IN VARCHAR2 ,
    x_attribute8 IN VARCHAR2 ,
    x_attribute9 IN VARCHAR2 ,
    x_attribute10 IN VARCHAR2,
    x_attribute11 IN VARCHAR2,
    x_attribute12 IN VARCHAR2,
    x_attribute13 IN VARCHAR2,
    x_attribute14 IN VARCHAR2,
    x_attribute15 IN VARCHAR2,
    x_attribute16 IN VARCHAR2,
    x_attribute17 IN VARCHAR2,
    x_attribute18 IN VARCHAR2,
    x_attribute19 IN VARCHAR2,
    x_attribute20 IN VARCHAR2,
    x_CAL_TYPE    IN VARCHAR2,
    x_SEQUENCE_NUMBER IN NUMBER,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER ,
    x_org_id IN NUMBER
  ) AS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_res_dtls_all
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
    new_references.resident_details_id := x_resident_details_id;
    new_references.person_id := x_person_id;
    new_references.residency_class_cd := x_residency_class_cd;
    new_references.residency_status_cd := x_residency_status_cd;
    new_references.evaluation_date := x_evaluation_date;
    new_references.evaluator := x_evaluator;
    new_references.comments := x_comments;
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
    new_references.cal_type := x_cal_type;
    new_references.sequence_number := x_sequence_number;

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
    new_references.org_id := x_org_id;

  END Set_Column_Values;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  ,
		 Column_Value IN VARCHAR2 ) AS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/
  BEGIN

      IF column_name IS NULL THEN
        NULL;
      END IF;

  END Check_Constraints;

 PROCEDURE Check_Uniqueness AS
/***********************************************************

Created By : svisweas

Date Created By : 2000/05/17

Purpose : check uniqueness on the table

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/

   BEGIN
     	IF Get_Uk_For_Validation (
    		new_references.residency_class_cd,
			new_references.person_id,
            new_references.cal_type,
            new_references.sequence_number
    		) THEN
 		 FND_MESSAGE.SET_NAME ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
         IGS_GE_MSG_STACK.ADD;
		 app_exception.raise_exception;
    	END IF;
 END Check_Uniqueness ;


  PROCEDURE Check_Parent_Existance AS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/

  BEGIN

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Pe_Person_Pkg.Get_PK_For_Validation (
        		new_references.person_id
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_resident_details_id IN NUMBER
    ) RETURN BOOLEAN AS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_res_dtls_all
      WHERE    resident_details_id = x_resident_details_id
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

  FUNCTION Get_UK_For_Validation (
    x_residency_class_cd IN VARCHAR2,
    x_person_id IN NUMBER,
    x_CAL_TYPE    IN VARCHAR2,
    x_SEQUENCE_NUMBER IN NUMBER
    ) RETURN BOOLEAN AS
/***********************************************************

Created By : svisweas

Date Created By : 2000/05/17

Purpose : check uniqueness on the table

Know limitations, enhancements or remarks

Change History

Who      When     What
asbala   3-SEP-03  Build SWCR01
****************************************************************/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_res_dtls_all
      WHERE    person_id = x_person_id
      AND      residency_class_cd = x_residency_class_cd
	  AND      cal_type = x_cal_type
	  AND      sequence_number = x_sequence_number
      AND      ((l_rowid is null) or (rowid <> l_rowid))
      ;
    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
        return (true);
        ELSE
       close cur_rowid;
      return(false);
    END IF;
  END Get_UK_For_Validation ;


  PROCEDURE Get_FK_Igs_Pe_Person (
    x_person_id IN NUMBER
    ) AS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_res_dtls_all
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PRD_PP_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Pe_Person;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_resident_details_id IN NUMBER ,
    x_person_id IN NUMBER ,
    x_residency_class_cd IN VARCHAR2 ,
    x_residency_status_cd IN VARCHAR2 ,
    x_evaluation_date IN DATE ,
    x_evaluator IN VARCHAR2 ,
    x_comments IN VARCHAR2 ,
    x_attribute_category IN VARCHAR2 ,
    x_attribute1 IN VARCHAR2 ,
    x_attribute2 IN VARCHAR2 ,
    x_attribute3 IN VARCHAR2 ,
    x_attribute4 IN VARCHAR2 ,
    x_attribute5 IN VARCHAR2 ,
    x_attribute6 IN VARCHAR2 ,
    x_attribute7 IN VARCHAR2 ,
    x_attribute8 IN VARCHAR2 ,
    x_attribute9 IN VARCHAR2 ,
    x_attribute10 IN VARCHAR2,
    x_attribute11 IN VARCHAR2,
    x_attribute12 IN VARCHAR2,
    x_attribute13 IN VARCHAR2,
    x_attribute14 IN VARCHAR2,
    x_attribute15 IN VARCHAR2,
    x_attribute16 IN VARCHAR2,
    x_attribute17 IN VARCHAR2,
    x_attribute18 IN VARCHAR2,
    x_attribute19 IN VARCHAR2,
    x_attribute20 IN VARCHAR2,
    x_CAL_TYPE    IN VARCHAR2,
    x_SEQUENCE_NUMBER IN NUMBER,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_org_id IN NUMBER
  ) AS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_resident_details_id,
      x_person_id,
      x_residency_class_cd,
      x_residency_status_cd,
      x_evaluation_date,
      x_evaluator,
      x_comments,
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
      x_cal_type,
      x_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the PROCEDUREs related to Before Insert.
      Null;
	     IF Get_Pk_For_Validation(
    		new_references.resident_details_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
               IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
      Check_Uniqueness;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the PROCEDUREs related to Before Update.
      Null;
      Check_Constraints;
      Check_Uniqueness;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the PROCEDUREs related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the PROCEDUREs related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.resident_details_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
      Check_Uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
      Check_Uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Null;
    END IF;

  END Before_DML;


--Local procedure
PROCEDURE ins_todo_det AS
    ------------------------------------------------------------------
    --Created by  : skpandey, Oracle India
    --Date created: 11-APR-2006

    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
     -------------------------------------------------------------------

    l_seq_num   NUMBER;
    l_seq_ref_num NUMBER;
    l_todo_rowid    ROWID;
    l_todo_ref_rowid ROWID;
    l_label VARCHAR2(200);
    l_debug_str VARCHAR2(4000);

    CURSOR c_todo_seq IS
    SELECT igs_pe_std_todo_seq_num_s.NEXTVAL
    FROM   DUAL;

    CURSOR c_todo_ref_seq IS
    SELECT IGS_PE_STD_TODO_REF_RF_NUM_S.NEXTVAL
    FROM DUAL;

BEGIN

  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN

    l_label := 'igs.plsql.igs_pe_res_dtls_pkg.ins_todo_det.begin';
    l_debug_str := 'PERSON ID : '||new_references.person_id ||'SEQUENCE NUMBER'||new_references.sequence_number;

    fnd_log.string( fnd_log.level_procedure, l_label, l_debug_str);
  END IF;

    -- Call the procedure used to initiate a fee reassessment when the residency class or residency status
    -- attached to a student is inserted or updated
    OPEN c_todo_seq;
    FETCH c_todo_seq INTO l_seq_num;
    CLOSE c_todo_seq;

	IGS_PE_STD_TODO_PKG.INSERT_ROW(
	x_rowid			=> l_todo_rowid,
	x_person_id		=> new_references.person_id,
	x_s_student_todo_type   => 'FEE_RECALC',
	x_sequence_number	=> l_seq_num,
	x_todo_dt		=> NULL,
	x_logical_delete_dt	=> NULL,
	x_mode			=> 'R');

    OPEN c_todo_ref_seq;
    FETCH c_todo_ref_seq INTO l_seq_ref_num;
    CLOSE c_todo_ref_seq;

        IGS_PE_STD_TODO_REF_PKG.INSERT_ROW (
	  x_rowid		=> l_todo_ref_rowid,
	  x_person_id		=> new_references.person_id,
	  x_s_student_todo_type => 'FEE_RECALC',
	  x_sequence_number	=> l_seq_num,
	  x_reference_number	=> l_seq_ref_num,
	  x_cal_type		=> new_references.cal_type,
	  x_ci_sequence_number	=> new_references.sequence_number,
	  x_course_cd		=> NULL,
	  x_unit_cd		=> NULL,
	  x_other_reference	=> NULL,
	  x_logical_delete_dt	=> NULL,
	  x_mode		=> 'R',
	  x_uoo_id		=> NULL
	  );

    EXCEPTION
        WHEN OTHERS THEN

              IF fnd_log.level_exception  >= fnd_log.g_current_runtime_level THEN

                 l_label := 'igs.plsql.igs_pe_res_dtls_pkg.ins_todo_det.exception';
                 l_debug_str := 'igs_pe_res_dtls_pkg.ins_todo_det ' || 'PERSON ID : '
                                          || new_references.person_id ||' SQLERRM:' ||  SQLERRM;

                 fnd_log.string( fnd_log.level_exception, l_label, l_debug_str);
              END IF;

    END ins_todo_det;


  PROCEDURE After_DML (
            p_action                  IN VARCHAR2,
            x_rowid                   IN VARCHAR2
          ) AS

-------------------------------------------------------------------------------
-- Bug ID : 1818617
-- who              when                  what
-- sjadhav          jun 29,2001           this PROCEDURE is modified to trigger
--                                        a Concurrent Request (IGFAPJ10) which
--                                        will create a new record in IGF To
--                                        Do table
-- rasahoo          01-Sep-2003           Removed the call of igf_update_data
--                                        as part of  FA-114(Obsoletion of FA base record History)
-------------------------------------------------------------------------------

/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What
asbala  1-SEP-03  Build : SWCR01,02,04
gmaheswa 1-Nov-2004 added a call out for processing FA todo items process in case of update/insert
****************************************************************/

  lv_rowid VARCHAR2(25);

  BEGIN
    -- lv_rowid := x_rowid;
    IF (p_action = 'INSERT') THEN

       igs_pe_wf_gen.change_residence(
        	p_resident_details_id => new_references.resident_details_id,
			p_old_res_status => old_references.residency_status_cd,
			p_old_evaluator => old_references.evaluator,
			p_old_evaluation_date => old_references.evaluation_date,
			p_old_comment => old_references.comments,
			p_action => 'I'
			);

      -- Call all the PROCEDUREs related to After Insert.
    IGS_PE_GEN_003.PROCESS_RES_DTLS(
		P_ACTION  	=>	'I',
        P_OLD_RECORD    =>	old_references,
		P_NEW_RECORD	=>	new_references
	);

	INS_TODO_DET;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the PROCEDUREs related to After Update.
     IF (new_references.residency_status_cd    <> old_references.residency_status_cd OR
        	new_references.evaluation_date <> old_references.evaluation_date OR
	        new_references.evaluator       <> old_references.evaluator OR
	        NVL(new_references.comments,'@$*&%')    <> NVL(old_references.comments,'@$*&%')) THEN

       igs_pe_wf_gen.change_residence(
        	p_resident_details_id => new_references.resident_details_id,
			p_old_res_status => old_references.residency_status_cd,
			p_old_evaluator => old_references.evaluator,
			p_old_evaluation_date => old_references.evaluation_date,
			p_old_comment => old_references.comments,
			p_action => 'U'
			);

       igs_pe_gen_003.process_res_dtls(
		P_ACTION  	=>	'U',
        P_OLD_RECORD    =>	old_references,
		P_NEW_RECORD	=>	new_references
    	);

      END IF;

      IF new_references.residency_status_cd  <> old_references.residency_status_cd  THEN
	INS_TODO_DET;
      END IF;

    ELSIF (p_action = 'DELETE') THEN
      -- Call all the PROCEDUREs related to After Delete.
      Null;
    END IF;
  END After_DML;

 PROCEDURE INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_RESIDENT_DETAILS_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_RESIDENCY_CLASS_CD IN VARCHAR2,
       x_RESIDENCY_STATUS_CD IN VARCHAR2,
       x_EVALUATION_DATE IN DATE,
       x_EVALUATOR IN VARCHAR2,
       x_COMMENTS IN VARCHAR2,
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
       x_CAL_TYPE    IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
      X_MODE in VARCHAR2 ,
      X_ORG_ID in NUMBER
  ) AS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/
    cursor C is select ROWID from igs_pe_res_dtls_all
             where   RESIDENT_DETAILS_ID= X_RESIDENT_DETAILS_ID;
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
            END if;
            X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
         if X_LAST_UPDATE_LOGIN is NULL then
            X_LAST_UPDATE_LOGIN := -1;
          END if;
       else
        FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
       END if;
    SELECT IGS_PE_RES_DTLS_S.NEXTVAL INTO X_RESIDENT_DETAILS_ID
    FROM DUAL;

   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_resident_details_id=>X_RESIDENT_DETAILS_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_residency_class_cd=>X_RESIDENCY_CLASS_CD,
 	       x_residency_status_cd=>X_RESIDENCY_STATUS_CD,
 	       x_evaluation_date=>X_EVALUATION_DATE,
 	       x_evaluator=>X_EVALUATOR,
 	       x_comments=>X_COMMENTS,
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
		   x_cal_type => x_cal_type,
		   x_sequence_number => x_sequence_number,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
	       x_org_id=>igs_ge_gen_003.get_org_id
	   );
      IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into igs_pe_res_dtls_all (
		RESIDENT_DETAILS_ID
		,PERSON_ID
		,RESIDENCY_CLASS_CD
		,RESIDENCY_STATUS_CD
		,EVALUATION_DATE
		,EVALUATOR
		,COMMENTS
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
		,CAL_TYPE
		,SEQUENCE_NUMBER
        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,ORG_ID
        ) values  (
	        NEW_REFERENCES.RESIDENT_DETAILS_ID
	        ,NEW_REFERENCES.PERSON_ID
	        ,NEW_REFERENCES.RESIDENCY_CLASS_CD
	        ,NEW_REFERENCES.RESIDENCY_STATUS_CD
	        ,NEW_REFERENCES.EVALUATION_DATE
	        ,NEW_REFERENCES.EVALUATOR
	        ,NEW_REFERENCES.COMMENTS
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
            ,NEW_REFERENCES.CAL_TYPE
            ,NEW_REFERENCES.SEQUENCE_NUMBER
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
	        ,NEW_REFERENCES.ORG_ID
);
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

		open c;
		 fetch c into X_ROWID;
 		if (c%notfound) then
		close c;
 	     raise no_data_found;
		END if;
 		close c;
    After_DML (
		    p_action       =>  'INSERT',
            x_rowid        =>  X_ROWID);


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

END INSERT_ROW;

 PROCEDURE LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_RESIDENT_DETAILS_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_RESIDENCY_CLASS_CD IN VARCHAR2,
       x_RESIDENCY_STATUS_CD IN VARCHAR2,
       x_EVALUATION_DATE IN DATE,
       x_EVALUATOR IN VARCHAR2,
       x_COMMENTS IN VARCHAR2,
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
       x_CAL_TYPE    IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER) AS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/
   cursor c1 is select
      PERSON_ID
,      RESIDENCY_CLASS_CD
,      RESIDENCY_STATUS_CD
,      EVALUATION_DATE
,      EVALUATOR
,      COMMENTS
,      CAL_TYPE
,      SEQUENCE_NUMBER
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
    from igs_pe_res_dtls_all
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
  END if;
  close c1;
if ( (  tlinfo.PERSON_ID = X_PERSON_ID)
  AND (tlinfo.RESIDENCY_CLASS_CD = X_RESIDENCY_CLASS_CD)
  AND (tlinfo.RESIDENCY_STATUS_CD = X_RESIDENCY_STATUS_CD)
  AND (tlinfo.CAL_TYPE = X_CAL_TYPE)
  AND (tlinfo.SEQUENCE_NUMBER = X_SEQUENCE_NUMBER)
  AND (tlinfo.EVALUATION_DATE = X_EVALUATION_DATE)
  AND (tlinfo.EVALUATOR = X_EVALUATOR)
  AND ((tlinfo.COMMENTS = X_COMMENTS)
 	    OR ((tlinfo.COMMENTS is null)
		AND (X_COMMENTS is null)))
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
  AND ((tlinfo.ATTRIBUTE20 = X_ATTRIBUTE20)
 	    OR ((tlinfo.ATTRIBUTE20 is null)
		AND (X_ATTRIBUTE20 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  END if;
  return;
END LOCK_ROW;

 PROCEDURE UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_RESIDENT_DETAILS_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_RESIDENCY_CLASS_CD IN VARCHAR2,
       x_RESIDENCY_STATUS_CD IN VARCHAR2,
       x_EVALUATION_DATE IN DATE,
       x_EVALUATOR IN VARCHAR2,
       x_COMMENTS IN VARCHAR2,
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
       x_CAL_TYPE    IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
      X_MODE in VARCHAR2
  ) AS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/
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
            END if;
            X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
         if X_LAST_UPDATE_LOGIN is NULL then
            X_LAST_UPDATE_LOGIN := -1;
          END if;
       else
        FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
       END if;
   Before_DML(
 		p_action=>'UPDATE',
 		x_rowid=>X_ROWID,
 	       x_resident_details_id=>X_RESIDENT_DETAILS_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_residency_class_cd=>X_RESIDENCY_CLASS_CD,
 	       x_residency_status_cd=>X_RESIDENCY_STATUS_CD,
 	       x_evaluation_date=>X_EVALUATION_DATE,
 	       x_evaluator=>X_EVALUATOR,
 	       x_comments=>X_COMMENTS,
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
		   x_cal_type => x_cal_type,
		   x_sequence_number => x_sequence_number,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
    IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 update igs_pe_res_dtls_all set
      PERSON_ID =  NEW_REFERENCES.PERSON_ID,
      RESIDENCY_CLASS_CD =  NEW_REFERENCES.RESIDENCY_CLASS_CD,
      RESIDENCY_STATUS_CD =  NEW_REFERENCES.RESIDENCY_STATUS_CD,
      EVALUATION_DATE =  NEW_REFERENCES.EVALUATION_DATE,
      EVALUATOR =  NEW_REFERENCES.EVALUATOR,
      COMMENTS =  NEW_REFERENCES.COMMENTS,
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
	  CAL_TYPE = NEW_REFERENCES.CAL_TYPE,
	  SEQUENCE_NUMBER = NEW_REFERENCES.SEQUENCE_NUMBER,
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
	  where ROWID = X_ROWID;
	if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
	END if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

 After_DML (
        	p_action        => 'UPDATE' ,
	        x_rowid         => X_ROWID
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

END UPDATE_ROW;

 PROCEDURE ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_RESIDENT_DETAILS_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_RESIDENCY_CLASS_CD IN VARCHAR2,
       x_RESIDENCY_STATUS_CD IN VARCHAR2,
       x_EVALUATION_DATE IN DATE,
       x_EVALUATOR IN VARCHAR2,
       x_COMMENTS IN VARCHAR2,
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
       x_CAL_TYPE    IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
      X_MODE in VARCHAR2,
      X_ORG_ID in NUMBER
  ) AS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/
    cursor c1 is select ROWID from igs_pe_res_dtls_all
             where     RESIDENT_DETAILS_ID= X_RESIDENT_DETAILS_ID
;
BEGIN
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_RESIDENT_DETAILS_ID,
       X_PERSON_ID,
       X_RESIDENCY_CLASS_CD,
       X_RESIDENCY_STATUS_CD,
       X_EVALUATION_DATE,
       X_EVALUATOR,
       X_COMMENTS,
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
	   X_CAL_TYPE,
	   X_SEQUENCE_NUMBER,
       X_MODE,
       X_ORG_ID );
     return;
	END if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_RESIDENT_DETAILS_ID,
       X_PERSON_ID,
       X_RESIDENCY_CLASS_CD,
       X_RESIDENCY_STATUS_CD,
       X_EVALUATION_DATE,
       X_EVALUATOR,
       X_COMMENTS,
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
	   X_CAL_TYPE,
	   X_SEQUENCE_NUMBER,
      X_MODE );
END ADD_ROW;

PROCEDURE DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) AS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/

begin
Before_DML (
p_action => 'DELETE',
x_rowid => X_ROWID
);
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 delete from igs_pe_res_dtls_all
 where ROWID = X_ROWID;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

After_DML (
                 p_action        => 'DELETE',
                 x_rowid         => X_ROWID
                 );

END DELETE_ROW;


END igs_pe_res_dtls_pkg;

/
