--------------------------------------------------------
--  DDL for Package Body IGS_RU_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_GEN_003" AS
/* $Header: IGSRU03B.pls 120.2 2005/07/19 07:03:02 appldev ship $ */

Function Rulp_Clc_Student_Fee(
  p_rule_number IN NUMBER ,
  p_charge_elements IN NUMBER ,
  p_charge_rate IN NUMBER )
RETURN NUMBER IS
        v_message       VARCHAR2(1000);
BEGIN
        RETURN IGS_RU_GEN_001.RULP_VAL_SENNA(
                        p_message => v_message,
                        p_rule_number => p_rule_number,
                        p_param_1 => p_charge_elements,
                        p_param_2 => p_charge_rate );
END;

Function Rulp_Del_Rlov(
  p_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
        gv_other_detail         VARCHAR2(255);
BEGIN
/*
 rulp_del_rlov
 Delete from IGS_RU_LOV table
*/
DECLARE
        e_resource_busy         EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_resource_busy, -54);
/*
Cursor to lock records for delete
*/

        CURSOR c_rlov_delete IS
                SELECT  rlov.rowid
                FROM    IGS_RU_LOV rlov
                WHERE   rlov.sequence_number = p_sequence_number
                FOR UPDATE OF rlov.sequence_number NOWAIT;
BEGIN
        p_message_name := null;
        FOR v_rlov_delete_rec IN c_rlov_delete LOOP
/*
                Delete current record
*/
                IGS_RU_LOV_PKG.Delete_Row(
                        X_ROWID => v_rlov_delete_rec.rowid
                        );
        END LOOP;
/*
        ecord successfully deleted.
*/
        RETURN TRUE;
EXCEPTION
        WHEN e_resource_busy THEN
                IF (c_rlov_delete%ISOPEN) THEN
                        CLOSE c_rlov_delete;
                END IF;
                p_message_name := 'IGS_GE_REC_NOT_LOCKED';
                RETURN FALSE;
        WHEN OTHERS THEN
                IF (c_rlov_delete%ISOPEN) THEN
                        CLOSE c_rlov_delete;
                END IF;
                RAISE;
END;
EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_RU_GEN_003.rulp_del_rlov');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END rulp_del_rlov;

Procedure Rulp_Del_Rule(
  p_rule_number IN NUMBER )
IS
/*
 cascade delete IGS_RU_RULE items
*/
PROCEDURE delete_rule_items(
        p_rule_number   IN IGS_RU_RULE.sequence_number%TYPE,
        p_item          IN IGS_RU_ITEM.item%TYPE)
IS
        CURSOR Cur_Item_Del( r_item IGS_RU_ITEM.item%TYPE) IS
                SELECT rowid
                FROM IGS_RU_ITEM
                WHERE rul_sequence_number = p_rule_number
                AND     item = r_item;

        CURSOR Cur_Rule_Del(r_rule_number IGS_RU_ITEM.rule_number%TYPE) IS
                SELECT rowid
                FROM IGS_RU_RULE
                WHERE sequence_number = r_rule_number;

        CURSOR Cur_Set_Mem_Del(r_set_number IGS_RU_ITEM.set_number%TYPE) IS
                SELECT rowid
                FROM IGS_RU_SET_MEMBER
                WHERE rs_sequence_number = r_set_number;

        CURSOR Cur_Set_Del(r_set_number IGS_RU_ITEM.set_number%TYPE) IS
                SELECT rowid
                FROM IGS_RU_SET
                WHERE sequence_number = r_set_number;


BEGIN
        FOR rule_items IN (
                SELECT  item,
                        rule_number,
                        set_number
                FROM    IGS_RU_ITEM
                WHERE   rul_sequence_number = p_rule_number
                AND     item >= p_item )
        LOOP

                for item_rec in Cur_Item_Del(rule_items.item) loop
                        IGS_RU_ITEM_PKG.DELETE_ROW(
                        X_ROWID => item_rec.rowid
                        );
                end loop;


                IF rule_items.rule_number IS NOT NULL
                THEN
/*
                         remove all items of this IGS_RU_RULE
*/
                        delete_rule_items(rule_items.rule_number,0);
/*
                         remove IGS_RU_RULE
*/

                        for rule_rec in Cur_Rule_Del( rule_items.rule_number) loop
                                IGS_RU_RULE_PKG.DELETE_ROW(
                                X_ROWID => rule_rec.rowid
                                );
                        end loop;

                ELSIF rule_items.set_number IS NOT NULL
                THEN
