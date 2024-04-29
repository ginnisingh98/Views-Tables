--------------------------------------------------------
--  DDL for Package Body IGS_TR_VAL_TRST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_TR_VAL_TRST" AS
/* $Header: IGSTR04B.pls 115.15 2003/05/09 14:34:24 pkpatel ship $ */
  /*
   Who       What
   msrinivi  Bug 1956374 duplicate removal Removed genp_prc_clear_rowid,genp_val_prsn_id
   pkkpatel  Bug 2858538(Tracking step type Enhancement)
             Modified the procedure trkp_val_stst_stt
  */
  -- Validate that the tracking step completion date set correctly.
  -- for tracking dld nov 2001 release (bug 1837257) modified the cursor
  --c_tracking_step to consider step_group also . also override_offset_clc_ind
  -- is checked now along with sequence_ind to perform the validation

  FUNCTION trkp_val_trst_cd_set(
    p_tracking_id IN NUMBER ,
    p_tracking_step_number IN NUMBER ,
    p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN

    DECLARE

      v_sequence_ind  igs_tr_item.sequence_ind%TYPE;
      v_completion_ind NUMBER;
      -- added for tracking dld in nov 2001 release (bug 1837257)
      l_override_offset_clc_ind igs_tr_item_all.override_offset_clc_ind%TYPE ;
      -- modified this cursor to select override_offset_clc_ind which is added
      -- in the tracking dld of nov2001 release
      CURSOR c_tracking_item( cp_tracking_id igs_tr_item.tracking_id%TYPE) IS
        SELECT sequence_ind , override_offset_clc_ind
        FROM   igs_tr_item
        WHERE  tracking_id = cp_tracking_id;

     -- modified this cursor during tracking dld nov 2001 (bug 1837257)
     --to include logic for step_group_id
      CURSOR c_tracking_step_prev( cp_tracking_id igs_tr_step.tracking_id%TYPE,
             cp_tracking_step_number igs_tr_step.tracking_step_number%TYPE) IS
        SELECT  distinct to_number('1')
        FROM    igs_tr_step trst
        WHERE   trst.tracking_id = cp_tracking_id
        AND     trst.tracking_step_number < cp_tracking_step_number
        AND     trst.step_group_id is null
        AND     trst.step_completion_ind = 'N'
        AND     trst.by_pass_ind = 'N'
    UNION
      (SELECT distinct trst.step_group_id
       FROM   igs_tr_step  trst
       WHERE  trst.tracking_id = cp_tracking_id
       AND     trst.tracking_step_number < cp_tracking_step_number
       AND     trst.step_group_id is not null
       AND     trst.step_completion_ind = 'N'
       AND     trst.by_pass_ind = 'N'
       GROUP BY  trst.step_group_id , trst.step_completion_ind
       MINUS
       SELECT distinct trst.step_group_id
       FROM   igs_tr_step  trst
       WHERE  trst.tracking_id = cp_tracking_id
       AND     trst.tracking_step_number < cp_tracking_step_number
       AND     trst.step_group_id is not null
       AND     trst.step_completion_ind = 'Y'
       GROUP BY  trst.step_group_id , trst.step_completion_ind
      );

     -- added this cursor during tracking dld nov 2001 (bug 1837257)
     --checks if any of the next steps are completed or can be treated as
     --complete then this step completion_dt cannot be updated
      CURSOR c_tracking_step_next( cp_tracking_id igs_tr_step.tracking_id%TYPE,
             cp_tracking_step_number igs_tr_step.tracking_step_number%TYPE) IS
        SELECT  distinct to_number('1')
        FROM    igs_tr_step trst
        WHERE   trst.tracking_id = cp_tracking_id
    AND     trst.tracking_step_number > cp_tracking_step_number
    AND     trst.step_group_id is null
    AND     trst.step_completion_ind = 'Y'
    MINUS
    SELECT  distinct to_number('1')
        FROM    igs_tr_step trst
        WHERE   trst.tracking_id = cp_tracking_id
    AND     trst.tracking_step_number = cp_tracking_step_number
    AND     trst.step_group_id is not null
    AND     trst.step_completion_ind = 'N'
    UNION
      (SELECT distinct trst.step_group_id
       FROM   igs_tr_step  trst
       WHERE  trst.tracking_id = cp_tracking_id
       AND     trst.tracking_step_number > cp_tracking_step_number
       AND     trst.step_group_id is not null
       AND     trst.step_completion_ind = 'Y'
       GROUP BY  trst.step_group_id , trst.step_completion_ind
       MINUS
       SELECT distinct trst.step_group_id
       FROM   igs_tr_step  trst
       WHERE  trst.tracking_id = cp_tracking_id
       AND     trst.tracking_step_number < cp_tracking_step_number
       AND     trst.step_group_id is not null
       GROUP BY  trst.step_group_id , trst.step_completion_ind
      );
      v_other_detail VARCHAR(255);
      lv_param_values  VARCHAR2(1080);

    BEGIN

      -- This module validates step_completion_ind against the
      -- completion_dt
      p_message_name := NULL;
      OPEN c_tracking_item( p_tracking_id);
      FETCH c_tracking_item INTO v_sequence_ind , l_override_offset_clc_ind ;
      CLOSE c_tracking_item;
      -- added condition to check for override offset clc ind also
      IF(v_sequence_ind = 'N') OR (l_override_offset_clc_ind = 'Y') THEN
        RETURN TRUE;
      END IF;

      IF(p_tracking_step_number > 1) THEN
        OPEN c_tracking_step_prev( p_tracking_id, p_tracking_step_number );
        FETCH c_tracking_step_prev INTO v_completion_ind;
        -- modified this condition during tracking dld nov 2001 (bug 1837257)
        --to include logic for step_group_id
        IF (c_tracking_step_prev%FOUND) THEN
          CLOSE c_tracking_step_prev;
          p_message_name := 'IGS_TR_CANNOT_SET_COMPL_DATE';
          RETURN FALSE;
        END IF;
        CLOSE c_tracking_step_prev;
      END IF;

 -- modified this code during build of tracking dld for nov 2001 release
 -- bug 1837257 - this is calling the new cursor added
      OPEN c_tracking_step_next( p_tracking_id, p_tracking_step_number);
      FETCH c_tracking_step_next INTO v_completion_ind;

      IF (c_tracking_step_next%FOUND) THEN
        CLOSE c_tracking_step_next;
        p_message_name := 'IGS_TR_COMPL_DT_UPD_NOT_ALLOW';
        RETURN FALSE;
      END IF;
      CLOSE c_tracking_step_next;
      RETURN TRUE;

    EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_TR_VAL_TRST.trkp_val_trst_cd_set');
        igs_ge_msg_stack.add;
        lv_param_values:=  TO_CHAR(p_tracking_id)||','||TO_CHAR(p_tracking_step_number);
        fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
        fnd_message.set_token('VALUE',lv_param_values);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
    END;
  END trkp_val_trst_cd_set;

  -- Validate the step completion indicator against step completion date
  FUNCTION trkp_val_trst_sci_cd(
    p_step_completion_ind IN VARCHAR2 DEFAULT 'N',
    p_completion_dt IN DATE ,
    p_by_pass_ind IN VARCHAR2 DEFAULT 'N',
    p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN
    DECLARE

     v_other_detail VARCHAR(255);

    BEGIN

      -- This module validates step_completion_ind against the
      -- completion_dt

      p_message_name := NULL;

      IF(p_step_completion_ind = 'Y' AND p_completion_dt IS NULL) THEN
         p_message_name := 'IGS_TR_COMPL_DT_MUST_BE_SET';
         RETURN FALSE;
      END IF;

      IF(p_step_completion_ind = 'N' AND p_completion_dt IS NOT NULL) THEN
        p_message_name := 'IGS_TR_CHECK_COMPL_DATE';
        RETURN FALSE;
      END IF;

      IF(p_by_pass_ind = 'Y' AND p_step_completion_ind = 'Y') THEN
        p_message_name := 'IGS_TR_INDICAT_CANNOT_BE_SET';
        RETURN FALSE;
      END IF;

      RETURN TRUE;

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

  END trkp_val_trst_sci_cd;


  -- Validate the system tracking step type within the tracking type.
  FUNCTION trkp_val_stst_stt(
    p_s_tracking_step_type IN VARCHAR2 ,
    p_tracking_type IN VARCHAR2 ,
    p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
/*
WHO      WHEN         WHAT
pkpatel  25-APR-2003  Bug 2858538(Tracking step type Enhancement)
                      Modified the cursor to validate system tracking step type within the tracking type.
*/
   gv_other_detail VARCHAR(255);
   lv_param_values VARCHAR2(1080);
   l_s_tracking_type igs_tr_type.s_tracking_type%TYPE;
   l_dummy         VARCHAR2(1);

   CURSOR tracking_type_cur IS
   SELECT s_tracking_type
   FROM   igs_tr_type
   WHERE  tracking_type = p_tracking_type;

   CURSOR step_type_cur(cp_s_tracking_type igs_tr_type.s_tracking_type%TYPE) IS
   SELECT 'X'
   FROM   igs_lookup_values
   WHERE  lookup_type = p_s_tracking_step_type AND
          lookup_code = cp_s_tracking_type;

  BEGIN

      -- This module checks that s_tracking_step_type is valid for
      -- the s_tracking_type.
      p_message_name := NULL;

      -- Find the System Tracking Type
      OPEN tracking_type_cur;
      FETCH tracking_type_cur INTO l_s_tracking_type;
         IF tracking_type_cur%NOTFOUND THEN
           CLOSE tracking_type_cur;
           p_message_name := 'IGS_TR_STEP_TYPE_INVALID';
           RETURN FALSE;
         END IF;
      CLOSE tracking_type_cur;

      -- Validate whether the System Tracking Type and the system tracking step type are associated.
      OPEN step_type_cur(l_s_tracking_type);
      FETCH step_type_cur INTO l_dummy;
         IF step_type_cur%NOTFOUND THEN
           CLOSE step_type_cur;
           p_message_name := 'IGS_TR_STEP_TYPE_INVALID';
           RETURN FALSE;
         END IF;
      CLOSE step_type_cur;


        RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_TR_VAL_TRST.trkp_val_stst_stt'||'-'||SQLERRM);
      igs_ge_msg_stack.add;
      lv_param_values:=p_s_tracking_step_type||','||p_tracking_type;
      fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
      fnd_message.set_token('VALUE',lv_param_values);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
  END trkp_val_stst_stt;

END igs_tr_val_trst;

/
