--------------------------------------------------------
--  DDL for Package Body IGS_FI_GEN_005
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_GEN_005" AS
/* $Header: IGSFI05B.pls 120.3 2006/02/23 21:16:19 skharida noship $ */
/********  ------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --skharida    24-Feb-2006     After Code Review: Modified finpl_val_trig_group() Bug# 5018036
  --skharida    15-Feb-2006     Modified finpl_val_trig_group() Bug# 5018036, (version 12.1)
  --bannamal    27-May-2005     Fee Calculation Performance Enhancement. Changes done as per TD.
  --pathipat    21-Sep-2004     Enh 3880438 - Retention Enhancements
  --                            Removed function get_retention_amount
  -- pathipat   14-Oct-2003     Enh 3117341 - Audit and Special Fees TD
  --                            Modified finp_val_fee_trigger(), added function get_retention_amount
  --pathipat    18-Apr-2003     Enh:2831569 - Commercial Receivables build
  --                            Modified finp_get_acct_meth()
  -- pradhakr   15-Jan-2003     Added one more paramter no_assessment_ind to
  --                            the call enrp_get_load_apply as an impact, following
  --                            the modification of the package Igs_En_Prc_Load.
  --                            Changes wrt ENCR026. Bug# 2743459
  --smadathi    03-Jan-2003     Bug 2684895. Created new generic function
  --                            finp_get_prsid_grp_code which returns group code
  sarakshi      13-sep-2002     Enh#2564643,removed the function validate_psa
    rnirwani    06-May-02       Bug# 2345570, in the usage of the view IGS_FI_FEE_TRG_GRP_V replaced the column trigger_type with trigger_type_code.
                                modification done in procedure finpl_val_trig_group
  --smadathi    26-feb-2002     bug 2238413. procedure finp_get_receivables_inst modified
  --jbegum      08-Feb-2002     Bug 2201081.Added function validate_psa.
  --sarakshi    24-jan-2002     Bug 2195715.Added function finp_get_acct_meth
  --schodava    29-Jan-2002 Enh # 2187247
  --                SFCR021: FCI-LCI Relation
  --                Modified function finp_val_fee_lblty
  --smadathi   22-Jan-2002      Bug 2170429. Procedure FINP_SET_FSS_EXPIRED
  --                             removed.
  --msrinivi                    Bug 1956374. duplicate removal Pointed genp_val_bus_day to igs_tr_val_tri
  ------------------------------------------------------------------*****/

g_v_yes           CONSTANT  VARCHAR2(10) := 'Y';
g_v_no            CONSTANT  VARCHAR2(10) := 'N';
g_v_sua_status    CONSTANT  VARCHAR2(30) := 'UNIT_ATTEMPT_STATUS';

