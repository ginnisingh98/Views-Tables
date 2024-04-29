--------------------------------------------------------
--  DDL for Package Body IGS_RU_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_GEN_001" AS
/* $Header: IGSRU01B.pls 120.7 2006/04/28 05:48:32 sepalani ship $ */
  ------------------------------------------------------------------
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --smadathi   07-JUN-2001      The functions ref_set, perid_chk, plc_chk,stg_set added . The length of
  --                             some of the variables were changed . The changes are as per enhancement bug No. 1775394
  --nalkumar   18-JUN-2001      The function rupl_get_alwd_cp added. The changes are as per enhancement bug No. 1830175
  --Prajeesh   21-apr-2002      In Log error Instead of directly raising
  --                            and exception put it in when others
  -- rghosh        3-Jan-2002      bug# 2507447 :Removed the reference to|
  --                                dual
  -------------------------------------------------------------------
  /*************************************************************
  Created By : nsinha
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who            When            What
  stutta     11-Apr-2006     Changed expand_uoo to create one pl/sql table record for a unit, version instance(only
                             for PREREQ, COREQ rules). Added fnd_logging when rules errors out with an exception. bug#5154191
  bdeviset      13-DEC-2005  Modified the cursor in function student to exclude the unit which the prereq or coreq is set if it not null.
                             Bug# 4304688
  bdeviset   05-OCT-2005     Modified functions adv_attribute,adv_relative_grade,sua_credit_points,asul_attribute
                             advanced_standing and advanced_stadning_unit_level for bug# 4480311
  bannamal     08-Jul-2005    Enh#3392088. added new turing functions.
  smaddali     11-may-05      Modified for bug#3723860. added new turin functions
  smaddali     11-apr-05      Modified for bug#4283221. Advance standing functionality has been modified
  stutta       15-Jul-2004    Build # 3381339; Modified sua_attribute and added p_final_ind as a new parameter.
                              Added handling for turning functions 'finlresult' and 'finalgrade'.
  ijeddy       03-Nov-2003     Build# 3181938; Modified this object as per Summary Measurement Of Attainment FD.
  knaraset       28-May-2003       Modified the functions/procedure/record group for MUS build bug 2829262
  smvk           28-Aug-2002     Removed the existing code in the function get_fdfr_rule and it is modified to return NULL always.
                                 as per SFCR005_Cleanup_Build TD (Enhancement Bug # 2531390). Removed Default values of the parameters
                                 in the function rulp_val_senna to avoid gscc warning 'File.Pkg.22'
  smanglm        10-05-2002      modified expand_gsch_set to segrgate grading schema and grad as both are stored together in unit_cd of igs_ru_set_member as per fix of bug 2287084
  smanglm        19-Apr-2002     Modified the cursor cur_gscd_set_members in the function
                                 expand_gsch_set to include DISTINCT in select query as the
                                 rule got modified as per bug 2287084
  svenkata       12-Dec-2001     Added prgp_cal_cp(), pr_rul_msg() Functions.  Modified turing() Function
                                 w.r.t Progression Rules Enhancement DLD, Bug No: 2146547.
  rbezawad       12-Dec-2001     Added prgpl_chk_gsch_exists(), prgp_cal_cp_gsch(), expand_gsch_set() Functions.
                                 Modified expand_set() Function w.r.t Progression Rules Enhancement DLD, Bug No: 2146547.
  smadathi       07-JUN-2001     The functions ref_set, perid_chk, plc_chk,stg_set added . The length of
                                 some of the variables were changed . The changes are as per enhancement bug No. 1775394
  nalkumar       18-JUN-2001     The function rupl_get_alwd_cp added. The changes are as per enhancement bug No. 1830175
  Navin          27-Aug-2001     Added a package variable igs_ru_gen_001.p_evaluated_part
                                 Created a turing function 'ifthen' and modified the logic of
                                 Rulp_Val_Senna as per the requirement of Bug# : 1899513.
  (reverse chronological order - newest change first)
  ***************************************************************/

g_debug_level CONSTANT NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

Function Rulp_Val_Senna(
  p_rule_call_name IN VARCHAR2,
  p_person_id IN NUMBER,
  p_course_cd IN VARCHAR2,
  p_course_version IN NUMBER,
  p_unit_cd IN VARCHAR2,
  p_unit_version IN NUMBER,
  p_cal_type IN VARCHAR2,
  p_ci_sequence_number IN NUMBER,
  p_message OUT NOCOPY VARCHAR2,
  p_rule_number  NUMBER,
  p_param_1  VARCHAR2,
  p_param_2  VARCHAR2,
  p_param_3  VARCHAR2,
  p_param_4  VARCHAR2,
  p_param_5  VARCHAR2,
  p_param_6  VARCHAR2,
  p_param_7  VARCHAR2,
  p_param_8  VARCHAR2, -- This parameter is used for passing uoo_id for prereq and coreq rules (eval_prereq and eval_coreq functions in igs_en_elgbl_unit)
  p_param_9  VARCHAR2,
  p_param_10  VARCHAR2,
  p_param_11  VARCHAR2,
  p_param_12  VARCHAR2,
  p_param_13  VARCHAR2,
  p_param_14  VARCHAR2,
  p_param_15  VARCHAR2,
  p_param_16  VARCHAR2,
  p_param_17  VARCHAR2,
  p_param_18  VARCHAR2,
  p_param_19  VARCHAR2,
  p_param_20  VARCHAR2,
  p_param_21  VARCHAR2,
  p_param_22  VARCHAR2,
  p_param_23  VARCHAR2,
  p_param_24  VARCHAR2,
  p_param_25  VARCHAR2,
  p_param_26  VARCHAR2,
  p_param_27  VARCHAR2,
  p_param_28  VARCHAR2,
  p_param_29  VARCHAR2,
  p_param_30  VARCHAR2,
  p_param_31  VARCHAR2,
  p_param_32  VARCHAR2,
  p_param_33  VARCHAR2,
  p_param_34  VARCHAR2,
  p_param_35  VARCHAR2,
  p_param_36  VARCHAR2,
  p_param_37  VARCHAR2,
  p_param_38  VARCHAR2,
  p_param_39  VARCHAR2,
  p_param_40  VARCHAR2,
  p_param_41  VARCHAR2,
  p_param_42  VARCHAR2,
  p_param_43  VARCHAR2,
  p_param_44  VARCHAR2,
  p_param_45  VARCHAR2,
  p_param_46  VARCHAR2,
  p_param_47  VARCHAR2,
  p_param_48  VARCHAR2,
  p_param_49  VARCHAR2,
  p_param_50  VARCHAR2,
  p_param_51  VARCHAR2,
  p_param_52  VARCHAR2,
  p_param_53  VARCHAR2,
  p_param_54  VARCHAR2,
  p_param_55  VARCHAR2,
  p_param_56  VARCHAR2,
  p_param_57  VARCHAR2,
  p_param_58  VARCHAR2,
  p_param_59  VARCHAR2,
  p_param_60  VARCHAR2,
  p_param_61  VARCHAR2,
  p_param_62  VARCHAR2,
  p_param_63  VARCHAR2,
  p_param_64  VARCHAR2,
  p_param_65  VARCHAR2,
  p_param_66  VARCHAR2,
  p_param_67  VARCHAR2,
  p_param_68  VARCHAR2,
  p_param_69  VARCHAR2,
  p_param_70  VARCHAR2,
  p_param_71  VARCHAR2,
  p_param_72  VARCHAR2,
  p_param_73  VARCHAR2,
  p_param_74  VARCHAR2,
  p_param_75  VARCHAR2,
  p_param_76  VARCHAR2,
  p_param_77  VARCHAR2,
  p_param_78  VARCHAR2,
  p_param_79  VARCHAR2,
  p_param_80  VARCHAR2,
  p_param_81  VARCHAR2,
  p_param_82  VARCHAR2,
  p_param_83  VARCHAR2,
  p_param_84  VARCHAR2,
  p_param_85  VARCHAR2,
  p_param_86  VARCHAR2,
  p_param_87  VARCHAR2,
  p_param_88  VARCHAR2,
  p_param_89  VARCHAR2,
  p_param_90  VARCHAR2,
  p_param_91  VARCHAR2,
  p_param_92  VARCHAR2,
  p_param_93  VARCHAR2,
  p_param_94  VARCHAR2,
  p_param_95  VARCHAR2,
  p_param_96  VARCHAR2,
  p_param_97  VARCHAR2,
  p_param_98  VARCHAR2,
  p_param_99  VARCHAR2 )
RETURN VARCHAR2 IS
  ------------------------------------------------------------------
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --smvk       28-AUG-2002     Removed the default value of parameters to avoid gscc warning 'File.Pkg.22'
  --svenkata   12-Dec-2001     Added Global variable g_grad_sch_set_no w.r.t Progression Rules Enhancement DLD, Bug No: 2146547
  --smadathi   07-JUN-2001     Length of the variable r_member.f1 changed to varchar2(30) from varchar2(10) .
  --                           Length of the variable r_tds.unit_cd changed to varchar2(30) from varchar2(10) .
  -------------------------------------------------------------------

/*
 RECORDS
 Set member record
*/

TYPE r_member IS RECORD (
        f1      VARCHAR2(30),
        f2      VARCHAR2(10),
        f3      VARCHAR2(10),
        f4      VARCHAR2(10),
        next    BINARY_INTEGER,
        f5      VARCHAR2(10)
);
/*
 Set record
*/
TYPE r_set IS RECORD (
        first           BINARY_INTEGER,
        last_insert     BINARY_INTEGER
);

/*
 turing data structure (data that turing may require)
 this data is used in subsequent turing calls
 mainly used by the set looping functions (select_set,sum_func,for_expand)
*/

TYPE r_tds IS RECORD (
        set_number                      BINARY_INTEGER,
        member_index            BINARY_INTEGER,  /* added 31/08/99 */
        unit_cd                 VARCHAR2(30),
        unit_version            VARCHAR2(10),
        cal_type                        VARCHAR2(10),
        ci_sequence_number      VARCHAR2(10),
        rule_outcome            IGS_RU_ITEM.value%TYPE,
        uoo_id                  VARCHAR2(10)
);

/*
 STRUCTURES
*/
TYPE t_member IS TABLE OF
        r_member
INDEX BY BINARY_INTEGER;
TYPE t_set IS TABLE OF
        r_set
INDEX BY BINARY_INTEGER;
TYPE t_stack IS TABLE OF
        IGS_RU_ITEM.value%TYPE
INDEX BY BINARY_INTEGER;


/*
 USER EXCEPTIONS
*/

rule_error              EXCEPTION;
/*
 CONSTANTS
*/
cst_space       CONSTANT VARCHAR2(1) := Fnd_Global.Local_Chr(31);
/*
 GLOBALS
 for debuging recursive code
*/
gv_turing_level         NUMBER(3);

/*
  GLOBAL Variable for getting the value of the Grading schema .
  Will be used when a call is made to the function p_grad_sch_set_no in the function pr_rul_msg.
  This is added w.r.t Progression Rules Enhancement DLD, Bug No: 2146547
*/
g_grad_sch_set_no NUMBER;

/*
 WORK SETS
 instance table of sets
*/
gv_set                  t_set;
gv_set_index            BINARY_INTEGER;
/*
 instance table of set members
*/
gv_member                       t_member;
gv_member_index         BINARY_INTEGER;
/*
turing engine stack
*/
gt_rule_stack           t_stack;
gv_stack_index          BINARY_INTEGER;

/*
 message stack
*/
gt_empty_message_stack  t_stack;
gt_message_stack        t_stack;
gv_message_stack_index  BINARY_INTEGER;
/*
 rule to message rule variable(s) table
*/
gt_variable             t_stack;
/*
 student sets, these are only gotten once per senna call
*/
gv_sua_set      BINARY_INTEGER := NULL;
gv_asu_set      BINARY_INTEGER := NULL;
gv_asul_set     BINARY_INTEGER := NULL;
gv_susa_set     BINARY_INTEGER := NULL;

-- Variable to hold set of grades obtained by student.
gv_grade_set    BINARY_INTEGER := NULL;

/*
variables to capture the param values for subsequent calls to function turing
*/

-- TYPE t_params_table IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
 --t_params t_params_table;
 v_index BINARY_INTEGER;

/*
 FORWARD REFERENCE DECLARATIONS
*/
FUNCTION turing (
  p_rule_number   IN NUMBER,
  p_tds           IN r_tds
) RETURN VARCHAR2;
/*
 MISCELLANEOUS FUNCTIONS
 display all non null parameters
*/
PROCEDURE log_error(
  p_function_name IN VARCHAR2,
  p_message       IN VARCHAR2
) IS
  v_error_text    VARCHAR2(2000);
