--------------------------------------------------------
--  DDL for Package Body IGS_CO_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_GEN_002" AS
/* $Header: IGSCO02B.pls 120.1 2006/01/06 04:10:11 gmaheswa noship $ */

/*
 Change History
   Who          When            What
   pkpatel      24-APR-2003     Bug 2908844
                                Stubbed the procedure corp_ins_spl_detail since its no longer used.
   gmaheswa	5-Jan-2004	Bug 4869737 Added a call to SET_ORG_ID in CORP_UPD_OC_DT_SENT to disable OSS for R12.
*/

FUNCTION corp_del_cori_spl(
  p_correspondence_type IN VARCHAR2 ,
  p_reference_number IN NUMBER ,
  p_letter_delete IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY varchar2 )
RETURN BOOLEAN AS
        e_resource_busy         EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_resource_busy, -54);
        lv_param_values         VARCHAR2(1080);
BEGIN   -- corp_del_cori_spl
        -- This module deletes all records related to a correspondence item.
        -- It also deletes any system IGS_PE_PERSON letter details related to the
        -- correspondence item.
        -- If any records are locked then we rollback and return false.
DECLARE
        cst_spl_seqnum          CONSTANT VARCHAR2(10) := 'SPL_SEQNUM';
        v_spl_sequence_number   NUMBER(10);
        v_dummy                 VARCHAR2(1);
        v_sys_generated_ind     IGS_CO_TYPE.sys_generated_ind%TYPE;
        CURSOR  c_corit(
                        cp_correspondence_type IGS_CO_ITM.CORRESPONDENCE_TYPE%TYPE,
                        cp_reference_number IGS_CO_ITM.reference_number%TYPE) IS
        SELECT  cort.sys_generated_ind
        FROM    IGS_CO_ITM      cori,
                IGS_CO_TYPE cort
        WHERE   cori.CORRESPONDENCE_TYPE        = cp_correspondence_type
        AND     cori.reference_number           = cp_reference_number
        AND     cort.CORRESPONDENCE_TYPE        = cori.CORRESPONDENCE_TYPE;
        CURSOR  c_sl(
                        cp_correspondence_type IGS_CO_ITM.CORRESPONDENCE_TYPE%TYPE) IS
        SELECT  'x'
        FROM    IGS_CO_S_LTR sl
        WHERE   sl.CORRESPONDENCE_TYPE  = cp_correspondence_type;
        CURSOR  c_cdo(
                        cp_correspondence_type IGS_CO_DTL_OLE.CORRESPONDENCE_TYPE%TYPE,
                        cp_reference_number IGS_CO_DTL_OLE.reference_number%TYPE) IS
        SELECT  ROWID
        FROM    IGS_CO_DTL_OLE cdo
        WHERE   cdo.CORRESPONDENCE_TYPE         = cp_correspondence_type
        AND     cdo.reference_number            = cp_reference_number
        FOR UPDATE OF cdo.CORRESPONDENCE_TYPE NOWAIT;
        CURSOR  c_cd(
                        cp_correspondence_type IGS_CO_DTL.CORRESPONDENCE_TYPE%TYPE,
                        cp_reference_number IGS_CO_DTL.reference_number%TYPE) IS
        SELECT  ROWID
        FROM    IGS_CO_DTL cd
        WHERE   cd.CORRESPONDENCE_TYPE          = cp_correspondence_type
        AND     cd.reference_number             = cp_reference_number
        FOR UPDATE OF cd.CORRESPONDENCE_TYPE NOWAIT;
        CURSOR  c_ocr(
                        cp_correspondence_type IGS_CO_OU_CO_REF.CORRESPONDENCE_TYPE%TYPE,
                        cp_reference_number IGS_CO_OU_CO_REF.reference_number%TYPE) IS
        SELECT  ocr.rowid,
                        ocr.other_reference,
                        ocr.person_id
        FROM    IGS_CO_OU_CO_REF ocr
        WHERE   ocr.CORRESPONDENCE_TYPE         = cp_correspondence_type
        AND     ocr.reference_number            = cp_reference_number
        AND     ocr.S_OTHER_REFERENCE_TYPE      = cst_spl_seqnum
        FOR UPDATE OF ocr.other_reference NOWAIT;
        CURSOR  c_spl(
                        cp_sequence_number IGS_CO_S_PER_LTR.sequence_number%TYPE,
                        cp_person_id IGS_CO_S_PER_LTR.person_id%TYPE) IS
        SELECT ROWID
        FROM    IGS_CO_S_PER_LTR spl
        WHERE   spl.sequence_number             = cp_sequence_number
        AND     spl.person_id                   = cp_person_id
        FOR UPDATE OF spl.sequence_number NOWAIT;
        CURSOR  c_splp(
                        cp_sequence_number IGS_CO_S_PER_LT_PARM.sequence_number%TYPE,
                        cp_person_id IGS_CO_S_PER_LT_PARM.person_id%TYPE) IS
        SELECT  ROWID
        FROM    IGS_CO_S_PER_LT_PARM splp
        WHERE   splp.spl_sequence_number        = cp_sequence_number
        AND     splp.person_id                  = cp_person_id
        FOR UPDATE OF splp.spl_sequence_number NOWAIT;
        CURSOR  c_splrg(
                        cp_sequence_number IGS_CO_S_PERLT_RPTGP.sequence_number%TYPE,
                        cp_person_id IGS_CO_S_PERLT_RPTGP.person_id%TYPE) IS
        SELECT  ROWID
        FROM    IGS_CO_S_PERLT_RPTGP splrg
        WHERE   splrg.spl_sequence_number       = cp_sequence_number
        AND     splrg.person_id                 = cp_person_id
        ORDER BY splrg.sequence_number DESC, splrg.sup_repeating_group_cd
        FOR UPDATE OF splrg.spl_sequence_number NOWAIT;
        CURSOR  c_aal(
                        cp_sequence_number IGS_AD_APPL_LTR.spl_sequence_number%TYPE,
                        cp_person_id IGS_AD_APPL_LTR.person_id%TYPE) IS
        SELECT  ROWID,
                        PERSON_ID,
                        ADMISSION_APPL_NUMBER,
                        CORRESPONDENCE_TYPE,
                        SEQUENCE_NUMBER,
                        COMPOSED_IND,
                        LETTER_REFERENCE_NUMBER,
                        SPL_SEQUENCE_NUMBER
        FROM    IGS_AD_APPL_LTR aal
        WHERE   aal.spl_sequence_number         = cp_sequence_number
        AND     aal.person_id                   = cp_person_id
        FOR UPDATE OF   aal.letter_reference_number, aal.spl_sequence_number NOWAIT;
        CURSOR  c_ocr_1(
                        cp_correspondence_type IGS_CO_OU_CO_REF.CORRESPONDENCE_TYPE%TYPE,
                        cp_reference_number IGS_CO_OU_CO_REF.reference_number%TYPE) IS
        SELECT  ROWID
        FROM    IGS_CO_OU_CO_REF ocr
        WHERE   ocr.CORRESPONDENCE_TYPE         = cp_correspondence_type
        AND     ocr.reference_number            = cp_reference_number
        FOR UPDATE OF ocr.CORRESPONDENCE_TYPE NOWAIT;
        CURSOR  c_oc(
                        cp_correspondence_type IGS_CO_OU_CO.CORRESPONDENCE_TYPE%TYPE,
                        cp_reference_number IGS_CO_OU_CO.reference_number%TYPE) IS
        SELECT  ROWID
        FROM    IGS_CO_OU_CO oc
        WHERE   oc.CORRESPONDENCE_TYPE          = cp_correspondence_type
        AND     oc.reference_number             = cp_reference_number
        FOR UPDATE OF oc.CORRESPONDENCE_TYPE NOWAIT;
        CURSOR  c_cit(
                        cp_correspondence_type IGS_CO_ITM.CORRESPONDENCE_TYPE%TYPE,
                        cp_reference_number IGS_CO_ITM.reference_number%TYPE) IS
        SELECT  ROWID
        FROM    IGS_CO_ITM cit
        WHERE   cit.CORRESPONDENCE_TYPE         = cp_correspondence_type
        AND     cit.reference_number            = cp_reference_number
        FOR UPDATE OF cit.CORRESPONDENCE_TYPE NOWAIT;

