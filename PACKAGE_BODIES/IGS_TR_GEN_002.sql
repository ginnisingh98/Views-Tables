--------------------------------------------------------
--  DDL for Package Body IGS_TR_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_TR_GEN_002" AS
/* $Header: IGSTR02B.pls 120.1 2006/05/18 03:15:58 prbhardw noship $ */
  --msrinivi 27 Aug,2001 Bug 1956374. Pointed genp_al_prsn_id to igs_co_val_oc

  FUNCTION trkp_del_tri(
    p_tracking_id IN NUMBER ,
    p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. Used for deletion of tracking step notes, deletion of
        tracking steps, for tracking items, deletion of tracking group members for
        IGS_TR_ITEMS, deletion of tracking item notes for IGS_TR_ITEMS and deletion of
        IGS_TR_ITEMS

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR007.fmb

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/

   lv_param_values  VARCHAR2(1080);
   gv_other_detail  VARCHAR2(255);

  BEGIN

    -- trkp_del_tri
    -- Delete a tracking item.
    DECLARE

      e_resource_busy  EXCEPTION;
      PRAGMA EXCEPTION_INIT(e_resource_busy, -54);
      v_message_name   VARCHAR2(30);

      ------------------------------------------------------------------------------
      -- 1. Delete tracking_step_notes for the IGS_TR_ITEM.
      ------------------------------------------------------------------------------

      FUNCTION trkpl_del_tsn (
        lp_tracking_id igs_tr_item.tracking_id%TYPE)
      RETURN BOOLEAN  AS
	lv_param_values  VARCHAR2(1080);
      BEGIN

	DECLARE

          CURSOR c_del_tsn IS
            SELECT   ROWID,reference_number
            FROM     igs_tr_step_note
            WHERE    tracking_id = lp_tracking_id
            FOR UPDATE OF tracking_id NOWAIT;

        BEGIN

          FOR v_tsn_rec IN c_del_tsn LOOP

	    igs_tr_step_note_pkg.delete_row(x_rowid => v_tsn_rec.ROWID);
            IF igs_ge_gen_001.genp_del_note( v_tsn_rec.reference_number, v_message_name) = FALSE THEN
              p_message_name := v_message_name;
              EXIT;
            END IF;
          END LOOP;

          IF (v_message_name <> NULL) THEN
            RETURN FALSE;
          END IF;

          RETURN TRUE;

        END;

        EXCEPTION

	  WHEN e_resource_busy THEN
            p_message_name := 'IGS_TR_ITEM_STEP_NOTE_LOCKED';
            RETURN FALSE;

	  WHEN OTHERS THEN
            fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
            fnd_message.set_token('NAME','IGS_TR_GEN_002.trkpl_del_tsn'||'-'||SQLERRM);
            igs_ge_msg_stack.ADD;
            lv_param_values:= TO_CHAR(lp_tracking_id);
            fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
            fnd_message.set_token('VALUE',lv_param_values);
            igs_ge_msg_stack.ADD;
            app_exception.raise_exception;

      END trkpl_del_tsn;

      ------------------------------------------------------------------------------
      -- 2. Delete tracking_step for the IGS_TR_ITEM.
      ------------------------------------------------------------------------------
      FUNCTION trkpl_del_ts(
        lp_tracking_id igs_tr_item.tracking_id%TYPE)
      RETURN BOOLEAN AS

        lv_param_values  VARCHAR2(1080);

      BEGIN

	DECLARE

	  CURSOR  c_del_ts IS
          SELECT  igs_tr_step.*,ROWID
          FROM    igs_tr_step
          WHERE   tracking_id = lp_tracking_id
          FOR UPDATE OF tracking_id NOWAIT;

        BEGIN

          FOR v_ts_rec IN c_del_ts LOOP
            igs_tr_step_pkg.delete_row( x_rowid => v_ts_rec.ROWID);
          END LOOP;
          RETURN TRUE;

        END;

        EXCEPTION
      	WHEN e_resource_busy THEN
          p_message_name := 'IGS_TR_STEP_RECORD_LOCKED';
          RETURN FALSE;

	WHEN OTHERS THEN
          fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
          fnd_message.set_token('NAME','IGS_TR_GEN_002.trkpl_del_ts'||'-'||SQLERRM);
          igs_ge_msg_stack.ADD;
          lv_param_values:= TO_CHAR(lp_tracking_id);
          fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
          fnd_message.set_token('VALUE',lv_param_values);
          igs_ge_msg_stack.ADD;
          app_exception.raise_exception;

      END trkpl_del_ts;

      ------------------------------------------------------------------------------
      -- 3. Delete tracking_group_member for the IGS_TR_ITEM.
      ------------------------------------------------------------------------------
      FUNCTION trkpl_del_tgm(
        lp_tracking_id igs_tr_item.tracking_id%TYPE)
      RETURN BOOLEAN AS
        lv_param_values  VARCHAR2(1080);
      BEGIN

	DECLARE

          CURSOR c_del_tgm IS
          SELECT ROWID,igs_tr_group_member.*
          FROM   igs_tr_group_member
          WHERE  tracking_id = p_tracking_id
          FOR UPDATE OF tracking_id NOWAIT;

        BEGIN

          FOR v_tgm_rec IN c_del_tgm LOOP
            igs_tr_group_member_pkg.delete_row( x_rowid => v_tgm_rec.ROWID);
          END LOOP;

          RETURN TRUE;
        END;

        EXCEPTION
          WHEN e_resource_busy THEN
            p_message_name := 'IGS_TR_GRP_RECORD_LOCKED';
            RETURN FALSE;

	  WHEN OTHERS THEN
            fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
            fnd_message.set_token('NAME','IGS_TR_GEN_002.trkpl_del_tgm'||'-'||SQLERRM);
            igs_ge_msg_stack.ADD;
            lv_param_values:= TO_CHAR(lp_tracking_id);
            fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
            fnd_message.set_token('VALUE',lv_param_values);
            igs_ge_msg_stack.ADD;
            app_exception.raise_exception;

      END trkpl_del_tgm;

      ------------------------------------------------------------------------------
      -- 4. Delete tracking_item_notes for the IGS_TR_ITEM.
      ------------------------------------------------------------------------------
      FUNCTION trkpl_del_tin (
        lp_tracking_id igs_tr_item.tracking_id%TYPE)
      RETURN BOOLEAN AS
        lv_param_values  VARCHAR2(1080);
      BEGIN

	DECLARE

	  CURSOR c_del_tin IS
          SELECT ROWID, reference_number
          FROM igs_tr_item_note
          WHERE tracking_id = lp_tracking_id
          FOR UPDATE OF tracking_id NOWAIT;

        BEGIN

          FOR v_tin_rec IN c_del_tin LOOP
            igs_tr_item_note_pkg.delete_row( x_rowid => v_tin_rec.ROWID);
            IF igs_ge_gen_001.genp_del_note( v_tin_rec.reference_number, v_message_name) = FALSE THEN
              p_message_name := v_message_name;
              EXIT;
            END IF;
          END LOOP;

          IF (v_message_name <> NULL) THEN
            RETURN FALSE;
          END IF;

          RETURN TRUE;
        END;

        EXCEPTION

	  WHEN e_resource_busy THEN
            p_message_name := 'IGS_TR_ITEM_NOTE_REC_LOCKED';
            RETURN FALSE;

	  WHEN OTHERS THEN
            fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
            fnd_message.set_token('NAME','IGS_TR_GEN_002.trkpl_del_tin'||'-'||SQLERRM);
            igs_ge_msg_stack.ADD;
            lv_param_values:= TO_CHAR(lp_tracking_id);
            fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
            fnd_message.set_token('VALUE',lv_param_values);
            igs_ge_msg_stack.ADD;
            app_exception.raise_exception;

      END trkpl_del_tin;

      ------------------------------------------------------------------------------
      -- 5. Delete the IGS_TR_ITEM.
      ------------------------------------------------------------------------------
      FUNCTION trkpl_del_tri(
        lp_tracking_id igs_tr_item.tracking_id%TYPE)
      RETURN BOOLEAN AS
        lv_param_values  VARCHAR2(1080);
      BEGIN

	DECLARE

	  CURSOR  c_del_tri IS
          SELECT  ROWID, igs_tr_item.*
          FROM    igs_tr_item
          WHERE   tracking_id = lp_tracking_id
          FOR UPDATE OF tracking_id NOWAIT;

        BEGIN

	  FOR v_tri_rec IN c_del_tri LOOP
            igs_tr_item_pkg.delete_row( x_rowid => v_tri_rec.ROWID);
          END LOOP;

          RETURN TRUE;
        END;

        EXCEPTION

	  WHEN e_resource_busy THEN
            p_message_name := 'IGS_TR_ITEM_RECORD_LOCKED';
            RETURN FALSE;

	  WHEN OTHERS THEN
            fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
            fnd_message.set_token('NAME','IGS_TR_GEN_002.trkpl_del_tri'||'-'||SQLERRM);
            igs_ge_msg_stack.ADD;
            lv_param_values:= TO_CHAR(lp_tracking_id);
            fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
            fnd_message.set_token('VALUE',lv_param_values);
            igs_ge_msg_stack.ADD;
            app_exception.raise_exception;

      END trkpl_del_tri;


      ------------------------------------------------------------------------------
      -- 6. Delete step group limit from IGS_TR_STEP_GRP_LMT
      -- Function added by pradhakr as part of CCR for Tracking in Applicant
      -- Self Service Part 3.
      ------------------------------------------------------------------------------
      FUNCTION trkpl_del_grp_lmt(
        lp_tracking_id igs_tr_step_grp_lmt.tracking_id%TYPE )
      RETURN BOOLEAN AS
        lv_param_values  VARCHAR2(1080);
      BEGIN

	DECLARE

	  CURSOR  c_del_grp_lmt IS
          SELECT  ROWID
          FROM    igs_tr_step_grp_lmt
          WHERE   tracking_id = lp_tracking_id
          FOR UPDATE OF tracking_id NOWAIT;

        BEGIN

	  FOR rec_del_grp_lmt IN c_del_grp_lmt LOOP
            igs_tr_step_grp_lmt_pkg.delete_row( x_rowid => rec_del_grp_lmt.rowid);
          END LOOP;

          RETURN TRUE;
        END;

        EXCEPTION

	  WHEN e_resource_busy THEN
            p_message_name := 'IGS_TR_LIMIT_RECORD_LOCKED';
            RETURN FALSE;

	  WHEN OTHERS THEN
            fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
            fnd_message.set_token('NAME','IGS_TR_GEN_002.trkpl_del_grp_lmt'||'-'||SQLERRM);
            igs_ge_msg_stack.add;
            lv_param_values:= TO_CHAR(lp_tracking_id);
            fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
            fnd_message.set_token('VALUE',lv_param_values);
            igs_ge_msg_stack.add;
            app_exception.raise_exception;

      END trkpl_del_grp_lmt;    /* End of the procedure  */

    BEGIN

      SAVEPOINT sp_del_tri;
      p_message_name := NULL;

      IF ( -- Delete tracking_step_note
        trkpl_del_tsn(p_tracking_id) = FALSE OR
        -- Delete tracking_step
        trkpl_del_ts(p_tracking_id) = FALSE  OR
        -- Deleting step group limit from IGS_TR_STEP_GRP_LMT
        trkpl_del_grp_lmt(p_tracking_id) = FALSE OR
        -- Delete tracking_group_member
        trkpl_del_tgm(p_tracking_id) = FALSE  OR
        -- Delete tracking_item_note
        trkpl_del_tin(p_tracking_id) = FALSE  OR
        -- Delete tracking_item
        trkpl_del_tri(p_tracking_id) = FALSE) THEN

	ROLLBACK TO sp_del_tri;
        RETURN FALSE;
      END IF;
      RETURN TRUE;

    END;

    EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_TR_GEN_002.trkp_del_tri'||'-'||SQLERRM);
        igs_ge_msg_stack.ADD;
        lv_param_values:= TO_CHAR(p_tracking_id);
        fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
        fnd_message.set_token('VALUE',lv_param_values);
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;

  END trkp_del_tri;


  FUNCTION trkp_get_group_sts(
    p_tracking_group_id IN NUMBER )
  RETURN VARCHAR2 IS

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. This function returns the status of a tracking group

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR007.FMB

  Known limitations/enhancements/remarks:
     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/

    BEGIN

    -- return status of a tracking group
    DECLARE

      v_other_detail  VARCHAR2(255);
      v_tracking_id  igs_tr_item.tracking_id%TYPE;
      v_s_tracking_status igs_tr_status.s_tracking_status%TYPE;
      v_active_flag  BOOLEAN DEFAULT FALSE;
      v_cancelled_cnt  NUMBER(3) DEFAULT 0;
      v_row_cnt  NUMBER(3) DEFAULT 0;

      CURSOR c_tracking_group_member ( cp_tracking_group_id igs_tr_group.tracking_group_id%TYPE) IS
        SELECT  tracking_id
        FROM    igs_tr_group_member
        WHERE   tracking_group_id = cp_tracking_group_id;

    BEGIN

      OPEN c_tracking_group_member(p_tracking_group_id);

      LOOP

	FETCH c_tracking_group_member INTO v_tracking_id;
        EXIT WHEN c_tracking_group_member%NOTFOUND;
        v_s_tracking_status := trkp_get_item_status(v_tracking_id);
        -- exit if any tracking item has a system status of ACTIVE

	IF (v_s_tracking_status = 'ACTIVE') THEN
          v_active_flag := TRUE;
          EXIT;

	ELSIF (v_s_tracking_status = 'CANCELLED') THEN
          v_cancelled_cnt := v_cancelled_cnt + 1;
        END IF;

      END LOOP;

      v_row_cnt := c_tracking_group_member%rowcount;
      CLOSE c_tracking_group_member;

      -- no members exist in the group
      IF (v_row_cnt = 0) THEN
        RETURN NULL;
      END IF;

      -- there exists tracking item has a system status of 'ACTIVE'
      IF (v_active_flag = TRUE) THEN
        RETURN 'ACTIVE';
      END IF;

      -- all tracking items have system status of 'CANCELLED'
      IF (v_row_cnt = v_cancelled_cnt) THEN
        RETURN 'CANCELLED';
      END IF;
      -- tracking items have system status of both 'CANCELLED' and 'COMPLETE'
      RETURN 'COMPLETE';
    END;

  END trkp_get_group_sts;

  FUNCTION trkp_get_item_status(
    p_tracking_id IN NUMBER )
  RETURN VARCHAR2 IS

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. This function returns the status of a tracking item

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR007.FMB

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/

  BEGIN

    -- Returns the status of tracking item
    DECLARE

      v_other_detail  VARCHAR2(255);
      v_s_tracking_status igs_tr_status.s_tracking_status%TYPE;

      CURSOR c_get_s_tracking_status ( cp_tracking_id igs_tr_item.tracking_id%TYPE) IS
        SELECT   s_tracking_status
        FROM     igs_tr_item it, igs_tr_status ts
        WHERE    it.tracking_id  = cp_tracking_id
	AND      it.tracking_status  = ts.tracking_status;

    BEGIN

      -- Returns the status of the tracking item
      OPEN c_get_s_tracking_status(p_tracking_id);
      FETCH c_get_s_tracking_status INTO v_s_tracking_status;
      IF (c_get_s_tracking_status%NOTFOUND) THEN
        CLOSE c_get_s_tracking_status;
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE c_get_s_tracking_status;
      RETURN v_s_tracking_status;

    END;

  END trkp_get_item_status;


  PROCEDURE trkp_ins_dflt_trst(
    p_tracking_id IN NUMBER ,
    p_message_name OUT NOCOPY VARCHAR2 )
  IS

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
   1. This program unit is used to insert the default tracking_steps for an item
      based on the IGS_TR_TYPE and its associated tracking_type_steps, duplicate
      existing IGS_GE_NOTE records and insert IGS_TR_STEP_NOTES

  Usage: (e.g. restricted, unrestricted, where to call from)
   1. Called from IGSTR007.FMB upon creation of a tracking item.

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        06 Jul,2001    Added logic to insert the newly added columns, i.e.
                                 step catalog id,step group id and publish indicator
  pradhakr        14-Feb-2002    Added code to insert step group limit after the
                                 default of tracking type steps.
  *******************************************************************************/

    gv_other_detail  VARCHAR2(255);
    lv_param_values  VARCHAR2(1080);

  BEGIN

    -- trkp_ins_dftl_trst
    -- Insert the default tracking_steps for an item based on the
    -- the IGS_TR_TYPE and its associated tracking_type_steps.
    -- This procedure should only be call on creation of a
    -- tracking item.

    DECLARE

      v_other_detail  VARCHAR2(255);
      v_tracking_type  igs_tr_item.tracking_type%TYPE;
      v_originator_person_id igs_tr_item.originator_person_id%TYPE;
      v_new_reference_number igs_ge_note.reference_number%TYPE;
      p_rowid   VARCHAR2(25);
      v_start_dt igs_tr_item.start_dt%TYPE;
      v_completion_due_dt igs_tr_item.completion_due_dt%TYPE;
      v_override_offset_clc_ind igs_tr_item.override_offset_clc_ind%TYPE;

      CURSOR c_tracking_item ( cp_tracking_id igs_tr_item.tracking_id%TYPE) IS
        SELECT  tracking_type, originator_person_id,start_dt,completion_due_dt, override_offset_clc_ind
        FROM    igs_tr_item
        WHERE   tracking_id = cp_tracking_id;

      CURSOR c_tracking_type_step ( cp_tracking_type igs_tr_type.tracking_type%TYPE) IS
        SELECT  *
        FROM    igs_tr_type_step
        WHERE   tracking_type  = cp_tracking_type;

      CURSOR c_tracking_type_step_note (
        cp_tracking_type  igs_tr_type.tracking_type%TYPE,
        cp_tracking_type_step_id  igs_tr_type_step.tracking_type_step_id%TYPE
      ) IS
        SELECT  reference_number, trk_note_type
        FROM    igs_tr_typ_step_note
        WHERE   tracking_type   = cp_tracking_type
	AND     tracking_type_step_id  = cp_tracking_type_step_id;

       -- Cursor to fetch group limit
       CURSOR c_tracking_type_step_grplmt (cp_tracking_type igs_tr_type.tracking_type%TYPE) IS
         SELECT step_group_id,
                step_group_limit
         FROM   igs_tr_tstp_grp_lmt
         WHERE  tracking_type = cp_tracking_type;


      -- This procedure insert a IGS_TR_STEP record
      PROCEDURE trkpl_ins_ts_rec (
        p_tracking_id  igs_tr_step.tracking_id%TYPE,
        p_tracking_step_id igs_tr_step.tracking_step_id%TYPE,
        p_tracking_step_number igs_tr_step.tracking_step_number%TYPE,
        p_description  igs_tr_step.description%TYPE,
        p_completion_dt  igs_tr_step.completion_dt%TYPE,
        p_action_days  igs_tr_step.action_days%TYPE,
        p_step_completion_ind igs_tr_step.step_completion_ind%TYPE,
        p_by_pass_ind  igs_tr_step.by_pass_ind%TYPE,
        p_recipient_id  igs_tr_step.recipient_id%TYPE,
        p_s_tracking_step_type igs_tr_type_step.s_tracking_step_type%TYPE,
        p_step_catalog_cd igs_tr_type_step.step_catalog_cd%TYPE,
        p_step_group_id igs_tr_type_step.step_group_id%TYPE,
        p_publish_ind igs_tr_type_step.publish_ind%TYPE)

      AS

	lv_param_values VARCHAR2(1080);
        p_rowid   VARCHAR2(25);

      BEGIN

	igs_tr_step_pkg.insert_row (
          x_rowid => p_rowid,
          x_tracking_id => p_tracking_id,
          x_tracking_step_id => p_tracking_step_id ,
          x_tracking_step_number => p_tracking_step_number,
          x_description => p_description,
          x_s_tracking_step_type=> p_s_tracking_step_type,
          x_completion_dt => p_completion_dt,
          x_action_days => p_action_days,
          x_step_completion_ind => p_step_completion_ind,
          x_by_pass_ind => p_by_pass_ind,
          x_recipient_id => p_recipient_id,
          x_mode => 'R',
          x_step_catalog_cd => p_step_catalog_cd,
          x_step_group_id => p_step_group_id,
          x_publish_ind => p_publish_ind
	);

     EXCEPTION

      WHEN OTHERS THEN
           app_exception.raise_exception;
       DECLARE
             l_message_name  VARCHAR2(30);
             l_app           VARCHAR2(50);
       BEGIN
        FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);
         IF l_message_name = 'IGS_TR_STEP_CTLG_CLOSED' THEN
		fnd_message.set_name('IGS',l_message_name);
		igs_ge_msg_stack.ADD;
                app_exception.raise_exception;
         ELSE
           fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
           fnd_message.set_token('NAME','IGS_TR_GEN_002.trkpl_ins_ts_rec'||'-'||SQLERRM);
           igs_ge_msg_stack.ADD;
           lv_param_values:=TO_CHAR(p_tracking_id)||','||TO_CHAR(p_tracking_step_id);
           fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
           fnd_message.set_token('VALUE',lv_param_values);
           igs_ge_msg_stack.ADD;
           lv_param_values:=TO_CHAR(p_tracking_step_number)||','||p_description;
           fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
           fnd_message.set_token('VALUE',lv_param_values);
           igs_ge_msg_stack.ADD;
           lv_param_values:=igs_ge_date.igschar (p_completion_dt)||','||TO_CHAR(p_action_days);
           fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
           fnd_message.set_token('VALUE',lv_param_values);
           igs_ge_msg_stack.ADD;
           lv_param_values:=p_step_completion_ind||','||p_by_pass_ind||','||TO_CHAR(p_recipient_id );
           fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
           fnd_message.set_token('VALUE',lv_param_values);
           igs_ge_msg_stack.ADD;
           lv_param_values:=p_s_tracking_step_type;
           fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
           fnd_message.set_token('VALUE',lv_param_values);
           igs_ge_msg_stack.ADD;
           app_exception.raise_exception;
         END IF;
       END;
      END trkpl_ins_ts_rec;

      -- Duplicate existing IGS_GE_NOTE record
      PROCEDURE trkpl_dup_note_rec (
        p_reference_number   igs_ge_note.reference_number%TYPE,
        p_new_reference_number OUT NOCOPY igs_ge_note.reference_number%TYPE)
      AS

        lv_param_values  VARCHAR2(1080);
        p_rowid  VARCHAR2(25);
        v_s_note_format_type igs_ge_note.s_note_format_type%TYPE;
        v_note_text  igs_ge_note.note_text%TYPE;
        v_next_ref_number igs_ge_note.reference_number%TYPE;

        CURSOR c_note IS
          SELECT  s_note_format_type, note_text
          FROM    igs_ge_note
          WHERE   reference_number = p_reference_number;

      BEGIN

        OPEN c_note;
        FETCH c_note INTO  v_s_note_format_type, v_note_text;
        CLOSE c_note;
        SELECT igs_ge_note_rf_num_s.NEXTVAL INTO v_next_ref_number FROM dual;

	p_new_reference_number := v_next_ref_number;
       igs_ge_note_pkg.insert_row(
         x_rowid => p_rowid,
         x_reference_number => v_next_ref_number,
         x_s_note_format_type => v_s_note_format_type,
         x_note_text => v_note_text,
         x_mode => 'R'
        );

       /* CALL ROUTINE TO COPY OLE DATA HERE */
       EXCEPTION
         WHEN OTHERS THEN
           fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
           fnd_message.set_token('NAME','IGS_TR_GEN_002.trkpl_dup_note_rec'||'-'||SQLERRM);
           igs_ge_msg_stack.ADD;
           lv_param_values:=TO_CHAR(p_reference_number);
           fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
           fnd_message.set_token('VALUE',lv_param_values);
           igs_ge_msg_stack.ADD;
           app_exception.raise_exception;

      END trkpl_dup_note_rec;

      -- Insert IGS_TR_STEP_NOTE record
      PROCEDURE trkpl_ins_tsn_rec(
        p_tracking_id  igs_tr_step_note.tracking_id%TYPE,
        p_tracking_step_id igs_tr_step_note.tracking_step_id%TYPE,
        p_reference_number igs_tr_step_note.reference_number%TYPE,
        p_trk_note_type  igs_tr_step_note.trk_note_type%TYPE)
      AS

	lv_param_values  VARCHAR2(1080);
        p_rowid   VARCHAR2(25);

      BEGIN

	igs_tr_step_note_pkg.insert_row(
          x_rowid => p_rowid,
          x_tracking_id => p_tracking_id,
          x_tracking_step_id => p_tracking_step_id,
          x_reference_number => p_reference_number,
          x_trk_note_type => p_trk_note_type,
          x_mode => 'R'
        );

        EXCEPTION
          WHEN OTHERS THEN
            fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
            fnd_message.set_token('NAME','IGS_TR_GEN_002.trkpl_ins_tsn_rec'||'-'||SQLERRM);
            igs_ge_msg_stack.ADD;
            lv_param_values:=TO_CHAR(p_tracking_id)||','||TO_CHAR(p_tracking_step_id)||','||TO_CHAR(p_reference_number);
            fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
            fnd_message.set_token('VALUE',lv_param_values);
            igs_ge_msg_stack.ADD;
            lv_param_values:=p_trk_note_type;
            fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
            fnd_message.set_token('VALUE',lv_param_values);
            igs_ge_msg_stack.ADD;
            app_exception.raise_exception;
      END trkpl_ins_tsn_rec;


      -- API to default the tracking steps for item based on the Tracking Type
      -- Added by pradhakr
      PROCEDURE trkpl_ins_ts_grp_lmt (
        p_tracking_id IN igs_tr_step_grp_lmt.tracking_id%TYPE,
	p_step_group_id  IN igs_tr_step_grp_lmt.step_group_id%TYPE,
        p_step_group_limit IN igs_tr_step_grp_lmt.step_group_limit%TYPE
       ) AS

        lv_param_values  VARCHAR2(1080);
        l_rowid  VARCHAR2(25);

      BEGIN

	IGS_TR_STEP_GRP_LMT_PKG.INSERT_ROW (
	  X_ROWID                 =>  l_rowid,
          X_TRACKING_ID           =>  p_tracking_id,
          X_STEP_GROUP_ID         =>  p_step_group_id,
          X_STEP_GROUP_LIMIT      =>  p_step_group_limit
	);

       EXCEPTION
         WHEN OTHERS THEN
           fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
           fnd_message.set_token('NAME','IGS_TR_GEN_002.trkpl_ins_ts_grp_lmt'||'-'||SQLERRM);
           igs_ge_msg_stack.add;
           lv_param_values:=TO_CHAR(p_tracking_id)||','||TO_CHAR(p_step_group_id)||','||TO_CHAR(p_step_group_limit);
           fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
           fnd_message.set_token('VALUE',lv_param_values);
           igs_ge_msg_stack.add;
           app_exception.raise_exception;

      END trkpl_ins_ts_grp_lmt; /* End of the procedure */

    BEGIN

      p_message_name := NULL;
      -- Select the IGS_TR_TYPE, originator_person_id
      OPEN c_tracking_item( p_tracking_id);
      FETCH c_tracking_item
      INTO
      v_tracking_type,
      v_originator_person_id,
      v_start_dt,
      v_completion_due_dt,
      v_override_offset_clc_ind;

      IF (c_tracking_item%NOTFOUND) THEN
        CLOSE c_tracking_item;
        p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
        RETURN;
      END IF;

      CLOSE c_tracking_item;

      -- Select all IGS_TR_TYPE_STEP records

      FOR v_tts_rec IN c_tracking_type_step( v_tracking_type) LOOP

	IF (v_tts_rec.recipient_id IS NULL) THEN
          v_tts_rec.recipient_id := v_originator_person_id;
        END IF;

      -- If the override offset ind is set, then set the action days to be
      -- completion due date minus the start date
        IF (NVL(v_override_offset_clc_ind,'N') = 'Y') THEN
        v_tts_rec.action_days := v_completion_due_dt - v_start_dt;
        END IF;

        -- For each record found, create a new IGS_TR_STEP record

        trkpl_ins_ts_rec (
          p_tracking_id,
          v_tts_rec.tracking_type_step_id,
          v_tts_rec.tracking_type_step_number,
          v_tts_rec.description,
          NULL,
          v_tts_rec.action_days,
          'N',
          'N',
          v_tts_rec.recipient_id,
          v_tts_rec.s_tracking_step_type,
          v_tts_rec.step_catalog_cd,
          v_tts_rec.step_group_id,
          v_tts_rec.publish_ind
	);

        -- If any tracking_type_step_notes exist then
        -- create a new IGS_GE_NOTE record(s) which duplicates the existing one

        FOR v_ttsn_rec IN c_tracking_type_step_note ( v_tts_rec.tracking_type, v_tts_rec.tracking_type_step_id) LOOP

	   trkpl_dup_note_rec(v_ttsn_rec.reference_number, v_new_reference_number);
           -- then create a new IGS_TR_STEP_NOTE

	   trkpl_ins_tsn_rec(
             p_tracking_id,
             v_tts_rec.tracking_type_step_id,
             v_new_reference_number,
             v_ttsn_rec.trk_note_type
	    );

        END LOOP;

      END LOOP;

	-- If any tracking group limit exists then insert into IGS_TR_STEP_GRP_LMT
	FOR rec_tracking_type_step_grplmt IN c_tracking_type_step_grplmt(v_tracking_type) LOOP
            trkpl_ins_ts_grp_lmt (p_tracking_id,
                                  rec_tracking_type_step_grplmt.step_group_id,
                                  rec_tracking_type_step_grplmt.step_group_limit);
        END LOOP;

    END;

    EXCEPTION
      WHEN OTHERS THEN
       DECLARE
             l_message_name  VARCHAR2(30);
             l_app           VARCHAR2(50);
       BEGIN
        FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);
	--kumma,2989286 , if l_message_name is not null then show message else unhandled
         IF l_message_name IS NOT NULL THEN
     		FND_MESSAGE.SET_NAME('IGS',l_message_name);
	     	IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
         ELSE
		fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
		fnd_message.set_token('NAME','IGS_TR_GEN_002.trkp_ins_dflt_trst'||'-'||SQLERRM);
		igs_ge_msg_stack.ADD;
		lv_param_values:=TO_CHAR(p_tracking_id);
		lv_param_values:=fnd_message.get;
		fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
		fnd_message.set_token('VALUE',lv_param_values);
		igs_ge_msg_stack.ADD;
		app_exception.raise_exception;
         END IF;
        END;

  END trkp_ins_dflt_trst;

  PROCEDURE trkp_ins_trk_item(
    p_tracking_status IN VARCHAR2 ,
    p_tracking_type IN VARCHAR2 ,
    p_source_person_id IN NUMBER ,
    p_start_dt IN DATE ,
    p_target_days IN NUMBER ,
    p_sequence_ind IN VARCHAR2 ,
    p_business_days_ind IN VARCHAR2 ,
    p_originator_person_id IN NUMBER ,
    p_s_created_ind IN VARCHAR2 ,
    p_tracking_id OUT NOCOPY NUMBER ,
    p_message_name OUT NOCOPY VARCHAR2,
    p_override_offset_clc_ind IN VARCHAR2 ,
    p_completion_due_dt IN DATE ,
    p_publish_ind IN VARCHAR2  )
  IS

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1.  This procedure will be used by batch processing to create a tracking item
         It will accept the details of the item to be created and insert a
         IGS_TR_ITEM record. The tracking item step will be defaulted
         when the database table  insert trigger fires for the tracking item.

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR007.FMB

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        06 Jul,2001     Added 3 new columns : completion due dt,
                                  override offset clc ind and publish ind
  ssawhney        18 Oct 2002     p_target_days, use NVL with cursor value. RE03 was not passing them
  *******************************************************************************/

    gv_other_detail  VARCHAR2(255);
    lv_param_values  VARCHAR2(1080);
    v_completion_due_dt igs_tr_item.completion_due_dt%TYPE;

  BEGIN

    -- trkp_ins_trk_item
    -- This procedure will be used by batch processing to create a tracking item
    -- It will accept the details of the item to be created and insert a
    -- IGS_TR_ITEM record. The tracking item step will be defaulted
    -- when the database table  insert trigger fires for the tracking item.

    DECLARE

      v_check   CHAR;
      v_tracking_type  igs_tr_type%ROWTYPE;
      v_nxt_tracking_id igs_tr_item.tracking_id%TYPE;
      l_sequence_ind igs_tr_type.sequence_ind%TYPE;
      l_business_days_ind igs_tr_type.business_days_ind%TYPE;
      p_rowid   VARCHAR2(25);

      CURSOR c_tracking_status IS
        SELECT  'x'
        FROM    igs_tr_status
        WHERE   tracking_status = p_tracking_status;

      CURSOR c_tracking_type IS
        SELECT *
        FROM   igs_tr_type
        WHERE  tracking_type = p_tracking_type;

      -- person exists check from person_base_v
      CURSOR c_person (cp_person_id igs_pe_person.person_id%TYPE) IS
        SELECT 'x'
        FROM igs_pe_person_base_v
        WHERE person_id = cp_person_id;

      CURSOR c_tri_nxt_seq_num IS
        SELECT igs_tr_item_tr_id_s.NEXTVAL
        FROM dual;

    BEGIN

      p_message_name := NULL;

      IF (p_tracking_status IS NULL) THEN
        p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
        RETURN;
      END IF;

      OPEN c_tracking_status;

      FETCH c_tracking_status INTO v_check;
      IF (c_tracking_status%NOTFOUND) THEN
        CLOSE c_tracking_status;
        p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
        RETURN;
      END IF;

      CLOSE c_tracking_status;

      IF (p_tracking_type IS NULL) THEN
        p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
        RETURN;
      END IF;

      OPEN c_tracking_type;

      FETCH c_tracking_type INTO v_tracking_type;
        IF (c_tracking_type%NOTFOUND) THEN
          CLOSE c_tracking_type;
          p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
          RETURN;
        END IF;

      CLOSE c_tracking_type;

      IF (p_originator_person_id IS NULL) THEN
        p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
        RETURN;
      END IF;

      OPEN c_person(p_originator_person_id);
      FETCH c_person INTO v_check;

      IF (c_person%NOTFOUND) THEN
        CLOSE c_person;
	p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
        RETURN;
      END IF;

      CLOSE c_person;

      IF (p_source_person_id IS NOT NULL) THEN
        OPEN c_person(p_source_person_id);
        FETCH c_person INTO v_check;
        IF (c_person%NOTFOUND) THEN
          CLOSE c_person;
          p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
          RETURN;
        END IF;
        CLOSE c_person;
      END IF;

      l_sequence_ind := NVL(p_sequence_ind, v_tracking_type.sequence_ind);
      l_business_days_ind := NVL(p_business_days_ind, v_tracking_type.business_days_ind);

      IF (l_sequence_ind = 'Y' OR l_business_days_ind = 'Y') AND
         NVL(p_override_offset_clc_ind,'N') = 'Y' THEN
        p_message_name := 'IGS_TR_CANNOT_CHK_SEQ_OR_BD';
        RETURN;
      END IF;