BEGIN
  IF p_rule_call_name IS NOT NULL
  THEN
    v_error_text := v_error_text||Fnd_Global.Local_Chr(10)||'p_rule_call_name=>'||p_rule_call_name;
  END IF;
  IF p_rule_number IS NOT NULL
  THEN
    v_error_text := v_error_text||Fnd_Global.Local_Chr(10)||'p_rule_number=>'||p_rule_number;
  END IF;
  IF p_person_id IS NOT NULL
  THEN
    v_error_text := v_error_text||Fnd_Global.Local_Chr(10)||'p_person_id=>'||p_person_id;
  END IF;
  IF p_course_cd IS NOT NULL
  THEN
    v_error_text := v_error_text||Fnd_Global.Local_Chr(10)||'p_course_cde=>'||p_course_cd;
  END IF;
  IF p_course_version IS NOT NULL
  THEN
    v_error_text := v_error_text||Fnd_Global.Local_Chr(10)||'p_course_version=>'||p_course_version;
  END IF;
  IF p_unit_cd IS NOT NULL
  THEN
    v_error_text := v_error_text||Fnd_Global.Local_Chr(10)||'p_unit_cd=>'||p_unit_cd;
  END IF;
  IF p_unit_version IS NOT NULL
  THEN
    v_error_text := v_error_text||Fnd_Global.Local_Chr(10)||'p_unit_version=>'||p_unit_version;
  END IF;
  IF p_cal_type IS NOT NULL
  THEN
    v_error_text := v_error_text||Fnd_Global.Local_Chr(10)||'p_cal_type=>'||p_cal_type;
  END IF;
  IF p_ci_sequence_number IS NOT NULL
  THEN
    v_error_text := v_error_text||Fnd_Global.Local_Chr(10)||'p_ci_sequence_number=>'||
                          p_ci_sequence_number;
  END IF;
  IF p_param_1 IS NOT NULL
  THEN
    v_error_text := v_error_text||','||Fnd_Global.Local_Chr(10)||'p_param_1=>'''||p_param_1||'''';
  END IF;
  IF p_param_2 IS NOT NULL
  THEN
    v_error_text := v_error_text||','||Fnd_Global.Local_Chr(10)||'p_param_2=>'''||p_param_2||'''';
  END IF;
  IF p_param_3 IS NOT NULL
  THEN
    v_error_text := v_error_text||','||Fnd_Global.Local_Chr(10)||'p_param_3=>'''||p_param_3||'''';
  END IF;
  IF p_param_4 IS NOT NULL
  THEN
    v_error_text := v_error_text||','||Fnd_Global.Local_Chr(10)||'p_param_4=>'''||p_param_4||'''';
  END IF;
  IF p_param_5 IS NOT NULL
  THEN
    v_error_text := v_error_text||','||Fnd_Global.Local_Chr(10)||'p_param_5=>'''||p_param_5||'''';
  END IF;
  IF p_param_6 IS NOT NULL
  THEN
    v_error_text := v_error_text||','||Fnd_Global.Local_Chr(10)||'p_param_6=>'''||p_param_6||'''';
  END IF;
  IF p_param_7 IS NOT NULL
  THEN
    v_error_text := v_error_text||','||Fnd_Global.Local_Chr(10)||'p_param_7=>'''||p_param_7||'''';
  END IF;
  IF p_param_8 IS NOT NULL
  THEN
    v_error_text := v_error_text||','||Fnd_Global.Local_Chr(10)||'p_param_8=>'''||p_param_8||'''';
  END IF;
  IF p_param_9 IS NOT NULL
  THEN
    v_error_text := v_error_text||','||Fnd_Global.Local_Chr(10)||'p_param_9=>'''||p_param_9||'''';
  END IF;
/* more room 99/06/25
  IF p_param_10 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_10=>'''||p_param_10||'''';
  END IF;
  IF p_param_11 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_11=>'''||p_param_11||'''';
  END IF;
  IF p_param_12 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_12=>'''||p_param_12||'''';
  END IF;
  IF p_param_13 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_13=>'''||p_param_13||'''';
  END IF;
  IF p_param_14 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_14=>'''||p_param_14||'''';
  END IF;
  IF p_param_15 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_15=>'''||p_param_15||'''';
  END IF;
  IF p_param_16 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_16=>'''||p_param_16||'''';
  END IF;
  IF p_param_17 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_17=>'''||p_param_17||'''';
  END IF;
  IF p_param_18 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_18=>'''||p_param_18||'''';
  END IF;
  IF p_param_19 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_19=>'''||p_param_19||'''';
  END IF;
/* need room hrt
  IF p_param_20 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_20=>'''||p_param_20||'''';
  END IF;
  IF p_param_21 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_21=>'''||p_param_21||'''';
  END IF;
  IF p_param_22 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_22=>'''||p_param_22||'''';
  END IF;
  IF p_param_23 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_23=>'''||p_param_23||'''';
  END IF;
  IF p_param_24 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_24=>'''||p_param_24||'''';
  END IF;
  IF p_param_25 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_25=>'''||p_param_25||'''';
  END IF;
  IF p_param_26 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_26=>'''||p_param_26||'''';
  END IF;
  IF p_param_27 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_27=>'''||p_param_27||'''';
  END IF;
  IF p_param_28 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_28=>'''||p_param_28||'''';
  END IF;
  IF p_param_29 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_29=>'''||p_param_29||'''';
  END IF;
  IF p_param_30 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_30=>'''||p_param_30||'''';
  END IF;
  IF p_param_31 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_31=>'''||p_param_31||'''';
  END IF;
  IF p_param_32 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_32=>'''||p_param_32||'''';
  END IF;
  IF p_param_33 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_33=>'''||p_param_33||'''';
  END IF;
  IF p_param_34 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_34=>'''||p_param_34||'''';
  END IF;
  IF p_param_35 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_35=>'''||p_param_35||'''';
  END IF;
  IF p_param_36 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_36=>'''||p_param_36||'''';
  END IF;
  IF p_param_37 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_37=>'''||p_param_37||'''';
  END IF;
  IF p_param_38 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_38=>'''||p_param_38||'''';
  END IF;
  IF p_param_39 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_39=>'''||p_param_39||'''';
  END IF;
  IF p_param_40 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_40=>'''||p_param_40||'''';
  END IF;
  IF p_param_41 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_41=>'''||p_param_41||'''';
  END IF;
  IF p_param_42 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_42=>'''||p_param_42||'''';
  END IF;
  IF p_param_43 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_43=>'''||p_param_43||'''';
  END IF;
  IF p_param_44 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_44=>'''||p_param_44||'''';
  END IF;
  IF p_param_45 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_45=>'''||p_param_45||'''';
  END IF;
  IF p_param_46 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_46=>'''||p_param_46||'''';
  END IF;
  IF p_param_47 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_47=>'''||p_param_47||'''';
  END IF;
  IF p_param_48 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_48=>'''||p_param_48||'''';
  END IF;
  IF p_param_49 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_49=>'''||p_param_49||'''';
  END IF;
  IF p_param_50 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_50=>'''||p_param_50||'''';
  END IF;
  IF p_param_51 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_51=>'''||p_param_51||'''';
  END IF;
  IF p_param_52 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_52=>'''||p_param_52||'''';
  END IF;
  IF p_param_53 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_53=>'''||p_param_53||'''';
  END IF;
  IF p_param_54 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_54=>'''||p_param_54||'''';
  END IF;
  IF p_param_55 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_55=>'''||p_param_55||'''';
  END IF;
  IF p_param_56 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_56=>'''||p_param_56||'''';
  END IF;
  IF p_param_57 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_57=>'''||p_param_57||'''';
  END IF;
  IF p_param_58 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_58=>'''||p_param_58||'''';
  END IF;
  IF p_param_59 IS NOT NULL
  THEN
    v_error_text := v_error_text||
                          ','||Fnd_Global.Local_Chr(10)||'p_param_59=>'''||p_param_59||'''';
  END IF;
*/
EXCEPTION
WHEN OTHERS THEN
         Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION ;
END log_error;

/*
 convert plsql BOOLEAN to turing BOOLEAN ('true','false')
*/
FUNCTION b_to_t (
        p_boolean       BOOLEAN )
RETURN VARCHAR2 IS
BEGIN
        IF p_boolean
        THEN
                RETURN 'true';
        ELSE
                RETURN 'false';
        END IF;
END b_to_t;
/*
 Get unit rule number
 If no rule return NULL
*/
FUNCTION get_unit_rule(
  p_rule_call_name        IN VARCHAR2,
  p_unit_cd               IN VARCHAR2,
  p_version               IN NUMBER
) RETURN NUMBER IS
  v_rule_number NUMBER;
BEGIN
  SELECT  rul_sequence_number
  INTO    v_rule_number
  FROM    IGS_PS_UNIT_VER_RU
  WHERE   unit_cd = p_unit_cd
  AND     version_number = p_version
  AND     s_rule_call_cd = p_rule_call_name;
  RETURN v_rule_number;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END get_unit_rule;
/*
 Get course rule number
 If no rule return NULL
*/
FUNCTION get_course_rule(
  p_rule_call_name        IN VARCHAR2,
  p_course_cd             IN VARCHAR2,
  p_version               IN NUMBER
) RETURN VARCHAR2 IS
  v_rule_number NUMBER;
BEGIN
  SELECT  rul_sequence_number
  INTO    v_rule_number
  FROM    IGS_PS_VER_RU
  WHERE   course_cd = p_course_cd
  AND     version_number = p_version
  AND     s_rule_call_cd = p_rule_call_name;
  RETURN v_rule_number;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END get_course_rule;
/*
 Get unit set rule number
 If no rule return NULL
*/
FUNCTION get_us_rule(
  p_rule_call_name        IN VARCHAR2,
  p_unit_set_cd           IN VARCHAR2,
  p_version               IN NUMBER
) RETURN VARCHAR2 IS
  v_rule_number NUMBER;
BEGIN
  SELECT  rul_sequence_number
  INTO    v_rule_number
  FROM    IGS_EN_UNIT_SET_RULE
  WHERE   unit_set_cd = p_unit_set_cd
  AND     version_number = p_version
  AND     s_rule_call_cd = p_rule_call_name;
  RETURN v_rule_number;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END get_us_rule;
/*
 Get fee disbursement formula rule number
 If no rule return NULL
 History
 who       when         what
*/
FUNCTION get_fdfr_rule (
  p_rule_call_name                IN VARCHAR2,
  p_fee_type                      IN IGS_FI_F_TYP_CA_INST_ALL.fee_type%TYPE,
  p_fee_cal_type                  IN IGS_FI_F_TYP_CA_INST_ALL.fee_cal_type%TYPE,
  p_fee_ci_sequence_number        IN IGS_FI_F_TYP_CA_INST_ALL.fee_ci_sequence_number%TYPE,
  p_formula_number                IN NUMBER
)
/*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  smvk           02-Sep-2002     Modified the IN parameters of type IGS_FI_FEE_DSB_FM_RU  as
  ||                                 parameters of type IGS_FI_F_TYP_CA_INST_ALL as IGS_FI_FEE_DSB_FM_RU is getting obsolete
  ||                                 IGS_FI_FEE_DSB_FM_RU.FORMULA_NUMBER is modified as Number.
  ||                                 As per SFCR005_Cleanup_Build TD (Enhancement Bug # 2531390)
  ||  smvk           28-Aug-2002     Removed the existing code and the function is modified to return NULL always.
  ||                                 As per SFCR005_Cleanup_Build TD (Enhancement Bug # 2531390)
  ----------------------------------------------------------------------------*/
RETURN VARCHAR2 IS
BEGIN
 /* code has been removed and this function always returns null, as per SFCR005_Cleanup_Build TD (Enhancement Bug # 2531390) */
 RETURN NULL;
END get_fdfr_rule;
/*
 Get course stage rule number
 if no rule return NULL
*/
FUNCTION get_crs_stg_rule(
  p_rule_call_name                IN VARCHAR2,
  p_course_cd             IN VARCHAR2,
  p_course_version                IN NUMBER,
  p_cst_sequence_number   IN NUMBER
) RETURN VARCHAR2 IS
  v_rule_number NUMBER;
BEGIN
  SELECT  rul_sequence_number
  INTO    v_rule_number
  FROM    IGS_PS_STAGE_RU
  WHERE   course_cd = p_course_cd
  AND     version_number = p_course_version
  AND     cst_sequence_number = p_cst_sequence_number
  AND     s_rule_call_cd = p_rule_call_name;
  RETURN v_rule_number;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END get_crs_stg_rule;
/*
 get the called rule number using called rule name
*/
FUNCTION get_called_rule (
  p_called_rule_cd        IGS_RU_CALL_RULE.called_rule_cd%TYPE
) RETURN NUMBER IS
BEGIN
  DECLARE
    v_rule_number   IGS_RU_RULE.sequence_number%TYPE;
  BEGIN
    SELECT  nr_rul_sequence_number
    INTO    v_rule_number
    FROM    IGS_RU_CALL_RULE
    WHERE   called_rule_cd = p_called_rule_cd;
    RETURN v_rule_number;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      log_error('get_called_rule', 'Invalid callable rule ('||p_called_rule_cd||')');
  END;
END get_called_rule;
/*
 Do course stage rule
*/
FUNCTION do_course_stage (
  p_course_stage_type     VARCHAR2
) RETURN VARCHAR2 IS
  v_cst_sequence_number   IGS_PS_STAGE.sequence_number%TYPE;
BEGIN
/*
 get sequence number for stage type
*/
  SELECT  cst.sequence_number
  INTO    v_cst_sequence_number
  FROM    IGS_PS_STAGE cst
  WHERE   cst.course_cd = p_course_cd
  AND     cst.version_number = p_course_version
  AND     cst.course_stage_type = p_course_stage_type;
/*
  get alternative stage completion method
*/
  RETURN igs_pr_gen_002.prgp_get_stg_comp (
           p_person_id,
           p_course_cd,
           p_course_version,
           v_cst_sequence_number
         );
EXCEPTION
  WHEN NO_DATA_FOUND THEN
/*
  stage type does not exist for course.version, default is 'Y'
*/
    RETURN 'Y';
END do_course_stage;
/*
NUMERIC FUNCTIONS
*/
FUNCTION divide (
        p_num1  NUMBER,
        p_num2  NUMBER )
RETURN NUMBER IS
BEGIN
        IF p_num2 = 0
        THEN
/*
  divide by zero
*/
                RETURN NULL;
        ELSE
                RETURN p_num1/p_num2;
        END IF;
END divide;


FUNCTION max_func (
        p_num1  NUMBER,
        p_num2  NUMBER )
RETURN NUMBER IS
BEGIN
        IF p_num1 > p_num2
        THEN
                RETURN p_num1;
        ELSE
                RETURN p_num2;
        END IF;
END max_func;

FUNCTION min_func (
        p_num1  NUMBER,
        p_num2  NUMBER )
RETURN NUMBER IS
BEGIN
        IF p_num1 < p_num2
        THEN
                RETURN p_num1;
        ELSE
                RETURN p_num2;
        END IF;
END min_func;

/*
 TARGET UNIT ATTRIBUTE FUNCTIONS
 unit version attributes
*/
FUNCTION uv_attribute (
        p_attribute     VARCHAR2,
        p_tds           r_tds )
RETURN VARCHAR2 IS
        v_repeatable_ind        IGS_PS_UNIT_VER.repeatable_ind%TYPE;
BEGIN
        SELECT  repeatable_ind
        INTO    v_repeatable_ind
        FROM    IGS_PS_UNIT_VER
        WHERE   unit_cd = p_tds.unit_cd
        AND     version_number = p_tds.unit_version;
        IF p_attribute = 'rep_ind'
        THEN
                RETURN v_repeatable_ind;
        ELSE
                log_error('uv_attribute',
                        'Invalid attribute ('||p_attribute||')');
        END IF;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
                RETURN NULL;
END uv_attribute;
/*
 duplicates within a set (by unit_cd)
*/
FUNCTION duplicate_count (
        p_tds   IN r_tds )
RETURN NUMBER IS
        v_member        BINARY_INTEGER;
        v_count         NUMBER := 0;
BEGIN
        v_member := gv_set(p_tds.set_number).first;
        LOOP
/*
                 check if last (must do check for null)
*/
                IF v_member IS NULL
                THEN
                        EXIT;
                END IF;
                IF gv_member(v_member).f1 = p_tds.unit_cd
                THEN
                        v_count := v_count + 1;
                END IF;
/*
                 next  member
*/
                v_member := gv_member(v_member).next;
        END LOOP;
        RETURN v_count;
END duplicate_count;
/*
 unit version credit points
*/
FUNCTION uv_credit_points (
        p_unit_cd       IGS_PS_UNIT_VER.unit_cd%TYPE,
        p_unit_version  IGS_PS_UNIT_VER.version_number%TYPE )
RETURN NUMBER IS
        v_achievable_credit_points      IGS_PS_UNIT_VER.achievable_credit_points%TYPE;
BEGIN
        SELECT  NVL(achievable_credit_points,enrolled_credit_points)
        INTO    v_achievable_credit_points
        FROM    IGS_PS_UNIT_VER
        WHERE   unit_cd = p_unit_cd
        AND     version_number = p_unit_version;
        RETURN  v_achievable_credit_points;
END uv_credit_points;

FUNCTION us_uv_credit_points( p_uoo_id IN NUMBER)
RETURN NUMBER IS
       l_n_credit_points IGS_PS_UNIT_VER.achievable_credit_points%TYPE;
BEGIN
      SELECT NVL(cps.achievable_credit_points,NVL(uv.achievable_credit_points,NVL(cps.enrolled_credit_points,uv.enrolled_credit_points)))
      INTO  l_n_credit_points
      FROM  IGS_PS_UNIT_VER uv,
            IGS_PS_UNIT_OFR_OPT uoo,
            IGS_PS_USEC_CPS  cps
     WHERE  uoo.uoo_id=cps.uoo_id(+) AND
            uoo.uoo_id=p_uoo_id  AND
            uoo.unit_cd = uv.unit_cd  AND
            uoo.version_number= uv.version_number;
     RETURN l_n_credit_points;
END us_uv_credit_points;


/*
 student unit attempt credit points achievable
*/
FUNCTION sua_credit_points (
        p_member_index  BINARY_INTEGER )
RETURN NUMBER IS
        v_unit_attempt_status           IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE;
        v_override_achievable_cp        IGS_EN_SU_ATTEMPT.override_achievable_cp%TYPE;
BEGIN
        -- added logic to obtain the advance standing credit points when the coo_id is null , bug#4283221

        -- added logic to obtain the advance standing credit points when the coo_id is null , bug#4283221
        -- Modified the below query to get the the sum of the credit points of all the records fetched.
        -- This is done because we should consider the credit points of all the advanced standing units against the same unit
        -- for bug# 4480311
        IF gv_member(p_member_index).f5 IS NULL THEN
              SELECT SUM(nvl(achievable_credit_points,0))
              INTO v_override_achievable_cp
              FROM       IGS_AV_STND_UNIT
              WHERE as_course_cd = p_course_cd
              AND person_id = p_person_id
              AND unit_cd = gv_member(p_member_index).f1
              AND  version_number = gv_member(p_member_index).f2
              AND s_adv_stnd_granting_status IN ('APPROVED','GRANTED')
              AND s_adv_stnd_recognition_type = 'CREDIT'
              AND (igs_av_val_asu.granted_adv_standing(person_id,as_course_cd,as_version_number,unit_cd,version_number,'BOTH',NULL) ='TRUE');


              RETURN  v_override_achievable_cp;

        ELSE
            SELECT  unit_attempt_status,
                override_achievable_cp
            INTO    v_unit_attempt_status,
                v_override_achievable_cp
            FROM    IGS_EN_SU_ATTEMPT
            WHERE   person_id = p_person_id
            AND     course_cd = p_course_cd
            AND     uoo_id = gv_member(p_member_index).f5;
            END IF;

        IF (v_override_achievable_cp IS NOT NULL)
        THEN
                RETURN  v_override_achievable_cp;
        ELSE
                RETURN us_uv_credit_points(gv_member(p_member_index).f5);
        END IF;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
/*
                 assume no sua record!
*/
                RETURN us_uv_credit_points(gv_member(p_member_index).f5);
END sua_credit_points;
/*
 student unit attempt status/result/grade/mark of target unit
*/
FUNCTION sua_attribute (
        p_attribute     IN VARCHAR2,
        p_member_index  IN BINARY_INTEGER,
        p_final_ind IN VARCHAR2)
RETURN VARCHAR2 IS
        v_unit_attempt_status   IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE;
        v_override_achievable_cp IGS_EN_SU_ATTEMPT.override_achievable_cp%TYPE;
        v_outcome_dt            IGS_AS_SU_STMPTOUT.outcome_dt%TYPE;
        v_grading_schema_cd     IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
        v_gs_version_number     IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
        v_grade                 IGS_AS_GRD_SCH_GRADE.grade%TYPE;
        v_mark                  IGS_AS_SU_STMPTOUT.mark%TYPE;
        v_original_course_cd    IGS_EN_SU_ATTEMPT.course_cd%TYPE;
        v_result                VARCHAR2(30);
BEGIN
        SELECT  unit_attempt_status,
                override_achievable_cp
        INTO    v_unit_attempt_status,
                v_override_achievable_cp
        FROM    IGS_EN_SU_ATTEMPT
        WHERE   person_id = p_person_id
        AND     course_cd = p_course_cd
        AND     uoo_id = gv_member(p_member_index).f5;

        IF p_attribute = 'status'
        THEN
                RETURN v_unit_attempt_status;
        END IF;
        v_result := IGS_AS_GEN_003.assp_get_sua_outcome (
                        p_person_id,
                        p_course_cd,
                        gv_member(p_member_index).f1,
                        gv_member(p_member_index).f3,
                        gv_member(p_member_index).f4,
                        v_unit_attempt_status,
                        p_final_ind, /*  finalised indicator (make parameter ??) */
                        v_outcome_dt,
                        v_grading_schema_cd,
                        v_gs_version_number,
                        v_grade,
                        v_mark,
                        v_original_course_cd,
                        gv_member(p_member_index).f5,
--added by LKAKI---
                        'N');
        IF p_attribute = 'result'
        THEN
                RETURN v_result;
        ELSIF p_attribute = 'grd_sch'
        THEN
                RETURN v_grading_schema_cd;
        ELSIF p_attribute = 'grade'
        THEN
                RETURN v_grade;
        ELSIF p_attribute = 'mark'
        THEN
                RETURN v_mark;
        ELSIF p_attribute = 'outcome_dt'
        THEN
                RETURN v_outcome_dt;
        ELSIF p_attribute = 'pass_conceded'
        THEN
                RETURN b_to_t(igs_as_gen_002.assp_get_gsg_cncd(v_grading_schema_cd,
                                        v_gs_version_number,
                                        v_grade) = 'Y');
        ELSE
                log_error('sua_attribute',
                        'Invalid attribute ('||p_attribute||')');
        END IF;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
                RETURN NULL;
END sua_attribute;


-- smaddali added this function for the new turin function added for bug#4304688

-- modified the query which gets grading schema code and grade to get grading schema code
-- and grade of the least ranked record (highest grade) for bug# 4580311
-- This query may return multiple records but we should consider only the least ranked record.

FUNCTION adv_attribute (p_attribute IN VARCHAR2, p_member_index  IN BINARY_INTEGER)
RETURN VARCHAR2 IS
        v_grading_schema_cd     IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
    v_grade                 IGS_AS_GRD_SCH_GRADE.grade%TYPE;

    CURSOR c_grad_sch IS
    SELECT av.grading_schema_cd, av.grade
    FROM igs_av_stnd_unit  av , igs_as_grd_sch_grade grad
    WHERE av.as_course_cd = p_course_cd
    AND av.person_id = p_person_id
    AND av.unit_cd = gv_member(p_member_index).f1
    AND av.version_number = gv_member(p_member_index).f2
    AND av.s_adv_stnd_granting_status IN ('APPROVED','GRANTED')
    AND av.s_adv_stnd_recognition_type = 'CREDIT'
    AND (igs_av_val_asu.granted_adv_standing(av.person_id,av.as_course_cd,av.as_version_number,av.unit_cd,av.version_number,'BOTH',NULL) ='TRUE')
    AND  grad.grading_schema_cd = av.grading_schema_cd
    AND  grad.version_number  = av.grd_sch_version_number
    AND  grad.grade = av.grade
    ORDER BY grad.rank ASC;
BEGIN
  OPEN  c_grad_sch;
  FETCH c_grad_sch INTO v_grading_schema_cd,v_grade;
  CLOSE c_grad_sch;

  IF p_attribute = 'grd_sch' THEN
       RETURN v_grading_schema_cd;
  ELSIF p_attribute = 'grade'  THEN
       RETURN v_grade;
  END IF;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                RETURN NULL;
END adv_attribute;




/*
 determine if target unit satisfies the attribute within the given set
 there can be more than one 'last' unit (same period/same credit points)
 all though it trys to resolve cp's by selecting latest (for duplicates)
*/
FUNCTION sua_select_unique(
        p_attribute     IN VARCHAR2,
        p_member_index  IN BINARY_INTEGER,
        p_set1          IN NUMBER )
RETURN VARCHAR2 IS
/*
  'true' or 'false'
*/
        v_member                BINARY_INTEGER;
        v_target_cp             NUMBER;
        v_duplicate_cp  NUMBER;
        v_rel_time              VARCHAR2(30);
BEGIN
        IF p_attribute = 'maxcp' OR p_attribute = 'mincp'
        THEN
/*
                 cp of target unit
*/
                v_target_cp := sua_credit_points(p_member_index);
        ELSIF p_attribute <> 'first' AND p_attribute <> 'last'
        THEN
                log_error('sua_select_unique',
                        'Invalid attribute ('||p_attribute||')');
        END IF;
/*
         for all members within given set
*/
        v_member := gv_set(p_set1).first;
        LOOP
/*
                 check if last (must do check for null)
*/
                IF v_member IS NULL
                THEN
                        EXIT;
                END IF;
                v_rel_time := IGS_CA_GEN_001.CALP_GET_RLTV_TIME(gv_member(v_member).f3,
                                        gv_member(v_member).f4,
                                        gv_member(p_member_index).f3,
                                        gv_member(p_member_index).f4);
                IF v_rel_time = 'AFTER'
                THEN
/*
                         target unit is after, therefore cannot be first
*/
                        IF p_attribute = 'first'
                        THEN
                                RETURN 'false';
                        END IF;
                ELSIF v_rel_time = 'BEFORE'
                THEN
/*
                         target unit is before, therefore cannot be last
*/
                        IF p_attribute = 'last'
                        THEN
                                RETURN 'false';
                        END IF;
                END IF;
                IF p_attribute = 'maxcp' OR p_attribute = 'mincp'
                THEN
/*
                         cp of unit
*/
                        v_duplicate_cp := sua_credit_points(v_member);
                        IF v_duplicate_cp > v_target_cp
                        THEN
/*
                                 target unit not highest cp, therefore cannot be maxcp
*/
                                IF p_attribute = 'maxcp'
                                THEN
                                        RETURN 'false';
                                END IF;
                        ELSIF v_duplicate_cp < v_target_cp
                        THEN
/*
                                 target unit not lowest cp, therefore cannot be mincp
*/
                                IF p_attribute = 'mincp'
                                THEN
                                        RETURN 'false';
                                END IF;
                        ELSIF v_rel_time = 'BEFORE'
                        THEN
/*
                                 target unit with equal cp but not last (default)
*/
                                RETURN 'false';
                        END IF;
                END IF;
/*
                 next member
*/
                v_member := gv_member(v_member).next;
        END LOOP;
/*
         target unit must be first/last/maxcp/mincp
*/
        RETURN 'true';
END sua_select_unique;
/*

 compare grades according to comparitor string operator
 assumes the highest rank has the lowest numerical value

*/
FUNCTION sua_relative_grade (
        p_lhs_gs        IN VARCHAR2,
        p_lhs_grade     IN VARCHAR2,
        p_comparitor    IN VARCHAR2,
        p_rhs_gs        IN VARCHAR2,
        p_rhs_grade     IN VARCHAR2,
        p_tds           IN r_tds )
RETURN VARCHAR2 IS
/*
 'true' or 'false'
*/
        v_lhs_rank                      IGS_AS_GRD_SCH_GRADE.rank%TYPE;
        v_rhs_rank                      IGS_AS_GRD_SCH_GRADE.rank%TYPE;
        v_location_cd           IGS_EN_SU_ATTEMPT.location_cd%TYPE;
        v_unit_class            IGS_EN_SU_ATTEMPT.unit_class%TYPE;
        v_grading_schema                IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
        v_gs_version_number     IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
BEGIN
/*
         if grading schema not same then only <> is true
*/
        IF p_lhs_gs <> p_rhs_gs
        THEN
                IF p_comparitor = '<>'
                THEN
                        RETURN 'true';
                END IF;
                RETURN 'false';
        END IF;
/*
         get gs_version_number
*/
        SELECT  location_cd,
                unit_class
        INTO    v_location_cd,
                v_unit_class
        FROM    IGS_EN_SU_ATTEMPT
        WHERE   person_id = p_person_id
        AND     course_cd = p_course_cd
        AND     uoo_id = p_tds.uoo_id;
        IF IGS_AS_GEN_003.ASSP_GET_SUA_GS(p_person_id,
                        p_course_cd,
                        p_tds.unit_cd,
                        p_tds.unit_version,
                        p_tds.cal_type,
                        p_tds.ci_sequence_number,
                        v_location_cd,
                        v_unit_class,
                        v_grading_schema,
                        v_gs_version_number ) = NULL
        THEN
                log_error('sua_relative_grade',
                        'IGS_AS_GEN_003.ASSP_GET_SUA_GS');
        END IF;
/*
         grading_schema must be same???
*/
        IF v_grading_schema <> p_lhs_gs
        THEN
                IF p_comparitor = '<>'
                THEN
                        RETURN 'true';
                END IF;
                RETURN 'false';
        END IF;
/*
         determine rank
*/
        BEGIN
                SELECT  rank
                INTO    v_lhs_rank
                FROM    IGS_AS_GRD_SCH_GRADE
                WHERE   grading_schema_cd = v_grading_schema
                AND     version_number  = v_gs_version_number
                AND     grade = p_lhs_grade;
                SELECT  rank
                INTO    v_rhs_rank
                FROM    IGS_AS_GRD_SCH_GRADE
                WHERE   grading_schema_cd = v_grading_schema
                AND     version_number  = v_gs_version_number
                AND     grade = p_rhs_grade;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        RETURN 'false';
        END;
/*
         Note the higher the rank the lower the grade
*/
        IF p_comparitor = '<'
        THEN
                IF v_lhs_rank > v_rhs_rank
                THEN
                        RETURN 'true';
                END IF;
        ELSIF p_comparitor = '<='
        THEN
                IF v_lhs_rank >= v_rhs_rank
                THEN
                        RETURN 'true';
                END IF;
        ELSIF p_comparitor = '='
        THEN
                IF v_lhs_rank = v_rhs_rank
                THEN
                        RETURN 'true';
                END IF;
        ELSIF p_comparitor = '<>'
        THEN
                IF v_lhs_rank <> v_rhs_rank
                THEN
                        RETURN 'true';
                END IF;
        ELSIF p_comparitor = '>='
        THEN
                IF v_lhs_rank <= v_rhs_rank
                THEN
                        RETURN 'true';
                END IF;
        ELSIF p_comparitor = '>'
        THEN
                IF v_lhs_rank < v_rhs_rank
                THEN
                        RETURN 'true';
                END IF;
        ELSE
                log_error('sua_relative_grade',
                        'Invalid comparitor ('||p_comparitor||')');
        END IF;
        RETURN 'false';
END sua_relative_grade;


-- smaddali added this function for the new turin function added for bug#4304688

-- modified the query which gets grading schema code and version number to get grading schema code
-- and grade of the least ranked record (highest grade) for bug# 4580311
-- This query may return multiple records but we should consider only the least ranked record.

FUNCTION adv_relative_grade (
        p_lhs_gs        IN VARCHAR2,
        p_lhs_grade     IN VARCHAR2,
        p_comparitor    IN VARCHAR2,
        p_rhs_gs        IN VARCHAR2,
        p_rhs_grade     IN VARCHAR2,
        p_tds           IN r_tds )
RETURN VARCHAR2 IS
/*
 'true' or 'false'
*/
        v_lhs_rank              IGS_AS_GRD_SCH_GRADE.rank%TYPE;
        v_rhs_rank              IGS_AS_GRD_SCH_GRADE.rank%TYPE;
        v_location_cd           IGS_EN_SU_ATTEMPT.location_cd%TYPE;
        v_unit_class            IGS_EN_SU_ATTEMPT.unit_class%TYPE;
        v_grading_schema        IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
        v_gs_version_number     IGS_AS_GRD_SCH_GRADE.version_number%TYPE;

        CURSOR c_grad_sch IS
        SELECT av.grading_schema_cd, av.grd_sch_version_number
        FROM 	 IGS_AV_STND_UNIT  av , igs_as_grd_sch_grade grad
        WHERE av.as_course_cd = p_course_cd
        AND av.person_id = p_person_id
        AND av.unit_cd = p_tds.unit_cd
        AND av.version_number = p_tds.unit_version
        AND av.s_adv_stnd_granting_status IN ('APPROVED','GRANTED')
        AND av.s_adv_stnd_recognition_type = 'CREDIT'
        AND (igs_av_val_asu.granted_adv_standing(av.person_id,av.as_course_cd,av.as_version_number,av.unit_cd,av.version_number,'BOTH',NULL) ='TRUE')
        AND  grad.grading_schema_cd = av.grading_schema_cd
        AND  grad.version_number  = av.grd_sch_version_number
        AND  grad.grade = av.grade
        ORDER BY grad.rank ASC;
BEGIN
/*
         if grading schema not same then only <> is true
*/
        IF p_lhs_gs <> p_rhs_gs   THEN
                IF p_comparitor = '<>'
                THEN
                        RETURN 'true';
                END IF;
                RETURN 'false';
        END IF;
/*
         get gs_version_number
*/
        BEGIN
            OPEN c_grad_sch;
            FETCH c_grad_sch INTO v_grading_schema, v_gs_version_number;
            CLOSE c_grad_sch;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        RETURN 'false';
        END ;
/*
         grading_schema must be same???
*/
        IF v_grading_schema <> p_lhs_gs
        THEN
                IF p_comparitor = '<>'
                THEN
                        RETURN 'true';
                END IF;
                RETURN 'false';
        END IF;
/*
         determine rank
*/
        BEGIN
                SELECT  rank
                INTO    v_lhs_rank
                FROM    IGS_AS_GRD_SCH_GRADE
                WHERE   grading_schema_cd = v_grading_schema
                AND     version_number  = v_gs_version_number
                AND     grade = p_lhs_grade;
                SELECT  rank
                INTO    v_rhs_rank
                FROM    IGS_AS_GRD_SCH_GRADE
                WHERE   grading_schema_cd = v_grading_schema
                AND     version_number  = v_gs_version_number
                AND     grade = p_rhs_grade;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        RETURN 'false';
        END;
/*
         Note the higher the rank the lower the grade
*/
        IF p_comparitor = '<'
        THEN
                IF v_lhs_rank > v_rhs_rank
                THEN
                        RETURN 'true';
                END IF;
        ELSIF p_comparitor = '<='
        THEN
                IF v_lhs_rank >= v_rhs_rank
                THEN
                        RETURN 'true';
                END IF;
        ELSIF p_comparitor = '='
        THEN
                IF v_lhs_rank = v_rhs_rank
                THEN
                        RETURN 'true';
                END IF;
        ELSIF p_comparitor = '<>'
        THEN
                IF v_lhs_rank <> v_rhs_rank
                THEN
                        RETURN 'true';
                END IF;
        ELSIF p_comparitor = '>='
        THEN
                IF v_lhs_rank <= v_rhs_rank
                THEN

                        RETURN 'true';
                END IF;
        ELSIF p_comparitor = '>'
        THEN
                IF v_lhs_rank < v_rhs_rank
                THEN
                        RETURN 'true';
                END IF;
        ELSE
                log_error('adv_relative_grade',
                        'Invalid comparitor ('||p_comparitor||')');
        END IF;
        RETURN 'false';
END adv_relative_grade;


/*

 UNIT SET ATTEMPT ATTRIBUTES

 get unit set status/psi for target unit set

*/
FUNCTION susa_attribute (
        p_attribute     IN VARCHAR2,
        p_tds           IN r_tds )
RETURN VARCHAR2 IS
        v_student_confirmed_ind IGS_AS_SU_SETATMPT.student_confirmed_ind%TYPE;
        v_end_dt                IGS_AS_SU_SETATMPT.end_dt%TYPE;
        v_rqrmnts_complete_ind  IGS_AS_SU_SETATMPT.rqrmnts_complete_ind%TYPE;
        v_primary_set_ind       IGS_AS_SU_SETATMPT.primary_set_ind%TYPE;
BEGIN
        SELECT  student_confirmed_ind,
                end_dt,
                rqrmnts_complete_ind,
                primary_set_ind
        INTO    v_student_confirmed_ind,
                v_end_dt,
                v_rqrmnts_complete_ind,
                v_primary_set_ind
        FROM    IGS_AS_SU_SETATMPT
        WHERE   person_id = p_person_id
        AND     course_cd = p_course_cd
        AND     unit_set_cd = p_tds.unit_cd
        AND     us_version_number = p_tds.unit_version
        AND     sequence_number = p_tds.cal_type;
        IF p_attribute = 'status'
        THEN
                IF v_student_confirmed_ind = 'N'
                THEN
                        RETURN 'UNCONFIRMED';
                ELSIF v_student_confirmed_ind = 'Y'
                AND   v_end_dt IS NULL
                AND   v_rqrmnts_complete_ind = 'N'
                THEN
                        RETURN 'SELECTED';
                ELSIF v_student_confirmed_ind = 'Y'
                AND   v_end_dt IS NOT NULL
                THEN
                        RETURN 'ENDED';
                ELSIF v_rqrmnts_complete_ind = 'Y'
                THEN
                        RETURN 'COMPLETE';
                END IF;
                RETURN NULL;
        ELSIF p_attribute = 'psi'
        THEN
                RETURN b_to_t(v_primary_set_ind = 'Y');
        END IF;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
                RETURN NULL;
END susa_attribute;
/*

 US ATTRIBUTES

 return unit set attribute value of target unit set

*/
FUNCTION us_attribute (
        p_attribute     IN VARCHAR2,
        p_tds           IN r_tds )
RETURN VARCHAR2 IS
        v_unit_set_cat  IGS_EN_UNIT_SET.unit_set_cat%TYPE;
BEGIN
        SELECT  unit_set_cat
        INTO    v_unit_set_cat
        FROM    IGS_EN_UNIT_SET
        WHERE   unit_set_cd = p_tds.unit_cd
        AND     version_number = p_tds.unit_version;
        IF p_attribute = 'usc'
        THEN
                RETURN v_unit_set_cat;
        END IF;
END us_attribute;
/*

 ASUL ATTRIBUTES

 return advanced standing unit level attribute value of a target unit

*/

-- Modified the query which gets credit points to get the sum of credit points of
-- all the records and added where clause s_adv_stnd_granting_status IN ('GRANTED').
FUNCTION asul_attribute (
        p_attribute     IN VARCHAR2,
        p_tds           IN r_tds )
RETURN VARCHAR2 IS
        v_credit_points IGS_AV_STND_UNIT_LVL.credit_points%TYPE;
BEGIN
        IF p_attribute = 'level'
        THEN
                RETURN p_tds.unit_version;
        END IF;
        SELECT  SUM(credit_points)
        INTO    v_credit_points
        FROM    IGS_AV_STND_UNIT_LVL
        WHERE   person_id = p_person_id
        AND     as_course_cd = p_course_cd
        AND     s_adv_stnd_granting_status IN ('GRANTED')
/*
         AND    as_version_number = p_course_version
*/
        AND     s_adv_stnd_type = p_tds.unit_cd
        AND     unit_level = p_tds.unit_version
        AND     crs_group_ind = p_tds.cal_type
        AND     exemption_institution_cd = p_tds.ci_sequence_number;
        IF p_attribute = 'credit_points'
        THEN
                RETURN v_credit_points;
        ELSE
                log_error('asul_attribute',
                        'Invalid attribute ('||p_attribute||')');
        END IF;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
                RETURN NULL;
END asul_attribute;
/*

 get WAM weighting for target unit

*/
FUNCTION wam_weighting (
        p_member_index  IN BINARY_INTEGER )
RETURN NUMBER IS
        v_wam_weighting IGS_PS_UNIT_LEVEL.wam_weighting%TYPE;
        v_unit_level    IGS_PS_UNIT_LEVEL.unit_level%TYPE;
BEGIN
        IF p_course_version IS NULL
        THEN
                RETURN NULL;
        END IF;
/*
         determine unit level
*/
        v_unit_level := IGS_PS_GEN_002.CRSP_GET_UN_LVL(gv_member(p_member_index).f1,
                                        gv_member(p_member_index).f2,
                                        p_course_cd,
                                        p_course_version);
        BEGIN
                SELECT  wam_weighting
                INTO    v_wam_weighting
                FROM    IGS_PS_UNIT_LVL
                WHERE   unit_cd = gv_member(p_member_index).f1
                AND     version_number = gv_member(p_member_index).f2
                AND     course_cd = p_course_cd
                AND     version_number = p_course_version
                AND     unit_level = v_unit_level;
                IF v_wam_weighting IS NOT NULL
                THEN
/*
                         course_unit_level overrides unit_level
*/
                        RETURN v_wam_weighting;
                END IF;
                EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                        NULL;
        END;
        BEGIN
                SELECT  wam_weighting
                INTO    v_wam_weighting
                FROM    IGS_PS_UNIT_LEVEL
                WHERE   unit_level = v_unit_level;
                IF v_wam_weighting IS NOT NULL
                THEN
                        RETURN v_wam_weighting;
                END IF;
                EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                        NULL;
        END;
/*
         default value is 1
*/
        RETURN 1;
END wam_weighting;
/*

 THE MESSAGING SYSTEM


 get message variable

*/
FUNCTION get_variable (
        p_variable_no   NUMBER )
RETURN VARCHAR2 IS
BEGIN
        RETURN gt_variable(p_variable_no);
        EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
                log_error('get_variable',
                        'Undeclared variable:'||p_variable_no);
END get_variable;

/*

 push message to message stack

*/
PROCEDURE push_message (
        p_message       VARCHAR2 )
IS
BEGIN
        gv_message_stack_index := gv_message_stack_index + 1;
        gt_message_stack(gv_message_stack_index) := p_message;
END push_message;
/*

 pop from message stack

*/
FUNCTION pop_message
RETURN VARCHAR2 IS
BEGIN
        gv_message_stack_index := gv_message_stack_index - 1;
        RETURN gt_message_stack(gv_message_stack_index + 1);
        EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
                RETURN 'ERROR:EMPTY MESSAGE STACK';
END pop_message;
/*

 return all messages on the stack
 default is return all messages on stack (one message per line)

*/
FUNCTION get_message
RETURN VARCHAR2 IS
        v_message       IGS_RU_ITEM.value%TYPE;
        v_pop_message   IGS_RU_ITEM.value%TYPE;
BEGIN
/*
         there will be one or more messages on the stack
*/
        WHILE gv_message_stack_index > 0
        LOOP
                v_pop_message := pop_message;
                IF v_pop_message IS NOT NULL
                THEN
                        IF LENGTH(v_message) > 0
                        THEN
                                v_message := v_message||Fnd_Global.Local_Chr(10);
                        END IF;
                        v_message := v_message||v_pop_message;
                END IF;
        END LOOP;
        RETURN v_message;
END get_message;
/*

 get and do message rule

*/
PROCEDURE do_message (
        p_rule_number   IGS_RU_RULE.sequence_number%TYPE,
        p_rule_outcome  IGS_RU_ITEM.value%TYPE,
        p_tds           r_tds )
IS
        v_message_rule  IGS_RU_RULE.sequence_number%TYPE;
        v_tds           r_tds;
BEGIN
/*
         get message rule number
*/
        SELECT  message_rule
        INTO    v_message_rule
        FROM    IGS_RU_NAMED_RULE
        WHERE   rul_sequence_number = p_rule_number;
        IF v_message_rule IS NOT NULL
        THEN
                v_tds := p_tds;
                v_tds.rule_outcome := p_rule_outcome;
                push_message(turing(v_message_rule,v_tds));
        END IF;
        EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
                null;
END do_message;
/*

 return set string

*/
FUNCTION display_set (
        p_set_number    IN BINARY_INTEGER)
RETURN VARCHAR2 IS
  ------------------------------------------------------------------
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --smvk        29-Nov-2004     File.Sql.35 warning fix.
  --smadathi    07-JUN-2001     The length of the variable v_prev_f1 changed to varchar2(30) from varchar2(10) .
  -------------------------------------------------------------------
        v_member        BINARY_INTEGER;
        v_prev_f1       VARCHAR2(30) ;
        v_more  BOOLEAN;
        v_set           IGS_RU_ITEM.value%TYPE;
BEGIN
        v_prev_f1 := '@$%!*(|' ;
        v_more := FALSE;
        v_set := '{';
        v_member := gv_set(p_set_number).first;
        LOOP
/*
                 check if last (must do check for null)
*/
                IF v_member IS NULL
                THEN
/*
                         yep, last member
*/
                        EXIT;
                END IF;
                IF gv_member(v_member).f1 <> v_prev_f1
                THEN
                        IF v_more
                        THEN
                                v_set := v_set||', ';
                        END IF;
                        v_set := v_set||gv_member(v_member).f1;
                        v_more := TRUE;
                        v_prev_f1 := gv_member(v_member).f1;
                END IF;
/*
                 next member
*/
                v_member := gv_member(v_member).next;
        END LOOP;
        v_set := v_set||'}';
        RETURN v_set;
END display_set;
/*

 STACK FUNCTIONS

 Push value to stack

*/
PROCEDURE push(
        p_value  IN VARCHAR2 )
IS
BEGIN
        gv_stack_index := gv_stack_index + 1;

        gt_rule_stack(gv_stack_index) := p_value;
END push;
/*

 Return value from stack

*/
FUNCTION pop
RETURN VARCHAR2 IS
BEGIN
        gv_stack_index := gv_stack_index - 1;
        RETURN gt_rule_stack(gv_stack_index + 1);
        EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
                log_error('pop',
                        'Stack empty');
END pop;
/*

 push parameters to stack for sub-function call

*/
PROCEDURE push_params (
        p_start_stack   IN NUMBER,
        p_no_parameters IN NUMBER)
IS
BEGIN
        FOR v_params IN 1 .. p_no_parameters
        LOOP
                push(gt_rule_stack(p_start_stack - p_no_parameters + v_params));
        END LOOP;
END push_params;
/*

 get parameter from stack

*/
FUNCTION get_parameter (
        p_parameter_no  NUMBER )
RETURN VARCHAR2 IS
BEGIN
        RETURN gt_rule_stack(p_parameter_no);
        EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
                log_error('get_parameter',
                        'Invalid parameter:'||p_parameter_no);
END get_parameter;
/*
 Clean up stack after function call
*/
PROCEDURE clean_up_stack (
        p_no_parameters IN NUMBER )
IS
BEGIN
/*
         reset index
*/
        gv_stack_index := gv_stack_index -  p_no_parameters;
END clean_up_stack;
/*

 COMPARISON FUNCTIONS

 equal function

*/
FUNCTION eq(
        p_val1  IN VARCHAR2,
        p_val2  IN VARCHAR2 )
RETURN VARCHAR2 IS
BEGIN
        IF p_val1 IS NULL AND p_val2 IS NULL
        THEN
                RETURN ('true');
        END IF;
        IF IGS_GE_NUMBER.TO_NUM(p_val1) = IGS_GE_NUMBER.TO_NUM(p_val2)
        THEN
                RETURN ('true');
        ELSE
                RETURN ('false');
        END IF;
        EXCEPTION
        WHEN VALUE_ERROR
        THEN
                IF RTRIM(p_val1) = RTRIM(p_val2)
                THEN
                        RETURN ('true');
                ELSE
                        RETURN ('false');
                END IF;
END eq;
/*

 not equal function

*/
FUNCTION neq(
        p_val1  IN VARCHAR2,
        p_val2  IN VARCHAR2 )
RETURN VARCHAR2 IS
BEGIN
        IF p_val1 IS NULL AND p_val2 IS NOT NULL
        OR p_val1 IS NOT NULL AND p_val2 IS NULL
        THEN
                RETURN ('true');
        END IF;
        IF IGS_GE_NUMBER.TO_NUM(p_val1) <> IGS_GE_NUMBER.TO_NUM(p_val2)
        THEN
                RETURN ('true');
        ELSE
                RETURN ('false');
        END IF;
        EXCEPTION
        WHEN VALUE_ERROR
        THEN
                IF RTRIM(p_val1) <> RTRIM(p_val2)
                THEN
                        RETURN ('true');
                ELSE
                        RETURN ('false');
                END IF;
END neq;
/*

 compare dates

*/
FUNCTION date_compare (
        p_lhs                   IN VARCHAR2,
        p_comparitor    IN VARCHAR2,
        p_rhs                   IN VARCHAR2 )
RETURN VARCHAR2 IS
        v_date_format   VARCHAR2(30);
        v_lhs           DATE;
        v_rhs           DATE;
BEGIN
        IF IGS_GE_GEN_004.jbsp_get_dt_picture(p_lhs,v_date_format)
        THEN
                v_lhs := TO_DATE(p_lhs,v_date_format);
        END IF;
        IF IGS_GE_GEN_004.jbsp_get_dt_picture(p_rhs,v_date_format)
        THEN
                v_rhs := TO_DATE(p_rhs,v_date_format);
        END IF;
        IF p_comparitor = '<'
        THEN
                RETURN b_to_t(v_lhs < v_rhs);
        ELSIF p_comparitor = '<='
        THEN
                RETURN b_to_t(v_lhs <= v_rhs);
        ELSIF p_comparitor = '='
        THEN
                RETURN b_to_t(v_lhs = v_rhs);
        ELSIF p_comparitor = '<>'
        THEN
                RETURN b_to_t(v_lhs <> v_rhs);
        ELSIF p_comparitor = '>='
        THEN
                RETURN b_to_t(v_lhs >= v_rhs);
        ELSIF p_comparitor = '>'
        THEN
                RETURN b_to_t(v_lhs > v_rhs);
        END IF;
END date_compare;
/*

 CONJUNCTION FUNCTIONS

 And function

*/
FUNCTION and_func(
        p_val1  IN VARCHAR2,
        p_val2  IN VARCHAR2 )
RETURN VARCHAR2 IS
BEGIN
        IF RTRIM(p_val1) = 'true' AND RTRIM(p_val2) = 'true'
        THEN
                RETURN 'true';
        ELSIF RTRIM(p_val1) = 'false' OR RTRIM(p_val2) = 'false'
        THEN
                RETURN 'false';
        ELSE
                log_error('and_func',
                        'Invalid arguments ('||RTRIM(p_val1)||','||RTRIM(p_val2)||')');
        END IF;
END and_func;
/*

 Or function

*/
FUNCTION or_func(
        p_val1  IN VARCHAR2,
        p_val2  IN VARCHAR2 )
RETURN VARCHAR2 IS
BEGIN
        IF RTRIM(p_val1) = 'true' OR RTRIM(p_val2) = 'true'
        THEN
                RETURN 'true';
        ELSIF RTRIM(p_val1) = 'false' AND RTRIM(p_val2) = 'false'
        THEN
                RETURN 'false';
        ELSE
                log_error('or_func',
                        'Invalid arguments ('||RTRIM(p_val1)||','||RTRIM(p_val2)||')');
        END IF;
END or_func;
/*
 SET FUNCTIONS

 Create new set
*/
FUNCTION new_set
RETURN BINARY_INTEGER IS
BEGIN
        gv_set_index := gv_set_index + 1;
/*
         make new set
*/
        gv_set(gv_set_index).first := NULL;
        gv_set(gv_set_index).last_insert := NULL;
        RETURN gv_set_index;
END new_set;
/*
 Compare members (char)
 left < right RETURN -1
 left = right RETURN 0
 left > right RETURN 1
*/
FUNCTION compare_members(
                l_index BINARY_INTEGER,
                r_index BINARY_INTEGER )
RETURN  NUMBER IS
BEGIN
        IF gv_member(l_index).f1 < gv_member(r_index).f1
        THEN
                RETURN -1;
        ELSIF gv_member(l_index).f1 > gv_member(r_index).f1
        THEN
                RETURN 1;
        ELSIF gv_member(l_index).f2 < gv_member(r_index).f2
        THEN
                RETURN -1;
        ELSIF gv_member(l_index).f2 > gv_member(r_index).f2
        THEN
                RETURN 1;
        ELSIF gv_member(l_index).f3 < gv_member(r_index).f3
        THEN
                RETURN -1;
        ELSIF gv_member(l_index).f3 > gv_member(r_index).f3
        THEN
                RETURN 1;
        ELSIF gv_member(l_index).f4 < gv_member(r_index).f4
        THEN
                RETURN -1;
        ELSIF gv_member(l_index).f4 > gv_member(r_index).f4
        THEN
                RETURN 1;
        ELSIF gv_member(l_index).f5 < gv_member(r_index).f5
        THEN
                RETURN -1;
        ELSIF gv_member(l_index).f5 > gv_member(r_index).f5
        THEN
                RETURN 1;
        ELSE
                RETURN 0;
        END IF;
END compare_members;
/*
 Add member to set, ordered ascending (char), no duplicates.
 Most efficient if successive members are in ascending order.
 It is a simple linked list with the exception that a last insert pointer is
 maintained so that successive members can be added without searching the
 entire structure.
*/
FUNCTION add_member(
        p_set_number    IN BINARY_INTEGER,
        p_f1            IN VARCHAR2,
        p_f2            IN VARCHAR2,
        p_f3            IN VARCHAR2,
        p_f4            IN VARCHAR2,
        p_f5            IN VARCHAR2)
RETURN BINARY_INTEGER IS
        v_current_ptr   BINARY_INTEGER;
        v_compare       NUMBER;
BEGIN
/*
         make new member
*/
        gv_member(gv_member_index).f1 := p_f1;
        gv_member(gv_member_index).f2 := p_f2;
        gv_member(gv_member_index).f3 := p_f3;
        gv_member(gv_member_index).f4 := p_f4;
        gv_member(gv_member_index).f5 := p_f5;
/*
         add member to structure (not duplicates)
*/
        v_current_ptr := gv_set(p_set_number).last_insert;
        IF v_current_ptr IS NULL
        THEN
/*
                 first member, virgin set
*/
                gv_set(p_set_number).first := gv_member_index;
                gv_set(p_set_number).last_insert := gv_member_index;
                gv_member_index := gv_member_index + 1;
                RETURN p_set_number;
        END IF;
        v_compare := compare_members(gv_member_index, v_current_ptr);
        IF v_compare = -1
        THEN
/*
                 go back and search from start
*/
                v_current_ptr := gv_set(p_set_number).first;
/*
                 check the first member
*/
                v_compare := compare_members(gv_member_index, v_current_ptr);
                IF v_compare = -1
                THEN
/*
                         new first member
*/
                        gv_member(gv_member_index).next := v_current_ptr;
                        gv_set(p_set_number).first := gv_member_index;
                        gv_set(p_set_number).last_insert := gv_member_index;
                        gv_member_index := gv_member_index + 1;
                        RETURN p_set_number;
                END IF;
        END IF;
/*
         check for duplicates from either of the above cases
*/
        IF v_compare = 0
        THEN
/*
                 duplicate member
*/
                gv_set(p_set_number).last_insert := v_current_ptr;
                RETURN p_set_number;
        END IF;
        LOOP
                IF gv_member(v_current_ptr).next IS NULL
                THEN
/*
                         new last member
*/
                        gv_member(v_current_ptr).next := gv_member_index;
                        gv_set(p_set_number).last_insert := gv_member_index;
                        gv_member_index := gv_member_index + 1;
                        RETURN p_set_number;
                END IF;
                v_compare := compare_members(gv_member_index, gv_member(v_current_ptr).next);
                IF v_compare = -1
                THEN
/*
                         insert new member
*/
                        gv_member(gv_member_index).next := gv_member(v_current_ptr).next;
                        gv_member(v_current_ptr).next := gv_member_index;
                        gv_set(p_set_number).last_insert := gv_member_index;
                        gv_member_index := gv_member_index + 1;
                        RETURN p_set_number;
                ELSIF v_compare = 0
                THEN
/*
                         duplicate member
*/
                        gv_set(p_set_number).last_insert := v_current_ptr;
                        RETURN p_set_number;
                ELSE
/*
                         get next member
*/
                        v_current_ptr := gv_member(v_current_ptr).next;
                END IF;
        END LOOP;
END add_member;
/*

 intersection of two sets

*/
FUNCTION set_intersect(
        p_set1  IN BINARY_INTEGER,
        p_set2  IN BINARY_INTEGER )
RETURN BINARY_INTEGER IS
        v_set3          BINARY_INTEGER;
        v_l_index       BINARY_INTEGER;
        v_r_index       BINARY_INTEGER;
        v_compare       NUMBER;
BEGIN
        v_set3 := new_set;
        v_l_index := gv_set(p_set1).first;
        v_r_index := gv_set(p_set2).first;
        LOOP
                IF v_l_index IS NULL OR
                   v_r_index IS NULL
                THEN
/*
                         last member in either set terminates intersect
*/
                        RETURN v_set3;
                END IF;
                v_compare := compare_members(v_l_index,v_r_index);
                IF v_compare = -1
                THEN
/*
                         get next left member
*/
                        v_l_index := gv_member(v_l_index).next;
                ELSIF v_compare = 0
                THEN
/*
                         add the equal member
*/
                        v_set3 := add_member(v_set3,
                                        gv_member(v_l_index).f1,
                                        gv_member(v_l_index).f2,
                                        gv_member(v_l_index).f3,
                                        gv_member(v_l_index).f4,
                                        gv_member(v_l_index).f5);
                        v_l_index := gv_member(v_l_index).next;
                        v_r_index := gv_member(v_r_index).next;
                ELSE
/*
                         get next right member
*/
                        v_r_index := gv_member(v_r_index).next;
                END IF;
        END LOOP;
        RETURN v_set3;
END set_intersect;
/*

 union of two sets

*/
FUNCTION set_union(
        p_set1  IN BINARY_INTEGER,
        p_set2  IN BINARY_INTEGER )
RETURN BINARY_INTEGER IS
        v_set3          BINARY_INTEGER;
        v_l_index       BINARY_INTEGER;
        v_r_index       BINARY_INTEGER;
        v_compare       NUMBER;
BEGIN
        v_set3 := new_set;
        v_l_index := gv_set(p_set1).first;
        v_r_index := gv_set(p_set2).first;
        LOOP
                IF v_l_index IS NULL AND
                   v_r_index IS NULL
                THEN
                        RETURN v_set3;
                END IF;
                IF v_l_index IS NULL
                THEN
/*
                         no more left, add all remaining right members
*/
                        v_compare := 1;
                ELSIF v_r_index IS NULL
                THEN
/*
                         no more right, add all remaining left members
*/
                        v_compare := -1;
                ELSE
/*
                         use compare to do ordered insert of members
*/
                        v_compare := compare_members(v_l_index,v_r_index);
                END IF;
                IF v_compare = -1
                THEN
/*
                         add left member, get next left
*/
                        v_set3 := add_member(v_set3,
                                        gv_member(v_l_index).f1,
                                        gv_member(v_l_index).f2,
                                        gv_member(v_l_index).f3,
                                        gv_member(v_l_index).f4,
                                        gv_member(v_l_index).f5);
                        v_l_index := gv_member(v_l_index).next;
                ELSIF v_compare = 0
                THEN
/*
                         equal, add one member, get next members
*/
                        v_set3 := add_member(v_set3,
                                        gv_member(v_l_index).f1,
                                        gv_member(v_l_index).f2,
                                        gv_member(v_l_index).f3,
                                        gv_member(v_l_index).f4,
                                        gv_member(v_l_index).f5);
                        v_l_index := gv_member(v_l_index).next;
                        v_r_index := gv_member(v_r_index).next;
                ELSE
/*
                         add right member, get next right
*/
                        v_set3 := add_member(v_set3,
                                        gv_member(v_r_index).f1,
                                        gv_member(v_r_index).f2,
                                        gv_member(v_r_index).f3,
                                        gv_member(v_r_index).f4,
                                        gv_member(v_r_index).f5 );
                        v_r_index := gv_member(v_r_index).next;
                END IF;
        END LOOP;
        RETURN v_set3;
END set_union;
/*

 set1 minus set2

*/
FUNCTION set_minus(
        p_set1  IN BINARY_INTEGER,
        p_set2  IN BINARY_INTEGER )
RETURN BINARY_INTEGER IS
        v_set3          BINARY_INTEGER;
        v_l_index       BINARY_INTEGER;
        v_r_index       BINARY_INTEGER;
        v_compare       NUMBER;
BEGIN
        v_set3 := new_set;
        v_l_index := gv_set(p_set1).first;
        v_r_index := gv_set(p_set2).first;
        LOOP
                IF v_l_index IS NULL
                THEN
/*
                         no more left, end minus
*/
                        RETURN v_set3;
                END IF;
                IF v_r_index IS NULL
                THEN
/*
                         no more right, add all remaining left members
*/
                        v_compare := -1;
                ELSE
/*
                         determine which members to add
*/
                        v_compare := compare_members(v_l_index,v_r_index);
                END IF;
                IF v_compare = -1
                THEN
/*
                        add left member, get next left
*/
                        v_set3 := add_member(v_set3,
                                        gv_member(v_l_index).f1,
                                        gv_member(v_l_index).f2,
                                        gv_member(v_l_index).f3,
                                        gv_member(v_l_index).f4,
                                        gv_member(v_l_index).f5);
                        v_l_index := gv_member(v_l_index).next;
                ELSIF v_compare = 0
                THEN
/*
                         equal, get next left and right
*/
                        v_l_index := gv_member(v_l_index).next;
                        v_r_index := gv_member(v_r_index).next;
                ELSE
/*
                         get next right
*/
                        v_r_index := gv_member(v_r_index).next;
                END IF;
        END LOOP;
        RETURN v_set3;
END set_minus;
/*
 count the set members by processing the linked list
 NOTE this count is UNIQUE on f1
*/
FUNCTION members (
        p_set_number    IN BINARY_INTEGER )
RETURN NUMBER IS
        v_member        BINARY_INTEGER;
        v_count         NUMBER := 0;
        v_prev_f1       VARCHAR2(10);
BEGIN
        v_prev_f1 := '@$%!*(|';  --smvk        29-Nov-2004     File.Sql.35 warning fix.
        v_member := gv_set(p_set_number).first;
        LOOP
/*
                 check if last (must do check for null)
*/
                IF v_member IS NULL
                THEN
/*
                        yep, last member
*/
                        EXIT;
                END IF;
                IF gv_member(v_member).f1 <> v_prev_f1
                THEN
                        v_count := v_count + 1;
                        v_prev_f1 := gv_member(v_member).f1;
                END IF;
/*
                next member
*/
                v_member := gv_member(v_member).next;
        END LOOP;
        RETURN v_count;
END members;
/*
 test if LHS exists in the set
*/
FUNCTION in_set (
        p_lhs           VARCHAR2,
        p_set_number    IN BINARY_INTEGER )
RETURN VARCHAR2 IS
        v_member        BINARY_INTEGER;
BEGIN
        v_member := gv_set(p_set_number).first;
        LOOP
/*
                 check if last (must do check for null)
*/
                IF v_member IS NULL
                THEN
/*
                         yep, last member
*/
                        EXIT;
                END IF;
                IF p_lhs = gv_member(v_member).f1
                THEN
                        RETURN 'true';
                END IF;
                v_member := gv_member(v_member).next;
        END LOOP;
        RETURN 'false';
END in_set;
/*
 show unit set members
*/
FUNCTION show_set(
        p_set_number    IN BINARY_INTEGER )
RETURN BINARY_INTEGER IS
        v_member        BINARY_INTEGER;
        v_wam_type      VARCHAR2(10);
BEGIN
        v_wam_type := 'COURSE'; --smvk        29-Nov-2004     File.Sql.35 warning fix.
/*
nks     debug_display('Set '||p_set_number);
*/
        IF p_cal_type IS NOT NULL
        THEN
                v_wam_type := 'PERIOD';
        END IF;

        v_member := gv_set(p_set_number).first;
        LOOP
/*
                 check if last (must do check for null)
*/
                IF v_member IS NULL
                THEN
/*
                         yep, last member
*/
                        EXIT;
                END IF;

/*
                 next member
*/
                v_member := gv_member(v_member).next;
        END LOOP;
        RETURN (p_set_number);
END show_set;
/*
show unit set set members
*/
FUNCTION show_us_set(
        p_set_number    IN BINARY_INTEGER )
RETURN BINARY_INTEGER IS
        v_member        BINARY_INTEGER;
        v_tds   r_tds;
BEGIN
        v_member := gv_set(p_set_number).first;
        LOOP
/*
                 check if last (must do check for null)
*/
                IF v_member IS NULL
                THEN
/*
                         yep, last member
*/
                        EXIT;
                END IF;
                v_tds.member_index := v_member;
                v_tds.unit_cd := gv_member(v_member).f1;
                v_tds.unit_version := gv_member(v_member).f2;
                v_tds.cal_type := gv_member(v_member).f3;
                v_tds.ci_sequence_number := gv_member(v_member).f4;
                v_tds.uoo_id := gv_member(v_member).f5;

/*
                 next member
*/
                v_member := gv_member(v_member).next;
        END LOOP;
        RETURN (p_set_number);
END show_us_set;
/*
 duplicates (by unit code) within the given set (not including self)
 only used in sua_select_unique call
*/
FUNCTION sua_duplicate_set (
        p_tds           IN r_tds )
RETURN BINARY_INTEGER IS
        v_member        BINARY_INTEGER;
        v_set1          BINARY_INTEGER;
BEGIN
        v_set1 := new_set;
        v_member := gv_set(p_tds.set_number).first;
        LOOP
/*
                check if last (must do check for null)
*/
                IF v_member IS NULL
                THEN
/*
                        yep, last member
*/
                        EXIT;
                END IF;
                IF gv_member(v_member).f1 = p_tds.unit_cd AND
                   NOT (gv_member(v_member).f2 = p_tds.unit_version AND
                        gv_member(v_member).f3 = p_tds.cal_type AND
                        gv_member(v_member).f4 = p_tds.ci_sequence_number AND
                        gv_member(v_member).f5 = p_tds.uoo_id)
                THEN
                        v_set1 := add_member(v_set1,
                                        gv_member(v_member).f1,
                                        gv_member(v_member).f2,
                                        gv_member(v_member).f3,
                                        gv_member(v_member).f4,
                                        gv_member(v_member).f5);
                END IF;
/*
                next member
*/
                v_member := gv_member(v_member).next;
        END LOOP;
        RETURN v_set1;
END sua_duplicate_set;
/*
STUDENT RELATED SETS

Select student units
*/
FUNCTION student
RETURN BINARY_INTEGER IS
BEGIN
        IF gv_sua_set IS NOT NULL
        THEN
                RETURN gv_sua_set;
        END IF;
        gv_sua_set := new_set;
        FOR student_unit_attempts IN (
                SELECT  unit_cd,
                        version_number,
                        cal_type,
                        ci_sequence_number,
                        uoo_id
                FROM    IGS_EN_SU_ATTEMPT
                WHERE   person_id = p_person_id
                AND     course_cd = p_course_cd
                AND (p_param_8 IS NULL OR p_param_8 <> uoo_id)
                -- AND  sup_unit_cd IS NULL 99/05/04 hrt
                ORDER BY unit_cd,IGS_GE_NUMBER.TO_CANN(version_number),
                        cal_type,IGS_GE_NUMBER.TO_CANN(ci_sequence_number) )
        LOOP
                gv_sua_set := add_member(gv_sua_set,
                                student_unit_attempts.unit_cd,
                                student_unit_attempts.version_number,
                                student_unit_attempts.cal_type,
                                student_unit_attempts.ci_sequence_number,
                                student_unit_attempts.uoo_id);
        END LOOP;
        RETURN gv_sua_set;
END student;

/*
 Student Admission test type sets.
*/
FUNCTION test_grade (cp_c_grade IN VARCHAR2) RETURN BINARY_INTEGER IS
  --Gets the grades assigned to the student (person_id) for the admission test (cp_c_grade)
  CURSOR c_tst_grade (cp_n_person_id IN NUMBER, cp_c_grade IN VARCHAR2) IS
    SELECT DISTINCT B.NAME GRADE
    FROM   IGS_AD_TEST_RESULTS A,
           IGS_AD_CODE_CLASSES B
    WHERE  A.PERSON_ID = cp_n_person_id
    AND    A.ADMISSION_TEST_TYPE = cp_c_grade
    AND    A.GRADE_ID IS NOT NULL
    AND    A.ACTIVE_IND  = 'Y'
    AND    A.GRADE_ID = B.CODE_ID ;
BEGIN
  -- if the grade set is already defined then return grade set number;
  IF gv_grade_set IS NOT NULL THEN
     RETURN gv_grade_set;
  END IF;
  -- creates a new set.
  gv_grade_set := new_set;

  FOR rec_tst_grade IN c_tst_grade(p_person_id,cp_c_grade) LOOP
     -- Adds the grade values to structure f1 value.
     gv_grade_set := add_member(gv_grade_set,
                                rec_tst_grade.grade,
                                '','','','');
  END LOOP;
  -- Return grades set number
  RETURN gv_grade_set;
END test_grade;

/*
 test if LHS grade exists in the grading set
*/
FUNCTION not_in_grd (
        p_set_number    IN BINARY_INTEGER,
        p_lhs           VARCHAR2        )
RETURN VARCHAR2 IS
        v_member        BINARY_INTEGER;
BEGIN
        -- get the first member in the set.
        v_member := gv_set(p_set_number).first;
        LOOP
/*
                 check if last (must do check for null)
*/
                IF v_member IS NULL
                THEN
/*
                         yep, last member
*/
                        EXIT;
                END IF;
                -- check if the LHS grade is not equal to student grade in the set then return true
                IF p_lhs <> gv_member(v_member).f1
                THEN
                        RETURN 'true';
                END IF;
                v_member := gv_member(v_member).next;
        END LOOP;
        RETURN 'false';
END not_in_grd;


/*
 Select advanced standing units
*/

-- Added distinct to the query which gets advanced standing unit level so that the same records
-- are not processed later.
FUNCTION advanced_standing
RETURN BINARY_INTEGER IS
        v_cal_type                      IGS_CA_TYPE.cal_type%TYPE;
        v_ci_sequence_number    IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE;
BEGIN
        IF gv_asu_set IS NOT NULL
        THEN
                RETURN gv_asu_set;
        END IF;
        gv_asu_set := new_set;
/*
         get ONE earliest calander for student to use in advanced standing set
*/
        FOR ASU IN (
                SELECT  DISTINCT unit_cd, version_number
                FROM    IGS_AV_STND_UNIT
                WHERE   person_id = p_person_id
                AND     as_course_cd = p_course_cd
                AND     s_adv_stnd_granting_status IN ('APPROVED','GRANTED')
                AND     s_adv_stnd_recognition_type = 'CREDIT'
                AND     (igs_av_val_asu.granted_adv_standing(person_id,as_course_cd,as_version_number,
                        unit_cd,version_number,'BOTH',NULL) ='TRUE')
                ORDER BY unit_cd,IGS_GE_NUMBER.TO_CANN(version_number) )
        LOOP
                /*
                 get ONE earliest calander for student to use in advanced standing set
                 modified this logic to be based on program offering options instead of unit attempts,bug#4283221
                */
                FOR cur_ec IN (
                        SELECT  a.cal_type,
                                a.ci_sequence_number,
                                ci.start_dt
                        FROM    IGS_PS_UNIT_OFR_OPT A, igs_ca_inst ci
                        WHERE   a.unit_cd = asu.unit_cd
                        AND     a.version_number = asu.version_number
                        AND     a.cal_type = ci.cal_type
                        AND     a.ci_sequence_number = ci.sequence_number
                        ORDER BY ci.start_dt )
                LOOP
                        v_cal_type := cur_ec.cal_type;
                        v_ci_sequence_number := cur_ec.ci_sequence_number;
                        EXIT;   /*  only get first (earliest) */
                END LOOP;

                gv_asu_set := add_member(gv_asu_set,
                                ASU.unit_cd,
                                ASU.version_number,
                                v_cal_type,
                                v_ci_sequence_number,'');
        END LOOP;
        RETURN gv_asu_set;
END advanced_standing;
/*
 Select advanced standing unit level set
*/

-- Added distinct to the query which gets advanced standing unit level so that the same records
-- are not processed later.
FUNCTION advanced_standing_unit_level
RETURN BINARY_INTEGER IS
BEGIN
        IF gv_asul_set IS NOT NULL
        THEN
                RETURN gv_asul_set;
        END IF;
        gv_asul_set := new_set;
        FOR ASUL IN (
                SELECT  DISTINCT s_adv_stnd_type, unit_level, crs_group_ind, exemption_institution_cd
                FROM    IGS_AV_STND_UNIT_LVL
                WHERE   person_id = p_person_id
                AND     as_course_cd = p_course_cd
                AND     s_adv_stnd_granting_status IN ('GRANTED')
                ORDER BY s_adv_stnd_type,unit_level,crs_group_ind,exemption_institution_cd )
        LOOP
                gv_asul_set := add_member(gv_asul_set,
                                ASUL.s_adv_stnd_type,           /*      VARCHAR2(10) */
                                ASUL.unit_level,                /*      VARCHAR2(10) */
                                ASUL.crs_group_ind,             /*      VARCHAR2(10) */
                                ASUL.exemption_institution_cd,  /*      VARCHAR2(10) */
                                ''); /*      VARCHAR2(10) */
        END LOOP;
        RETURN gv_asul_set;
END advanced_standing_unit_level;
/*
 student unit sets
*/
FUNCTION student_us
RETURN BINARY_INTEGER IS
BEGIN
        IF gv_susa_set IS NOT NULL
        THEN
                RETURN gv_susa_set;
        END IF;
        gv_susa_set := new_set;
        FOR SUSA IN (
                SELECT  unit_set_cd,
                        us_version_number,
                        sequence_number
                FROM    IGS_AS_SU_SETATMPT
                WHERE   person_id = p_person_id
                AND     course_cd = p_course_cd
                ORDER BY unit_set_cd,us_version_number,sequence_number )
        LOOP
                gv_susa_set := add_member(gv_susa_set,
                                SUSA.unit_set_cd,
                                SUSA.us_version_number,
                                SUSA.sequence_number,
                                '','');
        END LOOP;
        RETURN gv_susa_set;
END student_us;
/*
 evaluate the sql string and return the set number
*/
FUNCTION make_set (
        p_select_string IN VARCHAR2 )
RETURN BINARY_INTEGER IS
        v_cursor        INTEGER;
        v_rows  INTEGER;
        v_f1            VARCHAR2(10);
        v_f2            VARCHAR2(10);
        v_f3            VARCHAR2(10);
        v_f4            VARCHAR2(10);
        v_set1  BINARY_INTEGER;
BEGIN
        v_cursor := DBMS_SQL.OPEN_CURSOR;
/*
         only select allowed
*/
        DBMS_SQL.PARSE(v_cursor,
                'SELECT'||SUBSTR(LTRIM(p_select_string),7),
                dbms_sql.v7);
        DBMS_SQL.DEFINE_COLUMN(v_cursor,1,v_f1,10);
        DBMS_SQL.DEFINE_COLUMN(v_cursor,2,v_f2,10);
        DBMS_SQL.DEFINE_COLUMN(v_cursor,3,v_f3,10);
        DBMS_SQL.DEFINE_COLUMN(v_cursor,4,v_f4,10);
        v_rows := DBMS_SQL.EXECUTE(v_cursor);
        v_set1 := new_set;
        WHILE DBMS_SQL.FETCH_ROWS(v_cursor) > 0
        LOOP
                DBMS_SQL.COLUMN_VALUE(v_cursor,1,v_f1);
                DBMS_SQL.COLUMN_VALUE(v_cursor,2,v_f2);
                DBMS_SQL.COLUMN_VALUE(v_cursor,3,v_f3);
                DBMS_SQL.COLUMN_VALUE(v_cursor,4,v_f4);
                -- passing null string for f5, as the make_set rule is not used in the context of unit attempt
                v_set1 := add_member(v_set1,v_f1,v_f2,v_f3,v_f4,'');
        END LOOP;
        DBMS_SQL.CLOSE_CURSOR(v_cursor);
        RETURN v_set1;
END make_set;
/*
 if version number exists in version string
 version string form, 1-5,8,10
 version 10 and beyond is represented as 10-
 all versions upto 10 is represented as -10
*/
FUNCTION in_versions(
        p_version_number IN NUMBER,
        p_versions       IN VARCHAR )
RETURN BOOLEAN IS
        v_prev_comma    NUMBER := 1;    /* previous position of comma in string */
        v_curr_comma    NUMBER;         /* current position of comma in string */
        v_sub_str               VARCHAR2(30);   /* sub-string between comma's  */
        v_dash          NUMBER;         /* position of '-' in sub-string */
        v_lower         NUMBER;
        v_upper         NUMBER;
BEGIN
        IF p_versions IS null
        THEN
                RETURN (TRUE);
        END IF;
        LOOP
/*
                 find next comma (if exists)
*/
                v_curr_comma := INSTR(p_versions, ',', v_prev_comma);
                IF v_curr_comma = 0
                THEN
/*
                         all/rest of string
*/
                        v_sub_str := SUBSTR(p_versions, v_prev_comma);
                ELSE
/*
                         part of string, previous comma to this comma
*/
                        v_sub_str := SUBSTR(p_versions, v_prev_comma, v_curr_comma - v_prev_comma);
                END IF;
                v_prev_comma := v_curr_comma + 1;
                v_dash := INSTR(v_sub_str, '-');
                IF v_dash = 0
                THEN
                        v_lower := IGS_GE_NUMBER.TO_NUM(v_sub_str);
                        v_upper := v_lower;
                ELSE
/*
                         dash in sub-string, split lower and upper
*/
                        v_lower := IGS_GE_NUMBER.TO_NUM(SUBSTR(v_sub_str, 1, v_dash - 1));
                        v_upper := IGS_GE_NUMBER.TO_NUM(SUBSTR(v_sub_str, v_dash + 1));
                END IF;
                IF (p_version_number >= v_lower OR v_lower IS NULL) AND
                   (p_version_number <= v_upper OR v_upper IS NULL)
                THEN
                        RETURN (TRUE);
                END IF;
                IF v_curr_comma = 0
                THEN
                        RETURN (FALSE);
                END IF;
        END LOOP;
END in_versions;

  /******** this is for the reference set *************/

  FUNCTION ref_set(p_set1 IN BINARY_INTEGER) RETURN VARCHAR2 IS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 07-JUN-2001
  --
  --Purpose: As per enhancement bug no.1775394 . This function does the
  --         evaluation of rules set for Person reference Types
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --kdande   25-Nov-2002 Removed entire code from the function and
  --                     replaced it with true since the view
  --                     igs_pe_person_refs_v is obsolete
  -------------------------------------------------------------------
  BEGIN
    RETURN 'true';
  END ref_set ;       /** end of function ref_set **/

  /******** this is for the person id group *************/

  FUNCTION perid_chk(p_set1 IN BINARY_INTEGER) RETURN VARCHAR2 IS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 07-JUN-2001
  --
  --Purpose: As per enhancement bug no.1775394 . This function does the
  --         evaluation of rules set for Person Id group
  --
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
    l_member BINARY_INTEGER ;
    l_result VARCHAR2(100)  ;
    l_tds    r_tds          ;

    CURSOR c_persid IS
    SELECT peg.group_cd
    FROM   igs_pe_persid_group peg,igs_pe_prsid_grp_mem pegm
    WHERE  peg.group_id   = pegm.group_id
    AND    pegm.person_id = p_person_id  ;

  BEGIN
    l_result := 'false' ;                                       -- set the return result as false
    l_member := gv_set(p_set1).FIRST ;                          -- get the first member defined as part of the rule set
    LOOP                                                        -- loop thru all the members and exit when there are no records
      IF l_member IS NULL THEN
        EXIT ;
      END IF;
      l_tds.member_index :=  l_member ;                         -- get the index for pl/sql table
      l_tds.unit_cd      :=  gv_member(l_member).f1  ;          -- get the value of code defined in rules in local variable
      FOR rec_reference IN c_persid
      LOOP
        IF rec_reference.group_cd = l_tds.unit_cd THEN          -- if match is found then rule is evaluated to true else move to next reference code for the student
          RETURN 'true';
        END IF;
      END LOOP ;
      l_member := gv_member(l_member).NEXT ;
    END LOOP ;
    RETURN l_result ;
  END perid_chk ;       /** end of function perid_chk **/

  /******** this is for the unit placement set *************/

  FUNCTION plc_chk(p_set1 IN BINARY_INTEGER) RETURN VARCHAR2 IS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 07-JUN-2001
  --
  --Purpose: As per enhancement bug no.1775394 . This function does the
  --         evaluation of rules set for Unit placement set
  --
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --kkillams    31-10-2003      Modified the business validation as per
  --                            new requirements w.r.t. bug 3111609
  -------------------------------------------------------------------
    l_member BINARY_INTEGER ;
    l_result VARCHAR2(100)  ;
    l_found  BOOLEAN;
    l_tds    r_tds          ;

    CURSOR c_plc_chk IS
      SELECT d.unit_cd
      FROM   igs_ad_up_detail d
      WHERE  EXISTS (
                     SELECT 'x'
                     FROM   igs_ad_test_results atr,
                            igs_ad_up_header h
                     WHERE  atr.person_id = p_person_id
                     AND    atr.admission_test_type = h.admission_test_type
                     AND    h.up_header_id = d.up_header_id);
  PROCEDURE val_placement (pp_unit_cd      IN IGS_PS_UNIT_VER.UNIT_CD%TYPE,
                           pp_person_id    IN IGS_PE_PERSON.PERSON_ID%TYPE ,
                           pp_found        OUT NOCOPY BOOLEAN)IS

        l_dummy     VARCHAR2(1);

        --Gets the unit placement details
        CURSOR cur_st_test(cp_unit_cd igs_ps_unit_ver.unit_cd%TYPE) IS
        SELECT admission_test_type,
               test_segment_id,
               definition_level,
               min_score,
               max_score
               FROM  igs_ad_up_detail det,
                     igs_ad_up_header hed
               WHERE det.up_header_id = hed.up_header_id
               AND   det.unit_cd = cp_unit_cd
               AND   det.closed_ind ='N';
        CURSOR cur_test(cp_person_id           igs_pe_person.person_id%TYPE,
                        cp_admission_test_type igs_ad_up_header.admission_test_type%TYPE,
                        cp_min_score           igs_ad_up_header.min_score%TYPE,
                        cp_max_score           igs_ad_up_header.max_score%TYPE ) IS
        SELECT '1' FROM IGS_AD_TEST_RESULTS
                   WHERE person_id = cp_person_id
                   AND   admission_test_type = cp_admission_test_type
                   AND   NVL(comp_test_score,0) BETWEEN cp_min_score AND cp_max_score;
        --
        CURSOR cur_seg (cp_person_id           igs_pe_person.person_id%TYPE,
                        cp_admission_test_type igs_ad_up_header.admission_test_type%TYPE,
                        cp_test_segment_id     igs_ad_up_header.test_segment_id%TYPE,
                        cp_min_score           igs_ad_up_header.min_score%TYPE,
                        cp_max_score           igs_ad_up_header.max_score%TYPE ) IS
        SELECT '1' FROM IGS_AD_TEST_RESULTS   TST,
                        IGS_AD_TST_RSLT_DTLS  TDTL
                   WHERE tst.person_id = cp_person_id
                   AND   tst.admission_test_type = cp_admission_test_type
                   AND   tst.test_results_id     = tdtl.test_results_id
                   AND   tdtl.test_segment_id    = cp_test_segment_id
                   AND   tdtl.test_score BETWEEN cp_min_score AND cp_max_score;
  BEGIN
        l_found :=FALSE;
        FOR rec_st_test IN cur_st_test(pp_unit_cd)
        LOOP
            --Segment level verification
            IF rec_st_test.definition_level ='S' THEN
                  OPEN cur_seg(pp_person_id,rec_st_test.admission_test_type, rec_st_test.test_segment_id,rec_st_test.min_score,rec_st_test.max_score);
                  FETCH cur_seg INTO l_dummy;
                  IF cur_seg%FOUND THEN
                      pp_found := TRUE;
                      CLOSE cur_seg;
                      EXIT;
                  END IF;
                  CLOSE cur_seg;
            --Test type level verification
            ELSIF rec_st_test.definition_level ='T' THEN
                  OPEN cur_test(pp_person_id,rec_st_test.admission_test_type,rec_st_test.min_score,rec_st_test.max_score);
                  FETCH cur_test INTO l_dummy;
                  IF cur_test%FOUND THEN
                      pp_found := TRUE;
                      CLOSE cur_test;
                      EXIT;
                  END IF;
                  CLOSE cur_test;
            END IF;
        END LOOP;
  END val_placement;
  BEGIN
    l_result := 'false' ;                                              -- set the return result as false
    l_member := gv_set(p_set1).FIRST ;                                 -- get the first member defined as part of the rule set
    LOOP                                                               -- loop thru all the members and exit when there are no records
      IF l_member IS NULL THEN
        EXIT ;
      END IF;
      l_tds.member_index :=  l_member ;                                 -- get the index for pl/sql table
      l_tds.unit_cd      :=  gv_member(l_member).f1 ;                   -- get the value of code defined in rules in local variable
      val_placement(l_tds.unit_cd,p_person_id,l_found);
      IF l_found THEN
          RETURN 'true';
      END IF;
      l_member := gv_member(l_member).NEXT ;
    END LOOP ;
    RETURN l_result ;
  END plc_chk ;       /** end of function plc_chk **/

  /******** this is for the program stage completion evaluation *************/

  FUNCTION stg_set(p_set1 IN BINARY_INTEGER) RETURN VARCHAR2 IS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 07-JUN-2001
  --
  --Purpose: As per enhancement bug no.1775394 . This function does the
  --         evaluation of rules set for Program Stage completion
  --
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --sepalani    4/27/2006       Bug 5076203.
  -------------------------------------------------------------------
    l_member               BINARY_INTEGER ;
    l_result               VARCHAR2(100)  ;
    l_tds                  r_tds          ;

    CURSOR    c_igs_ps_stage(lc_course_cd         igs_ps_stage.course_cd%TYPE,
                             lc_version_number    igs_ps_stage.version_number%TYPE,
                             lc_course_stage_type igs_ps_stage.course_stage_type%TYPE) IS
    SELECT    cst.sequence_number
    FROM      igs_ps_stage cst
    WHERE     cst.course_cd         =  lc_course_cd
    AND       cst.version_number    =  lc_version_number
    AND       cst.course_stage_type =  lc_course_stage_type ;

    l_cst_sequence_number  igs_ps_stage.sequence_number%TYPE ;

    v_rule_text    VARCHAR2(2000);

    CURSOR c_csr (lc_course_cd            igs_ps_stage.course_cd%TYPE,
                  lc_version_number       igs_ps_stage.version_number%TYPE,
                  lc_cst_sequence_number  igs_ps_stage.sequence_number%TYPE,
                  lc_course_stage_type    igs_ps_stage.course_stage_type%TYPE) IS
        SELECT igs_ru_gen_003.rulp_get_rule (rul_sequence_number)
        FROM   igs_ps_stage_ru
        WHERE  course_cd = lc_course_cd
        AND    version_number = lc_version_number
        AND    cst_sequence_number = lc_cst_sequence_number
        AND    s_rule_call_cd = lc_course_stage_type;

  BEGIN
    l_result := 'true';                                                -- set the return result as true
    l_member := gv_set(p_set1).FIRST ;                                 -- get the first member defined as part of the rule set
    LOOP                                                               -- loop thru all the members and exit when there are no records
      IF l_member IS NULL THEN
        EXIT ;
      END IF;
      l_tds.member_index :=  l_member ;                                 -- get the index for pl/sql table
      l_tds.unit_cd      :=  gv_member(l_member).f1   ;                 -- get the value of code defined in rules in local variable

      -- Checking if the Stage is attached to the Program
      OPEN c_igs_ps_stage(p_course_cd, p_course_version,l_tds.unit_cd);
      FETCH c_igs_ps_stage INTO l_cst_sequence_number;
      IF c_igs_ps_stage%NOTFOUND THEN
                CLOSE c_igs_ps_stage;
                RETURN 'false';
      END IF;
      CLOSE c_igs_ps_stage;

      -- Checking if the Stage attached to the Program has a Rule
      OPEN c_csr(p_course_cd, p_course_version,l_cst_sequence_number,'STG-COMP');
      FETCH c_csr INTO v_rule_text;
      IF c_csr%NOTFOUND THEN
           CLOSE c_csr;
           RETURN 'false';
        END IF;
      CLOSE c_csr;

      --Checking Rule Status
      IF IGS_PR_GEN_002.PRGP_GET_STG_COMP(p_person_id           => p_person_id,
                                          p_course_cd           => p_course_cd,
                                          p_crv_version_number  => p_course_version,
                                          p_course_stage_type   => l_cst_sequence_number) = 'N' THEN
           l_result := 'false';
      END IF;
      l_member := gv_member(l_member).NEXT ;

    END LOOP ;
    RETURN l_result ;
  END stg_set ;       /** end of function stg_set **/


FUNCTION rulp_get_alwd_cp(
        p_percentage      IN NUMBER,
        p_course_cd       IN VARCHAR2,
        p_course_version  IN NUMBER )
  RETURN NUMBER IS
------------------------------------------------------------------
--Created by  : Nalin Kumar, Oracle IDC
--Date created: 18-JUN-2001
--
--Purpose: As per enhancement Bug# 1830175.
--         Function rulp_get_alwd_cp added as per the requirement of
--         Enrolment eligibility and Validations DLD (For form IGSEN058).
--
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-------------------------------------------------------------------
CURSOR cur_c1 (
        p_course_cd       VARCHAR2,
        p_course_version  NUMBER    )IS
  SELECT   max_cp_per_teaching_period
  FROM     IGS_PS_VER
  WHERE    course_cd      = p_course_cd AND
           version_number = p_course_version;

  l_max_cp   IGS_PS_VER.max_cp_per_teaching_period%Type;

BEGIN

  OPEN   cur_c1(p_course_cd,
                p_course_version);
  FETCH  cur_c1 INTO l_max_cp;
  CLOSE  cur_c1;
  RETURN  l_max_cp * (p_percentage/100);

END rulp_get_alwd_cp; /* End of rulp_get_alwd_cp function. */


/*
Expand a set member to all version_number/cal_type/ci_sequence_number
*/
FUNCTION expand_uoo(
        p_set1          IN BINARY_INTEGER,
        p_unit_cd               IN VARCHAR2,
        p_versions              IN VARCHAR2 )
RETURN BINARY_INTEGER IS        /*  set number */
        v_set1          BINARY_INTEGER;
BEGIN
/*
order by char because add_member expects char order
*/
        FOR uv IN (
                SELECT  unit_cd,
                        version_number
                FROM    IGS_PS_UNIT_VER
                WHERE   unit_cd LIKE (p_unit_cd)
                ORDER BY unit_cd,IGS_GE_NUMBER.TO_CANN(version_number) )
        LOOP
                IF in_versions(uv.version_number,
                        p_versions) = TRUE
                THEN
                        IF p_person_id IS NULL OR p_rule_call_name IN ('PREREQ','COREQ')
                        THEN
/*
                                 no student, no cal_type
*/
                                v_set1 := add_member(p_set1,
                                                uv.unit_cd,
                                                uv.version_number,
                                                '','','');
                        ELSE
/*
                                 this assumes a ENROLLED student has units/student has advance standing in this unit
                                 removed the check with unit attempts for bug#4283221,
                                 because advance standing units needn't depend on student unit attempt teaching calendar
*/
                                       /*
                                          this loop is added as part of MUS build bug 2829262
                                          it will fetch all unit sections under given unit and the teach cals.
                                       */
                                        FOR uoo IN (
                                                SELECT unt_oo.cal_type,unt_oo.ci_sequence_number,unt_oo.uoo_id
                                                FROM IGS_PS_UNIT_OFR_OPT unt_oo
                                                WHERE unt_oo.unit_cd = uv.unit_cd AND
                                                      unt_oo.version_number = uv.version_number
                                                ORDER BY unt_oo.cal_type, IGS_GE_NUMBER.TO_CANN(unt_oo.ci_sequence_number)
                                                     )
                                        LOOP
                                             v_set1 := add_member(p_set1,
                                                        uv.unit_cd,
                                                        uv.version_number,
                                                        uoo.cal_type,
                                                        uoo.ci_sequence_number,
                                                        uoo.uoo_id);
                                        END LOOP;/* uoo  */

                        END IF;
                END IF;
        END LOOP;
        RETURN p_set1;
END expand_uoo;
/*
 Get SNARTS (inverse of TRANS sets) and expand uoo
 The TRANS rule MUST BE a plain vanila type SET
*/
FUNCTION get_snarts (
                p_unit_cd       IN VARCHAR2,
                p_unit_version  IN NUMBER )
RETURN BINARY_INTEGER IS        /* set number */
        v_set1  BINARY_INTEGER;
BEGIN
        v_set1 := new_set;
        FOR SNART IN (
                SELECT  rsm.unit_cd rms_unit_cd,
                        rsm.versions rms_versions,
                        uvr.unit_cd uvr_unit_cd,
                        uvr.version_number uvr_version_number
                FROM    IGS_PS_UNIT_VER_RU uvr,
                        igs_ru_item rui,
                        igs_ru_set_member rsm
                WHERE   rsm.unit_cd = p_unit_cd
                AND     uvr.s_rule_call_cd = 'TRANS'
                AND     rui.rul_sequence_number = uvr.rul_sequence_number
                AND     rsm.rs_sequence_number = rui.set_number
                ORDER BY uvr.unit_cd,IGS_GE_NUMBER.TO_CANN(uvr.version_number) )
        LOOP
                IF in_versions(p_unit_version,SNART.rms_versions)
                THEN
                        FOR UOO IN (
                                SELECT UNIQUE
                                        unit_cd,
                                        version_number,
                                        cal_type,
                                        ci_sequence_number,
                                        uoo_id
                                FROM    IGS_PS_UNIT_OFR_OPT
                                WHERE   unit_cd = SNART.uvr_unit_cd
                                AND     version_number = SNART.uvr_version_number
                                ORDER BY unit_cd,IGS_GE_NUMBER.TO_CANN(version_number),
                                         cal_type,IGS_GE_NUMBER.TO_CANN(ci_sequence_number) )
                        LOOP
                                v_set1 := add_member(v_set1,
                                                UOO.unit_cd,
                                                UOO.version_number,
                                                UOO.cal_type,
                                                UOO.ci_sequence_number,
                                                UOO.uoo_id);
                        END LOOP;
                END IF;
        END LOOP;
        RETURN v_set1;
END get_snarts;
/*
 Expand rule set to work set for a set of units
*/
FUNCTION expand_unit_set(
        p_set1  IN NUMBER )
RETURN NUMBER IS
        v_set2  BINARY_INTEGER;
BEGIN
        v_set2 := new_set;
        FOR set_members IN (
                SELECT  unit_cd,
                        versions
                FROM    IGS_RU_SET_MEMBER
                WHERE   rs_sequence_number = p_set1
                ORDER BY unit_cd )
        LOOP
/*
                 expand to all unit offering options (version and cal)
*/
                v_set2 := expand_uoo(v_set2,
                                set_members.unit_cd,
                                set_members.versions);
        END LOOP;
        RETURN v_set2;
END expand_unit_set;
/*
Expand rule set to work set for a set of unit sets
*/
FUNCTION expand_us_set(
        p_set1  IN NUMBER )
RETURN BINARY_INTEGER IS
        v_set2  BINARY_INTEGER;
BEGIN
        v_set2 := new_set;
        FOR set_members IN (
                SELECT  unit_cd,
                        versions
                FROM    IGS_RU_SET_MEMBER
                WHERE   rs_sequence_number = p_set1
                ORDER BY unit_cd )
        LOOP
                FOR US IN (
                        SELECT  unit_set_cd,
                                version_number
                        FROM    IGS_EN_UNIT_SET
                        WHERE   unit_set_cd LIKE (set_members.unit_cd)
                        ORDER BY unit_set_cd,IGS_GE_NUMBER.TO_CANN(version_number) )
                LOOP
                        IF in_versions(US.version_number,
                                       set_members.versions) = TRUE
                        THEN
/*
                               has big potential for error (sequence_number) hrt
*/
                                v_set2 := add_member(v_set2,
                                                US.unit_set_cd,
                                                US.version_number,
                                                '','','');
                        END IF;
                END LOOP;
        END LOOP;
        RETURN v_set2;
END expand_us_set;
/*
 Expand rule set to work set for a set of courses
*/
FUNCTION expand_crs_set(
        p_set1  IN NUMBER )
RETURN BINARY_INTEGER IS
        v_set2  BINARY_INTEGER;
BEGIN
        v_set2 := new_set;
        FOR set_members IN (
                SELECT  unit_cd,
                        versions
                FROM    IGS_RU_SET_MEMBER
                WHERE   rs_sequence_number = p_set1
                ORDER BY unit_cd )
        LOOP
                FOR CRS IN (
                        SELECT  course_cd,
                                version_number
                        FROM    IGS_PS_VER
                        WHERE   course_cd LIKE (set_members.unit_cd)
                        ORDER BY course_cd,IGS_GE_NUMBER.TO_CANN(version_number) )
                LOOP
                        IF in_versions(CRS.version_number,
                                       set_members.versions) = TRUE
                        THEN
                                v_set2 := add_member(v_set2,
                                                CRS.course_cd,
                                                CRS.version_number,
                                                '','','');
                        END IF;
                END LOOP;
        END LOOP;
        RETURN v_set2;
END expand_crs_set;

  FUNCTION expand_gsch_set(
    p_set1 IN NUMBER )
  RETURN NUMBER IS
    /**********************************************************************************************
       Created By      :   rbezawad
       Date Created By :   30-Nov-2001
       Purpose         :   To add members(i.e., [Grading_Schema_Code.Grade] pairs ) for the Grading Schema Code.
                           Created as part of Progression Rules Enhancement Build, Bug No: 2146547.

       Known limitations,enhancements,remarks:
       Change History
       Who     When       What
    *************************************************************************************************/

    -- Get the Grading Schema Code given in the Rule Definition
    CURSOR cur_rul_set_member IS
      SELECT unit_cd
      FROM   igs_ru_set_member
      WHERE  rs_sequence_number = p_set1
      ORDER BY unit_cd ;

    -- Get All the Grading Schema Code, Grade pairs for the Grading Schema Code given in Rule Definition.
   /* added DISTINCT to select query as the rule 34420 has DISTINCT in its query */

    CURSOR cur_gscd_set_members(cp_grading_schema_cd  igs_as_grd_sch_grade.grading_schema_cd%TYPE,
                                cp_grade igs_as_grd_sch_grade.grade%TYPE) IS
      SELECT DISTINCT grading_schema_cd, grade
      FROM   igs_as_grd_sch_grade
      WHERE  grading_schema_cd = cp_grading_schema_cd
      AND    grade = cp_grade
      ORDER BY grading_schema_cd;

    l_set2 BINARY_INTEGER;
    l_unit_cd igs_ru_set_member.unit_cd%TYPE;

  BEGIN

  l_set2 := new_set;

    -- To Get the Grading Schema Code
  FOR rec_rul_set_member IN cur_rul_set_member LOOP

    -- Get All the Grading Schema Code, Grade pairs
    -- pass segregated value of grading schema from unit_cd
    FOR l_gscd_set_members_rec IN cur_gscd_set_members(
                               SUBSTR(rec_rul_set_member.unit_cd,1,instr(rec_rul_set_member.unit_cd,'/')-1),
                               SUBSTR(rec_rul_set_member.unit_cd,INSTR(rec_rul_set_member.unit_cd,'/')+1 )
                                                      ) LOOP
      -- Add the Grading Schema Member to the Set.
      l_set2 := add_member(l_set2,
                           l_gscd_set_members_rec.grading_schema_cd,
                           l_gscd_set_members_rec.grade,'','','');
    END LOOP;
  END LOOP;
  RETURN l_set2;

  END expand_gsch_set;


/*
Expand rule set to work set according to type
*/
FUNCTION expand_set(
        p_set1  IN NUMBER )
RETURN NUMBER IS
   /**********************************************************************************************
     Created By      :
     Date Created By :
     Purpose         :  To add set Members

     Known limitations,enhancements,remarks:
     Change History
     Who       When          What
     rbezawad  30-Nov-2001   Added Condition to check for Set Type GSCH_SET and call expand_gsch_set() function.
                             Modifications done W.r.t Progression Rules Enhancement Build, Bug No: 2146547.
    *************************************************************************************************/

        v_set_type      IGS_RU_SET.set_type%TYPE;
        v_set2          BINARY_INTEGER;
BEGIN
        SELECT  set_type
        INTO    v_set_type
        FROM    IGS_RU_SET
        WHERE   sequence_number = p_set1;
        IF v_set_type = 'UNIT_SET'
        THEN
                RETURN expand_unit_set(p_set1);
        ELSIF v_set_type = 'US_SET'
        THEN
                RETURN expand_us_set(p_set1);
        ELSIF v_set_type = 'CC_SET'
        THEN
                RETURN expand_crs_set(p_set1);
        ELSIF v_set_type = 'GSCH_SET' THEN
          RETURN expand_gsch_set(p_set1);
        ELSE
/*
                 all other sets (generic) just copy across to work set
*/
                v_set2 := new_set;
                FOR set_members IN (
                        SELECT  unit_cd
                        FROM    IGS_RU_SET_MEMBER
                        WHERE   rs_sequence_number = p_set1
                        ORDER BY unit_cd )
                LOOP
                        v_set2 := add_member(v_set2,
                                        set_members.unit_cd
                                        ,'','','','');
                END LOOP;
                RETURN v_set2;
        END IF;
END expand_set;
/*
 LOOPING FUNCTIONS

 Select members which satisfy the attribute rule criteria
*/
FUNCTION select_set(
        p_set1          BINARY_INTEGER,
        p_where_rule    NUMBER )
RETURN BINARY_INTEGER IS
        v_member        BINARY_INTEGER;
        v_set2  BINARY_INTEGER;
        v_result        IGS_RU_ITEM.value%TYPE;
        v_tds           r_tds;
BEGIN
/*
         populate structure, target set number
*/
        v_tds.set_number := p_set1;
        v_set2 := new_set;
        v_member := gv_set(p_set1).first;
        LOOP
/*
                 check if last (must do check for null)
*/
                IF v_member IS NULL
                THEN
/*
                         yep, last member
*/
                        EXIT;
                END IF;
/*
                 populate structure, target set member
*/
                v_tds.member_index := v_member;
                v_tds.unit_cd := gv_member(v_member).f1;
                v_tds.unit_version := gv_member(v_member).f2;
                v_tds.cal_type := gv_member(v_member).f3;
                v_tds.ci_sequence_number := gv_member(v_member).f4;
                v_tds.uoo_id := gv_member(v_member).f5;
/*
                 evaluate attribute criteria rule
*/
                v_result := RTRIM(turing(p_where_rule,v_tds));
                IF v_result = 'true'
                THEN
                        v_set2 := add_member(v_set2,
                                        gv_member(v_member).f1,
                                        gv_member(v_member).f2,
                                        gv_member(v_member).f3,
                                        gv_member(v_member).f4,
                                        gv_member(v_member).f5);
                ELSIF v_result = 'false'
                THEN
                        null;
                ELSE
                        log_error('select_set',
                                'Invalid condition rule return ('||v_result||')'||Fnd_Global.Local_Chr(10)||
                                'rule='||p_where_rule);
                END IF;
/*
                 next member
*/
                v_member := gv_member(v_member).next;
        END LOOP;
        RETURN v_set2;
END select_set;
/*
 Select N members from an ordered set
*/
FUNCTION select_N_members (
        p_members       IN NUMBER,
        p_set1          IN BINARY_INTEGER,
        p_order_by_rule IN NUMBER )
RETURN BINARY_INTEGER IS        /* set number */
        v_member        BINARY_INTEGER;
        v_set2  BINARY_INTEGER;
        v_set3  BINARY_INTEGER;
        v_result        IGS_RU_ITEM.value%TYPE;
        v_tds           r_tds;
        v_count NUMBER := 0;
BEGIN
        IF p_members >= members(p_set1)
        THEN
/*
                 don't bother trying
*/
                RETURN p_set1;
        END IF;
        v_set2 := new_set;
        v_set3 := p_set1;
        FOR v_ii IN 1 .. p_members      /* can never be more than p_member times */
        LOOP
/*
                 populate structure, target set number
*/
                v_tds.set_number := v_set3;
                v_member := gv_set(v_set3).first;
                LOOP
/*
                         check if last (must do check for null)
*/
                        IF v_member IS NULL
                        THEN
/*
                                 yep, last member
*/
                                EXIT;
                        END IF;
/*
                         populate structure, target set member
*/
                        v_tds.member_index := v_member;
                        v_tds.unit_cd := gv_member(v_member).f1;
                        v_tds.unit_version := gv_member(v_member).f2;
                        v_tds.cal_type := gv_member(v_member).f3;
                        v_tds.ci_sequence_number := gv_member(v_member).f4;
                        v_tds.uoo_id := gv_member(v_member).f5;
/*
                         evaluate attribute criteria rule
*/
                        v_result := RTRIM(turing(p_order_by_rule,v_tds));
                        IF v_result = 'true'
                        THEN
                                v_set2 := add_member(v_set2,
                                                gv_member(v_member).f1,
                                                gv_member(v_member).f2,
                                                gv_member(v_member).f3,
                                                gv_member(v_member).f4,
                                                gv_member(v_member).f5);
                                v_count := v_count + 1;
                                IF v_count >= p_members
                                THEN
                                        RETURN v_set2;
                                END IF;
                        ELSIF v_result = 'false'
                        THEN
                                null;
                        ELSE
                                log_error('select_N_set',
                                        'Invalid condition rule return ('||v_result||')'||Fnd_Global.Local_Chr(10)||
                                        'rule='||p_order_by_rule);
                        END IF;
/*
                         next member
*/
                        v_member := gv_member(v_member).next;
                END LOOP;
/*
                Remove selected members from target set
*/
                v_set3 := set_minus(v_set3,v_set2);
        END LOOP;
        RETURN v_set2;
END select_N_members;
/*
 Sum according to attribute rule
*/
FUNCTION sum_func(
        p_set1                  IN BINARY_INTEGER,
        p_attribute_rule        IN NUMBER )
RETURN BINARY_INTEGER IS
        v_member        BINARY_INTEGER;
        v_result        NUMBER;
        v_tds           r_tds;
BEGIN
        v_result := 0;
        v_member := gv_set(p_set1).first;
        LOOP
/*
                 check if last (must do check for null)
*/
                IF v_member IS NULL
                THEN
/*
                         yep, last member
*/
                        EXIT;
                END IF;
/*
                 populate structure, target set member
*/
                v_tds.member_index := v_member;
                v_tds.unit_cd := gv_member(v_member).f1;
                v_tds.unit_version := gv_member(v_member).f2;
                v_tds.cal_type := gv_member(v_member).f3;
                v_tds.ci_sequence_number := gv_member(v_member).f4;
                v_tds.uoo_id := gv_member(v_member).f5;
/*
                 sum evaluated attribute rule
*/
                v_result := v_result + turing(p_attribute_rule,v_tds);
/*
                 next member
*/
                v_member := gv_member(v_member).next;
        END LOOP;
        RETURN v_result;
END sum_func;
/*
 append set2 to set1
*/
FUNCTION append_to_set (
        p_set1  BINARY_INTEGER,
        p_set2  BINARY_INTEGER )
RETURN BINARY_INTEGER IS
        v_member        BINARY_INTEGER;
        v_set1          BINARY_INTEGER;
BEGIN
        v_member := gv_set(p_set2).first;
        LOOP
/*
                 check if last (must do check for null)
*/
                IF v_member IS NULL
                THEN
/*
                         yep, last member
*/
                        EXIT;
                END IF;
                v_set1 := add_member(p_set1,
                                gv_member(v_member).f1,
                                gv_member(v_member).f2,
                                gv_member(v_member).f3,
                                gv_member(v_member).f4,
                                gv_member(v_member).f5);
/*
                 next member
*/
                v_member := gv_member(v_member).next;
        END LOOP;
        RETURN p_set1;
END append_to_set;
/*
 for all members of the set create an expanded set according to the rule
*/
FUNCTION for_expand(
        p_set1          IN BINARY_INTEGER,
        p_rule_number   IN NUMBER )
RETURN BINARY_INTEGER IS
        v_member        BINARY_INTEGER;
        v_set1          BINARY_INTEGER;
        v_tds           r_tds;
        v_prev_f1       VARCHAR2(10) ;
        v_prev_f2       VARCHAR2(10) ;
BEGIN
        --smvk        29-Nov-2004     File.Sql.35 warning fix.
        v_prev_f1 := '@$%!*(|';
        v_prev_f2 := '@$%!*(|';

        v_set1 := new_set;
/*
         the expansion of a set is only meaninful for unit and version 99/06/07
*/
        v_member := gv_set(p_set1).first;
        LOOP
/*
                 check if last (must do check for null)
*/
                IF v_member IS NULL
                THEN
/*
                         yep, last member
*/
                        EXIT;
                END IF;
                IF NOT (gv_member(v_member).f1 = v_prev_f1 AND
                        gv_member(v_member).f2 = v_prev_f2)
                THEN
/*
                         populate stucture, target set member
*/
                        v_tds.member_index := v_member;
                        v_tds.unit_cd := gv_member(v_member).f1;
                        v_tds.unit_version := gv_member(v_member).f2;
                        v_tds.cal_type := gv_member(v_member).f3;
                        v_tds.ci_sequence_number := gv_member(v_member).f4;
                        v_tds.uoo_id := gv_member(v_member).f5;
/*
                         append evaluated set rule
*/
                        v_set1 := append_to_set(v_set1,turing(p_rule_number,v_tds));
                        v_prev_f1 := gv_member(v_member).f1;
                        v_prev_f2 := gv_member(v_member).f2;
                END IF;
/*
                 next member
*/
                v_member := gv_member(v_member).next;
        END LOOP;
        RETURN v_set1;
END for_expand;
/*
 expand set and add original set
*/

/* out NOCOPY not used 99/06/28
FUNCTION for_union(
        p_set1          IN BINARY_INTEGER,
        p_rule_number   IN NUMBER )
RETURN NUMBER IS
        v_set1  BINARY_INTEGER;
BEGIN
        v_set1 := for_expand(p_set1,p_rule_number);
        v_set1 := set_union(v_set1,p_set1);
        RETURN v_set1;
END for_union;
*/
/*
 repeat expand until nothing left to expand
*/
FUNCTION cascade_expand (
        p_expanded      IN BINARY_INTEGER,      /* previously expanded set     */
        p_expand        IN BINARY_INTEGER,      /* set to expand               */
        p_rule_number   IN NUMBER )             /* the rule by which to expand */
RETURN BINARY_INTEGER IS
        v_expanded      BINARY_INTEGER; /* expanded set        */
        v_tot_expanded  BINARY_INTEGER; /* total expanded set  */
        v_unexpanded    BINARY_INTEGER; /* unexpanded set      */
BEGIN
        v_expanded := for_expand(p_expand,p_rule_number);
        v_tot_expanded := set_union(p_expanded,p_expand);
        v_unexpanded := set_minus(v_expanded,v_tot_expanded);
        IF members(v_unexpanded) > 0
        THEN
                RETURN cascade_expand(v_tot_expanded,v_unexpanded,p_rule_number);
        END IF;
        RETURN v_tot_expanded;
END cascade_expand;
/*
 return the specified (1-4) field value of the first member of the set
 this is used for recursive set manipulation
*/
FUNCTION set_field_val (
        p_member        IN BINARY_INTEGER,
        p_field         IN NUMBER )
RETURN VARCHAR2 IS
BEGIN
        IF p_field = 1 THEN RETURN gv_member(p_member).f1;
        ELSIF p_field = 2 THEN RETURN gv_member(p_member).f2;
        ELSIF p_field = 3 THEN RETURN gv_member(p_member).f3;
        ELSIF p_field = 4 THEN RETURN gv_member(p_member).f4;
        ELSIF p_field = 5 THEN RETURN gv_member(p_member).f5;
        END IF;
        RETURN 'NO FIELD '||p_field;
END set_field_val;
/*
 IF THEN ELSE FUNCTIONS

 return the first member of the set
 this is used for recursive set manipulation
*/
FUNCTION first (
        p_set1  IN BINARY_INTEGER )
RETURN BINARY_INTEGER IS
        v_member        BINARY_INTEGER;
BEGIN
        v_member := gv_set(p_set1).first;
        RETURN add_member(new_set,
                        gv_member(v_member).f1,
                        gv_member(v_member).f2,
                        gv_member(v_member).f3,
                        gv_member(v_member).f4,
                        gv_member(v_member).f5);
END first;
/*
 if then else
*/
FUNCTION ifthenelse(
        p_conditional   IN VARCHAR2,
        p_then_rule     IN NUMBER,
        p_else_rule     IN NUMBER,
        p_tds           IN r_tds )
RETURN VARCHAR2 IS
  /*************************************************************
  Created By : nsinha
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  Navin           27-Aug-2001     Added a package variable igs_ru_gen_001.p_evaluated_part
                                  as part of Bug# : 1899513.
  (reverse chronological order - newest change first)
  ***************************************************************/

        v_count NUMBER;
BEGIN
        IF RTRIM(p_conditional) = 'true'
        THEN
                igs_ru_gen_001.p_evaluated_part := 'IF';
                RETURN (turing(p_then_rule,p_tds));
        ELSIF RTRIM(p_conditional) = 'false'
        THEN
                igs_ru_gen_001.p_evaluated_part := 'ELSE';
                RETURN (turing(p_else_rule,p_tds));
        ELSE
                log_error('ifthenelse',
                        'Invalid condition ('||p_conditional||')');
        END IF;
END ifthenelse;

/*
 if then
*/
FUNCTION ifthen(
        p_conditional   IN VARCHAR2,
        p_then_rule     IN NUMBER,
        p_tds           IN r_tds )
RETURN VARCHAR2 IS
  /*************************************************************
  Created By : nsinha
  Date Created By : 27-Aug-2001
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  Navin           27-Aug-2001     Added this function to support a rule of
                                  type IF <condition> THEN <action>.
                                  This change is as per requirement of Bug# : 1899513.
  (reverse chronological order - newest change first)
  ***************************************************************/
BEGIN
        IF RTRIM(p_conditional) = 'true'
        THEN
                igs_ru_gen_001.p_evaluated_part := 'IF';
                RETURN (turing(p_then_rule,p_tds));
        ELSIF RTRIM(p_conditional) = 'false'
        THEN
                igs_ru_gen_001.p_evaluated_part := 'ELSE';
                RETURN NULL;
        ELSE
                log_error('ifthen',
                        'Invalid condition (' || p_conditional|| ')');
        END IF;
END ifthen;

  FUNCTION prgpl_chk_gsch_exists (
    p_grading_schema_cd IN VARCHAR2,
    p_grade IN VARCHAR2,
    p_set_number IN BINARY_INTEGER
  ) RETURN VARCHAR2 IS
    /**********************************************************************************************
     Created By      :   rbezawad
     Date Created By :   20-Nov-2001
     Purpose         :   Local function to check if a supplied grading schema and grade exists in the rule set.
                         Created W.r.t Progression Rules Enhancement Build, Bug No: 2146547.

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    *************************************************************************************************/

    l_member BINARY_INTEGER;

  BEGIN

    -- Get the first member defined as part of the rule set
    l_member := gv_set(p_set_number).first;

    -- Loop thru all the members in gv_set and exit when there are no records in the
    -- global plsql record group gv_member(l_member).f1 ( grading schema code ).
    LOOP
      -- Check if the member is last or not.
      IF l_member IS NULL THEN
        -- If it is Last member then Exit loop and return FALSE.
        EXIT;
      END IF;

      -- check if a supplied grading schema and grade exists in the rule set
      IF p_grading_schema_cd ||'.'||p_grade = gv_member(l_member).F1||'.'||gv_member(l_member).f2 THEN
        RETURN 'true';
      END IF;

      -- Get Next member
      l_member := gv_member(l_member).NEXT;
    END LOOP;

    RETURN 'false';

  END prgpl_chk_gsch_exists;

------------------------Gjha Added for Class Rank Build ---------------------------------------

FUNCTION prgp_chk_chrt_exists (
    p_prg_stat IN VARCHAR2,
    p_set_number IN BINARY_INTEGER
  ) RETURN VARCHAR2 IS

    l_member BINARY_INTEGER;

  BEGIN
    -- Get the first member defined as part of the rule set
      l_member := gv_set(p_set_number).first;
    -- Loop thru all the members in PRG_STAT and exit when there are no records in the
    -- global plsql record group gv_member(l_member).f1 ( grading schema code ).
    LOOP
      -- Check if the member is last or not.
      IF l_member IS NULL THEN
        -- If it is Last member then Exit loop and return FALSE.
        EXIT;
      END IF;

      -- check if a supplied grading schema and grade exists in the rule set
      IF p_prg_stat  = gv_member(l_member).F1 THEN
        RETURN 'true';
      END IF;

      -- Get Next member
      l_member := gv_member(l_member).NEXT;
    END LOOP;
    RETURN 'false';

  END prgp_chk_chrt_exists;
  ------------------------Gjha Added for Class Rank Build ---------------------------------------

  --
  -- Function to calculate the statistics credit points based on the rules defined in the system
  --
  FUNCTION sua_credit_points_st (
    p_rule_type  IN VARCHAR2,
    p_statistic_type IN VARCHAR2,
    p_number IN NUMBER,
    p_progression_period IN NUMBER
  ) RETURN VARCHAR2 IS
  ------------------------------------------------------------------------------
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  -- Who      When        What
  -- smvk     29-Nov-2004 File.Sql.35 warning fix.
  -- kdande   11-Nov-2002 Created the function as part of Progression Rules
  --                      Enhancement for Financial Aid for Jan 2003 Release
  -- ijeddy   11/23/2005  Bug 4754335, modified cur_sua
  ------------------------------------------------------------------------------

    CURSOR cur_sua IS
      SELECT   sua.unit_cd,
               sua.version_number,
               sua.cal_type,
               sua.ci_sequence_number,
               sua.uoo_id
      FROM     igs_en_su_attempt sua,
               igs_ca_inst_rel cir,
               igs_ca_type cat,
               igs_ca_inst ci1,
               igs_ca_inst ci2
      WHERE    sua.person_id = p_person_id
      AND      sua.course_cd = p_course_cd
      AND      sua.cal_type = cir.sub_cal_type
      AND      sua.ci_sequence_number = cir.sub_ci_sequence_number
      AND      ci1.cal_type = cir.sup_cal_type
      AND      ci1.sequence_number = cir.sup_ci_sequence_number
      AND      ci1.cal_type = cat.cal_type
      AND      cat.s_cal_cat = 'PROGRESS'
      AND      ci2.cal_type = p_cal_type
      AND      ci2.sequence_number = p_ci_sequence_number
      AND      ci1.start_dt <= ci2.start_dt;

    --
    v_unit_attempt_status   IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE;
    v_override_achievable_cp IGS_EN_SU_ATTEMPT.override_achievable_cp%TYPE;
    v_outcome_dt            IGS_AS_SU_STMPTOUT.outcome_dt%TYPE;
    v_grading_schema_cd     IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
    v_gs_version_number     IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
    v_grade                 IGS_AS_GRD_SCH_GRADE.grade%TYPE;
    v_mark                  IGS_AS_SU_STMPTOUT.mark%TYPE;
    v_original_course_cd    IGS_EN_SU_ATTEMPT.course_cd%TYPE;
    v_result                VARCHAR2(30);
    l_progression_period NUMBER ;
    l_failed_cp NUMBER := 0;
    l_attempted_cp NUMBER  := 0;
    l_earned_cp  NUMBER := 0;
    l_total_attempted_cp NUMBER := 0;
    l_flag VARCHAR2(1);
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    --
  BEGIN
    l_progression_period := NVL (p_progression_period, 0);
    l_flag := 'Y';
    --
    FOR sua_rec IN cur_sua
    LOOP
      l_flag := 'Y';
      IF (p_rule_type IN ('NCPCPP', 'NCPPNPP')) THEN
        l_flag := igs_pr_gen_002.prgp_get_sua_prg_num (
                    p_cal_type,
                    p_ci_sequence_number,
                    p_progression_period + 1,
                    p_person_id,
                    p_course_cd,
                    sua_rec.unit_cd,
                    sua_rec.cal_type,
                    sua_rec.ci_sequence_number,
                    sua_rec.uoo_id
                  );
      END IF;
      IF (l_flag = 'Y') THEN
        igs_pr_cp_gpa.get_sua_cp (
          p_person_id                    => p_person_id,
          p_course_cd                    => p_course_cd,
          p_unit_cd                      => sua_rec.unit_cd,
          p_unit_version_number          => sua_rec.version_number,
          p_teach_cal_type               => sua_rec.cal_type,
          p_teach_ci_sequence_number     => sua_rec.ci_sequence_number,
          p_stat_type                    => p_statistic_type,
          p_system_stat                  => 'PROGRESSION',
          p_earned_cp                    => l_earned_cp,
          p_attempted_cp                 => l_attempted_cp ,
          p_return_status                => l_return_status,
          p_msg_count                    => l_msg_count,
          p_msg_data                     => l_msg_data,
          p_uoo_id                       => sua_rec.uoo_id
        );
        -- Calculate the total cp attempted:
        l_total_attempted_cp := NVL (l_total_attempted_cp, 0) + NVL (l_attempted_cp, 0);
        -- Get the unit attempt status
        SELECT  unit_attempt_status,
                override_achievable_cp
        INTO    v_unit_attempt_status,
                v_override_achievable_cp
        FROM    igs_en_su_attempt
        WHERE   person_id = p_person_id
        AND     course_cd = p_course_cd
        AND     uoo_id = sua_rec.uoo_id;
        -- Get the outcome of the unit attempt
        v_result := igs_as_gen_003.assp_get_sua_outcome (
                      p_person_id,
                      p_course_cd,
                      sua_rec.unit_cd,
                      sua_rec.cal_type,
                      sua_rec.ci_sequence_number,
                      v_unit_attempt_status,
                      'N', /*  finalised indicator (make parameter ??) */
                      v_outcome_dt,
                      v_grading_schema_cd,
                      v_gs_version_number,
                      v_grade,
                      v_mark,
                      v_original_course_cd,
                      sua_rec.uoo_id,
---added by LKAKI---
                      'N');
        -- If the student has failed the unit, increment the Failed points.
        IF (v_result = 'FAIL') THEN
          l_failed_cp := NVL (l_failed_cp, 0) + NVL (l_attempted_cp, 0);
        END IF;
      END IF;
    END LOOP;
    -- Total attempted and failed CPs are calculated : See the rule
    IF ((NVL (l_failed_cp, 0)/NVL (l_total_attempted_cp, 0)) * 100 > p_number) THEN
      return 'true';
    ELSE
      return 'false';
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    WHEN ZERO_DIVIDE THEN
      RETURN 'true';
  END sua_credit_points_st;
  --
  -- Function to calculate the statistics based on the rules defined in the system
  --
  FUNCTION prgp_cal_stat (
    p_rule_type                   IN VARCHAR2,
    p_statistic_type              IN VARCHAR2,
    p_statistic_element           IN VARCHAR2,
    p_number                      IN NUMBER
  ) RETURN VARCHAR2 IS
  ------------------------------------------------------------------------------
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  -- Who      When        What
  -- kdande   11-Nov-2002 Created the function as part of Progression Rules
  --                      Enhancement for Financial Aid for Jan 2003 Release
  ------------------------------------------------------------------------------
    --Cursor to fetch the Load calendar corresponding to the Progression Calendar.
    CURSOR c_cir (cp_prg_cal_type        igs_ca_inst.cal_type%TYPE,
                  cp_prg_sequence_number igs_ca_inst.sequence_number%TYPE) IS
    SELECT cir.sub_cal_type cal_type, cir.sub_ci_sequence_number ci_sequence_number
    FROM   IGS_CA_INST     ci ,
           IGS_CA_INST_REL cir,
           IGS_CA_TYPE     cat,
           IGS_CA_STAT     cs
    WHERE  cir.sup_cal_type           = cp_prg_cal_type
    AND    cir.sup_ci_sequence_number = cp_prg_sequence_number
    AND    ci.cal_type                = cir.sub_cal_type
    AND    ci.sequence_number         = cir.sub_ci_sequence_number
    AND    cat.cal_type               = ci.cal_type
    AND    cat.s_cal_cat              = 'LOAD'
    AND    cs.CAL_STATUS              = ci.CAL_STATUS
    AND    cs.s_CAL_STATUS            = 'ACTIVE';
    rec_cir c_cir%ROWTYPE;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    v_gpa_value NUMBER;
    v_gpa_cp NUMBER;
    v_gpa_quality_points NUMBER;
    v_earned_cp NUMBER;
    v_attempted_cp NUMBER;
    l_cumulative_ind VARCHAR2(1);
  BEGIN
    IF p_rule_type IN ('PLT','PMT') THEN
      l_cumulative_ind := 'N';
    ELSE
      l_cumulative_ind := 'Y';
    END IF;
    IF (p_statistic_element IN ('GPA', 'GPA CP', 'GPA QP')) THEN
      -- Start of new code added to fix Bug# 3103892; nalkumar; 20-Aug-2003
      --
      OPEN c_cir(p_cal_type, p_ci_sequence_number);
      FETCH c_cir INTO rec_cir;
      CLOSE c_cir;
      --
      -- End of new code added to fix Bug# 3103892; nalkumar; 20-Aug-2003
      igs_pr_cp_gpa.get_gpa_stats (
        p_person_id                   => p_person_id, -- Person ID passed as the parameter for rulp_val_senna,
        p_course_cd                   => p_course_cd, -- Course code passed as the parameter for rulp_val_senna,
        p_stat_type                   => p_statistic_type, -- Statistic type defined in the rule.
        p_load_cal_type               => rec_cir.cal_type,     -- Load Calendar drived by the above cursor
        p_load_ci_sequence_number     => rec_cir.ci_sequence_number, -- Load Calendar Instance drived by the above cursor
        p_system_stat                 => NULL, -- System Statistics Type
        p_cumulative_ind              => l_cumulative_ind,
        p_gpa_value                   => v_gpa_value,
        p_gpa_cp                      => v_gpa_cp,
        p_gpa_quality_points          => v_gpa_quality_points,
        p_return_status               => l_return_status,
        p_msg_count                   => l_msg_count,
        p_msg_data                    => l_msg_data
      );
      IF p_rule_type IN ('PLT', 'CLT') THEN
        IF (p_statistic_element = 'GPA') THEN
          IF (v_gpa_value < p_number) THEN
            RETURN 'true';
          ELSE
            RETURN 'false';
          END IF;
        ELSIF (p_statistic_element = 'GPA CP') THEN
          IF (v_gpa_cp < p_number) THEN
            RETURN 'true';
          ELSE
            RETURN 'false';
          END IF;
        ELSIF (p_statistic_element = 'GPA QP') THEN
          IF (v_gpa_quality_points < p_number) THEN
            RETURN 'true';
          ELSE
            RETURN 'false';
          END IF;
        END IF;
      ELSIF p_rule_type IN ('PMT', 'CMT') THEN
        IF (p_statistic_element = 'GPA') THEN
          IF (v_gpa_value > p_number) THEN
            RETURN 'true';
          ELSE
            RETURN 'false';
          END IF;
        ELSIF (p_statistic_element = 'GPA CP') THEN
          IF (v_gpa_cp > p_number) THEN
            RETURN 'true';
          ELSE
            RETURN 'false';
          END IF;
        ELSIF (p_statistic_element = 'GPA QP') THEN
          IF (v_gpa_quality_points > p_number) THEN
            RETURN 'true';
          ELSE
            RETURN 'false';
          END IF;
        END IF;
      END IF;
    ELSIF (p_statistic_element IN ('CP_ATTEMPTED', 'CP_EARNED')) THEN
      -- Start of new code added to fix Bug# 3103892; nalkumar; 20-Aug-2003
      --
      OPEN c_cir(p_cal_type, p_ci_sequence_number);
      FETCH c_cir INTO rec_cir;
      CLOSE c_cir;
      --
      -- End of new code added to fix Bug# 3103892; nalkumar; 20-Aug-2003
      igs_pr_cp_gpa.get_cp_stats (
        p_person_id                   => p_person_id, -- Person ID passed as the parameter for rulp_val_senna,
        p_course_cd                   => p_course_cd, -- Course code passed as the parameter for rulp_val_senna,
        p_stat_type                   => p_statistic_type, -- Statistic type defined in the rule.
        p_load_cal_type               => rec_cir.cal_type,     -- Load Calendar drived by the above cursor
        p_load_ci_sequence_number     => rec_cir.ci_sequence_number, -- Load Calendar Instance drived by the above cursor
        p_system_stat                 => NULL, -- System Statistics Type
        p_cumulative_ind              => l_cumulative_ind,
        p_earned_cp                   => v_earned_cp,
        p_attempted_cp                => v_attempted_cp,
        p_return_status               => l_return_status,
        p_msg_count                   => l_msg_count,
        p_msg_data                    => l_msg_data
      );
      IF p_rule_type IN ('PLT', 'CLT') THEN
        IF (p_statistic_element = 'CP_ATTEMPTED') THEN
          IF (v_attempted_cp < p_number) THEN
            RETURN 'true';
          ELSE
            RETURN 'false';
          END IF;
        ELSIF (p_statistic_element = 'CP_EARNED') THEN
          IF (v_earned_cp < p_number) THEN
            RETURN 'true';
          ELSE
            RETURN 'false';
          END IF;
        END IF;
      ELSIF p_rule_type IN ('PMT', 'CMT') THEN
        IF (p_statistic_element = 'CP_ATTEMPTED') THEN
          IF (v_attempted_cp > p_number) THEN
            RETURN 'true';
          ELSE
            RETURN 'false';
          END IF;
        ELSIF (p_statistic_element = 'CP_EARNED') THEN
          IF (v_earned_cp > p_number) THEN
            RETURN 'true';
          ELSE
            RETURN 'false';
          END IF;
        END IF;
      END IF;
    END IF;
    RETURN 'false';
  END prgp_cal_stat;
  --
  FUNCTION prgp_get_chrt ( p_rule IN VARCHAR2,
                        p_set_number IN BINARY_INTEGER
                        ) RETURN VARCHAR2 IS
-- Cursor to get the Progression status of the student  This will return only one row: since there is a join based on person ID and Course Code
-- nalkumar ** CURSOR CUR_PRG_STAT IS SELECT PV.RESPONSIBLE_ORG_UNIT_CD, PA.PROGRESSION_STATUS FROM
CURSOR cur_prg_stat IS
SELECT pa.progression_status, pv.responsible_org_unit_cd
FROM igs_en_stdnt_ps_att pa, igs_ps_ver pv
WHERE pv.course_cd = pa.course_cd and pv.version_number = pa.version_number and pa.person_id = p_person_id and pa.course_cd = p_course_cd;


-- CURSOR TO SELECT THE PERSON id GROUPS TO WHICH THE STUDENT BELONGS
CURSOR CUR_PID IS  SELECT  G.GROUP_CD, PERSON_ID from IGS_PE_PRSID_GRP_MEM M, IGS_PE_PERSID_GROUP G WHERE
G.GROUP_ID = M.GROUP_ID AND SYSDATE BETWEEN M.START_DATE AND NVL(M.END_DATE, SYSDATE+1)
AND M.PERSON_ID = P_PERSON_ID ;

--Cursor to get all the unit sets attempted by the student
CURSOR USET_CUR IS SELECT UNIT_SET_CD FROM IGS_AS_SU_SETATMPT WHERE PERSON_ID = P_PERSON_ID  AND COURSE_CD = P_COURSE_CD;

--Cursor to get the ceremony rounds of the student
-- nalkumar ** CURSOR CUR_GRD_RND IS select rpad(GRD_CAL_TYPE,10)||rpad(GRD_CI_SEQUENCE_NUMBER,6) GRAD_ROUND  from IGS_GR_AWD_CRMN WHERE PERSON_ID = P_PERSON_ID ;
CURSOR CUR_GRD_RND IS select GRD_CAL_TYPE||GRD_CI_SEQUENCE_NUMBER GRAD_ROUND  from IGS_GR_AWD_CRMN WHERE PERSON_ID = P_PERSON_ID ;


lv_Group_id IGS_PE_PERSID_GROUP.GROUP_CD%TYPE;
lv_progression_status IGS_EN_STDNT_PS_ATT_ALL.PROGRESSION_STATUS%TYPE;
lv_org_unit  IGS_PS_VER.RESPONSIBLE_ORG_UNIT_CD%TYPE;
lv_Unit_set_cd IGS_AS_SU_SETATMPT.UNIT_SET_CD%TYPE;
lv_att_type VARCHAR2(30);
lv_class_standing varchar2(30);


  BEGIN
-------------------------------------------------
    IF p_rule = 'PRGST' OR p_rule = 'NPRGST' Then
            OPEN CUR_PRG_STAT;
            FETCH  CUR_PRG_STAT INTO lv_progression_status, lv_org_unit ;
            CLOSE CUR_PRG_STAT;
        IF prgp_chk_chrt_exists(lv_progression_status, p_set_number) = 'true' THEN
           IF p_rule = 'PRGST' Then
                      RETURN 'true';
           ELSE
              RETURN 'false';
           END IF;
         ELSE
           IF p_rule = 'NPRGST' Then --**
             RETURN 'true'; --**
           END IF; --**
          RETURN 'false';
        END IF;

    ELSIF  (p_rule = 'ORG' OR p_rule = 'NORG') THEN
            OPEN CUR_PRG_STAT;
            FETCH  CUR_PRG_STAT INTO lv_progression_status, lv_org_unit ;
            CLOSE CUR_PRG_STAT;

         IF prgp_chk_chrt_exists(lv_org_unit, p_set_number) = 'true' THEN
           IF p_rule = 'ORG' THEN
             RETURN 'true';
           ELSE
             RETURN 'false';
           END IF;
         ELSE
           IF p_rule = 'NORG' THEN --**
             RETURN 'true'; --**
           END IF; --**
           RETURN 'false';
         END IF;

  ELSIF  (p_rule = 'CRS' OR p_rule = 'NCRS') Then
        IF prgp_chk_chrt_exists(p_course_cd, p_set_number) = 'true' THEN
           IF p_rule = 'CRS' THEN
                      RETURN 'true';
           ELSE
              RETURN 'false';
           END IF;
        ELSE
           IF p_rule = 'NCRS' Then --**
             RETURN 'true'; --**
           END IF; --**
          RETURN 'false';
        END IF;

  ELSIF  (p_rule = 'PIDST' OR p_rule = 'NPIDST') Then
 --  Get the person ID group of the student and Loop
    FOR PID_REC IN CUR_PID LOOP
     IF prgp_chk_chrt_exists(PID_REC.GROUP_CD, p_set_number) = 'true' THEN
                IF p_rule = 'PIDST'  THEN
                  return 'true';
                 ELSIF p_rule ='NPIDST'  THEN
                        return 'false';
                END IF;
       END IF;
       END LOOP;
        IF p_rule = 'PIDST'  THEN
                return 'false';
        ELSE
          RETURN 'true';
        END IF;

  ELSIF  p_rule = 'UNST' OR p_rule = 'NUNST' Then
 --  Get all the unit sets attempted by the students for the given program attempt and Loop
    FOR USET_REC IN USET_CUR LOOP
     IF prgp_chk_chrt_exists(USET_REC.UNIT_SET_CD, p_set_number) = 'true' THEN
                IF p_rule = 'UNST'  THEN
                  return 'true';
                 ELSIF p_rule ='NUNST' THEN
                        return 'false';
                END IF;
       END IF;
       END LOOP;
        IF p_rule = 'UNST' then
                return 'false';
        ELSE
          RETURN 'true';
        END IF;


ELSIF  p_rule = 'GRDN' OR p_rule = 'NGRDN' Then

 --  Get all the Graduation round of the student  and Loop
    FOR GRDN_REC IN CUR_GRD_RND LOOP
     IF prgp_chk_chrt_exists(GRDN_REC.GRAD_ROUND, p_set_number) = 'true' THEN
                IF p_rule = 'GRDN'  THEN
                  return 'true';
                 ELSIF p_rule ='NGRDN' THEN
                        return 'false';
                END IF;
     END IF;
   END LOOP;
       IF p_rule = 'GRDN' then
          return 'false';
       ELSE
         RETURN 'true';
       END IF;

    ELSIF  p_rule = 'ATTTYP' OR p_rule = 'NATTTYP' Then
--Get the attendance Type of the student for a program attempt  into l_att_type

         lv_att_type := igs_en_prc_load.ENRP_GET_PRG_ATT_TYPE
                (
                P_PERSON_ID => P_PERSON_ID,
                P_COURSE_CD => P_COURSE_CD,
                P_CAL_TYPE   => P_CAL_TYPE,
                P_SEQUENCE_NUMBER => P_CI_SEQUENCE_NUMBER
                );

       IF prgp_chk_chrt_exists( lv_att_type, p_set_number) = 'true' THEN
           IF p_rule = 'ATTTYP' THEN
               RETURN 'true';
           ELSE
              RETURN 'false';
           END IF;
       ELSE
         IF p_rule = 'NATTTYP' THEN
           RETURN 'true';
         END IF;
         RETURN 'false';
       END IF ;

 ELSIF  p_rule = 'CLSSTD' OR p_rule = 'NCLSSTD' Then
--      Get the class standing of the student for  a program attempt  into lv_class standing . Make use of the function igs_pr_get_class_std.get_class_standing.

        lv_class_standing := igs_pr_get_class_std.GET_CLASS_STANDING
                 (
                P_PERSON_ID               => P_PERSON_ID,
                P_COURSE_CD               => P_COURSE_CD,
                P_PREDICTIVE_IND          => 'Y',
                P_EFFECTIVE_DT            => NULL,
                P_LOAD_CAL_TYPE           => P_CAL_TYPE,
                P_LOAD_CI_SEQUENCE_NUMBER => P_CI_SEQUENCE_NUMBER
                 );

        IF prgp_chk_chrt_exists( lv_class_standing, p_set_number) = 'true' THEN
           IF p_rule = 'CLSSTD' THEN
              RETURN 'true';
           ELSE
             RETURN 'false';
           END IF;
        ELSE
          IF p_rule = 'NCLSSTD' THEN
            RETURN 'true';
          END IF;
          RETURN 'false';
        END IF           ;
 END IF; -- End If for Rule codes..

 END prgp_get_chrt;
----------------------------------Gjha Added For Class Rank-------------------------------------

  FUNCTION prgp_cal_cp_gsch (
    p_rule_type IN VARCHAR2,
    p_person_id IN NUMBER,
    p_course_cd IN VARCHAR2,
    p_course_version IN NUMBER,
    p_prg_cal_type   IN VARCHAR2,
    p_prg_ci_sequence_number IN NUMBER,
    p_grad_sch_set_no IN NUMBER,
    p_cp_in_rule IN NUMBER,
    p_cp_result OUT NOCOPY NUMBER,
    p_stat_type IN VARCHAR2
  ) RETURN VARCHAR2 IS

    /**********************************************************************************************
     Created By      :   rbezawad
     Date Created By :   20-Nov-2001
     Purpose         :   This procedure is used to calculate the credit points or units for
                         a student in context for the rules evaluation.
                         Created W.r.t Progression Rules Enhancement Build, Bug No: 2146547.
     Known limitations,enhancements,remarks:
     Change History
     Who     When         What
     smvk    29-Nov-2004  File.Sql.35 warning fix.
     smvk    02-Sep-2002  Default keyword is replaced by assignment operator (:=), to overcome File.Pkg.22 warning
                          As a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390).
     kdande  11-Nov-2002  Changed the code to handle the addition of Statistic Type for the Rules as
                          part of Progression Rules Enhancement for Financial Aid for Jan 2003 Release
    *************************************************************************************************/

    -- Get all the Student Unit Attempts for teaching periods subordinate
    -- to all Progression periods upto and including the current progression Period.
    CURSOR cur_sua_all_prd  IS
      SELECT sua.unit_cd,
             sua.version_number,
             sua.cal_type,
             sua.ci_sequence_number,
             sua.unit_attempt_status,
             uoo_id
      FROM   igs_en_su_attempt sua,
             igs_ca_inst       ci_cur,
             igs_ca_inst_rel   cir,
             igs_ca_inst       ci,
             igs_ca_type       ct
      WHERE  sua.person_id = p_person_id
      AND    sua.course_cd = p_course_cd
      AND    sua.unit_attempt_status = 'COMPLETED'
      AND    sua.cal_type = cir.sub_cal_type
      AND    sua.ci_sequence_number = cir.sub_ci_sequence_number
      AND    ci.cal_type = cir.sup_cal_type
      AND    ci.sequence_number = cir.sup_ci_sequence_number
      AND    ci.cal_type = ct.cal_type
      AND    ct.s_cal_cat = 'PROGRESS'
      AND    ci_cur.cal_type = p_prg_cal_type
      AND    ci_cur.sequence_number = p_prg_ci_sequence_number
      AND    ci.end_dt <= ci_cur.end_dt;

    -- Get all the Student Unit Attempts for teaching periods
    -- subordinate to only the Current Progression period.
    CURSOR cur_sua_curr_prd  IS
      SELECT sua.unit_cd,
             sua.version_number,
             sua.cal_type,
             sua.ci_sequence_number,
             sua.unit_attempt_status,
             uoo_id
      FROM   igs_en_su_attempt sua,
             igs_ca_inst_rel   cir
      WHERE  sua.person_id = p_person_id
      AND    sua.course_cd = p_course_cd
      AND    sua.unit_attempt_status = 'COMPLETED'
      AND    sua.cal_type = cir.sub_cal_type
      AND    sua.ci_sequence_number = cir.sub_ci_sequence_number
      AND    cir.sup_cal_type = p_prg_cal_type
      AND    cir.sup_ci_sequence_number = p_prg_ci_sequence_number;

    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_earned_cp igs_ps_unit_ver.achievable_credit_points%TYPE;
    l_attempted_cp igs_ps_unit_ver.achievable_credit_points%TYPE;
    l_result_type igs_as_grd_sch_grade.s_result_type%TYPE;

    --OUT varibales to be passed to igs_as_gen_003.assp_get_sua_outcomes Function
    l_outcome_dt        igs_as_su_stmptout.outcome_dt%TYPE;
    l_grading_schema_cd igs_as_grd_sch_grade.grading_schema_cd%TYPE;
    l_version_number    igs_as_grd_sch_grade.version_number%TYPE;
    l_grade             igs_as_grd_sch_grade.grade%TYPE;
    l_mark              igs_as_su_stmptout.mark%TYPE;
    l_origin_course_cd  igs_en_su_attempt.course_cd%TYPE;

    l_total_attempted_cp    NUMBER := 0;  -- Replaced Default by :=
    l_total_attempted_units NUMBER := 0;  -- Replaced Default by :=
    l_set_attempted_cp      NUMBER := 0;  -- Replaced Default by :=
    l_set_attempted_units   NUMBER := 0;  -- Replaced Default by :=
    l_stat_type VARCHAR2(30);
  BEGIN
      l_stat_type := p_stat_type;
    --
    IF p_rule_type IN ('ALL_PERD_PM', 'ALL_PERD_PL', 'ALL_PERDM', 'ALL_PERDL', 'ALL_PERD_UPM', 'ALL_PERD_UPL', 'ALL_PERD_UM', 'ALL_PERD_UL',
                       'ALL_PERD_PM_ST', 'ALL_PERD_PL_ST', 'ALL_PERDM_ST', 'ALL_PERDL_ST') THEN
      -- All Period Rules (Cumulative Rules)
      FOR l_sua_all_prd_rec IN cur_sua_all_prd LOOP
        -- To get the Earned and Attempted CP values for the Student Unit Attempt
        igs_pr_cp_gpa.get_sua_cp (
          p_person_id                => p_person_id,
          p_course_cd                => p_course_cd,
          p_unit_cd                  => l_sua_all_prd_rec.unit_cd,
          p_unit_version_number      => l_sua_all_prd_rec.version_number,
          p_teach_cal_type           => l_sua_all_prd_rec.cal_type,
          p_teach_ci_sequence_number => l_sua_all_prd_rec.ci_sequence_number,
          p_stat_type                => l_stat_type,
          p_system_stat              => 'PROGRESSION',
          p_earned_cp                => l_earned_cp,
          p_attempted_cp             => l_attempted_cp,
          p_return_status            => l_return_status,
          p_msg_count                => l_msg_count,
          p_msg_data                 => l_msg_data,
          p_uoo_id                   => l_sua_all_prd_rec.uoo_id
        );
        -- To get the Grading Schema Code for the Student Unit Attempt.
        l_result_type := igs_as_gen_003.assp_get_sua_outcome (
                           p_person_id,
                           p_course_cd,
                           l_sua_all_prd_rec.unit_cd,
                           l_sua_all_prd_rec.cal_type,
                           l_sua_all_prd_rec.ci_sequence_number,
                           l_sua_all_prd_rec.unit_attempt_status,
                           'Y',
                           l_outcome_dt,
                           l_grading_schema_cd,
                           l_version_number,
                           l_grade,
                           l_mark,
                           l_origin_course_cd,
                           l_sua_all_prd_rec.uoo_id,
--added by LKAKI---
                           'N');
        l_total_attempted_cp := l_total_attempted_cp + NVL(l_attempted_cp,0);
        l_total_attempted_units := l_total_attempted_units + 1;
        IF prgpl_chk_gsch_exists(l_grading_schema_cd, l_grade, p_grad_sch_set_no) = 'true' THEN
          -- If Grading Schema Code of the unit attempt exists in the Grading Schema Set of the
          -- Grading Schema Code defined in the rule then add the  Unit Attempt CP to the Set Attempted CP
          -- and increment the Set Attempted Units.
          l_set_attempted_cp := l_set_attempted_cp + NVL(l_attempted_cp,0);
          l_set_attempted_units := l_set_attempted_units + 1;
        END IF;
      END LOOP;
    ELSIF p_rule_type IN ('CUR_PERD_PM', 'CUR_PERD_PL', 'CUR_PERDM', 'CUR_PERDL', 'CUR_PERD_UPM', 'CUR_PERD_UPL', 'CUR_PERD_UM', 'CUR_PERD_UL',
                          'CUR_PERD_PM_ST', 'CUR_PERD_PL_ST', 'CUR_PERDM_ST', 'CUR_PERDL_ST') THEN
      -- Current Period Rules
      FOR l_sua_curr_prd_rec IN cur_sua_curr_prd LOOP
        -- To get the Earned and Attempted CP values for the Student Unit Attempt.
        igs_pr_cp_gpa.get_sua_cp (
          p_person_id                => p_person_id,
          p_course_cd                => p_course_cd,
          p_unit_cd                  => l_sua_curr_prd_rec.unit_cd,
          p_unit_version_number      => l_sua_curr_prd_rec.version_number,
          p_teach_cal_type           => l_sua_curr_prd_rec.cal_type,
          p_teach_ci_sequence_number => l_sua_curr_prd_rec.ci_sequence_number,
          p_stat_type                => l_stat_type,
          p_system_stat              => 'PROGRESSION',
          p_earned_cp                => l_earned_cp,
          p_attempted_cp             => l_attempted_cp,
          p_return_status            => l_return_status,
          p_msg_count                => l_msg_count,
          p_msg_data                 => l_msg_data,
          p_uoo_id                   => l_sua_curr_prd_rec.uoo_id );
        -- To get the Grading Schema Code for the Student Unit Attempt.
        l_result_type := igs_as_gen_003.assp_get_sua_outcome (
                           p_person_id,
                           p_course_cd,
                           l_sua_curr_prd_rec.unit_cd,
                           l_sua_curr_prd_rec.cal_type,
                           l_sua_curr_prd_rec.ci_sequence_number,
                           l_sua_curr_prd_rec.unit_attempt_status,
                           'Y',
                           l_outcome_dt,
                           l_grading_schema_cd,
                           l_version_number,
                           l_grade,
                           l_mark,
                           l_origin_course_cd,
                           l_sua_curr_prd_rec.uoo_id,
---added by LKAKI----
                           'N');
        l_total_attempted_cp := l_total_attempted_cp + NVL(l_attempted_cp,0);
        l_total_attempted_units := l_total_attempted_units + 1;
        IF prgpl_chk_gsch_exists(l_grading_schema_cd, l_grade, p_grad_sch_set_no) = 'true' THEN
          -- If Grading Schema Code of the unit attempt exists in the Grading Schema Set of the
          -- Grading Schema Code defined in the rule then add the  Unit Attempt CP to the Set Attempted CP
          -- and increment the Set Attempted Units.
          l_set_attempted_cp := l_set_attempted_cp + NVL(l_attempted_cp,0);
          l_set_attempted_units := l_set_attempted_units + 1;
        END IF;
      END LOOP;
    END IF;  -- p_rule_type check condition
    --
    -- CP Based Rules
    --
    IF p_rule_type IN ('ALL_PERD_PM', 'ALL_PERD_PM_ST', 'CUR_PERD_PM', 'CUR_PERD_PM_ST') THEN
      -- All/Current Period, Percent CP More Than.
      p_cp_result := (l_set_attempted_cp/l_total_attempted_cp)*100;
      IF ((l_set_attempted_cp/l_total_attempted_cp)*100) > p_cp_in_rule THEN
        RETURN 'true';
      ELSE
        RETURN 'false';
      END IF;
    ELSIF p_rule_type IN ('ALL_PERD_PL', 'ALL_PERD_PL_ST', 'CUR_PERD_PL', 'CUR_PERD_PL_ST') THEN
      -- All/Current Period, Percent CP Less Than.
      p_cp_result := (l_set_attempted_cp/l_total_attempted_cp)*100;
      IF  ((l_set_attempted_cp/l_total_attempted_cp)*100) < p_cp_in_rule THEN
        RETURN 'true';
      ELSE
        RETURN 'false';
      END IF;
    ELSIF p_rule_type IN ('ALL_PERDM', 'ALL_PERDM_ST', 'CUR_PERDM', 'CUR_PERDM_ST') THEN
      -- All/Current Period, Number CP More Than.
      p_cp_result := l_set_attempted_cp;
      IF ( l_set_attempted_cp > p_cp_in_rule ) THEN
        RETURN 'true';
      ELSE
        RETURN 'false';
      END IF;
    ELSIF p_rule_type IN ('ALL_PERDL', 'ALL_PERDL_ST', 'CUR_PERDL', 'CUR_PERDL_ST') THEN
      -- All/Current Period, Number CP Less Than.
      p_cp_result := l_set_attempted_cp;
      IF ( l_set_attempted_cp < p_cp_in_rule ) THEN
        RETURN 'true';
      ELSE
        RETURN 'false';
      END IF;
    --
    --  Unit Based Rules
    --
    ELSIF p_rule_type IN ('ALL_PERD_UPM', 'CUR_PERD_UPM') THEN
      -- All/Current Period, Percent Units More Than.
      p_cp_result := (l_set_attempted_units/l_total_attempted_units)*100;
      IF  ((l_set_attempted_units/l_total_attempted_units)*100) > p_cp_in_rule THEN
        RETURN 'true';
      ELSE
        RETURN 'false';
      END IF;
    ELSIF p_rule_type  IN ('ALL_PERD_UPL', 'CUR_PERD_UPL') THEN
      -- All/Current Period, Percent Units Less Than.
      p_cp_result := (l_set_attempted_units/l_total_attempted_units)*100;
      IF ((l_set_attempted_units/l_total_attempted_units)*100) < p_cp_in_rule THEN
        RETURN 'true';
      ELSE
        RETURN 'false';
      END IF;
    ELSIF p_rule_type IN ('ALL_PERD_UM', 'CUR_PERD_UM') THEN
      -- All/Current Period, Number Units More Than.
      p_cp_result := l_set_attempted_units;
      IF l_set_attempted_units > p_cp_in_rule THEN
        RETURN 'true';
      ELSE
        RETURN 'false';
      END IF;
    ELSIF p_rule_type IN ('ALL_PERD_UL', 'CUR_PERD_UL') THEN
      -- All/Current Period, Number Units Less Than.
      p_cp_result := l_set_attempted_units;
      IF l_set_attempted_units <  p_cp_in_rule THEN
        RETURN 'true';
      ELSE
        RETURN 'false';
      END IF;
    END IF; -- p_rule_type check condition
    RETURN 'true';
  EXCEPTION
    WHEN ZERO_DIVIDE THEN
      IF p_rule_type IN ('ALL_PERD_PM', 'CUR_PERD_PM', 'ALL_PERD_PM_ST', 'CUR_PERD_PM_ST', 'ALL_PERD_UPM', 'CUR_PERD_UPM') THEN
        RETURN 'false';
      ELSIF p_rule_type IN ('ALL_PERD_PL', 'CUR_PERD_PL', 'ALL_PERD_PL_ST', 'CUR_PERD_PL_ST', 'ALL_PERD_UPL', 'CUR_PERD_UPL') THEN
        RETURN 'true';
      END IF;
    WHEN OTHERS THEN
      RETURN 'false';
  END prgp_cal_cp_gsch;

  FUNCTION prgp_cal_cp(
    p_rule_type IN VARCHAR2,
    p_person_id IN NUMBER,
    p_course_cd IN VARCHAR2,
    p_course_version IN NUMBER,
    p_cal_type IN VARCHAR2,
    p_ci_sequence_number IN NUMBER)
  RETURN NUMBER AS
    /**********************************************************************************************
     Created By      :  svenkata
     Date Created By :  21-Nov-2001
     Purpose         :  The function calculates the credit points for a student in
                        context .This FUNCTION accepts a string AS the first input
                        parameter TO identify the rule for which the credit points
                        need to be calculated. The relevant parameters required to
                        calculate the GPA/CP/Unit Grades are also added to this function.
                        Bug No: 2146547.
     Known limitations,enhancements,remarks:
     Change History
     Who     When         What
     smvk    02-Sep-2002  Default keyword is replaced by assignment operator (:=), to overcome File.Pkg.22 warning
                          As a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390).
    *************************************************************************************************/

    l_earned_cp igs_ps_unit_ver.achievable_credit_points%TYPE;
    l_attempted_cp igs_ps_unit_ver.achievable_credit_points%TYPE;
    l_total_earned_cp igs_ps_unit_ver.achievable_credit_points%TYPE := 0 ; -- Replaced Default by :=
    l_total_attempted_cp igs_ps_unit_ver.achievable_credit_points%TYPE := 0 ; -- Replaced Default by :=
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);

    CURSOR c_sua_accp  IS
      SELECT sua.unit_cd,
             sua.version_number,
             sua.cal_type,
             sua.ci_sequence_number,
             sua.uoo_id
      FROM   igs_en_su_attempt sua,
             igs_ca_inst       ci_cur,
             igs_ca_inst_rel   cir,
             igs_ca_inst       ci,
             igs_ca_type       ct
      WHERE  sua.person_id = p_person_id
      AND    sua.course_cd = p_course_cd
      AND    sua.unit_attempt_status = 'COMPLETED'
      AND    sua.cal_type = cir.sub_cal_type
      AND    sua.ci_sequence_number = cir.sub_ci_sequence_number
      AND    ci.cal_type = cir.sup_cal_type
      AND    ci.sequence_number = cir.sup_ci_sequence_number
      AND    ci.cal_type = ct.cal_type
      AND    ct.s_cal_cat = 'PROGRESS'
      AND    ci_cur.cal_type = p_cal_type
      AND    ci_cur.sequence_number = p_ci_sequence_number
      AND    ci.end_dt <= ci_cur.end_dt;

    CURSOR   c_sua_apcp  IS
      SELECT sua.unit_cd,
             sua.version_number,
             sua.cal_type,
             sua.ci_sequence_number,
             sua.uoo_id
      FROM   igs_en_su_attempt sua,
             igs_ca_inst_rel   cir
      WHERE  sua.person_id = p_person_id
      AND    sua.course_cd = p_course_cd
      AND    sua.unit_attempt_status = 'COMPLETED'
      AND    sua.cal_type = cir.sub_cal_type
      AND    sua.ci_sequence_number = cir.sub_ci_sequence_number
      AND    p_cal_type = cir.sup_cal_type
      AND    p_ci_sequence_number = cir.sup_ci_sequence_number;

    l_attempt_accp c_sua_accp%ROWTYPE;
    l_attempt_apcp c_sua_apcp%ROWTYPE;

  BEGIN
    --       If the Rule Type involves Attempted Cumulative Credit Point, or
    --         Earned Cumulative Credit Point the following condition is evaluated .
    --         Cumulative is taken to mean all progression periods up to and including
    --         the current progression.  The cursor finds all student unit attempts
    --         where the teaching period is related to a progression period with an
    --         end date on or before the end date of the current progression period.

    IF p_rule_type = 'ACCP' OR p_rule_type = 'ECCP' THEN
      FOR l_sua_rec IN c_sua_accp LOOP
        Igs_Pr_Cp_Gpa.Get_Sua_Cp(
                                 p_person_id  => p_person_id,
                                 p_course_cd  => p_course_cd,
                                 p_unit_cd  => l_sua_rec.unit_cd,
                                 p_unit_version_number => l_sua_rec.version_number,
                                 p_teach_cal_type => l_sua_rec.cal_type,
                                 p_teach_ci_sequence_number => l_sua_rec.ci_sequence_number,
                                 p_stat_type     => NULL,
                                 p_system_stat   => 'PROGRESSION',
                                 p_earned_cp     => l_earned_cp,
                                 p_attempted_cp  => l_attempted_cp,
                                 p_return_status => l_return_status,
                                 p_msg_count     => l_msg_count,
                                 p_msg_data      => l_msg_data,
                                 p_uoo_id        => l_sua_rec.uoo_id);

        l_total_attempted_cp := l_total_attempted_cp + NVL(l_attempted_cp, 0);
        l_total_earned_cp := l_total_earned_cp + NVL(l_earned_cp, 0);
      END LOOP  ;

      IF P_RULE_TYPE = 'ACCP' THEN
        RETURN l_total_attempted_cp;
      ELSE
        RETURN l_total_earned_cp;
      END IF;

      --         If the Rule Type involves Attempted Period Credit Point, or
      --         Earned Period Credit Point the following condition is evaluated .
      --         Period is taken to mean units taken in teaching periods related TO
      --         the current progression period.  The cursor finds all student units
      --         attempts where the teaching period is related to the current
      --         progression period.
    ELSIF p_rule_type = 'APCP' OR p_rule_type = 'EPCP' THEN
      FOR l_sua_rec IN c_sua_apcp LOOP
        Igs_Pr_Cp_Gpa.Get_Sua_Cp(
                                 p_person_id  => p_person_id,
                                 p_course_cd  => p_course_cd,
                                 p_unit_cd  => l_sua_rec.unit_cd,
                                 p_unit_version_number => l_sua_rec.version_number,
                                 p_teach_cal_type => l_sua_rec.cal_type,
                                 p_teach_ci_sequence_number => l_sua_rec.ci_sequence_number,
                                 p_stat_type     => NULL,
                                 p_system_stat   => 'PROGRESSION',
                                 p_earned_cp     => l_earned_cp,
                                 p_attempted_cp  => l_attempted_cp,
                                 p_return_status => l_return_status,
                                 p_msg_count     => l_msg_count,
                                 p_msg_data      => l_msg_data,
                                 p_uoo_id        => l_sua_rec.uoo_id);

        l_total_attempted_cp := l_total_attempted_cp + NVL(l_attempted_cp, 0);
        l_total_earned_cp := l_total_earned_cp + NVL(l_earned_cp, 0);
      END LOOP;

      IF P_RULE_TYPE = 'APCP' THEN
        RETURN l_total_attempted_cp;
      ELSE
        RETURN l_total_earned_cp;
      END IF;

    END IF;

  END prgp_cal_cp;


  FUNCTION pr_rul_msg( p_rule_type IN  VARCHAR2)
  RETURN VARCHAR2 IS
  /**********************************************************************************************
   Created By       :   svenkata
   Date Created By  :   21-Nov-2001
   Purpose          :   This turing function displays the message text along with the rule when
                        the rule is being validated. This is done by popping the Message name that
                        has been registered for the rule and therafter using that to resolve the
                        reference to the rule type . Once the required calculation is made
                        ( GPA / Credit Points ) either for the Current period or for All periods,
                        the appropriate message along with the calculated figures is displayed to the
                        user. All  Messages are hard coded instead of using messgae dictionary in
                        simillar lines with existing messgae rules as a known NLS issue with all rules .
                        Bug No: 2146547.
   Known limitations,enhancements,remarks:
   Change History
   Who     When       What
  *************************************************************************************************/

   l_message VARCHAR2(5000);
   l_gpa_cp_calc NUMBER ;
   l_rule_type VARCHAR2(100);
   l_outcome VARCHAR2(100);

  BEGIN

    IF p_rule_type = 'ACCPM' THEN
        l_rule_type := 'ACCP' ;
        l_gpa_cp_calc :=  prgp_cal_cp(
                                      l_rule_type,
                                      p_person_id,
                                      p_course_cd,
                                      p_course_version,
                                      p_cal_type,
                                      p_ci_sequence_number);
         l_message :=  'Attempted Cumulative Credit Points is ' || IGS_GE_NUMBER.TO_CANN(ROUND(l_gpa_cp_calc)) ;
    ELSIF p_rule_type = 'APCPM' THEN
         l_rule_type := 'APCP' ;
         l_gpa_cp_calc :=  prgp_cal_cp(
                                       l_rule_type,
                                       p_person_id,
                                       p_course_cd,
                                       p_course_version,
                                       p_cal_type,
                                       p_ci_sequence_number);
          l_message := 'Attempted Period Credit Points is ' || IGS_GE_NUMBER.TO_CANN(ROUND(l_gpa_cp_calc)) ;
    ELSIF p_rule_type = 'ECCPM' THEN
         l_rule_type := 'ECCP' ;
         l_gpa_cp_calc :=  prgp_cal_cp(
                                       l_rule_type,
                                       p_person_id,
                                       p_course_cd,
                                       p_course_version,
                                       p_cal_type,
                                       p_ci_sequence_number);
          l_message := 'Earned Cumulative Credit Points is ' || IGS_GE_NUMBER.TO_CANN(ROUND(l_gpa_cp_calc)) ;
    ELSIF p_rule_type = 'EPCPM' THEN
         l_rule_type := 'EPCP' ;
         l_gpa_cp_calc :=  prgp_cal_cp(
                                       l_rule_type,
                                       p_person_id,
                                       p_course_cd,
                                       p_course_version,
                                       p_cal_type,
                                       p_ci_sequence_number);
          l_message := 'Earned Period Credit Points is ' || IGS_GE_NUMBER.TO_CANN(l_gpa_cp_calc) ;
    ELSIF p_rule_type IN ('MACPGSAPM', 'MACPGSAPM_ST') THEN
         l_rule_type := 'ALL_PERD_PM' ;
         -- kdande; Changed the following call to include statistic type as part of FA112
         l_outcome   :=   prgp_cal_cp_gsch (
                                            l_rule_type,
                                            p_person_id,
                                            p_course_cd,
                                            p_course_version,
                                            p_cal_type,
                                            p_ci_sequence_number,
                                            g_grad_sch_set_no,
                                            0,
                                            l_gpa_cp_calc,
                                            NULL);
          l_message := 'Percentage Attempted credit Points in grading schemas in ALL Periods is ' || IGS_GE_NUMBER.TO_CANN(ROUND(l_gpa_cp_calc)) ;
    ELSIF p_rule_type IN ('MACPGSCPM', 'MACPGSCPM_ST') THEN
         l_rule_type := 'CUR_PERD_PM' ;
         -- kdande; Changed the following call to include statistic type as part of FA112
         l_outcome   :=   prgp_cal_cp_gsch (
                                            l_rule_type,
                                            p_person_id,
                                            p_course_cd,
                                            p_course_version,
                                            p_cal_type,
                                            p_ci_sequence_number,
                                            g_grad_sch_set_no,
                                            0,
                                            l_gpa_cp_calc,
                                            NULL);
          l_message := 'Percentage Attempted Credit Points in grading schemas in CURRENT Period is ' || IGS_GE_NUMBER.TO_CANN(ROUND(l_gpa_cp_calc)) ;
    ELSIF p_rule_type IN ('LACPGSAPM', 'LACPGSAPM_ST') THEN
         l_rule_type := 'ALL_PERD_PL' ;
         -- kdande; Changed the following call to include statistic type as part of FA112
         l_outcome   :=   prgp_cal_cp_gsch (
                                            l_rule_type,
                                            p_person_id,
                                            p_course_cd,
                                            p_course_version,
                                            p_cal_type,
                                            p_ci_sequence_number,
                                            g_grad_sch_set_no,
                                            0,
                                            l_gpa_cp_calc,
                                            NULL);
         l_message := 'Percentage Attempted Credit Points in grading schemas in ALL Periods is ' || IGS_GE_NUMBER.TO_CANN(ROUND(l_gpa_cp_calc)) ;
    ELSIF p_rule_type IN ('LACPGSCPM', 'LACPGSCPM_ST') THEN
         l_rule_type := 'CUR_PERD_PL' ;
         -- kdande; Changed the following call to include statistic type as part of FA112
         l_outcome   :=   prgp_cal_cp_gsch (
                                            l_rule_type,
                                            p_person_id,
                                            p_course_cd,
                                            p_course_version,
                                            p_cal_type,
                                            p_ci_sequence_number,
                                            g_grad_sch_set_no,
                                            0,
                                            l_gpa_cp_calc,
                                            NULL);
          l_message := 'Percentage Attempted Credit Points in grading schemas in CURRENT Period is ' || IGS_GE_NUMBER.TO_CANN(ROUND(l_gpa_cp_calc)) ;
    ELSIF p_rule_type IN ('MACPGSAM', 'MACPGSAM_ST') THEN
         l_rule_type := 'ALL_PERDM' ;
         -- kdande; Changed the following call to include statistic type as part of FA112
         l_outcome   :=   prgp_cal_cp_gsch (
                                            l_rule_type,
                                            p_person_id,
                                            p_course_cd,
                                            p_course_version,
                                            p_cal_type,
                                            p_ci_sequence_number,
                                            g_grad_sch_set_no,
                                            0,
                                            l_gpa_cp_calc,
                                            NULL);
          l_message := 'Attempted credit Points in grading schemas in ALL Periods is  ' || IGS_GE_NUMBER.TO_CANN(ROUND(l_gpa_cp_calc)) ;
    ELSIF p_rule_type IN ('MACPGSCM', 'MACPGSCM_ST') THEN
         l_rule_type := 'CUR_PERDM' ;
         -- kdande; Changed the following call to include statistic type as part of FA112
         l_outcome   :=   prgp_cal_cp_gsch (
                                            l_rule_type,
                                            p_person_id,
                                            p_course_cd,
                                            p_course_version,
                                            p_cal_type,
                                            p_ci_sequence_number,
                                            g_grad_sch_set_no,
                                            0,
                                            l_gpa_cp_calc,
                                            NULL);
          l_message := 'Attempted credit Points in grading schemas in CURRENT Period is  ' || IGS_GE_NUMBER.TO_CANN(ROUND(l_gpa_cp_calc)) ;
    ELSIF p_rule_type IN ('LACPGSCM', 'LACPGSCM_ST') THEN
         l_rule_type := 'CUR_PERDL' ;
         -- kdande; Changed the following call to include statistic type as part of FA112
         l_outcome   :=   prgp_cal_cp_gsch (
                                            l_rule_type,
                                            p_person_id,
                                            p_course_cd,
                                            p_course_version,
                                            p_cal_type,
                                            p_ci_sequence_number,
                                            g_grad_sch_set_no,
                                            0,
                                            l_gpa_cp_calc,
                                            NULL);
          l_message := 'Attempted credit Points in grading schemas in CURRENT Period is  ' || IGS_GE_NUMBER.TO_CANN(ROUND(l_gpa_cp_calc)) ;
    ELSIF p_rule_type IN ('LACPGSAM', 'LACPGSAM_ST') THEN
         l_rule_type := 'ALL_PERDL' ;
         -- kdande; Changed the following call to include statistic type as part of FA112
         l_outcome   :=   prgp_cal_cp_gsch (
                                            l_rule_type,
                                            p_person_id,
                                            p_course_cd,
                                            p_course_version,
                                            p_cal_type,
                                            p_ci_sequence_number,
                                            g_grad_sch_set_no,
                                            0,
                                            l_gpa_cp_calc,
                                            NULL);
          l_message := 'Attempted credit Points in grading schemas in ALL Periods is  ' || IGS_GE_NUMBER.TO_CANN(ROUND(l_gpa_cp_calc)) ;
    ELSIF p_rule_type = 'MAUGSAPM'  THEN
         l_rule_type := 'ALL_PERD_UPM' ;
         -- kdande; Changed the following call to include statistic type as part of FA112
         l_outcome   :=   prgp_cal_cp_gsch (
                                            l_rule_type,
                                            p_person_id,
                                            p_course_cd,
                                            p_course_version,
                                            p_cal_type,
                                            p_ci_sequence_number,
                                            g_grad_sch_set_no,
                                            0,
                                            l_gpa_cp_calc,
                                            NULL);
          l_message := 'Percentage Attempted units in grading schemas in ALL Periods is  ' || IGS_GE_NUMBER.TO_CANN(ROUND(l_gpa_cp_calc)) ;
          ELSIF p_rule_type = 'MAUGSCPM'  THEN
         l_rule_type := 'CUR_PERD_UPM' ;
         -- kdande; Changed the following call to include statistic type as part of FA112
         l_outcome   :=   prgp_cal_cp_gsch (
                                            l_rule_type,
                                            p_person_id,
                                            p_course_cd,
                                            p_course_version,
                                            p_cal_type,
                                            p_ci_sequence_number,
                                            g_grad_sch_set_no,
                                            0,
                                            l_gpa_cp_calc,
                                            NULL);
          l_message := 'Percentage Attempted units in grading schemas in CURRENT Period is ' || IGS_GE_NUMBER.TO_CANN(ROUND(l_gpa_cp_calc)) ;
          ELSIF p_rule_type = 'LAUGSAPM'  THEN
         l_rule_type := 'ALL_PERD_UPL' ;
         -- kdande; Changed the following call to include statistic type as part of FA112
         l_outcome   :=   prgp_cal_cp_gsch (
                                            l_rule_type,
                                            p_person_id,
                                            p_course_cd,
                                            p_course_version,
                                            p_cal_type,
                                            p_ci_sequence_number,
                                            g_grad_sch_set_no,
                                            0,
                                            l_gpa_cp_calc,
                                            NULL);
          l_message := 'Percentage Attempted units in grading schemas in ALL Periods is ' || IGS_GE_NUMBER.TO_CANN(ROUND(l_gpa_cp_calc)) ;
    ELSIF p_rule_type = 'LAUGSCPM'  THEN
         l_rule_type := 'CUR_PERD_UPL' ;
         -- kdande; Changed the following call to include statistic type as part of FA112
         l_outcome   :=   prgp_cal_cp_gsch (
                                            l_rule_type,
                                            p_person_id,
                                            p_course_cd,
                                            p_course_version,
                                            p_cal_type,
                                            p_ci_sequence_number,
                                            g_grad_sch_set_no,
                                            0,
                                            l_gpa_cp_calc,
                                            NULL);
          l_message := 'Percentage Attempted units in grading schemas in CURRENT Period is ' || IGS_GE_NUMBER.TO_CANN(ROUND(l_gpa_cp_calc)) ;
    ELSIF p_rule_type = 'MAUGSAM'  THEN
         l_rule_type := 'ALL_PERD_UM' ;
         -- kdande; Changed the following call to include statistic type as part of FA112
         l_outcome   :=   prgp_cal_cp_gsch (
                                            l_rule_type,
                                            p_person_id,
                                            p_course_cd,
                                            p_course_version,
                                            p_cal_type,
                                            p_ci_sequence_number,
                                            g_grad_sch_set_no,
                                            0,
                                            l_gpa_cp_calc,
                                            NULL);
          l_message := 'Attempted units in grading schemas in ALL Periods is ' || IGS_GE_NUMBER.TO_CANN(ROUND(l_gpa_cp_calc)) ;
    ELSIF p_rule_type = 'MAUGSCM'  THEN
         l_rule_type := 'CUR_PERD_UM' ;
         -- kdande; Changed the following call to include statistic type as part of FA112
         l_outcome   :=   prgp_cal_cp_gsch (
                                            l_rule_type,
                                            p_person_id,
                                            p_course_cd,
                                            p_course_version,
                                            p_cal_type,
                                            p_ci_sequence_number,
                                            g_grad_sch_set_no,
                                            0,
                                            l_gpa_cp_calc,
                                            NULL);
          l_message := 'Attempted units in grading schemas in CURRENT Period is ' || IGS_GE_NUMBER.TO_CANN(ROUND(l_gpa_cp_calc)) ;
    ELSIF p_rule_type = 'LAUGSAM'  THEN
         l_rule_type := 'ALL_PERD_UL' ;
         -- kdande; Changed the following call to include statistic type as part of FA112
         l_outcome   :=   prgp_cal_cp_gsch (
                                            l_rule_type,
                                            p_person_id,
                                            p_course_cd,
                                            p_course_version,
                                            p_cal_type,
                                            p_ci_sequence_number,
                                            g_grad_sch_set_no,
                                            0,
                                            l_gpa_cp_calc,
                                            NULL);
          l_message := 'Attempted units in grading schemas in ALL Periods is ' || IGS_GE_NUMBER.TO_CANN(ROUND(l_gpa_cp_calc)) ;
    ELSIF p_rule_type = 'LAUGSCM'  THEN
         l_rule_type := 'CUR_PERD_UL' ;
         -- kdande; Changed the following call to include statistic type as part of FA112
         l_outcome   :=   prgp_cal_cp_gsch (
                                            l_rule_type,
                                            p_person_id,
                                            p_course_cd,
                                            p_course_version,
                                            p_cal_type,
                                            p_ci_sequence_number,
                                            g_grad_sch_set_no,
                                            0,
                                            l_gpa_cp_calc,
                                            NULL);
          l_message := 'Attempted units in grading schemas in CURRENT Period is ' || IGS_GE_NUMBER.TO_CANN(ROUND(l_gpa_cp_calc)) ;
    END IF;

    RETURN l_message ;

  END pr_rul_msg;

/*
 evaluate the sql string and return the (last) value (only one)
*/
FUNCTION evaluate_sql (
        p_select_string IN      VARCHAR2 )
RETURN VARCHAR2 IS
        v_cursor        INTEGER;
        v_rows          INTEGER;
        v_value         VARCHAR2(4000);
BEGIN
        v_cursor := DBMS_SQL.OPEN_CURSOR;
/*
         only select allowed
*/
        DBMS_SQL.PARSE(v_cursor,
                'SELECT'||SUBSTR(LTRIM(p_select_string),7),
                dbms_sql.native);
        DBMS_SQL.DEFINE_COLUMN(v_cursor,1,v_value,4000);
        v_rows := DBMS_SQL.EXECUTE(v_cursor);
        WHILE DBMS_SQL.FETCH_ROWS(v_cursor) > 0
        LOOP
                DBMS_SQL.COLUMN_VALUE(v_cursor,1,v_value);
        END LOOP;
        DBMS_SQL.CLOSE_CURSOR(v_cursor);
        RETURN v_value;
END evaluate_sql;
/*

 TURING - the  IGS_RU_RULE engine

*/
FUNCTION turing(
        p_rule_number   IN NUMBER,
        p_tds           IN r_tds )
RETURN VARCHAR2 IS
  ------------------------------------------------------------------
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --bannamal   08-Jul-2005      Enh# 3392088. New Turing functions are added.
  --svenkata   12-Dec-2001      Modifications are done w.r.t. Progression Rules Enhancement DLD. Bug No: 2146547.
  --smadathi   07-JUN-2001      The changes are as per enhancement bug No. 1775394 . The turin functions for person reference set evaluation,
  --                            unit placement set evaluation, program stage set evaluation, person id group set evaluation added .
  --nalkumar 18-JUN-2001        This function has been modified as per the requirement of Enrolment eligibility and Validations DLD(Bug# 1830175).
  --                            The turin functions for pct_mx_ald added.
  --svanukur 30-jul-2003        replaced the function IGS_PR_GEN_002.PRGP_GET_SUA_GPA_VAL that calculates the gpa with the new function
 --                             igs_pr_cp_gpa.get_sua_all as per bug 3031749
 --svanukur  08-aug-2003        removed the cursor to get the unit version number since it is already available in  gv_member(p_tds.member_index).f2
 --svanukur  18-AUG-2003        Modified the '_ER' case to pop the parameters into a PL/SQL table,t_params declared in the main function rulp_val_senna.
 --                             Also modified the cases , p_param_1 and p_param_2 to push these into the stack. BUG# 3049903
 --rvangala  06-Apr-2004        Modified the '_ER' case to remove code which pushes parameters into PL/SQL table (t_params)
 --                             modified cases , p_param_1 and p_param_2 to removes references to t_params. BUG# 3285358
 --stutta    21-Sep-2004        Passing p_final_ind as 'Y' in call to sua_attribute for turing funtion 'sua.pc', so that only
 --                             finalized outcomes are picked for Conseded pass grades.Bug #3654871
 --swaghmar  15-Sep-2005	Bug# 4491456
  -------------------------------------------------------------------
        v_start_stack   BINARY_INTEGER;
        v_result        IGS_RU_ITEM.value%TYPE;
        v_no_parameters NUMBER;
        v_set           IGS_RU_SET.sequence_number%TYPE;
        v_conditional   IGS_RU_ITEM.value%TYPE;
        v_then          IGS_RU_RULE.sequence_number%TYPE;
        v_variable_no   NUMBER;
        v_number        NUMBER;
        v_message_stack_index   BINARY_INTEGER;
        l_rule_type  VARCHAR2(50);
        l_cp_in_rule NUMBER;
        l_cp_result  NUMBER;
        l_progression_period NUMBER;
        l_stat_type VARCHAR2(30);
        l_element VARCHAR2(30);

        l_earned_cp        NUMBER;
        l_attempted_cp     NUMBER;
        l_gpa_value        NUMBER;
        l_gpa_cp           NUMBER;
        l_gpa_quality_points  NUMBER;
        l_return_status           VARCHAR2(30);
        l_msg_count               NUMBER(2);
        l_msg_data                VARCHAR2(2000);
        l_version_number         igs_ps_unit_ofr_opt.version_number%TYPE;
        l_best_worst VARCHAR2(3);
        l_recommended VARCHAR2(3);

        l_n_grd_set  IGS_RU_SET.sequence_number%TYPE; -- Variable to hold grading schema set.
        l_c_temp     igs_ru_item.value%TYPE;          -- Variable to hold test type

BEGIN
        gv_turing_level := gv_turing_level + 1;
/*
         mark the start of the stack
*/
        v_start_stack := gv_stack_index;
        FOR rule_items IN (
                SELECT  rul_sequence_number,
                        item,
                        turin_function,
                        named_rule,
                        rule_number,
                        derived_rule,
                        set_number,
                        value
                FROM    IGS_RU_ITEM
                WHERE   rul_sequence_number = p_rule_number
                ORDER BY item DESC )
        LOOP
                IF rule_items.turin_function IS NOT NULL
                THEN
/*
                         turing functions
                         if then else
*/
                        IF rule_items.turin_function = 'ifthenelse'
                        THEN
                                v_conditional := pop;
                                v_no_parameters := pop;
                                v_then := pop;
                                clean_up_stack(v_no_parameters);
                                v_no_parameters := pop;
                                igs_ru_gen_001.p_evaluated_part := NULL;
                                v_result := ifthenelse(v_conditional,v_then,pop,p_tds);
                                clean_up_stack(v_no_parameters);
                                push(v_result);
                       /*
                        * turing functions
                        * if then
                        * Navin  27-Aug-2001
                        * Added as part of Bug# : 1899513.
                        */
                        ELSIF rule_items.turin_function = 'ifthen'
                        THEN
                                v_conditional := pop;
                                v_no_parameters := pop;
                                v_then := pop;
                                clean_up_stack(v_no_parameters);
                                igs_ru_gen_001.p_evaluated_part := NULL;
                                v_result := ifthen(v_conditional,v_then,p_tds);
                                push(v_result);
/*
                         BOOLEAN FUNCTIONS
*/
                        ELSIF rule_items.turin_function = 'true'
                        THEN
                                push('true');
                        ELSIF rule_items.turin_function = 'false'
                        THEN
                                push('false');
/*
                         numeric comparison functions
*/
                        ELSIF rule_items.turin_function = 'lt'
                        THEN
                                push(b_to_t(IGS_GE_NUMBER.TO_NUM(pop) < IGS_GE_NUMBER.TO_NUM(pop)));
                        ELSIF rule_items.turin_function = 'lte'
                        THEN
                                push(b_to_t(IGS_GE_NUMBER.TO_NUM(pop) <= IGS_GE_NUMBER.TO_NUM(pop)));
                        ELSIF rule_items.turin_function = 'eq'
                        THEN
                                push(eq(pop,pop));
                        ELSIF rule_items.turin_function = 'neq'
                        THEN
                                push(neq(pop,pop));
                        ELSIF rule_items.turin_function = 'gte'
                        THEN
                                push(b_to_t(IGS_GE_NUMBER.TO_NUM(pop) >= IGS_GE_NUMBER.TO_NUM(pop)));
                        ELSIF rule_items.turin_function = 'gt'
                        THEN
                                push(b_to_t(IGS_GE_NUMBER.TO_NUM(pop) > IGS_GE_NUMBER.TO_NUM(pop)));
/*
                         string comparisons
*/
                        ELSIF rule_items.turin_function = 'slt'
                        THEN
                                push(b_to_t(pop < pop));
                        ELSIF rule_items.turin_function = 'slte'
                        THEN
                                push(b_to_t(pop <= pop));
                        ELSIF rule_items.turin_function = 'seq'
                        THEN                            push(b_to_t(pop = pop));
                        ELSIF rule_items.turin_function = 'sneq'
                        THEN
                                push(b_to_t(pop <> pop));
                        ELSIF rule_items.turin_function = 'sgte'
                        THEN
                                push(b_to_t(pop >= pop));
                        ELSIF rule_items.turin_function = 'sgt'
                        THEN
                                push(b_to_t(pop > pop));
/*
                         date comparisons
*/
                        ELSIF rule_items.turin_function = 'dlt'
                        THEN
                                push(date_compare(pop,'<',pop));
                        ELSIF rule_items.turin_function = 'dlte'
                        THEN
                                push(date_compare(pop,'<=',pop));
                        ELSIF rule_items.turin_function = 'deq'
                        THEN
                                push(date_compare(pop,'=',pop));
                        ELSIF rule_items.turin_function = 'dneq'
                        THEN
                                push(date_compare(pop,'<>',pop));
                        ELSIF rule_items.turin_function = 'dgte'
                        THEN
                                push(date_compare(pop,'>=',pop));
                        ELSIF rule_items.turin_function = 'dgt'
                        THEN
                                push(date_compare(pop,'>',pop));
/*
                         grade comparisons
*/
                        ELSIF rule_items.turin_function = 'grd_lt'
                        THEN
                                push(sua_relative_grade(pop,pop,'<',pop,pop,p_tds));
                        ELSIF rule_items.turin_function = 'grd_lte'
                        THEN
                                push(sua_relative_grade(pop,pop,'<=',pop,pop,p_tds));
                        ELSIF rule_items.turin_function = 'grd_eq'
                        THEN
                                push(sua_relative_grade(pop,pop,'=',pop,pop,p_tds));
                        ELSIF rule_items.turin_function = 'grd_neq'
                        THEN
                                push(sua_relative_grade(pop,pop,'<>',pop,pop,p_tds));
                        ELSIF rule_items.turin_function = 'grd_gte'
                        THEN
                                push(sua_relative_grade(pop,pop,'>=',pop,pop,p_tds));
                        -- smaddali added this code for the new turin function added for bug#4304688
                        ELSIF rule_items.turin_function = 'adv_gte' THEN
                                                push(adv_relative_grade(pop,pop,'>=',pop,pop,p_tds));

                        ELSIF rule_items.turin_function = 'grd_gt'
                        THEN
                                push(sua_relative_grade(pop,pop,'>',pop,pop,p_tds));
                        ELSIF rule_items.turin_function = 'isnull'
                        THEN
                                push(b_to_t(pop IS NULL));
                        ELSIF rule_items.turin_function = 'isnotnull'
                        THEN
                                push(b_to_t(pop IS NOT NULL));
/*
                         boolean set functions
*/
                        ELSIF rule_items.turin_function = 'null_set'
                        THEN
                                push(b_to_t(gv_set(pop).first IS NULL));
                        ELSIF rule_items.turin_function = 'in_set'
                        THEN
                                push(in_set(pop,pop));
                        ELSIF rule_items.turin_function = 'not_in_set'
                        THEN
                                push(b_to_t(in_set(pop,pop) = 'false'));

                        ELSIF rule_items.turin_function = 'test_grade'
                        THEN
                                l_c_temp := pop;             -- holds the test type value.
                                push(l_c_temp);              -- push back the test type value ( it's required as clear_parameter will try to remove the parameter from the stack.
                                push(test_grade(l_c_temp));  -- push the return value (set number) into the stack.

                         ELSIF rule_items.turin_function = 'in_grd'
                         THEN
                                l_n_grd_set := pop;            -- holds the grading schema set number;
                                push(in_set(pop,l_n_grd_set)); -- push the return type (boolean) into the stack

                        ELSIF rule_items.turin_function = 'not_in_grd'
                        THEN
                                push(not_in_grd(pop,pop));   -- push the return type (boolean) into the stack

/*
                         conjunction functions
*/
                        ELSIF rule_items.turin_function = 'and'
                        THEN
                                push(and_func(pop,pop));
                        ELSIF rule_items.turin_function = 'or'
                        THEN
                                push(or_func(pop,pop));
/*
                         parent rule result (used in message rule)
*/
                        ELSIF rule_items.turin_function = 'outcome'
                        THEN
                                push(p_tds.rule_outcome);
/*
                         VALUE FUNCTIONS
                         numeric functions
*/
                        ELSIF rule_items.turin_function = 'plus'
                        THEN
                                push(pop + pop);
                        ELSIF rule_items.turin_function = 'subtract'
                        THEN
                                push(pop - pop);
                        ELSIF rule_items.turin_function = 'mult'
                        THEN
                                push(pop * pop);
                        ELSIF rule_items.turin_function = 'divide'
                        THEN
                                push(divide(pop,pop));
                        ELSIF rule_items.turin_function = 'round'
                        THEN
                                push(ROUND(pop,pop));
                        ELSIF rule_items.turin_function = 'trunc'
                        THEN
                                push(TRUNC(pop,pop));
                        ELSIF rule_items.turin_function = 'max'
                        THEN
                                push(max_func(pop,pop));
                        ELSIF rule_items.turin_function = 'min'
                        THEN
                                push(min_func(pop,pop));
                        ELSIF rule_items.turin_function = 'total_cp'
                        THEN
                                push(IGS_EN_GEN_001.enrp_clc_sca_pass_cp(p_person_id,p_course_cd,TRUNC(SYSDATE)));
                        ELSIF rule_items.turin_function = 'stage_comp'
                        THEN
                                push(do_course_stage(pop));
/*
                         SET FUNCTIONS
                         return number
*/
                        ELSIF rule_items.turin_function = 'members'
                        THEN
                                push(members(pop));
/*
                         return set
*/
                        ELSIF rule_items.turin_function = 'new_set'
                        THEN
                                push(new_set);
                        ELSIF rule_items.turin_function = 'output'
                        THEN
                                push(new_set);
                        ELSIF rule_items.turin_function = 'show_set'
                        THEN
                                push(show_set(pop));
                        ELSIF rule_items.turin_function = 'show_us'
                        THEN
                                push(show_us_set(pop));
                        ELSIF rule_items.turin_function = 'intersect'
                        THEN
                                push(set_intersect(pop,pop));
                        ELSIF rule_items.turin_function = 'union'
                        THEN
                                push(set_union(pop,pop));
                        ELSIF rule_items.turin_function = 'minus'
                        THEN
                                push(set_minus(pop,pop));
                        ELSIF rule_items.turin_function = 'setelement'
                        THEN
                                push(add_member(new_set,pop,pop,'','',''));
                        ELSIF rule_items.turin_function = 'exp_unit'
                        THEN
                                push(expand_uoo(new_set,pop,pop));
                        ELSIF rule_items.turin_function = 'snarts'
                        THEN
                                push(get_snarts(pop,pop));
/*
                         student sets
*/
                        ELSIF rule_items.turin_function = 'student'
                        THEN
                                push(student);
                        ELSIF rule_items.turin_function = 'adv_stnd'
                        THEN
                                push(advanced_standing);
                        ELSIF rule_items.turin_function = 'asul_set'
                        THEN
                                push(advanced_standing_unit_level);
                        ELSIF rule_items.turin_function = 'stdnt_us'
                        THEN
                                push(student_us);
                        ELSIF rule_items.turin_function = 'make_set'
                        THEN
                                push(make_set(pop));
/*
                         LOOP THROUGH SET APPLYING RULE
                         return number
*/
                        ELSIF rule_items.turin_function = 'sum'
                        THEN
                                v_set := pop;
                                v_no_parameters := pop;
                                v_result := sum_func(v_set,pop);
                                clean_up_stack(v_no_parameters);
                                push(v_result);
/*
                         return set
*/
                        ELSIF rule_items.turin_function = 'for_expand'
                        THEN
                                v_set := pop;
                                v_no_parameters := pop;
                                v_result := for_expand(v_set,pop);
                                clean_up_stack(v_no_parameters);
                                push(v_result);
                        ELSIF rule_items.turin_function = 'cascade'
                        THEN
                                v_set := pop;
                                v_no_parameters := pop;
                                v_result := cascade_expand(new_set,v_set,pop);
                                clean_up_stack(v_no_parameters);
                                push(v_result);
                        ELSIF rule_items.turin_function = 'select'
                        THEN
                                v_set := pop;
                                v_no_parameters := pop;
                                v_result := select_set(v_set,pop);
                                clean_up_stack(v_no_parameters);
                                push(v_result);
                        ELSIF rule_items.turin_function = 'selectn'
                        THEN
                                v_number := pop;
                                v_set := pop;
                                v_no_parameters := pop;
                                v_result := select_N_members(v_number,v_set,pop);
                                clean_up_stack(v_no_parameters);
                                push(v_result);
/*
                         TARGET MEMBER ATTRIBUTE VALUES
                         member values (set in loop functions)
*/
                        ELSIF rule_items.turin_function = 'g_unit_cd'
                        THEN
                                push(gv_member(p_tds.member_index).f1);
                        ELSIF rule_items.turin_function = 'g_unit_ver'
                        THEN
                                push(gv_member(p_tds.member_index).f2);
                        ELSIF rule_items.turin_function = 'g_cal_type'
                        THEN
                                push(gv_member(p_tds.member_index).f3);
                        ELSIF rule_items.turin_function = 'g_ci_seq'
                        THEN
                                push(gv_member(p_tds.member_index).f4);
                        ELSIF rule_items.turin_function = 'g_uoo_id'
                        THEN
                                push(gv_member(p_tds.member_index).f5);
                        ELSIF rule_items.turin_function = 'setfldval'
                        THEN
                                push(set_field_val(pop,pop));
/*
                         member index functions
*/
                        ELSIF rule_items.turin_function = 'setmbridx'
                        THEN
                                push(gv_set(pop).first);
                        ELSIF rule_items.turin_function = 'mbridx'
                        THEN
                                push(p_tds.member_index);
/*
                         SET MEMBER ATTRIBUTES
                         unit attributes
*/
                        ELSIF rule_items.turin_function = 'rep_ind'
                        THEN
                                push(uv_attribute('rep_ind',p_tds));
                        ELSIF rule_items.turin_function = 'level'
                        THEN
                                push(IGS_PS_GEN_002.CRSP_GET_UN_LVL(gv_member(p_tds.member_index).f1,
                                                gv_member(p_tds.member_index).f2,
                                                p_course_cd,
                                                p_course_version));
                        ELSIF rule_items.turin_function = 'uv_cp'
                        THEN
                                push(uv_credit_points(gv_member(p_tds.member_index).f1,
                                                gv_member(p_tds.member_index).f2));
/*
                         student unit attempt attributes
*/
                        ELSIF rule_items.turin_function = 'status'
                        THEN
                                push(sua_attribute('status',p_tds.member_index,'N'));
                        ELSIF rule_items.turin_function = 'sua.status'
                        THEN
                                push(sua_attribute('status',pop,'N'));
                        ELSIF rule_items.turin_function = 'result'
                        THEN
                                push(sua_attribute('result',p_tds.member_index,'N'));
                        ELSIF rule_items.turin_function = 'sua_grade'
                        THEN
                                push(sua_attribute('grade',p_tds.member_index,'N'));
                                push(sua_attribute('grd_sch',p_tds.member_index,'N'));
                        -- smaddali added this code for the new turin function added for bug#4304688
                        ELSIF rule_items.turin_function = 'adv_grd' THEN
                                push(adv_attribute('grade',p_tds.member_index));
                                push(adv_attribute('grd_sch',p_tds.member_index));

                        ELSIF rule_items.turin_function = 'sua_mark'
                        THEN
                                push(sua_attribute('mark',p_tds.member_index,'N'));
                        ELSIF rule_items.turin_function = 'outcome_dt'
                        THEN
                                push(sua_attribute('outcome_dt',p_tds.member_index,'N'));
                        ELSIF rule_items.turin_function = 'finlresult'
                        THEN
                                push(sua_attribute('result',p_tds.member_index,'Y'));
                        ELSIF rule_items.turin_function = 'finalgrade'
                        THEN
                                push(sua_attribute('grade',p_tds.member_index,'Y'));
                                push(sua_attribute('grd_sch',p_tds.member_index,'Y'));

                        ELSIF rule_items.turin_function = 'sua.pc'
                        THEN
                                push(sua_attribute('pass_conceded',p_tds.member_index,'Y'));
                        ELSIF rule_items.turin_function = 'credit_pts'
                        THEN
                                push(sua_credit_points(p_tds.member_index));
                        ELSIF rule_items.turin_function = 'gpa'
                        THEN


                                l_gpa_value := NULL;
                                l_best_worst := pop;
                                l_recommended := pop;

                                igs_pr_cp_gpa.get_sua_all (
                                 p_person_id => p_person_id,
                                 p_course_cd => p_course_cd,
                                 p_unit_cd   => gv_member(p_tds.member_index).f1,
                                 p_unit_version_number =>  gv_member(p_tds.member_index).f2,
                                 p_teach_cal_type => gv_member(p_tds.member_index).f3,
                                 p_teach_ci_sequence_number => gv_member(p_tds.member_index).f4,
                                 p_stat_type =>    NULL,
                                 p_system_stat =>  NULL,
                                 p_earned_cp =>l_earned_cp,
                                 p_attempted_cp =>l_attempted_cp,
                                 p_gpa_value =>l_gpa_value,
                                 p_gpa_cp =>l_gpa_cp ,
                                 p_gpa_quality_points=>l_gpa_quality_points,
                                 p_init_msg_list => fnd_api.g_true ,
                                 p_return_status => l_return_status ,
                                 p_msg_count =>l_msg_count ,
                                 p_msg_data => l_msg_data  ,
                                 p_uoo_id => gv_member(p_tds.member_index).f5) ;

                                push(l_gpa_value);

                        ELSIF rule_items.turin_function = 'prg_prd'
                        THEN
                                push(b_to_t(IGS_PR_GEN_002.prgp_get_sua_prg_num(p_cal_type,
                                                p_ci_sequence_number,
                                                pop + 1,        /* 1 is current period, i like 0 */
                                                p_person_id,
                                                p_course_cd,
                                                gv_member(p_tds.member_index).f1,
                                                gv_member(p_tds.member_index).f3,
                                                gv_member(p_tds.member_index).f4,
                                                gv_member(p_tds.member_index).f5) = 'Y'));
                        ELSIF rule_items.turin_function = 'period'
                        THEN
                                push(IGS_CA_GEN_001.CALP_GET_RLTV_TIME(p_cal_type,
                                                        p_ci_sequence_number,
                                                        gv_member(p_tds.member_index).f3,
                                                        gv_member(p_tds.member_index).f4));
                        ELSIF rule_items.turin_function = 'wam_wyt'
                        THEN
                                push(wam_weighting(p_tds.member_index));
                        ELSIF rule_items.turin_function = 'wam'
                        THEN
                                push(igs_pr_gen_002.prgp_get_sua_wam(p_person_id,
                                                p_course_cd,
                                                gv_member(p_tds.member_index).f1,
                                                gv_member(p_tds.member_index).f3,
                                                gv_member(p_tds.member_index).f4,
                                                pop,    /*  use recomended */
                                                pop,    /*  abort when missing */
                                                pop,
                                                gv_member(p_tds.member_index).f5));  /*  wam type */
/*
                         sua order attributes
*/
                        ELSIF rule_items.turin_function = 's_latest'
                        THEN
                                push(sua_select_unique('last',p_tds.member_index,p_tds.set_number));
                        ELSIF rule_items.turin_function = 's_earliest'
                        THEN
                                push(sua_select_unique('first',p_tds.member_index,p_tds.set_number));
                        ELSIF rule_items.turin_function = 's_maxcpm'
                        THEN
                                push(sua_select_unique('maxcp',p_tds.member_index,p_tds.set_number));
                        ELSIF rule_items.turin_function = 's_mincpm'
                        THEN
                                push(sua_select_unique('mincp',p_tds.member_index,p_tds.set_number));
/*
                         sua attributes of duplicates within a set
*/
                        ELSIF rule_items.turin_function = 'dup_cnt'
                        THEN
                                push(duplicate_count(p_tds));
                        ELSIF rule_items.turin_function = 'latest'
                        THEN
                                push(sua_select_unique('last',p_tds.member_index,
                                                        sua_duplicate_set(p_tds)));
                        ELSIF rule_items.turin_function = 'earliest'
                        THEN
                                push(sua_select_unique('first',p_tds.member_index,
                                                        sua_duplicate_set(p_tds)));
                        ELSIF rule_items.turin_function = 'maxcpm'
                        THEN
                                push(sua_select_unique('maxcp',p_tds.member_index,
                                                        sua_duplicate_set(p_tds)));
                        ELSIF rule_items.turin_function = 'mincpm'
                        THEN
                                push(sua_select_unique('mincp',p_tds.member_index,
                                                        sua_duplicate_set(p_tds)));
/*
                         advanced standing  unit level attributes
*/
                        ELSIF rule_items.turin_function = 'asul_level'
                        THEN
                                push(asul_attribute('level',p_tds));
                        ELSIF rule_items.turin_function = 'asul_cp'
                        THEN
                                push(asul_attribute('credit_points',p_tds));

                        -- for person reference set evaluation
                        ELSIF  rule_items.turin_function = 'ref_set' THEN
                          push(ref_set(gv_stack_index)) ;
                        -- for unit placement set evaluation
                        ELSIF  rule_items.turin_function = 'plc_chk' THEN
                          push(plc_chk(gv_stack_index)) ;
                        -- for program stage set evaluation
                        ELSIF  rule_items.turin_function = 'stg_set' THEN
                          push(stg_set(gv_stack_index)) ;
                        -- for person id group set evaluation
                        ELSIF  rule_items.turin_function = 'perid_chk' THEN
                          push(perid_chk(gv_stack_index)) ;

                        --Next ELSIF part is added as per the requirement of
                        --Enrolment eligibility and Validations DLD (For form IGSEN058) BUG# 1830175.
                        ELSIF rule_items.turin_function = 'pct_mx_ald'
                        THEN
                                push(rulp_get_alwd_cp(pop,p_param_1,p_param_2));

/*
                         student UNIT set attempt attributes
*/
                        ELSIF rule_items.turin_function = 'us_status'
                        THEN
                                push(susa_attribute('status',p_tds));
                        ELSIF rule_items.turin_function = 'susa.psi'
                        THEN
                                push(susa_attribute('psi',p_tds));
/*
                         unit set attributes
*/
                        ELSIF rule_items.turin_function = 'us.usc'
                        THEN
                                push(us_attribute('usc',p_tds));
/*
                         special set functions
                         select the first member from a set (returns set with one member)
*/
                        ELSIF rule_items.turin_function = 'first'
                        THEN
                                push(first(pop));
/*
                         date
*/
                        ELSIF rule_items.turin_function = 'date'
                        THEN
                                null;
/*
                         string functions
*/
                        ELSIF rule_items.turin_function = 'string'
                        THEN
                                push(REPLACE(pop,cst_space,' '));
                        ELSIF rule_items.turin_function = 'concat'
                        THEN
                                push(pop||pop);
                        ELSIF rule_items.turin_function = 'to_string'
                        THEN
                                null;
                        ELSIF rule_items.turin_function = 'displayset'
                        THEN
                                push(display_set(pop));
                        ELSIF rule_items.turin_function = 'pop_mess'
                        THEN
                                push(pop_message);
/*
                         SPECIAL FUNCTIONS
                         evaluate an sql statment
*/
                        ELSIF rule_items.turin_function = 'sql'
                        THEN
                                push(evaluate_sql(pop));
/*
                         evaluate a RULE
*/
                        ELSIF rule_items.turin_function = 'turing'
                        THEN
                                push(turing(pop,p_tds));
                        ELSIF rule_items.turin_function = 'turing_fm'
                        THEN
                                v_message_stack_index := gv_message_stack_index;
                                push(turing(pop,p_tds));
                                gv_message_stack_index := v_message_stack_index;
/*
                         get derived RULE number
*/
                        ELSIF rule_items.turin_function = 'unit_rule'
                        THEN
                                push(get_unit_rule(pop,pop,pop));
                        ELSIF rule_items.turin_function = 'crs_rule'
                        THEN
                                push(get_course_rule(pop,pop,pop));
                        ELSIF rule_items.turin_function = 'us_rule'
                        THEN
                                push(get_us_rule(pop,pop,pop));
                        ELSIF rule_items.turin_function = 'fdfr_rule'
                        THEN
                                push(get_fdfr_rule(pop,pop,pop,pop,pop));
                        ELSIF rule_items.turin_function = 'cs_rule'
                        THEN
                                push(get_crs_stg_rule(pop,pop,pop,pop));
/*
                         item.subitem
*/
                        ELSIF rule_items.turin_function = 'dot'
                        THEN
                                null;

/*
                         type coercion
*/
                        ELSIF rule_items.turin_function = 'coerce'
                        THEN
                                null;
/*
                         global variables (per senna call)
*/
                        ELSIF rule_items.turin_function = 'set_var'
                        THEN
                                v_variable_no := pop;
                                gt_variable(v_variable_no) := pop;
                                push(gt_variable(v_variable_no));
                        ELSIF rule_items.turin_function = 'get_var'
                        THEN
                                push(get_variable(pop));
/*
                         FUNDAMENTAL TURING FUNCTIONS
                         function parameters
*/
                        ELSIF rule_items.turin_function = '$'
                        THEN
/*
                                 fetch and push parameter
*/
                                push(get_parameter(v_start_stack - pop + 1));
/*
                         invisible functions
*/
                        ELSIF rule_items.turin_function = '_ER'
                        THEN
/*
                                 evaluate RULE
*/
                               v_no_parameters := pop;

                                v_result := turing(pop,p_tds);
                                clean_up_stack(v_no_parameters);
                                push(v_result);


                        ELSIF rule_items.turin_function = 'pr_rul_msg' THEN
                          -- This turing function check has been included as part of Progression Rules Enhancement DLD
                          -- to display messages to the user when the rule is evaluated.  Bug No: 2146547 by svenkata
                          l_rule_type := pop ;
                          push(pr_rul_msg(l_rule_type));

                        ELSIF rule_items.turin_function = 'pr_rul_cp' THEN
                          -- This turing function check has been included as part of Progression Rules Enhancement DLD
                          -- to evaluate Progression rules.  Bug No: 2146547 by svenkata
                          l_rule_type := pop ;
                          push (   prgp_cal_cp( l_rule_type,
                                                p_person_id,
                                                p_course_cd,
                                                p_course_version,
                                                p_cal_type,
                                                p_ci_sequence_number));

                        ELSIF rule_items.turin_function = 'pr_rul_gcp' THEN
                          -- This turing function check has been included as part of Progression Rules Enhancement DLD
                          -- to evaluate Progression rules.  Bug No: 2146547 by svenkata
                          l_rule_type := pop;        -- this will get the unique code defined
                          l_cp_in_rule := pop;       -- To get the set number for the grading schema defined in the rule
                          IF (INSTR (l_rule_type, '_ST') > 0) THEN
                            l_stat_type := pop;
                          END IF;
                          g_grad_sch_set_no :=  pop; -- units of grade percentage or number defined in the rule,

                          -- The following code will balance the stack since we have poped two values for this rule.
                          IF (INSTR (l_rule_type, '_ST') > 0) THEN
                            gv_stack_index := gv_stack_index + 3;
                          ELSE
                            gv_stack_index := gv_stack_index + 2;
                          END IF;
                          -- kdande; Changed the following call to include statistic type as part of FA112
                          push( prgp_cal_cp_gsch( l_rule_type,
                                                  p_person_id,
                                                  p_course_cd,
                                                  p_course_version,
                                                  p_cal_type,
                                                  p_ci_sequence_number,
                                                  g_grad_sch_set_no,
                                                  l_cp_in_rule,
                                                  l_cp_result,
                                                  l_stat_type));
/*
                         INPUT PARAMETERS
*/
                        ELSIF rule_items.turin_function = 'chrt_rul' THEN
                          l_rule_type := pop; -- this will get the unique code defined for the kind of rule used
                          g_grad_sch_set_no :=  pop; -- Set ID for progression status
                          gv_stack_index := gv_stack_index + 1;
                          Push( prgp_get_chrt( l_rule_type,
                                                  g_grad_sch_set_no
                                                ));
                        -- kdande; Added the following ELSIF for stcl as part of FA112
                        ELSIF rule_items.turin_function = 'stcl' THEN
                          l_rule_type := pop;
                          l_stat_type := pop;
                          l_element := pop;
                          l_cp_in_rule := pop;
                          gv_stack_index := gv_stack_index + 3;
                          push (prgp_cal_stat (l_rule_type, l_stat_type, l_element, l_cp_in_rule));
                        -- kdande; Added the following ELSIF for calcstcp as part of FA112
                        ELSIF rule_items.turin_function = 'calcstcp' THEN
                          l_rule_type := pop;
                          l_cp_in_rule := pop;
                          l_stat_type := pop;
                          IF (l_rule_type = 'NCPPNPP') THEN
                            l_progression_period := pop;
                            gv_stack_index := gv_stack_index + 3;
                          ELSIF (l_rule_type = 'NCPCPP') THEN
                            l_progression_period := 0;
                            gv_stack_index := gv_stack_index + 2;
                          ELSE
                            gv_stack_index := gv_stack_index + 2;
                          END IF;
                          push (sua_credit_points_st (l_rule_type, l_stat_type, l_cp_in_rule, l_progression_period));
                        ELSIF rule_items.turin_function = 'p_rule_cd'
                        THEN
                                push(p_rule_call_name);
                        ELSIF rule_items.turin_function = 'p_prsn_id'
                        THEN
                                push(p_person_id);
                        ELSIF rule_items.turin_function = 'p_crs_cd'
                        THEN
                                push(p_course_cd);
                        ELSIF rule_items.turin_function = 'p_crs_ver'
                        THEN
                                push(p_course_version);
                        ELSIF rule_items.turin_function = 'p_unit_cd'
                        THEN
                                push(p_unit_cd);
                        ELSIF rule_items.turin_function = 'p_unit_ver'
                        THEN
                                push(p_unit_version);
                        ELSIF rule_items.turin_function = 'p_cal_type'
                        THEN
                                push(p_cal_type);
                        ELSIF rule_items.turin_function = 'p_ci_seq'
                        THEN
                                push(p_ci_sequence_number);
                        ELSIF rule_items.turin_function = 'p_param_1'
                        THEN
                                push(p_param_1);
                        ELSIF rule_items.turin_function = 'p_param_2'
                        THEN
                                 push(p_param_2);
                        ELSIF rule_items.turin_function = 'p_param_3'
                        THEN
                                push(p_param_3);
                        ELSIF rule_items.turin_function = 'p_param_4'
                        THEN
                                push(p_param_4);
                        ELSIF rule_items.turin_function = 'p_param_5'
                        THEN
                                push(p_param_5);
                        ELSIF rule_items.turin_function = 'p_param_6'
                        THEN
                                push(p_param_6);
                        ELSIF rule_items.turin_function = 'p_param_7'
                        THEN
                                push(p_param_7);
                        ELSIF rule_items.turin_function = 'p_param_8'
                        THEN
                                push(p_param_8);
                        ELSIF rule_items.turin_function = 'p_param_9'
                        THEN
                                push(p_param_9);
                        ELSIF rule_items.turin_function = 'p_param_10'
                        THEN
                                push(p_param_10);
                        ELSIF rule_items.turin_function = 'p_param_11'
                        THEN
                                push(p_param_11);
                        ELSIF rule_items.turin_function = 'p_param_12'
                        THEN
                                push(p_param_12);
                        ELSIF rule_items.turin_function = 'p_param_13'
                        THEN
                                push(p_param_13);
                        ELSIF rule_items.turin_function = 'p_param_14'
                        THEN
                                push(p_param_14);
                        ELSIF rule_items.turin_function = 'p_param_15'
                        THEN
                                push(p_param_15);
                        ELSIF rule_items.turin_function = 'p_param_16'
                        THEN
                                push(p_param_16);
                        ELSIF rule_items.turin_function = 'p_param_17'
                        THEN
                                push(p_param_17);
                        ELSIF rule_items.turin_function = 'p_param_18'
                        THEN
                                push(p_param_18);
                        ELSIF rule_items.turin_function = 'p_param_19'
                        THEN
                                push(p_param_19);
                        ELSIF rule_items.turin_function = 'p_param_20'
                        THEN
                                push(p_param_20);
                        ELSIF rule_items.turin_function = 'p_param_21'
                        THEN
                                push(p_param_21);
                        ELSIF rule_items.turin_function = 'p_param_22'
                        THEN
                                push(p_param_22);
                        ELSIF rule_items.turin_function = 'p_param_23'
                        THEN
                                push(p_param_23);
                        ELSIF rule_items.turin_function = 'p_param_24'
                        THEN
                                push(p_param_24);
                        ELSIF rule_items.turin_function = 'p_param_25'
                        THEN
                                push(p_param_25);
                        ELSIF rule_items.turin_function = 'p_param_26'
                        THEN
                                push(p_param_26);
                        ELSIF rule_items.turin_function = 'p_param_27'
                        THEN
                                push(p_param_27);
                        ELSIF rule_items.turin_function = 'p_param_28'
                        THEN
                                push(p_param_28);
                        ELSIF rule_items.turin_function = 'p_param_29'
                        THEN
                                push(p_param_29);
                        ELSIF rule_items.turin_function = 'p_param_30'
                        THEN
                                push(p_param_30);
                        ELSIF rule_items.turin_function = 'p_param_31'
                        THEN
                                push(p_param_31);
                        ELSIF rule_items.turin_function = 'p_param_32'
                        THEN
                                push(p_param_32);
                        ELSIF rule_items.turin_function = 'p_param_33'
                        THEN
                                push(p_param_33);
                        ELSIF rule_items.turin_function = 'p_param_34'
                        THEN
                                push(p_param_34);
                        ELSIF rule_items.turin_function = 'p_param_35'
                        THEN
                                push(p_param_35);
                        ELSIF rule_items.turin_function = 'p_param_36'
                        THEN
                                push(p_param_36);
                        ELSIF rule_items.turin_function = 'p_param_37'
                        THEN
                                push(p_param_37);
                        ELSIF rule_items.turin_function = 'p_param_38'
                        THEN
                                push(p_param_38);
                        ELSIF rule_items.turin_function = 'p_param_39'
                        THEN
                                push(p_param_39);
                        ELSIF rule_items.turin_function = 'p_param_40'
                        THEN
                                push(p_param_40);
                        ELSIF rule_items.turin_function = 'p_param_41'
                        THEN
                                push(p_param_41);
                        ELSIF rule_items.turin_function = 'p_param_42'
                        THEN
                                push(p_param_42);
                        ELSIF rule_items.turin_function = 'p_param_43'
                        THEN
                                push(p_param_43);
                        ELSIF rule_items.turin_function = 'p_param_44'
                        THEN
                                push(p_param_44);
                        ELSIF rule_items.turin_function = 'p_param_45'
                        THEN
                                push(p_param_45);
                        ELSIF rule_items.turin_function = 'p_param_46'
                        THEN
                                push(p_param_46);
                        ELSIF rule_items.turin_function = 'p_param_47'
                        THEN
                                push(p_param_47);
                        ELSIF rule_items.turin_function = 'p_param_48'
                        THEN
                                push(p_param_48);
                        ELSIF rule_items.turin_function = 'p_param_49'
                        THEN
                                push(p_param_49);
                        ELSIF rule_items.turin_function = 'p_param_50'
                        THEN
                                push(p_param_50);
                        ELSIF rule_items.turin_function = 'p_param_51'
                        THEN
                                push(p_param_51);
                        ELSIF rule_items.turin_function = 'p_param_52'
                        THEN
                                push(p_param_52);
                        ELSIF rule_items.turin_function = 'p_param_53'
                        THEN
                                push(p_param_53);
                        ELSIF rule_items.turin_function = 'p_param_54'
                        THEN
                                push(p_param_54);

                        ELSIF rule_items.turin_function = 'fiuntcd'
                        THEN
                              Push(p_param_1);
                        ELSIF rule_items.turin_function = 'fiprgtypl'
                        THEN
                              Push(p_param_2);
                        ELSIF rule_items.turin_function = 'fiorgunt'
                        THEN
                              Push(p_param_3);
                        ELSIF rule_items.turin_function = 'fiuntmode'
                        THEN
                              Push(p_param_4);
                        ELSIF rule_items.turin_function = 'fiuntcls'
                        THEN
                              Push(p_param_5);

/* need room 99/06/29
                        ELSIF rule_items.turin_function = 'p_param_55'
                        THEN
                                push(p_param_55);
                        ELSIF rule_items.turin_function = 'p_param_56'
                        THEN
                                push(p_param_56);
                        ELSIF rule_items.turin_function = 'p_param_57'
                        THEN
                                push(p_param_57);
                        ELSIF rule_items.turin_function = 'p_param_58'
                        THEN
                                push(p_param_58);
                        ELSIF rule_items.turin_function = 'p_param_59'
                        THEN
                                push(p_param_59);
                        ELSIF rule_items.turin_function = 'p_param_60'
                        THEN
                                push(p_param_60);
                        ELSIF rule_items.turin_function = 'p_param_61'
                        THEN
                                push(p_param_61);
                        ELSIF rule_items.turin_function = 'p_param_62'
                        THEN
                                push(p_param_62);
                        ELSIF rule_items.turin_function = 'p_param_63'
                        THEN
                                push(p_param_63);
                        ELSIF rule_items.turin_function = 'p_param_64'
                        THEN
                                push(p_param_64);
                        ELSIF rule_items.turin_function = 'p_param_65'
                        THEN
                                push(p_param_65);
                        ELSIF rule_items.turin_function = 'p_param_66'
                        THEN
                                push(p_param_66);
                        ELSIF rule_items.turin_function = 'p_param_67'
                        THEN
                                push(p_param_67);
                        ELSIF rule_items.turin_function = 'p_param_68'
                        THEN
                                push(p_param_68);
                        ELSIF rule_items.turin_function = 'p_param_69'
                        THEN
                                push(p_param_69);
                        ELSIF rule_items.turin_function = 'p_param_70'
                        THEN
                                push(p_param_70);
                        ELSIF rule_items.turin_function = 'p_param_71'
                        THEN
                                push(p_param_71);
                        ELSIF rule_items.turin_function = 'p_param_72'
                        THEN
                                push(p_param_72);
                        ELSIF rule_items.turin_function = 'p_param_73'
                        THEN
                                push(p_param_73);
                        ELSIF rule_items.turin_function = 'p_param_74'
                        THEN
                                push(p_param_74);
                        ELSIF rule_items.turin_function = 'p_param_75'
                        THEN
                                push(p_param_75);
                        ELSIF rule_items.turin_function = 'p_param_76'
                        THEN
                                push(p_param_76);
                        ELSIF rule_items.turin_function = 'p_param_77'
                        THEN
                                push(p_param_77);
                        ELSIF rule_items.turin_function = 'p_param_78'
                        THEN
                                push(p_param_78);
                        ELSIF rule_items.turin_function = 'p_param_79'
                        THEN
                                push(p_param_79);
                        ELSIF rule_items.turin_function = 'p_param_80'
                        THEN
                                push(p_param_80);
                        ELSIF rule_items.turin_function = 'p_param_81'
                        THEN
                                push(p_param_81);
                        ELSIF rule_items.turin_function = 'p_param_82'
                        THEN
                                push(p_param_82);
                        ELSIF rule_items.turin_function = 'p_param_83'
                        THEN
                                push(p_param_83);
                        ELSIF rule_items.turin_function = 'p_param_84'
                        THEN
                                push(p_param_84);
                        ELSIF rule_items.turin_function = 'p_param_85'
                        THEN
                                push(p_param_85);
                        ELSIF rule_items.turin_function = 'p_param_86'
                        THEN
                                push(p_param_86);
                        ELSIF rule_items.turin_function = 'p_param_87'
                        THEN
                                push(p_param_87);
                        ELSIF rule_items.turin_function = 'p_param_88'
                        THEN
                                push(p_param_88);
                        ELSIF rule_items.turin_function = 'p_param_89'
                        THEN
                                push(p_param_89);
                        ELSIF rule_items.turin_function = 'p_param_90'
                        THEN
                                push(p_param_90);
                        ELSIF rule_items.turin_function = 'p_param_91'
                        THEN
                                push(p_param_91);
                        ELSIF rule_items.turin_function = 'p_param_92'
                        THEN
                                push(p_param_92);
                        ELSIF rule_items.turin_function = 'p_param_93'
                        THEN
                                push(p_param_93);
                        ELSIF rule_items.turin_function = 'p_param_94'
                        THEN
                                push(p_param_94);
                        ELSIF rule_items.turin_function = 'p_param_95'
                        THEN
                                push(p_param_95);
                        ELSIF rule_items.turin_function = 'p_param_96'
                        THEN
                                push(p_param_96);
                        ELSIF rule_items.turin_function = 'p_param_97'
                        THEN
                                push(p_param_97);
                        ELSIF rule_items.turin_function = 'p_param_98'
                        THEN
                                push(p_param_98);
                        ELSIF rule_items.turin_function = 'p_param_99'
                        THEN
                                push(p_param_99);
*/
                        ELSE
                                log_error('turing',
                                        'Unknown turing function:'||
                                        rule_items.turin_function||
                                        ': rule='||p_rule_number);
                        END IF;
                ELSIF rule_items.named_rule IS NOT NULL
                THEN
                        push(rule_items.named_rule);
/*
                         parameter count
*/
                        push(NVL(rule_items.value,0));
                ELSIF rule_items.rule_number IS NOT NULL
                THEN
/*
                         repush the parameters
*/
                        push_params(v_start_stack,NVL(rule_items.value,0));
                        push(rule_items.rule_number);
/*
                         parameter count
*/
                        push(NVL(rule_items.value,0));
                ELSIF rule_items.set_number IS NOT NULL
                THEN
                        push(expand_set(rule_items.set_number));
                ELSE
/*
                         rule_items.value can be null (null string)
*/
                        push(rule_items.value);
                END IF;
        END LOOP;
        v_result := pop;
/*
         check stack
*/

        IF v_start_stack <> gv_stack_index
        THEN
                log_error('turing',
                        'Unbalanced stack:Start='||
                        v_start_stack||' Current='||
                        gv_stack_index||Fnd_Global.Local_Chr(10)||
                        'rule='||p_rule_number);
        END IF;
        do_message(p_rule_number,v_result,p_tds);
        gv_turing_level := gv_turing_level - 1;
        RETURN (v_result);
END turing;
/*
 rulp_val_senna - the IGS_RU_RULE engine driver
*/
BEGIN DECLARE
        v_rule_number   NUMBER;
        v_turing_return IGS_RU_ITEM.value%TYPE;
        v_tds           r_tds;
        v_before_t      DATE;
        v_before_rb     DATE;
BEGIN
        v_before_t := sysdate;
/*
         initialise globals
*/
        gv_turing_level := 0;
        gv_stack_index := 0;
        gv_set_index := 0;
        gv_member_index := 1;
/*
         delete any existing messages, reset index
*/
        gt_message_stack := gt_empty_message_stack;
        gv_message_stack_index := 0;
/*
         if defined use p_rule_number
*/
        IF p_rule_number IS NOT NULL
        THEN
                v_rule_number := p_rule_number;
        ELSIF p_rule_call_name IS NOT NULL
        THEN
                v_rule_number := get_called_rule(p_rule_call_name);
        ELSE
                log_error('main',
                        'Invalid rule call');
        END IF;
/*
         evaluate RULE
*/
        v_turing_return := RTRIM(turing(v_rule_number,v_tds));
        /*
        * Who : Navin  When : 27-Aug-2001
        * What : Following IF condition is added as part of Bug# : 1899513.
        */
        IF p_rule_call_name = 'AD-TRK-SET' AND v_turing_return IS NOT NULL THEN
                 v_turing_return := display_set ( v_turing_return );
        END IF;

        p_message := get_message;
        v_before_rb := sysdate;
        RETURN v_turing_return;
        EXCEPTION
        WHEN rule_error THEN
                p_message := 'Rule Error while processing rule ';
		IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
		        FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.rules.error :',p_message||':'||SQLERRM);
		END IF;
                RETURN NULL;
        WHEN OTHERS THEN
                log_error('main',
                        'Error while processing rule');
                p_message := 'Error while processing rule ';
		IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
		        FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.rules.error :',p_message||':'||SQLERRM);
		END IF;
                RETURN NULL;
END;

END rulp_val_senna;

END igs_ru_gen_001;

/