BEGIN
        COMMIT;
        SAVEPOINT       sp_before_delete;
        p_message_name := Null;
        OPEN    c_corit(
                        p_correspondence_type,
                        p_reference_number);
        FETCH   c_corit INTO v_sys_generated_ind;
        IF(c_corit%NOTFOUND) THEN
                CLOSE c_corit;
                ROLLBACK TO sp_before_delete;
                p_message_name := 'IGS_CO_CORITEM_DOESNOT_EXIST';
                RETURN FALSE;
        END IF;
        CLOSE c_corit;
        -- If this is for the deletion of a letter check it is system generated and
        -- there is a letter with this correspondence type.
        IF(p_letter_delete = 'Y') THEN
                IF(v_sys_generated_ind = 'N') THEN
                        ROLLBACK TO sp_before_delete;
                        p_message_name := 'IGS_CO_CORTYPE_ISNOT_SYSGEN';
                        RETURN FALSE;
                END IF;
                OPEN    c_sl(
                                p_correspondence_type);
                FETCH   c_sl INTO v_dummy;
                IF(c_sl%NOTFOUND) THEN
                        CLOSE c_sl;
                        ROLLBACK TO sp_before_delete;
                        p_message_name := 'IGS_AD_DFLT_FEECAT_MAPPING';
                        RETURN FALSE;
                END IF;
                CLOSE c_sl;
        END IF;
        -- delete any IGS_CO_DTL_OLE records for this correspondence item
        FOR v_cdo_rec IN c_cdo(
                                p_correspondence_type,
                                p_reference_number) LOOP
                IGS_CO_DTL_OLE_PKG.DELETE_ROW(X_ROWID=>v_cdo_rec.ROWID);
        END LOOP;
        -- delete any IGS_CO_DTL records for this IGS_CO_ITM
        FOR vcd_rec IN  c_cd(
                                p_correspondence_type,
                                p_reference_number) LOOP
                IGS_CO_DTL_PKG.DELETE_ROW(X_ROWID=>vcd_rec.ROWID);
        END LOOP;
        IF(p_letter_delete = 'Y') THEN
                -- find related IGS_CO_S_PER_LTR records from IGS_CO_OU_CO_REF
                FOR v_ocr_rec IN c_ocr(
                                        p_correspondence_type,
                                        p_reference_number) LOOP
                        v_spl_sequence_number := TO_NUMBER(v_ocr_rec.other_reference);
                        FOR v_spl_rec IN c_spl(
                                                v_spl_sequence_number,
                                                v_ocr_rec.person_id) LOOP
                                -- delete any parameters for this letter
                                FOR v_splp_rec IN c_splp(
                                                        v_spl_sequence_number,
                                                        v_ocr_rec.person_id) LOOP
                                        IGS_CO_S_PER_LT_PARM_PKG.DELETE_ROW(X_ROWID=>v_splp_rec.ROWID);
                                END LOOP;
                                -- delete the repeating groups.  Must delete in the correct order as
                                -- table can contain parent/child relationship
                                FOR v_splrg_rec IN c_splrg(
                                                        v_spl_sequence_number,
                                                        v_ocr_rec.person_id) LOOP
                                        IGS_CO_S_PERLT_RPTGP_PKG.DELETE_ROW(X_ROWID=>v_splrg_rec.ROWID);
                                END LOOP;
                                -- remove the reference to the IGS_CO_S_PER_LTR sequence number
                                -- from the IGS_AD_APPL_LTR record
                                FOR v_aal_rec IN c_aal(
                                                        v_spl_sequence_number,
                                                        v_ocr_rec.person_id) LOOP
                                        IGS_AD_APPL_LTR_PKG.UPDATE_ROW(
                                                        X_ROWID => v_aal_rec.ROWID,
                                                        X_PERSON_ID => v_aal_rec.PERSON_ID,
                                                        X_ADMISSION_APPL_NUMBER =>v_aal_rec.ADMISSION_APPL_NUMBER ,
                                                        X_CORRESPONDENCE_TYPE =>v_aal_rec.CORRESPONDENCE_TYPE,
                                                        X_SEQUENCE_NUMBER =>v_aal_rec.SEQUENCE_NUMBER,
                                                        X_COMPOSED_IND =>v_aal_rec.COMPOSED_IND,
                                                        X_LETTER_REFERENCE_NUMBER =>NULL,
                                                        X_SPL_SEQUENCE_NUMBER =>NULL,
                                                        X_MODE => 'R'
                                                        );
                                END LOOP;
                                -- delete the IGS_CO_S_PER_LTR record
                                IGS_CO_S_PER_LTR_PKG.DELETE_ROW(X_ROWID => v_spl_rec.rowid);
                        END LOOP;
                        -- delete current IGS_CO_OU_CO_REF record
                        IGS_CO_OU_CO_REF_PKG.DELETE_ROW(X_ROWID => v_ocr_rec.ROWID );
                END LOOP;
        ELSE -- p_letter_delete = 'N'
                -- delete all the out NOCOPY correspondence ref records for this correspondence item
                FOR v_ocr_1_rec IN c_ocr_1(
                                        p_correspondence_type,
                                        p_reference_number) LOOP
                        IGS_CO_OU_CO_REF_PKG.DELETE_ROW(X_ROWID=>v_ocr_1_rec.ROWID);
                END LOOP;
        END IF;
        -- delete all the outgoing correspondence records for this correspondence item.
        FOR v_oc_rec IN c_oc(
                        p_correspondence_type,
                        p_reference_number) LOOP
                IGS_CO_OU_CO_PKG.DELETE_ROW(X_ROWID=>v_oc_rec.ROWID);
        END LOOP;
        -- delete correspondence item
        FOR v_cit_rec IN c_cit(
                                p_correspondence_type,
                                p_reference_number) LOOP
                IGS_CO_ITM_PKG.DELETE_ROW(X_ROWID=>v_cit_rec.ROWID);
        END LOOP;
        COMMIT;
        RETURN TRUE;
