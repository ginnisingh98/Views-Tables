--------------------------------------------------------
--  DDL for Package Body IGS_TR_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_TR_GEN_001" AS
/* $Header: IGSTR01B.pls 115.8 2002/11/29 04:18:08 nsidana ship $ */

  FUNCTION trkp_clc_action_dt(
    p_tracking_id IN NUMBER ,
    p_tracking_step_number IN NUMBER ,
    p_start_dt IN DATE ,
    p_sequence_ind IN VARCHAR2 DEFAULT 'N',
    p_business_days_ind IN VARCHAR2 DEFAULT 'N')
  RETURN DATE IS
    gv_other_detail  VARCHAR2(255);
    v_start_dt  igs_tr_item.start_dt%TYPE;
    v_action_days  igs_tr_step.action_days%TYPE;
    v_action_dt  DATE;
    v_prev_completion_dt DATE;
    -- new variables added during tracking dld for nov 2001 release bug(1837257)
    -- added a new cursor to get the override offset indicator value for the item
    l_override_offset_clc_ind igs_tr_item_all.override_offset_clc_ind%TYPE ;
    l_completion_due_dt  igs_tr_item_all.completion_due_dt%TYPE ;
  BEGIN

    DECLARE

      CURSOR c_tracking_step( cp_tracking_id igs_tr_step.tracking_id%TYPE, cp_tracking_step_number igs_tr_step.tracking_step_number%TYPE) IS
        SELECT ts.action_days, ts.completion_dt, ts.by_pass_ind
        FROM   igs_tr_step ts
        WHERE  ts.tracking_id = cp_tracking_id
        AND    ts.tracking_step_number <= cp_tracking_step_number
        ORDER BY ts.tracking_step_number;

      CURSOR c_tracking_step_1( cp_tracking_id igs_tr_step.tracking_id%TYPE, cp_tracking_step_number igs_tr_step.tracking_step_number%TYPE) IS
        SELECT ts.action_days
        FROM   igs_tr_step ts
        WHERE  ts.tracking_id = cp_tracking_id
        AND    ts.tracking_step_number = cp_tracking_step_number;
      --added for tracking dld - nov 2001
      CURSOR c_tracking_item IS
        SELECT NVL(override_offset_clc_ind , 'N'), completion_due_dt
        FROM   igs_tr_item
        WHERE  tracking_id = p_tracking_id ;

    BEGIN
      OPEN c_tracking_item ;
      FETCH c_tracking_item  INTO l_override_offset_clc_ind , l_completion_due_dt ;
      CLOSE c_tracking_item ;
      -- if override offset clc ind is yes then action date is equal to completion due date
      IF  l_override_offset_clc_ind = 'Y' THEN
        v_action_dt := l_completion_due_dt ;

      -- Calculates the action date for a tracking step.
      ELSIF (p_sequence_ind = 'Y') THEN
        v_start_dt := p_start_dt;
        v_action_dt := NULL;
        v_prev_completion_dt := NULL;

        FOR v_tracking_step_rec IN c_tracking_step(
          p_tracking_id,
          p_tracking_step_number) LOOP

          -- If the previous steps completion date has been set
          -- then need to calculate the action date from that date.
          IF v_prev_completion_dt IS NOT NULL THEN
            v_start_dt := v_prev_completion_dt;
          END IF;

	  v_action_dt := trkp_clc_dt_offset(
          v_start_dt,
          v_tracking_step_rec.action_days,
          p_business_days_ind);

          IF v_tracking_step_rec.by_pass_ind = 'N' THEN
            v_prev_completion_dt := v_tracking_step_rec.completion_dt;
            v_start_dt := v_action_dt;
          END IF;
        END LOOP;

      ELSE
        OPEN  c_tracking_step_1(
        p_tracking_id,
        p_tracking_step_number);
        FETCH  c_tracking_step_1 INTO v_action_days;
        CLOSE c_tracking_step_1;
        v_action_dt := trkp_clc_dt_offset(
        p_start_dt,
        v_action_days,
        p_business_days_ind);
      END IF;

      RETURN v_action_dt;

      EXCEPTION WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXCEPTION');

    END;

  END trkp_clc_action_dt;

  FUNCTION trkp_clc_bus_dt(
    p_start_dt IN DATE ,
    p_business_days IN NUMBER )
  RETURN DATE IS
  BEGIN

    DECLARE
      v_return_dt DATE;
      v_start_dt DATE;
      v_other_detail VARCHAR(255);
      v_message_name VARCHAR2(30);
      v_cntr  NUMBER;

    BEGIN

      -- This module based on an initial date plus a number of business days
      -- determines the new date
      IF(p_business_days = 0) THEN
        RETURN p_start_dt;
      END IF;

      v_return_dt := p_start_dt;
      v_start_dt := p_start_dt + 1;
      v_cntr := 1;

      WHILE v_cntr <= p_business_days LOOP
        IF(igs_tr_val_tri.genp_val_bus_day(v_start_dt,'N','N', v_message_name)) THEN
          v_return_dt := v_start_dt;
          v_cntr := v_cntr + 1;
        END IF;
        v_start_dt := v_start_dt + 1;
      END LOOP;

      WHILE NOT igs_tr_val_tri.genp_val_bus_day(v_return_dt,'N','N', v_message_name) LOOP
        v_return_dt := v_return_dt + 1;
      END LOOP;

      RETURN v_return_dt;

    END;

  END trkp_clc_bus_dt;

  FUNCTION trkp_clc_days_ovrdue(
    p_action_dt IN DATE ,
    p_completion_dt IN DATE ,
    p_business_days_ind IN VARCHAR2 DEFAULT 'N'
  )RETURN NUMBER IS

    gv_other_detail  VARCHAR2(255);

  BEGIN

    DECLARE
      v_completion_dt  igs_tr_step.completion_dt%TYPE;
      v_ovrdue_days  NUMBER;
      v_message_name  VARCHAR2(30);

    BEGIN

      -- Determine the number of days that a tracking object is overdue.
      IF p_completion_dt IS NULL THEN
        v_completion_dt := SYSDATE;
      ELSE
        v_completion_dt := p_completion_dt;
      END IF;

      IF v_completion_dt <= p_action_dt THEN
        RETURN 0;
      END IF;

      IF p_business_days_ind = 'Y' THEN
        v_ovrdue_days := trkp_clc_num_bus_day( p_action_dt, v_completion_dt, v_message_name);
      ELSE
        v_ovrdue_days := TO_NUMBER(TO_CHAR(v_completion_dt, 'J')) - TO_NUMBER(TO_CHAR(p_action_dt, 'J'));
      END IF;
      RETURN v_ovrdue_days;

    END;

  END trkp_clc_days_ovrdue;

  FUNCTION trkp_clc_dt_offset(
    p_start_dt IN DATE ,
    p_offset_days IN NUMBER ,
    p_business_days_ind IN VARCHAR2 DEFAULT 'N' ,
    -- Tracking dld nov 2001 , bug#1837257 added new parameter p_override_offset_clc_ind
    -- if override ind is set then no need to calculate offset date
    p_override_offset_clc_ind IN varchar2 DEFAULT 'N'
  )RETURN DATE IS

   gv_other_detail  VARCHAR2(255);

  BEGIN

    DECLARE
    BEGIN
      -- do not process if override offset clc ind is yes
      IF (p_override_offset_clc_ind = 'N' ) THEN
        -- Determine the date from a start date, plus and offset, allowing
        -- for business days only if the p_business_days_ind is set.
        IF (p_business_days_ind = 'Y') THEN
          RETURN trkp_clc_bus_dt( p_start_dt, p_offset_days);
        ELSE
          RETURN p_start_dt + p_offset_days;
        END IF;
      ELSE
        RETURN NULL ;
      END IF;

    END;

  END trkp_clc_dt_offset;

  FUNCTION trkp_clc_num_bus_day(
    p_start_dt IN DATE ,
    p_end_dt IN DATE ,
    p_message_name OUT NOCOPY VARCHAR2
  ) RETURN NUMBER IS

  BEGIN

    DECLARE
      v_end_dt DATE;
      v_message_name  VARCHAR2(30);
      v_day_diff NUMBER;
      v_day_count NUMBER;
      v_other_detail VARCHAR(255);

    BEGIN

      -- This module determines the number of business days between
      -- two dates. (The start date is not inclusive where the end date is
      -- inclusive)
      p_message_name := NULL;
      IF(p_start_dt = p_end_dt) THEN
        RETURN 0;
      END IF;

      IF(p_start_dt > p_end_dt) THEN
        p_message_name := 'IGS_GE_INVALID_DATE';
        RETURN 0;
      END IF;

      v_end_dt := TRUNC(p_end_dt);
      v_day_diff := TRUNC(p_end_dt) - TRUNC(p_start_dt);
      v_day_count := 0;

      FOR i IN 1..v_day_diff LOOP
        IF(igs_tr_val_tri.genp_val_bus_day(v_end_dt,'N', 'N', v_message_name)) THEN
          v_day_count := v_day_count + 1;
        END IF;
        v_end_dt := v_end_dt - 1;
      END LOOP;

      RETURN v_day_count;

    EXCEPTION
      WHEN OTHERS THEN
        RAISE;

    END;

  END trkp_clc_num_bus_day;

  FUNCTION trkp_clc_tri_cmp_dt(
    p_tracking_id IN NUMBER ,
    p_start_dt IN DATE )
  RETURN DATE IS
   gv_other_detail  VARCHAR2(255);

  BEGIN

    DECLARE
      cst_active  VARCHAR2(6) := 'ACTIVE';
      v_completion_dt  igs_tr_step.completion_dt%TYPE;
      CURSOR c_tracking_step( cp_tracking_id igs_tr_step.tracking_id%TYPE) IS
        SELECT  MAX(ts.completion_dt)
        FROM    igs_tr_step ts
        WHERE   ts.tracking_id = cp_tracking_id;

    BEGIN

      -- If the tracking item is still active then there is no completion date for
      -- the item.

      IF (igs_tr_gen_002.trkp_get_item_status( p_tracking_id) = cst_active) THEN
         RETURN NULL;

      ELSE
        -- Determine the maximum completion date of the steps for the item.
        -- If a null date, then all steps may have been by-passed or no steps exist.
        -- Return the start date.
        OPEN  c_tracking_step(p_tracking_id);
        FETCH   c_tracking_step INTO v_completion_dt;
        CLOSE c_tracking_step;
        IF v_completion_dt IS NULL THEN
          RETURN p_start_dt;
        ELSE
          RETURN v_completion_dt;
        END IF;
      END IF;

    END;

  END trkp_clc_tri_cmp_dt;

END igs_tr_gen_001;

/
