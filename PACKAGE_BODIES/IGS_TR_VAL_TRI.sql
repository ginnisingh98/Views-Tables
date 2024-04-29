--------------------------------------------------------
--  DDL for Package Body IGS_TR_VAL_TRI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_TR_VAL_TRI" AS
/* $Header: IGSTR03B.pls 115.7 2003/02/19 10:24:44 kpadiyar ship $ */
  -- msrinivi bug 1956374 . removed genp_val_prsn_id
  -- Validate that the date is a business day
  FUNCTION genp_val_bus_day(
    p_date IN DATE ,
    p_weekend_ind IN VARCHAR2 DEFAULT 'N',
    p_uni_holiday_ind IN VARCHAR2 DEFAULT 'N',
    p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN

    DECLARE

      v_other_detail VARCHAR(255);
      v_day  VARCHAR2(20);

    BEGIN

      -- This module validates that the date passed in is
      -- a valid business day
      p_message_name := NULL;
      -- kdande --
      v_day := RTRIM(TO_CHAR(p_date,'d'));
      IF(p_weekend_ind = 'N' ) THEN
        -- kdande --
        IF(v_day = '7' OR v_day = '1') THEN
          p_message_name := 'IGS_GE_DATE_IS_IN_WEEKEND';
          RETURN FALSE;
        END IF;
      END IF;
      RETURN TRUE;

    END;

  END genp_val_bus_day;

  -- Validate the status for a tracking item.
  FUNCTION trkp_val_tri_status(
    p_tracking_status IN VARCHAR2 ,
    p_inserting IN BOOLEAN ,
    p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS

    gv_other_detail  VARCHAR2(255);
    lv_param_values  VARCHAR2(1080);

  BEGIN

    -- Validate the IGS_TR_ITEM.tracking_status.
    DECLARE

      v_s_tracking_status igs_tr_status.s_tracking_status%TYPE;
      v_closed_ind  igs_tr_status.closed_ind%TYPE;

      CURSOR  c_get_closed_ind ( cp_tracking_status igs_tr_item.tracking_status%TYPE) IS
        SELECT  s_tracking_status, closed_ind
        FROM    igs_tr_status
        WHERE   tracking_status = cp_tracking_status;

    BEGIN

      p_message_name := NULL;
      OPEN c_get_closed_ind(p_tracking_status);

      FETCH c_get_closed_ind INTO v_s_tracking_status, v_closed_ind;

      IF (c_get_closed_ind%NOTFOUND) THEN
        CLOSE c_get_closed_ind;
        RETURN TRUE;
      END IF;

      CLOSE c_get_closed_ind;

      IF (v_closed_ind = 'Y') THEN
        p_message_name := 'IGS_TR_STATUS_CLOSED';
        RETURN FALSE;
      END IF;

      -- Validate that the status is active when inserting.
      IF p_inserting THEN
        IF v_s_tracking_status <> 'ACTIVE' THEN
          p_message_name := 'IGS_TR_MUST_HAVE_STATUS_ACTIV';
          RETURN FALSE;
        END IF;
      END IF;

      RETURN TRUE;

    END;

    EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_TR_VAL_TRI.trkp_val_tri_status');
        igs_ge_msg_stack.add;
        lv_param_values:=p_tracking_status;
        fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
        fnd_message.set_token('VALUE',lv_param_values);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END trkp_val_tri_status;

  -- Validate the tracking type for a tracking item.
  FUNCTION trkp_val_tri_type(
    p_tracking_type IN VARCHAR2 ,
    p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS

    gv_other_detail  VARCHAR2(255);
    lv_param_values  VARCHAR2(1080);

  BEGIN

     -- Validate the IGS_TR_ITEM.tracking_type.
     DECLARE

       v_closed_ind igs_tr_type.closed_ind%TYPE;
      CURSOR c_get_closed_ind ( cp_tracking_type igs_tr_item.tracking_type%TYPE) IS
      SELECT  closed_ind
      FROM    igs_tr_type
      WHERE   tracking_type = cp_tracking_type;

    BEGIN

      p_message_name := NULL;
      OPEN c_get_closed_ind(p_tracking_type);
      FETCH c_get_closed_ind INTO v_closed_ind;
      IF (c_get_closed_ind%NOTFOUND) THEN
        CLOSE c_get_closed_ind;
        RETURN TRUE;
      END IF;
      CLOSE c_get_closed_ind;

      IF (v_closed_ind = 'N') THEN
        RETURN TRUE;
      END IF;

      p_message_name := 'IGS_TR_TYPE_CLOSED';

      RETURN FALSE;

    END;

    EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_TR_VAL_TRI.trkp_val_tri_type');
        igs_ge_msg_stack.add;
        lv_param_values:=p_tracking_type;
        fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
        fnd_message.set_token('VALUE',lv_param_values);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END trkp_val_tri_type;

  -- Validate the tracking item start date.
  FUNCTION trkp_val_tri_strt_dt(
    p_start_dt IN DATE ,
    p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN
    DECLARE

      v_other_detail VARCHAR(255);
      cst_min_dt CONSTANT DATE := igs_ge_date.igsdate ('1950/01/01');
      cst_max_dt CONSTANT DATE := igs_ge_date.igsdate ('9999/01/01');
      lv_param_values  VARCHAR2(1080);

    BEGIN

      -- This module validates IGS_TR_ITEM.start_dt is within
      -- a valid range for date manipulation within the form.
      p_message_name := NULL;

      IF NOT (p_start_dt BETWEEN cst_min_dt AND cst_max_dt) THEN
        p_message_name := 'IGS_TR_ST_DT_1950_2045';
        RETURN FALSE;
      END IF;
      RETURN TRUE;

      EXCEPTION
        WHEN OTHERS THEN
          fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
          fnd_message.set_token('NAME','IGS_TR_VAL_TRI.trkp_val_tri_strt_dt');
          igs_ge_msg_stack.add;
          lv_param_values:=p_start_dt;
          fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
          fnd_message.set_token('VALUE',lv_param_values);
          igs_ge_msg_stack.add;
          app_exception.raise_exception;

    END;

  END trkp_val_tri_strt_dt;


FUNCTION val_tr_step_ctlg(
    		p_step_catalog_cd IN VARCHAR2 ,
    		p_message_name OUT NOCOPY VARCHAR2 )
 	RETURN BOOLEAN IS
    	v_closed_ind  igs_tr_step_ctlg.closed_ind%TYPE;

      	CURSOR  c_get_closed_ind ( cp_step_catalog_cd  igs_tr_step_ctlg.step_catalog_cd%TYPE) IS
       	SELECT  closed_ind
        	FROM    igs_tr_step_ctlg
        	WHERE   step_catalog_cd = cp_step_catalog_cd;

   	 BEGIN

     	p_message_name := NULL;
      	OPEN c_get_closed_ind(p_step_catalog_cd);
      	FETCH c_get_closed_ind INTO v_closed_ind;
      	IF (c_get_closed_ind%NOTFOUND) THEN
        		CLOSE c_get_closed_ind;
        		RETURN TRUE;
     	END IF;
      	CLOSE c_get_closed_ind;
     	IF (v_closed_ind = 'Y') THEN
        		p_message_name := 'IGS_TR_STEP_CTLG_CLOSED';
		RETURN FALSE;
      	END IF;
	RETURN TRUE;
END val_tr_step_ctlg;

END igs_tr_val_tri;

/