END;
EXCEPTION
        WHEN e_resource_busy THEN
                        ROLLBACK TO sp_before_delete;
                        p_message_name := 'IGS_CO_CORITEM_REC_LOCKED';
                        RETURN FALSE;
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                Fnd_Message.Set_Token('NAME','IGS_CO_GEN_002.corp_del_cori_spl');
                IGS_GE_MSG_STACK.ADD;
                lv_param_values := p_correspondence_type||','||TO_CHAR(p_reference_number)||','||p_letter_delete;
                Fnd_Message.Set_Name('IGS','IGS_GE_PARAMETERS');
                Fnd_Message.Set_Token('VALUE','lv_param_values');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END corp_del_cori_spl;

FUNCTION corp_ins_splp(
  p_person_id IN NUMBER ,
  p_correspondence_type IN VARCHAR2 ,
  p_letter_reference_number IN NUMBER ,
  p_spl_sequence_number IN NUMBER ,
  p_letter_parameter_type IN VARCHAR2 ,
  p_letter_repeating_group_cd IN VARCHAR2 ,
  p_splrg_sequence_number IN NUMBER ,
  p_record_number IN NUMBER ,
  p_letter_context_parameter IN VARCHAR2 ,
  p_extra_context OUT NOCOPY VARCHAR2 ,
  p_stored_ind OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2,
  p_letter_order_number IN number)
RETURN BOOLEAN AS
BEGIN   -- corp_ins_splp
        -- This module calculates the value for a IGS_CO_LTR_PARAM and inserts
        -- a record into the IGS_CO_S_PER_LT_PARM table.
