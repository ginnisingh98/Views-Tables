--------------------------------------------------------
--  DDL for Package Body IGS_GR_VAL_AWC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_VAL_AWC" AS
/* $Header: IGSGR05B.pls 115.5 2004/02/04 04:53:11 kdande ship $ */
  --
  -- Validate the award has the correct system award type
  --
  FUNCTION grdp_val_award_type(
  p_award_cd IN VARCHAR2 ,
  p_s_award_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN -- grdp_val_award_type
    -- Description: Validate the award specified by the award_cd has a
    -- s_award_type the same as that supplied.
  DECLARE
    v_award_rec IGS_PS_AWD.s_award_type%TYPE;
    v_ret_val BOOLEAN DEFAULT TRUE;
    cst_course  CONSTANT VARCHAR2(6) := 'COURSE';
    cst_honorary  CONSTANT VARCHAR2(8) := 'HONORARY';
    cst_special CONSTANT VARCHAR2(7) := 'SPECIAL';
    CURSOR  c_award IS
      SELECT  s_award_type
      FROM  IGS_PS_AWD
      WHERE award_cd = p_award_cd;
  BEGIN
    p_message_name := NULL;
    IF p_award_cd IS NULL OR
        p_s_award_type IS NULL THEN
      RETURN TRUE;
    END IF;
    OPEN c_award;
    FETCH c_award INTO v_award_rec;
    IF (c_award%FOUND) THEN
      IF p_s_award_type = cst_course AND
            p_s_award_type <> v_award_rec THEN
        CLOSE c_award;
        p_message_name := 'IGS_GR_TYPE_MUST_BE_COURSE';
        RETURN FALSE;
      END IF;
      IF  p_s_award_type = cst_honorary AND
            p_s_award_type <> v_award_rec THEN
        CLOSE c_award;
        p_message_name := 'IGS_GR_TYPE_MUST_BE_HNRY';
        RETURN FALSE;
      END IF;
      IF  p_s_award_type = cst_special AND
            (v_award_rec = cst_course OR
            v_award_rec = cst_honorary) THEN
        CLOSE c_award;
        p_message_name := 'IGS_GR_NOT_A_VALID_AWD_TYPE';
        RETURN FALSE;
      END IF;
    END IF;
    CLOSE c_award;
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      IF (c_award%ISOPEN) THEN
        CLOSE c_award;
      END IF;
    RAISE;
  END;
  EXCEPTION
    WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
          App_Exception.Raise_Exception;
      RAISE;
  END grdp_val_award_type;
  --
  -- Validate the award ceremony has related student course attempts
  --
  FUNCTION grdp_val_awc_sca(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN -- grdp_val_awc_sca
    -- Description: Warn the user if no student_course_attempt records
    -- exist for the specified course_cd and version_number.  WARNING ONLY
  DECLARE
    v_dummy   VARCHAR2(1);
    CURSOR  c_sca IS
      SELECT  'X'
      FROM  IGS_EN_STDNT_PS_ATT sca
      WHERE sca.course_cd   = p_course_cd AND
        sca.version_number  = p_version_number;
  BEGIN
    p_message_name := NULL;
    IF p_course_cd IS NULL OR
        p_version_number IS NULL THEN
      RETURN TRUE;
    END IF;
    OPEN c_sca;
    FETCH c_sca INTO v_dummy;
    IF (c_sca%NOTFOUND) THEN
      CLOSE c_sca;
      p_message_name := 'IGS_GR_NO_STUD_COURSE_EXISTS';
      RETURN TRUE;
    END IF;
    CLOSE c_sca;
    RETURN TRUE;
  END;
  EXCEPTION
    WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
  END grdp_val_awc_sca;
  --
  -- Validate the award is not closed.
  --
  FUNCTION crsp_val_aw_closed(
  p_award_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
    v_other_detail    VARCHAR(255);
    v_closed_ind    IGS_PS_AWD.closed_ind%TYPE;
    CURSOR  c_aw IS
      SELECT closed_ind
      FROM   IGS_PS_AWD aw
      WHERE  aw.award_cd = p_award_cd;
  BEGIN
    -- check if the award is closed
    OPEN c_aw;
    FETCH c_aw INTO v_closed_ind;
    IF c_aw%NOTFOUND THEN
      p_message_name := NULL;
      CLOSE c_aw;
      RETURN TRUE;
    ELSIF (v_closed_ind = 'N') THEN
      p_message_name := NULL;
      CLOSE c_aw;
      RETURN TRUE;
    ELSE
      p_message_name := 'IGS_PS_AWARD_CD_CLOSED';
      CLOSE c_aw;
      RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
  END crsp_val_aw_closed;
  --
  -- Validate the award ceremony order in ceremony
  --
  FUNCTION grdp_val_awc_order(
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_ceremony_number IN NUMBER ,
  p_award_course_cd IN VARCHAR2 ,
  p_award_crs_version_number IN NUMBER ,
  p_award_cd IN VARCHAR2 ,
  p_order_in_ceremony IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN -- grdp_val_awc_order
  DECLARE
    v_awc_exists    VARCHAR2(1);
    v_acusg_grd_cal_type      IGS_GR_AWD_CRM_US_GP.grd_cal_type%TYPE;
    v_acusg_grd_ci_sequence_number
              IGS_GR_AWD_CRM_US_GP.grd_ci_sequence_number%TYPE;
    v_acusg_ceremony_number     IGS_GR_AWD_CRM_US_GP.ceremony_number%TYPE;
    v_acusg_award_course_cd     IGS_GR_AWD_CRM_US_GP.award_course_cd%TYPE;
    v_acusg_award_crs_version_num
              IGS_GR_AWD_CRM_US_GP.award_crs_version_number%TYPE;
    v_acusg_award_cd      IGS_GR_AWD_CRM_US_GP.award_cd%TYPE;
    v_acusg_us_group_number     IGS_GR_AWD_CRM_US_GP.us_group_number%TYPE;
    v_message_name        VARCHAR2(30);
    CURSOR c_awc IS
      SELECT  'X'
      FROM  IGS_GR_AWD_CEREMONY awc
      WHERE awc.grd_cal_type    = p_grd_cal_type AND
        awc.grd_ci_sequence_number  = p_grd_ci_sequence_number AND
        awc.ceremony_number   = p_ceremony_number AND
        awc.order_in_ceremony   = p_order_in_ceremony AND
        awc.award_cd      <> p_award_cd;
    CURSOR  c_acusg IS
      SELECT  acusg.grd_cal_type,
        acusg.grd_ci_sequence_number,
        acusg.ceremony_number,
        acusg.award_course_cd,
        acusg.award_crs_version_number,
        acusg.award_cd,
        acusg.us_group_number
      FROM  IGS_GR_AWD_CRM_US_GP  acusg
      WHERE acusg.grd_cal_type    = p_grd_cal_type AND
        acusg.grd_ci_sequence_number  = p_grd_ci_sequence_number AND
        acusg.ceremony_number   = p_ceremony_number AND
        acusg.award_course_cd   = p_award_course_cd AND
        acusg.award_crs_version_number  = p_award_crs_version_number AND
        acusg.award_cd      = p_award_cd;
  BEGIN
    -- Set the default message number
    p_message_name := NULL;
    --1. Check parameters :
    IF p_grd_cal_type IS NULL OR
          p_grd_ci_sequence_number  IS NULL OR
          p_ceremony_number   IS NULL OR
        p_award_cd      IS NULL OR
          p_order_in_ceremony   IS NULL THEN
      RETURN TRUE;
    END IF;
    --Check for any award_ceremony records with for the same graduation_ceremony
    -- with the same order_in_ceremony but a different award_cd.
    --4.  If any records are found raise an error.
    OPEN c_awc;
    FETCH c_awc INTO  v_awc_exists;
    IF c_awc%FOUND THEN
      CLOSE c_awc;
      p_message_name := 'IGS_GR_MUST_BE_SAME_AWRD_CD';
      RETURN FALSE;
    END IF;
    -- If course code and version number are NULL it mus be
    -- an honorary award which cannot have unit set groups.
    IF p_award_course_cd    IS NULL OR
          p_award_crs_version_number  IS NULL THEN
      RETURN TRUE;
    END IF;
    --5. Loop through all of the award_ceremony_us_group records for this
    -- award_ceremony and call GRDP_VAL_ACUSG_ORDER to check for any
    -- order_in_award conflicts.
    FOR v_acusg_rec IN c_acusg LOOP
      IF NOT IGS_GR_VAL_AWC.grdp_val_acusg_order(
            v_acusg_rec.grd_cal_type,
            v_acusg_rec.grd_ci_sequence_number,
            v_acusg_rec.ceremony_number,
            v_acusg_rec.award_course_cd,
            v_acusg_rec.award_crs_version_number,
            v_acusg_rec.award_cd,
            v_acusg_rec.us_group_number,
            v_message_name) THEN
        p_message_name := v_message_name;
        RETURN FALSE;
      END IF;
    END LOOP;
    -- Return the default value
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_awc%ISOPEN THEN
        CLOSE c_awc;
      END IF;
      IF c_acusg%ISOPEN THEN
        CLOSE c_acusg;
      END IF;
      RAISE;
  END;
  EXCEPTION
    WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
  END grdp_val_awc_order;
  --
  -- Validate if the award ceremony us group order in award.
  --
  FUNCTION grdp_val_acusg_order(
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_ceremony_number IN NUMBER ,
  p_award_course_cd IN VARCHAR2 ,
  p_award_crs_version_number IN NUMBER ,
  p_award_cd IN VARCHAR2 ,
  p_us_group_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN -- grdp_val_acusg_order
    -- This validates that award_ceremony_us_group records with the same
    -- order_in_award which have parent award_ceremony records in the same
    -- graduation_ceremony with the same order_in_ceremony have matching
    -- award_ceremony_unit_set records.
  DECLARE
    v_awc_acusg_exists  VARCHAR2(1);
    CURSOR c_awc_acusg IS
      SELECT  'x'
      FROM  IGS_GR_AWD_CEREMONY awc1,
        IGS_GR_AWD_CEREMONY awc2,
        IGS_GR_AWD_CRM_US_GP  acusg1,
        IGS_GR_AWD_CRM_US_GP  acusg2
      WHERE acusg1.grd_cal_type   = p_grd_cal_type AND
        acusg1.grd_ci_sequence_number = p_grd_ci_sequence_number AND
        acusg1.ceremony_number    = p_ceremony_number AND
        acusg1.award_course_cd    = p_award_course_cd AND
        acusg1.award_crs_version_number = p_award_crs_version_number AND
        acusg1.award_cd     = p_award_cd AND
        acusg1.us_group_number    = p_us_group_number AND
        acusg1.closed_ind       = 'N' AND
        acusg2.grd_cal_type   = acusg1.grd_cal_type AND
        acusg2.grd_ci_sequence_number = acusg1.grd_ci_sequence_number AND
        acusg2.ceremony_number    = acusg1.ceremony_number AND
        (acusg2.award_course_cd   <> acusg1.award_course_cd OR
        acusg2.award_crs_version_number <> acusg1.award_crs_version_number) AND
        acusg2.award_cd     = acusg1.award_cd AND
        acusg2.closed_ind       = 'N' AND
        acusg1.order_in_award   = acusg2.order_in_award AND
        awc1.grd_cal_type     = acusg1.grd_cal_type AND
        awc1.grd_ci_sequence_number = acusg1.grd_ci_sequence_number AND
        awc1.ceremony_number    = acusg1.ceremony_number AND
        awc1.award_course_cd    = acusg1.award_course_cd AND
        awc1.award_crs_version_number = acusg1.award_crs_version_number AND
        awc1.award_cd     = acusg1.award_cd AND
        awc1.closed_ind     = 'N' AND
        awc2.grd_cal_type     = acusg2.grd_cal_type AND
        awc2.grd_ci_sequence_number = acusg2.grd_ci_sequence_number AND
        awc2.ceremony_number    = acusg2.ceremony_number AND
        awc2.award_course_cd    = acusg2.award_course_cd AND
        awc2.award_crs_version_number = acusg2.award_crs_version_number AND
        awc2.award_cd     = acusg2.award_cd AND
        awc2.closed_ind     = 'N' AND
        awc1.order_in_ceremony    = awc2.order_in_ceremony
      AND
      (EXISTS
        (SELECT acus.unit_set_cd,
          acus.us_version_number
        FROM  IGS_GR_AWD_CRM_UT_ST  acus
        WHERE acus.grd_cal_type     = acusg1.grd_cal_type AND
          acus.grd_ci_sequence_number = acusg1.grd_ci_sequence_number AND
          acus.ceremony_number    = acusg1.ceremony_number AND
          acus.award_course_cd    = acusg1.award_course_cd AND
          acus.award_crs_version_number = acusg1.award_crs_version_number AND
          acus.award_cd     = acusg1.award_cd AND
          acus.us_group_number    = acusg1.us_group_number
        MINUS
          SELECT  acus.unit_set_cd,
            acus.us_version_number
          FROM  IGS_GR_AWD_CRM_UT_ST  acus
          WHERE acus.grd_cal_type     = acusg2.grd_cal_type AND
            acus.grd_ci_sequence_number = acusg2.grd_ci_sequence_number AND
            acus.ceremony_number    = acusg2.ceremony_number AND
            acus.award_course_cd    = acusg2.award_course_cd AND
            acus.award_crs_version_number = acusg2.award_crs_version_number AND
            acus.award_cd     = acusg2.award_cd AND
            acus.us_group_number    = acusg2.us_group_number)
      OR
      EXISTS
        (SELECT acus.unit_set_cd,
          acus.us_version_number
        FROM  IGS_GR_AWD_CRM_UT_ST  acus
        WHERE acus.grd_cal_type     = acusg2.grd_cal_type AND
          acus.grd_ci_sequence_number = acusg2.grd_ci_sequence_number AND
          acus.ceremony_number    = acusg2.ceremony_number AND
          acus.award_course_cd    = acusg2.award_course_cd AND
          acus.award_crs_version_number = acusg2.award_crs_version_number AND
          acus.award_cd     = acusg2.award_cd AND
          acus.us_group_number    = acusg2.us_group_number
        MINUS
          SELECT  acus.unit_set_cd,
            acus.us_version_number
          FROM  IGS_GR_AWD_CRM_UT_ST  acus
          WHERE acus.grd_cal_type     = acusg1.grd_cal_type AND
            acus.grd_ci_sequence_number = acusg1.grd_ci_sequence_number AND
            acus.ceremony_number    = acusg1.ceremony_number AND
            acus.award_course_cd    = acusg1.award_course_cd AND
            acus.award_crs_version_number = acusg1.award_crs_version_number AND
            acus.award_cd     = acusg1.award_cd AND
            acus.us_group_number    = acusg1.us_group_number)
      );
  BEGIN
    -- Set the default message number
    p_message_name := NULL;
    -- Check Parameters
    IF p_grd_cal_type IS NULL OR
        p_grd_ci_sequence_number IS NULL OR
        p_ceremony_number IS NULL OR
        p_award_course_cd IS NULL OR
        p_award_crs_version_number IS NULL OR
        p_award_cd IS NULL OR
        p_us_group_number IS NULL THEN
      RETURN TRUE;
    END IF;
    -- Check if there is any award_ceremony_us_group records with parent
    -- award_ceremony records with the same order_in_ceremony (are for the
    -- same award_cd but different course codes/versions) which have
    -- award_ceremony_us_group records with the same order_in_award but are made
    -- up of different award_ceremony_unit_set records.
    OPEN c_awc_acusg;
    FETCH c_awc_acusg INTO v_awc_acusg_exists;
    IF c_awc_acusg%FOUND THEN
      CLOSE c_awc_acusg;
      p_message_name := 'IGS_GR_AWD_SET_GRP_EXISTS';
      RETURN FALSE;
    END IF;
    CLOSE c_awc_acusg;
    -- Return the default value
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_awc_acusg%ISOPEN THEN
        CLOSE c_awc_acusg;
      END IF;
      RAISE;
  END;
  EXCEPTION
    WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
  END grdp_val_acusg_order;
END igs_gr_val_awc;

/
