--------------------------------------------------------
--  DDL for Package Body IGS_PS_CATALOG_ROLLOVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_CATALOG_ROLLOVER" AS
/* $Header: IGSPS75B.pls 115.9 2003/11/06 10:56:18 jdeekoll ship $ */

PROCEDURE catalog_rollover (
errbuf  OUT NOCOPY  VARCHAR2,
retcode OUT NOCOPY  NUMBER,
p_old_catalog_version  IN IGS_PS_CATLG_VERS_ALL.CATALOG_VERSION%TYPE,
p_new_catalog_version IN IGS_PS_CATLG_VERS_ALL.CATALOG_VERSION%TYPE,
p_override_flag IN VARCHAR2,
p_debug_flag IN VARCHAR2,
p_org_id IN NUMBER ) AS
  ------------------------------------------------------------------
  --Created by  :
  --Date created:
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --smvk      06-Jan-2003       Bug # 2647185. Removed the hard coded strings
  --                           ('New Catalog Version','New Catalog Notes','Updated Catalog Notes')
  -------------------------------------------------------------------
  CURSOR cur_sel_catalog_vers(p_catalog_version IGS_PS_CATLG_VERS.CATALOG_VERSION%TYPE) IS
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
    WHERE catalog_version = p_catalog_version
    AND catalog_schedule = 'CATALOG';

  CURSOR cur_sel_old_catalog_notes(p_catalog_version_id IGS_PS_CATLG_NOTES.CATALOG_VERSION_ID%TYPE) IS
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
    WHERE catalog_version_id = p_catalog_version_id;

  CURSOR cur_sel_new_catalog_notes(p_catalog_version_id IGS_PS_CATLG_NOTES.CATALOG_VERSION_ID%TYPE,
					     p_note_type_id IGS_PS_CATLG_NOTES.NOTE_TYPE_ID%TYPE,
					     p_sequence IGS_PS_CATLG_NOTES.SEQUENCE%TYPE ) IS
    SELECT ROWID,  -- included
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
    WHERE catalog_version_id = p_catalog_version_id
    AND note_type_id = p_note_type_id
    AND SEQUENCE = p_sequence
    FOR UPDATE NOWAIT;

  cur_sel_ctlg_vers cur_sel_catalog_vers%ROWTYPE;
  cur_sel_old_ctlg_notes cur_sel_old_catalog_notes%ROWTYPE;
  cur_sel_new_ctlg_notes cur_sel_new_catalog_notes%ROWTYPE;


  lv_new_catalog_version_id IGS_PS_CATLG_VERS.CATALOG_VERSION_ID%TYPE;
  lv_old_catalog_version_id IGS_PS_CATLG_VERS.CATALOG_VERSION_ID%TYPE;
  lv_catalog_note_id IGS_PS_CATLG_NOTES.CATALOG_NOTE_ID%TYPE;