DECLARE
        cst_in                          CONSTANT        VARCHAR2(2)  := 'IN';
        cst_out                         CONSTANT        VARCHAR2(3)  := 'OUT';
        cst_phrase                      CONSTANT        VARCHAR2(6)  := 'PHRASE';
        cst_adm                         CONSTANT        VARCHAR2(3)  := 'ADM';
        cst_person_id                   CONSTANT        VARCHAR2(11) := 'p_person_id';
        cst_rec_num                     CONSTANT        VARCHAR2(15) := 'p_record_number';
        cst_let_context_param           CONSTANT        VARCHAR2(26) := 'p_letter_context_parameter';
        cst_cor_type                    CONSTANT        VARCHAR2(21) := 'p_correspondence_type';
        cst_let_ref_num                 CONSTANT        VARCHAR2(25) := 'p_letter_reference_number';
        cst_s_let_parm_type             CONSTANT        VARCHAR2(25) := 'p_s_letter_parameter_type';
        cst_p_let_ref_num               CONSTANT        VARCHAR2(25) := 'p_letter_reference_number';
        cst_s_let_param_type            CONSTANT        VARCHAR2(26) := 'v_s_letter_parameter_type';
        cst_v_extra_context             CONSTANT        VARCHAR2(15) := 'v_extra_context';
        cst_v_value                     CONSTANT        VARCHAR2(7)  := 'v_value';
        v_dbms                          INTEGER;
        v_dbms_return                   INTEGER;
        v_value                         VARCHAR2(2000);
        v_sequence_number               IGS_CO_S_PER_LT_PARM.sequence_number%TYPE;
        v_lpt_s_letter_parameter_type
                                        IGS_CO_LTR_PARM_TYPE.S_LETTER_PARAMETER_TYPE%TYPE;
        v_letter_text                   IGS_CO_LTR_PARM_TYPE.letter_text%TYPE;
        v_code_block                    IGS_CO_S_LTR_PARAM.code_block%TYPE;
        v_slpt_s_letter_parameter_type
                                        IGS_CO_S_LTR_PARAM.S_LETTER_PARAMETER_TYPE%TYPE;
        v_adm_appl_num                  IGS_AD_APPL.admission_appl_number%TYPE;
        v_aal_sequence_number           IGS_CO_S_PER_LT_PARM.sequence_number%TYPE;
        v_extra_context                 VARCHAR2(100);
        v_message_name                  varchar2(30);
        X_ROWID                         VARCHAR2(25);
        CURSOR c_get_nxt_seq IS
                SELECT IGS_CO_S_PER_LT_PARM_SEQ_NUM_S.NEXTVAL
                FROM DUAL;
        CURSOR c_lpt IS
                SELECT  lpt.S_LETTER_PARAMETER_TYPE,
                        lpt.letter_text,
                        slpt.code_block,
                        slpt.S_LETTER_PARAMETER_TYPE
                FROM    IGS_CO_LTR_PARM_TYPE    lpt,
                        IGS_CO_S_LTR_PARAM slpt
                WHERE   lpt.LETTER_PARAMETER_TYPE       = p_letter_parameter_type AND
                        slpt.S_LETTER_PARAMETER_TYPE    = lpt.S_LETTER_PARAMETER_TYPE;
        CURSOR c_slpta_in (
                         cp_s_letter_parameter_type
                                IGS_CO_S_LTR_PARAM.S_LETTER_PARAMETER_TYPE%TYPE) IS
                SELECT  slpta.bind_variable
                FROM    IGS_CO_S_LTR_PR_ARG slpta
                WHERE   slpta.S_LETTER_PARAMETER_TYPE = cp_s_letter_parameter_type AND
                        slpta.direction = cst_in;
        CURSOR c_slpta_out(
                         cp_s_letter_parameter_type
                                IGS_CO_S_LTR_PARAM.S_LETTER_PARAMETER_TYPE%TYPE) IS
                SELECT  slpta.bind_variable
                FROM    IGS_CO_S_LTR_PR_ARG slpta
                WHERE   slpta.S_LETTER_PARAMETER_TYPE = cp_s_letter_parameter_type  AND
                        slpta.direction = cst_out;
