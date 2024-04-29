--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_AM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_AM" AS
/* $Header: IGSPS09B.pls 120.2 2006/05/01 07:15:11 sommukhe noship $ */


  -- Validate Govt Attendance Mode is not closed.
  FUNCTION CRSP_VAL_AM_GOVT(
       p_govt_attendance_mode IN VARCHAR2 ,
       p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind	IGS_PS_GOVT_ATD_MODE.closed_ind%TYPE;

  	CURSOR 	c_govt_attendance_mode(
  			cp_govt_attendance_mode IGS_EN_ATD_MODE.govt_attendance_mode%TYPE)IS
  		SELECT 	closed_ind
  		FROM	IGS_PS_GOVT_ATD_MODE
  		WHERE	govt_attendance_mode = cp_govt_attendance_mode;
  BEGIN
  	p_message_name := NULL;
  	OPEN c_govt_attendance_mode(
  			p_govt_attendance_mode);
  	FETCH c_govt_attendance_mode INTO v_closed_ind;
  	IF(c_govt_attendance_mode%NOTFOUND) THEN
  		CLOSE c_govt_attendance_mode;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_govt_attendance_mode;
  	IF (v_closed_ind = 'N') THEN
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_GOVE_ATTEND_MODE_CLOSE';
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
  		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_AM.crsp_val_am_govt');
	 	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_am_govt;


PROCEDURE log_messages ( p_msg_name IN VARCHAR2 ,
                           p_msg_val  IN VARCHAR2
                         ) IS
  ------------------------------------------------------------------

  --Change History:
  --Who         When            What
  --sommukhe   17-APR-2006     Bug#4111831, include this procedure to log the messages.
  -------------------------------------------------------------------
  BEGIN

    FND_MESSAGE.SET_NAME('IGS','IGS_FI_CAL_BALANCES_LOG');
    FND_MESSAGE.SET_TOKEN('PARAMETER_NAME',p_msg_name);
    FND_MESSAGE.SET_TOKEN('PARAMETER_VAL' ,p_msg_val) ;
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

  END log_messages ;

  PROCEDURE schedule_rollover (
    errbuf  OUT NOCOPY  VARCHAR2,
    retcode OUT NOCOPY  NUMBER,
    p_old_sch_version  IN IGS_PS_CATLG_VERS_ALL.CATALOG_VERSION%TYPE,
    p_new_sch_version IN IGS_PS_CATLG_VERS_ALL.CATALOG_VERSION%TYPE,
    p_override_flag IN VARCHAR2,
    p_debug_flag IN VARCHAR2,
    p_org_id IN NUMBER ) AS
 /*------------------------------------------------------------------

  Change History:
  Who         When            What
  sommukhe   17-APR-2006     Bug#4111831, included logging for parameters, raising error with valid message when old and
                             new schedule versions are same,removed note id,note type id, schedule idfrom log as they are
			     not relevant to user.
  -------------------------------------------------------------------*/
  CURSOR cur_sel_sch_vers(p_sch_version IGS_PS_CATLG_VERS.CATALOG_VERSION%TYPE) IS
    SELECT catalog_version_id,
           catalog_version,
           description,
           closed_ind,
           catalog_schedule,
           created_by,
           creation_date,
           last_update_date,
           last_update_login,
           last_updated_by
    FROM IGS_PS_CATLG_VERS
    WHERE catalog_version = p_sch_version
    AND catalog_schedule = 'SCHEDULE';

  CURSOR cur_sel_old_sch_notes(p_sch_version_id IGS_PS_CATLG_NOTES.CATALOG_VERSION_ID%TYPE) IS
    SELECT catalog_note_id,
           catalog_version_id,
           note_type_id,
           create_date,
           end_date,
           SEQUENCE,
           note_text,
           created_by,
           creation_date,
           last_update_date,
           last_update_login,
           last_updated_by
         FROM IGS_PS_CATLG_NOTES
    WHERE catalog_version_id = p_sch_version_id;

  CURSOR cur_sel_new_sch_notes(p_sch_version_id IGS_PS_CATLG_NOTES.CATALOG_VERSION_ID%TYPE,
					     p_note_type_id IGS_PS_CATLG_NOTES.NOTE_TYPE_ID%TYPE,
					     p_sequence IGS_PS_CATLG_NOTES.SEQUENCE%TYPE) IS
    SELECT ROWID,
	       catalog_note_id,
           catalog_version_id,
           note_type_id,
           create_date,
           end_date,
           SEQUENCE,
           note_text,
           created_by,
           creation_date,
           last_update_date,
           last_update_login,
           last_updated_by
    FROM IGS_PS_CATLG_NOTES
    WHERE catalog_version_id = p_sch_version_id
    AND note_type_id = p_note_type_id
    AND SEQUENCE = p_sequence
    FOR UPDATE NOWAIT;


  v_sel_sch_vers cur_sel_sch_vers%ROWTYPE;
  v_sel_old_sch_notes cur_sel_old_sch_notes%ROWTYPE;
  v_sel_new_sch_notes cur_sel_new_sch_notes%ROWTYPE;


  lv_new_sch_version_id IGS_PS_CATLG_VERS.CATALOG_VERSION_ID%TYPE;
  lv_old_sch_version_id IGS_PS_CATLG_VERS.CATALOG_VERSION_ID%TYPE;
  lv_sch_note_id IGS_PS_CATLG_NOTES.CATALOG_NOTE_ID%TYPE;

  INVALID         EXCEPTION;

BEGIN

  -- Set the multi org ID
   igs_ge_gen_003.set_org_id(p_org_id);

  retcode:=0;
   /** logs all the parameters in the LOG **/
  Fnd_Message.Set_Name('IGS','IGS_FI_ANC_LOG_PARM');
  Fnd_File.Put_Line(Fnd_File.LOG,FND_MESSAGE.GET);
  log_messages('Old schedule version :',p_old_sch_version);
  log_messages('New schedule version :',p_new_sch_version);
  log_messages('Override flag        :',p_override_flag);
  log_messages('Debug flag           :',p_debug_flag);
  fnd_file.put_line(fnd_file.LOG,' ');
  IF p_old_sch_version = p_new_sch_version THEN
    FND_MESSAGE.SET_NAME('IGS','IGS_PS_SCH_VER_SAME');
    fnd_file.put_line(fnd_file.LOG,FND_MESSAGE.GET);
    fnd_file.put_line(fnd_file.LOG,' ');
    RAISE INVALID;
  END IF;
  OPEN cur_sel_sch_vers(p_old_sch_version);
  FETCH cur_sel_sch_vers INTO  v_sel_sch_vers;
  lv_old_sch_version_id := v_sel_sch_vers.catalog_version_id;
  CLOSE cur_sel_sch_vers;

  OPEN cur_sel_sch_vers(p_new_sch_version);
  FETCH cur_sel_sch_vers INTO v_sel_sch_vers;
  lv_new_sch_version_id := v_sel_sch_vers.catalog_version_id;
  IF cur_sel_sch_vers%NOTFOUND THEN
    CLOSE cur_sel_sch_vers;
    OPEN cur_sel_sch_vers(p_old_sch_version);
    FETCH cur_sel_sch_vers INTO v_sel_sch_vers;
    IF cur_sel_sch_vers%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_PS_NO_SCH_VER');
      fnd_file.put_line(fnd_file.LOG,FND_MESSAGE.GET);
      fnd_file.put_line(fnd_file.LOG,' ');
      RAISE INVALID;
    ELSE
	  DECLARE
	    lv_rowid VARCHAR2(25);
	  BEGIN
	  igs_ps_catlg_vers_pkg.insert_row(
	    x_rowid               =>  lv_rowid,
	    x_catalog_version_id  =>  lv_new_sch_version_id,
	    x_catalog_version     =>  p_new_sch_version,
	    x_description         =>  v_sel_sch_vers.description,
	    x_closed_ind          =>  v_sel_sch_vers.closed_ind,
	    x_catalog_schedule    =>  v_sel_sch_vers.catalog_schedule,
	    x_mode	      	  =>  'R',
	    x_org_id              =>  p_org_id);
	  END;
    END IF;
     IF p_debug_flag = 'Y' THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_PS_NEW_SCH');
        fnd_file.put_line(fnd_file.LOG,FND_MESSAGE.GET||lv_new_sch_version_id||' '||
                          p_new_sch_version ||' '||v_sel_sch_vers.description||' '||
                          v_sel_sch_vers.closed_ind||' '||v_sel_sch_vers.catalog_schedule||' '||
                          v_sel_old_sch_notes.note_text);
     END IF;
   CLOSE cur_sel_sch_vers;
  END IF;
  --Second part
  OPEN cur_sel_old_sch_notes(lv_old_sch_version_id);
  LOOP
    FETCH cur_sel_old_sch_notes INTO v_sel_old_sch_notes;
    IF cur_sel_old_sch_notes%NOTFOUND THEN
	  EXIT;
    END IF;
    OPEN cur_sel_new_sch_notes(    lv_new_sch_version_id, --v_sel_old_sch_notes.catalog_version_id,
                                   v_sel_old_sch_notes.note_type_id,
                                   v_sel_old_sch_notes.SEQUENCE);
    FETCH cur_sel_new_sch_notes INTO v_sel_new_sch_notes;
    IF cur_sel_new_sch_notes%NOTFOUND THEN
      DECLARE
	    lv_rowid VARCHAR2(25);
	  BEGIN
      igs_ps_catlg_notes_pkg.insert_row(
        x_rowid  => lv_rowid,
        x_catalog_note_id =>  lv_sch_note_id,
        x_catalog_version_id => lv_new_sch_version_id,
        x_note_type_id => v_sel_old_sch_notes.note_type_id,
        x_create_date => v_sel_old_sch_notes.create_date,
        x_end_date  => v_sel_old_sch_notes.end_date,
        x_sequence => v_sel_old_sch_notes.SEQUENCE,
        x_note_text => v_sel_old_sch_notes.note_text,
        x_mode => 'R',
        x_org_id  => p_org_id );
	  END;
      IF p_debug_flag = 'Y' THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_PS_NEW_SCH_NOTES');
        fnd_file.put_line(fnd_file.LOG,FND_MESSAGE.GET||v_sel_old_sch_notes.create_date||' '||
                          v_sel_old_sch_notes.end_date||' '||v_sel_old_sch_notes.SEQUENCE||' '||
                          v_sel_old_sch_notes.note_text);
      END IF;
    ELSE
      IF p_override_flag = 'Y' THEN
       igs_ps_catlg_notes_pkg.update_row(
        x_rowid  => v_sel_new_sch_notes.ROWID,
        x_catalog_note_id =>  v_sel_new_sch_notes.catalog_note_id,
        x_catalog_version_id => v_sel_new_sch_notes.catalog_version_id,
        x_note_type_id => v_sel_new_sch_notes.note_type_id,
        x_create_date => v_sel_new_sch_notes.create_date,
        x_end_date  => v_sel_new_sch_notes.end_date,
        x_sequence => v_sel_new_sch_notes.SEQUENCE,
        x_note_text => v_sel_old_sch_notes.note_text,
        x_mode => 'R');
      IF p_debug_flag = 'Y' THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_PS_UPD_SCH_NOTES');
        fnd_file.put_line(fnd_file.LOG,FND_MESSAGE.GET||v_sel_new_sch_notes.create_date||' '|| v_sel_new_sch_notes.end_date||' '||
                          v_sel_new_sch_notes.SEQUENCE||' '|| v_sel_new_sch_notes.note_text);
     END IF;
     END IF;
    END IF;
    CLOSE cur_sel_new_sch_notes ;
  END LOOP;
  CLOSE cur_sel_old_sch_notes ;
EXCEPTION
  WHEN INVALID THEN
        ROLLBACK;
	RETCODE:=2;
  WHEN OTHERS THEN
        ROLLBACK;
        RETCODE:=2;
        ERRBUF:=FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END schedule_rollover;
END Igs_Ps_Val_Am;

/
