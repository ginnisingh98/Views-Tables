--------------------------------------------------------
--  DDL for Package Body IGS_PE_TYP_INSTANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_TYP_INSTANCES_PKG" AS
/* $Header: IGSNI46B.pls 120.12 2006/07/12 12:17:22 vskumar ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_pe_typ_instances_all%RowType;
  new_references igs_pe_typ_instances_all%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_type_instance_id IN NUMBER ,
    x_person_type_code IN VARCHAR2 ,
    x_cc_version_number IN NUMBER ,
    x_funnel_status IN VARCHAR2 ,
    x_admission_appl_number IN NUMBER ,
    x_nominated_course_cd IN VARCHAR2 ,
    x_ncc_version_number IN NUMBER ,
    x_sequence_number IN NUMBER,
    x_start_date IN DATE ,
    x_end_date IN DATE ,
    x_create_method IN VARCHAR2 ,
    x_ended_by IN NUMBER ,
    x_end_method IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER,
    x_org_id IN NUMBER ,
    x_emplmnt_category_code IN VARCHAR2
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
      FROM     IGS_PE_TYP_INSTANCES_ALL
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
    new_references.course_cd := x_course_cd;
    new_references.type_instance_id := x_type_instance_id;
    new_references.person_type_code := x_person_type_code;
    new_references.cc_version_number := x_cc_version_number;
    new_references.funnel_status := x_funnel_status;
    new_references.admission_appl_number := x_admission_appl_number;
    new_references.nominated_course_cd := x_nominated_course_cd;
    new_references.ncc_version_number := x_ncc_version_number;
    new_references.sequence_number := x_sequence_number;
    new_references.start_date := trunc(x_start_date);
    new_references.end_date := trunc(x_end_date);
    new_references.create_method := x_create_method;
    new_references.ended_by := x_ended_by;
    new_references.end_method := x_end_method;
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
    new_references.emplmnt_category_code := x_emplmnt_category_code;

  END Set_Column_Values;

  PROCEDURE After_Insert_update AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pkpatel         25-APR-2003     Bug 2908851
                                  Tuned the cursors c_get_others and c_get_active. Removed the unnecessary join with
								  igs_lookups_view and changed igs_pe_typ_instances to igs_pe_typ_instances_all
  pkpatel         4-MAY-2003      Bug 2989307
                                  Removed the existence of active records for person types other than OTHER
  (reverse chronological order - newest change first)
  ***************************************************************/

      CURSOR c_get_others(cp_system_type igs_pe_person_types.system_type%TYPE) IS
        SELECT pti.rowid
        FROM   igs_pe_typ_instances_all pti,
               igs_pe_person_types pt
        WHERE  pt.system_type = cp_system_type                 --'OTHER'
            AND pti.person_type_code = pt.person_type_code
            AND pti.person_id = new_references.person_id;

      CURSOR c_get_active(cp_system_type igs_pe_person_types.system_type%TYPE)IS
        SELECT pti.type_instance_id
        FROM   igs_pe_typ_instances_all pti,
               igs_pe_person_types pt
        WHERE  pt.system_type <> cp_system_type            --'OTHER'
            AND pti.person_type_code = pt.person_type_code
            AND pti.person_id = new_references.person_id;

        lv_rowid  VARCHAR2(25);
        lv_typ_inst_id IGS_PE_TYP_INSTANCES.TYPE_INSTANCE_ID%TYPE;

  BEGIN

    OPEN c_get_others('OTHER');
    FETCH c_get_others into lv_rowid;
    IF c_get_others%FOUND THEN

      OPEN c_get_active('OTHER');
      FETCH c_get_active into lv_typ_inst_id;
      IF c_get_active%FOUND THEN
        delete_row(lv_rowid);
      END IF;
      CLOSE c_get_active;

    END IF;
    CLOSE c_get_others;

  END After_Insert_update;

  PROCEDURE checkprospectevaluator(
    p_person_id         IN  HZ_PARTIES.party_id%TYPE,
    p_person_type_code  IN  igs_pe_typ_instances_all.person_type_code%TYPE
  )  AS
  /*************************************************************
  Created By : Nilotpal Shee
  Date Created By : 05-dec-2001
  Purpose : see the comments above
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pkpatel         20-sep-2004     Bug 3690856 (Tuned the cursors. Used a single cursor pros_eval_cur and referred the table instead of view)
  mesriniv        18-FEB-2002     Modified the >= to > in cursors
                                  c_prospect_exist,c_evaluator_exist
                                  Bug:2203778 SWCR001 Person CCR

  nshee           05-dec-2001     see comments below
  -- This procedure has been added during Evaluate Applicant Qualifications
  -- and make decision DLD (Bug#2097333). This checks whether a valid prospect/evaluator exists
  -- for a Person and hence restricts insertion of person type of evaluator/prospect respectively.
  -- This is called in Before_DML. On finding records it will throw up respective error
  -- messages which will be trapped wherever this API is called from and the error handling
  -- will be done depending on the error message returned
  (reverse chronological order - newest change first)
  ***************************************************************/
  CURSOR c_prospect_evaluator(l_person_type_code igs_pe_typ_instances_all.person_type_code%TYPE) IS
    SELECT ppt.system_type
    FROM igs_pe_person_types ppt
    WHERE ppt.person_type_code = l_person_type_code;
  l_system_type IGS_PE_PERSON_TYPES.system_type%TYPE;

   --This Cursor makes sure that a Person Can have a Person Type
   --Evaluator created from FORM only if the existing Prospect Person Type is End Dated with Sysdate or
  --less than Sysdate. And vice versa..
  --Existing check for >= has been changed to > .SInce problem
  --was found while testing IGSPE006.fmb (SWCR001 )
  --Bug.No:2203778
  CURSOR pros_eval_cur(cp_person_id igs_pe_typ_instances_all.person_id%TYPE,
                       cp_system_type igs_pe_person_types.system_type%TYPE)
  IS
  SELECT 'X'
  FROM   igs_pe_typ_instances_all pti, igs_pe_person_types ppt
  WHERE  pti.person_id = cp_person_id AND
  pti.person_type_code = ppt.person_type_code AND
  ppt.system_type = cp_system_type AND
  (pti.end_date is NULL OR (pti.end_date IS NOT NULL AND trunc(pti.end_date) > trunc(SYSDATE)));

  l_pros_eval_exist VARCHAR2(1);


  BEGIN
  OPEN c_prospect_evaluator(p_person_type_code);
  FETCH c_prospect_evaluator INTO l_system_type;
  CLOSE c_prospect_evaluator;

  IF l_system_type = 'EVALUATOR' THEN

    OPEN pros_eval_cur(p_person_id,'PROSPECT');
    FETCH pros_eval_cur INTO l_pros_eval_exist;
    IF pros_eval_cur%FOUND THEN
      CLOSE pros_eval_cur;
      FND_MESSAGE.SET_NAME('IGS','IGS_AD_PROSPCT_XST_NO_EVAL');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
     CLOSE pros_eval_cur;

  ELSIF l_system_type = 'PROSPECT' THEN

  OPEN pros_eval_cur(p_person_id,'EVALUATOR');
  FETCH pros_eval_cur INTO l_pros_eval_exist;
    IF pros_eval_cur%FOUND THEN
      CLOSE pros_eval_cur;
      FND_MESSAGE.SET_NAME('IGS','IGS_AD_EVAL_XST_NO_PROSPCT');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE pros_eval_cur;

  END IF;

  END checkprospectevaluator;