BEGIN
        -- Initialise output parameters
        p_message_name  := Null;
        p_stored_ind    := 'N';
        -- Get IGS_CO_S_LTR_PARAM from IGS_CO_LTR_PARM_TYPE
        OPEN    c_lpt;
        FETCH   c_lpt   INTO    v_lpt_s_letter_parameter_type,
                                v_letter_text,
                                v_code_block,
                                v_slpt_s_letter_parameter_type;
        IF(c_lpt%NOTFOUND) THEN
                CLOSE c_lpt;
                p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
                RETURN FALSE;
        END IF;
        CLOSE c_lpt;
        -- Set up all the bind variables that could be passed into the dynamic SQL
        IF(v_lpt_s_letter_parameter_type <> cst_phrase) THEN
                IF(v_letter_text IS NOT NULL) THEN
                        IF(p_record_number <> 1) THEN
                                p_stored_ind := 'N';
                                RETURN TRUE;
                        ELSE
                                v_value := v_letter_text;
                        END IF;
                ELSE
                        IF v_code_block IS NULL THEN
                                p_stored_ind := 'N';
                                RETURN TRUE;
                        END IF;
                        -- Open a cursor for dynamic SQL
                        v_dbms := DBMS_SQL.OPEN_CURSOR;
                        -- Put the block of code from the IGS_CO_S_LTR_PARAM table
                        -- into the dynmaic SQL cursor
                        DBMS_SQL.PARSE(
                                        v_dbms,
                                        v_code_block,
                                        DBMS_SQL.NATIVE);
                        -- Set up all the bind variables that could be passed into the
                        -- dynamic SQL
                        FOR v_slpta_in_rec IN c_slpta_in (
                                                        v_slpt_s_letter_parameter_type) LOOP
                                IF v_slpta_in_rec.bind_variable = cst_rec_num THEN
                                        DBMS_SQL.BIND_VARIABLE(
                                                                v_dbms,
                                                                'p_record_number',
                                                                p_record_number);
                                ELSIF v_slpta_in_rec.bind_variable = cst_let_context_param THEN
                                        DBMS_SQL.BIND_VARIABLE(
                                                                v_dbms,
                                                                'p_letter_context_parameter',
                                                                p_letter_context_parameter);
                                ELSIF v_slpta_in_rec.bind_variable = cst_person_id THEN
                                        DBMS_SQL.BIND_VARIABLE(
                                                                v_dbms,
                                                                'p_person_id',
                                                                p_person_id);
                                ELSIF v_slpta_in_rec.bind_variable = cst_cor_type THEN
                                        DBMS_SQL.BIND_VARIABLE(
                                                                v_dbms,
                                                                'p_correspondence_type',
                                                                p_correspondence_type);
                                ELSIF v_slpta_in_rec.bind_variable = cst_let_ref_num THEN
                                        DBMS_SQL.BIND_VARIABLE(
                                                                v_dbms,
                                                                'p_letter_reference_number',
                                                                p_letter_reference_number);
                                ELSIF v_slpta_in_rec.bind_variable = cst_s_let_param_type then
                                        DBMS_SQL.BIND_VARIABLE(
                                                                v_dbms,
                                                                'v_s_letter_parameter_type',
                                                                v_lpt_s_letter_parameter_type);
                                END IF;
                        END LOOP;
                        -- set up all the bind variables that may be passed out NOCOPY of the dynamic SQL
                        FOR v_slpta_out_rec IN c_slpta_out  (
                                                        v_slpt_s_letter_parameter_type)  LOOP
                                IF v_slpta_out_rec.bind_variable = cst_v_value THEN
                                        DBMS_SQL.BIND_VARIABLE(
                                                                v_dbms,
                                                                'v_value',
                                                                NULL,
                                                                2000);
                                ELSIF v_slpta_out_rec.bind_variable = cst_v_extra_context THEN
                                        DBMS_SQL.BIND_VARIABLE(
                                                                v_dbms,
                                                                'v_extra_context',
                                                                NULL,
                                                                2000);
                                END IF;
                        END LOOP;
                        -- execute the dynmaic SQL block of code.
                        v_dbms_return := DBMS_SQL.EXECUTE(v_dbms);
                        -- Copy values of bind variables to program variables.
                        FOR v_slpta_out_rec IN c_slpta_out  (
                                                        v_slpt_s_letter_parameter_type) LOOP
                                IF v_slpta_out_rec.bind_variable = cst_v_value THEN
                                        DBMS_SQL.VARIABLE_VALUE(
                                                                v_dbms,
                                                                'v_value',
                                                                v_value);
                                ELSIF v_slpta_out_rec.bind_variable = cst_v_extra_context THEN
                                        DBMS_SQL.VARIABLE_VALUE(
                                                                v_dbms,
                                                                'v_extra_context',
                                                                p_extra_context);
                                END IF;
                        END LOOP;
                        -- Close the dynamic SQL cursor
                        DBMS_SQL.CLOSE_CURSOR(v_dbms);
                END IF;  -- v_letter_text IS NULL
                -- After all the tests are done check if v_value is NULL
                IF(v_value IS NOT NULL) THEN
                        p_stored_ind := 'Y';
                        -- splp_sequence_number.NEXTVAL
                        OPEN c_get_nxt_seq;
                        FETCH c_get_nxt_seq INTO v_sequence_number;
                        CLOSE c_get_nxt_seq;
                        IGS_CO_S_PER_LT_PARM_PKG.INSERT_ROW(X_ROWID=>X_ROWID,
                                        X_PERSON_ID=>p_person_id,
                                        X_CORRESPONDENCE_TYPE=>p_correspondence_type,
                                        X_LETTER_REFERENCE_NUMBER=>p_letter_reference_number,
                                        X_SPL_SEQUENCE_NUMBER=>p_spl_sequence_number,
                                        X_LETTER_PARAMETER_TYPE=>p_letter_parameter_type,
                                        X_SEQUENCE_NUMBER=>v_sequence_number,
                                        X_PARAMETER_VALUE=>v_value,
                                        X_LETTER_REPEATING_GROUP_CD=>p_letter_repeating_group_cd,
                                        X_SPLRG_SEQUENCE_NUMBER=>p_splrg_sequence_number,
                                        X_MODE=>'R',
					x_letter_order_number => p_letter_order_number,
					X_ORG_ID => FND_PROFILE.value('ORG_ID'));
                END IF;
        ELSE    -- IGS_CO_S_LTR_PARAM = 'PHRASE'
                IF p_record_number <> 1 THEN
                        p_stored_ind := 'N';
                        RETURN TRUE;
                END IF;
                IF(igs_ad_val_apcl.corp_val_slet_slrt(
                                                p_correspondence_type,
                                                p_letter_reference_number,
                                                cst_adm,
                                                v_message_name) = TRUE) THEN
                        v_adm_appl_num := TO_NUMBER(IGS_GE_GEN_002.genp_get_delimit_str(
                                                                p_letter_context_parameter,1,'|'));
                        v_aal_sequence_number := TO_NUMBER(IGS_GE_GEN_002.genp_get_delimit_str(
                                                                p_letter_context_parameter,2,'|'));
                               declare
                              p_letter_order_number NUMBER(3);
                                 cursor get_lon IS SELECT letter_order_number
                                   from igs_co_ltr_param
  where correspondence_type = p_correspondence_type and letter_parameter_type = p_letter_parameter_type and
         letter_reference_number = p_letter_reference_number;

                                    begin
                                        open get_lon;
				fetch get_lon into p_letter_order_number;
						close get_lon;

                        IF(IGS_AD_GEN_011.admp_ins_phrase_splp(
                                                p_person_id,
                                                v_adm_appl_num,
                                                p_correspondence_type,
                                                v_aal_sequence_number,
                                                p_letter_parameter_type,
                                                p_letter_reference_number,
                                                p_spl_sequence_number,
                                                p_letter_repeating_group_cd,
                                                p_splrg_sequence_number, p_letter_order_number ) = TRUE) THEN
                                p_stored_ind := 'Y';
                        END IF;
