--------------------------------------------------------
--  DDL for Package Body IGS_EN_SPA_AWD_AIM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_SPA_AWD_AIM_PKG" AS
/* $Header: IGSEI59B.pls 120.4 2006/06/29 10:41:27 shimitta ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_en_spa_awd_aim%ROWTYPE;
  new_references igs_en_spa_awd_aim%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER  ,
    x_course_cd                         IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_start_dt                          IN     DATE    ,
    x_end_dt                            IN     DATE    ,
    x_complete_ind                      IN     VARCHAR2,
    x_conferral_date			IN     DATE    ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER   ,
    x_award_mark                        IN     NUMBER,
    x_award_grade                       IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-NOV-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_en_spa_awd_aim
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
    new_references.person_id                         := x_person_id;
    new_references.course_cd                         := x_course_cd;
    new_references.award_cd                          := x_award_cd;
    new_references.start_dt                          := TRUNC(x_start_dt);  -- TRUNC added in the code by Nishikant - bug#2386592 - 24MAY2002.
    new_references.end_dt                            := TRUNC(x_end_dt);  -- TRUNC added in the code by Nishikant - bug#2386592 - 24MAY2002.
    new_references.complete_ind                      := x_complete_ind;
    new_references.conferral_date                    := TRUNC(x_conferral_date);

--ijeddy, Build 31229913
    new_references.award_mark                        := x_award_mark;
    new_references.award_grade                       := x_award_grade;
    new_references.grading_schema_cd                 := x_grading_schema_cd;
    new_references.gs_version_number                 := x_gs_version_number;

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

  -- anilk, 01-Oct-2003, Program Completion Validation build
  -- This local procedure inserts record into history table for spaa.
  PROCEDURE ins_spaa_hist AS
    l_rowid  VARCHAR2(25);
  BEGIN
     IF ( NVL(new_references.start_dt, igs_ge_date.igsdate('1900/01/01')) <> NVL(old_references.start_dt, igs_ge_date.igsdate('1900/01/01'))  OR
          NVL(new_references.end_dt,   igs_ge_date.igsdate('1900/01/01')) <> NVL(old_references.end_dt,   igs_ge_date.igsdate('1900/01/01'))  OR
          NVL(new_references.complete_ind,'NULL')        <> NVL(old_references.complete_ind, 'NULL')        OR
          NVL(new_references.conferral_date,igs_ge_date.igsdate('1900/01/01'))<> NVL(old_references.conferral_date, igs_ge_date.igsdate('1900/01/01'))OR
          NVL(new_references.award_mark,  99999)         <> NVL(old_references.award_mark, 99999)           OR
          NVL(new_references.award_grade, 'NULL')        <> NVL(old_references.award_grade,'NULL')          OR
          NVL(new_references.grading_schema_cd, 'NULL')  <> NVL(old_references.grading_schema_cd, 'NULL')   OR
          NVL(new_references.gs_version_number, 999)     <> NVL(old_references.gs_version_number, 999)    ) THEN
             igs_en_spaa_hist_pkg.insert_row (
                x_rowid                 =>  l_rowid,
                x_person_id             =>  old_references.person_id,
                x_course_cd             =>  old_references.course_cd,
                x_award_cd              =>  old_references.award_cd,
                x_start_date            =>  old_references.start_dt,
                x_end_date              =>  old_references.end_dt,
                x_complete_flag         =>  old_references.complete_ind,
                x_conferral_date        =>  old_references.conferral_date,
                x_award_mark            =>  old_references.award_mark,
                x_award_grade           =>  old_references.award_grade,
                x_grading_schema_cd     =>  old_references.grading_schema_cd,
                x_gs_version_number     =>  old_references.gs_version_number,
                x_mode                  =>  'R');
     END IF;
  END ins_spaa_hist;

  -- anilk, 01-Oct-2003, Program Completion Validation build
  -- This local procedure deletes records from history table for spaa.
  PROCEDURE del_spaa_hist(p_rowid IN VARCHAR2) AS
    l_rowid  VARCHAR2(25);
    CURSOR cur_spaah IS
    SELECT spaah.rowid
      FROM igs_en_spa_awd_aim spaa,
           igs_en_spaa_hist   spaah
     WHERE spaa.rowid = p_rowid AND
           spaa.person_id = spaah.person_id AND
           spaa.course_cd = spaah.course_cd AND
           spaa.award_cd  = spaah.award_cd;
  BEGIN
      FOR cur_spaah_rec IN cur_spaah LOOP
             igs_en_spaa_hist_pkg.delete_row(x_rowid => cur_spaah_rec.rowid);
      END LOOP;
  END del_spaa_hist;

  -- anilk, 01-Oct-2003, Program Completion Validation build
  PROCEDURE AfterRowInsertUpdate1(
                p_inserting IN BOOLEAN DEFAULT FALSE,
                p_updating IN BOOLEAN DEFAULT FALSE,
                p_deleting IN BOOLEAN DEFAULT FALSE
            ) AS
    v_message_name	VARCHAR2(30);
  BEGIN
	IF p_updating THEN
	       ins_spaa_hist;
	END IF;
  END AfterRowInsertUpdate1;

  PROCEDURE AfterRowInsertUpdate(     p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN,
    p_rowid IN VARCHAR2 DEFAULT NULL
   ) AS
   /*
  ||  Created By : shimitta
  ||  Created On : 27-JUN-2006
  ||  Purpose : Changing the person type depending on the conferral date as per bug# 2691653.
  ||  Change History :
  ||  Who             When            What
  */

     -- Cursor to fetch active Person Type Instance Record
      CURSOR cur_typ_id_inst(p_PERSON_ID NUMBER,p_COURSE_CD VARCHAR2,p_PERSON_TYPE_CODE VARCHAR2) IS
        SELECT pti.*
        FROM igs_pe_typ_instances_all  pti
        WHERE pti.PERSON_ID = p_PERSON_ID AND
              pti.COURSE_CD = p_COURSE_CD AND
              pti.PERSON_TYPE_CODE = p_PERSON_TYPE_CODE AND
              pti.END_DATE IS NULL;

      CURSOR cur_pers_type(p_system_type varchar2) IS
        SELECT PERSON_TYPE_CODE
        FROM igs_pe_person_types
        WHERE SYSTEM_TYPE = p_system_type AND
              CLOSED_IND = 'N';

      -- Cursor used to fetch the Person Type Instance record which is being opened
      -- irrespective of the system person type is closed or not.

      CURSOR cur_pe_typ_inst( p_person_id   igs_pe_typ_instances.PERSON_ID%TYPE,
                              p_course_cd   igs_pe_typ_instances.course_cd%TYPE,
                              p_system_type igs_pe_person_types.SYSTEM_TYPE%TYPE
			      ) IS
        SELECT pti.rowid row_id ,pti.*
        FROM  igs_pe_typ_instances_all pti,
              igs_pe_person_types  pty
        WHERE pti.person_id = p_person_id AND
              pti.course_cd = p_course_cd AND
              pti.end_date IS NULL AND
              pty.person_type_code = pti.person_type_code AND
              pty.system_type = p_system_type;

         --Cursor to fecth Person Type Instance record with end date not null
	CURSOR cur_per_typ_dt( p_person_id   igs_pe_typ_instances.PERSON_ID%TYPE,
                              p_course_cd   igs_pe_typ_instances.course_cd%TYPE,
                              p_system_type igs_pe_person_types.SYSTEM_TYPE%TYPE,
			      p_date DATE ) IS
        SELECT pti.rowid row_id ,pti.*
        FROM  igs_pe_typ_instances_all pti,
              igs_pe_person_types  pty
        WHERE pti.person_id = p_person_id AND
              pti.course_cd = p_course_cd AND
              pti.end_date = p_date AND
              pty.person_type_code = pti.person_type_code AND
              pty.system_type = p_system_type;



      CURSOR cur_conf_dt (p_rowid  VARCHAR2) IS
	SELECT *
	FROM IGS_EN_SPA_AWD_AIM
	WHERE ROWID = p_rowid ;

	cur_conf_dt_rec cur_conf_dt%ROWTYPE;
        cur_pe_typ_inst_rec cur_pe_typ_inst%ROWTYPE;
	cur_typ_id_inst_rec cur_typ_id_inst%ROWTYPE;
	cur_per_typ_dt_rec cur_per_typ_dt%ROWTYPE;
	l_person_type igs_pe_person_types.PERSON_TYPE_CODE%TYPE;
	l_method         igs_pe_typ_instances.CREATE_METHOD%TYPE;
	l_TYPE_INSTANCE_ID  igs_pe_typ_instances.TYPE_INSTANCE_ID%TYPE;
	l_rowid  VARCHAR2(25);
        l_date  DATE;



    BEGIN
    IF (new_references.conferral_date IS NOT NULL AND p_updating) THEN
	    l_person_type := NULL;
	    l_date := SYSDATE;
            l_method := 'PERSON_DEG_CONFER_PRG';

	     -- Select Person type Code for the System type GRADUATE
             OPEN cur_pers_type('GRADUATE');
             FETCH cur_pers_type INTO l_person_type;
             CLOSE cur_pers_type;
             IF l_person_type IS NULL THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_EN_PERSON_TYPE_NOT_DEF');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
             END IF;

             OPEN cur_typ_id_inst(new_references.PERSON_ID,new_references.COURSE_CD,l_person_type);
             FETCH cur_typ_id_inst INTO cur_typ_id_inst_rec;
             IF cur_typ_id_inst%NOTFOUND THEN
	        igs_pe_typ_instances_pkg.insert_row(
                                                X_ROWID  => l_ROWID,
                                                X_PERSON_ID => new_references.PERSON_ID,
                                                X_COURSE_CD => new_references.COURSE_CD,
                                                X_TYPE_INSTANCE_ID => l_TYPE_INSTANCE_ID,
                                                X_PERSON_TYPE_CODE => l_person_type,
                                                X_CC_VERSION_NUMBER => NULL,
                                                X_FUNNEL_STATUS => NULL,
                                                X_ADMISSION_APPL_NUMBER => NULL,
                                                X_NOMINATED_COURSE_CD => NULL,
                                                X_NCC_VERSION_NUMBER => NULL,
                                                X_SEQUENCE_NUMBER => NULL,
                                                X_START_DATE => new_references.conferral_date,
                                                X_END_DATE => NULL,
                                                X_CREATE_METHOD => l_method,
                                                X_ENDED_BY => NULL,
                                                X_END_METHOD => NULL,
                                                X_MODE => 'R',
                                                X_ORG_ID => NULL,
                                                X_EMPLMNT_CATEGORY_CODE => NULL
                                                );
	     END IF;
             CLOSE cur_typ_id_inst;

	     OPEN cur_pe_typ_inst( new_references.person_id,
                                   new_references.COURSE_CD,
                                   'GRADUATE');
             FETCH cur_pe_typ_inst INTO cur_pe_typ_inst_rec;
             IF cur_pe_typ_inst%FOUND THEN
	     l_date := cur_pe_typ_inst_rec.START_DATE;
	     igs_pe_typ_instances_pkg.update_row(
                  X_ROWID                 => cur_pe_typ_inst_rec.ROW_ID,
                  X_PERSON_ID             => cur_pe_typ_inst_rec.PERSON_ID,
                  X_COURSE_CD             => cur_pe_typ_inst_rec.COURSE_CD,
                  X_TYPE_INSTANCE_ID      => cur_pe_typ_inst_rec.TYPE_INSTANCE_ID,
                  X_PERSON_TYPE_CODE      => cur_pe_typ_inst_rec.PERSON_TYPE_CODE,
                  X_CC_VERSION_NUMBER     => cur_pe_typ_inst_rec.CC_VERSION_NUMBER,
                  X_FUNNEL_STATUS         => cur_pe_typ_inst_rec.FUNNEL_STATUS,
                  X_ADMISSION_APPL_NUMBER => cur_pe_typ_inst_rec.ADMISSION_APPL_NUMBER,
                  X_NOMINATED_COURSE_CD   => cur_pe_typ_inst_rec.NOMINATED_COURSE_CD,
                  X_NCC_VERSION_NUMBER    => cur_pe_typ_inst_rec.NCC_VERSION_NUMBER,
                  X_SEQUENCE_NUMBER       => cur_pe_typ_inst_rec.SEQUENCE_NUMBER,
                  X_START_DATE            => new_references.conferral_date,
                  X_END_DATE              => NULL,
                  X_CREATE_METHOD         => cur_pe_typ_inst_rec.CREATE_METHOD,
                  X_ENDED_BY              => NULL,
                  X_END_METHOD            => NULL,
                  X_MODE                  => 'R' ,
                  X_EMPLMNT_CATEGORY_CODE => cur_pe_typ_inst_rec.emplmnt_category_code);
             END IF;
	     CLOSE cur_pe_typ_inst;

	     l_person_type := NULL;
             -- Select Person type Code for the System type FORMER_STUDENT
             OPEN cur_pers_type('FORMER_STUDENT');
             FETCH cur_pers_type INTO l_person_type;
             CLOSE cur_pers_type;
             IF l_person_type IS NULL THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_EN_PERSON_TYPE_NOT_DEF');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
             END IF;

             -- Check any active record found for this student program, with System Person Type,FORMER_STUDENT
             OPEN cur_per_typ_dt( new_references.person_id,
                                   new_references.COURSE_CD,
                                   'FORMER_STUDENT',
				   l_date);
             FETCH cur_per_typ_dt INTO cur_per_typ_dt_rec;
             IF cur_per_typ_dt%FOUND THEN
	     igs_pe_typ_instances_pkg.update_row(
                  X_ROWID                 => cur_per_typ_dt_rec.ROW_ID,
                  X_PERSON_ID             => cur_per_typ_dt_rec.PERSON_ID,
                  X_COURSE_CD             => cur_per_typ_dt_rec.COURSE_CD,
                  X_TYPE_INSTANCE_ID      => cur_per_typ_dt_rec.TYPE_INSTANCE_ID,
                  X_PERSON_TYPE_CODE      => cur_per_typ_dt_rec.PERSON_TYPE_CODE,
                  X_CC_VERSION_NUMBER     => cur_per_typ_dt_rec.CC_VERSION_NUMBER,
                  X_FUNNEL_STATUS         => cur_per_typ_dt_rec.FUNNEL_STATUS,
                  X_ADMISSION_APPL_NUMBER => cur_per_typ_dt_rec.ADMISSION_APPL_NUMBER,
                  X_NOMINATED_COURSE_CD   => cur_per_typ_dt_rec.NOMINATED_COURSE_CD,
                  X_NCC_VERSION_NUMBER    => cur_per_typ_dt_rec.NCC_VERSION_NUMBER,
                  X_SEQUENCE_NUMBER       => cur_per_typ_dt_rec.SEQUENCE_NUMBER,
                  X_START_DATE            => cur_per_typ_dt_rec.START_DATE,
                  X_END_DATE              => new_references.conferral_date,
                  X_CREATE_METHOD         => cur_per_typ_dt_rec.CREATE_METHOD,
                  X_ENDED_BY              => cur_per_typ_dt_rec.ENDED_BY,
                  X_END_METHOD            => l_method,
                  X_MODE                  => 'R' ,
                  X_EMPLMNT_CATEGORY_CODE => cur_per_typ_dt_rec.emplmnt_category_code);
             END IF;
             CLOSE cur_per_typ_dt;

	     OPEN cur_pe_typ_inst( new_references.person_id,
                                   new_references.COURSE_CD,
                                   'FORMER_STUDENT');
             FETCH cur_pe_typ_inst INTO cur_pe_typ_inst_rec;
             IF cur_pe_typ_inst%FOUND THEN
	       igs_pe_typ_instances_pkg.update_row(
                  X_ROWID                 => cur_pe_typ_inst_rec.ROW_ID,
                  X_PERSON_ID             => cur_pe_typ_inst_rec.PERSON_ID,
                  X_COURSE_CD             => cur_pe_typ_inst_rec.COURSE_CD,
                  X_TYPE_INSTANCE_ID      => cur_pe_typ_inst_rec.TYPE_INSTANCE_ID,
                  X_PERSON_TYPE_CODE      => cur_pe_typ_inst_rec.PERSON_TYPE_CODE,
                  X_CC_VERSION_NUMBER     => cur_pe_typ_inst_rec.CC_VERSION_NUMBER,
                  X_FUNNEL_STATUS         => cur_pe_typ_inst_rec.FUNNEL_STATUS,
                  X_ADMISSION_APPL_NUMBER => cur_pe_typ_inst_rec.ADMISSION_APPL_NUMBER,
                  X_NOMINATED_COURSE_CD   => cur_pe_typ_inst_rec.NOMINATED_COURSE_CD,
                  X_NCC_VERSION_NUMBER    => cur_pe_typ_inst_rec.NCC_VERSION_NUMBER,
                  X_SEQUENCE_NUMBER       => cur_pe_typ_inst_rec.SEQUENCE_NUMBER,
                  X_START_DATE            => cur_pe_typ_inst_rec.START_DATE,
                  X_END_DATE              => new_references.conferral_date,
                  X_CREATE_METHOD         => cur_pe_typ_inst_rec.CREATE_METHOD,
                  X_ENDED_BY              => cur_pe_typ_inst_rec.ENDED_BY,
                  X_END_METHOD            => l_method,
                  X_MODE                  => 'R' ,
                  X_EMPLMNT_CATEGORY_CODE => cur_pe_typ_inst_rec.emplmnt_category_code);
             END IF;
             CLOSE cur_pe_typ_inst;

    ELSIF (new_references.conferral_date IS NULL AND p_updating) THEN
	     l_date := NULL;
             l_person_type := NULL;
	     l_method := 'PERSON_NO_ENROLL_PRG';

	     -- Select Person type Code for the System type GRADUATE
             OPEN cur_pers_type('GRADUATE');
             FETCH cur_pers_type INTO l_person_type;
             CLOSE cur_pers_type;
             IF l_person_type IS NULL THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_EN_PERSON_TYPE_NOT_DEF');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
             END IF;

             -- Check any active record found for this student program, with System Person Type,GRADUATE
             OPEN cur_pe_typ_inst( new_references.person_id,
                                   new_references.COURSE_CD,
                                   'GRADUATE');
             FETCH cur_pe_typ_inst INTO cur_pe_typ_inst_rec;
             IF cur_pe_typ_inst%FOUND THEN

	       IF SYSDATE < cur_pe_typ_inst_rec.START_DATE THEN
			l_date := cur_pe_typ_inst_rec.START_DATE;
                ELSE l_date := SYSDATE;
		END IF;
               igs_pe_typ_instances_pkg.update_row(
                  X_ROWID                 => cur_pe_typ_inst_rec.ROW_ID,
                  X_PERSON_ID             => cur_pe_typ_inst_rec.PERSON_ID,
                  X_COURSE_CD             => cur_pe_typ_inst_rec.COURSE_CD,
                  X_TYPE_INSTANCE_ID      => cur_pe_typ_inst_rec.TYPE_INSTANCE_ID,
                  X_PERSON_TYPE_CODE      => cur_pe_typ_inst_rec.PERSON_TYPE_CODE,
                  X_CC_VERSION_NUMBER     => cur_pe_typ_inst_rec.CC_VERSION_NUMBER,
                  X_FUNNEL_STATUS         => cur_pe_typ_inst_rec.FUNNEL_STATUS,
                  X_ADMISSION_APPL_NUMBER => cur_pe_typ_inst_rec.ADMISSION_APPL_NUMBER,
                  X_NOMINATED_COURSE_CD   => cur_pe_typ_inst_rec.NOMINATED_COURSE_CD,
                  X_NCC_VERSION_NUMBER    => cur_pe_typ_inst_rec.NCC_VERSION_NUMBER,
                  X_SEQUENCE_NUMBER       => cur_pe_typ_inst_rec.SEQUENCE_NUMBER,
                  X_START_DATE            => cur_pe_typ_inst_rec.START_DATE,
                  X_END_DATE              => l_date, --- what should be the end date
                  X_CREATE_METHOD         => cur_pe_typ_inst_rec.CREATE_METHOD,
                  X_ENDED_BY              => cur_pe_typ_inst_rec.ENDED_BY,
                  X_END_METHOD            => l_method,
                  X_MODE                  => 'R' ,
                  X_EMPLMNT_CATEGORY_CODE => cur_pe_typ_inst_rec.emplmnt_category_code);
             END IF;
             CLOSE cur_pe_typ_inst;

             l_person_type := NULL;
             -- Select Person type Code for the System type FORMER_STUDENT
             OPEN cur_pers_type('FORMER_STUDENT');
             FETCH cur_pers_type INTO l_person_type;
             CLOSE cur_pers_type;
             IF l_person_type IS NULL THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_EN_PERSON_TYPE_NOT_DEF');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
             END IF;

	     IF l_date = SYSDATE THEN
	     OPEN cur_typ_id_inst(new_references.PERSON_ID,new_references.COURSE_CD,l_person_type);
             FETCH cur_typ_id_inst INTO cur_typ_id_inst_rec;
             IF cur_typ_id_inst%NOTFOUND THEN
	           igs_pe_typ_instances_pkg.insert_row(
                                                X_ROWID  => l_ROWID,
                                                X_PERSON_ID => new_references.PERSON_ID,
                                                X_COURSE_CD => new_references.COURSE_CD,
                                                X_TYPE_INSTANCE_ID => l_TYPE_INSTANCE_ID,
                                                X_PERSON_TYPE_CODE => l_person_type,
                                                X_CC_VERSION_NUMBER => NULL,
                                                X_FUNNEL_STATUS => NULL,
                                                X_ADMISSION_APPL_NUMBER => NULL,
                                                X_NOMINATED_COURSE_CD => NULL,
                                                X_NCC_VERSION_NUMBER => NULL,
                                                X_SEQUENCE_NUMBER => NULL,
                                                X_START_DATE => l_date, -- what should be the start date
                                                X_END_DATE => NULL,
                                                X_CREATE_METHOD => l_method,
                                                X_ENDED_BY => NULL,
                                                X_END_METHOD => NULL,
                                                X_MODE => 'R',
                                                X_ORG_ID => NULL,
                                                X_EMPLMNT_CATEGORY_CODE => NULL
                                                );
             END IF;
             CLOSE cur_typ_id_inst;
	     ELSE
	     OPEN cur_per_typ_dt( new_references.person_id,
                                   new_references.COURSE_CD,
                                   'FORMER_STUDENT',
				   l_date);
             FETCH cur_per_typ_dt INTO cur_per_typ_dt_rec;
             IF cur_per_typ_dt%FOUND THEN
	       igs_pe_typ_instances_pkg.update_row(
                  X_ROWID                 => cur_per_typ_dt_rec.ROW_ID,
                  X_PERSON_ID             => cur_per_typ_dt_rec.PERSON_ID,
                  X_COURSE_CD             => cur_per_typ_dt_rec.COURSE_CD,
                  X_TYPE_INSTANCE_ID      => cur_per_typ_dt_rec.TYPE_INSTANCE_ID,
                  X_PERSON_TYPE_CODE      => cur_per_typ_dt_rec.PERSON_TYPE_CODE,
                  X_CC_VERSION_NUMBER     => cur_per_typ_dt_rec.CC_VERSION_NUMBER,
                  X_FUNNEL_STATUS         => cur_per_typ_dt_rec.FUNNEL_STATUS,
                  X_ADMISSION_APPL_NUMBER => cur_per_typ_dt_rec.ADMISSION_APPL_NUMBER,
                  X_NOMINATED_COURSE_CD   => cur_per_typ_dt_rec.NOMINATED_COURSE_CD,
                  X_NCC_VERSION_NUMBER    => cur_per_typ_dt_rec.NCC_VERSION_NUMBER,
                  X_SEQUENCE_NUMBER       => cur_per_typ_dt_rec.SEQUENCE_NUMBER,
                  X_START_DATE            => cur_per_typ_dt_rec.START_DATE,
                  X_END_DATE              => NULL, --- what should be the end date
                  X_CREATE_METHOD         => cur_per_typ_dt_rec.CREATE_METHOD,
                  X_ENDED_BY              => NULL,
                  X_END_METHOD            => NULL,
                  X_MODE                  => 'R' ,
                  X_EMPLMNT_CATEGORY_CODE => cur_per_typ_dt_rec.emplmnt_category_code);
             END IF;
             CLOSE cur_per_typ_dt;
	     END IF;

    ELSIF p_deleting THEN
             l_date := SYSDATE;
             l_person_type := NULL;
	     l_method := 'PERSON_NO_ENROLL_PRG';

             -- Select Person type Code for the System type GRADUATE
             OPEN cur_pers_type('GRADUATE');
             FETCH cur_pers_type INTO l_person_type;
             CLOSE cur_pers_type;
             IF l_person_type IS NULL THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_EN_PERSON_TYPE_NOT_DEF');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
              END IF;

	     OPEN cur_conf_dt(p_rowid);
	     FETCH cur_conf_dt INTO cur_conf_dt_rec;
	     IF cur_conf_dt%FOUND THEN
	     -- Check any active record found for this student program, with System Person Type,GRADUATE
             OPEN cur_pe_typ_inst( cur_conf_dt_rec.person_id,
                                   cur_conf_dt_rec.COURSE_CD,
                                   'GRADUATE');
             FETCH cur_pe_typ_inst INTO cur_pe_typ_inst_rec;
             IF cur_pe_typ_inst%FOUND THEN
	       IF SYSDATE < cur_pe_typ_inst_rec.START_DATE THEN
			l_date := cur_pe_typ_inst_rec.START_DATE;
               END IF;
               igs_pe_typ_instances_pkg.update_row(
                  X_ROWID                 => cur_pe_typ_inst_rec.ROW_ID,
                  X_PERSON_ID             => cur_pe_typ_inst_rec.PERSON_ID,
                  X_COURSE_CD             => cur_pe_typ_inst_rec.COURSE_CD,
                  X_TYPE_INSTANCE_ID      => cur_pe_typ_inst_rec.TYPE_INSTANCE_ID,
                  X_PERSON_TYPE_CODE      => cur_pe_typ_inst_rec.PERSON_TYPE_CODE,
                  X_CC_VERSION_NUMBER     => cur_pe_typ_inst_rec.CC_VERSION_NUMBER,
                  X_FUNNEL_STATUS         => cur_pe_typ_inst_rec.FUNNEL_STATUS,
                  X_ADMISSION_APPL_NUMBER => cur_pe_typ_inst_rec.ADMISSION_APPL_NUMBER,
                  X_NOMINATED_COURSE_CD   => cur_pe_typ_inst_rec.NOMINATED_COURSE_CD,
                  X_NCC_VERSION_NUMBER    => cur_pe_typ_inst_rec.NCC_VERSION_NUMBER,
                  X_SEQUENCE_NUMBER       => cur_pe_typ_inst_rec.SEQUENCE_NUMBER,
                  X_START_DATE            => cur_pe_typ_inst_rec.START_DATE,
                  X_END_DATE              => l_date,
                  X_CREATE_METHOD         => cur_pe_typ_inst_rec.CREATE_METHOD,
                  X_ENDED_BY              => cur_pe_typ_inst_rec.ENDED_BY,
                  X_END_METHOD            => l_method,
                  X_MODE                  => 'R' ,
                  X_EMPLMNT_CATEGORY_CODE => cur_pe_typ_inst_rec.emplmnt_category_code);
             END IF;
             CLOSE cur_pe_typ_inst;

             l_person_type := NULL;
             -- Select Person type Code for the System type FORMER_STUDENT
             OPEN cur_pers_type('FORMER_STUDENT');
             FETCH cur_pers_type INTO l_person_type;
             CLOSE cur_pers_type;
             IF l_person_type IS NULL THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_EN_PERSON_TYPE_NOT_DEF');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
             END IF;
             IF l_date = SYSDATE THEN
             OPEN cur_typ_id_inst(cur_conf_dt_rec.PERSON_ID,cur_conf_dt_rec.COURSE_CD,l_person_type);
             FETCH cur_typ_id_inst INTO cur_typ_id_inst_rec;
             IF cur_typ_id_inst%NOTFOUND THEN
	        igs_pe_typ_instances_pkg.insert_row(
                                                X_ROWID  => l_ROWID,
                                                X_PERSON_ID => cur_conf_dt_rec.PERSON_ID,
                                                X_COURSE_CD => cur_conf_dt_rec.COURSE_CD,
                                                X_TYPE_INSTANCE_ID => l_TYPE_INSTANCE_ID,
                                                X_PERSON_TYPE_CODE => l_person_type,
                                                X_CC_VERSION_NUMBER => NULL,
                                                X_FUNNEL_STATUS => NULL,
                                                X_ADMISSION_APPL_NUMBER => NULL,
                                                X_NOMINATED_COURSE_CD => NULL,
                                                X_NCC_VERSION_NUMBER => NULL,
                                                X_SEQUENCE_NUMBER => NULL,
                                                X_START_DATE => SYSDATE, -- what should be the start date
                                                X_END_DATE => NULL,
                                                X_CREATE_METHOD => l_method,
                                                X_ENDED_BY => NULL,
                                                X_END_METHOD => NULL,
                                                X_MODE => 'R',
                                                X_ORG_ID => NULL,--new_references.ORG_ID,
                                                X_EMPLMNT_CATEGORY_CODE => NULL
                                                );
             END IF;
             CLOSE cur_typ_id_inst;
	     ELSE
	     OPEN cur_per_typ_dt( cur_conf_dt_rec.PERSON_ID,
                                   cur_conf_dt_rec.COURSE_CD,
                                   'FORMER_STUDENT',
				   l_date);
             FETCH cur_per_typ_dt INTO cur_per_typ_dt_rec;
             IF cur_per_typ_dt%FOUND THEN
	       igs_pe_typ_instances_pkg.update_row(
                  X_ROWID                 => cur_per_typ_dt_rec.ROW_ID,
                  X_PERSON_ID             => cur_per_typ_dt_rec.PERSON_ID,
                  X_COURSE_CD             => cur_per_typ_dt_rec.COURSE_CD,
                  X_TYPE_INSTANCE_ID      => cur_per_typ_dt_rec.TYPE_INSTANCE_ID,
                  X_PERSON_TYPE_CODE      => cur_per_typ_dt_rec.PERSON_TYPE_CODE,
                  X_CC_VERSION_NUMBER     => cur_per_typ_dt_rec.CC_VERSION_NUMBER,
                  X_FUNNEL_STATUS         => cur_per_typ_dt_rec.FUNNEL_STATUS,
                  X_ADMISSION_APPL_NUMBER => cur_per_typ_dt_rec.ADMISSION_APPL_NUMBER,
                  X_NOMINATED_COURSE_CD   => cur_per_typ_dt_rec.NOMINATED_COURSE_CD,
                  X_NCC_VERSION_NUMBER    => cur_per_typ_dt_rec.NCC_VERSION_NUMBER,
                  X_SEQUENCE_NUMBER       => cur_per_typ_dt_rec.SEQUENCE_NUMBER,
                  X_START_DATE            => cur_per_typ_dt_rec.START_DATE,
                  X_END_DATE              => NULL, --- what should be the end date
                  X_CREATE_METHOD         => cur_per_typ_dt_rec.CREATE_METHOD,
                  X_ENDED_BY              => NULL,
                  X_END_METHOD            => NULL,
                  X_MODE                  => 'R' ,
                  X_EMPLMNT_CATEGORY_CODE => cur_per_typ_dt_rec.emplmnt_category_code);
             END IF;
             CLOSE cur_per_typ_dt;
	     END IF;
	     CLOSE cur_conf_dt;
	     END IF;
	  END IF;