Procedure after_insertupdate2 AS
  /*************************************************************
  Created By :IDK
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pkpatel         20-sep-2004     Bug 3690856 (removed the cursor c_get_prospect since its not used. Removed igs_lookups_view join in th                                     cursor c_get_applicant. Made cursors parameterized.
  sykrishn  IDOPA2      Commented part which  prevents PROSPECT and STUDENT to coexist
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR c_get_applicant(cp_system_type igs_pe_person_types.system_type%TYPE,
	                       cp_person_id igs_pe_typ_instances_all.person_id%TYPE,
						   cp_course_cd igs_pe_typ_instances_all.nominated_course_cd%TYPE) IS
        SELECT pti.rowid,pti.*
        FROM   igs_pe_typ_instances_all pti,
               igs_pe_person_types pt
        WHERE  pt.system_type = cp_system_type      --'APPLICANT'
            AND pti.person_type_code = pt.person_type_code
            AND pti.person_id = cp_person_id
                AND pti.nominated_course_cd = cp_course_cd
                AND pti.end_date IS NULL;

    CURSOR c_get_sys_typ(cp_person_type_code igs_pe_person_types.person_type_code%TYPE) IS
        SELECT pt.system_type
        FROM igs_pe_person_types pt
        WHERE pt.person_type_code = cp_person_type_code;

l_system_type igs_pe_person_types.system_type%TYPE;
l_flag varchar2(10) ;
l_end_method varchar2(30);

begin
l_flag :='FALSE';
open c_get_sys_typ(new_references.person_type_code);
fetch c_get_sys_typ into l_system_type;
close c_get_sys_typ;

IF l_system_type = 'STUDENT' then
  for c_appl_rec in c_get_applicant('APPLICANT',new_references.person_id,new_references.course_cd)loop
    l_flag := 'TRUE' ;
    igs_pe_typ_instances_pkg.update_row(
                                        X_ROWID  => c_appl_rec.rowid,
                                        X_PERSON_ID => c_appl_rec.PERSON_ID,
                                        X_COURSE_CD => c_appl_rec.COURSE_CD,
                                        X_TYPE_INSTANCE_ID => c_appl_rec.TYPE_INSTANCE_ID,
                                        X_PERSON_TYPE_CODE => c_appl_rec.PERSON_TYPE_CODE,
                                        X_CC_VERSION_NUMBER => c_appl_rec.CC_VERSION_NUMBER,
                                        X_FUNNEL_STATUS => c_appl_rec.FUNNEL_STATUS,
                                        X_ADMISSION_APPL_NUMBER => c_appl_rec.ADMISSION_APPL_NUMBER,
                                        X_NOMINATED_COURSE_CD => c_appl_rec.NOMINATED_COURSE_CD,
                                        X_NCC_VERSION_NUMBER => c_appl_rec.NCC_VERSION_NUMBER,
                                        X_SEQUENCE_NUMBER => c_appl_rec.SEQUENCE_NUMBER,
                                        X_START_DATE => c_appl_rec.START_DATE,
                                        X_END_DATE => SYSDATE,
                                        X_CREATE_METHOD => c_appl_rec.CREATE_METHOD,
                                        X_ENDED_BY => c_appl_rec.ENDED_BY,
                                        X_END_METHOD => 'CREATE_STUDENT',
                                        X_MODE => 'R',
                                        X_EMPLMNT_CATEGORY_CODE => c_appl_rec.EMPLMNT_CATEGORY_CODE);

  end loop;
END IF;


END after_insertupdate2;


PROCEDURE before_insert AS

  /*************************************************************
  Created By : prabhat.patel
  Date Created By :
  Purpose :Bug No 2389552. The Person Type code should have the value that is not closed.
  Since at many places the closed indicator is not checked, the Active person type code is being passed explicitly.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pathipat        17-JUL-2002     Added check for system person types with more than one mapping
                  for Bug No: 2464771
  pkpatel         3-APR-2003      Bug No: 2859277
                                  Closed the cursor person_type_cur in else condition.
  asbala          12-SEP-03        Changed igs_lookups_view to igs_lookup_values in CURSOR meaning_cur
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR system_type_cur IS
    SELECT system_type
    FROM   igs_pe_person_types pt
    WHERE  pt.person_type_code = new_references.person_type_code;

    CURSOR person_type_cur(cp_system_type igs_pe_person_types.system_type%TYPE,cp_closed_ind igs_pe_person_types.closed_ind%TYPE) IS
    SELECT person_type_code
    FROM   igs_pe_person_types pt
    WHERE  pt.system_type = cp_system_type AND
           pt.closed_ind = cp_closed_ind;

    CURSOR meaning_cur(cp_system_type igs_lookup_values.lookup_code%TYPE,cp_lookup_type igs_lookups_view.lookup_type%TYPE) IS
    SELECT meaning
    FROM igs_lookup_values
    WHERE lookup_code = cp_system_type AND
          lookup_type = cp_lookup_type;

    meaning_rec meaning_cur%ROWTYPE;
        system_type_rec system_type_cur%ROWTYPE;
        person_type_rec person_type_cur%ROWTYPE;
BEGIN
     -- No need to show the System Type when code is passed as null.
    IF new_references.person_type_code IS NULL THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_PE_PERSON_TYPE_N_MAPPED');
       FND_MESSAGE.SET_TOKEN('SYSTEM_TYPE',NULL);
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    OPEN system_type_cur;
    FETCH system_type_cur INTO system_type_rec;
    CLOSE system_type_cur;

    -- Check added for system person types with more than one mapping  (pathipat)  Bug:2464771
        IF system_type_rec.system_type NOT IN ('USER_DEFINED','SS_ENROLL_STAFF') THEN
          OPEN person_type_cur(system_type_rec.system_type,'N');
          FETCH person_type_cur INTO person_type_rec;

              IF person_type_cur%NOTFOUND THEN
                 CLOSE person_type_cur;

                 OPEN meaning_cur(system_type_rec.system_type,'SYSTEM_PERSON_TYPES');
                 FETCH meaning_cur INTO meaning_rec;
                 CLOSE meaning_cur;

                     meaning_rec.meaning := ''''||meaning_rec.meaning||'''';

                 FND_MESSAGE.SET_NAME('IGS','IGS_PE_PERSON_TYPE_N_MAPPED');
                 FND_MESSAGE.SET_TOKEN('SYSTEM_TYPE',meaning_rec.meaning);
                 IGS_GE_MSG_STACK.ADD;
                 APP_EXCEPTION.RAISE_EXCEPTION;
              ELSE
                 CLOSE person_type_cur;
                 new_references.person_type_code := person_type_rec.person_type_code;
              END IF;
      END IF;

END before_insert;



  PROCEDURE Check_Constraints (
                 Column_Name IN VARCHAR2 ,
                 Column_Value IN VARCHAR2 ) AS
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
        NULL;
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

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.admission_appl_number = new_references.admission_appl_number) AND
         (old_references.nominated_course_cd = new_references.nominated_course_cd) AND
         (old_references.sequence_number = new_references.sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.admission_appl_number IS NULL) OR
         (new_references.nominated_course_cd IS NULL) OR
         (new_references.sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Ps_Appl_Inst_Pkg.Get_PK_For_Validation (
                        new_references.person_id,
                         new_references.admission_appl_number,
                         new_references.nominated_course_cd,
                         new_references.sequence_number
        )  THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.person_type_code = new_references.person_type_code)) OR
        ((new_references.person_type_code IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Pe_Person_Types_Pkg.Get_PK_For_Validation (
                        new_references.person_type_code
        )  THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.cc_version_number = new_references.cc_version_number)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.cc_version_number IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ps_Ver_Pkg.Get_PK_For_Validation (
                        new_references.course_cd,
                         new_references.cc_version_number
        )  THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

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
    x_type_instance_id IN NUMBER
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
      FROM     igs_pe_typ_instances_all
      WHERE    type_instance_id = x_type_instance_id
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
      FROM     igs_pe_typ_instances_all
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
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_TYP_APPLINST');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Ps_Appl_Inst;

  PROCEDURE Get_FK_Igs_Pe_Person_Types (
    x_person_type_code IN VARCHAR2
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
      FROM     igs_pe_typ_instances_all
      WHERE    person_type_code = x_person_type_code ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PTI_PPT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Pe_Person_Types;

  PROCEDURE Get_FK_Igs_Ps_Ver (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
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
      FROM     igs_pe_typ_instances_all
      WHERE    course_cd = x_course_cd
      AND      cc_version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_TYP_VER');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ps_Ver;

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
      FROM     igs_pe_typ_instances_all
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PTI_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;


  END Get_FK_Igs_Pe_Person;

  PROCEDURE Check_Mand_Person_Type
  (
    p_person_type_code  IN IGS_PE_PERSON_TYPES.person_type_code%TYPE,
    p_person_id                 IN HZ_PARTIES.party_id%TYPE
  )
  IS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
 (reverse chronological order - newest change first)
  ssaleem       21-NOV-2003       Bug No: 3039238
                                  Removed UPPER check for person type code in Mand_Emt cursor
  pkpatel       3-APR-2003        Bug No: 2859277
                                  Added the DBMS_SQL.CLOSE_CURSOR for the dynamic SQL created.
  asbala        12-SEP-03         Bug No:2667343 Replaced Hard coded strings populating lv_Data_Emt by
                                  lookup_codes from a lookup_type
  gmaheswa	07-JUL-05	  Bug No: 4327807 Added condition to skip Person Type Mandatory data validation
				  incase of Self-Service applications.
   vskumar	12-Jul-2006	  Bug No: 4068301 & 4068322. Added a new cursor c_ar_lookups for address_types to display meaning
						 instead of lookup_code in the error message, when it is mendatory.
  ***************************************************************/

  CURSOR Mand_Emt IS
  SELECT setup_data_element_id, person_type_code, data_element,
         value, required_ind
  FROM   igs_pe_stup_data_emt
  WHERE  person_type_code = p_person_type_code
  AND    NVL(required_ind, 'S') IN ('M');

  CURSOR Data_Emt (p_data_element IGS_PE_DATA_ELEMENT.data_element%TYPE) IS
  SELECT table_name, column_name
  FROM   igs_pe_data_element
  WHERE  UPPER(data_element) = UPPER(p_data_element) ;

  CURSOR c_lookup_meaning(cp_lookup_type  VARCHAR2,
                          cp_lookup_code  VARCHAR2) IS
                   SELECT meaning
                   FROM   IGS_LOOKUP_VALUES
                   WHERE lookup_type=cp_lookup_type AND
                         lookup_code=cp_lookup_code;

  CURSOR  c_ar_lookups(cp_lookup_type  VARCHAR2,
                          cp_lookup_code  VARCHAR2) IS
			SELECT meaning
			FROM ar_lookups
			WHERE lookup_type = cp_lookup_type
			AND lookup_code = cp_lookup_code;

  lvc_SQLStmt VARCHAR2(2000) ;
  l_Ext_Cursor NUMBER;
  lnRows NUMBER;
  lv_DataEmt  VARCHAR2(100);
  l_lookup_type VARCHAR2(30);
  l_lookup_code VARCHAR2(30);
  lv_ar_description  VARCHAR2(100);
  BEGIN

  IF IGS_PE_GEN_004.G_SKIP_MAND_DATA_VAL = 'Y' THEN
     RETURN;
  END IF;

   FOR c_Mand_Emt IN Mand_Emt LOOP
     l_lookup_type := 'PE_MAND_DATA_ELEMENT';
     lvc_SQLStmt := 'SELECT 1 FROM ';
     IF c_Mand_Emt.data_element IN ('PREFERRED_GIVEN_NAME', 'TITLE', 'DATE_OF_BIRTH',
                                    'SEX', 'EMAIL_ADDR', 'ETHNIC_ORIGIN',
                                    'INST_RES_STATUS', 'TEACH_PERIOD_RES_STATUS') THEN

       FOR c_Data_Emt IN Data_Emt (c_Mand_Emt.data_element) LOOP
         lvc_SQLStmt := lvc_SQLStmt || c_Data_Emt.table_name || ' WHERE person_id = ' || p_person_id
                                || ' AND ' || c_Data_Emt.column_name || ' IS NOT NULL ';

       END LOOP;

     ELSIF c_Mand_Emt.data_element = ('ADDRESS_TYPE') THEN
           FOR c_Data_Emt IN Data_Emt (c_Mand_Emt.data_element) LOOP
         lvc_SQLStmt := lvc_SQLStmt || c_Data_Emt.table_name || ' WHERE person_id = ' || p_person_id
                                || ' AND ' || c_Data_Emt.column_name || ' = ''' || c_Mand_Emt.value || '''';
       END LOOP;

    ELSIF c_Mand_Emt.data_element = ('PERSON_ID_TYPE') THEN
           FOR c_Data_Emt IN Data_Emt (c_Mand_Emt.data_element) LOOP
         lvc_SQLStmt := lvc_SQLStmt || c_Data_Emt.table_name || ' WHERE pe_person_id = ' || p_person_id
                                || ' AND ' || c_Data_Emt.column_name || ' = ''' || c_Mand_Emt.value || '''';
       END LOOP;


     ELSIF c_Mand_Emt.data_element IN ('PROOF_OF_INS', 'PROOF_OF_IMMU') THEN
           FOR c_Data_Emt IN Data_Emt (c_Mand_Emt.data_element) LOOP
         lvc_SQLStmt := lvc_SQLStmt || c_Data_Emt.table_name || ' WHERE person_id = ' || p_person_id
                                || ' AND NVL(' || c_Data_Emt.column_name || ', ''N'') = ''Y''';
       END LOOP;
     END IF;

     IF c_Mand_Emt.data_element IN ('PREFERRED_GIVEN_NAME', 'TITLE', 'DATE_OF_BIRTH',
                                    'ETHNIC_ORIGIN') THEN
       lv_DataEmt := INITCAP(REPLACE(c_Mand_Emt.data_element, '_', ' '));
     ELSIF c_Mand_Emt.data_element = 'SEX' THEN
       l_lookup_type := 'PERSON_TYPE_MAND_DATA';
       l_lookup_code := 'SEX';
       OPEN c_lookup_meaning(l_lookup_type,l_lookup_code);
       FETCH c_lookup_meaning INTO lv_DataEmt;
       CLOSE c_lookup_meaning;
     ELSIF c_Mand_Emt.data_element = 'EMAIL_ADDR' THEN
       l_lookup_code := 'EMAIL_ADDRESS';
       OPEN c_lookup_meaning(l_lookup_type,l_lookup_code);
       FETCH c_lookup_meaning INTO lv_DataEmt;
       CLOSE c_lookup_meaning;
     ELSIF c_Mand_Emt.data_element = 'INST_RES_STATUS' THEN
           l_lookup_code := 'INST_RES_STATUS';
	   l_lookup_type := 'PERSON_TYPE_MAND_DATA';
       OPEN c_lookup_meaning(l_lookup_type,l_lookup_code);
       FETCH c_lookup_meaning INTO lv_DataEmt;
       CLOSE c_lookup_meaning;
     ELSIF c_Mand_Emt.data_element = 'TEACH_PERIOD_RES_STATUS' THEN
       l_lookup_code := 'TEACH_PERIOD_RES_STATUS';
	   l_lookup_type := 'PERSON_TYPE_MAND_DATA';
       OPEN c_lookup_meaning(l_lookup_type,l_lookup_code);
       FETCH c_lookup_meaning INTO lv_DataEmt;
       CLOSE c_lookup_meaning;
     ELSIF c_Mand_Emt.data_element = 'ADDRESS_TYPE' THEN
       l_lookup_code := 'ADDRESS_USAGE';
       OPEN c_lookup_meaning(l_lookup_type,l_lookup_code);
       FETCH c_lookup_meaning INTO lv_DataEmt;
       CLOSE c_lookup_meaning;

       OPEN c_ar_lookups('PARTY_SITE_USE_CODE', c_Mand_Emt.Value);
       FETCH c_ar_lookups INTO lv_ar_description;
       CLOSE c_ar_lookups;
       lv_DataEmt := lv_DataEmt || ' ' || lv_ar_description;
     ELSIF c_Mand_Emt.data_element = 'PERSON_ID_TYPE' THEN
      l_lookup_code := 'PERSON_ID_TYP';
       OPEN c_lookup_meaning(l_lookup_type,l_lookup_code);
       FETCH c_lookup_meaning INTO lv_DataEmt;
       CLOSE c_lookup_meaning;
       lv_DataEmt := lv_DataEmt || ' ' || c_Mand_Emt.Value;
     ELSIF c_Mand_Emt.data_element = 'PROOF_OF_INS' THEN
       l_lookup_code := 'PROOF_OF_INS';
       OPEN c_lookup_meaning(l_lookup_type,l_lookup_code);
       FETCH c_lookup_meaning INTO lv_DataEmt;
       CLOSE c_lookup_meaning;
     ELSIF c_Mand_Emt.data_element = 'PROOF_OF_IMMU' THEN
       l_lookup_code := 'PROOF_OF_IMMU';
       OPEN c_lookup_meaning(l_lookup_type,l_lookup_code);
       FETCH c_lookup_meaning INTO lv_DataEmt;
       CLOSE c_lookup_meaning;
     END IF;


    l_Ext_Cursor := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE (l_Ext_Cursor, lvc_SQLStmt, DBMS_SQL.V7);

        lnRows := DBMS_SQL.EXECUTE_AND_FETCH (l_Ext_Cursor);

        IF lnRows = 0 THEN
