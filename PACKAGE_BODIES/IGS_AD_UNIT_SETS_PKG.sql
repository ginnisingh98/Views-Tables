--------------------------------------------------------
--  DDL for Package Body IGS_AD_UNIT_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_UNIT_SETS_PKG" AS
/* $Header: IGSAI98B.pls 120.3 2006/05/30 11:42:19 pbondugu ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_unit_sets%RowType;
  new_references igs_ad_unit_sets%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_set_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_rank IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
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
      FROM     IGS_AD_UNIT_SETS
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
    new_references.unit_set_id := x_unit_set_id;
    new_references.person_id := x_person_id;
    new_references.admission_appl_number := x_admission_appl_number;
    new_references.nominated_course_cd := x_nominated_course_cd;
    new_references.sequence_number := x_sequence_number;
    new_references.unit_set_cd := x_unit_set_cd;
    new_references.version_number := x_version_number;
    new_references.rank := x_rank;
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
    Column_Value IN VARCHAR2  DEFAULT NULL
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
    IF column_name IS NULL THEN
      NULL;
    ELSIF  UPPER(column_name) = 'RANK'  THEN
      new_references.rank := IGS_GE_NUMBER.TO_NUM(column_value);
      NULL;
    END IF;

    -- The following code checks for check constraints on the Columns.
    IF Upper(Column_Name) = 'RANK' OR
      Column_Name IS NULL THEN
      IF NOT (new_references.rank > 0)  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_SS_DSRD_RANK_NONEGATE'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
    END IF;
  END Check_Constraints;

  PROCEDURE Check_Uniqueness AS
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
    IF Get_Uk_For_Validation (
    	new_references.sequence_number
    	,new_references.unit_set_cd
    	,new_references.version_number
    	,new_references.admission_appl_number
    	,new_references.nominated_course_cd
    	,new_references.person_id
    	) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    END IF;
  END Check_Uniqueness ;

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
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PROGRAM_APPL'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.unit_set_cd = new_references.unit_set_cd) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.unit_set_cd IS NULL) OR
         (new_references.version_number IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_En_Unit_Set_Pkg.Get_PK_For_Validation (
       		new_references.unit_set_cd,
       		new_references.version_number
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_PS_UNIT_SET'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_unit_set_id IN NUMBER
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
      FROM     igs_ad_unit_sets
      WHERE    unit_set_id = x_unit_set_id
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
    x_sequence_number IN NUMBER,
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_person_id IN NUMBER
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
      FROM     igs_ad_unit_sets
      WHERE    sequence_number = x_sequence_number
      AND      unit_set_cd = x_unit_set_cd
      AND      version_number = x_version_number
      AND      admission_appl_number = x_admission_appl_number
      AND      nominated_course_cd = x_nominated_course_cd
      AND      person_id = x_person_id 	and      ((l_rowid is null) or (rowid <> l_rowid))

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
      FROM     igs_ad_unit_sets
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
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AUTS_ACAI_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Ps_Appl_Inst;

  PROCEDURE Get_FK_Igs_En_Unit_Set (
    x_unit_set_cd IN VARCHAR2,
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
      FROM     igs_ad_unit_sets
      WHERE    unit_set_cd = x_unit_set_cd
      AND      version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AUTS_EUS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_En_Unit_Set;
 -- begin oxford unit set code bug 5194658
  PROCEDURE GET_FK_IGS_PS_OFR_UNIT_SET (
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_course_cd VARCHAR2,
    x_crv_version_number NUMBER,
    x_acad_cal_type VARCHAR2
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
     SELECT   aus.rowid
      FROM     igs_ad_unit_sets aus, igs_ad_appl_all apl, igs_ad_ps_appl_inst_all inst
      WHERE    aus.person_id             = apl.person_id
      AND      aus.admission_appl_number = apl.admission_appl_number
      AND      aus.person_id             = inst.person_id
      AND      aus.admission_appl_number = inst.admission_appl_number
      AND      aus.nominated_course_cd   = inst.nominated_course_cd
      AND      aus.sequence_number       = inst.sequence_number
      AND      aus.unit_set_cd           = x_unit_set_cd
      AND      aus.version_number        = x_version_number
      AND      aus.nominated_course_cd   = x_course_cd
      AND      inst.crv_version_number   = x_crv_version_number
      AND      apl.acad_cal_type         = x_acad_cal_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AUTS_EUS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_OFR_UNIT_SET;
 -- end oxford unit set code bug 5194658

FUNCTION Validate_Unit_Set(p_version_number      igs_ad_unit_sets.version_number%TYPE
                          ,p_unit_set_cd         igs_ad_unit_sets.unit_set_cd%TYPE
                          ,p_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE
                          ,p_crv_version_number  igs_ad_ps_appl_inst_all.crv_version_number%TYPE
                          ,p_admission_cat       igs_ad_appl_all.admission_cat%TYPE
                          ,p_acad_cal_type       igs_ad_appl_all.acad_cal_type%TYPE
                          ,p_location_cd         igs_ad_ps_appl_inst_all.location_cd%TYPE
                          ,p_attendance_mode     igs_ad_ps_appl_inst_all.attendance_mode%TYPE
                          ,p_attendance_type     igs_ad_ps_appl_inst_all.attendance_type%TYPE)
RETURN BOOLEAN
IS
CURSOR cur_unit_sets IS
SELECT  '1'
FROM    IGS_PS_OFR_OPT_UNIT_SET_V psusv
WHERE   psusv.unit_set_cd       = p_unit_set_cd         -- extra condition,  when compared to unit set lov query on IGSAD097.pld, IGSAD046.pld
   AND psusv.us_version_number  = p_version_number      -- extra condition,  when compared to unit set lov query on IGSAD097.pld, IGSAD046.pld
   AND psusv.course_cd          =     p_nominated_course_cd
   AND psusv.crv_version_number =     p_crv_version_number
   AND psusv.cal_type           =     p_acad_cal_type
   AND psusv.location_cd        =  NVL(p_location_cd ,    psusv.location_cd)
   AND psusv.attendance_mode    =  NVL(p_attendance_mode, psusv.attendance_mode)
   AND psusv.attendance_type    =  NVL(p_attendance_type, psusv.attendance_type)
   AND NOT EXISTS
   (SELECT 1
   FROM    igs_ps_coo_ad_unit_s psus
   WHERE   psus.course_cd              = psusv.course_cd
           AND psus.crv_version_number = psusv.crv_version_number
           AND psus.cal_type           = psusv.cal_type
           AND psus.location_cd        = psusv.location_cd
           AND psus.attendance_mode    = psusv.attendance_mode
           AND psus.attendance_type    = psusv.attendance_type
           AND psus.admission_cat      = p_admission_cat
   )
   AND psusv.UNIT_SET_STATUS IN
   (SELECT unit_set_status
   FROM    igs_en_unit_set_stat uss
   WHERE   psusv.unit_set_status       = uss.unit_set_status
           AND uss.s_unit_set_status <> 'INACTIVE'
   )
   AND psusv.unit_set_cat IN
   (SELECT usc.unit_set_cat
   FROM    igs_en_unit_set_cat usc
   WHERE   ((fnd_profile.value ('IGS_PS_PRENRL_YEAR_IND') <> 'Y'
           OR usc.s_unit_set_cat = 'PRENRL_YR'))
   )
   AND psusv.expiry_dt IS NULL
UNION
SELECT  '1'
FROM    igs_ps_coo_ad_unit_s psus,
   igs_en_unit_set us
WHERE  psus.unit_set_cd       = p_unit_set_cd         -- extra condition,  when compared to unit set lov query on IGSAD097.pld, IGSAD046.pld
   AND psus.us_version_number = p_version_number      -- extra condition,  when compared to unit set lov query on IGSAD097.pld, IGSAD046.pld
   AND us.unit_set_cd          = psus.unit_set_cd
   AND us.version_number       = psus.us_version_number
   AND psus.course_cd          = p_nominated_course_cd
   AND psus.crv_version_number = p_crv_version_number
   AND psus.cal_type           = p_acad_cal_type
   AND psus.location_cd        = nvl(p_location_cd ,     psus.location_cd)
   AND psus.attendance_mode    = nvl(p_attendance_mode,  psus.attendance_mode)
   AND psus.attendance_type    = nvl(p_attendance_type , psus.attendance_type)
   AND psus.admission_cat      = p_admission_cat
   AND us.unit_set_status     IN
   (SELECT unit_set_status
   FROM    igs_en_unit_set_stat uss
   WHERE   us.unit_set_status         = uss.unit_set_status
           AND uss.s_unit_set_status <> 'INACTIVE'
   )
   AND us.unit_set_cat IN
   (SELECT usc.unit_set_cat
   FROM    igs_en_unit_set_cat usc
   WHERE   ((fnd_profile.value ('IGS_PS_PRENRL_YEAR_IND') <> 'Y'
           OR usc.s_unit_set_cat = 'PRENRL_YR'))
   )
   AND us.expiry_dt IS NULL;

   l_var VARCHAR2(1);
BEGIN

    OPEN cur_unit_sets;
    FETCH cur_unit_sets INTO l_var;
    IF cur_unit_sets%NOTFOUND THEN
       CLOSE cur_unit_sets;
       RETURN FALSE;
    END IF;
    CLOSE cur_unit_sets;
    RETURN TRUE;
END;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_set_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_rank IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
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
        CURSOR c_appl IS
	SELECT  appinsti.crv_version_number
		,apli.admission_cat
		,apli.acad_cal_type
		,appinsti.attendance_type
		,appinsti.attendance_mode
		,appinsti.location_cd
	FROM  igs_ad_appl_all apli
	      ,igs_ad_ps_appl_inst_all appinsti
	WHERE  appinsti.person_id = x_person_id
               AND appinsti.nominated_course_cd =x_nominated_course_cd
               AND appinsti.admission_appl_number= x_admission_appl_number
               AND appinsti.sequence_number = x_sequence_number
               AND apli.person_id =  appinsti.person_id
               AND apli.admission_appl_number = appinsti.admission_appl_number;
  	c_appl_rec  c_appl%ROWTYPE;





  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_unit_set_id,
      x_person_id,
      x_admission_appl_number,
      x_nominated_course_cd,
      x_sequence_number,
      x_unit_set_cd,
      x_version_number,
      x_rank,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    igs_ad_gen_002.check_adm_appl_inst_stat(
      nvl(x_person_id,old_references.person_id),
      nvl(x_admission_appl_number,old_references.admission_appl_number),
      nvl(x_nominated_course_cd,old_references.nominated_course_cd),
      nvl(x_sequence_number,old_references.sequence_number)
      );

    OPEN c_appl;
    FETCH c_appl  INTO c_appl_rec;
    CLOSE c_appl;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
     IF Get_Pk_For_Validation(
	new_references.unit_set_id)  THEN
        Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
     END IF;

     IF NOT Validate_Unit_Set(
         new_references.version_number
	,new_references.unit_set_cd
        ,new_references.nominated_course_cd
        ,c_appl_rec.crv_version_number
        ,c_appl_rec.admission_cat
        ,c_appl_rec.acad_cal_type
        ,c_appl_rec.location_cd
        ,c_appl_rec.attendance_mode
        ,c_appl_rec.attendance_type
        )  THEN
        Fnd_Message.Set_name('IGS','IGS_AD_PRGOFOP_NOT_VALID');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
     END IF;

      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
     IF NOT Validate_Unit_Set(
         new_references.version_number
	,new_references.unit_set_cd
        ,new_references.nominated_course_cd
        ,c_appl_rec.crv_version_number
        ,c_appl_rec.admission_cat
        ,c_appl_rec.acad_cal_type
        ,c_appl_rec.location_cd
        ,c_appl_rec.attendance_mode
        ,c_appl_rec.attendance_type
        )  THEN
        Fnd_Message.Set_name('IGS','IGS_AD_PRGOFOP_NOT_VALID');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
     END IF;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.unit_set_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;

      Check_Uniqueness;
      Check_Constraints;

    ELSIF (p_action = 'VALIDATE_UPDATE') THEN

      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Null;
    END IF;
    l_rowid := NULL; --Bug:2863832
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

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SET_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_UNIT_SET_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_RANK IN NUMBER,
      X_MODE in VARCHAR2
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

    cursor C is select ROWID from IGS_AD_UNIT_SETS
             where                 UNIT_SET_ID= X_UNIT_SET_ID
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

   X_UNIT_SET_ID := -1;
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_unit_set_id=>X_UNIT_SET_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_admission_appl_number=>X_ADMISSION_APPL_NUMBER,
 	       x_nominated_course_cd=>X_NOMINATED_COURSE_CD,
 	       x_sequence_number=>X_SEQUENCE_NUMBER,
 	       x_unit_set_cd=>X_UNIT_SET_CD,
 	       x_version_number=>X_VERSION_NUMBER,
 	       x_rank=>X_RANK,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_AD_UNIT_SETS (
		UNIT_SET_ID
		,PERSON_ID
		,ADMISSION_APPL_NUMBER
		,NOMINATED_COURSE_CD
		,SEQUENCE_NUMBER
		,UNIT_SET_CD
		,VERSION_NUMBER
		,RANK
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,REQUEST_ID
		,PROGRAM_ID
		,PROGRAM_APPLICATION_ID
		,PROGRAM_UPDATE_DATE
        ) values  (
	         IGS_AD_UNIT_SETS_S.NEXTVAL
	        ,NEW_REFERENCES.PERSON_ID
	        ,NEW_REFERENCES.ADMISSION_APPL_NUMBER
	        ,NEW_REFERENCES.NOMINATED_COURSE_CD
	        ,NEW_REFERENCES.SEQUENCE_NUMBER
	        ,NEW_REFERENCES.UNIT_SET_CD
	        ,NEW_REFERENCES.VERSION_NUMBER
	        ,NEW_REFERENCES.RANK
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
		,X_REQUEST_ID
		,X_PROGRAM_ID
		,X_PROGRAM_APPLICATION_ID
		,X_PROGRAM_UPDATE_DATE
)RETURNING UNIT_SET_ID INTO X_UNIT_SET_ID;
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
end INSERT_ROW;
 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_SET_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_UNIT_SET_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_RANK IN NUMBER  ) AS
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
,      ADMISSION_APPL_NUMBER
,      NOMINATED_COURSE_CD
,      SEQUENCE_NUMBER
,      UNIT_SET_CD
,      VERSION_NUMBER
,      RANK
    from IGS_AD_UNIT_SETS
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
if ( (  tlinfo.PERSON_ID = X_PERSON_ID)
  AND (tlinfo.ADMISSION_APPL_NUMBER = X_ADMISSION_APPL_NUMBER)
  AND (tlinfo.NOMINATED_COURSE_CD = X_NOMINATED_COURSE_CD)
  AND (tlinfo.SEQUENCE_NUMBER = X_SEQUENCE_NUMBER)
  AND (tlinfo.UNIT_SET_CD = X_UNIT_SET_CD)
  AND (tlinfo.VERSION_NUMBER = X_VERSION_NUMBER)
  AND (tlinfo.RANK = X_RANK)
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
       x_UNIT_SET_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_UNIT_SET_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_RANK IN NUMBER,
      X_MODE in VARCHAR2
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
 	       x_unit_set_id=>X_UNIT_SET_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_admission_appl_number=>X_ADMISSION_APPL_NUMBER,
 	       x_nominated_course_cd=>X_NOMINATED_COURSE_CD,
 	       x_sequence_number=>X_SEQUENCE_NUMBER,
 	       x_unit_set_cd=>X_UNIT_SET_CD,
 	       x_version_number=>X_VERSION_NUMBER,
 	       x_rank=>X_RANK,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);

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
 update IGS_AD_UNIT_SETS set
      PERSON_ID =  NEW_REFERENCES.PERSON_ID,
      ADMISSION_APPL_NUMBER =  NEW_REFERENCES.ADMISSION_APPL_NUMBER,
      NOMINATED_COURSE_CD =  NEW_REFERENCES.NOMINATED_COURSE_CD,
      SEQUENCE_NUMBER =  NEW_REFERENCES.SEQUENCE_NUMBER,
      UNIT_SET_CD =  NEW_REFERENCES.UNIT_SET_CD,
      VERSION_NUMBER =  NEW_REFERENCES.VERSION_NUMBER,
      RANK =  NEW_REFERENCES.RANK,
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
,	REQUEST_ID = X_REQUEST_ID,
	PROGRAM_ID = X_PROGRAM_ID,
	PROGRAM_APPLICATION_ID = PROGRAM_APPLICATION_ID,
	PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
	  where ROWID = X_ROWID;
	if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     IF (x_mode = 'S') THEN
       igs_sc_gen_001.unset_ctx('R');
     END IF;
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
end UPDATE_ROW;
 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SET_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_UNIT_SET_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_RANK IN NUMBER,
      X_MODE in VARCHAR2
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

    cursor c1 is select ROWID from IGS_AD_UNIT_SETS
             where     UNIT_SET_ID= X_UNIT_SET_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_UNIT_SET_ID,
       X_PERSON_ID,
       X_ADMISSION_APPL_NUMBER,
       X_NOMINATED_COURSE_CD,
       X_SEQUENCE_NUMBER,
       X_UNIT_SET_CD,
       X_VERSION_NUMBER,
       X_RANK,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_UNIT_SET_ID,
       X_PERSON_ID,
       X_ADMISSION_APPL_NUMBER,
       X_NOMINATED_COURSE_CD,
       X_SEQUENCE_NUMBER,
       X_UNIT_SET_CD,
       X_VERSION_NUMBER,
       X_RANK,
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
  ravishar      5/30/2005        Security related changes

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
 delete from IGS_AD_UNIT_SETS
 where ROWID = X_ROWID;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     IF (x_mode = 'S') THEN
        igs_sc_gen_001.unset_ctx('R');
     END IF;
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
 END IF;

After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
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
end DELETE_ROW;

END igs_ad_unit_sets_pkg;

/