FUNCTION finp_val_fee_lblty(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_fee_type IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
  /******************************************************************
  Created By        :
  Date Created By   :
  Purpose           :
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who        When        What
  schodava   21-Jan-2002     Enh # 2187247
                 Cursor c_ftcmav removed
                 Function finp_get_lci_fci_relation
                 invoked.
******************************************************************/

    gv_other_detail     VARCHAR2(255);
    gr_scaeh        IGS_AS_SC_ATTEMPT_H_ALL%ROWTYPE;
    gv_data_found       BOOLEAN;
    gt_suaeh_table      IGS_FI_GET_SUAEH.t_suaeh_dtl;
    gv_table_index      BINARY_INTEGER;
        lv_param_values         VARCHAR2(1080);

BEGIN   -- finp_val_fee_lblty
    -- This routine validates whether or not a student's IGS_PS_COURSE attempt
    -- is liable for fees. The routine returns TRUE if the student's IGS_PS_COURSE
    -- attempt is liable for fees and FALSE if the student's IGS_PS_COURSE attempt
    -- is not liable for fees.  If the fee type is passed as an input
    -- parameter, the routine will check if the student's IGS_PS_COURSE attempt is
    -- liable for the specified fee type.

DECLARE

    cst_active      CONSTANT VARCHAR2(10) := 'ACTIVE';
    cst_institutn       CONSTANT VARCHAR2(10) := 'INSTITUTN';
    v_liability     BOOLEAN := FALSE;
    v_load_found        BOOLEAN := FALSE;
    v_dummy         CHAR(1);
    v_trigger_fired     igs_lookups_view.lookup_code%TYPE;
    v_index         BINARY_INTEGER;
        r_suaeh         IGS_FI_GET_SUAEH.r_t_suaeh_dtl;
    v_ret_cal_type      igs_ca_type.cal_type%TYPE;
    v_ret_ci_sequence_number igs_ca_type.cal_type%TYPE;
    v_message_name      fnd_new_messages.message_name%TYPE;

    -- cursor to find the ACTIVE fee liabilities on the effective date

    CURSOR c_ftci IS

    SELECT  ftci.FEE_TYPE,
        ftci.fee_cal_type,
        ftci.fee_ci_sequence_number,
        ft.s_fee_trigger_cat
    FROM    IGS_FI_F_TYP_CA_INST    ftci,
        IGS_FI_FEE_STR_STAT fss,
        IGS_FI_FEE_TYPE     ft
    WHERE   (p_fee_type IS NULL OR
        ftci.FEE_TYPE = p_fee_type) AND
        fss.FEE_STRUCTURE_STATUS = ftci.fee_type_ci_status AND
        fss.s_fee_structure_status = cst_active AND
        ft.FEE_TYPE = ftci.FEE_TYPE AND
        ftci.FEE_TYPE IN
        (SELECT FEE_TYPE
            FROM    IGS_FI_F_CAT_FEE_LBL_V  fcflv,
                IGS_FI_FEE_STR_STAT fss
            WHERE   fcflv.FEE_CAT = p_fee_cat AND
                fcflv.fee_cal_type = ftci.fee_cal_type AND
                fcflv.fee_ci_sequence_number = ftci.fee_ci_sequence_number AND
                fcflv.FEE_TYPE = ftci.FEE_TYPE AND
                fss.FEE_STRUCTURE_STATUS = fcflv.fee_liability_status AND
                fss.s_fee_structure_status = cst_active AND
                p_effective_dt BETWEEN
                        IGS_CA_GEN_001.calp_get_alias_val(fcflv.start_dt_alias,
                                fcflv.start_dai_sequence_number,
                                ftci.fee_cal_type,
                                ftci.fee_ci_sequence_number) AND
                        IGS_CA_GEN_001.calp_get_alias_val(fcflv.end_dt_alias,
                                fcflv.end_dai_sequence_number,
                                ftci.fee_cal_type,
                                ftci.fee_ci_sequence_number));

    -- cursor find the charge method apportionments applicable to the
    -- fee cat fee liability
    -- Enh # 2187247 cursor removed and functionality replaced by the call to the function
    -- igs_fi_gen_001.finp_get_lcfi_reln

    -- check if the IGS_PS_COURSE attempt status is fee assessible

    CURSOR c_scas ( cp_course_attempt_status IGS_LOOKUPS_VIEW.lookup_code%TYPE ) IS

        SELECT  'x'
        FROM    IGS_LOOKUPS_view    scas
        WHERE   scas.lookup_code = cp_course_attempt_status AND
                        scas.lookup_type = 'CRS_ATTEMPT_STATUS' AND
            scas.fee_ass_ind = 'Y';

    -- check if the IGS_PS_UNIT attempt status is fee assessible

    CURSOR c_suas ( cp_unit_attempt_status IGS_LOOKUPS_VIEW.lookup_code%TYPE) IS

        SELECT  'x'
        FROM    IGS_LOOKUPS_view suas
        WHERE   suas.lookup_code = cp_unit_attempt_status AND
                        suas.lookup_type = 'UNIT_ATTEMPT_STATUS' AND
            suas.fee_ass_ind = 'Y';

BEGIN   -- finp_val_fee_lblty
    -- Set the default message number



    p_message_name := Null;
    -- check parameters

    IF p_person_id IS NULL OR
            p_course_cd IS NULL OR
            p_fee_cat IS NULL OR
            p_effective_dt IS NULL THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception(Null, Null, fnd_message.get);
    END IF;

    -- Find the ACTIVE fee cat fee liabilities

    FOR v_ftci IN c_ftci LOOP
        -- check if the fee type is a liability for the sca
        v_liability := FALSE;
        -- get sca effective history data
        IGS_FI_GET_SCAEH.finp_get_scaeh(
                p_person_id,
                p_course_cd,
                p_effective_dt,
                gv_data_found,
                gr_scaeh);
        IF gv_data_found = TRUE THEN
            -- check if the IGS_PS_COURSE status is fee assessible
            OPEN c_scas (gr_scaeh.course_attempt_status);
            FETCH c_scas INTO v_dummy;
            IF (c_scas%FOUND) THEN
                -- check if a fee trigger is fired
                IF (v_ftci.s_fee_trigger_cat = cst_institutn OR
                    finp_val_fee_trigger(
                            gr_scaeh.FEE_CAT,
                                v_ftci.fee_cal_type,
                                v_ftci.fee_ci_sequence_number,
                                v_ftci.FEE_TYPE,
                            v_ftci.s_fee_trigger_cat,
                            p_effective_dt,
                            gr_scaeh.person_id,
                                gr_scaeh.course_cd,
                                gr_scaeh.version_number,
                                gr_scaeh.CAL_TYPE,
                                gr_scaeh.location_cd,
                                gr_scaeh.ATTENDANCE_MODE,
                                gr_scaeh.ATTENDANCE_TYPE,
                            v_trigger_fired) = TRUE) THEN
                    v_liability := TRUE;
                END IF;
            END IF;
            CLOSE c_scas;
        END IF;
        IF v_liability = TRUE THEN
            -- check if load is incurred for a IGS_PS_UNIT attempt within any of the
            -- liability charge method apportionments
            -- Find the liability charge method apportionments

            -- Enh # 2187247
            -- SFCR021 : FCI-LCI Relation
            -- Invoke the function FINP_GET_LFCI_RELN
            -- to derive the Load Calendar Instance of the passed Fee calendar instance

            IF IGS_FI_GEN_001.FINP_GET_LFCI_RELN(
                    v_ftci.fee_cal_type,
                    v_ftci.fee_ci_sequence_number,
                    'FEE',
                    v_ret_cal_type,
                    v_ret_ci_sequence_number,
                    v_message_name) = TRUE THEN

                -- get sua effective history data
                IGS_FI_GET_SUAEH.finp_get_suaeh(
                        p_person_id,
                        p_course_cd,
                        NULL, -- IGS_PS_UNIT cd
                        p_effective_dt,
                        gv_table_index,
                        gt_suaeh_table);
                IF gv_table_index > 0 THEN
                    FOR  v_index IN 1..gv_table_index
                    LOOP
                        r_suaeh := gt_suaeh_table(v_index);
                        -- check if the IGS_PS_UNIT status is fee assessible
                        OPEN c_suas (r_suaeh.unit_attempt_status);
                        FETCH c_suas INTO v_dummy;
                        IF (c_suas%FOUND) THEN
                            CLOSE c_suas;
                            -- Check if load is incured
                            -- Added parameter p_include_audit
                            IF IGS_EN_PRC_LOAD.enrp_get_load_apply(
                              p_teach_cal_type               => r_suaeh.CAL_TYPE,
                              p_teach_sequence_number        => r_suaeh.ci_sequence_number,
                              p_discontinued_dt              => r_suaeh.discontinued_dt,
                              p_administrative_unit_status   => r_suaeh.ADMINISTRATIVE_UNIT_STATUS,
                              p_unit_attempt_status          => r_suaeh.unit_attempt_status,
                              p_no_assessment_ind            => r_suaeh.no_assessment_ind,
                              p_load_cal_type                => v_ret_cal_type,
                              p_load_sequence_number         => v_ret_ci_sequence_number,
                              p_include_audit                => 'N') = 'Y' THEN
                              -- Set that load was found
                              v_load_found := TRUE;
                              EXIT;
                            END IF;
                        ELSE
                            CLOSE c_suas;
                        END IF;
                    END LOOP;
                    IF v_load_found THEN
                        EXIT;
                    END IF;
                END IF;
            ELSE        -- The FINP_GET_LFCI_RELN function returns FALSE
              p_message_name := v_message_name;
            END IF;     -- For the function FINP_GET_LFCI_RELN
            IF v_load_found THEN
                EXIT;
            END IF;
        END IF;
    END LOOP;
    IF NOT v_load_found THEN
        p_message_name := 'IGS_FI_STUD_PRG_ATTEMPT_NL';
    END IF;
    RETURN v_load_found;
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        IF c_ftci%ISOPEN THEN
            CLOSE c_ftci;
        END IF;
        IF c_scas%ISOPEN THEN
            CLOSE c_scas;
        END IF;
        IF c_suas%ISOPEN THEN
            CLOSE c_suas;
        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;
END;

 EXCEPTION
WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_FI_GEN_005.FINP_VAL_FEE_LBLTY');
        IGS_GE_MSG_STACK.ADD;
        lv_param_values := to_char(p_person_id)||','||
          p_course_cd||','||p_fee_cat||','||
          p_fee_type||','||
          fnd_date.date_to_displaydt(p_effective_dt);
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PARAMETERS');
         FND_MESSAGE.SET_TOKEN('VALUE',lv_param_values);
         IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END finp_val_fee_lblty;



--
FUNCTION finp_val_fee_trigger(
  p_fee_cat IN IGS_FI_F_CAT_CA_INST.FEE_CAT%TYPE ,
  p_fee_cal_type IN IGS_FI_F_CAT_CA_INST.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number IN IGS_FI_F_CAT_CA_INST.fee_ci_sequence_number%TYPE ,
  p_fee_type IN IGS_FI_F_CAT_FEE_LBL_ALL.FEE_TYPE%TYPE ,
  p_s_fee_trigger_cat IN IGS_FI_FEE_TYPE_ALL.s_fee_trigger_cat%TYPE ,
  p_effective_dt IN DATE ,
  p_person_id IN IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
  p_course_cd IN IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_version_number IN IGS_EN_STDNT_PS_ATT_ALL.version_number%TYPE ,
  p_cal_type IN IGS_EN_STDNT_PS_ATT_ALL.CAL_TYPE%TYPE ,
  p_location_cd IN IGS_EN_STDNT_PS_ATT_ALL.location_cd%TYPE ,
  p_attendance_mode IN IGS_EN_STDNT_PS_ATT_ALL.ATTENDANCE_MODE%TYPE ,
  p_attendance_type IN IGS_EN_STDNT_PS_ATT_ALL.ATTENDANCE_TYPE%TYPE ,
  p_trigger_fired OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
/***************************************************************************/
-- Change History:
-- Who         When            What
-- pathipat    14-Oct-2003     Enh 3117341 - Audit and Special Fees TD
--                             Modified cursor c_sua, added code for
--                             fee trigger type 'AUDIT'
/***************************************************************************/
    gv_table_index      BINARY_INTEGER;
        lv_param_values         VARCHAR2(1080);
BEGIN
    DECLARE
        CURSOR c_ft IS

            SELECT  ft.s_fee_trigger_cat
            FROM    IGS_FI_FEE_TYPE ft
            WHERE   ft.FEE_TYPE = p_fee_type;

        CURSOR c_ctft IS

            SELECT  ctft.COURSE_TYPE
            FROM    IGS_PS_TYPE_FEE_TRG ctft,
                IGS_PS_VER      cv
            WHERE   ctft.FEE_CAT = p_fee_cat AND
                ctft.fee_cal_type = p_fee_cal_type AND
                ctft.fee_ci_sequence_number = p_fee_ci_sequence_number AND
                ctft.FEE_TYPE = p_fee_type AND
                cv.course_cd = p_course_cd AND
                cv.version_number = p_version_number AND
                cv.COURSE_TYPE = ctft.COURSE_TYPE AND
                ctft.logical_delete_dt IS NULL;

        CURSOR c_cgft IS

            SELECT  cgft.course_group_cd
            FROM    IGS_PS_GRP_FEE_TRG  cgft,
                IGS_PS_GRP_MBR  cgm
            WHERE   cgft.FEE_CAT = p_fee_cat AND
                cgft.fee_cal_type = p_fee_cal_type AND
                cgft.fee_ci_sequence_number = p_fee_ci_sequence_number AND
                cgft.FEE_TYPE = p_fee_type AND
                cgm.course_cd = p_course_cd AND
                cgm.version_number = p_version_number AND
                cgm.course_group_cd = cgft.course_group_cd AND
                cgft.logical_delete_dt IS NULL;

        CURSOR c_cft IS

            SELECT  cft.fee_trigger_group_number
            FROM    IGS_PS_FEE_TRG      cft
            WHERE   cft.FEE_CAT = p_fee_cat AND
                cft.fee_cal_type = p_fee_cal_type AND
                cft.fee_ci_sequence_number = p_fee_ci_sequence_number AND
                cft.FEE_TYPE = p_fee_type AND
                cft.course_cd = p_course_cd AND
                (cft.version_number IS NULL OR
                cft.version_number = p_version_number) AND
                p_cal_type LIKE NVL(cft.CAL_TYPE, '%') AND
                p_location_cd LIKE NVL(cft.location_cd, '%') AND
                p_attendance_mode LIKE NVL(cft.ATTENDANCE_MODE, '%') AND
                p_attendance_type LIKE NVL(cft.ATTENDANCE_TYPE, '%') AND
                cft.logical_delete_dt IS NULL;

        CURSOR c_uft    IS

            SELECT  uft.unit_cd,
                uft.version_number,
                uft.CAL_TYPE,
                uft.ci_sequence_number,
                uft.location_cd,
                uft.UNIT_CLASS,
                uft.fee_trigger_group_number
            FROM    IGS_FI_UNIT_FEE_TRG     uft
            WHERE   uft.FEE_CAT = p_fee_cat AND
                uft.fee_cal_type = p_fee_cal_type AND
                uft.fee_ci_sequence_number = p_fee_ci_sequence_number AND
                uft.FEE_TYPE = p_fee_type AND
                uft.logical_delete_dt IS NULL;

        CURSOR c_sua    (cp_unit_cd IGS_EN_SU_ATTEMPT.unit_cd%TYPE,

                cp_version_number
                        IGS_EN_SU_ATTEMPT.version_number%TYPE,
                cp_cal_type IGS_EN_SU_ATTEMPT.CAL_TYPE%TYPE,
                cp_ci_sequence_number
                        IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE,
                cp_location_cd  IGS_EN_SU_ATTEMPT.location_cd%TYPE,
                cp_unit_class   IGS_EN_SU_ATTEMPT.UNIT_CLASS%TYPE,
                cp_v_audit_only  VARCHAR2) IS
            SELECT  'X'
            FROM    IGS_EN_SU_ATTEMPT   sua,
                IGS_LOOKUPS_view         suas
            WHERE   sua.person_id = p_person_id AND
                sua.course_cd = p_course_cd AND
                ( sua.unit_cd = cp_unit_cd OR cp_unit_cd IS NULL) AND
                (cp_version_number IS NULL OR
                sua.version_number = cp_version_number) AND
                (cp_cal_type IS NULL OR
                sua.CAL_TYPE = cp_cal_type) AND
                (cp_ci_sequence_number IS NULL OR
                sua.ci_sequence_number = cp_ci_sequence_number) AND
                (cp_location_cd IS NULL OR
                sua.location_cd = cp_location_cd) AND
                (cp_unit_class IS NULL OR
                sua.UNIT_CLASS = cp_unit_class) AND
                suas.lookup_code = sua.unit_attempt_status AND
                suas.lookup_type = g_v_sua_status AND
                suas.fee_ass_ind = g_v_yes AND
                ( ( sua.no_assessment_ind = g_v_yes AND
                     cp_v_audit_only = g_v_yes
                   )
                  OR cp_v_audit_only = g_v_no
                );

        CURSOR c_usft   IS

            SELECT  usft.unit_set_cd,
                usft.version_number,
                usft.fee_trigger_group_number
            FROM    IGS_EN_UNITSETFEETRG        usft
            WHERE   usft.FEE_CAT = p_fee_cat AND
                usft.fee_cal_type = p_fee_cal_type AND
                usft.fee_ci_sequence_number = p_fee_ci_sequence_number AND
                usft.FEE_TYPE = p_fee_type AND
                usft.logical_delete_dt IS NULL;

        CURSOR c_susa   (cp_unit_set_cd     IGS_AS_SU_SETATMPT.unit_set_cd%TYPE,
                cp_version_number   IGS_AS_SU_SETATMPT.us_version_number%TYPE) IS

            SELECT  'X'
            FROM    IGS_AS_SU_SETATMPT  susa
            WHERE   susa.person_id = p_person_id AND
                susa.course_cd = p_course_cd AND
                susa.unit_set_cd = cp_unit_set_cd AND
                susa.us_version_number = cp_version_number AND
                susa.student_confirmed_ind = g_v_yes AND
                (susa.selection_dt IS NOT NULL AND
                TRUNC(p_effective_dt) >= TRUNC(susa.selection_dt)) AND
                (susa.end_dt IS NULL OR
                TRUNC(p_effective_dt) <= TRUNC(susa.end_dt)) AND
                (susa.rqrmnts_complete_dt IS NULL OR
                TRUNC(p_effective_dt) <= TRUNC(susa.rqrmnts_complete_dt));
        v_s_fee_trigger_cat IGS_FI_FEE_TYPE.s_fee_trigger_cat%TYPE;
        v_check         VARCHAR2(1);

        -- Cursor to find out if the Student has atleast one auditable unit
        CURSOR c_sua_audit_one (cp_person_id NUMBER,
                                cp_course_cd VARCHAR2) IS
          SELECT 'X'
          FROM igs_en_su_attempt sua,
               igs_lookups_view suas
          WHERE sua.person_id = p_person_id
          AND   sua.course_cd = p_course_cd
          AND   suas.lookup_type = g_v_sua_status
          AND   suas.lookup_code = sua.unit_attempt_status
          AND   suas.fee_ass_ind = g_v_yes
          AND   sua.no_assessment_ind = g_v_yes;

          l_b_fee_trigger_found      BOOLEAN := FALSE;

    FUNCTION finpl_val_trig_group (p_fee_trigger_group_number
                IGS_FI_FEE_TRG_GRP.fee_trigger_group_number%TYPE)
    RETURN BOOLEAN AS
    BEGIN
        -- validate the fee trigger group members match the student
    DECLARE
        CURSOR	c_ftgv_course   IS
                SELECT  lkp.lookup_code trigger_type_code,
                        cft.course_cd code,
                        cft.version_number
                FROM    IGS_PS_FEE_TRG  cft,
                        IGS_PS_VER  crv,
                        IGS_LOOKUP_VALUES lkp
                WHERE   cft.FEE_CAT = p_fee_cat AND
                        cft.fee_cal_type = p_fee_cal_type AND
                        cft.fee_ci_sequence_number = p_fee_ci_sequence_number AND
                        cft.FEE_TYPE = p_fee_type AND
                        cft.fee_trigger_group_number = p_fee_trigger_group_number AND
                        lkp.lookup_type = 'IGS_FI_TRIGGER_GROUP' AND
                        lkp.lookup_code = 'COURSE' AND
                        cft.fee_trigger_group_number IS NOT NULL AND
                        cft.logical_delete_dt IS NULL AND
                        cft.course_cd = crv.course_cd AND
                        (cft.version_number = crv.version_number OR
                        (cft.version_number IS NULL AND
                        crv.version_number = (  SELECT  MAX(crv2.version_number)
                                                FROM    IGS_PS_VER crv2
                                                WHERE   crv2.course_cd = crv.course_cd)));
        CURSOR c_ftgv_unit   IS
                SELECT  lkp.lookup_code trigger_type_code,
                        uft.unit_cd code,
                        uft.version_number
                FROM    IGS_FI_UNIT_FEE_TRG     uft,
                        IGS_PS_UNIT_VER         uv,
                        IGS_LOOKUP_VALUES       lkp
                WHERE   uft.FEE_CAT = p_fee_cat AND
                        uft.fee_cal_type = p_fee_cal_type AND
                        uft.fee_ci_sequence_number = p_fee_ci_sequence_number AND
                        uft.FEE_TYPE = p_fee_type AND
                        uft.fee_trigger_group_number = p_fee_trigger_group_number AND
                        lkp.lookup_type = 'IGS_FI_TRIGGER_GROUP' AND
                        lkp.lookup_code = 'UNIT' AND
                        uft.fee_trigger_group_number IS NOT NULL AND
                        uft.logical_delete_dt IS NULL AND
                        uft.unit_cd = uv.unit_cd AND
                        (uft.version_number = uv.version_number OR
                        (uft.version_number IS NULL AND
                        uv.version_number = (   SELECT  MAX(uv2.version_number)
                                                FROM    IGS_PS_UNIT_VER uv2
                                                WHERE   uv2.unit_cd = uv.unit_cd)));
        CURSOR c_ftgv_unitset   IS
                SELECT  usft.unit_set_cd code,   usft.version_number,
                        lkp.lookup_code trigger_type_code
                FROM    IGS_EN_UNITSETFEETRG    usft,
                        IGS_EN_UNIT_SET         us,
                        IGS_LOOKUP_VALUES       lkp
                WHERE   usft.FEE_CAT = p_fee_cat AND
                        usft.fee_cal_type = p_fee_cal_type AND
                        usft.fee_ci_sequence_number = p_fee_ci_sequence_number AND
                        usft.FEE_TYPE = p_fee_type AND
                        usft.fee_trigger_group_number = p_fee_trigger_group_number AND
                        lkp.lookup_type = 'IGS_FI_TRIGGER_GROUP' AND
                        lkp.lookup_code = 'UNITSET' AND
                        usft.fee_trigger_group_number IS NOT NULL AND
                        usft.logical_delete_dt IS NULL AND
                        usft.unit_set_cd = us.unit_set_cd AND
                        usft.version_number = us.version_number;
        CURSOR c_ftg_uft    (
                    cp_unit_cd  IGS_EN_SU_ATTEMPT.unit_cd%TYPE,
                    cp_version_number
                            IGS_EN_SU_ATTEMPT.version_number%TYPE)IS
            SELECT  uft.unit_cd,
                uft.version_number,
                uft.CAL_TYPE,
                uft.ci_sequence_number,
                uft.location_cd,
                uft.UNIT_CLASS,
                uft.fee_trigger_group_number
            FROM    IGS_FI_UNIT_FEE_TRG     uft
            WHERE   uft.FEE_CAT = p_fee_cat AND
                uft.fee_cal_type = p_fee_cal_type AND
                uft.fee_ci_sequence_number = p_fee_ci_sequence_number AND
                uft.FEE_TYPE = p_fee_type AND
                uft.unit_cd = cp_unit_cd AND
                (uft.version_number IS NULL OR
                uft.version_number = cp_version_number) AND
                uft.logical_delete_dt IS NULL;
        CURSOR c_ftg_usft   (
                    cp_unit_set_cd
                        IGS_AS_SU_SETATMPT.unit_set_cd%TYPE,
                    cp_version_number
                        IGS_AS_SU_SETATMPT.us_version_number%TYPE) IS
            SELECT  usft.unit_set_cd,
                usft.version_number,
                usft.fee_trigger_group_number
            FROM    IGS_EN_UNITSETFEETRG        usft
            WHERE   usft.FEE_CAT = p_fee_cat AND
                usft.fee_cal_type = p_fee_cal_type AND
                usft.fee_ci_sequence_number = p_fee_ci_sequence_number AND
                usft.FEE_TYPE = p_fee_type AND
                usft.unit_set_cd = cp_unit_set_cd AND
                usft.version_number = cp_version_number AND
                usft.logical_delete_dt IS NULL;
        v_trigger_group_fired   BOOLEAN;
    BEGIN
        -- check the fee trigger group members
        v_trigger_group_fired := TRUE;
        FOR v_ftgv_rec IN c_ftgv_course LOOP
                -- check for matching student IGS_PS_COURSE attempt
                IF (v_ftgv_rec.code <> p_course_cd OR
                    NVL(v_ftgv_rec.version_number, p_version_number) <>
                                p_version_number) THEN
                    v_trigger_group_fired := FALSE;
                    RETURN v_trigger_group_fired;
                END IF;
        END LOOP;
        FOR v_ftgv_rec IN c_ftgv_unit LOOP
                FOR v_ftg_uft_rec IN c_ftg_uft  ( v_ftgv_rec.code,
                                                        v_ftgv_rec.version_number) LOOP
                        -- check for matching student IGS_PS_UNIT attempt
                        OPEN c_sua (    v_ftg_uft_rec.unit_cd,
                                v_ftg_uft_rec.version_number,
                                v_ftg_uft_rec.CAL_TYPE,
                                v_ftg_uft_rec.ci_sequence_number,
                                v_ftg_uft_rec.location_cd,
                                v_ftg_uft_rec.UNIT_CLASS,
                                'N');
                        FETCH c_sua INTO v_check;
                        IF (c_sua%NOTFOUND) THEN
                            CLOSE c_sua;
                            v_trigger_group_fired := FALSE;
                            RETURN v_trigger_group_fired;
                        END IF;
                        CLOSE c_sua;
                END LOOP;
        END LOOP;
        FOR v_ftgv_rec IN c_ftgv_unitset LOOP
                FOR v_ftg_usft_rec IN c_ftg_usft ( v_ftgv_rec.code,
                                                        v_ftgv_rec.version_number) LOOP
                        -- check for matching student IGS_PS_UNIT set attempt
                        OPEN c_susa (   v_ftg_usft_rec.unit_set_cd,
                                        v_ftg_usft_rec.version_number);
                        FETCH c_susa INTO v_check;
                        IF (c_susa%NOTFOUND) THEN
                                CLOSE c_susa;
                        v_trigger_group_fired := FALSE;
                        RETURN v_trigger_group_fired;
                        END IF;
                        CLOSE c_susa;
                END LOOP;
        END LOOP;
        RETURN v_trigger_group_fired;
    END;
    END finpl_val_trig_group;
--------------------------------------------------------------------------------
    -- Begin for finp_val_fee_trigger
    BEGIN
        -- This routine checks the students enrolment details to test
        -- for matching a fee trigger.
        -- Check if enrolment history is being used

        IF p_s_fee_trigger_cat IS NULL THEN
            OPEN    c_ft;
            FETCH   c_ft    INTO    v_s_fee_trigger_cat;
            CLOSE   c_ft;
        ELSE
            v_s_fee_trigger_cat := p_s_fee_trigger_cat;
        END IF;
        IF (v_s_fee_trigger_cat = 'INSTITUTN') THEN
            -- IGS_GE_NOTE, IGS_OR_INSTITUTION fees have no triggers - they always apply.
            -- Trigger Fired
            p_trigger_fired := 'INSTITUTN';
            RETURN TRUE;
        ELSIF (v_s_fee_trigger_cat = 'COURSE') THEN
            FOR v_ctft_rec IN c_ctft LOOP
                -- Trigger Fired
                p_trigger_fired := 'CTFT';
                RETURN TRUE;
            END LOOP;
            FOR v_cgft_rec IN c_cgft LOOP
                -- Trigger Fired
                p_trigger_fired := 'CGFT';
                RETURN TRUE;
            END LOOP;
            FOR v_cft_rec IN c_cft LOOP
                -- Trigger Fired
                p_trigger_fired := 'CFT';
                RETURN TRUE;
            END LOOP;
        ELSIF (v_s_fee_trigger_cat = 'UNIT') THEN
            FOR v_uft_rec IN c_uft
            LOOP
                    OPEN c_sua (    v_uft_rec.unit_cd,
                            v_uft_rec.version_number,
                            v_uft_rec.CAL_TYPE,
                            v_uft_rec.ci_sequence_number,
                            v_uft_rec.location_cd,
                            v_uft_rec.UNIT_CLASS,
                            g_v_no);
                    FETCH c_sua INTO v_check;
                    IF (c_sua%FOUND) THEN
                        CLOSE c_sua;
                        -- Trigger Fired
                        p_trigger_fired := 'UFT';
                        RETURN TRUE;
                    END IF;
                    CLOSE c_sua;

            END LOOP;
        ELSIF (v_s_fee_trigger_cat = 'UNITSET') THEN
            FOR v_usft_rec IN c_usft
            LOOP
                OPEN c_susa (   v_usft_rec.unit_set_cd,
                        v_usft_rec.version_number);
                FETCH c_susa INTO v_check;
                IF (c_susa%FOUND) THEN
                    CLOSE c_susa;
                    -- Trigger Fired
                    p_trigger_fired := 'USFT';
                    RETURN TRUE;
                END IF;
                CLOSE c_susa;
            END LOOP;
        ELSIF (v_s_fee_trigger_cat = 'COMPOSITE') THEN
            -- check IGS_PS_COURSE fee triggers
            FOR v_cft_rec IN c_cft
            LOOP
                IF (v_cft_rec.fee_trigger_group_number IS NULL) THEN
                    -- Trigger Fired
                    p_trigger_fired := 'CFT';
                    RETURN TRUE;
                ELSE
                    -- check the fee trigger group members
                    IF (finpl_val_trig_group(v_cft_rec.fee_trigger_group_number) = TRUE) THEN
                        -- Trigger Fired
                        p_trigger_fired := 'COMPOSITE';
                        RETURN TRUE;
                    END IF;
                END IF;
            END LOOP;
            -- check IGS_PS_UNIT fee triggers
            FOR v_uft_rec IN c_uft
            LOOP
                IF (v_uft_rec.fee_trigger_group_number IS NOT NULL) THEN
                    -- check the fee trigger group members
                    IF (finpl_val_trig_group(v_uft_rec.fee_trigger_group_number) = TRUE) THEN
                        -- Trigger Fired
                        p_trigger_fired := 'COMPOSITE';
                        RETURN TRUE;
                    END IF;
                ELSE
                        OPEN c_sua  (v_uft_rec.unit_cd,
                                v_uft_rec.version_number,
                                v_uft_rec.CAL_TYPE,
                                v_uft_rec.ci_sequence_number,
                                v_uft_rec.location_cd,
                                v_uft_rec.UNIT_CLASS,
                                g_v_no);
                        FETCH c_sua INTO v_check;
                        IF (c_sua%FOUND) THEN
                            CLOSE c_sua;
                            -- Trigger Fired
                            p_trigger_fired := 'UFT';
                            RETURN TRUE;
                        END IF;
                        CLOSE c_sua;

                END IF;
            END LOOP;
            -- check IGS_PS_UNIT set fee triggers
            FOR v_usft_rec IN c_usft
            LOOP
                IF (v_usft_rec.fee_trigger_group_number IS NOT NULL) THEN
                    -- check the fee trigger group members
                    IF (finpl_val_trig_group(v_usft_rec.fee_trigger_group_number) = TRUE) THEN
                        -- Trigger Fired
                        p_trigger_fired := 'COMPOSITE';
                        RETURN TRUE;
                    END IF;
                ELSE
                    OPEN c_susa (   v_usft_rec.unit_set_cd,
                            v_usft_rec.version_number);
                    FETCH c_susa INTO v_check;
                    IF (c_susa%FOUND) THEN
                        CLOSE c_susa;
                        -- Trigger Fired
                        p_trigger_fired := 'USFT';
                        RETURN TRUE;
                    END IF;
                    CLOSE c_susa;
                END IF;
            END LOOP;

        -- For System Fee Trigger type of Audit
        ELSIF (v_s_fee_trigger_cat = 'AUDIT') THEN
            l_b_fee_trigger_found := FALSE;
            -- Check if any unit fee triggers have been defined
            FOR v_uft_rec IN c_uft LOOP
               -- Set flag if trigger is found
               l_b_fee_trigger_found := TRUE;

                    -- Check if any of the triggers found are for auditable units
                    -- (auditable indicator to be 'Y')
                    OPEN c_sua (v_uft_rec.unit_cd,
                                v_uft_rec.version_number,
                                v_uft_rec.cal_type,
                                v_uft_rec.ci_sequence_number,
                                v_uft_rec.location_cd,
                                v_uft_rec.unit_class,
                                g_v_yes);
                    FETCH c_sua INTO v_check;
                    IF (c_sua%FOUND) THEN
                        CLOSE c_sua;
                        -- Trigger Fired
                        p_trigger_fired := 'AUDIT';
                        RETURN TRUE;
                    END IF;
                    CLOSE c_sua;
            END LOOP;

            -- If triggers were found, but none were auditable, return False
            IF l_b_fee_trigger_found THEN
               p_trigger_fired := NULL;
               RETURN FALSE;
            END IF;

            -- If Unit Triggers are not found or there is no auditable unit trigger, then
            -- check if student has any auditable unit attempts effective as on
            -- the effective date

                OPEN c_sua_audit_one(p_person_id, p_course_cd);
                FETCH c_sua_audit_one INTO v_check;
                IF c_sua_audit_one%FOUND THEN
                   CLOSE c_sua_audit_one;
                   p_trigger_fired := 'AUDIT';
                   RETURN TRUE;
                END IF;
                CLOSE c_sua_audit_one;
        END IF;

        -- Trigger did not fire
        p_trigger_fired := NULL;
        RETURN FALSE;

    END;

  EXCEPTION
WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_FI_GEN_005.FINP_VAL_FEE_TRIGGER');
        IGS_GE_MSG_STACK.ADD;
        lv_param_values := p_fee_cat||','||
          p_fee_cal_type||','||to_char(p_fee_ci_sequence_number)||','||
          p_fee_type||','||p_s_fee_trigger_cat||','||
          fnd_date.date_to_displaydt(p_effective_dt)||','||
          to_char(p_person_id)||','||
          p_course_cd||','||to_char(p_version_number)||','||
          p_cal_type||','||p_location_cd||','||
          p_attendance_mode||','||p_attendance_type;

         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PARAMETERS');
         FND_MESSAGE.SET_TOKEN('VALUE',lv_param_values);
         IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;

END finp_val_fee_trigger;

--
FUNCTION fins_val_fee_trigger(
  p_fee_cat  IGS_FI_F_CAT_CA_INST.FEE_CAT%TYPE ,
  p_fee_cal_type  IGS_FI_F_CAT_CA_INST.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number  IGS_FI_F_CAT_CA_INST.fee_ci_sequence_number%TYPE ,
  p_fee_type  IGS_FI_F_CAT_FEE_LBL_ALL.FEE_TYPE%TYPE ,
  p_s_fee_trigger_cat  IGS_FI_FEE_TYPE_ALL.s_fee_trigger_cat%TYPE ,
  p_effective_dt  DATE ,
  p_person_id  IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
  p_course_cd  IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_version_number  IGS_EN_STDNT_PS_ATT_ALL.version_number%TYPE ,
  p_cal_type  IGS_EN_STDNT_PS_ATT_ALL.CAL_TYPE%TYPE ,
  p_location_cd  IGS_EN_STDNT_PS_ATT_ALL.location_cd%TYPE ,
  p_attendance_mode  IGS_EN_STDNT_PS_ATT_ALL.ATTENDANCE_MODE%TYPE ,
  p_attendance_type  IGS_EN_STDNT_PS_ATT_ALL.ATTENDANCE_TYPE%TYPE )
RETURN CHAR AS
BEGIN
    DECLARE
    v_trigger_fired     igs_lookups_view.lookup_code%TYPE;
    BEGIN
        IF finp_val_fee_trigger(p_fee_cat,
                p_fee_cal_type,
                p_fee_ci_sequence_number,
                p_fee_type,
                p_s_fee_trigger_cat,
                p_effective_dt,
                p_person_id,
                p_course_cd,
                p_version_number,
                p_cal_type,
                p_location_cd,
                p_attendance_mode,
                p_attendance_type,
                v_trigger_fired) = TRUE THEN
            RETURN 'Y';
        ELSE
            RETURN 'N';
        END IF;
    END;
END fins_val_fee_trigger;
--
--
PROCEDURE finp_set_pymnt_schdl(
  errbuf  out NOCOPY  varchar2,
  retcode out NOCOPY  number,
  P_FEE_ASSESSMENT_PERIOD IN VARCHAR2,
  p_person_id IN            IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
  p_fee_category IN            IGS_EN_STDNT_PS_ATT_ALL.fee_cat%TYPE ,
  p_grace_days IN NUMBER ,
  p_effective_dt_c IN VARCHAR2 ,
  p_notification_dt_c IN VARCHAR2 ,
  p_include_man_entries IN VARCHAR2 ,
  p_next_bus_day IN VARCHAR2 ,
  p_org_id NUMBER
) AS
BEGIN   -- finp_set_pymnt_schdl
-- As per the SFCR005, this concurrent program has been obsoleted
-- If the User is trying to run this concurrent program, then the error message
-- should be written to the log file that the concurrent program has been obsoleted
-- and cannot be run
    retcode:=0;
        FND_MESSAGE.Set_Name('IGS',
                             'IGS_GE_OBSOLETE_JOB');
        FND_FILE.Put_Line(FND_FILE.Log,
                          FND_MESSAGE.Get);
EXCEPTION
WHEN OTHERS THEN
    RETCODE:=2;
    ERRBUF:=FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END finp_set_pymnt_schdl;

  FUNCTION finp_get_receivables_inst RETURN IGS_FI_CONTROL.Rec_Installed%TYPE AS
  ------------------------------------------------------------------
  --
  --Change History:
  --Who         When            What
  --smadathi    27-Feb-2002     Bug 2238413. Exception will be raised if
  --                            no record has been found in igs_fi_control table
  -------------------------------------------------------------------
    lv_rec_installed           IGS_FI_CONTROL.Rec_Installed%TYPE;

-- Cursor fro getting the value of the Rec_Installed flag
-- in the table IGS_FI_CONTROL
    CURSOR cur_ctrl IS
      SELECT rec_installed
      FROM   igs_fi_control;
  BEGIN

-- Open the cursor and fetch the value of the REC_INSTALLED flag
    OPEN cur_ctrl;
    FETCH cur_ctrl INTO lv_rec_installed;
    -- If no records are found in IGS_FI_CONTROL table
    -- exception is raised.
    IF cur_ctrl%NOTFOUND THEN
      CLOSE cur_ctrl;
      FND_MESSAGE.SET_NAME('IGS','IGS_FI_SYSTEM_OPT_SETUP');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE cur_ctrl;

-- If the records are not found, then this means that a Receivables system is not
-- installed
-- if the value of lv_rec_installed is
-- N :  No receivables system is installed
-- Y :  Oracle Accounts Receivables is installed
    lv_rec_installed := NVL(lv_rec_installed,'N');
    RETURN lv_rec_installed;
  END finp_get_receivables_inst;

  FUNCTION finp_get_acct_meth RETURN igs_fi_control.accounting_method%TYPE AS
  /*||  Created By :Sarakshi
    ||  Created On :02-Feb-2002
    ||  Purpose : For returning the accounting method.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  pathipat        18-Apr-2003     Enh:2831569 - Commercial Receivables build
    ||                                  Added code for manage_accounts.
    ||  (reverse chronological order - newest change first) */

    CURSOR cur_acc IS
    SELECT manage_accounts,accounting_method
    FROM   igs_fi_control;

    l_accounting_method  igs_fi_control.accounting_method%TYPE;
    l_v_manage_accounts  igs_fi_control_all.manage_accounts%TYPE;

  BEGIN
    OPEN cur_acc;
    FETCH cur_acc INTO l_v_manage_accounts, l_accounting_method;
    IF cur_acc%FOUND THEN
      CLOSE cur_acc;
      -- If manage_accounts = Other, then return Accrual as the
      -- accounting method for internal processing.
      IF l_v_manage_accounts = 'OTHER' THEN
         l_accounting_method := 'ACCRUAL';
      END IF;
      RETURN l_accounting_method;
    ELSE
      CLOSE cur_acc;
      RETURN NULL;
    END IF;
  END finp_get_acct_meth;

  FUNCTION finp_get_prsid_grp_code(p_n_group_id igs_pe_persid_group.group_id%TYPE)
  RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 03 jan 2003
  --
  --Purpose: This generic function returns group code for the person group id
  --         passed as parameter
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ------------------------------------------------------------------

  CURSOR c_igs_pe_prsid_group (cp_n_group_id igs_pe_persid_group.group_id%TYPE) IS
  SELECT group_cd
  FROM   igs_pe_persid_group
  WHERE  group_id = cp_n_group_id;

  l_c_group_cd igs_pe_persid_group.group_cd%TYPE := NULL;

  BEGIN

    -- if person group id passed is NULL, the function returns null value
    -- if person group id passed is invalid, the function returns group id value itself
    -- if person group id passed is valid, the function returns group code
    IF p_n_group_id IS NULL THEN
      RETURN NULL;
    ELSE
      OPEN  c_igs_pe_prsid_group(cp_n_group_id => p_n_group_id);
      FETCH c_igs_pe_prsid_group INTO l_c_group_cd;
      IF c_igs_pe_prsid_group%NOTFOUND
      THEN
        CLOSE  c_igs_pe_prsid_group;
        RETURN p_n_group_id;
      END IF;
      CLOSE  c_igs_pe_prsid_group;
      RETURN l_c_group_cd;
    END IF;
  END finp_get_prsid_grp_code;


END igs_fi_gen_005;

/