-- Next line modified due to Bug no# 1496059
          DBMS_SQL.CLOSE_CURSOR(l_Ext_Cursor);
          FND_MESSAGE.SET_NAME ('IGS', 'IGS_PE_CHECK_MAND_DATA');
          FND_MESSAGE.SET_TOKEN ('Person_Type_Code', INITCAP(c_Mand_Emt.person_type_code));
          FND_MESSAGE.SET_TOKEN ('DataElement', lv_DataEmt);
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

        END IF;

        DBMS_SQL.CLOSE_CURSOR(l_Ext_Cursor);

  END LOOP;

  END Check_Mand_Person_Type;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_person_id IN NUMBER ,
    x_course_cd IN VARCHAR2 ,
    x_type_instance_id IN NUMBER ,
    x_person_type_code IN VARCHAR2 ,
    x_cc_version_number IN NUMBER ,
    x_funnel_status IN VARCHAR2 ,
    x_admission_appl_number IN NUMBER ,
    x_nominated_course_cd IN VARCHAR2 ,
    x_ncc_version_number IN NUMBER ,
    x_sequence_number IN NUMBER ,
    x_start_date IN DATE ,
    x_end_date IN DATE ,
    x_create_method IN VARCHAR2 ,
    x_ended_by IN NUMBER ,
    x_end_method IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_org_id IN NUMBER ,
    x_emplmnt_category_code IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pkpatel         5-JUL-2002      Bug No 2389552
                                  Added the call to the procedure before_insert
  rrengara        4-JAN-2002      Added code logic for the bug 2168915
  (reverse chronological order -  newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_course_cd,
      x_type_instance_id,
      x_person_type_code,
      x_cc_version_number,
   x_funnel_status,
      x_admission_appl_number,
      x_nominated_course_cd,
      x_ncc_version_number,
      x_sequence_number,
      x_start_date,
      x_end_date,
      x_create_method,
      x_ended_by,
      x_end_method,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id,
      x_emplmnt_category_code
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
             IF Get_Pk_For_Validation(
                new_references.type_instance_id)  THEN
               Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
             END IF;
      Check_Constraints;
      Check_Parent_Existance;
      -- takes the current active person type code for the system person type
      before_insert;

      Check_Mand_Person_Type (
        new_references.person_type_code,
        new_references.person_id);
      -- Call to local procedure to check whether valid Prospect/Evaluator exists
      Checkprospectevaluator(
        new_references.person_id,
        new_references.person_type_code);

     ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Constraints;
      Check_Parent_Existance;

      -- Added the following code for the Bug 2168915

      IF old_references.funnel_status = '300-INQUIRED' THEN
        IF new_references.funnel_status <> '300-INQUIRED' THEN
            FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_INVALID_FUNSTAT');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
      ELSIF old_references.funnel_status = '200-CONTACTED' THEN
        IF new_references.funnel_status  = '100-IDENTIFIED' THEN
            FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_INVALID_FUNSTAT');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
      END IF;

      Check_Mand_Person_Type (
        new_references.person_type_code,
        new_references.person_id);
      -- Call to local procedure to check whether valid Prospect/Evaluator exists
      IF (trunc(new_references.end_date) > trunc(sysdate) OR new_references.end_date IS NULL) THEN
        Checkprospectevaluator(
          new_references.person_id,
          new_references.person_type_code);
      END IF;
    ELSIF (p_action = 'DELETE') THEN
         Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
         -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
                new_references.type_instance_id)  THEN
               Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
             END IF;
      Check_Constraints;
      Check_Mand_Person_Type (
        new_references.person_type_code,
        new_references.person_id);
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
      Check_Mand_Person_Type (
        new_references.person_type_code,
        new_references.person_id);
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
       NULL;
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
  skpandey        18-AUG-2005     Bug#: 4378028
                                  Added Business Event logic for INSERT, UPDATE and DELETE cases respectively
  (reverse chronological order - newest change first)
  ***************************************************************/

  CURSOR get_usr_id_cur(cp_person_id fnd_user.person_party_id%type) IS
      SELECT user_id
      FROM fnd_user
      WHERE person_party_id = cp_person_id;

  CURSOR person_type_cur(cp_person_type igs_pe_person_types.person_type_code%TYPE) IS
    SELECT system_type
    FROM   igs_pe_person_types pt
    WHERE  pt.person_type_code = cp_person_type;


  l_system_type           igs_pe_person_types.system_type%TYPE;
  l_usr_id                fnd_user.user_id%type;
  l_usr_d_id              fnd_user.user_id%type;
  l_person_type_w_other   varchar2(30) ; -- to hold the person_type value during insert of a person type for the first time.
  l_person_id_w_other     number;  -- to hold the person_id value during insert of a person type for the first time.