BEGIN
   igs_ge_gen_003.set_org_id(p_org_id);
  retcode:=0;

  OPEN cur_sel_catalog_vers(p_old_catalog_version);
  FETCH cur_sel_catalog_vers INTO  cur_sel_ctlg_vers;
  lv_old_catalog_version_id := cur_sel_ctlg_vers.catalog_version_id;
  CLOSE cur_sel_catalog_vers;

  OPEN cur_sel_catalog_vers(p_new_catalog_version);
  FETCH cur_sel_catalog_vers INTO cur_sel_ctlg_vers;
  lv_new_catalog_version_id := cur_sel_ctlg_vers.catalog_version_id;
  IF cur_sel_catalog_vers%NOTFOUND THEN

    CLOSE cur_sel_catalog_vers;
    OPEN cur_sel_catalog_vers(p_old_catalog_version);
    FETCH cur_sel_catalog_vers INTO cur_sel_ctlg_vers;
    IF cur_sel_catalog_vers%NOTFOUND THEN

      fnd_message.set_name('IGS','IGS_PS_NO_CAT_VER');
      fnd_file.put_line(fnd_file.LOG,fnd_message.get);
      app_exception.raise_exception;
    ELSE

      DECLARE
	      lv_rowid VARCHAR2(25);
	  BEGIN
      igs_ps_catlg_vers_pkg.insert_row(
        x_rowid  =>  lv_rowid,
        x_catalog_version_id  => lv_new_catalog_version_id,
        x_catalog_version  => p_new_catalog_version,
        x_description  =>  cur_sel_ctlg_vers.description,
        x_closed_ind  =>  cur_sel_ctlg_vers.closed_ind,
        x_catalog_schedule  =>  cur_sel_ctlg_vers.catalog_schedule,
  	    x_mode		=> 'R',
	    x_org_id => p_org_id );
      END;

    END IF;

      IF p_debug_flag = 'Y' THEN
      fnd_message.set_name('IGS','IGS_PS_NEW_CTLG_VERSION');
      fnd_file.put_line(fnd_file.LOG, fnd_message.get ||': '||lv_new_catalog_version_id||' '||
                          p_new_catalog_version ||' '||cur_sel_ctlg_vers.description||' '||
                          cur_sel_ctlg_vers.closed_ind||' '||cur_sel_ctlg_vers.catalog_schedule||' '||
                          cur_sel_old_ctlg_notes.note_text);
     END IF;
   CLOSE cur_sel_catalog_vers;
  END IF;

  --Second part
  OPEN cur_sel_old_catalog_notes(lv_old_catalog_version_id);
  LOOP
    FETCH cur_sel_old_catalog_notes INTO cur_sel_old_ctlg_notes;

    IF cur_sel_old_catalog_notes%NOTFOUND THEN

	  EXIT;
    END IF;


    OPEN cur_sel_new_catalog_notes( lv_new_catalog_version_id,  --cur_sel_old_ctlg_notes.catalog_version_id,
                                    cur_sel_old_ctlg_notes.note_type_id ,
                                    cur_sel_old_ctlg_notes.SEQUENCE);
    FETCH cur_sel_new_catalog_notes INTO cur_sel_new_ctlg_notes;


    IF cur_sel_new_catalog_notes%NOTFOUND THEN

      DECLARE
	      lv_rowid VARCHAR2(25);
	  BEGIN
      igs_ps_catlg_notes_pkg.insert_row(
        x_rowid  => lv_rowid,
        x_catalog_note_id =>  lv_catalog_note_id,
        x_catalog_version_id => lv_new_catalog_version_id,
        x_note_type_id => cur_sel_old_ctlg_notes.note_type_id,
        x_create_date => cur_sel_old_ctlg_notes.create_date,
        x_end_date  => cur_sel_old_ctlg_notes.end_date,
        x_sequence => cur_sel_old_ctlg_notes.SEQUENCE,
        x_note_text => cur_sel_old_ctlg_notes.note_text,
        x_mode => 'R',
        x_org_id => p_org_id );
		END;

      IF p_debug_flag = 'Y' THEN
        fnd_message.set_name('IGS','IGS_PS_NEW_CTLG_NOTES');
        fnd_file.put_line(fnd_file.LOG,fnd_message.get || ': '||lv_catalog_note_id||' '||lv_new_catalog_version_id
                          ||' '||cur_sel_old_ctlg_notes.note_type_id||' '||cur_sel_old_ctlg_notes.create_date||' '||
                          cur_sel_old_ctlg_notes.end_date||' '||cur_sel_old_ctlg_notes.SEQUENCE||' '||
                          cur_sel_old_ctlg_notes.note_text);
     END IF;
    ELSE

      IF p_override_flag = 'Y'  THEN  -- was 'YES'

       igs_ps_catlg_notes_pkg.update_row(
        x_rowid  => cur_sel_new_ctlg_notes.ROWID,
        x_catalog_note_id =>  cur_sel_new_ctlg_notes.catalog_note_id,
        x_catalog_version_id => cur_sel_new_ctlg_notes.catalog_version_id,
        x_note_type_id => cur_sel_new_ctlg_notes.note_type_id,
        x_create_date => cur_sel_new_ctlg_notes.create_date,
        x_end_date  => cur_sel_new_ctlg_notes.end_date,
        x_sequence => cur_sel_new_ctlg_notes.SEQUENCE,
        x_note_text => cur_sel_old_ctlg_notes.note_text,
        x_mode => 'R');

      IF p_debug_flag = 'Y' THEN
        fnd_message.set_name('IGS','IGS_PS_UPD_CTLG_NOTES');
        fnd_file.put_line(fnd_file.LOG, fnd_message.get || ': '||cur_sel_new_ctlg_notes.catalog_note_id||' '||
                          cur_sel_new_ctlg_notes.catalog_version_id||' '||cur_sel_new_ctlg_notes.note_type_id||' '||
                          cur_sel_new_ctlg_notes.create_date||' '|| cur_sel_new_ctlg_notes.end_date||' '||
                          cur_sel_new_ctlg_notes.SEQUENCE||' '|| cur_sel_new_ctlg_notes.note_text);
     END IF;
     END IF;
    END IF;
    CLOSE cur_sel_new_catalog_notes ;
  END LOOP;
  CLOSE cur_sel_old_catalog_notes ;
EXCEPTION
  WHEN OTHERS THEN
        RETCODE:=2;
        ERRBUF:=FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END catalog_rollover;
END Igs_Ps_Catalog_Rollover;

/