end;
                END IF;
        END IF;
        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
                IF DBMS_SQL.IS_OPEN(v_dbms) THEN
                      DBMS_SQL.CLOSE_CURSOR(v_dbms);
                END IF;
                IF c_get_nxt_seq%ISOPEN THEN
                        CLOSE c_get_nxt_seq;
                END IF;
                IF c_lpt%ISOPEN THEN
                        CLOSE c_lpt;
                END IF;
                IF c_slpta_in%ISOPEN THEN
                        CLOSE c_slpta_in;
                END IF;
                IF c_slpta_out%ISOPEN THEN
                        CLOSE c_slpta_out;
                END IF;
                RAISE;
END;
EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                Fnd_Message.Set_Token('NAME','IGS_CO_GEN_002.corp_ins_splp');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END corp_ins_splp;
--
FUNCTION corp_ins_spl_detail(
  p_person_id IN NUMBER ,
  p_correspondence_type IN VARCHAR2 ,
  p_letter_reference_number IN NUMBER ,
  p_letter_context_parameter IN VARCHAR2 ,
  p_spl_sequence_number OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY varchar2)
RETURN BOOLEAN AS
/*
 Change History
   Who          When            What
   pkpatel      24-APR-2003     Bug 2908844
                                The procedure is no longer used. Hence stubbed.
*/
BEGIN

 RETURN TRUE;

END corp_ins_spl_detail;
--
PROCEDURE CORP_UPD_OC_DT_SENT(
  errbuf  out NOCOPY  varchar2,
  retcode out NOCOPY  varchar2,
  p_reference_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_issue_dt_c IN VARCHAR2 ,
  p_dt_sent_c IN varchar2 )
AS
        e_no_records_found      EXCEPTION;
        e_resource_busy         EXCEPTION;
        PRAGMA  EXCEPTION_INIT(e_resource_busy, -54);
        CURSOR c_outgoing_correspondence (
                                cp_reference_number IGS_CO_OU_CO.reference_number%TYPE,
                                cp_person_id IGS_CO_OU_CO.person_id%TYPE,
                                cp_issue_dt IGS_CO_OU_CO.issue_dt%TYPE) IS
                SELECT  oc.ROWID,
                                oc.PERSON_ID ,
                                oc.CORRESPONDENCE_TYPE,
                                oc.REFERENCE_NUMBER,
                                oc.ISSUE_DT,
                                oc.DT_SENT ,
                                oc.UNKNOWN_RETURN_DT,
                                oc.ADDR_TYPE,
                                oc.TRACKING_ID,
                                oc.COMMENTS,
				oc.LETTER_REFERENCE_NUMBER        ,
				oc.SPL_SEQUENCE_NUMBER
                FROM    IGS_CO_OU_CO oc
                WHERE   oc.reference_number = cp_reference_number AND
                        ((oc.person_id = cp_person_id AND
                          (cp_person_id IS NOT NULL OR cp_person_id <> 0)) OR
                          (cp_person_id IS NULL OR cp_person_id = 0))AND
                        TRUNC(oc.issue_dt) = cp_issue_dt AND
                        oc.dt_sent IS NULL
                FOR UPDATE OF oc.dt_sent NOWAIT;
        v_record_found                  BOOLEAN;
        v_other_detail                  VARCHAR2(255);
        p_issue_dt                      DATE;
        p_dt_sent                       DATE;
BEGIN
        igs_ge_gen_003.set_org_id;

        retcode:=0;
        p_issue_dt := TO_DATE(p_issue_dt_c,'YYYY/MM/DD HH24:MI:SS');
        p_dt_sent := TO_DATE(p_dt_sent_c,'YYYY/MM/DD HH24:MI:SS');
        -- This module updates outgoing correspondence records with date sent.
        -- IGS_GE_NOTE: person_id parameter may be optionally provided.
        -- If a lock is encountered at any time, then its handled as an exception,
        -- by sending a message via DBMS_OUTPUT and re-raising the exception.
        v_record_found := FALSE;
        FOR v_outgoing_correspondence_rec IN c_outgoing_correspondence(
                                                                p_reference_number,
                                                                p_person_id,
                                                                p_issue_dt) LOOP
                v_record_found := TRUE;
                IGS_CO_OU_CO_PKG.update_row(
                                        X_ROWID => v_outgoing_correspondence_rec.ROWID,
                                        X_PERSON_ID =>v_outgoing_correspondence_rec.PERSON_ID ,
                                        X_CORRESPONDENCE_TYPE =>v_outgoing_correspondence_rec.CORRESPONDENCE_TYPE,
                                        X_REFERENCE_NUMBER => v_outgoing_correspondence_rec.REFERENCE_NUMBER,
                                        X_ISSUE_DT => v_outgoing_correspondence_rec.ISSUE_DT,
                                        X_DT_SENT =>P_DT_SENT,
                                        X_UNKNOWN_RETURN_DT => v_outgoing_correspondence_rec.UNKNOWN_RETURN_DT,
                                        X_ADDR_TYPE =>  v_outgoing_correspondence_rec.ADDR_TYPE ,
                                        X_TRACKING_ID => v_outgoing_correspondence_rec.TRACKING_ID ,
                                        X_COMMENTS => v_outgoing_correspondence_rec.COMMENTS ,
					X_LETTER_REFERENCE_NUMBER      =>v_outgoing_correspondence_rec.letter_REFERENCE_NUMBER,
					X_SPL_SEQUENCE_NUMBER          =>v_outgoing_correspondence_rec.spl_sequence_NUMBER,
                                        X_MODE=> 'R'
                                );
        END LOOP;
        IF(v_record_found = FALSE) THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('FND', 'FORM_RECORD_DELETED')
                                        || '  ' || TO_CHAR(p_reference_number)
                                        || '  ' || TO_CHAR(p_person_id)
                                        || '  ' || TO_CHAR(p_issue_dt)
                                        || '  ' || TO_CHAR(p_dt_sent));
        ELSE
                COMMIT;
        END IF;