---- Check if the person has more than ONE ACTIVE assignment for the same System Person Type,
---- as the user PERSON TYPE passed. UPDATE CASE
CURSOR get_active_inst_cur(cp_person_id hz_parties.party_id%type,
                           cp_system_type igs_pe_person_types.system_type%type ,
			   cp_rowid  varchar2) IS
SELECT MAX(NVL(end_date,TO_DATE('4712/12/31','YYYY/MM/DD'))) FROM igs_pe_typ_instances_all pti
WHERE pti.person_id = cp_person_id
AND   pti.rowid <> cp_rowid
AND   SYSDATE BETWEEN pti.start_date and NVL(pti.end_date, SYSDATE)
AND   pti.person_type_code IN
      (select  person_type_code from igs_pe_person_types pt where system_type =cp_system_type) ;
l_max_active_date       DATE;
l_person_end_date_other DATE;
l_prog_label               CONSTANT VARCHAR2(100) := 'igs.plsql.igs_pe_typ_instances_pkg.after_dml';
l_label                    VARCHAR2(500);
l_debug_str                VARCHAR2(3200);
l_old_end_date          DATE;
l_default_date          DATE := TO_DATE('4712/12/31','YYYY/MM/DD');
BEGIN

    l_rowid := x_rowid;
      -- Call all the procedures related to After Insert.

    -- logic is, when new person type is added for a person for the firs time, the after_insert_update calls the delete_row with rowid, that sets the
    -- new_references to null. Hence when we raise the event, it bombs.
    -- so only for that particular loop we need to hold back the values of new_references into another variable.
       l_person_type_w_other := new_references.person_type_code;
       l_person_id_w_other := new_references.person_id;
       l_person_end_date_other:= new_references.end_date;  -- 4612440,4612692
       l_old_end_date := old_references.end_date;

        IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
                 l_label := 'igs.plsql.igs_pe_typ_instances_pkg.after_dml.'||p_action;
                 l_debug_str := 'Person Type Code : '||l_person_type_w_other ||'/'|| ' Person id : ' ||l_person_id_w_other || ' End Date ' ||'/' ||l_person_end_date_other;
                 fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
        END IF;

    -- cursor when action is Insert/Update
    OPEN get_usr_id_cur(l_person_id_w_other);
    FETCH get_usr_id_cur INTO l_usr_id;
    CLOSE get_usr_id_cur;


    OPEN person_type_cur(new_references.person_type_code);
    FETCH person_type_cur INTO l_system_type;
    CLOSE person_type_cur;
    -- raise the event only if the person is associated with fnd user.
    -- raise the event for update only if this person has NO other person type instances
    -- through which he can get the same set of RESP.
    IF (p_action = 'INSERT') THEN

      After_Insert_Update;
      after_insertupdate2;

      -- The Business event should be raised only if end date is greater than current date
         IF l_usr_id IS NOT NULL AND (NVL(l_person_end_date_other,SYSDATE+1) > SYSDATE)THEN
            igs_pe_gen_003.RAISE_PERSON_TYPE_EVENT(l_person_id_w_other, l_person_type_w_other, p_action, l_person_end_date_other);
         END IF;

    ELSIF (p_action = 'UPDATE') THEN

      -- Call all the procedures related to After Update.
         After_Insert_Update;

      -- Business event should be raised is old and new end dates are different
	 IF l_usr_id IS NOT NULL AND (NVL(l_old_end_date,l_default_date) <> NVL(l_person_end_date_other,l_default_date)) THEN


	    OPEN get_active_inst_cur(new_references.person_id , l_system_type,l_rowid);
            FETCH get_active_inst_cur INTO l_max_active_date;
	    CLOSE get_active_inst_cur;

	     --if setting end date of person type to NULL, then dont bother, just raise the event.
             --else raise the event only if no other end date person type instance for same person type exists and
             --the end date is greated than the Max end date of other records
	    IF l_person_end_date_other IS NULL THEN
	       igs_pe_gen_003.RAISE_PERSON_TYPE_EVENT(new_references.person_id , new_references.person_type_code, p_action, l_person_end_date_other);
	    ELSE
	      IF l_max_active_date IS NULL OR l_max_active_date < l_person_end_date_other THEN
                 -- This case is specifically for Import process where start/end date can be less
                 -- current date. So if end date is passed as less than the current date then pass it as current date

                 IF l_person_end_date_other < SYSDATE THEN
                   l_person_end_date_other := TRUNC(SYSDATE);
                 END IF;
	         igs_pe_gen_003.RAISE_PERSON_TYPE_EVENT(new_references.person_id , new_references.person_type_code, p_action, l_person_end_date_other);
	      END IF;
	    END IF;


         END IF;
    ELSIF (p_action = 'DELETE') THEN
      --Call all the procedures related to After Delete.
      -- cursor when action is Delete
        OPEN get_usr_id_cur(old_references.person_id);
        FETCH get_usr_id_cur INTO l_usr_d_id;
        CLOSE get_usr_id_cur;

         IF l_usr_d_id IS NOT NULL THEN
           igs_pe_gen_003.RAISE_PERSON_TYPE_EVENT(old_references.person_id, old_references.person_type_code, p_action);
         END IF;
    END IF;
  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_PERSON_ID IN NUMBER,
       x_COURSE_CD IN VARCHAR2,
       x_TYPE_INSTANCE_ID IN OUT NOCOPY NUMBER,
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_CC_VERSION_NUMBER IN NUMBER,
       x_FUNNEL_STATUS IN VARCHAR2,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_NCC_VERSION_NUMBER IN NUMBER,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_CREATE_METHOD IN VARCHAR2,
       x_ENDED_BY IN NUMBER,
       x_END_METHOD IN VARCHAR2,
      X_MODE in VARCHAR2  ,
      X_ORG_ID in NUMBER ,
      X_EMPLMNT_CATEGORY_CODE IN VARCHAR2
  )
AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_PE_TYP_INSTANCES_ALL
             where  TYPE_INSTANCE_ID= X_TYPE_INSTANCE_ID;
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

        select IGS_PE_TYPE_INSTANCES_S.NEXTVAL INTO x_type_instance_id FROM DUAL;
   Before_DML(
                p_action=>'INSERT',
                x_rowid=>X_ROWID,
               x_person_id=>X_PERSON_ID,
               x_course_cd=>X_COURSE_CD,
               x_type_instance_id=>X_TYPE_INSTANCE_ID,
               x_person_type_code=>X_PERSON_TYPE_CODE,
               x_cc_version_number=>X_CC_VERSION_NUMBER,
               x_funnel_status=>X_FUNNEL_STATUS,
               x_admission_appl_number=>X_ADMISSION_APPL_NUMBER,
               x_nominated_course_cd=>X_NOMINATED_COURSE_CD,
               x_ncc_version_number=>X_NCC_VERSION_NUMBER,
               x_sequence_number=>X_SEQUENCE_NUMBER,
               x_start_date=>X_START_DATE,
               x_end_date=>X_END_DATE,
               x_create_method=>X_CREATE_METHOD,
               x_ended_by=>X_ENDED_BY,
               x_end_method=>X_END_METHOD,
               x_creation_date=>X_LAST_UPDATE_DATE,
               x_created_by=>X_LAST_UPDATED_BY,
               x_last_update_date=>X_LAST_UPDATE_DATE,
               x_last_updated_by=>X_LAST_UPDATED_BY,
               x_last_update_login=>X_LAST_UPDATE_LOGIN,
               x_org_id=>igs_ge_gen_003.get_org_id,
               x_emplmnt_category_code => x_emplmnt_category_code
           );
      IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_PE_TYP_INSTANCES_ALL (
                PERSON_ID
                ,COURSE_CD
                ,TYPE_INSTANCE_ID
                ,PERSON_TYPE_CODE
                ,CC_VERSION_NUMBER
                ,FUNNEL_STATUS
                ,ADMISSION_APPL_NUMBER
                ,NOMINATED_COURSE_CD
                ,NCC_VERSION_NUMBER
                ,SEQUENCE_NUMBER
                ,START_DATE
                ,END_DATE
                ,CREATE_METHOD
                ,ENDED_BY
                ,END_METHOD
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN
                ,ORG_ID
                ,EMPLMNT_CATEGORY_CODE
        ) values  (
                NEW_REFERENCES.PERSON_ID
                ,NEW_REFERENCES.COURSE_CD
                ,NEW_REFERENCES.TYPE_INSTANCE_ID
                ,NEW_REFERENCES.PERSON_TYPE_CODE
                ,NEW_REFERENCES.CC_VERSION_NUMBER
                ,NEW_REFERENCES.FUNNEL_STATUS
                ,NEW_REFERENCES.ADMISSION_APPL_NUMBER
                ,NEW_REFERENCES.NOMINATED_COURSE_CD
                ,NEW_REFERENCES.NCC_VERSION_NUMBER
                ,NEW_REFERENCES.SEQUENCE_NUMBER
                ,NEW_REFERENCES.START_DATE
                ,NEW_REFERENCES.END_DATE
                ,NEW_REFERENCES.CREATE_METHOD
                ,NEW_REFERENCES.ENDED_BY
                ,NEW_REFERENCES.END_METHOD
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_LOGIN
                ,NEW_REFERENCES.ORG_ID
                ,NEW_REFERENCES.EMPLMNT_CATEGORY_CODE
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
       x_PERSON_ID IN NUMBER,
       x_COURSE_CD IN VARCHAR2,
       x_TYPE_INSTANCE_ID IN NUMBER,
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_CC_VERSION_NUMBER IN NUMBER,
       x_FUNNEL_STATUS IN VARCHAR2,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_NCC_VERSION_NUMBER IN NUMBER,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_CREATE_METHOD IN VARCHAR2,
       x_ENDED_BY IN NUMBER,
       x_END_METHOD IN VARCHAR2,
       X_EMPLMNT_CATEGORY_CODE IN VARCHAR2
    )
AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      PERSON_ID
,      COURSE_CD
,      PERSON_TYPE_CODE
,      CC_VERSION_NUMBER
,      FUNNEL_STATUS
,      ADMISSION_APPL_NUMBER
,      NOMINATED_COURSE_CD
,      NCC_VERSION_NUMBER
,      SEQUENCE_NUMBER
,      START_DATE
,      END_DATE
,      CREATE_METHOD
,      ENDED_BY
,      END_METHOD
,      EMPLMNT_CATEGORY_CODE
    from IGS_PE_TYP_INSTANCES_ALL
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
if ( (  (tlinfo.PERSON_ID <> X_PERSON_ID)
            OR ((tlinfo.PERSON_ID is null)
                AND (X_PERSON_ID is null)))
  AND ((tlinfo.COURSE_CD <> X_COURSE_CD)
            OR ((tlinfo.COURSE_CD is null)
                AND (X_COURSE_CD is null)))
  AND ((tlinfo.PERSON_TYPE_CODE <> X_PERSON_TYPE_CODE)
            OR ((tlinfo.PERSON_TYPE_CODE is null)
                AND (X_PERSON_TYPE_CODE is null)))
  AND ((tlinfo.CC_VERSION_NUMBER <> X_CC_VERSION_NUMBER)
            OR ((tlinfo.CC_VERSION_NUMBER is null)
                AND (X_CC_VERSION_NUMBER is null)))
  AND ((tlinfo.FUNNEL_STATUS <> X_FUNNEL_STATUS)
            OR ((tlinfo.FUNNEL_STATUS is null)
                AND (X_FUNNEL_STATUS is null)))
  AND ((tlinfo.ADMISSION_APPL_NUMBER <> X_ADMISSION_APPL_NUMBER)
            OR ((tlinfo.ADMISSION_APPL_NUMBER is null)
                AND (X_ADMISSION_APPL_NUMBER is null)))
  AND ((tlinfo.NOMINATED_COURSE_CD <> X_NOMINATED_COURSE_CD)
            OR ((tlinfo.NOMINATED_COURSE_CD is null)
                AND (X_NOMINATED_COURSE_CD is null)))
  AND ((tlinfo.NCC_VERSION_NUMBER <> X_NCC_VERSION_NUMBER)
            OR ((tlinfo.NCC_VERSION_NUMBER is null)
                AND (X_NCC_VERSION_NUMBER is null)))
  AND ((tlinfo.SEQUENCE_NUMBER <> X_SEQUENCE_NUMBER)
            OR ((tlinfo.SEQUENCE_NUMBER is null)
                AND (X_SEQUENCE_NUMBER is null)))
  AND ((tlinfo.START_DATE <> X_START_DATE)
            OR ((tlinfo.START_DATE is null)
                AND (X_START_DATE is null)))
  AND ((tlinfo.END_DATE <> X_END_DATE)
            OR ((tlinfo.END_DATE is null)
                AND (X_END_DATE is null)))
  AND ((tlinfo.CREATE_METHOD <> X_CREATE_METHOD)
            OR ((tlinfo.CREATE_METHOD is null)
                AND (X_CREATE_METHOD is null)))
  AND ((tlinfo.ENDED_BY <> X_ENDED_BY)
            OR ((tlinfo.ENDED_BY is null)
                AND (X_ENDED_BY is null)))
  AND ((tlinfo.END_METHOD <> X_END_METHOD)
            OR ((tlinfo.END_METHOD is null)
                AND (X_END_METHOD is null)))
  AND ((tlinfo.EMPLMNT_CATEGORY_CODE <> X_EMPLMNT_CATEGORY_CODE)
            OR ((tlinfo.EMPLMNT_CATEGORY_CODE is null)
                AND (X_EMPLMNT_CATEGORY_CODE is null)))
  ) then
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  else
      null;
  end if;
  return;