END AfterRowInsertUpdate;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-NOV-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  Nalin Kumar 22-Oct-2002  Added the call to igs_gr_honours_level_pkg.get_pk_for_validation to validate the foreign key.
  */
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_stdnt_ps_att_pkg.get_pk_for_validation (
                new_references.person_id,
                new_references.course_cd
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.award_cd = new_references.award_cd)) OR
        ((new_references.award_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_awd_pkg.get_pk_for_validation (
                new_references.award_cd
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.grading_schema_cd = new_references.grading_schema_cd) AND
         (old_references.gs_version_number = new_references.gs_version_number)) OR
        ((new_references.grading_schema_cd IS NULL) OR
         (new_references.gs_version_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_as_grd_schema_pkg.get_pk_for_validation (
                new_references.grading_schema_cd,
                new_references.gs_version_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;

PROCEDURE Check_Child_Existance AS
/*
  ||  Created By : Imran.Jeddy@oracle.com
  ||  Created On : 24-Sept-2003
  ||  Purpose : Checking for child existance
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    IGS_GR_GRADUAND_PKG.GET_FK_IGS_EN_SPA_AWD(
        old_references.person_id,
	old_references.course_cd,
	old_references.award_cd
     );
  END Check_Child_Existance;

  FUNCTION get_pk_for_validation (
    x_award_cd                          IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_person_id                         IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-NOV-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_spa_awd_aim
      WHERE    award_cd = x_award_cd
      AND      course_cd = x_course_cd
      AND      person_id = x_person_id
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


  PROCEDURE get_fk_igs_en_stdnt_ps_att (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-NOV-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_spa_awd_aim
      WHERE   ((course_cd = x_course_cd) AND
               (person_id = x_person_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_EN_ESAA_SCA_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_stdnt_ps_att;


  PROCEDURE get_fk_igs_as_grading_sch (
        x_grading_schema_cd                 IN     VARCHAR2,
	x_gs_version_number                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-NOV-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  || rvangala    27-Aug-2004  Bug #3699796, changed incorrect column
  ||                          x_grading_schema_cd to grading_schema_cd
  ||                          in cursor cur_rowid
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_spa_awd_aim
      WHERE   (( grading_schema_cd = x_grading_schema_cd) AND
               (gs_version_number = x_gs_version_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AS_GSG_GS_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_as_grading_sch;



  PROCEDURE get_fk_igs_gr_honours_level (
    x_honours_level                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-Oct-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ijeddy          23-Sept-03      Obsoleted the function as per build #3129913.
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    NULL;
  END get_fk_igs_gr_honours_level;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER  ,
    x_course_cd                         IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_start_dt                          IN     DATE    ,
    x_end_dt                            IN     DATE    ,
    x_complete_ind                      IN     VARCHAR2,
    x_honours_level                     IN     VARCHAR2,
    x_conferral_date			IN     DATE    ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_award_mark                        IN     NUMBER,
    x_award_grade                       IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-NOV-2001
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
      x_person_id,
      x_course_cd,
      x_award_cd,
      x_start_dt,
      x_end_dt,
      x_complete_ind,
      x_conferral_date,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_award_mark,
      x_award_grade,
      x_grading_schema_cd,
      x_gs_version_number
    );

    IF (p_action = 'INSERT') THEN
          -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.award_cd,
             new_references.course_cd,
             new_references.person_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
         -- Call all the procedures related to Before Update.
    check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
          -- Call all the procedures related to Before Delete.
      AfterRowInsertUpdate(                           p_rowid => x_rowid,
						      p_inserting => FALSE,
						      p_updating => FALSE,
						      p_deleting => TRUE );
      Check_Child_Existance;
      del_spaa_hist(x_rowid);
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.award_cd,
             new_references.course_cd,
             new_references.person_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;

  PROCEDURE After_DML (
      p_action IN VARCHAR2,
      x_rowid IN VARCHAR2
    ) AS
  BEGIN
    l_rowid := x_rowid;
    IF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate1 ( p_updating => TRUE );
    END IF;
    IF(NVL(old_references.conferral_date,IGS_GE_DATE.IGSDATE('1900/01/01')) <> NVL(new_references.conferral_date,IGS_GE_DATE.IGSDATE('1900/01/01'))) THEN
	AfterRowInsertUpdate(			      p_inserting => FALSE,
						      p_updating => TRUE,
						      p_deleting => FALSE );

        END IF;
  END After_DML;
  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_complete_ind                      IN     VARCHAR2,
    x_honours_level                     IN     VARCHAR2,
    x_conferral_date			IN     DATE    ,
    x_mode                              IN     VARCHAR2  ,
    x_award_mark                        IN     NUMBER,
    x_award_grade                       IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-NOV-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_en_spa_awd_aim
      WHERE    award_cd                          = x_award_cd
      AND      course_cd                         = x_course_cd
      AND      person_id                         = x_person_id;

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

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_award_cd                          => x_award_cd,
      x_start_dt                          => x_start_dt,
      x_end_dt                            => x_end_dt,
      x_complete_ind                      => x_complete_ind,
      x_conferral_date                      => x_conferral_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_award_mark                        => x_award_mark,
      x_award_grade                       => x_award_grade,
      x_grading_schema_cd                 => x_grading_schema_cd,
      x_gs_version_number                 => x_gs_version_number
    );

    IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  INSERT INTO igs_en_spa_awd_aim (
      person_id,
      course_cd,
      award_cd,
      start_dt,
      end_dt,
      complete_ind,
      conferral_date,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      award_mark,
      award_grade,
      grading_schema_cd,
      gs_version_number

    ) VALUES (
      new_references.person_id,
      new_references.course_cd,
      new_references.award_cd,
      new_references.start_dt,
      new_references.end_dt,
      new_references.complete_ind,
      new_references.conferral_date,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      new_references.award_mark,
      new_references.award_grade,
      new_references.grading_schema_cd,
      new_references.gs_version_number
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
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_complete_ind                      IN     VARCHAR2,
    x_honours_level                     IN     VARCHAR2,
    x_conferral_date			IN     DATE ,
    x_award_mark                        IN     NUMBER,
    x_award_grade                       IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-NOV-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  Nishikant       24MAY2002       Bug#2386592. Date fields was not being truncating before comparing.
  */
    CURSOR c1 IS
      SELECT
        start_dt,
        end_dt,
        complete_ind,
        conferral_date
      FROM  igs_en_spa_awd_aim
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
    -- TRUNCs added in the code by Nishikant - bug#2386592 - 24MAY2002.
    IF (
        (TRUNC(tlinfo.start_dt) = TRUNC(x_start_dt))
        AND ((TRUNC(tlinfo.end_dt) = TRUNC(x_end_dt)) OR ((tlinfo.end_dt IS NULL) AND (X_end_dt IS NULL)))
        AND (tlinfo.complete_ind = x_complete_ind)
        AND ((TRUNC(tlinfo.conferral_date) = TRUNC(x_conferral_date)) OR ((tlinfo.conferral_date IS NULL) AND (X_conferral_date IS NULL)))
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
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_complete_ind                      IN     VARCHAR2,
    x_honours_level                     IN     VARCHAR2,
    x_conferral_date			IN     DATE,
    x_mode                              IN     VARCHAR2  ,
    x_award_mark                        IN     NUMBER,
    x_award_grade                       IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER

  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-NOV-2001
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
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_award_cd                          => x_award_cd,
      x_start_dt                          => x_start_dt,
      x_end_dt                            => x_end_dt,
      x_complete_ind                      => x_complete_ind,
      x_conferral_date                      => x_conferral_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_award_mark                        => x_award_mark,
      x_award_grade                       => x_award_grade,
      x_grading_schema_cd                 => x_grading_schema_cd,
      x_gs_version_number                 => x_gs_version_number

    );

    IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  UPDATE igs_en_spa_awd_aim
      SET
        award_cd                          = new_references.award_cd,
        start_dt                          = new_references.start_dt,
        end_dt                            = new_references.end_dt,
        complete_ind                      = new_references.complete_ind,
	conferral_date                    = new_references.conferral_date,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        award_mark                        = new_references.award_mark,
        award_grade                       = new_references.award_grade,
        grading_schema_cd                 = new_references.grading_schema_cd,
        gs_version_number                 = new_references.gs_version_number
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

    After_DML(
      p_action => 'UPDATE',
      x_rowid => x_rowid
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
 END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_complete_ind                      IN     VARCHAR2,
    x_honours_level                     IN     VARCHAR2,
    x_conferral_date			IN     DATE,
    x_mode                              IN     VARCHAR2 ,
    x_award_mark                        IN     NUMBER,
    x_award_grade                       IN     VARCHAR2  DEFAULT NULL,
    x_grading_schema_cd                 IN     VARCHAR2  DEFAULT NULL,
    x_gs_version_number                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-NOV-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_en_spa_awd_aim
      WHERE    award_cd                          = x_award_cd
      AND      course_cd                         = x_course_cd
      AND      person_id                         = x_person_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_person_id,
        x_course_cd,
        x_award_cd,
        x_start_dt,
        x_end_dt,
        x_complete_ind,
        x_conferral_date,
        x_mode,
        x_award_mark,
        x_award_grade,
        x_grading_schema_cd,
        x_gs_version_number
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_person_id,
      x_course_cd,
      x_award_cd,
      x_start_dt,
      x_end_dt,
      x_complete_ind,
      x_conferral_date,
      x_mode,
      x_award_mark,
      x_award_grade,
      x_grading_schema_cd ,
      x_gs_version_number
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 22-NOV-2001
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
  DELETE FROM igs_en_spa_awd_aim
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


END igs_en_spa_awd_aim_pkg;

/