EXCEPTION
        WHEN e_resource_busy THEN
                errbuf:= FND_MESSAGE.get_string('IGS','IGS_CO_CORREC_LOCK_ANOTHERUSR');
                retcode :=2;
        WHEN OTHERS THEN
                retcode :=2;
                errbuf:= FND_MESSAGE.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END corp_upd_oc_dt_sent;
--
PROCEDURE corp_get_ocv_details(
  p_person_id IN OUT NOCOPY IGS_CO_OU_CO.person_id%TYPE ,
  p_correspondence_type IN OUT NOCOPY IGS_CO_ITM.CORRESPONDENCE_TYPE%TYPE ,
  p_cal_type IN OUT NOCOPY IGS_CO_OU_CO_REF.CAL_TYPE%TYPE ,
  p_ci_sequence_number IN OUT NOCOPY IGS_CO_OU_CO_REF.ci_sequence_number%TYPE,
  p_course_cd IN OUT NOCOPY IGS_CO_OU_CO_REF.course_cd%TYPE ,
  p_cv_version_number IN OUT NOCOPY IGS_CO_OU_CO_REF.cv_version_number%TYPE ,
  p_unit_cd IN OUT NOCOPY IGS_CO_OU_CO_REF.unit_cd%TYPE ,
  p_uv_version_number IN OUT NOCOPY IGS_CO_OU_CO_REF.uv_version_number%TYPE ,
  p_s_other_reference_type IN OUT NOCOPY IGS_CO_OU_CO_REF.S_OTHER_REFERENCE_TYPE%TYPE ,
  p_other_reference IN OUT NOCOPY IGS_CO_OU_CO_REF.other_reference%TYPE ,
  p_addr_type IN OUT NOCOPY IGS_CO_OU_CO.ADDR_TYPE%TYPE ,
  p_tracking_id IN OUT NOCOPY IGS_CO_OU_CO.tracking_id%TYPE ,
  p_request_num IN OUT NOCOPY IGS_CO_ITM.request_num%TYPE ,
  p_s_job_name IN OUT NOCOPY IGS_CO_ITM.s_job_name%TYPE ,
  p_request_job_id IN OUT NOCOPY IGS_CO_ITM.request_job_id%TYPE ,
  p_request_job_run_id IN OUT NOCOPY IGS_CO_ITM.request_job_run_id%TYPE,
  p_correspondence_cat OUT NOCOPY VARCHAR2 ,
  p_reference_number OUT NOCOPY IGS_CO_ITM.reference_number%TYPE ,
  p_issue_dt OUT NOCOPY IGS_CO_OU_CO.issue_dt%TYPE ,
  p_dt_sent OUT NOCOPY IGS_CO_OU_CO.dt_sent%TYPE ,
  p_unknown_return_dt OUT NOCOPY IGS_CO_OU_CO.unknown_return_dt%TYPE ,
  p_adt_description OUT NOCOPY varchar2,
  p_create_dt OUT NOCOPY IGS_CO_ITM.create_dt%TYPE ,
  p_originator_person_id OUT NOCOPY IGS_CO_ITM.originator_person_id%TYPE ,
  p_output_num OUT NOCOPY IGS_CO_ITM.output_num%TYPE ,
  p_oc_comments OUT NOCOPY IGS_CO_OU_CO.comments%TYPE ,
  p_cori_comments OUT NOCOPY IGS_CO_ITM.comments%TYPE ,
  p_message_name OUT NOCOPY varchar2 )
AS
BEGIN   -- corp_get_ocv_details
        -- This module gets information from the latest record in the outgoing
        -- correspondence view for a set of variable parameters.