end LOCK_ROW;

 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_PERSON_ID IN NUMBER,
       x_COURSE_CD IN VARCHAR2,
       x_TYPE_INSTANCE_ID IN NUMBER,
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_CC_VERSION_NUMBER IN NUMBER,
       x_FUNNEL_STATUS IN VARCHAR2,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_NCC_VERSION_NUMBER IN NUMBER,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_CREATE_METHOD IN VARCHAR2,
       x_ENDED_BY IN NUMBER,
       x_END_METHOD IN VARCHAR2,
       X_MODE in VARCHAR2 ,
       X_EMPLMNT_CATEGORY_CODE IN VARCHAR2
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
               x_person_id=>X_PERSON_ID,
               x_course_cd=>X_COURSE_CD,
               x_type_instance_id=>X_TYPE_INSTANCE_ID,
               x_person_type_code=>X_PERSON_TYPE_CODE,
               x_cc_version_number=>X_CC_VERSION_NUMBER,
               x_funnel_status=>X_FUNNEL_STATUS,
               x_admission_appl_number=>X_ADMISSION_APPL_NUMBER,
               x_nominated_course_cd=>X_NOMINATED_COURSE_CD,
               x_ncc_version_number=>X_NCC_VERSION_NUMBER,
               x_sequence_number=>X_SEQUENCE_NUMBER,
               x_start_date=>X_START_DATE,
               x_end_date=>X_END_DATE,
               x_create_method=>X_CREATE_METHOD,
               x_ended_by=>X_ENDED_BY,
               x_end_method=>X_END_METHOD,
               x_creation_date=>X_LAST_UPDATE_DATE,
               x_created_by=>X_LAST_UPDATED_BY,
               x_last_update_date=>X_LAST_UPDATE_DATE,
               x_last_updated_by=>X_LAST_UPDATED_BY,
               x_last_update_login=>X_LAST_UPDATE_LOGIN,
               x_emplmnt_category_code => X_EMPLMNT_CATEGORY_CODE
           );
    IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 update IGS_PE_TYP_INSTANCES_ALL set
      PERSON_ID =  NEW_REFERENCES.PERSON_ID,
      COURSE_CD =  NEW_REFERENCES.COURSE_CD,
      PERSON_TYPE_CODE =  NEW_REFERENCES.PERSON_TYPE_CODE,
      CC_VERSION_NUMBER =  NEW_REFERENCES.CC_VERSION_NUMBER,
      FUNNEL_STATUS =  NEW_REFERENCES.FUNNEL_STATUS,
      ADMISSION_APPL_NUMBER =  NEW_REFERENCES.ADMISSION_APPL_NUMBER,
      NOMINATED_COURSE_CD =  NEW_REFERENCES.NOMINATED_COURSE_CD,
      NCC_VERSION_NUMBER =  NEW_REFERENCES.NCC_VERSION_NUMBER,
      SEQUENCE_NUMBER =  NEW_REFERENCES.SEQUENCE_NUMBER,
      START_DATE =  NEW_REFERENCES.START_DATE,
      END_DATE =  NEW_REFERENCES.END_DATE,
      CREATE_METHOD =  NEW_REFERENCES.CREATE_METHOD,
      ENDED_BY =  NEW_REFERENCES.ENDED_BY,
      END_METHOD =  NEW_REFERENCES.END_METHOD,
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY = X_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
        EMPLMNT_CATEGORY_CODE = X_EMPLMNT_CATEGORY_CODE
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
       x_PERSON_ID IN NUMBER,
       x_COURSE_CD IN VARCHAR2,
       x_TYPE_INSTANCE_ID IN OUT NOCOPY NUMBER,
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_CC_VERSION_NUMBER IN NUMBER,
       x_FUNNEL_STATUS IN VARCHAR2,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_NCC_VERSION_NUMBER IN NUMBER,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_CREATE_METHOD IN VARCHAR2,
       x_ENDED_BY IN NUMBER,
       x_END_METHOD IN VARCHAR2,
      X_MODE in VARCHAR2 ,
      X_ORG_ID in NUMBER,
      X_EMPLMNT_CATEGORY_CODE IN VARCHAR2
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

    cursor c1 is select ROWID from IGS_PE_TYP_INSTANCES_ALL
             where     TYPE_INSTANCE_ID= X_TYPE_INSTANCE_ID
