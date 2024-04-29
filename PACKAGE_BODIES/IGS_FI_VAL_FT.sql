--------------------------------------------------------
--  DDL for Package Body IGS_FI_VAL_FT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_VAL_FT" AS
/* $Header: IGSFI33B.pls 120.0 2005/06/01 18:46:11 appldev noship $ */
  --
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  rmaddipa        28-SEP-04       Enh #: 3880438 Retention Enhancements. Modified finp_val_ft_opt_pymt
  ||  rmaddipa        22-SEP-04       Bug #: 3864296 Modified finp_val_ft_trig
  ||  rmaddipa        02-SEP-04       Bug #: 3864296 Modified local functions of function finp_val_ft_trig
  ||  rmaddipa        31-AUG-04       Bug #: 3864296 Modified a local function of function finp_val_ft_trig
  ||
  ||  vvutukur        26-Aug-2002  Bug#2531390.Modified function finp_val_ft_sftc.
  ----------------------------------------------------------------------------*/

  -- removed code related to table charge method apportionemtn as the table is being obsoleted (2187247) (rnirwani) (18.Jan.02)
-- Removed reference to IGS_FI_FEE_ENCMB table asthe table is obseleted as part of bug 2126091 sykrishn -30112001
  -- Validate the optional payment indicator can be set to 'Y'.
  FUNCTION finp_val_ft_opt_pymt(
  p_fee_type IN VARCHAR2 ,
  p_optional_payment_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
    ------------------------------------------------------------------
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --rmaddipa    28-SEP-2004     Enh #:3880438 . Added code to check whether any retention schedule exist at teaching period level
  --                            for the context fee type.
  --------------------------------------------------------------------
  BEGIN         -- finp_val_ft_opt_pymt
        -- Validate changes to the IGS_FI_FEE_TYPE.s_fee_trigger_cat, cannot be set yo 'Y'
        -- when related  fee_rentention_schedule records exist.
  DECLARE
        v_dummy                 VARCHAR2(1);
        CURSOR c_fee_retention_schedule (
                        cp_fee_type     IGS_FI_FEE_RET_SCHD.fee_type%TYPE) IS
                SELECT  'x'
                FROM    IGS_FI_FEE_RET_SCHD frs
                WHERE   frs.fee_type    = cp_fee_type;
        -- Removed reference to IGS_FI_FEE_ENCMB(c_fee_encumbrance cursor)  table asthe table is obseleted as part of bug 2126091 sykrishn -30112001

        --cursor to check whether any retention schedule exists at teaching period level for a given fee type.
        CURSOR cur_tp_ret_schd (
                                cp_fee_type  igs_fi_fee_type_all.fee_type%TYPE) IS
                SELECT 'X'
                FROM igs_fi_tp_ret_schd
                WHERE fee_type = cp_fee_type;

  BEGIN
        p_message_name := NULL;
        -- Validate parameters
        IF(p_fee_type IS NULL OR
                        p_optional_payment_ind IS NULL) THEN
                p_message_name := NULL;
                Return TRUE;
        END IF;
        -- Check if the optional_payment_ind is set to 'Y' if it is look for related
        -- IGS_FI_FEE_RET_SCHD
        IF(p_optional_payment_ind = 'Y') THEN
                -- Check for Fee Retention Schedules related to the Fee Type
                OPEN    c_fee_retention_schedule(
                                        p_fee_type);
                FETCH   c_fee_retention_schedule INTO v_dummy;
                IF(c_fee_retention_schedule%FOUND) THEN
                        CLOSE c_fee_retention_schedule;
                        p_message_name := 'IGS_FI_OPPYMNT_Y_FEERETSCH';
                        RETURN FALSE;
                END IF;
                CLOSE c_fee_retention_schedule;

                OPEN cur_tp_ret_schd(cp_fee_type => p_fee_type);
                FETCH cur_tp_ret_schd INTO v_dummy;
                IF (cur_tp_ret_schd%FOUND) THEN
                    CLOSE cur_tp_ret_schd;
                    p_message_name := 'IGS_FI_OPPYMNT_Y_FEERETSCH';
                    RETURN FALSE;
                END IF;
                CLOSE cur_tp_ret_schd;
                -- Check for Fee Encumbrances related to the Fee Type
-- Removed reference to IGS_FI_FEE_ENCMB table asthe table is obseleted as part of bug 2126091 sykrishn -30112001
        END IF;
        RETURN TRUE;
  END;
  END finp_val_ft_opt_pymt;
  --
  -- Validate changes to s_fee_trigger_cat.
  FUNCTION finp_val_ft_trig(
  p_fee_type IN VARCHAR2 ,
  p_new_s_fee_trigger_cat IN VARCHAR2 ,
  p_old_s_fee_trigger_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

    ------------------------------------------------------------------
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --rmaddipa    22-SEP-04       Bug #:3864296 added calls to functions finpl_get_course_type_trig() and
  --                            finpl_get_course_group_trig() to check for existence of Program Type and Program Group triggers
  --rmaddipa    01-SEP-04       Bug #: 3864296
  --                            Local functions finpl_get_course_type_trig,
  --                                            finpl_get_course_group_trig,
  --                                            finpl_get_unit_trig,
  --                                            finpl_get_unit_set_trig  Modified
  --rmaddipa    31-AUG-04       Bug #: 3864296
  --                            Local function  finpl_get_course_trig  Modified
  -------------------------------------------------------------------


  BEGIN         -- finp_val_ft_trig
        -- Validate changes to the IGS_FI_FEE_TYPE.s_fee_trigger_cat.
        -- If changing from INSTITUTN to anything else ensure there are
        -- no related IGS_FI_FEE_AS records.
        -- If changing to INSTITUTN from anything else ensure there are no
        -- related IGS_FI_FEE_AS records
        -- and that there are no related IGS_PS_COURSE, IGS_PS_UNIT or IGS_PS_UNIT set triggers.
        -- If changing to IGS_PS_COURSE ensure there are only IGS_PS_COURSE triggers.
        -- If changing to IGS_PS_UNIT ensure there are only IGS_PS_UNIT triggers.
        -- If changing to UNITSET ensure there are only IGS_PS_UNIT set triggers.
  DECLARE
        cst_institutn           CONSTANT VARCHAR2(10) := 'INSTITUTN';
        cst_unit                CONSTANT VARCHAR2(10) := 'UNIT';
        cst_unitset             CONSTANT VARCHAR2(10) := 'UNITSET';
        cst_course              CONSTANT VARCHAR2(10) := 'COURSE';
        cst_composite           CONSTANT VARCHAR2(10) := 'COMPOSITE';
        v_dummy                 VARCHAR2(1);
        FUNCTION finpl_get_fee_ass(
                                p_fee_type IGS_FI_FEE_AS.fee_type%TYPE)
        RETURN BOOLEAN AS
        BEGIN
        DECLARE
                v_dummy                         VARCHAR2(1);
                CURSOR c_fee_ass (
                        cp_fee_type     IGS_FI_FEE_AS.fee_type%TYPE) IS
                SELECT  'x'
                FROM    IGS_FI_FEE_AS fa
                WHERE   fa.fee_type     = cp_fee_type;
        BEGIN
                -- Check for Fee Assessment records in the IGS_FI_FEE_AS table. If any are found
                -- the function should return TRUE otherwise return FALSE.
                OPEN    c_fee_ass(
                                p_fee_type);
                FETCH   c_fee_ass INTO v_dummy;
                IF(c_fee_ass%FOUND) THEN
                        CLOSE c_fee_ass;
                        RETURN TRUE;
                END IF;
                CLOSE c_fee_ass;
                RETURN FALSE;
        END;
        END finpl_get_fee_ass;
        FUNCTION finpl_get_course_type_trig(
                                p_fee_type IGS_PS_TYPE_FEE_TRG.fee_type%TYPE)
        RETURN BOOLEAN AS
 ------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --rmaddipa    2-SEP-04        Bug #: 3864296
  --                            Modified the definition of cursor c_crs_typ_fee_trig
  --                            so that the records in table IGS_PS_TYPE_FEE_TRG which are logically deleted
  --                            are not considered.
  -------------------------------------------------------------------
        BEGIN
        DECLARE
                v_dummy                         VARCHAR2(1);

                -- cursor definition modified by rmaddipa ( Bug #: 3864296)
                -- records that are deleted should'nt be considered
                CURSOR c_crs_typ_fee_trig (
                                cp_fee_type     IGS_PS_TYPE_FEE_TRG.fee_type%TYPE) IS
                SELECT  'x'
                FROM    IGS_PS_TYPE_FEE_TRG ctft
                WHERE   ctft.fee_type   = cp_fee_type
                        AND logical_delete_dt IS NULL;
        BEGIN
                -- Check for IGS_PS_COURSE Trigger records in the IGS_PS_TYPE_FEE_TRG table.
                -- If any are found the function should return TRUE otherwise return FALSE.
                OPEN    c_crs_typ_fee_trig(
                                        p_fee_type);
                FETCH   c_crs_typ_fee_trig INTO v_dummy;
                IF(c_crs_typ_fee_trig%FOUND) THEN
                        CLOSE c_crs_typ_fee_trig;
                        RETURN TRUE;
                END IF;
                CLOSE c_crs_typ_fee_trig;
                RETURN FALSE;
        END;
        END finpl_get_course_type_trig;
        FUNCTION finpl_get_course_group_trig(
                                p_fee_type IGS_PS_GRP_FEE_TRG.fee_type%TYPE)
        RETURN BOOLEAN AS
 ------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --rmaddipa    2-SEP-04        Bug #: 3864296
  --                            Modified the definition of cursor c_crs_grp_fee_trig
  --                            so that the records in table IGS_PS_GRP_FEE_TRG which are logically deleted
  --                            are not considered.
  -------------------------------------------------------------------
        BEGIN
        DECLARE
                v_dummy                         VARCHAR2(1);

                -- cursor definition modified by rmaddipa ( Bug #: 3864296)
                -- records that are deleted should'nt be considered
                CURSOR c_crs_grp_fee_trig (
                                cp_fee_type     IGS_PS_GRP_FEE_TRG.fee_type%TYPE) IS
                SELECT  'x'
                FROM    IGS_PS_GRP_FEE_TRG cgft
                WHERE   cgft.fee_type   = cp_fee_type
                        AND logical_delete_dt IS NULL;
        BEGIN
                -- Check for IGS_PS_COURSE Trigger records in the IGS_PS_GRP_FEE_TRG table.
                -- If any are found the function should return TRUE otherwise return FALSE.
                OPEN    c_crs_grp_fee_trig(
                                        p_fee_type);
                FETCH   c_crs_grp_fee_trig INTO v_dummy;
                IF(c_crs_grp_fee_trig%FOUND) THEN
                        CLOSE c_crs_grp_fee_trig;
                        RETURN TRUE;
                END IF;
                CLOSE c_crs_grp_fee_trig;
                RETURN FALSE;
        END;
        END finpl_get_course_group_trig;
        FUNCTION finpl_get_course_trig(
                                p_fee_type IGS_PS_TYPE_FEE_TRG.fee_type%TYPE)
        RETURN BOOLEAN AS
  ------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --rmaddipa    22-SEP-04       Bug #:3864296 removed calls to functions finpl_get_course_type_trig() and
  --                            finpl_get_course_group_trig() since they are being called from finp_val_ft_trig().
  --rmaddipa    31-AUG-04       Bug #: 3864296
  --                            Modified the definition of cursor c_crs_fee_trig
  --                            so that the records in table IGS_PS_FEE_TRG which are logically deleted
  --                            are not considered.
  -------------------------------------------------------------------
        BEGIN
        DECLARE
                v_dummy                         VARCHAR2(1);

                -- cursor definition modified by rmaddipa ( Bug #: 3864296)
                -- records that are deleted should'nt be considered
                CURSOR c_crs_fee_trig (
                                cp_fee_type     IGS_PS_FEE_TRG.fee_type%TYPE) IS
                SELECT  'x'
                FROM    IGS_PS_FEE_TRG cft
                WHERE   cft.fee_type    = cp_fee_type
                        AND logical_delete_dt IS NULL;

        BEGIN
                -- Check for IGS_PS_COURSE Trigger records in the IGS_PS_TYPE_FEE_TRG,
                -- IGS_PS_GRP_FEE_TRG OR IGS_PS_FEE_TRG tables. If any are found
                -- the function should return TRUE otherwise return FALSE.
                OPEN    c_crs_fee_trig (p_fee_type);
                FETCH   c_crs_fee_trig INTO v_dummy;
                IF(c_crs_fee_trig%FOUND) THEN
                        CLOSE c_crs_fee_trig;
                        RETURN TRUE;
                END IF;
                CLOSE c_crs_fee_trig;
                RETURN FALSE;
        END;
        END finpl_get_course_trig;
        FUNCTION finpl_get_unit_trig(
                                p_fee_type IGS_FI_UNIT_FEE_TRG.fee_type%TYPE)
        RETURN BOOLEAN AS
  ------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --rmaddipa    2-SEP-04        Bug #: 3864296
  --                            Modified the definition of cursor c_unit_fee_trig
  --                            so that the records in table IGS_FI_UNIT_FEE_TRG which are logically deleted
  --                            are not considered.
  -------------------------------------------------------------------
        BEGIN
        DECLARE
                v_dummy                         VARCHAR2(1);
                -- cursor definition modified by rmaddipa ( Bug #: 3864296)
                -- records that are deleted should'nt be considered
                CURSOR c_unit_fee_trig (
                                cp_fee_type     IGS_FI_UNIT_FEE_TRG.fee_type%TYPE) IS
                SELECT  'x'
                FROM    IGS_FI_UNIT_FEE_TRG uft
                WHERE   uft.fee_type    = cp_fee_type
                        AND logical_delete_dt IS NULL;
        BEGIN
                -- Check if there are any IGS_PS_UNIT Triggers in the IGS_FI_UNIT_FEE_TRG table.
                -- If any are found the function should return TRUE otherwise return FALSE.
                OPEN    c_unit_fee_trig(
                                        p_fee_type);
                FETCH   c_unit_fee_trig INTO v_dummy;
                IF(c_unit_fee_trig%FOUND) THEN
                        CLOSE c_unit_fee_trig;
                        RETURN TRUE;
                END IF;
                CLOSE c_unit_fee_trig;
                RETURN FALSE;
        END;
        END finpl_get_unit_trig;
        FUNCTION finpl_get_unit_set_trig(
                                p_fee_type IGS_EN_UNITSETFEETRG.fee_type%TYPE)
        RETURN BOOLEAN AS
  ------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --rmaddipa    2-SEP-04        Bug #: 3864296
  --                            Modified the definition of cursor c_unit_set_fee_trig
  --                            so that the records in table IGS_EN_UNITSETFEETRG which are logically deleted
  --                            are not considered.
  -------------------------------------------------------------------
        BEGIN
        DECLARE
                v_dummy                         VARCHAR2(1);
                -- cursor definition modified by rmaddipa ( Bug #: 3864296)
                -- records that are deleted should'nt be considered
                CURSOR c_unit_set_fee_trig(
                                cp_fee_type     IGS_EN_UNITSETFEETRG.fee_type%TYPE) IS
                SELECT  'x'
                FROM    IGS_EN_UNITSETFEETRG usft
                WHERE   usft.fee_type   = cp_fee_type
                        AND logical_delete_dt IS NULL;
        BEGIN
                -- Check if there are any IGS_PS_UNIT Set Triggers in the IGS_EN_UNITSETFEETRG table.
                -- If any are found the function should return TRUE otherwise return FALSE.
                OPEN    c_unit_set_fee_trig(
                                                p_fee_type);
                FETCH   c_unit_set_fee_trig INTO v_dummy;
                IF(c_unit_set_fee_trig%FOUND) THEN
                        CLOSE c_unit_set_fee_trig;
                        RETURN TRUE;
                END IF;
                CLOSE c_unit_set_fee_trig;
                RETURN FALSE;
        END;
        END finpl_get_unit_set_trig;
  BEGIN         -- finp_val_ft_trig
        p_message_name := NULL;
        -- Validate parameters
        IF(p_fee_type IS NULL OR
                        p_old_s_fee_trigger_cat IS NULL OR
                        p_new_s_fee_trigger_cat IS NULL) THEN
                p_message_name := NULL;
                Return TRUE;
        END IF;
        -- Check trigger details if the s_fee_trigger_cat has changed
        IF(p_old_s_fee_trigger_cat <> p_new_s_fee_trigger_cat) THEN
                IF(p_old_s_fee_trigger_cat = cst_institutn OR
                        p_new_s_fee_trigger_cat = cst_institutn) THEN
                        IF(finpl_get_fee_ass(p_fee_type) = TRUE) THEN
                                p_message_name := 'IGS_FI_CAT_INSTITUTN';
                                Return FALSE;
                        END IF;
                END IF;
                IF(p_new_s_fee_trigger_cat = cst_institutn OR
                        p_new_s_fee_trigger_cat = cst_unit OR
                        p_new_s_fee_trigger_cat = cst_unitset) THEN
                        IF(finpl_get_course_trig(p_fee_type) = TRUE) THEN
                                p_message_name := 'IGS_FI_CAT_PRGFEE_TRG_EXISTS';
                                Return FALSE;
                        END IF;
                        IF(finpl_get_course_type_trig(p_fee_type) = TRUE) THEN
                               p_message_name := 'IGS_FI_NOTCHG_SYSFEE_TRGCAT';
                               Return FALSE;
                        END IF;
                        IF(finpl_get_course_group_trig(p_fee_type) = TRUE) THEN
                              p_message_name := 'IGS_FI_NOTCHG_SYSFEE_TRGCAT';
                              Return FALSE;
                        END IF;
                END IF;
                IF(p_new_s_fee_trigger_cat = cst_institutn OR
                        p_new_s_fee_trigger_cat = cst_course OR
                        p_new_s_fee_trigger_cat = cst_unitset) THEN
                        IF(finpl_get_unit_trig(p_fee_type) = TRUE) THEN
                                p_message_name := 'IGS_FI_CAT_UNITFEE_TRG_EXISTS';
                                Return FALSE;
                        END IF;
                END IF;
                IF(p_new_s_fee_trigger_cat = cst_institutn OR
                        p_new_s_fee_trigger_cat = cst_course OR
                        p_new_s_fee_trigger_cat = cst_unit) THEN
                        IF(finpl_get_unit_set_trig(p_fee_type) = TRUE) THEN
                                p_message_name := 'IGS_FI_CAT_UNIT_SETFEE_TRG';
                                Return FALSE;
                        END IF;
                END IF;
                IF(p_new_s_fee_trigger_cat = cst_composite) THEN
                        IF(finpl_get_course_type_trig(p_fee_type) = TRUE) THEN
                                p_message_name := 'IGS_FI_NOTCHG_SYSFEE_TRGCAT';
                                Return FALSE;
                        END IF;
                        IF(finpl_get_course_group_trig(p_fee_type) = TRUE) THEN
                                p_message_name := 'IGS_FI_NOTCHG_SYSFEE_TRGCAT';
                                Return FALSE;
                        END IF;
                END IF;
        END IF;
        RETURN TRUE;
  END;
  END finp_val_ft_trig;
  --
  -- Validate the s_fee_type and s_fee_trigger_cat are compatible.
  FUNCTION finp_val_ft_sft_trig(
  p_s_fee_type IN VARCHAR2 ,
  p_s_fee_trigger_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
        -- finp_val_ft_sft_trig
        -- Validate the IGS_FI_FEE_TYPE.s_fee_type and fee_type.s_fee_trigger_cat are
        -- compatible.
  DECLARE
  BEGIN
        p_message_name := NULL;
        -- Validate parameters
        IF ( p_s_fee_type  IS NULL OR p_s_fee_trigger_cat  IS NULL) THEN
                RETURN TRUE;
        END IF;
        -- Check the system fee type against the system trigger category
        IF p_s_fee_type IN ('HECS', 'TUITION') AND
                p_s_fee_trigger_cat NOT IN ('COURSE', 'UNITSET') THEN
                p_message_name := 'IGS_FI_SYSFEETYPE_HECS_TUITIO';
                RETURN FALSE;
        END IF;
        RETURN TRUE;
  END;
  END finp_val_ft_sft_trig;
  --
  -- Validate changes to s_fee_trigger_cat.
  FUNCTION finp_val_ft_sftc(
  p_fee_type IN VARCHAR2 ,
  p_new_s_fee_trigger_cat IN VARCHAR2 ,
  p_old_s_fee_trigger_cat IN VARCHAR2 ,
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
  ||  vvutukur        26-Aug-2002  Bug#2531390.Removed cursor C_FEE_PAYMENT_SCHEDULE and related code, in
  ||                               which there is Check for FCFL level Fee Payment Schedules related to
  ||                               the Fee Type.
  ----------------------------------------------------------------------------*/
  BEGIN         -- finp_val_ft_sftc
        -- Validate changes to the IGS_FI_FEE_TYPE.s_fee_trigger_cat.
        -- If changing to INSTITUTN from anything else ensure there are no
        -- related IGS_FI_F_CAT_FEE_LBL records with SI_FI_S_CHG_MTH or
        -- rule_sequence_number set.
        -- If changing to INSTITUTN from anything else ensure there are no
        -- related records at FCFL level for the following:
        --      IGS_FI_FEE_PAY_SCHD
        --      IGS_FI_FEE_RET_SCHD
        --      IGS_FI_FEE_ENCMB - Removed reference from this package-
        --      IGS_FI_CHG_MTH_APP
        --      IGS_FI_FEE_AS_RATE
        --      IGS_FI_ELM_RANGE
  DECLARE
        v_dummy                 VARCHAR2(1);
        CURSOR c_fee_cat_fee_liability (cp_fee_type     IGS_FI_FEE_TYPE.fee_type%TYPE) IS
        SELECT  'x'
        FROM    IGS_FI_F_CAT_FEE_LBL
        WHERE   FEE_TYPE = cp_fee_type AND
                (s_chg_method_type IS NOT NULL OR
                rul_sequence_number IS NOT NULL);

        CURSOR c_fee_retention_schedule (cp_fee_type    IGS_FI_FEE_TYPE.fee_type%TYPE) IS
        SELECT  'x'
        FROM    IGS_FI_FEE_RET_SCHD
        WHERE   FEE_TYPE = cp_fee_type AND
                s_relation_type = 'FCFL';

 -- Removed reference to IGS_FI_FEE_ENCMB table asthe table is obseleted as part of bug 2126091 sykrishn -30112001

        -- removed the cursor selecting data from the charge method apportionment table
        -- tbl obsoleted as a prt of bug - 2187247 (rnirwani)

        CURSOR c_fee_ass_rate (cp_fee_type      IGS_FI_FEE_TYPE.fee_type%TYPE) IS
        SELECT  'x'
        FROM    IGS_FI_FEE_AS_RATE
        WHERE   FEE_TYPE = cp_fee_type AND
                s_relation_type = 'FCFL' AND
                logical_delete_dt IS NULL;
        CURSOR c_elements_range (cp_fee_type    IGS_FI_FEE_TYPE.fee_type%TYPE) IS
        SELECT  'x'
        FROM    IGS_FI_ELM_RANGE
        WHERE   FEE_TYPE = cp_fee_type AND
                s_relation_type = 'FCFL' AND
                logical_delete_dt IS NULL;
  BEGIN
        p_message_name := NULL;
        -- Validate parameters
        IF(p_fee_type IS NULL OR
                        p_old_s_fee_trigger_cat IS NULL OR
                        p_new_s_fee_trigger_cat IS NULL) THEN
                p_message_name := NULL;
                Return TRUE;
        END IF;
        IF p_new_s_fee_trigger_cat =  'INSTITUTN' AND
            p_old_s_fee_trigger_cat <> p_new_s_fee_trigger_cat THEN
                -- Check for fee cat fee liability records related to this Fee Type
                OPEN    c_fee_cat_fee_liability(p_fee_type);
                FETCH   c_fee_cat_fee_liability INTO v_dummy;
                IF(c_fee_cat_fee_liability%FOUND) THEN
                        CLOSE c_fee_cat_fee_liability;
                        p_message_name := 'IGS_FI_SYS_FEE_TRGCAT_NOTCHG';
                        RETURN FALSE;
                END IF;
                CLOSE c_fee_cat_fee_liability;

                -- Check for FCFL level  Fee Retention Schedules related to this Fee Type
                OPEN    c_fee_retention_schedule(p_fee_type);
                FETCH   c_fee_retention_schedule INTO v_dummy;
                IF(c_fee_retention_schedule%FOUND) THEN
                        CLOSE c_fee_retention_schedule;
                        p_message_name := 'IGS_FI_TRGCAT_FEE_RETNSCH';
                        RETURN FALSE;
                END IF;
                CLOSE c_fee_retention_schedule;
                -- Check for FCFL level  Fee Encumbrances related to this Fee Type
                -- Removed reference to IGS_FI_FEE_ENCMB table asthe table is obseleted as part of bug 2126091 sykrishn -30112001

                -- Check for FCFL level Charge Method Apportions related to this Fee Type
                 -- removed the reference to charge method approtionemnt table since this has been obsoleted. bug-2187247 (rnirwani)


                -- Check for FCFL level Fee Ass Rates related to this Fee Type
                OPEN    c_fee_ass_rate (p_fee_type);
                FETCH   c_fee_ass_rate INTO v_dummy;
                IF(c_fee_ass_rate%FOUND) THEN
                        CLOSE c_fee_ass_rate;
                        p_message_name := 'IGS_FI_TRGSCH_FEEASS_RATE';
                        RETURN FALSE;
                END IF;
                CLOSE c_fee_ass_rate;
                -- Check for FCFL level Elements Range records related to this Fee Type
                OPEN    c_elements_range (p_fee_type);
                FETCH   c_elements_range INTO v_dummy;
                IF(c_elements_range%FOUND) THEN
                        CLOSE c_elements_range;
                        p_message_name := 'IGS_FI_TRGSCH_ELERNG_RECORD';
                        RETURN FALSE;
                END IF;
                CLOSE c_elements_range;
        END IF;
        Return TRUE;
  END;
  END finp_val_ft_sftc;
END IGS_FI_VAL_FT;

/
