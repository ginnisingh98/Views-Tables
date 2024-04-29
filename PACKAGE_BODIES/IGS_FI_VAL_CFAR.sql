--------------------------------------------------------
--  DDL for Package Body IGS_FI_VAL_CFAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_VAL_CFAR" AS
/* $Header: IGSFI12B.pls 120.0 2005/06/01 22:43:45 appldev noship $ */
/*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        28-Jan-2004   Enh#3167098.FICR112 Build.Modified finp_val_cfar_ins.
  ||  vvutukur        20-May-2002   modified findp_val_cfar_ins,finp_val_ft_closed
  ||                                to remove upper check on fee_type.bug#2344826.
  ----------------------------------------------------------------------------*/
  --
  -- Ensure  S_FEE_TYPE is 'OTHER' and S_FEE_TRIGGER_CAT is not 'INSTITUTN'
  FUNCTION finp_val_cfar_ins(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_fee_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur    28-Jan-2004  Enh#3167098.FICR112.Modified cursor c_sca to consider
  ||                           the student term records also.
  ||  vvutukur        20-May-2002   removed upper check constraint on fee_type column
  ||                                in c_ft cursor.bug#2344826.
  ----------------------------------------------------------------------------*/
        gv_other_detail         VARCHAR2(255);
  BEGIN
  DECLARE
        CURSOR c_ft IS
                SELECT  ft.s_fee_type,
                        ft.s_fee_trigger_cat
                FROM    IGS_FI_FEE_TYPE ft
                WHERE   ft.fee_type = p_fee_type;
        CURSOR c_sca IS
               SELECT   'X'
               FROM     igs_en_stdnt_ps_att sca,
                        igs_fi_f_cat_fee_lbl fcfl,
                        igs_fi_fee_str_stat fsst
               WHERE    sca.person_id = p_person_id
               AND      sca.course_cd = p_course_cd
               AND      fcfl.fee_type = p_fee_type
               AND      fcfl.fee_cat = sca.fee_cat
               AND      fcfl.fee_liability_status = fsst.fee_structure_status
               AND      fsst.s_fee_structure_status = 'ACTIVE'
               UNION ALL
               SELECT   'X'
               FROM     igs_en_spa_terms spa,
                        igs_fi_f_cat_fee_lbl fcfl,
                        igs_fi_fee_str_stat fsst
               WHERE    spa.person_id = p_person_id
               AND      spa.program_cd = p_course_cd
               AND      fcfl.fee_type = p_fee_type
               AND      fcfl.fee_cat = spa.fee_cat
               AND      fcfl.fee_liability_status = fsst.fee_structure_status
               AND      fsst.s_fee_structure_status = 'ACTIVE';

        v_s_fee_type            IGS_FI_FEE_TYPE.s_fee_type%TYPE;
        v_s_fee_trigger_cat     IGS_FI_FEE_TYPE.s_fee_trigger_cat%TYPE;
        v_dummy                 VARCHAR2(1);
        CST_OTHER               IGS_FI_FEE_TYPE.s_fee_type%TYPE := 'OTHER';
        CST_TUITION             IGS_FI_FEE_TYPE.s_fee_type%TYPE := 'TUITION';
        CST_TUTNFEE             IGS_FI_FEE_TYPE.s_fee_type%TYPE := 'TUTNFEE';
        CST_INSTITUTN           IGS_FI_FEE_TYPE.s_fee_trigger_cat%TYPE := 'INSTITUTN';
  BEGIN
        -- Validate the IGS_FI_FEE_AS_RT can only be defined for
        -- fee types with s_fee_type = 'OTHER'or 'TUTNFEE' or 'TUITION' and
        -- s_fee_trigger_cat not 'INSTITUTN'.
        -- Set the default message number
        p_message_name := Null;
        OPEN c_ft;
        FETCH c_ft into v_s_fee_type, v_s_fee_trigger_cat;
        IF c_ft%NOTFOUND THEN           -- if no record is found
                CLOSE c_ft;
                RETURN TRUE;
        END IF;
        CLOSE c_ft;
        -- Check the system fee type
        IF v_s_fee_type <> CST_OTHER
           AND v_s_fee_type <> CST_TUTNFEE
                AND v_s_fee_type <> CST_TUITION THEN
                p_message_name := 'IGS_FI_ASSRATES_OTHER_TUTUION';
                RETURN FALSE;
        END IF;
        -- Check the system fee trigger category
        IF v_s_fee_trigger_cat = CST_INSTITUTN THEN
                p_message_name := 'IGS_FI_FEEASS_NOT_INSTITN';
                RETURN FALSE;
        END IF;
        OPEN c_sca;
        FETCH c_sca INTO v_dummy;
        IF c_sca%NOTFOUND THEN
                CLOSE c_sca;
                p_message_name := 'IGS_FI_FEETYPE_NOT_ACTIVE';
                RETURN FALSE;
        END IF;
        CLOSE c_sca;
        -- Execution Complete
        RETURN TRUE;
  END;
  END finp_val_cfar_ins;
  --
  -- Ensure the start and end dates don't overlap with other records.
  FUNCTION finp_val_cfar_ovrlp(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_fee_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
        gv_other_detail         VARCHAR2(255);
  BEGIN
  DECLARE
        CURSOR c_cfar IS
                SELECT  cfar.start_dt,
                        cfar.end_dt
                FROM    IGS_FI_FEE_AS_RT        cfar
                WHERE   cfar.person_id = p_person_id AND
                        cfar.course_cd = p_course_cd AND
                        cfar.fee_type = p_fee_type AND
                        cfar.start_dt <> p_start_dt;
  BEGIN
        -- Validate the contract_fee+ass_rate (cfar) table to ensure that for
        -- records with the same person_id, course_cd and fee_type that the date ranges
        -- don't overlap.
        --- Set the default message number
        p_message_name := Null;
        FOR v_cfar_rec IN c_cfar LOOP
                IF (v_cfar_rec.end_dt IS NOT NULL) THEN
                        IF (p_start_dt BETWEEN v_cfar_rec.start_dt AND v_cfar_rec.end_dt) THEN
                                p_message_name := 'IGS_FI_STDT_BTWN_STDT_ENDDT';
                                RETURN FALSE;
                        END IF;
                        IF (p_end_dt IS NOT NULL) THEN
                                IF (p_end_dt BETWEEN v_cfar_rec.start_dt AND v_cfar_rec.end_dt) THEN
                                        p_message_name := 'IGS_FI_ENDDT_BTWN_STDT_ENDDT';
                                        RETURN FALSE;
                                END IF;
                                IF (p_start_dt <= v_cfar_rec.start_dt AND
                                                p_end_dt >= v_cfar_rec.end_dt) THEN
                                        p_message_name := 'IGS_FI_STDT_ENDDT_ENCOMPASS';
                                        RETURN FALSE;
                                END IF;
                        ELSE
                                IF (p_start_dt <= v_cfar_rec.start_dt) THEN
                                        p_message_name := 'IGS_FI_OPEN_DATE_RANGE';
                                        RETURN FALSE;
                                END IF;
                        END IF;
                ELSE
                        IF (p_start_dt >= v_cfar_rec.start_dt OR
                                        p_end_dt >= v_cfar_rec.start_dt) THEN
                                p_message_name := 'IGS_FI_DATES_OVERLAP_STDT';
                                RETURN FALSE;
                        END IF;
                END IF;
        END LOOP;
        RETURN TRUE;
  END;
  END finp_val_cfar_ovrlp;
  --
  -- Validate that only one record has an open end date.
  FUNCTION finp_val_cfar_open(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_fee_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
        gv_other_detail         VARCHAR2(255);
  BEGIN
  DECLARE
        v_person_id             IGS_FI_FEE_AS_RT.person_id%TYPE;
        CURSOR c_cfar IS
                SELECT  cfar.person_id
                FROM    IGS_FI_FEE_AS_RT        cfar
                WHERE   cfar.person_id = p_person_id AND
                        cfar.course_cd = p_course_cd AND
                        cfar.fee_type = p_fee_type AND
                        cfar.start_dt <> p_start_dt AND
                        cfar.end_dt IS NULL;
  BEGIN
        -- Validate the IGS_FI_FEE_AS_RT (cfar) table to ensure that
        -- for records with the same person_id, course_cd, and fee_type
        -- that only one record has a NULL end_dt.
        OPEN    c_cfar;
        FETCH   c_cfar  INTO    v_person_id;
        IF (c_cfar%FOUND) THEN
                CLOSE   c_cfar;
                p_message_name := 'IGS_FI_CONTRACT_FEEASS_RATE';
                RETURN FALSE;
        END IF;
        CLOSE   c_cfar;
        p_message_name := Null;
        RETURN TRUE;
  END;
  END finp_val_cfar_open;
  --
  -- Validate that end date is null or >= start date.
  FUNCTION finp_val_cfar_end_dt(
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
        gv_other_detail         VARCHAR2(255);
  BEGIN
        -- Validates the IGS_FI_FEE_AS_RT (cfar) table to ensure that if the
        -- end_dt is NOT NULL and it is greater than or equal to the start_dt.
        IF (p_end_dt IS NOT NULL) AND
                        (p_end_dt < p_start_dt) THEN
                -- The end date must be greater than or equal to the start date.
                p_message_name := 'IGS_GE_END_DT_GE_ST_DATE';
                RETURN FALSE;
        END IF;
        p_message_name := Null;
        RETURN TRUE;
  END finp_val_cfar_end_dt;
  --
  -- Validate the Attendance Mode closed indicator
  FUNCTION finp_val_am_closed(
  p_attendance_mode IN IGS_EN_ATD_MODE_ALL.attendance_mode%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
        gv_other_detail         VARCHAR2(255);
  BEGIN --finp_val_am_closed
        --Validate if IGS_EN_ATD_MODE.attendance_mode is closed
  DECLARE
        v_closed_ind    VARCHAR2(1);
        CURSOR c_am IS
                SELECT  am.closed_ind
                FROM    IGS_EN_ATD_MODE am
                WHERE   am.attendance_mode = p_attendance_mode;
  BEGIN
        --set default message_number
        p_message_name := Null;
        OPEN c_am;
        FETCH c_am INTO v_closed_ind;
        IF (c_am%FOUND) THEN
                IF (v_closed_ind = 'Y') THEN
                        CLOSE c_am;
                        p_message_name := 'IGS_PS_ATTEND_MODE_CLOSED';
                        RETURN FALSE;
                END IF;
        END IF;
        CLOSE c_am;
        RETURN TRUE;
  END;
  END finp_val_am_closed;
  --
  -- Validate the Attendance Type closed indicator
  FUNCTION finp_val_att_closed(
  p_attendance_type IN IGS_EN_ATD_TYPE_ALL.attendance_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
        gv_other_detail         VARCHAR2(255);
  BEGIN --finp_val_att_closed
        --Validate if IGS_EN_ATD_TYPE.attendance_type is closed
  DECLARE
        v_closed_ind    VARCHAR2(1);
        CURSOR c_att IS
                SELECT  att.closed_ind
                FROM    IGS_EN_ATD_TYPE att
                WHERE   att.attendance_type = p_attendance_type;
  BEGIN
        --set default message_number
        p_message_name := Null;
        OPEN c_att;
        FETCH c_att INTO v_closed_ind;
        IF (c_att%FOUND) THEN
                IF (v_closed_ind = 'Y') THEN
                        CLOSE c_att;
                        p_message_name := 'IGS_PS_ATTEND_TYPE_CLOSED';
                        RETURN FALSE;
                END IF;
        END IF;
        CLOSE c_att;
        RETURN TRUE;
  END;
  END finp_val_att_closed;
  --
  -- Validate the Location closed indicator
  FUNCTION finp_val_loc_closed(
  p_location_cd IN IGS_AD_LOCATION_ALL.location_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
        gv_other_detail         VARCHAR2(255);
  BEGIN --finp_val_loc_closed
        --Validate if IGS_EN_ATD_TYPE.attendance_type is closed
  DECLARE
        v_closed_ind    VARCHAR2(1);
        v_location_type igs_lookups_view.lookup_code%TYPE;
        CURSOR c_loc IS
                SELECT  loc.closed_ind,
                        loc.location_type
                FROM    IGS_AD_LOCATION loc
                WHERE   loc.location_cd = p_location_cd;
  BEGIN
        --set default message_number
        p_message_name := Null;
        OPEN c_loc;
        FETCH c_loc INTO v_closed_ind, v_location_type;
        IF (c_loc%FOUND) THEN
                IF (v_closed_ind = 'Y') THEN
                        CLOSE c_loc;
                        p_message_name := 'IGS_FI_LOCATION_CLOSED';
                        RETURN FALSE;
                END IF;
                IF (v_location_type <> 'CAMPUS') THEN
                        CLOSE c_loc;
                        p_message_name := 'IGS_PS_LOC_NOT_TYPE_CAMPUS';
                        RETURN FALSE;
                END IF;
        END IF;
        CLOSE c_loc;
        RETURN TRUE;
  END;
  END finp_val_loc_closed;
  --
  -- Validate the fee_type in the fee_type_account is not closed.
  FUNCTION finp_val_ft_closed(
  p_fee_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        20-May-2002   removed upper check constraint on fee_type column
  ||                                in c_ft cursor.bug#2344826.
  ----------------------------------------------------------------------------*/
        gv_other_detail         VARCHAR2(255);
  BEGIN
  DECLARE
        CURSOR c_ft IS
                SELECT  ft.closed_ind
                FROM    IGS_FI_FEE_TYPE ft
                WHERE   ft.fee_type = p_fee_type;
        v_fee_type      IGS_FI_FEE_TYPE.closed_ind%TYPE;
  BEGIN         -- finp_val_ft_closed
        -- Validate that the fee type is not closed
        -- Set the default message number
        p_message_name := Null;
        OPEN c_ft;
        FETCH c_ft into v_fee_type;
        IF c_ft%NOTFOUND THEN       -- If a record is not found
                CLOSE c_ft;
                RETURN TRUE;
        END IF;
        CLOSE c_ft;
        IF v_fee_type = 'Y' then
                p_message_name := 'IGS_FI_FEETYPE_CLOSED';
                RETURN FALSE;
        END IF;
        -- Return the default value
        RETURN TRUE;
  END;
  END finp_val_ft_closed;
END IGS_FI_VAL_CFAR;

/