;
begin
        open c1;
                fetch c1 into X_ROWID;
        if (c1%notfound) then
        close c1;
    INSERT_ROW (
      X_ROWID,
       X_PERSON_ID,
       X_COURSE_CD,
       X_TYPE_INSTANCE_ID,
       X_PERSON_TYPE_CODE,
       X_CC_VERSION_NUMBER,
       X_FUNNEL_STATUS,
       X_ADMISSION_APPL_NUMBER,
       X_NOMINATED_COURSE_CD,
       X_NCC_VERSION_NUMBER,
       X_SEQUENCE_NUMBER,
       X_START_DATE,
       X_END_DATE,
       X_CREATE_METHOD,
       X_ENDED_BY,
       X_END_METHOD,
      X_MODE,
      X_ORG_ID,
      X_EMPLMNT_CATEGORY_CODE);
     return;
        end if;
           close c1;
UPDATE_ROW (
      X_ROWID,
       X_PERSON_ID,
       X_COURSE_CD,
       X_TYPE_INSTANCE_ID,
       X_PERSON_TYPE_CODE,
       X_CC_VERSION_NUMBER,
       X_FUNNEL_STATUS,
       X_ADMISSION_APPL_NUMBER,
       X_NOMINATED_COURSE_CD,
       X_NCC_VERSION_NUMBER,
       X_SEQUENCE_NUMBER,
       X_START_DATE,
       X_END_DATE,
       X_CREATE_METHOD,
       X_ENDED_BY,
       X_END_METHOD,
      X_MODE,
      X_EMPLMNT_CATEGORY_CODE);
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
 delete from IGS_PE_TYP_INSTANCES_ALL
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
END igs_pe_typ_instances_pkg;

/