/*
                 remove set members
*/
                        for set_mem_rec in Cur_Set_Mem_Del( rule_items.set_number) loop
                                IGS_RU_SET_MEMBER_PKG.DELETE_ROW(
                                X_ROWID => set_mem_rec.rowid
                                );
                        end loop;
/*
                remove set
*/
                        for set_rec in Cur_Set_Del( rule_items.set_number) loop
                                IGS_RU_SET_PKG.DELETE_ROW(
                                X_ROWID => set_rec.rowid
                                );
                        end loop;
                END IF;
        END LOOP;
END delete_rule_items;

/*
rulp_del_rule
*/
BEGIN
        delete_rule_items(p_rule_number,0);
END;

Function Rulp_Del_Ur_Rule(
  p_unit_cd IN VARCHAR2 ,
  p_s_rule_call_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
BEGIN
DECLARE
        v_other_detail          VARCHAR2(255);
        v_ur_rec                        IGS_PS_UNIT_RU%ROWTYPE;
        CURSOR  c_unit_rule
                (cp_unit_cd             IGS_PS_UNIT_RU.unit_cd%TYPE,
                 cp_s_rule_call_cd              IGS_PS_UNIT_RU.s_rule_call_cd%TYPE) IS
                SELECT  *
                FROM    IGS_PS_UNIT_RU ur
                WHERE   ur.unit_cd      = cp_unit_cd AND
                        ur.s_rule_call_cd       = cp_s_rule_call_cd;

        CURSOR Cur_Unit_Ru_Del(r_unit_cd IGS_PS_UNIT_RU.unit_cd%TYPE,
                                     r_s_rule_call_cd IGS_PS_UNIT_RU.s_rule_call_cd%TYPE
                                        ) IS
                SELECT rowid
                FROM IGS_PS_UNIT_RU
                WHERE   unit_cd             = r_unit_cd AND
                        s_rule_call_cd      = r_s_rule_call_cd;

        CURSOR Cur_Rule_Del(r_sequence_number IGS_PS_UNIT_RU.rul_sequence_number%TYPE) IS
                SELECT rowid
                FROM IGS_RU_RULE
                WHERE sequence_number = r_sequence_number;

BEGIN
        p_message_name := Null;
/*
        Validate input parameters
*/
        IF p_unit_cd IS NULL OR
            p_s_rule_call_cd IS NULL THEN
                p_message_name := 'IGS_GE_INVALID_VALUE';
                RETURN FALSE;
        END IF;
/*
- This module deletes a IGS_PS_UNIT_RU and associated IGS_RU_RULE.
*/
        OPEN c_unit_rule(p_unit_cd,
                         p_s_rule_call_cd);


/*
        check if a record has been found
        if so, the record can be deleted.
*/
        IF (c_unit_rule%FOUND) THEN
/*
                Delete IGS_PS_UNIT_RU
*/

                for unit_ru_rec in Cur_Unit_Ru_Del(v_ur_rec.unit_cd, v_ur_rec.s_rule_call_cd) loop
                        IGS_PS_UNIT_RU_PKG.DELETE_ROW(
                        X_ROWID => unit_ru_rec.rowid
                        );
                end loop;

/*
                Delete associated IGS_RU_RULE
*/

                for rule_rec in Cur_Rule_Del( v_ur_rec.rul_sequence_number) loop
                        IGS_RU_RULE_PKG.DELETE_ROW(
                        X_ROWID => rule_rec.rowid
                        );
                end loop;

                CLOSE c_unit_rule;
        ELSE
                CLOSE c_unit_rule;
        END IF;
EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('Name','IGS_RU_GEN_003.rulp_del_ur_rule');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END;
END rulp_del_ur_rule;

Function Rulp_Get_Ret_Type(
  p_rud_sequence_number  NUMBER )
RETURN VARCHAR2 IS
        v_return_type   IGS_RU_RET_TYPE.s_return_type%TYPE;
BEGIN
        SELECT  s_return_type
        INTO    v_return_type
        FROM    IGS_RU_DESCRIPTION
        WHERE   sequence_number = p_rud_sequence_number;
        RETURN v_return_type;
END rulp_get_ret_type;

Function Rulp_Get_Rgi(
  p_description_number  NUMBER ,
  p_description_type  VARCHAR2 )
RETURN VARCHAR2 IS
/*
 Expand description_number to IGS_RU_DESCRIPTION or group_name
 if invalid return NULL
*/
        v_message_name  VARCHAR2(30);
BEGIN
        RETURN IGS_RU_GEN_004.rulp_val_desc_rgi(p_description_number,
                                p_description_type,
                                v_message_name);
END rulp_get_rgi;

FUNCTION Rulp_Get_Rule(
  p_rule_number IN NUMBER )
RETURN VARCHAR2 IS
  ------------------------------------------------------------------
  --Created by  : nsinha, Oracle India
  --Date created: 12-Mar-2001
  --
  --Purpose: Get text version of IGS_RU_RULE
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --nsinha      12-Mar-2002     Bug# 2233951: Moved the content of this
  --                            function in Igs_ru_gen_006.rulp_get_rule
  --                            and called it from there.
  --
  -------------------------------------------------------------------
        v_rule          VARCHAR2(2000);
BEGIN
   v_rule := Igs_ru_gen_006.rulp_get_rule(p_rule_number);
   RETURN v_rule;
END rulp_get_rule;

Function Rulp_Ins_Copy_Rule(
  p_rule_call_cd  VARCHAR2 ,
  p_rule_number IN NUMBER )
RETURN NUMBER IS
/*
 Copy a derived IGS_RU_RULE to a new IGS_RU_RULE
 RETURN IGS_RU_RULE number
 on error raise exception
*/
        CURSOR c_get_rule_dtls (
                cp_rule_call_cd IGS_RU_CALL.s_rule_call_cd%TYPE ) IS
                SELECT  select_group,
                        s_return_type
                FROM    IGS_RU_CALL,
                        IGS_RU_DESCRIPTION
                WHERE   s_rule_call_cd = p_rule_call_cd
                AND     sequence_number = rud_sequence_number;
        v_rule          VARCHAR2(2000);
        v_select_group  IGS_RU_CALL.select_group%TYPE;
        v_return_type   IGS_RU_RET_TYPE.s_return_type%TYPE;
        v_unprocessed   VARCHAR2(2000);
        v_rule_number   IGS_RU_RULE.sequence_number%TYPE;
        v_lov_number    IGS_RU_LOV.sequence_number%TYPE;
        v_other_details VARCHAR2(255);
        e_parser_error  EXCEPTION;
BEGIN
/*
        get text version of IGS_RU_RULE
*/
        v_rule := rulp_get_rule(p_rule_number);
/*
        get select group and return type
*/
        OPEN c_get_rule_dtls( p_rule_call_cd);
        FETCH c_get_rule_dtls INTO v_select_group, v_return_type;
        CLOSE c_get_rule_dtls;
        IF IGS_RU_GEN_002.rulp_ins_parser(v_select_group,
                        v_return_type,
                        '',
                        v_rule,
                        v_unprocessed,
                        TRUE,
                        v_rule_number,
                        v_lov_number) THEN
                RETURN v_rule_number;
        ELSE
                RAISE e_parser_error;
        END IF;
EXCEPTION
        WHEN e_parser_error THEN
Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
App_Exception.Raise_Exception;
        WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
FND_MESSAGE.SET_TOKEN('NAME','IGS_RU_GEN_003.rulp_ins_copy_rule');
IGS_GE_MSG_STACK.ADD;
App_Exception.Raise_Exception;
END rulp_ins_copy_rule;

FUNCTION rulp_clc_student_scope(
                           p_rule_number     IN   NUMBER,
                           p_unit_loc_cd     IN   VARCHAR2,
                           p_prg_type_level  IN   VARCHAR2,
                           p_org_code        IN   VARCHAR2,
                           p_unit_mode       IN   VARCHAR2,
                           p_unit_class      IN   VARCHAR2,
                           p_message         OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
  ------------------------------------------------------------------
  --Created by  : Bhaskar Annamalai, Oracle India
  --Date created: 12-Jul-2005
  --
  --Purpose: To Evaluate the Selection Criteria Rule
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

l_v_ret_val  VARCHAR2(100);

BEGIN
 l_v_ret_val  := igs_ru_gen_001.rulp_val_senna(
                         p_rule_number   => p_rule_number,
                         p_param_1       => p_unit_loc_cd,
                         p_param_2       => p_prg_type_level,
                         p_param_3       => p_org_code,
                         p_param_4       => p_unit_mode,
                         p_param_5       => p_unit_class,
                         p_message       => p_message );
 IF (l_v_ret_val = 'true') THEN
   return TRUE;
 ELSE
   return FALSE;
 END IF;
END rulp_clc_student_scope;


END IGS_RU_GEN_003;

/