--Manu
      IF NVL(p_override_offset_clc_ind,'N') = 'Y' AND p_completion_due_dt IS NULL THEN
        p_message_name := 'IGS_TR_COMP_DUE_DATE_REQ';
        RETURN;
      END IF;

      IF NVL(p_override_offset_clc_ind,'N') = 'N' AND p_completion_due_dt IS NOT NULL THEN
        p_message_name := 'IGS_TR_COMP_DUE_DATE_NOT_SUPP';
        RETURN;
      END IF;

      -- ssawhney customer bug 2610394,
      -- RE was passing p_target_days as null and because of that v_comp_due_dt was coming out NOCOPY to be same as p_start_dt.

      IF p_completion_due_dt IS NULL THEN
         v_completion_due_dt := igs_tr_gen_001.trkp_clc_dt_offset(p_start_dt,
                                                                  NVL(p_target_days, v_tracking_type.target_days), -- p_target_days,
                                                                  l_business_days_ind,
                                                                  NVL(p_override_offset_clc_ind,'N'));
      END IF;
--Manu

      OPEN c_tri_nxt_seq_num;
      FETCH c_tri_nxt_seq_num INTO v_nxt_tracking_id;
      CLOSE c_tri_nxt_seq_num;
      p_tracking_id := v_nxt_tracking_id;

      igs_tr_item_pkg.insert_row(
        x_rowid => p_rowid,
        x_tracking_id => v_nxt_tracking_id,
        x_tracking_status => p_tracking_status ,
        x_tracking_type => p_tracking_type,
        x_source_person_id => p_source_person_id,
        x_start_dt => NVL(p_start_dt, SYSDATE),
        x_target_days => NVL(p_target_days, v_tracking_type.target_days),
        x_sequence_ind => l_sequence_ind,
        x_business_days_ind => l_business_days_ind,
        x_originator_person_id => p_originator_person_id,
        x_s_created_ind => NVL(p_s_created_ind, 'N'),
        x_mode => 'R',
	x_org_id => igs_ge_gen_003.get_org_id,
	x_override_offset_clc_ind => NVL(p_override_offset_clc_ind,'N'),
        x_completion_due_dt => NVL(p_completion_due_dt,v_completion_due_dt),
        x_publish_ind => p_publish_ind
      );

    END;

    EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_TR_GEN_002.trkp_ins_trk_item'||'-'||SQLERRM);
        igs_ge_msg_stack.ADD;
        lv_param_values:= p_tracking_status ||','||p_tracking_type||','||TO_CHAR(p_source_person_id );
        fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
        fnd_message.set_token('VALUE',lv_param_values);
        igs_ge_msg_stack.ADD;
        lv_param_values:= igs_ge_date.igschar (p_start_dt)||','|| TO_CHAR(p_target_days)||','||p_sequence_ind ;
        fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
        fnd_message.set_token('VALUE',lv_param_values);
        igs_ge_msg_stack.ADD;
        lv_param_values:= p_business_days_ind ||','||TO_CHAR(p_originator_person_id )||','||p_s_created_ind ;
        fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
        fnd_message.set_token('VALUE',lv_param_values);
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;

  END trkp_ins_trk_item;

  FUNCTION trkp_next_step_cmplt (
    p_tracking_id igs_tr_step.tracking_id%TYPE,
    p_tracking_step_number  igs_tr_step.tracking_step_number%TYPE,
    p_step_group_id igs_tr_step.step_group_id%TYPE,
    p_message_name OUT NOCOPY VARCHAR2
    ) RETURN BOOLEAN IS
  ------------------------------------------------------------------
  --Created by  : Apex, Oracle IDC (ssanyal.in)
  --Date created: 15-DEC-1999
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --msrinivi    13 Jul,2001     To check validity of change in by pass flag
  -------------------------------------------------------------------
    lv_param_values  VARCHAR2(1080);
    gv_other_detail  VARCHAR2(255);

    l_prev_grp_step_comp VARCHAR2(1) := 'N';
    l_next_step_comp VARCHAR2(1) := 'N';

    TYPE rec_step_group_id IS RECORD ( step_group_id NUMBER);
    TYPE tab_step_group_id IS TABLE OF
       rec_step_group_id  INDEX BY BINARY_INTEGER;
    plsql_step_group_id tab_step_group_id;
    cnt NUMBER DEFAULT 1;
    l_row_count NUMBER DEFAULT 0;
    l_num_rows NUMBER DEFAULT 0;

  -- ssawhney, table reference included instead of view
    CURSOR c_trst_all IS
      SELECT *
      FROM igs_tr_step
      WHERE tracking_id = p_tracking_id
      ORDER BY tracking_step_number;

    CURSOR c_trst_later IS
      SELECT *
      FROM igs_Tr_step
      WHERE tracking_id = p_tracking_id
      AND tracking_step_number > p_tracking_step_number
      ORDER BY tracking_step_number;

    c_trst_all_rec c_trst_all%ROWTYPE;

    BEGIN
      FOR l_trst_all IN c_trst_all LOOP
        EXIT WHEN (l_trst_all.tracking_step_number =  p_tracking_step_number);
        IF l_trst_all.step_group_id IS NOT NULL AND
           l_trst_all.step_completion_ind = 'Y' THEN
          plsql_step_group_id(cnt).step_group_id := l_trst_all.step_group_id;
          cnt := cnt + 1;
        END IF;
      END LOOP;

      FOR l_trst_all IN c_trst_all LOOP
        l_row_count := l_row_count+1;
        EXIT WHEN (l_trst_all.tracking_step_number =  p_tracking_step_number OR
                   l_prev_grp_step_comp = 'Y');
        IF l_trst_all.completion_dt IS NOT NULL AND
           l_trst_all.step_group_id IS NOT NULL THEN
          IF l_trst_all.step_group_id = p_step_group_id THEN
            l_prev_grp_step_comp := 'Y';
            EXIT;
          END IF;
        END IF;
      END LOOP;

    IF l_prev_grp_step_comp = 'Y' THEN
      RETURN FALSE;
    END IF;

    l_next_step_comp := 'N';

    FOR l_trst_all IN c_trst_all LOOP
      l_num_rows := l_num_rows + 1;
    END LOOP;

    IF l_num_rows = l_row_count THEN
      RETURN FALSE;
    END IF;

    FOR l_trst_later IN c_trst_later LOOP
      EXIT WHEN (l_next_step_comp = 'Y');
      IF (l_trst_later.completion_dt IS NOT NULL) THEN
        IF l_trst_later.step_group_id IS NOT NULL THEN
          l_next_step_comp := 'Y';
          FOR idx IN 1..plsql_step_group_id.COUNT
          LOOP
            IF plsql_step_group_id(idx).step_group_id = l_trst_later.step_group_id THEN
              l_next_step_comp := 'N';
              EXIT;
            END IF;
          END LOOP;
        ELSE
          l_next_step_comp := 'Y';
        END IF;
      END IF;
    END LOOP;

    IF l_next_step_comp = 'Y' THEN
      p_message_name := 'IGS_TR_CANNOT_UNCHK_COMPL_IND';
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_TR_GEN_002.trkp_next_step_cmplt'||'-'||SQLERRM);
        igs_ge_msg_stack.ADD;
        lv_param_values:= TO_CHAR(p_tracking_id) ||','||TO_CHAR(p_tracking_step_number)||','||TO_CHAR(p_step_group_id);
        fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
        fnd_message.set_token('VALUE',lv_param_values);
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
  END trkp_next_step_cmplt;

  FUNCTION trkp_next_grp_step_cmplt (
    p_tracking_id igs_tr_step.tracking_id%TYPE,
    p_tracking_step_number igs_tr_step.tracking_step_number%TYPE,
    p_step_group_id igs_tr_step.step_group_id%TYPE,
    p_message_name OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN IS
  ------------------------------------------------------------------
  --Created by  : Apex, Oracle IDC (ssanyal.in)
  --Date created: 15-DEC-1999
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  lv_param_values  VARCHAR2(1080);
  gv_other_detail  VARCHAR2(255);

  l_next_step_comp VARCHAR2(1) := 'N';

  TYPE rec_step_group_id IS RECORD ( step_group_id NUMBER);
  TYPE tab_step_group_id IS TABLE OF
       rec_step_group_id  INDEX BY BINARY_INTEGER;
  plsql_step_group_id tab_step_group_id;
  cnt NUMBER DEFAULT 1;
  l_row_count NUMBER DEFAULT 0;
  l_num_rows NUMBER DEFAULT 0;

  --ssawhney, view reference changed to table.
  CURSOR c_trst_later IS
    SELECT *
    FROM igs_tr_step
    WHERE tracking_id = p_tracking_id
    AND tracking_step_number > p_tracking_step_number
    ORDER BY tracking_step_number;

  CURSOR c_trst_all IS
    SELECT *
    FROM igs_tr_step
    WHERE tracking_id = p_tracking_id
    ORDER BY tracking_step_number;

  CURSOR c_trst_next(p_tracking_step_number NUMBER) IS
    SELECT *
    FROM igs_tr_step
    WHERE tracking_id = p_tracking_id
    AND tracking_step_number > p_tracking_step_number
    ORDER BY tracking_step_number;

  c_trst_all_rec c_trst_all%ROWTYPE;
  c_trst_later_rec c_trst_later%ROWTYPE;

  BEGIN

    OPEN c_trst_later;
    FETCH c_trst_later INTO c_trst_later_rec;
      IF (c_trst_later%NOTFOUND) THEN
        CLOSE c_trst_later;
        RETURN FALSE;
      END IF;
    CLOSE c_trst_later;

    FOR l_trst_all IN c_trst_all LOOP
      EXIT WHEN (l_trst_all.tracking_step_number = p_tracking_step_number);
      IF l_trst_all.step_group_id IS NOT NULL AND
         l_trst_all.step_completion_ind = 'Y' THEN
        plsql_step_group_id(cnt).step_group_id := l_trst_all.step_group_id;
        cnt := cnt + 1;
      END IF;
    END LOOP;

    l_row_count := p_tracking_step_number;

    FOR l_trst_later IN c_trst_later LOOP
      l_row_count := l_row_count + 1;
      IF (l_trst_later.step_group_id = p_step_group_id AND
          l_trst_later.step_completion_ind = 'N' AND
          l_trst_later.by_pass_ind = 'N') THEN
        EXIT;
      END IF;
    END LOOP;

    FOR l_trst_all IN c_trst_all LOOP
      l_num_rows := l_num_rows + 1;
    END LOOP;

    l_next_step_comp := 'N';

    IF l_num_rows =  l_row_count THEN
      RETURN FALSE;
    END IF;

    FOR l_trst_next IN c_trst_next(l_row_count) LOOP
      EXIT WHEN (l_next_step_comp = 'Y');
      IF l_trst_next.completion_dt IS NOT NULL THEN
        l_next_step_comp := 'Y';
      ELSE
        l_next_step_comp := 'N';
      END IF;
    END LOOP;

    IF l_next_step_comp = 'Y' THEN
      p_message_name := 'IGS_TR_CANNOT_CHK_BYPAS_IND';
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_TR_GEN_002.trkp_next_grp_step_cmplt'||'-'||SQLERRM);
        igs_ge_msg_stack.ADD;
        lv_param_values:= TO_CHAR(p_tracking_id) ||','||TO_CHAR(p_tracking_step_number)||','||TO_CHAR(p_step_group_id);
        fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
        fnd_message.set_token('VALUE',lv_param_values);
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
  END trkp_next_grp_step_cmplt;


  FUNCTION trkp_check_step_group_limit (
    p_tracking_id  IN igs_tr_step.tracking_id%TYPE,
    p_tracking_step_number IN igs_tr_step.tracking_step_number%TYPE,
    p_step_group_id IN igs_tr_step.step_group_id%TYPE,
    p_message_name OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN IS
  ------------------------------------------------------------------
  --Created by  : pradhakr, Oracle IDC
  --Date created: 11-FEB-2002
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  lv_param_values  VARCHAR2(1080);

  --  Cursor to get all step group ids and the number of completed steps prior to the
  --  passed step group id (p_step_group_id) and tracking step number (p_ tracking_step_number) and
  --  comparing the result with the one in the table IGS_TR_STEP_GRP_LMT

    CURSOR c_grp_limit IS
    SELECT tab.step_group_id, tab.step_group_limit
    FROM
	  ( SELECT step_group_id, count(*) step_group_limit
	    FROM   igs_tr_step trst
	    WHERE  trst.tracking_id = p_tracking_id
	    AND    trst.tracking_step_number < p_tracking_step_number
	    AND    trst.step_group_id is not null
	    AND    trst.step_group_id <> p_step_group_id
	    AND    trst.step_completion_ind = 'Y'
	    AND    trst.by_pass_ind = 'N'
	    GROUP BY trst.step_group_id, trst.step_completion_ind
	    MINUS
	    SELECT step_group_id, step_group_limit
	    FROM   igs_tr_step_grp_lmt
	    WHERE  tracking_id = p_tracking_id
	  ) tab ,
	    igs_tr_step_grp_lmt trg
    WHERE   tab.step_group_id = trg.step_group_id
     AND    trg.tracking_id = p_tracking_id
    AND     tab.step_group_limit < trg.step_group_limit ;

    l_grp_limit c_grp_limit%ROWTYPE;

  BEGIN

    OPEN c_grp_limit;
    FETCH c_grp_limit INTO l_grp_limit;
    -- If record exists, it means that some of the step group limit has not been met for the step group id.
    IF c_grp_limit%FOUND THEN
       p_message_name := 'IGS_TR_STEP_GRPLMT_VIOLATE';
       RETURN FALSE;
    ELSE
       RETURN TRUE;
    END IF;
    CLOSE c_grp_limit;

  EXCEPTION
    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_TR_GEN_002.trkp_check_step_group_limit'||'-'||SQLERRM);
        igs_ge_msg_stack.add;
        lv_param_values:= TO_CHAR(p_tracking_id) ||','||TO_CHAR(p_tracking_step_number)||','||TO_CHAR(p_step_group_id);
        fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
        fnd_message.set_token('VALUE',lv_param_values);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END trkp_check_step_group_limit;


  FUNCTION trkp_prev_step_cmplt (
    p_tracking_id igs_tr_step.tracking_id%TYPE,
    p_tracking_step_number igs_tr_step.tracking_step_number%TYPE,
    p_step_group_id igs_tr_step.step_group_id%TYPE,
    p_message_name OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN IS
  ------------------------------------------------------------------
  --Created by  : Apex, Oracle IDC (ssanyal.in)
  --Date created: 15-DEC-1999
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
    lv_param_values  VARCHAR2(1080);
    gv_other_detail  VARCHAR2(255);


    CURSOR c_earlier_step_trst IS
      SELECT DISTINCT TO_NUMBER('1')
      FROM igs_tr_step trst
      WHERE trst.tracking_id = p_tracking_id
      AND   trst.tracking_step_number < p_tracking_step_number
      AND   trst.step_group_id IS NULL
      AND   trst.step_completion_ind = 'N'
      AND   trst.by_pass_ind = 'N'
      UNION
      (
       SELECT   DISTINCT trst.step_group_id
       FROM     igs_tr_step trst
       WHERE    trst.tracking_id = p_tracking_id
       AND      trst.tracking_step_number < p_tracking_step_number
       AND      trst.step_group_id IS NOT NULL
       AND      trst.step_completion_ind = 'N'
       AND      trst.by_pass_ind = 'N'
       GROUP BY   trst.step_group_id, trst.step_completion_ind
       MINUS
       SELECT   DISTINCT trst.step_group_id
       FROM     igs_tr_step trst
       WHERE    trst.tracking_id = p_tracking_id
       AND      trst.tracking_step_number < p_tracking_step_number
       AND      trst.step_group_id IS NOT NULL
       AND      trst.step_completion_ind = 'Y'
       GROUP BY trst.step_group_id, trst.step_completion_ind
      );
    v_step_completion_ind_temp NUMBER;

  BEGIN

     OPEN c_earlier_step_trst;
     FETCH c_earlier_step_trst INTO v_step_completion_ind_temp;
     IF (c_earlier_step_trst%FOUND) THEN
       CLOSE c_earlier_step_trst;
       p_message_name := 'IGS_TR_PREV_STEP_COMPLETED';
       RETURN FALSE;
     END IF;
     CLOSE c_earlier_step_trst;

     IF trkp_check_step_group_limit (
                                  p_tracking_id,
		                  p_tracking_step_number,
                    	          p_step_group_id,
		                  p_message_name   ) THEN

        RETURN TRUE;
     ELSE
        RETURN FALSE;
     END IF;

  EXCEPTION
    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_TR_GEN_002.trkp_next_grp_step_cmplt'||'-'||SQLERRM);
        igs_ge_msg_stack.ADD;
        lv_param_values:= TO_CHAR(p_tracking_id) ||','||TO_CHAR(p_tracking_step_number);
        fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
        fnd_message.set_token('VALUE',lv_param_values);
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
  END trkp_prev_step_cmplt;


  FUNCTION trkp_upd_trst(
    p_tracking_id IN NUMBER ,
    p_tracking_step_id IN NUMBER ,
    p_s_tracking_step_type IN VARCHAR2 ,
    p_action_dt IN DATE ,
    p_completion_dt IN DATE ,
    p_step_completion_ind IN VARCHAR2,
    p_by_pass_ind IN VARCHAR2,
    p_recipient_id IN NUMBER ,
    p_message_name OUT NOCOPY VARCHAR2
  )
  RETURN BOOLEAN AS

  /***********************************************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1.  This module will update fields of the action days of
         a IGS_TR_STEP record.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR007.FMB

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When           What

  msrinivi       06 Jul,2001     Modified to have the logic for step groups before update. msrinivi
				 11 Jul,2001     Step update not allowed if item is complete,
                                 Complete item if all the steps are considered complete

  Aiyer          24-Apr-2002     This code has been modified by Aiyer for the bug 2309359
                                 In call to function igs_tr_gen_001.trkp_clc_bus_dt the p_business_days
				 parameter was being passed as 'N'.This was causing a numeric conversion error .
				 This has been set to NVL(p_action_days,0) in this fix.

  ssawhney       4-Nov-2003	 Bug 3206700. The cursor to check item completion modified.
				 Logic also modified to concider BY PASS item as complete.
  **************************************************************************************************************/

    lv_param_values  VARCHAR2(1080);
    gv_other_detail  VARCHAR2(255);


  BEGIN

    -- trkp_upd_trst
    -- This module will update fields of the action days of
    -- a IGS_TR_STEP record.

    DECLARE

      e_resource_busy_exception EXCEPTION;

      PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);

      v_tracking_step_id igs_tr_step.tracking_step_id%TYPE;
      v_action_days  NUMBER;
      v_completion_dt  igs_tr_step.completion_dt%TYPE;
      v_step_completion_ind igs_tr_step.step_completion_ind%TYPE;
      v_by_pass_ind  igs_tr_step.by_pass_ind%TYPE;
      v_recipient_id  igs_tr_step.recipient_id%TYPE;
      v_start_dt  igs_tr_item.start_dt%TYPE;
      v_business_days_ind igs_tr_item.business_days_ind%TYPE;
      v_sequence_ind  igs_tr_item.sequence_ind%TYPE;
      v_step_completion_ind_temp igs_tr_step.step_completion_ind%TYPE;
      v_action_dt  igs_tr_step_v.action_dt%TYPE;
      v_message_name  VARCHAR2(30);
      v_rowid   VARCHAR2(25);
      v_step_group_id igs_tr_step.step_group_id%TYPE;
      v_tracking_step_number igs_tr_step.tracking_step_number%TYPE;
      l_field_mod VARCHAR2(10) := NULL;
      l_end_dt DATE;
      l_action_days igs_tr_step.action_days%TYPE;
      l_action_dt DATE;

      TYPE rec_step_group_id IS RECORD ( step_group_id NUMBER);
      TYPE tab_step_group_id IS TABLE OF
        rec_step_group_id  INDEX BY BINARY_INTEGER;
      plsql_step_group_id tab_step_group_id;
      cnt NUMBER DEFAULT 1;

      CURSOR c_tri_all IS
        SELECT *
        FROM igs_tr_item
        WHERE tracking_id = p_tracking_id;

      CURSOR c_sys_trk_sts(p_tracking_status igs_tr_status.tracking_status%TYPE) IS
        SELECT s_tracking_status
        FROM igs_tr_status
        WHERE tracking_status = p_tracking_status;

      --ssawhney cant change view reference..using view logic in select.
      CURSOR c_update_trst IS
        SELECT trst.*, trst.rowid ROW_ID, igs_tr_gen_001.trkp_clc_action_dt ( trst.tracking_id, trst.tracking_step_number,
							tri.start_dt, tri.sequence_ind,tri.business_days_ind ) action_dt
          FROM   igs_tr_step trst,
	         igs_tr_item tri
          WHERE  trst.tracking_id = p_tracking_id
	  AND    trst.tracking_id = tri.tracking_id
	  AND   ((NVL(p_tracking_step_id, 0) = 0)
	        OR
                (trst.tracking_step_id = p_tracking_step_id))
	  AND    ((NVL(p_s_tracking_step_type, 'NULL') = 'NULL')
	        OR
                (trst.s_tracking_step_type = p_s_tracking_step_type))
	  AND    ROWNUM = 1
        ORDER BY trst.tracking_step_number DESC
        FOR  UPDATE OF trst.action_days NOWAIT;

        --Added by Manu to check if the item should be marked as complete
        --if the all the steps can be considered as complete
	-- Cursor modified for Bug 3206700
	-- first half gets info if any step outside the group is not complete
	-- second half gets info if any group has steps open/bypass or steps are complete by group limit is not achieved.

	--ssawhney view reference changed to table.
	CURSOR   c_check_item_cmpltn  IS
	SELECT DISTINCT TO_NUMBER('1')
        FROM igs_tr_step trst
        WHERE trst.tracking_id = p_tracking_id
        AND trst.step_group_id IS NULL
        AND trst.step_completion_ind = 'N'
        AND trst.by_pass_ind = 'N'
        UNION
        (
         SELECT distinct step_group_id
         FROM igs_tr_step a
         WHERE a.tracking_id = p_tracking_id
         AND a.step_group_id IS NOT NULL
-- total no of groups for the tracking item
         MINUS
-- subtract groups that are open
         SELECT c.step_group_id
         FROM (
               SELECT tab.step_group_id, tab.count_step
               FROM (
                     SELECT  trst.step_group_id step_group_id,
                             COUNT(*) count_step
                     FROM    igs_tr_step trst
                     WHERE   trst.tracking_id = p_tracking_id
                     AND     trst.step_group_id IS NOT NULL
                     AND     ((trst.step_completion_ind = 'Y' AND trst.by_pass_ind = 'N') OR
		              (trst.step_completion_ind = 'N' AND trst.by_pass_ind = 'Y'))
                     GROUP BY   trst.step_group_id,
                                trst.step_completion_ind
                    ) tab,
-- a step is considered complete if either its BY PASSED or its completion ind is Y
                    igs_tr_step_grp_lmt trg
               WHERE tab.step_group_id = trg.step_group_id
                AND  trg.tracking_id = p_tracking_id
               AND   tab.count_step >= trg.step_group_limit
-- subtract only if the total steps completed are less than the group limit.
             ) c
        );

      CURSOR c_dflt_trk_sts IS
        SELECT tracking_status
        FROM igs_tr_status
        WHERE s_tracking_status = 'COMPLETE'
        AND default_ind = 'Y';

      igs_tr_step_rec  c_update_trst%ROWTYPE;
      igs_tr_item_rec  c_tri_all%ROWTYPE;
      l_sys_trk_sts igs_tr_status.s_tracking_status%TYPE;
      l_trk_sts igs_tr_status.tracking_status%TYPE;
      l_item_cmpl c_check_item_cmpltn%ROWTYPE;

      -- validitate action / completion date and get action days
      FUNCTION process_date (
          p_date_type IN VARCHAR2,
          p_tracking_id IN igs_tr_step.tracking_id%TYPE,
          p_tracking_step_number IN igs_tr_step.tracking_step_number%TYPE,
          p_end_dt IN OUT NOCOPY DATE,
          p_action_days IN OUT NOCOPY igs_tr_step.action_days%TYPE,
          p_message_name OUT NOCOPY VARCHAR2
      )RETURN BOOLEAN IS
        --ssawhney view reference changed to table in the second part..first part still referes to the function for getting the dates.

        CURSOR c_start_dt IS
          SELECT NVL(trst.completion_dt,igs_tr_gen_001.trkp_clc_action_dt ( trst.tracking_id, trst.tracking_step_number,
							tri.start_dt, tri.sequence_ind,tri.business_days_ind )) start_dt
          FROM   igs_tr_step trst, igs_tr_item tri
          WHERE  trst.tracking_id = tri.tracking_id
	  AND    trst.tracking_id = p_tracking_id
          AND    trst.tracking_step_number = (SELECT MAX(b.tracking_step_number)
                                         FROM   igs_tr_step b
                                         WHERE  b.tracking_id = p_tracking_id
                                         AND    b.tracking_step_number < p_tracking_step_number
                                         AND    b.by_pass_ind = 'N');

         --ssawhney view reference changed to table and introduced fucntions.
        CURSOR c_upd_next_dt IS
          SELECT trst.*, trst.rowid ROW_ID, igs_tr_gen_001.trkp_clc_action_dt ( trst.tracking_id, trst.tracking_step_number,
							tri.start_dt, tri.sequence_ind,tri.business_days_ind ) action_dt
          FROM   igs_tr_step trst,
	         igs_tr_item tri
          WHERE  trst.tracking_id = tri.tracking_id
	  AND    trst.tracking_id = p_tracking_id
          AND    trst.tracking_step_number > p_tracking_step_number
          FOR  UPDATE OF trst.action_days NOWAIT;

        l_start_dt DATE;
        l_p_action_dt DATE;
        l_action_days igs_tr_step.action_days%TYPE;
        l_next_start_dt_diff NUMBER;
        l_next_start_dt DATE;

        FUNCTION validate_date (
            p_date_type IN VARCHAR2,
            p_tracking_id IN igs_tr_step.tracking_id%TYPE,
            p_tracking_step_number IN igs_tr_step.tracking_step_number%TYPE,
            p_start_dt IN DATE,
            p_end_dt IN OUT NOCOPY DATE,
            p_action_days IN OUT NOCOPY igs_tr_step.action_days%TYPE,
            p_message_name OUT NOCOPY VARCHAR2
        )RETURN BOOLEAN IS

          l_clc_end_dt DATE;

        BEGIN
          IF p_start_dt > p_end_dt THEN
            p_message_name := 'IGS_TR_DT_CANNOT_LT_ST_DATE';
            RETURN FALSE;
          END IF;

          IF igs_tr_item_rec.business_days_ind = 'Y' THEN
            -- This code has been changed by Aiyer for the bug 2309359
	    -- In function igs_tr_gen_001.trkp_clc_bus_dt the p_business_days parameter was being passed as 'N'.
	    -- This was causing a numeric conversion error . This has been set to NVL(p_action_days,0) in this fix.
            l_clc_end_dt := igs_tr_gen_001.trkp_clc_bus_dt(p_end_dt, NVL(p_action_days,0));

            IF p_end_dt IS NOT NULL AND p_end_dt <> l_clc_end_dt THEN
              p_end_dt := l_clc_end_dt;
              RETURN FALSE;
            ELSE
              p_end_dt := l_clc_end_dt;
            END IF;
          END IF;

	  -- Validate that the action days has not exceeded the maximum allowable.
	  --kumma, 2719789, Increased the length of the constant from 999 to 9999
          IF (TRUNC(p_start_dt) - TRUNC(p_end_dt)) > 9999 THEN
            p_message_name := 'IGS_TR_MAXIMUM_DAYS_EXCEEDED';
            RETURN FALSE;
          ELSE
            IF p_date_type = 'A' THEN
              p_action_days := TRUNC(p_end_dt) - TRUNC(p_start_dt);
            END IF;
          END IF;

          RETURN TRUE;
        EXCEPTION

          WHEN OTHERS THEN
            fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
            fnd_message.set_token('NAME','IGS_TR_GEN_002.trkp_upd_trst.process_date.validate_date'||'-'||SQLERRM);
            igs_ge_msg_stack.ADD;
            lv_param_values:= TO_CHAR(p_tracking_id) ||','||TO_CHAR(p_tracking_step_number)||','||TO_CHAR(p_action_days)
                              ||','||p_date_type||','||igs_ge_date.igschar (p_start_dt)
                              ||','||igs_ge_date.igschar (p_end_dt);
            fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
            fnd_message.set_token('VALUE',lv_param_values);
            igs_ge_msg_stack.ADD;
            app_exception.raise_exception;
        END validate_date;

      BEGIN
        IF igs_tr_item_rec.sequence_ind = 'Y' THEN
          IF (p_tracking_step_number - 1) = 0  THEN
            l_start_dt := igs_tr_item_rec.start_dt;
          ELSE
            OPEN c_start_dt;
            FETCH c_start_dt INTO l_start_dt;
            CLOSE c_start_dt;
          END IF;
        ELSE
          l_start_dt := igs_tr_item_rec.start_dt;
        END IF;

        IF NOT (validate_date (p_date_type,
                               p_tracking_id,
                               p_tracking_step_number,
                               l_start_dt,
                               p_end_dt,
                               p_action_days,
                               p_message_name)) THEN
          RETURN FALSE;
        END IF;

        IF p_date_type = 'A' THEN
          l_next_start_dt_diff := TRUNC(p_end_dt) - TRUNC(igs_tr_step_rec.action_dt);
          l_next_start_dt := TRUNC(p_end_dt);
        ELSIF p_date_type = 'C' THEN
          l_next_start_dt_diff := TRUNC(p_end_dt) - TRUNC(igs_tr_step_rec.completion_dt);
          l_next_start_dt := TRUNC(p_end_dt);
        END IF;

        IF igs_tr_item_rec.sequence_ind = 'Y' THEN

          FOR l_upd_next_dt_rec IN c_upd_next_dt LOOP

            IF (l_upd_next_dt_rec.step_completion_ind = 'N' AND l_upd_next_dt_rec.by_pass_ind = 'N') THEN

              l_p_action_dt := l_next_start_dt + l_upd_next_dt_rec.action_days;
              IF NOT (validate_date ('A',
                                     l_upd_next_dt_rec.tracking_id,
                                     l_upd_next_dt_rec.tracking_step_number,
                                     l_next_start_dt,
                                     l_p_action_dt,
                                     l_action_days,
                                     p_message_name)) THEN
                RETURN FALSE;
              END IF;

              -- Update the record with NOWAIT option

              IF p_date_type = 'C' THEN
                l_action_days := l_upd_next_dt_rec.action_days;
              END IF;

              igs_tr_step_pkg.update_row(
                  x_rowid                => l_upd_next_dt_rec.row_id,
                  x_tracking_id          => l_upd_next_dt_rec.tracking_id,
                  x_tracking_step_id     => l_upd_next_dt_rec.tracking_step_id,
                  x_tracking_step_number => l_upd_next_dt_rec.tracking_step_number,
                  x_description          => l_upd_next_dt_rec.description,
                  x_s_tracking_step_type => l_upd_next_dt_rec.s_tracking_step_type,
                  x_completion_dt        => l_upd_next_dt_rec.completion_dt,
                  x_action_days          => l_action_days,
                  x_step_completion_ind  => l_upd_next_dt_rec.step_completion_ind,
                  x_by_pass_ind          => l_upd_next_dt_rec.by_pass_ind,
                  x_recipient_id         => l_upd_next_dt_rec.recipient_id,
                  x_mode                 => 'R',
                  x_step_group_id        => l_upd_next_dt_rec.step_group_id,
                  x_step_catalog_cd      => l_upd_next_dt_rec.step_catalog_cd,
                  x_publish_ind          => NVL(l_upd_next_dt_rec.publish_ind,'N')
               );

              l_next_start_dt_diff := TRUNC(l_p_action_dt) - TRUNC(l_upd_next_dt_rec.action_dt);
              l_next_start_dt := TRUNC(l_p_action_dt);

            ELSIF l_upd_next_dt_rec.step_completion_ind = 'Y' THEN
              l_next_start_dt_diff := 0;
              l_next_start_dt := TRUNC(l_upd_next_dt_rec.completion_dt);

            ELSIF l_upd_next_dt_rec.by_pass_ind = 'Y' THEN
              NULL;
            END IF;

          END LOOP;
        END IF;

        RETURN TRUE;

      EXCEPTION
        WHEN e_resource_busy_exception THEN
          p_message_name := 'IGS_TR_CANNOT_UPDATE_STEP';
          RETURN FALSE;

        WHEN OTHERS THEN
          fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
          fnd_message.set_token('NAME','IGS_TR_GEN_002.trkp_upd_trst.process_date'||'-'||SQLERRM);
          igs_ge_msg_stack.ADD;
          lv_param_values:= p_date_type||','||TO_CHAR(p_tracking_id) ||','||TO_CHAR(p_tracking_step_number)||
                            ','||igs_ge_date.igschar (p_end_dt)||','||TO_CHAR(p_action_days);
          fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
          fnd_message.set_token('VALUE',lv_param_values);
          igs_ge_msg_stack.ADD;
          app_exception.raise_exception;
      END process_date;

    BEGIN

      -- Set the default message number
      p_message_name := NULL;

      -- Validate that p_tracking_step_id and p_s_tracking_step_type cannot both be null.
      IF ((p_tracking_step_id IS NULL) AND (p_s_tracking_step_type IS NULL)) THEN
        p_message_name := 'IGS_TR_STEP_TYPE_ID_NOT_NULL';
        RETURN FALSE;
      END IF;

      -- Manu Validate that the step being updated does not
      -- belong to an item that is complete
      OPEN c_tri_all;
      FETCH c_tri_all INTO igs_tr_item_rec;

      IF c_tri_all%NOTFOUND THEN
        CLOSE c_tri_all;
        p_message_name := 'IGS_TR_INVALID_ITEM_ID';
        RETURN FALSE;

      ELSE
        OPEN c_sys_trk_sts(igs_tr_item_rec.tracking_status);
        FETCH c_sys_trk_sts INTO l_sys_trk_sts;
        CLOSE c_sys_trk_sts;

        IF (l_sys_trk_sts <> 'ACTIVE') THEN
          p_message_name := 'IGS_TR_ST_UPD_CMPLT_ITM_NA';
          CLOSE c_tri_all;
          RETURN FALSE;
        END IF;

        CLOSE c_tri_all;
      END IF;

      -- Select the original fields of the tracking step record for UPDATE NOWWAIT.
      -- Select only the first record from this query if p_tracking_id is null and
      -- multiple steps having the same s_tracking_step_type exists,
      -- since we are only interested in the first one.

      OPEN c_update_trst;
      FETCH c_update_trst INTO igs_tr_step_rec ;

      IF (c_update_trst%NOTFOUND) THEN
        CLOSE c_update_trst;
        p_message_name := 'IGS_TR_INVALID_STEP_ID';
        RETURN FALSE;
      END IF;

      IF (p_step_completion_ind IS NOT NULL AND
          p_step_completion_ind <> igs_tr_step_rec.step_completion_ind) THEN
        l_field_mod := l_field_mod || 'S';
      END IF;

      IF (p_by_pass_ind IS NOT NULL AND
          p_by_pass_ind <> igs_tr_step_rec.by_pass_ind) THEN
        l_field_mod := l_field_mod || 'B';
      END IF;

      IF (igs_tr_item_rec.override_offset_clc_ind = 'N' AND
          p_action_dt IS NOT NULL AND
          p_action_dt <> igs_tr_step_rec.action_dt AND
          igs_tr_step_rec.step_completion_ind = 'N' AND
          igs_tr_step_rec.by_pass_ind = 'N') THEN
        IF (igs_tr_item_rec.sequence_ind = 'Y' AND
            NVL(INSTR(l_field_mod,'S'),0) = 0 AND
            NVL(INSTR(l_field_mod,'B'),0) = 0) OR
           (igs_tr_item_rec.sequence_ind = 'N') THEN
          l_field_mod := l_field_mod || 'A';
        END IF;
      END IF;

      IF (NVL(INSTR(l_field_mod,'S'),0) = 0 AND
          NVL(INSTR(l_field_mod,'B'),0) = 0) THEN
        IF (p_completion_dt IS NOT NULL AND
          igs_tr_step_rec.step_completion_ind = 'Y' AND
          p_completion_dt <> igs_tr_step_rec.completion_dt) THEN
          l_field_mod := l_field_mod || 'C';
        END IF;
      END IF;

      IF (NVL(INSTR(l_field_mod,'S'),0) = 0 AND
          NVL(INSTR(l_field_mod,'B'),0) = 0 AND
          igs_tr_step_rec.step_completion_ind = 'N' AND
          igs_tr_step_rec.by_pass_ind = 'N') OR
         NVL(INSTR(l_field_mod,'S'),0) > 0 OR
         NVL(INSTR(l_field_mod,'B'),0) > 0 THEN
        IF (p_recipient_id IS NOT NULL) THEN
          IF (igs_tr_step_rec.recipient_id IS NOT NULL AND
              p_recipient_id <> igs_tr_step_rec.recipient_id ) OR
             (igs_tr_step_rec.recipient_id IS NULL) THEN
            l_field_mod := l_field_mod || 'R';
          END IF;
        END IF;
      END IF;

      -- Validate that the step being updated does not modify
      -- step_completion_ind and by_pass_ind together to 'Y'
      IF ((p_step_completion_ind = 'Y') AND
          (p_by_pass_ind = 'Y')) THEN
        p_message_name := 'IGS_TR_BOTH_CMP_BYPAS_UPD_Y_NA';
        CLOSE c_update_trst;
        RETURN FALSE;
      END IF;

      IF (igs_tr_item_rec.sequence_ind = 'Y') THEN
        IF NVL(INSTR(l_field_mod,'S'),0) > 0 THEN
          IF p_step_completion_ind = 'Y' THEN
          -- Validate new value, on error return false
            IF trkp_prev_step_cmplt (
                   igs_tr_step_rec.tracking_id,
                   igs_tr_step_rec.tracking_step_number,
                   igs_tr_step_rec.step_group_id,
                   p_message_name) THEN

              igs_tr_step_rec.step_completion_ind := 'Y';
              igs_tr_step_rec.by_pass_ind := 'N';

              l_end_dt := NVL(p_completion_dt,SYSDATE);
              IF NOT (process_date (
                      'C',
                      igs_tr_step_rec.tracking_id,
                      igs_tr_step_rec.tracking_step_number,
                      l_end_dt,
                      l_action_days,
                      p_message_name)) THEN
                CLOSE c_update_trst;
                RETURN FALSE;
              END IF;
              igs_tr_step_rec.completion_dt := l_end_dt;

            ELSE
              CLOSE c_update_trst;
              RETURN FALSE;
            END IF;

          ELSIF p_step_completion_ind = 'N' THEN
            -- Validate new value, on error return false
            IF NOT (trkp_next_step_cmplt (
                   igs_tr_step_rec.tracking_id,
                   igs_tr_step_rec.tracking_step_number,
                   igs_tr_step_rec.step_group_id,
                   p_message_name)) THEN

              IF NVL(INSTR(l_field_mod,'C'),0) > 0 AND
                 p_completion_dt IS NOT NULL THEN
                p_message_name := 'IGS_TR_CANNOT_SET_CMP_DATE';
                CLOSE c_update_trst;
                RETURN FALSE;
              END IF;

              igs_tr_step_rec.step_completion_ind := 'N';
              igs_tr_step_rec.completion_dt := NULL;
              IF NVL(INSTR(l_field_mod,'A'),0) = 0 THEN
                l_action_dt := NVL(p_action_dt,igs_tr_step_rec.action_dt);
                l_field_mod := l_field_mod || 'A';
              END IF;

            ELSE
              CLOSE c_update_trst;
              RETURN FALSE;
            END IF;
          END IF;

        END IF;

        IF NVL(INSTR(l_field_mod,'B'),0) > 0 THEN
          IF p_by_pass_ind = 'Y' THEN
            -- Validate new value, on error return false
            IF NOT (trkp_next_grp_step_cmplt (
                   igs_tr_step_rec.tracking_id,
                   igs_tr_step_rec.tracking_step_number,
                   igs_tr_step_rec.step_group_id,
                   p_message_name)) THEN

              IF NVL(INSTR(l_field_mod,'C'),0) > 0 AND
                 p_completion_dt IS NOT NULL THEN
                p_message_name := 'IGS_TR_CANNOT_SET_CMP_DATE';
                CLOSE c_update_trst;
                RETURN FALSE;
              END IF;

              igs_tr_step_rec.step_completion_ind := 'N';
              igs_tr_step_rec.by_pass_ind := 'Y';
              igs_tr_step_rec.completion_dt := NULL;
              IF NVL(INSTR(l_field_mod,'A'),0) = 0 THEN
                l_action_dt := NVL(p_action_dt,igs_tr_step_rec.action_dt);
                l_field_mod := l_field_mod || 'A';
              END IF;

            ELSE
              CLOSE c_update_trst;
              RETURN FALSE;
            END IF;

          ELSIF p_by_pass_ind = 'N' THEN
            -- Validate new value, on error return false
            IF NOT (trkp_next_step_cmplt (
                   igs_tr_step_rec.tracking_id,
                   igs_tr_step_rec.tracking_step_number,
                   igs_tr_step_rec.step_group_id,
                   p_message_name)) THEN
              IF NVL(INSTR(l_field_mod,'C'),0) > 0 THEN
                p_message_name := 'IGS_TR_CANNOT_SET_CMP_DATE';
                CLOSE c_update_trst;
                RETURN FALSE;
              END IF;

              igs_tr_step_rec.by_pass_ind := 'N';

            ELSE
              CLOSE c_update_trst;
              RETURN FALSE;
            END IF;
          END IF;

        END IF;

        IF NVL(INSTR(l_field_mod,'A'),0) > 0 THEN
          -- Validate new value, on error return false
          l_end_dt := NVL(p_action_dt,l_action_dt);
          IF NOT (process_date (
                  'A',
                  igs_tr_step_rec.tracking_id,
                  igs_tr_step_rec.tracking_step_number,
                  l_end_dt,
                  l_action_days,
                  p_message_name)) THEN
            CLOSE c_update_trst;
            RETURN FALSE;
          END IF;

          igs_tr_step_rec.action_dt := l_end_dt;
          igs_tr_step_rec.action_days := l_action_days;

        END IF;

        IF NVL(INSTR(l_field_mod,'C'),0) > 0 THEN
          -- Validate new value, on error return false

          l_end_dt := NVL(p_completion_dt,SYSDATE);
          IF NOT (process_date (
                  'C',
                  igs_tr_step_rec.tracking_id,
                  igs_tr_step_rec.tracking_step_number,
                  l_end_dt,
                  l_action_days,
                  p_message_name)) THEN
            CLOSE c_update_trst;
            RETURN FALSE;
          END IF;
          igs_tr_step_rec.completion_dt := l_end_dt;
        END IF;

        IF NVL(INSTR(l_field_mod,'R'),0) > 0 THEN
          -- Validate new value, on error return false

          IF NOT (igs_co_val_oc.genp_val_prsn_id(p_recipient_id, p_message_name)) THEN
            CLOSE c_update_trst;
            RETURN FALSE;
          ELSE
            igs_tr_step_rec.recipient_id := p_recipient_id;
          END IF;

        END IF;

      ELSIF (igs_tr_item_rec.sequence_ind = 'N') THEN

        IF NVL(INSTR(l_field_mod,'S'),0) > 0 THEN
          IF p_step_completion_ind = 'Y' THEN
            -- Validate new value, on error return false

            igs_tr_step_rec.step_completion_ind := 'Y';
            igs_tr_step_rec.by_pass_ind := 'N';

            l_end_dt := NVL(p_completion_dt,SYSDATE);
            IF NOT (process_date (
                    'C',
                    igs_tr_step_rec.tracking_id,
                    igs_tr_step_rec.tracking_step_number,
                    l_end_dt,
                    l_action_days,
                    p_message_name)) THEN
              CLOSE c_update_trst;
              RETURN FALSE;
            END IF;
            igs_tr_step_rec.completion_dt := l_end_dt;

          ELSIF p_step_completion_ind = 'N' THEN
            -- Validate new value, on error return false

            IF NVL(INSTR(l_field_mod,'C'),0) > 0 AND
               p_completion_dt IS NOT NULL THEN
              p_message_name := 'IGS_TR_CANNOT_SET_CMP_DATE';
              CLOSE c_update_trst;
              RETURN FALSE;
            END IF;

            igs_tr_step_rec.step_completion_ind := 'N';
            igs_tr_step_rec.completion_dt := NULL;

          END IF;

        END IF;

        IF NVL(INSTR(l_field_mod,'B'),0) > 0 THEN
          IF p_by_pass_ind = 'Y' THEN
            -- Validate new value, on error return false

            IF NVL(INSTR(l_field_mod,'C'),0) > 0 AND
               p_completion_dt IS NOT NULL THEN
              p_message_name := 'IGS_TR_CANNOT_SET_CMP_DATE';
              CLOSE c_update_trst;
              RETURN FALSE;
            END IF;

            igs_tr_step_rec.step_completion_ind := 'N';
            igs_tr_step_rec.by_pass_ind := 'Y';
            igs_tr_step_rec.completion_dt := NULL;

          ELSIF p_by_pass_ind = 'N' THEN
            -- Validate new value, on error return false

            IF NVL(INSTR(l_field_mod,'C'),0) > 0 THEN
              p_message_name := 'IGS_TR_CANNOT_SET_CMP_DATE';
              CLOSE c_update_trst;
              RETURN FALSE;
            END IF;

            igs_tr_step_rec.by_pass_ind := 'N';

          END IF;

        END IF;

        IF NVL(INSTR(l_field_mod,'A'),0) > 0 THEN
          -- Validate new value, on error return false

          IF p_action_dt IS NOT NULL THEN
            l_end_dt := p_action_dt;
            IF NOT (process_date (
                    'A',
                    igs_tr_step_rec.tracking_id,
                    igs_tr_step_rec.tracking_step_number,
                    l_end_dt,
                    l_action_days,
                    p_message_name)) THEN
              CLOSE c_update_trst;
              RETURN FALSE;
            END IF;
            igs_tr_step_rec.action_dt := l_end_dt;
            igs_tr_step_rec.action_days := l_action_days;
          END IF;
        END IF;

        IF NVL(INSTR(l_field_mod,'C'),0) > 0 THEN
          -- Validate new value, on error return false

          l_end_dt := NVL(p_completion_dt,SYSDATE);
          IF NOT (process_date (
                  'C',
                  igs_tr_step_rec.tracking_id,
                  igs_tr_step_rec.tracking_step_number,
                  l_end_dt,
                  l_action_days,
                  p_message_name)) THEN
            CLOSE c_update_trst;
            RETURN FALSE;
          END IF;
          igs_tr_step_rec.completion_dt := l_end_dt;
        END IF;

        IF NVL(INSTR(l_field_mod,'R'),0) > 0 THEN
          -- Validate new value, on error return false

          IF NOT (igs_co_val_oc.genp_val_prsn_id(p_recipient_id, p_message_name)) THEN
            CLOSE c_update_trst;
            RETURN FALSE;
          ELSE
            igs_tr_step_rec.recipient_id := p_recipient_id;
          END IF;
        END IF;

      END IF;   -- End of sequential validation

      -- Update the record with NOWAIT option

      igs_tr_step_pkg.update_row(
            x_rowid                => igs_tr_step_rec.row_id,
            x_tracking_id          => igs_tr_step_rec.tracking_id,
            x_tracking_step_id     => igs_tr_step_rec.tracking_step_id,
            x_tracking_step_number => igs_tr_step_rec.tracking_step_number,
            x_description          => igs_tr_step_rec.description,
            x_s_tracking_step_type => igs_tr_step_rec.s_tracking_step_type,
            x_completion_dt        => igs_tr_step_rec.completion_dt,
            x_action_days          => igs_tr_step_rec.action_days,
            x_step_completion_ind  => igs_tr_step_rec.step_completion_ind,
            x_by_pass_ind          => igs_tr_step_rec.by_pass_ind,
            x_recipient_id         => igs_tr_step_rec.recipient_id,
            x_mode                 => 'R',
            x_step_group_id        => igs_tr_step_rec.step_group_id,
            x_step_catalog_cd      => igs_tr_step_rec.step_catalog_cd,
            x_publish_ind          => NVL(igs_tr_step_rec.publish_ind,'N')
       );

      CLOSE c_update_trst;

      --Added by Manu : The following check if the item should be marked as complete
      OPEN c_check_item_cmpltn;
      FETCH c_check_item_cmpltn INTO l_item_cmpl;
      IF c_check_item_cmpltn%NOTFOUND THEN
        -- The item should be marked complete since the steps are considered complete

        OPEN c_dflt_trk_sts;
        FETCH c_dflt_trk_sts INTO l_trk_sts;
        IF c_dflt_trk_sts%NOTFOUND THEN
          CLOSE c_dflt_trk_sts;
          CLOSE c_check_item_cmpltn;
          p_message_name := 'IGS_TR_DFLT_STATUS_NOT_DEFINED';
          RETURN FALSE;
        END IF;
        CLOSE c_dflt_trk_sts;

        igs_tr_item_pkg.update_row(
          x_mode                     =>  'R',
          x_rowid                    => igs_tr_item_rec.row_id,
          x_tracking_id              => igs_tr_item_rec.tracking_id,
          x_tracking_status          => l_trk_sts,
          x_tracking_type            => igs_tr_item_rec.tracking_type,
          x_source_person_id         => igs_tr_item_rec.source_person_id,
          x_start_dt                 => igs_tr_item_rec.start_dt,
          x_target_days              => igs_tr_item_rec.target_days,
          x_sequence_ind             => igs_tr_item_rec.sequence_ind,
          x_business_days_ind        => igs_tr_item_rec.business_days_ind,
          x_originator_person_id     => igs_tr_item_rec.originator_person_id,
          x_s_created_ind            => igs_tr_item_rec.s_created_ind,
          x_override_offset_clc_ind  => igs_tr_item_rec.override_offset_clc_ind,
          x_completion_due_dt        => igs_tr_item_rec.completion_due_dt,
          x_publish_ind              => igs_tr_item_rec.publish_ind
          );

      END IF;
      CLOSE c_check_item_cmpltn;

    EXCEPTION
      WHEN e_resource_busy_exception THEN
        p_message_name := 'IGS_TR_CANNOT_UPDATE_STEP';
        RETURN FALSE;

    END;
    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_TR_GEN_002.trkp_upd_trst'||'-'||SQLERRM);
        igs_ge_msg_stack.ADD;
        lv_param_values:= TO_CHAR(p_tracking_id) ||','||TO_CHAR(p_tracking_step_id)||','||p_s_tracking_step_type;
        fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
        fnd_message.set_token('VALUE',lv_param_values);
        igs_ge_msg_stack.ADD;
        lv_param_values:= igs_ge_date.igschar (p_action_dt)||','||igs_ge_date.igschar (p_completion_dt);
        fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
        fnd_message.set_token('VALUE',lv_param_values);
        igs_ge_msg_stack.ADD;
        lv_param_values:= p_step_completion_ind ||','||p_by_pass_ind ||','||TO_CHAR(p_recipient_id);
        fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
        fnd_message.set_token('VALUE',lv_param_values);
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;

  END trkp_upd_trst;

  PROCEDURE sync_trk_type_grplmt ( p_tracking_type  IGS_TR_TYPE_STEP_V.tracking_type%TYPE, p_execute VARCHAR2  )  IS

  /***********************************************************************************************************

   Created By:        pradhakr
   Date Created By:   11-Feb-2002
   Purpose:     This procedure will synchronise the content of the table IGS_TR_STEP_GRP_LMT with the content
                of IGS_TR_TYPE_STEP_V.
	        1. If that step group being deleted in form IGSTR001 ( block tracking step) is the last one of its
	           kind for a particular tracking id, the step group id will be deleted  from IGS_TR_TSTP_GRP_LMT
   	           else Step Group Limit will be decremented by 1.
                2. Any new Step Group ID being created in the form IGSTR001 ( block tracking step) will also be created
   	           in the table IGS_TR_TSTP_GRP_LMT and the Step Group Limit would be defaulted to 1.

   Known limitations,enhancements,remarks:
   Change History
   Who        When        What
   ************************************************************************************************************/

   --ssawhney view reference changed to table
   -- Decrements a step group limit
    CURSOR c_decrement_step_grp_lmt IS
    SELECT  step_group_id
      FROM  igs_tr_tstp_grp_lmt
     WHERE  tracking_type = p_tracking_type
     MINUS
    SELECT  step_group_id
      FROM  igs_tr_type_step  tts
     WHERE  tracking_type = p_tracking_type
            AND  tts.step_group_id IS NOT NULL
            GROUP BY tts.step_group_id;

   --ssawhney view reference changed to table
   -- Insert a step group limit
   CURSOR c_insert_step_grp_lmt IS
   SELECT step_group_id
     FROM igs_tr_type_step tts
    WHERE tracking_type = p_tracking_type
	  AND tts.step_group_id IS NOT NULL
          GROUP BY tts.step_group_id
    MINUS
   SELECT  step_group_id
     FROM  igs_tr_tstp_grp_lmt
    WHERE  tracking_type = p_tracking_type;


  -- Cursor to fetch the Rowid
  CURSOR c_rowid (p_tracking_type IGS_TR_TYPE_STEP_V.tracking_type%TYPE, p_step_group_id igs_tr_tstp_grp_lmt.step_group_id%TYPE)  IS
  SELECT ROWID
    FROM igs_tr_tstp_grp_lmt
   WHERE tracking_type = p_tracking_type
         AND step_group_id = p_step_group_id;

  --ssawhney view reference changed to table
  -- Cursor to get the count of step group id from tracking type step
  CURSOR c_type_step (p_tracking_type igs_tr_type_step_v.tracking_type%TYPE)   IS
  SELECT step_group_id, COUNT(*) step_group_count
    FROM igs_tr_type_step
   WHERE tracking_type = p_tracking_type
         GROUP BY step_group_id;

  -- Cursor to get the step group limit from igs_tr_tstp_grp_lmt table
  CURSOR c_grp_lmt (p_tracking_type igs_tr_tstp_grp_lmt.tracking_type%TYPE, p_step_group_id  igs_tr_tstp_grp_lmt.step_group_id%TYPE)  IS
  SELECT step_group_limit
    FROM igs_tr_tstp_grp_lmt
   WHERE tracking_type = p_tracking_type
         AND step_group_id = p_step_group_id;

  lv_rowid VARCHAR2(25);
  l_rowid  VARCHAR2(25);
  l_step_group_limit igs_tr_tstp_grp_lmt.step_group_limit%TYPE;
  l_grp_lmt igs_tr_tstp_grp_lmt.step_group_limit%TYPE;

  BEGIN

   -- Do not execute the code if the records are being updated in group limit block

   IF p_execute = 'N' THEN
      RETURN;
   END IF;

   -- Delete records from IGS_TR_TSTP_GRP_LMT table when a tracking_type and step_group_id combination exists in
   -- IGS_TR_TSTP_GRP_LMT but does not exist in view IGS_TR_TYPE_STEP_V

   FOR rec_decrement_step_grp_lmt IN c_decrement_step_grp_lmt LOOP

      OPEN c_rowid(p_tracking_type, rec_decrement_step_grp_lmt.step_group_id );
      FETCH c_rowid INTO l_rowid;
      CLOSE c_rowid;

      igs_tr_tstp_grp_lmt_pkg.delete_row (  X_ROWID => l_rowid   );

   END LOOP;


   -- Insert records into IGS_TR_TSTP_GRP_LMT when tracking_type and step_group_id combination
   -- exists in IGS_TR_TYPE_STEP_V but not in IGS_TR_TSTP_GRP_LMT.
   -- Default the value of Step_group_limit to 1.

   FOR rec_insert_step_grp_lmt IN c_insert_step_grp_lmt LOOP
       igs_tr_tstp_grp_lmt_pkg.insert_row (
                                             X_ROWID                => lv_rowid                                   ,
                                             X_TRACKING_TYPE        => p_tracking_type                            ,
                                             X_STEP_GROUP_ID        => rec_insert_step_grp_lmt.step_group_id      ,
                                             X_STEP_GROUP_LIMIT     => 1                                          ,
                                             X_MODE                 => 'R'
                                          );
   END LOOP;

   FOR rec_type_step IN c_type_step (p_tracking_type)
   LOOP
      OPEN c_grp_lmt (p_tracking_type, rec_type_step.step_group_id);
      FETCH c_grp_lmt INTO l_grp_lmt;
      CLOSE c_grp_lmt;

      OPEN c_rowid(p_tracking_type, rec_type_step.step_group_id );
      FETCH c_rowid INTO l_rowid;
      CLOSE c_rowid;

      -- Checking whether Group limit is greater than the count of Tracking step types for a group id
      IF l_grp_lmt > rec_type_step.step_group_count THEN
	        igs_tr_tstp_grp_lmt_pkg.update_row (
                                             X_ROWID                => l_rowid                                  ,
                                             X_TRACKING_TYPE        => p_tracking_type                          ,
                                             X_STEP_GROUP_ID        => rec_type_step.step_group_id              ,
                                             X_STEP_GROUP_LIMIT     => rec_type_step.step_group_count           ,
                                             X_MODE                 => 'R'
                                          );
      END IF;
   END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token('NAME','IGS_TR_GEN_002.sync_trk_type_grplmt'||'-'||SQLERRM);
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;

  END sync_trk_type_grplmt;

PROCEDURE sync_trk_item_grplmt ( p_tracking_id  IGS_TR_STEP_V.tracking_id %TYPE,
                                  p_execute VARCHAR2
                                )
 IS

/***********************************************************************************************************

 Created By:        Arun Iyer

 Date Created By:   11-Feb-2002

 Purpose:     This procedure would be called from the post_forms commit trigger of the Form IGSTR007 (Tracking Items ).
              This procedure will synchronise the content of the table IGS_TR_STEP_GRP_LMT with the content
              of IGS_TR_STEP_V.
              1. If that step group being deleted in form IGSTR007 ( block tracking step) is the last one of its
	        kind for a particular tracking id, the step group id will be deleted  from IGS_TR_STEP_GRP_LMT

              2. Any new Step Group ID being created in the form IGSTR007 ( block tracking step) will also be created
	        in the table IGS_TR_STEP_GRP_LMT and the Step Group Limit would be defaulted to 1.

              3. In case IGS_TR_STEP_GRP_LMT.STEP_GROUP_LIMIT is greater than the count of step_group_id's for tracking_id and step_group_id
                combination in IGS_TR_STEP_V view then set it equal to the lower value (i.e count of step_group_id's in the IGS_TR_STEP_V).


  Known limitations,enhancements,remarks:

  Change History

  Who        When        What
  ************************************************************************************************************/



 -- Fetch all the distinct step group id's for the given tracking id which are there in the table IGS_TR_STEP_GRP_LMT and not  in the view IGS_TR_STEP_V
 -- IF such records are found then delete them from the table igs_tr_step_grp_lmt
 -- ssawhney view reference changed to table
 CURSOR c_decrement_step_grp_lmt
 IS
       SELECT
               step_group_id
       FROM
              igs_tr_step_grp_lmt
       WHERE
              tracking_id = p_tracking_id
       MINUS
       SELECT
               step_group_id
       FROM
              igs_tr_step sv
       WHERE
              tracking_id = p_tracking_id
       AND
              sv.step_group_id IS NOT NULL
       GROUP BY
               sv.step_group_id;


 --  Fetch all the distinct step group id's for the given tracking id which are there in IGS_TR_STEP and not in the table IGS_TR_STEP_GRP_LMT
 --  IF such records are found then insert them from the table igs_tr_step_grp_lmt with a default group_limit of 1.
 --  ssawhney view reference changed to table
 CURSOR c_insert_step_grp_lmt
 IS
       SELECT
               step_group_id
       FROM
              igs_tr_step sv
       WHERE
              tracking_id = p_tracking_id
       AND
              sv.step_group_id IS NOT NULL
       GROUP BY
               sv.step_group_id
       MINUS
       SELECT
               step_group_id
       FROM
              igs_tr_step_grp_lmt
       WHERE
              tracking_id = p_tracking_id;


  -- Cursor to fetch the Rowid from the igs_tr_step_grp_lmt table for a tracking_id, step_group_id combination

  CURSOR c_rowid ( p_tracking_id   IGS_TR_STEP_GRP_LMT.TRACKING_ID%TYPE ,
                   p_step_group_id IGS_TR_STEP_GRP_LMT.STEP_GROUP_ID%TYPE
		 )
  IS
  SELECT
           ROWID
  FROM
           igs_tr_step_grp_lmt
  WHERE
           tracking_id   = p_tracking_id
  AND
           step_group_id = p_step_group_id;


  -- Cursor to get the count of step_group_id's for a tracking item step
  -- ssawhney view reference changed to table
  CURSOR c_item_step ( p_tracking_id IGS_TR_STEP_V.TRACKING_ID%TYPE )
  IS
  SELECT
           step_group_id,
           COUNT(step_group_id) step_group_count
  FROM
           igs_tr_step
  WHERE
           tracking_id = p_tracking_id
  AND
           step_group_id IS NOT NULL
  GROUP BY
           step_group_id;


  -- Cursor to get the step group limit from igs_tr_step_grp_lmt table for a combination of tracking_id and step_group_id

  CURSOR  c_grp_lmt (p_tracking_id    igs_tr_step_grp_lmt.tracking_id%TYPE,
                     p_step_group_id  igs_tr_step_grp_lmt.step_group_id%TYPE)
  IS
  SELECT
          step_group_limit
  FROM
          igs_tr_step_grp_lmt
  WHERE
          tracking_id = p_tracking_id
  AND
          step_group_id = p_step_group_id;


 lv_rowid               VARCHAR2(25);
 ln_step_group_limit    igs_tr_step_grp_lmt.step_group_limit%TYPE;
 ln_grp_lmt             igs_tr_step_grp_lmt.step_group_limit%TYPE;

 BEGIN

  /************************************ Validation 1 ***********************************************************/

   -- Do not execute the code if the records are being updated in group limit block
   IF p_execute = 'N' THEN
      RETURN;
   END IF;


  /************************************ Validation 2 ***********************************************************/
   -- Fetch all the distinct step group id's for the given tracking id which are there in the table IGS_TR_STEP_GRP_LMT
   -- and not  in the view IGS_TR_STEP_V.
   -- IF such records are found then delete them from the table igs_tr_step_grp_lmt

   FOR rec_decrement_step_grp_lmt IN c_decrement_step_grp_lmt LOOP
     OPEN c_rowid(p_tracking_id, rec_decrement_step_grp_lmt.step_group_id );
     FETCH c_rowid INTO lv_rowid;
     CLOSE c_rowid;
     igs_tr_step_grp_lmt_pkg.delete_row ( X_ROWID => lv_rowid );
   END LOOP;



  /************************************* Validation 3 ***********************************************************/
   -- Insert records into IGS_TR_STEP_GRP_LMT when tracking_id and step_group_id combination exists in IGS_TR_STEP_V
   -- but not in IGS_TR_STEP_GRP_LMT.
   -- Default the value of Step_group_limit to 1.

   FOR rec_insert_step_grp_lmt IN c_insert_step_grp_lmt LOOP
       igs_tr_step_grp_lmt_pkg.insert_row (
                                             X_ROWID                => lv_rowid                                   ,
                                             X_TRACKING_ID          => p_tracking_id                              ,
                                             X_STEP_GROUP_ID        => rec_insert_step_grp_lmt.step_group_id      ,
                                             X_STEP_GROUP_LIMIT     => 1                                          ,
                                             X_MODE                 => 'R'
                                          );
   END LOOP;


  /*************************************** Validation 4 ***********************************************************/
   -- Check the step group limit for a combination of Tracking_Id and Step_group_id in the table IGS_TR_STEP_GRP_LMT
   -- and the view IGS_TR_STEP_V.
   -- In case IGS_TR_STEP_GRP_LMT.STEP_GROUP_LIMIT is greater than the count of step_group_id's for tracking_id and step_group_id
   -- combination in IGS_TR_STEP_V view then set it equal to the count of step_group_id's in the IGS_TR_STEP_V.

   FOR rec_item_step IN c_item_step (p_tracking_id)
   LOOP
     OPEN c_grp_lmt (p_tracking_id, rec_item_step.step_group_id);
     FETCH c_grp_lmt INTO ln_grp_lmt;
     CLOSE c_grp_lmt;

     OPEN c_rowid(p_tracking_id, rec_item_step.step_group_id );
     FETCH c_rowid INTO lv_rowid;
     CLOSE c_rowid;

     -- Check whether Step Group limit is greater than the count of Tracking item steps for a step group id and tracking_id combination
     -- then set the step group limit equal to the count of step group id's in the igs)tr)step_v view for a step group id and tracking_id combination.

     IF ln_grp_lmt > rec_item_step.step_group_count THEN
       igs_tr_step_grp_lmt_pkg.update_row (
                                             X_ROWID                => lv_rowid                                  ,
                                             X_TRACKING_ID          => p_tracking_id                            ,
                                             X_STEP_GROUP_ID        => rec_item_step.step_group_id              ,
                                             X_STEP_GROUP_LIMIT     => rec_item_step.step_group_count           ,
                                             X_MODE                 => 'R'
                                          );
     END IF;
   END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token('NAME','IGS_TR_GEN_002.sync_trk_item_grplmt'||'-'||SQLERRM);
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;

END sync_trk_item_grplmt;


FUNCTION validate_completion_status ( p_tracking_id     IN IGS_TR_STEP_V.TRACKING_ID%TYPE,
                                      p_tracking_status IN IGS_TR_ITEM_V.TRACKING_STATUS%TYPE,
				      p_sequence_ind      IN IGS_TR_ITEM_V.SEQUENCE_IND%TYPE,
                                      p_message_name OUT NOCOPY VARCHAR2
                                     )
RETURN BOOLEAN
IS
/***********************************************************************************************************

Created By:        Arun Iyer

Date Created By:   13-Feb-2002

Purpose:      This procedure would be called from the post forms commit trigger of the form IGSTR007 (Tracking Items)

              1. IF the user has checked the sequential flag (value = Y' ) for the current tracking id then it would
	         checks whether all the previous steps have been completed or not. In case they have not been completed
	         it suitable raises an error.
	      2. If in the form the tracking status has been set to COMPLETE then this procedure validate whether
	         the tracking status changed to COMPLETE is correct or not.
		 In case it is incorrect then a suitable error message is returned back to the calling form

Known limitations,enhancements,remarks:

Change History

Who        When        What
************************************************************************************************************/

-- ssawhney view reference changed to table
CURSOR  c_tracking_step
IS
SELECT
       tracking_id,
       tracking_step_number,
       step_group_id
FROM
       igs_tr_step
WHERE
       tracking_id = p_tracking_id
     AND step_completion_ind = 'Y';

-- ssawhney view reference changed to table
CURSOR
         c_check_item_cmpltn
 IS
          SELECT
                   DISTINCT TO_NUMBER('1'),
		   1
          FROM
                   igs_tr_step trst
          WHERE
                   trst.tracking_id = p_tracking_id
          AND
                   trst.step_group_id IS NULL
          AND
                   trst.step_completion_ind = 'N'
          AND
                   trst.by_pass_ind = 'N'
          UNION
	  (
	   SELECT tab.step_group_id , tab.count_step
	   FROM (
		  SELECT
			   DISTINCT trst.step_group_id step_group_id,
			   COUNT(*) count_step
		  FROM
			   igs_tr_step trst
		  WHERE
			   trst.tracking_id = p_tracking_id
		  AND
			   trst.step_group_id IS NOT NULL
		  AND
			   (trst.step_completion_ind = 'Y'
		  OR
			   trst.by_pass_ind = 'Y')
		  GROUP BY
			   trst.step_group_id
			--   trst.step_completion_ind
		  MINUS
		  SELECT
			  DISTINCT trgl.step_group_id step_group_id,
				  step_group_limit count_step
		  FROM
			  igs_tr_step_grp_lmt trgl
		  WHERE
			  trgl.tracking_id = p_tracking_id
                ) tab,
		igs_tr_step_grp_lmt trg
	   WHERE tab.step_group_id = trg.step_group_id
	   AND
	         trg.tracking_id = p_tracking_id
	   AND
	         tab.count_step < trg.step_group_limit
         );


  rec_check_item_cmpltn c_check_item_cmpltn%ROWTYPE;

BEGIN

 /*******************************************   Validation 1 ************************************************/
  -- IF the Sequence_ind check box is checked then check if all the previous steps have been completed

  IF p_sequence_ind = 'Y' THEN
    FOR rec_tracking_step IN c_tracking_step LOOP

      IF  NOT trkp_prev_step_cmplt (
                                      rec_tracking_step.tracking_id,
                                      rec_tracking_step.tracking_step_number,
                                      rec_tracking_step.step_group_id,
                                      p_message_name
			            ) THEN
         RETURN (FALSE);
      END IF;
    END LOOP;
  END IF;

 /*******************************************   Validation 2 ************************************************/
  -- Validate whether the tracking status changed to COMPLETE is correct or not.

  IF p_tracking_status = 'COMPLETE' THEN
    OPEN  c_check_item_cmpltn;
    FETCH c_check_item_cmpltn INTO rec_check_item_cmpltn ;
    IF (C_CHECK_ITEM_CMPLTN%FOUND) THEN
	  CLOSE c_check_item_cmpltn;
      p_message_name := 'IGS_TR_ITST_NOT_COMPLETE';
      RETURN (FALSE);
    END IF;
    CLOSE c_check_item_cmpltn;
  END IF;

  RETURN (TRUE);

 EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_TR_GEN_002.validate_completion_status'||'-'||SQLERRM);
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;

END validate_completion_status;

END igs_tr_gen_002;

/