DECLARE
        CURSOR c_ocv IS
                SELECT  person_id,
                        CORRESPONDENCE_TYPE,
                        CAL_TYPE,
                        ci_sequence_number,
                        course_cd,
                        cv_version_number,
                        unit_cd,
                        uv_version_number,
                        S_OTHER_REFERENCE_TYPE,
                        other_reference,
                        ADDR_TYPE,
                        tracking_id,
                        request_num,
                        s_job_name,
                        request_job_id,
                        request_job_run_id,
                        CORRESPONDENCE_CAT,
                        reference_number,
                        issue_dt,
                        dt_sent,
                        unknown_return_dt,
                        adt_description,
                        create_dt,
                        originator_person_id,
                        output_num,
                        oc_comments,
                        cori_comments
                FROM    IGS_CO_OU_CO_V
                WHERE   (p_person_id IS NULL OR
                        person_id               = p_person_id) AND
                        (p_correspondence_type IS NULL OR
                        CORRESPONDENCE_TYPE     = p_correspondence_type) AND
                        (p_cal_type IS NULL OR
                        CAL_TYPE                = p_cal_type) AND
                        (p_ci_sequence_number IS NULL OR
                        ci_sequence_number      = p_ci_sequence_number) AND
                        (p_course_cd IS NULL OR
                        course_cd               = p_course_cd) AND
                        (p_cv_version_number IS NULL OR
                        cv_version_number       = p_cv_version_number) AND
                        (p_unit_cd IS NULL OR
                        unit_cd                 = p_unit_cd) AND
                        (p_uv_version_number IS NULL OR
                        uv_version_number       = p_uv_version_number) AND
                        (p_s_other_reference_type IS NULL OR
                        S_OTHER_REFERENCE_TYPE  = p_s_other_reference_type) AND
                        (p_other_reference IS NULL OR
                        other_reference         = p_other_reference) AND
                        (p_addr_type IS NULL OR
                        ADDR_TYPE               = p_addr_type) AND
                        (p_tracking_id IS NULL OR
                        tracking_id             = p_tracking_id) AND
                        (p_request_num IS NULL OR
                        request_num             = p_request_num) AND
                        (p_s_job_name IS NULL OR
                        s_job_name              = p_s_job_name) AND
                        (p_request_job_id IS NULL OR
                        request_job_id          = p_request_job_id) AND
                        (p_request_job_run_id IS NULL OR
                        request_job_run_id      = p_request_job_run_id)
                ORDER BY issue_dt DESC,
                        reference_number DESC;
        v_ocv_rec       c_ocv%ROWTYPE;
BEGIN
        -- Set the default message number
        p_message_name := Null;
        -- Cursor handling
        OPEN c_ocv;
        FETCH c_ocv INTO v_ocv_rec;
        IF c_ocv%NOTFOUND THEN
                CLOSE c_ocv;
                -- Set the out NOCOPY parameters to null
                p_person_id := NULL;
                p_correspondence_type := NULL;
                p_cal_type := NULL;
                p_ci_sequence_number := NULL;
                p_course_cd := NULL;
                p_cv_version_number := NULL;
                p_unit_cd := NULL;
                p_uv_version_number := NULL;
                p_s_other_reference_type := NULL;
                p_other_reference := NULL;
                p_addr_type := NULL;
                p_tracking_id := NULL;
                p_request_num := NULL;
                p_s_job_name := NULL;
                p_request_job_id := NULL;
                p_request_job_run_id := NULL;
                p_correspondence_cat := NULL;
                p_reference_number := NULL;
                p_issue_dt := NULL;
                p_dt_sent := NULL;
                p_unknown_return_dt := NULL;
                p_adt_description := NULL;
                p_create_dt := NULL;
                p_originator_person_id := NULL;
                p_output_num := NULL;
                p_oc_comments := NULL;
                p_cori_comments := NULL;
                p_message_name := 'IGS_AS_OUTGOING_CORREC_NOTFND';
                RETURN;
        END IF;
        CLOSE c_ocv;
        p_person_id := v_ocv_rec.person_id;
        p_correspondence_type := v_ocv_rec.CORRESPONDENCE_TYPE;
        p_cal_type := v_ocv_rec.CAL_TYPE;
        p_ci_sequence_number := v_ocv_rec.ci_sequence_number;
        p_course_cd := v_ocv_rec.course_cd;
        p_cv_version_number := v_ocv_rec.cv_version_number;
        p_unit_cd := v_ocv_rec.unit_cd;
        p_uv_version_number := v_ocv_rec.uv_version_number;
        p_s_other_reference_type := v_ocv_rec.S_OTHER_REFERENCE_TYPE;
        p_other_reference := v_ocv_rec.other_reference;
        p_addr_type := v_ocv_rec.ADDR_TYPE;
        p_tracking_id := v_ocv_rec.tracking_id;
        p_request_num := v_ocv_rec.request_num;
        p_s_job_name := v_ocv_rec.s_job_name;
        p_request_job_id := v_ocv_rec.request_job_id;
        p_request_job_run_id := v_ocv_rec.request_job_run_id;
        p_correspondence_cat := v_ocv_rec.CORRESPONDENCE_CAT;
        p_reference_number := v_ocv_rec.reference_number;
        p_issue_dt := v_ocv_rec.issue_dt;
        p_dt_sent := v_ocv_rec.dt_sent;
        p_unknown_return_dt := v_ocv_rec.unknown_return_dt;
        p_adt_description := v_ocv_rec.adt_description;
        p_create_dt := v_ocv_rec.create_dt;
        p_originator_person_id := v_ocv_rec.originator_person_id;
        p_output_num := v_ocv_rec.output_num;
        p_oc_comments := v_ocv_rec.oc_comments;
        p_cori_comments := v_ocv_rec.cori_comments;
        RETURN;
EXCEPTION
        WHEN OTHERS THEN
                IF c_ocv%ISOPEN THEN
                        CLOSE c_ocv;
                END IF;
                RAISE;
END;
EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                Fnd_Message.Set_Token('NAME','IGS_CO_GEN_002.corp_get_ocv_details');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END corp_get_ocv_details;

END IGS_CO_GEN_002;

/
