--------------------------------------------------------
--  DDL for Package Body IGS_FI_F_TYP_CA_INST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_F_TYP_CA_INST_PKG" AS
/* $Header: IGSSI49B.pls 120.3 2005/09/03 10:49:56 appldev ship $ */

/*********************************************************************************************
 | Who         When         What
 | gurprsin   16-Aug-2005   Bug# 3392088 , Added a column max_chg_elements as part of CPF build.
 | gurprsin   18-Jun-2005   Bug# 3392088 , Added 2 new columns scope_rul_sequence_num and elm_rng_order_name.
 | svuppala   13-Apr-2005   Bug 4297359 - ER REGISTRATION FEE ISSUE - ASSESSED TO STUDENTS WITH NO LOAD
 |                          Added new field NONZERO_BILLABLE_CP_FLAG in Fee Type Calendar Instances Table.
 | pathipat   11-Feb-2003   Enh 2747325 - Locking Issues build
 |                          Changes according to FI204_TD_Locking_Issues_s1a.doc
 |
 | sbaliga     13-feb-2002  Modified call to before_dml in insert_row procedure
 |                          as part of SWCR006 build.
 | Bug 1956374
 |   What :Duplicate code removal Pointed finp_val_fss_closed to igs_fi_val_fcci
 |         Pointed finp_val_ft_closed to igs_fi_val_cfar
 |   Who msrinivi
 |
 |      Bug 2126091
 |      What Removed calls to IGS_FI_FEE_ENCMB_PKG and IGS_FI_FEE_ENCMB_H_PKG as these tables are obsleted.
 |      Who sykrishn
 |      When 30112001
 |
 | agairola    07-Sep-2004      Enh 3316063: Retention Enhancements changes
 | shtatiko      13-may-2003    Enh# 2831572, Modified check_constraints.
 | vvutukur      23-Jul-2002    Bug#2425767.removed payment_hierarchy_rank references from set_column_values,
 |                              insert_row,update_row,lock_row,add_row,before_dml,AfterRowUpdate3.Removed
 |                              procedure AfterStmtInsertUpdate4 as this procedure has only one validation
 |                              which validates payment_hierarchy_rank.Modified After_DML procedure to
 |                              removed references to AfterStmtInsertUpdate4 procedure.
 | jbegum          10-jun-02    As part of bug #2403209 commented local procedure AfterStmtInsertUpdate4
 |                              and calls to it in the package
 |  vvutukur     20-may-2002    bug#2344826.modified check_constraints procedure.
 |  vchappid     25-Apr-2002    Bug# 2329407, Removed the parameters account_cd, fin_cal_type
 |                              and fin_ci_sequence_number from the function call finp_val_ftci_rqrd,
 |                              removed the parameters from procedure 'finp_ins_ftci_hist' in the procedure
 |                              AfterRowUpdate3 procedure
 |                              Removed the reference to the Account_Cd column from the table igs_fi_f_typ_ca_inst table
 |
 | agairola     08-Mar-2002     Enh# 2144600 added the get_Fk in the check child existance for Refunds Interface
 | vchappid     25-Feb-2002     Enh# 2144600, added get_fk in the check_child_existance
 | vchappid     06-Feb-2002     Enh# 2187247, Removed calls to IGS_FI_CHG_MTH_APP_PKG, IGS_FI_CHG_MTH_APP_H_PKG
 |                              as these table are obsolete
 | vvutukur     25-jan-2002     Code added for bug 2195715 as part of SFCR003 in BeforeRowInsertUpdateDelete1
 | vvutukur     11-Jan-2002     Code related to subaccount id is removed as part of Bug 2175865
 | vivuyyur     10-sep-2001     Bug No :1966961
 |                              Procedure GET_FK_IGS_FI_ACC is removed ,
 |                              IGS_FI_ACC_PKG.Get_PK_For_Validation is changed.
 |                              Check constraints related to FIN_CAL_TYPE,FIN_CI_SEQUENCE_NUMBER are
 |                              deleted . GET_PK_FOR_VALIDATION , IGS_FI_VAL_FTCI.finp_val_ftci_ac are changed.
 |                              fin_cal_type,fin_ci_sequence_number,account_cd are removed from Table Handler calls
 | jbegum       16-nov-2001     As part of the bug# 2113459
 |                              Added two new columns ret_gl_ccid and ret_account_cd.
 |                              Also modified the procedures check_parent_existence and GET_FK_IGS_FI_ACC_ALL
 | sarakshi     20-Nov-2001     In the update_row proc , for the account_cd and ccid columns , they are set to new references
 | sarakshi     20-Nov-2001     In the proc check parants existance removed the condition of old value null and new value
 |                              null to do nothing, instead only new value to be null to do nothing
 |bayadav       20-DEC-2001    Removed calls to IGS_PE_PND_FEE_ENCUM_PKG as these table is obsleted.
 |                              This is as per the SFCR015-HOLDS DLD. Bug:2126091
 **************************************************************************************************************/

  l_rowid VARCHAR2(25);
  old_references IGS_FI_F_TYP_CA_INST_ALL%RowType;
  new_references IGS_FI_F_TYP_CA_INST_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_fee_type_ci_status IN VARCHAR2 DEFAULT NULL,
    x_start_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_start_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_end_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_end_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_retro_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_retro_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_s_chg_method_type IN VARCHAR2 DEFAULT NULL,
    x_rul_sequence_number IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_initial_default_amount in NUMBER DEFAULT NULL,
    x_acct_hier_id IN NUMBER DEFAULT NULL,
    x_rec_gl_ccid IN NUMBER DEFAULT NULL,
    x_rev_account_cd IN VARCHAR2 DEFAULT NULL,
    x_rec_account_cd IN VARCHAR2 DEFAULT NULL,
    x_ret_gl_ccid IN NUMBER DEFAULT NULL,
    x_ret_account_cd IN VARCHAR2 DEFAULT NULL,
    x_retention_level_code IN VARCHAR2 DEFAULT NULL,
    x_complete_ret_flag IN VARCHAR2 DEFAULT NULL,
    x_nonzero_billable_cp_flag IN VARCHAR2 DEFAULT NULL,
    x_scope_rul_sequence_num IN NUMBER DEFAULT NULL,
    x_elm_rng_order_name IN VARCHAR2 DEFAULT NULL,
    X_MAX_CHG_ELEMENTS IN NUMBER DEFAULT NULL
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  gurprsin    16-Aug-2005      Bug# 3392088 , Added a column max_chg_elements as part of CPF build.
  ||  gurprsin      18-Jun-2005   Bug# 3392088 , Added 2 new columns scope_rul_sequence_num and elm_rng_order_name.
  ||  svuppala    13-Apr-2005      Bug 4297359 Added new field NONZERO_BILLABLE_CP_FLAG in Fee Type Calendar Instances Table
  ||  agairola    07-Sep-2004      Enh 3316063: Retention Enhancements changes
  ||  vvutukur        23-Jul-2002  Bug#2425767.removed parameter x_payment_hierarchy_rank
  ||                               and its reference in copying old_references value
  ||                               into new_references value.
  ----------------------------------------------------------------------------*/
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_F_TYP_CA_INST_ALL
      WHERE    rowid = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_old_ref_values;
      Return;
    END IF;
    Close cur_old_ref_values;
    -- Populate New Values.
    new_references.fee_type := x_fee_type;
    new_references.fee_cal_type := x_fee_cal_type;
    new_references.fee_ci_sequence_number := x_fee_ci_sequence_number;
    new_references.fee_type_ci_status := x_fee_type_ci_status;
    new_references.start_dt_alias := x_start_dt_alias;
    new_references.start_dai_sequence_number := x_start_dai_sequence_number;
    new_references.end_dt_alias := x_end_dt_alias;
    new_references.end_dai_sequence_number := x_end_dai_sequence_number;
    new_references.retro_dt_alias := x_retro_dt_alias;
    new_references.retro_dai_sequence_number := x_retro_dai_sequence_number;
    new_references.s_chg_method_type := x_s_chg_method_type;
    new_references.rul_sequence_number := x_rul_sequence_number;
    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.org_id                 := x_org_id;
    new_references.last_update_date       := x_last_update_date;
    new_references.last_updated_by        := x_last_updated_by;
    new_references.last_update_login      := x_last_update_login;
    new_references.initial_default_amount := x_initial_default_amount;
    new_references.acct_hier_id           := x_acct_hier_id;
    new_references.rec_gl_ccid            := x_rec_gl_ccid;
    new_references.rev_account_cd         := x_rev_account_cd;
    new_references.rec_account_cd         := x_rec_account_cd;
    new_references.ret_gl_ccid            := x_ret_gl_ccid;
    new_references.ret_account_cd         := x_ret_account_cd;
    new_references.retention_level_code   := x_retention_level_code;
    new_references.complete_ret_flag      := x_complete_ret_flag;
    new_references.nonzero_billable_cp_flag := x_nonzero_billable_cp_flag;
    new_references.scope_rul_sequence_num      := x_scope_rul_sequence_num;
    new_references.elm_rng_order_name    := x_elm_rng_order_name;
    new_references.max_chg_elements      := x_max_chg_elements;
  END Set_Column_Values;
  -- Trigger description :-
  -- "OSS_TST".trg_ftci_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_FI_F_TYP_CA_INST_ALL
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
--CHANGE HISTORY
--WHO           WHEN           WHAT
--gurprsin    18-Jun-2005      Bug# 3392088 , Added 2 new columns scope_rul_sequence_num and elm_rng_order_name.
--vvutukur    25-jan-2002      code added for the following validation for bug 2195715:
--                             account hierarchy field should be updateable only if there
--                             exists no charge, for active fee type calendar instance.

--Cursor to check if there exists a charge for current fee type calendar instance.
--created cursor by vvutukur on 25-jan-2002 for bug

  CURSOR cur_acct_hier_chrg(cp_fee_type               VARCHAR2,
                            cp_fee_cal_type           VARCHAR2,
                            cp_fee_ci_sequence_number NUMBER
                           ) IS
    SELECT 'x'
    FROM   igs_fi_inv_int
    WHERE  fee_type = cp_fee_type
    AND    fee_cal_type = cp_fee_cal_type
    AND    fee_ci_sequence_number = cp_fee_ci_sequence_number;

    l_var          VARCHAR2(1);
    v_message_name varchar2(30);

  BEGIN
        -- Validate Fee Type is not closed
        IF (p_inserting OR p_updating) THEN
                IF IGS_FI_VAL_CFAR.finp_val_ft_closed (
                                new_references.fee_type,
                                v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
        END IF;
        -- Validate Fee Type Calendar is of type FEE
        IF (p_inserting) THEN
                IF IGS_FI_VAL_FCCI.finp_val_ci_fee (
                                new_references.fee_cal_type,
                                new_references.fee_ci_sequence_number,
                                v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
        END IF;
        -- Validate Fee Type fee and fin calenders are related
        IF p_inserting THEN

                IF IGS_FI_VAL_FTCI.finp_val_ftci_ac (
                                new_references.fee_cal_type,
                                new_references.fee_ci_sequence_number,
                                v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
        END IF;
        -- Validate Fee Type CI Status is not closed.
        IF (p_inserting OR (old_references.fee_type_ci_status) <>
                        (new_references.fee_type_ci_status)) THEN
                IF IGS_FI_VAL_FCCI.finp_val_fss_closed (
                                new_references.fee_type_ci_status,
                                v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
        END IF;
        -- Validate status can be changed to the new value.
        IF (p_updating AND (old_references.fee_type_ci_status) <>
                        (new_references.fee_type_ci_status)) THEN
                IF IGS_FI_VAL_FTCI.finp_val_ftci_status (
                                new_references.fee_type,
                                new_references.fee_cal_type,
                                new_references.fee_ci_sequence_number,
                                new_references.fee_type_ci_status,
                                old_references.fee_type_ci_status,
                                v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
        END IF;
        -- Validate the Charge Method s_chg_method_type.
        IF (p_inserting OR (old_references.s_chg_method_type) <>
                        (new_references.s_chg_method_type)) THEN
                IF IGS_FI_VAL_FTCI.finp_val_ftci_c_mthd (
                                new_references.fee_type,
                                new_references.s_chg_method_type,
                                v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
        END IF;
        -- Validate the Start, End and Retro dates.
        IF (p_inserting OR
                (old_references.start_dt_alias) <> (new_references.start_dt_alias) OR
                (old_references.start_dai_sequence_number) <> (new_references.start_dai_sequence_number) OR
                (old_references.end_dt_alias) <> (new_references.end_dt_alias) OR
                (old_references.end_dai_sequence_number) <> (new_references.end_dai_sequence_number) OR
                (old_references.retro_dt_alias) <> (new_references.retro_dt_alias) OR
                (old_references.retro_dai_sequence_number) <> (new_references.retro_dai_sequence_number)) THEN
                IF IGS_FI_VAL_FTCI.finp_val_ftci_dates (
                                new_references.fee_cal_type,
                                new_references.fee_ci_sequence_number,
                                new_references.start_dt_alias,
                                new_references.start_dai_sequence_number,
                                new_references.end_dt_alias,
                                new_references.end_dai_sequence_number,
                                new_references.retro_dt_alias,
                                new_references.retro_dai_sequence_number,
                                v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
        END IF;
        -- Validate the required data has been entered for the Fee Type calendar status
        IF (p_inserting OR p_updating) THEN
                IF IGS_FI_VAL_FTCI.finp_val_ftci_rqrd (
                                new_references.fee_cal_type,
                                new_references.fee_ci_sequence_number,
                                new_references.fee_type,
                                old_references.s_chg_method_type,
                                old_references.rul_sequence_number,
                                new_references.s_chg_method_type,
                                new_references.rul_sequence_number,
                                new_references.fee_type_ci_status,
                                v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF (p_updating AND old_references.acct_hier_id <> new_references.acct_hier_id) THEN
          OPEN cur_acct_hier_chrg(new_references.fee_type,
                                  new_references.fee_cal_type,
                                  new_references.fee_ci_sequence_number);
          FETCH cur_acct_hier_chrg INTO l_var;
          IF cur_acct_hier_chrg%FOUND THEN
            CLOSE cur_acct_hier_chrg;
            FND_MESSAGE.SET_NAME('IGS','IGS_FI_AC_HI_NT_UPD');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;
          CLOSE cur_acct_hier_chrg;
        END IF;
  END BeforeRowInsertUpdateDelete1;
  -- Trigger description :-
  -- "OSS_TST".trg_ftci_ar_u_hist
  -- AFTER UPDATE
  -- ON IGS_FI_F_TYP_CA_INST_ALL
  -- FOR EACH ROW
  PROCEDURE AfterRowUpdate3(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  gurprsin      18-Jun-2005   Bug# 3392088 , Added 2 new columns scope_rul_sequence_num and elm_rng_order_name.
  ||  svuppala        13-Apr-2005  Bug 4297359 New field "nonzero_billable_cp_flag"
  ||  vvutukur        23-Jul-2002  Bug#2425767.removed payment_hierarchy_rank references(from call to
  ||                               IGS_FI_GEN_002.FINP_INS_FTCI_HIST.
  ----------------------------------------------------------------------------*/
  BEGIN
        -- create a history
        IGS_FI_GEN_002.FINP_INS_FTCI_HIST(old_references.fee_type,
                old_references.fee_cal_type,
                old_references.fee_ci_sequence_number,
                new_references.fee_type_ci_status,
                old_references.fee_type_ci_status,
                new_references.start_dt_alias,
                old_references.start_dt_alias,
                new_references.start_dai_sequence_number,
                old_references.start_dai_sequence_number,
                new_references.end_dt_alias,
                old_references.end_dt_alias,
                new_references.end_dai_sequence_number,
                old_references.end_dai_sequence_number,
                new_references.retro_dt_alias,
                old_references.retro_dt_alias,
                new_references.retro_dai_sequence_number,
                old_references.retro_dai_sequence_number,
                new_references.s_chg_method_type,
                old_references.s_chg_method_type,
                new_references.rul_sequence_number,
                old_references.rul_sequence_number,
                new_references.last_updated_by,
                old_references.last_updated_by,
                new_references.last_update_date,
                old_references.last_update_date,
                -- msrinivi : 1882122 Commented due to leap frog
                -- msrinivi: 1882122 Uncommented after leapfrog
               --msrinivi: 1956374 Commented due to leap frog
               --msrinivi: 1956374 Uncommented after leap frog
                 new_references.initial_default_amount,
                 old_references.initial_default_amount,
                 new_references.nonzero_billable_cp_flag,
                 old_references.nonzero_billable_cp_flag
       );
  END AfterRowUpdate3;

  -- As part of bug fix of bug#2403209 the following procedure has been commented out NOCOPY

  -- Trigger description :-
  -- "OSS_TST".trg_ftci_as_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_FI_F_TYP_CA_INST_ALL
  PROCEDURE Check_Constraints (
    column_name  IN  VARCHAR2 DEFAULT NULL,
    column_value IN  VARCHAR2 DEFAULT NULL
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  gurprsin      16-Aug-2005   Bug# 3392088 , Added a column max_chg_elements as part of CPF build.
  ||  gurprsin      18-Jun-2005   Bug# 3392088 , Added 2 new columns scope_rul_sequence_num and elm_rng_order_name.
  ||  svuppala        13-Apr-2005   Bug 4297359 Added new field NONZERO_BILLABLE_CP_FLAG in Fee Type Calendar Instances Table
  ||  shtatiko        13-MAY-2003   Enh# 2831572, Check for ACC_HIER_ID is done only
  ||                                if Oracle General Ledger is installed
  ||  vvutukur        20-May-2002   removed upper check constraint on fee_type,
  ||                            fee_type_ci_status(alias of fee_structure_status) columns.bug#2344826.
  ----------------------------------------------------------------------------*/
  l_v_rec_installed igs_fi_control_all.rec_installed%TYPE;

  BEGIN
    IF (column_name IS NULL) THEN
      NULL;
    ELSIF (UPPER (column_name) = 'END_DT_ALIAS') THEN
      new_references.end_dt_alias := column_value;
    ELSIF (UPPER (column_name) = 'FEE_CAL_TYPE') THEN
      new_references.fee_cal_type := column_value;
    ELSIF (UPPER (column_name) = 'RETRO_DT_ALIAS') THEN
      new_references.retro_dt_alias := column_value;
    ELSIF (UPPER (column_name) = 'START_DT_ALIAS') THEN
      new_references.start_dt_alias := column_value;
    ELSIF (UPPER (column_name) = 'S_CHG_METHOD_TYPE') THEN
      new_references.s_chg_method_type := column_value;
    ELSIF (UPPER (column_name) = 'START_DAI_SEQUENCE_NUMBER') THEN
      new_references.start_dai_sequence_number := IGS_GE_NUMBER.TO_NUM (column_value);
    ELSIF (UPPER (column_name) = 'RETRO_DAI_SEQUENCE_NUMBER') THEN
      new_references.retro_dai_sequence_number := IGS_GE_NUMBER.TO_NUM (column_value);
    ELSIF (UPPER (column_name) = 'END_DAI_SEQUENCE_NUMBER') THEN
      new_references.end_dai_sequence_number := IGS_GE_NUMBER.TO_NUM (column_value);
    ELSIF (UPPER (column_name) = 'RUL_SEQUENCE_NUMBER') THEN
      new_references.rul_sequence_number := IGS_GE_NUMBER.TO_NUM (column_value);
    ELSIF (UPPER (column_name) = 'FEE_CI_SEQUENCE_NUMBER') THEN
      new_references.fee_ci_sequence_number := IGS_GE_NUMBER.TO_NUM (column_value);

    --Removed IF condition related to subaccount_id, as part of Bug 2175865

    ELSIF (UPPER (column_name) = 'INITIAL_DEFAULT_AMOUNT') THEN
      new_references.initial_default_amount := IGS_GE_NUMBER.TO_NUM (column_value);
    ELSIF (UPPER(column_name) = 'ACCT_HIER_ID') THEN
      new_references.acct_hier_id := column_value;
    ELSIF (UPPER(column_name) = 'RETENTION_LEVEL_CODE') THEN
      new_references.retention_level_code := column_value;
    ELSIF (UPPER(column_name) = 'COMPLETE_RET_FLAG') THEN
      new_references.complete_ret_flag := column_value;
    ELSIF (UPPER(column_name) = 'NONZERO_BILLABLE_CP_FLAG') THEN
      new_references.nonzero_billable_cp_flag := column_value;
    ELSIF (UPPER(column_name) = 'scope_rul_sequence_num') THEN
      new_references.scope_rul_sequence_num := IGS_GE_NUMBER.TO_NUM (column_value);
    ELSIF (UPPER(column_name) = 'ELM_RNG_ORDER_NAME') THEN
      new_references.elm_rng_order_name := column_value;
    ELSIF (UPPER(column_name) = 'MAX_CHG_ELEMENTS') THEN
      new_references.max_chg_elements := column_value;
    END IF;


    -- Fetch the value of rec_installed
    l_v_rec_installed := igs_fi_gen_005.finp_get_receivables_inst;

    IF ((UPPER (column_name) = 'END_DT_ALIAS') OR (column_name IS NULL)) THEN
      IF (new_references.end_dt_alias <> UPPER (new_references.end_dt_alias)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'FEE_CAL_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.fee_cal_type <> UPPER (new_references.fee_cal_type)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'RETRO_DT_ALIAS') OR (column_name IS NULL)) THEN
      IF (new_references.retro_dt_alias <> UPPER (new_references.retro_dt_alias)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'START_DT_ALIAS') OR (column_name IS NULL)) THEN
      IF (new_references.start_dt_alias <> UPPER (new_references.start_dt_alias)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'S_CHG_METHOD_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.s_chg_method_type <> UPPER (new_references.s_chg_method_type)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'START_DAI_SEQUENCE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.start_dai_sequence_number < 1) OR (new_references.start_dai_sequence_number > 999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'RETRO_DAI_SEQUENCE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.retro_dai_sequence_number < 1) OR (new_references.retro_dai_sequence_number > 999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'END_DAI_SEQUENCE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.end_dai_sequence_number < 1) OR (new_references.end_dai_sequence_number >999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'RUL_SEQUENCE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.rul_sequence_number < 1) OR (new_references.rul_sequence_number > 999999))
 THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'FEE_CI_SEQUENCE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.fee_ci_sequence_number < 1) OR (new_references.fee_ci_sequence_number > 999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    --Removed IF related to subaccount_id,as part of Bug 2175865

    IF ((UPPER (column_name) = 'INITIAL_DEFAULT_AMOUNT') OR (column_name IS NULL)) THEN
      IF ((new_references.initial_default_amount < 0) OR (new_references.initial_default_amount > 999999.99)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
--msrinivi : bug 1882122  Account hier id is not null
    -- Validation of Account Hierarchy Id should be done only if Oracle General Ledger is installed.
    IF l_v_rec_installed = 'Y'
       AND (UPPER(column_name) = 'ACCT_HIER_ID'
            OR (column_name IS NULL)) THEN
      IF new_references.acct_hier_id IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'COMPLETE_RET_FLAG') OR (column_name IS NULL)) THEN
      IF (new_references.complete_ret_flag NOT IN ('Y','N') OR new_references.complete_ret_flag IS NULL) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'NONZERO_BILLABLE_CP_FLAG') OR (column_name IS NULL)) THEN
      IF (new_references.nonzero_billable_cp_flag NOT IN ('Y','N') OR new_references.nonzero_billable_cp_flag IS NULL) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'scope_rul_sequence_num') OR (column_name IS NULL)) THEN
      IF ((new_references.scope_rul_sequence_num < 1) OR (new_references.scope_rul_sequence_num > 999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'ELM_RNG_ORDER_NAME') OR (column_name IS NULL)) THEN
      IF (new_references.elm_rng_order_name <> UPPER (new_references.elm_rng_order_name)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'MAX_CHG_ELEMENTS') OR (column_name IS NULL)) THEN
     IF ((new_references.max_chg_elements < 0) OR (new_references.max_chg_elements > 9999999.999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance IS
    CURSOR c_gl_code_combinations_pk IS
      SELECT 'X'
      FROM GL_CODE_COMBINATIONS
      WHERE code_combination_id = new_references.rec_gl_ccid;
    l_ccid_temp c_gl_code_combinations_pk%ROWTYPE;

  BEGIN
    IF (((old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
               new_references.fee_cal_type,
               new_references.fee_ci_sequence_number
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((old_references.rec_account_cd = new_references.rec_account_cd) OR
         (new_references.rec_account_cd IS NULL)) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_ACC_PKG.Get_PK_For_Validation (
               new_references.rec_account_cd
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((old_references.rev_account_cd = new_references.rev_account_cd) OR
         (new_references.rev_account_cd IS NULL)) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_ACC_PKG.Get_PK_For_Validation (
               new_references.rev_account_cd
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.end_dt_alias = new_references.end_dt_alias) AND
         (old_references.end_dai_sequence_number = new_references.end_dai_sequence_number) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.end_dt_alias IS NULL) OR
         (new_references.end_dai_sequence_number IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_INST_PKG.Get_PK_For_Validation (
               new_references.end_dt_alias,
               new_references.end_dai_sequence_number,
               new_references.fee_cal_type,
               new_references.fee_ci_sequence_number
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.fee_type_ci_status = new_references.fee_type_ci_status)) OR
        ((new_references.fee_type_ci_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_FEE_STR_STAT_PKG.Get_PK_For_Validation (
               new_references.fee_type_ci_status
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.fee_type = new_references.fee_type)) OR
        ((new_references.fee_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_FEE_TYPE_PKG.Get_PK_For_Validation (
               new_references.fee_type
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.retro_dt_alias = new_references.retro_dt_alias) AND
         (old_references.retro_dai_sequence_number = new_references.retro_dai_sequence_number) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.retro_dt_alias IS NULL) OR
         (new_references.retro_dai_sequence_number IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_INST_PKG.Get_PK_For_Validation (
               new_references.retro_dt_alias,
               new_references.retro_dai_sequence_number,
               new_references.fee_cal_type,
               new_references.fee_ci_sequence_number
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.rul_sequence_number = new_references.rul_sequence_number)) OR
        ((new_references.rul_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RU_RULE_PKG.Get_PK_For_Validation (
               new_references.rul_sequence_number
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.start_dt_alias = new_references.start_dt_alias) AND
         (old_references.start_dai_sequence_number = new_references.start_dai_sequence_number) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.start_dt_alias IS NULL) OR
         (new_references.start_dai_sequence_number IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_INST_PKG.Get_PK_For_Validation (
               new_references.start_dt_alias,
               new_references.start_dai_sequence_number,
               new_references.fee_cal_type,
               new_references.fee_ci_sequence_number
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    --Added by msrinivi for bug 1882122
    IF ( (old_references.acct_hier_id = new_references.acct_hier_id) OR
        --commented by sarakshi, as a part of SFCR012,
        --(old_references.acct_hier_id IS NULL AND
        (new_references.acct_hier_id IS NULL))
    THEN
      NULL;
    ELSE
      IF NOT  IGS_FI_HIER_ACCOUNTS_PKG.get_pk_for_validation(
         new_references.acct_hier_id) THEN
         FND_MESSAGE.set_name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
    END IF;
    --Added by msrinivi for bug 1882122
    IF ( (old_references.rec_gl_ccid = new_references.rec_gl_ccid) OR
        --commented by sarakshi, as a part of SFCR012,
        -- (old_references.rec_gl_ccid IS NULL AND
          (new_references.rec_gl_ccid IS NULL))
    THEN
      NULL;
    ELSE
      OPEN c_gl_code_combinations_pk;
      FETCH c_gl_code_combinations_pk INTO l_ccid_temp;
      IF c_gl_code_combinations_pk%NOTFOUND THEN
         CLOSE c_gl_code_combinations_pk;
         FND_MESSAGE.set_name ('FND', 'FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
      IF c_gl_code_combinations_pk%ISOPEN THEN
        CLOSE c_gl_code_combinations_pk;
      END IF;
    END IF;

    -- Added by jbegum for bug #2113459
    IF ((old_references.ret_account_cd = new_references.ret_account_cd) OR
         (new_references.ret_account_cd IS NULL)) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_ACC_PKG.Get_PK_For_Validation (
               new_references.ret_account_cd
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((old_references.retention_level_code = new_references.retention_level_code) OR
         (new_references.retention_level_code IS NULL)) THEN
      NULL;
    ELSE
      IF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
               'IGS_FI_RET_LEVEL',
               new_references.retention_level_code
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((old_references.elm_rng_order_name = new_references.elm_rng_order_name) OR
         (new_references.elm_rng_order_name IS NULL)) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_ELM_RNG_ORDS_PKG.Get_PK_For_Validation (
               new_references.elm_rng_order_name
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.scope_rul_sequence_num = new_references.scope_rul_sequence_num)) OR
        ((new_references.scope_rul_sequence_num IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RU_RULE_PKG.Get_PK_For_Validation (
               new_references.scope_rul_sequence_num
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Parent_Existance;


  FUNCTION Get_PK_For_Validation (
    x_fee_type IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER
    ) RETURN BOOLEAN AS
  ------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --pathipat    11-Feb-2003     Enh 2747325 - Locking Issues Build
  --                            Removed FOR UPDATE NOWAIT clause in cursor cur_rowid
  -------------------------------------------------------------------

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_TYP_CA_INST_ALL
      WHERE    fee_type = x_fee_type
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number;

    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return (TRUE);
    ELSE
      Close cur_rowid;
      Return (FALSE);
    END IF;
  END Get_PK_For_Validation;


  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_TYP_CA_INST_ALL
      WHERE    fee_cal_type = x_cal_type
      AND      fee_ci_sequence_number = x_sequence_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FTCI_CI_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_rowid;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_CA_INST;


  PROCEDURE GET_FK_IGS_CA_DA_INST (
    x_dt_alias IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_TYP_CA_INST_ALL
      WHERE    (end_dt_alias = x_dt_alias
      AND      end_dai_sequence_number = x_sequence_number
      AND      fee_cal_type = x_cal_type
      AND      fee_ci_sequence_number = x_ci_sequence_number)
      OR       (retro_dt_alias = x_dt_alias
      AND      retro_dai_sequence_number = x_sequence_number
      AND      fee_cal_type = x_cal_type
      AND      fee_ci_sequence_number = x_ci_sequence_number)
      OR       (start_dt_alias = x_dt_alias
      AND      start_dai_sequence_number = x_sequence_number
      AND      fee_cal_type = x_cal_type
      AND      fee_ci_sequence_number = x_ci_sequence_number);
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FTCI_END_DAI_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_rowid;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_CA_DA_INST;

  PROCEDURE GET_FK_IGS_FI_FEE_STR_STAT (
    x_fee_structure_status IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_TYP_CA_INST_ALL
      WHERE    fee_type_ci_status = x_fee_structure_status ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FTCI_FSST_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_rowid;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_FI_FEE_STR_STAT;

  --Removed the procedure get_fk_igs_fi_subaccts_all as part of Bug 2175865

  PROCEDURE GET_FK_IGS_RU_RULE (
    x_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_TYP_CA_INST_ALL
      WHERE    rul_sequence_number = x_sequence_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FTCI_RUL_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_rowid;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_RU_RULE;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_chg_method_type IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_TYP_CA_INST_ALL
      WHERE    s_chg_method_type = x_s_chg_method_type ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FTCI_SLV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_rowid;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_LOOKUPS_VIEW ;

  PROCEDURE GET_FK_IGS_FI_ELM_RNG_ORDS (
    x_elm_rng_order_name IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_TYP_CA_INST_ALL
      WHERE    elm_rng_order_name = x_elm_rng_order_name ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FERO_FTCI_FK1');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_rowid;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_FI_ELM_RNG_ORDS ;

  PROCEDURE GET_FK1_IGS_RU_RULE (
    x_scope_rul_sequence_num IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_TYP_CA_INST_ALL
      WHERE    scope_rul_sequence_num = x_scope_rul_sequence_num ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FERO_FTCI_FK2');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_rowid;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK1_IGS_RU_RULE;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_fee_type_ci_status IN VARCHAR2 DEFAULT NULL,
    x_start_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_start_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_end_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_end_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_retro_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_retro_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_s_chg_method_type IN VARCHAR2 DEFAULT NULL,
    x_rul_sequence_number IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_initial_default_amount IN NUMBER DEFAULT NULL,
    x_acct_hier_id IN NUMBER DEFAULT NULL,
    x_rec_gl_ccid IN NUMBER DEFAULT NULL,
    x_rev_account_cd IN VARCHAR2 DEFAULT NULL,
    x_rec_account_cd IN VARCHAR2 DEFAULT NULL,
    x_ret_gl_ccid IN NUMBER DEFAULT NULL,
    x_ret_account_cd IN VARCHAR2 DEFAULT NULL,
    x_retention_level_code IN VARCHAR2 DEFAULT NULL,
    x_complete_ret_flag IN VARCHAR2 DEFAULT NULL,
    x_nonzero_billable_cp_flag IN VARCHAR2 DEFAULT NULL,
    x_scope_rul_sequence_num IN NUMBER DEFAULT NULL,
    x_elm_rng_order_name IN VARCHAR2 DEFAULT NULL,
    X_MAX_CHG_ELEMENTS IN NUMBER DEFAULT NULL
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  gurprsin      16-Aug-2005   Bug# 3392088 , Added a column max_chg_elements as part of CPF build.
  ||  gurprsin      18-Jun-2005   Bug# 3392088 , Added 2 new columns scope_rul_sequence_num and elm_rng_order_name.
  ||  svuppala    13-Apr-2005      Bug 4297359 Added new field NONZERO_BILLABLE_CP_FLAG in Fee Type Calendar Instances Table
  ||  agairola    07-Sep-2004      Enh 3316063: Retention Enhancements changes
  ||  pathipat        11-Feb-2003     Enh 2747325 - Locking Issues Build
  ||                                  Removed code for p_action = 'DELETE' and 'VALIDATE-DELETE'
  ||  vvutukur        23-Jul-2002     Bug#2425767.removed parameter x_payment_hierarchy_rank
  ||                                  and its references(from call to set_column_values).
  ----------------------------------------------------------------------------*/
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_fee_type,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_fee_type_ci_status,
      x_start_dt_alias,
      x_start_dai_sequence_number,
      x_end_dt_alias,
      x_end_dai_sequence_number,
      x_retro_dt_alias,
      x_retro_dai_sequence_number,
      x_s_chg_method_type,
      x_rul_sequence_number,
      x_org_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_initial_default_amount,
      x_acct_hier_id ,
      x_rec_gl_ccid ,
      x_rev_account_cd,
      x_rec_account_cd,
      x_ret_gl_ccid ,
      x_ret_account_cd,
      x_retention_level_code,
      x_complete_ret_flag,
      x_nonzero_billable_cp_flag,
      x_scope_rul_sequence_num,
      x_elm_rng_order_name,
      x_max_chg_elements
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
      IF (Get_PK_For_Validation (
            new_references.fee_type,
            new_references.fee_cal_type,
            new_references.fee_ci_sequence_number
            )) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF (Get_PK_For_Validation (
            new_references.fee_type,
            new_references.fee_cal_type,
            new_references.fee_ci_sequence_number
          )) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
    END IF;
  END Before_DML;


  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  gurprsin      16-Aug-2005   Bug# 3392088 , Added a column max_chg_elements as part of CPF build.
  ||  gurprsin      18-Jun-2005   Bug# 3392088 , Added 2 new columns scope_rul_sequence_num and elm_rng_order_name.
  ||  svuppala        13-Apr-2005  Bug 4297359 Added new field NONZERO_BILLABLE_CP_FLAG in Fee Type Calendar Instances Table
  ||  vvutukur        23-Jul-2002  Bug#2425767.Removed references to AfterStmtInsertUpdate4 procedure as this
  ||                               procedure is removed. Removed if conditions if p_action='INSERT'
  ||                               and p_action='UPDATE' as there is no code present in those conditions.
  ----------------------------------------------------------------------------*/
  BEGIN
    l_rowid := x_rowid;
    IF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowUpdate3 ( p_updating => TRUE );
    END IF;
  END After_DML;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE_CI_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_END_DT_ALIAS in VARCHAR2,
  X_END_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETRO_DT_ALIAS in VARCHAR2,
  X_RETRO_DAI_SEQUENCE_NUMBER in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_ORG_ID in NUMBER default NULL,
  X_MODE in VARCHAR2 default 'R',
  X_INITIAL_DEFAULT_AMOUNT in NUMBER DEFAULT NULL,
  x_acct_hier_id IN NUMBER DEFAULT NULL,
  x_rec_gl_ccid IN NUMBER DEFAULT NULL,
  x_rev_account_cd IN VARCHAR2 DEFAULT NULL,
  x_rec_account_cd IN VARCHAR2 DEFAULT NULL,
  x_ret_gl_ccid IN NUMBER DEFAULT NULL,
  x_ret_account_cd IN VARCHAR2 DEFAULT NULL,
  x_retention_level_code IN VARCHAR2 DEFAULT NULL,
  x_complete_ret_flag IN VARCHAR2 DEFAULT NULL,
  x_nonzero_billable_cp_flag IN VARCHAR2 DEFAULT NULL,
  X_SCOPE_RUL_SEQUENCE_NUM IN NUMBER DEFAULT NULL,
  X_ELM_RNG_ORDER_NAME IN VARCHAR2 DEFAULT NULL,
  X_MAX_CHG_ELEMENTS IN NUMBER DEFAULT NULL
  ) is
  /***************************************************************************
  agairola    07-Sep-2004      Enh 3316063: Retention Enhancements changes
  vvutukur   23-Jul-2002     Bug#2425767.removed parameter x_payment_hierarchy_rank and its references(from
                             call to before_dml and from insert statement).
  SBALIGA    13-feb-2002        Assigned igs_ge_gen_003.get_org_id to x_org_id
                           in call to bafore_dml as part of SWCR006 build.
  ********************************************************************************/
    cursor C is select ROWID from IGS_FI_F_TYP_CA_INST_ALL
      where FEE_TYPE = X_FEE_TYPE
      and FEE_CAL_TYPE = X_FEE_CAL_TYPE
      and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE = 'R') then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
    X_REQUEST_ID:=FND_GLOBAL.CONC_REQUEST_ID;
    X_PROGRAM_ID:=FND_GLOBAL.CONC_PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID:=FND_GLOBAL.PROG_APPL_ID;
    if (X_REQUEST_ID = -1 ) then
      X_REQUEST_ID:=NULL;
      X_PROGRAM_ID:=NULL;
      X_PROGRAM_APPLICATION_ID:=NULL;
      X_PROGRAM_UPDATE_DATE:=NULL;
    else
      X_PROGRAM_UPDATE_DATE:=SYSDATE;
    end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
Before_DML(
 p_action=>'INSERT',
 x_rowid=>X_ROWID,
 x_end_dai_sequence_number=>X_END_DAI_SEQUENCE_NUMBER,
 x_end_dt_alias=>X_END_DT_ALIAS,
 x_fee_cal_type=>X_FEE_CAL_TYPE,
 x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
 x_fee_type=>X_FEE_TYPE,
 x_fee_type_ci_status=>X_FEE_TYPE_CI_STATUS,
 x_retro_dai_sequence_number=>X_RETRO_DAI_SEQUENCE_NUMBER,
 x_retro_dt_alias=>X_RETRO_DT_ALIAS,
 x_rul_sequence_number=>X_RUL_SEQUENCE_NUMBER,
 x_s_chg_method_type=>X_S_CHG_METHOD_TYPE,
 x_start_dai_sequence_number=>X_START_DAI_SEQUENCE_NUMBER,
 x_start_dt_alias=>X_START_DT_ALIAS,
 x_org_id =>igs_ge_gen_003.get_org_id,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN,
 x_initial_default_amount=>X_INITIAL_DEFAULT_AMOUNT,
 x_acct_hier_id     => x_acct_hier_id,
 x_rec_gl_ccid      => x_rec_gl_ccid,
 x_rev_account_cd   => x_rev_account_cd,
 x_rec_account_cd   => x_rec_account_cd,
 x_ret_gl_ccid      => x_ret_gl_ccid,
 x_ret_account_cd   => x_ret_account_cd,
 x_retention_level_code => x_retention_level_code,
 x_complete_ret_flag  => x_complete_ret_flag,
 x_nonzero_billable_cp_flag => x_nonzero_billable_cp_flag,
 x_scope_rul_sequence_num        => x_scope_rul_sequence_num,
 x_elm_rng_order_name       => x_elm_rng_order_name,
 x_max_chg_elements         => x_max_chg_elements
);
  insert into IGS_FI_F_TYP_CA_INST_ALL (
    FEE_TYPE,
    FEE_CAL_TYPE,
    FEE_CI_SEQUENCE_NUMBER,
    FEE_TYPE_CI_STATUS,
    START_DT_ALIAS,
    START_DAI_SEQUENCE_NUMBER,
    END_DT_ALIAS,
    END_DAI_SEQUENCE_NUMBER,
    RETRO_DT_ALIAS,
    RETRO_DAI_SEQUENCE_NUMBER,
    S_CHG_METHOD_TYPE,
    RUL_SEQUENCE_NUMBER,
    ORG_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE,
    INITIAL_DEFAULT_AMOUNT,
    acct_hier_id,
    rec_gl_ccid ,
    rev_account_cd,
    rec_account_cd,
    ret_gl_ccid ,
    ret_account_cd,
    retention_level_code,
    complete_ret_flag,
    nonzero_billable_cp_flag,
    scope_rul_sequence_num,
    elm_rng_order_name,
    max_chg_elements
  ) values (
    NEW_REFERENCES.FEE_TYPE,
    NEW_REFERENCES.FEE_CAL_TYPE,
    NEW_REFERENCES.FEE_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.FEE_TYPE_CI_STATUS,
    NEW_REFERENCES.START_DT_ALIAS,
    NEW_REFERENCES.START_DAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.END_DT_ALIAS,
    NEW_REFERENCES.END_DAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.RETRO_DT_ALIAS,
    NEW_REFERENCES.RETRO_DAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.S_CHG_METHOD_TYPE,
    NEW_REFERENCES.RUL_SEQUENCE_NUMBER,
    NEW_REFERENCES.ORG_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE,
    NEW_REFERENCES.INITIAL_DEFAULT_AMOUNT,
    new_references.acct_hier_id ,
    new_references.rec_gl_ccid,
    new_references.rev_account_cd,
    new_references.rec_account_cd,
    new_references.ret_gl_ccid,
    new_references.ret_account_cd,
    new_references.retention_level_code,
    new_references.complete_ret_flag,
    new_references.nonzero_billable_cp_flag,
    new_references.scope_rul_sequence_num,
    new_references.elm_rng_order_name,
    new_references.max_chg_elements
  );
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
After_DML (
 p_action => 'INSERT',
 x_rowid => X_ROWID
);
end INSERT_ROW;
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE_CI_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_END_DT_ALIAS in VARCHAR2,
  X_END_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETRO_DT_ALIAS in VARCHAR2,
  X_RETRO_DAI_SEQUENCE_NUMBER in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_INITIAL_DEFAULT_AMOUNT in NUMBER DEFAULT NULL,
  x_acct_hier_id IN NUMBER DEFAULT NULL,
  x_rec_gl_ccid IN NUMBER DEFAULT NULL,
  x_rev_account_cd IN VARCHAR2 DEFAULT NULL,
  x_rec_account_cd IN VARCHAR2 DEFAULT NULL,
  x_ret_gl_ccid IN NUMBER DEFAULT NULL,
  x_ret_account_cd IN VARCHAR2 DEFAULT NULL,
  x_retention_level_code IN VARCHAR2 DEFAULT NULL,
  x_complete_ret_flag IN VARCHAR2 DEFAULT NULL,
  x_nonzero_billable_cp_flag IN VARCHAR2 DEFAULT NULL,
  X_SCOPE_RUL_SEQUENCE_NUM IN NUMBER DEFAULT NULL,
  X_ELM_RNG_ORDER_NAME IN VARCHAR2 DEFAULT NULL,
  X_MAX_CHG_ELEMENTS IN NUMBER DEFAULT NULL
) is
/*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || gurprsin    18-Jun-2005      Bug# 3392088 , Added 2 new columns scope_rul_sequence_num and elm_rng_order_name.
  || svuppala    13-Apr-2005      Bug 4297359 Added new field NONZERO_BILLABLE_CP_FLAG in Fee Type Calendar Instances Table
  || agairola    07-Sep-2004      Enh 3316063: Retention Enhancements changes
  ||  vvutukur        23-Jul-2002  Bug#2425767.removed parameter x_payment_hierarchy_rank
  ||                               and its references(from cursor c1 and if condition).
  ----------------------------------------------------------------------------*/
  cursor c1 is select
      FEE_TYPE_CI_STATUS,
      START_DT_ALIAS,
      START_DAI_SEQUENCE_NUMBER,
      END_DT_ALIAS,
      END_DAI_SEQUENCE_NUMBER,
      RETRO_DT_ALIAS,
      RETRO_DAI_SEQUENCE_NUMBER,
      S_CHG_METHOD_TYPE,
      RUL_SEQUENCE_NUMBER,
      INITIAL_DEFAULT_AMOUNT,
      acct_hier_id ,
      rec_gl_ccid,
      rev_account_cd,
      rec_account_cd ,
      ret_gl_ccid,
      ret_account_cd,
      retention_level_code,
      complete_ret_flag,
      nonzero_billable_cp_flag,
      scope_rul_sequence_num,
      elm_rng_order_name,
      max_chg_elements
    from IGS_FI_F_TYP_CA_INST_ALL
    where ROWID=X_ROWID
    for update nowait;
  tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;
  if ( (tlinfo.FEE_TYPE_CI_STATUS = X_FEE_TYPE_CI_STATUS)
      AND (tlinfo.START_DT_ALIAS = X_START_DT_ALIAS)
      AND (tlinfo.START_DAI_SEQUENCE_NUMBER = X_START_DAI_SEQUENCE_NUMBER)
      AND (tlinfo.END_DT_ALIAS = X_END_DT_ALIAS)
      AND (tlinfo.END_DAI_SEQUENCE_NUMBER = X_END_DAI_SEQUENCE_NUMBER)
      AND (tlinfo.COMPLETE_RET_FLAG = X_COMPLETE_RET_FLAG)
      AND (tlinfo.NONZERO_BILLABLE_CP_FLAG = X_NONZERO_BILLABLE_CP_FLAG)
      AND ((tlinfo.RETRO_DT_ALIAS = X_RETRO_DT_ALIAS)
           OR ((tlinfo.RETRO_DT_ALIAS is null)
               AND (X_RETRO_DT_ALIAS is null)))
      AND ((tlinfo.RETRO_DAI_SEQUENCE_NUMBER = X_RETRO_DAI_SEQUENCE_NUMBER)
           OR ((tlinfo.RETRO_DAI_SEQUENCE_NUMBER is null)
               AND (X_RETRO_DAI_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.S_CHG_METHOD_TYPE = X_S_CHG_METHOD_TYPE)
           OR ((tlinfo.S_CHG_METHOD_TYPE is null)
               AND (X_S_CHG_METHOD_TYPE is null)))
      AND ((tlinfo.RUL_SEQUENCE_NUMBER = X_RUL_SEQUENCE_NUMBER)
           OR ((tlinfo.RUL_SEQUENCE_NUMBER is null)
               AND (X_RUL_SEQUENCE_NUMBER is null)))
      --Removed code related to subaccount_id, as part of Bug 2175865

      AND ((tlinfo.INITIAL_DEFAULT_AMOUNT = X_INITIAL_DEFAULT_AMOUNT)
           OR ((tlinfo.INITIAL_DEFAULT_AMOUNT is null)
               AND (X_INITIAL_DEFAULT_AMOUNT is null)))
      AND ((tlinfo.acct_hier_id = X_acct_hier_id)
           OR ((tlinfo.acct_hier_id is null)
               AND (X_acct_hier_id is null)))
      AND ((tlinfo.rec_gl_ccid = X_rec_gl_ccid)
           OR ((tlinfo.rec_gl_ccid is null)
               AND (X_rec_gl_ccid is null)))
      AND ((tlinfo.rev_account_cd = X_rev_account_cd)
           OR ((tlinfo.rev_account_cd is null)
               AND (X_rev_account_cd is null)))
      AND ((tlinfo.rec_account_cd = X_rec_account_cd)
           OR ((tlinfo.rec_account_cd is null)
               AND (X_rec_account_cd is null)))
      AND ((tlinfo.ret_gl_ccid = X_ret_gl_ccid)
           OR ((tlinfo.ret_gl_ccid is null)
               AND (X_ret_gl_ccid is null)))
      AND ((tlinfo.ret_account_cd = X_ret_account_cd)
           OR ((tlinfo.ret_account_cd is null)
               AND (X_ret_account_cd is null)))
      AND ((tlinfo.retention_level_code = X_retention_level_code)
           OR ((tlinfo.retention_level_code is null)
               AND (X_retention_level_code is null)))

      AND ((tlinfo.scope_rul_sequence_num = X_scope_rul_sequence_num)
           OR ((tlinfo.scope_rul_sequence_num is null)
               AND (X_scope_rul_sequence_num is null)))
      AND ((tlinfo.elm_rng_order_name = X_elm_rng_order_name)
           OR ((tlinfo.elm_rng_order_name is null)
               AND (X_elm_rng_order_name is null)))
      AND ((tlinfo.max_chg_elements = X_max_chg_elements)
           OR ((tlinfo.max_chg_elements is null)
               AND (X_max_chg_elements is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE_CI_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_END_DT_ALIAS in VARCHAR2,
  X_END_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETRO_DT_ALIAS in VARCHAR2,
  X_RETRO_DAI_SEQUENCE_NUMBER in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_INITIAL_DEFAULT_AMOUNT in NUMBER DEFAULT NULL,
  x_acct_hier_id IN NUMBER DEFAULT NULL,
  x_rec_gl_ccid IN NUMBER DEFAULT NULL,
  x_rev_account_cd IN VARCHAR2 DEFAULT NULL,
  x_rec_account_cd IN VARCHAR2 DEFAULT NULL,
  x_ret_gl_ccid IN NUMBER DEFAULT NULL,
  x_ret_account_cd IN VARCHAR2 DEFAULT NULL,
  x_retention_level_code IN VARCHAR2 DEFAULT NULL,
  x_complete_ret_flag IN VARCHAR2 DEFAULT NULL,
  x_nonzero_billable_cp_flag IN VARCHAR2 DEFAULT NULL,
  X_SCOPE_RUL_SEQUENCE_NUM IN NUMBER DEFAULT NULL,
  X_ELM_RNG_ORDER_NAME IN VARCHAR2 DEFAULT NULL,
  X_MAX_CHG_ELEMENTS IN NUMBER DEFAULT NULL
  ) is
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || gurprsin    16-Aug-2005      Bug# 3392088 , Added a column max_chg_elements as part of CPF build.
  || gurprsin    18-Jun-2005      Bug# 3392088 , Added 2 new columns scope_rul_sequence_num and elm_rng_order_name.
  || svuppala    13-Apr-2005      Bug 4297359 Added new field NONZERO_BILLABLE_CP_FLAG in Fee Type Calendar Instances Table
  || agairola    07-Sep-2004      Enh 3316063: Retention Enhancements changes
  ||  vvutukur        23-Jul-2002  Bug#2425767.removed parameter x_payment_hierarchy_rank
  ||                               and its references(from call to before_dml and from update statement).
  ----------------------------------------------------------------------------*/
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE = 'R') then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
    X_REQUEST_ID:=FND_GLOBAL.CONC_REQUEST_ID;
    X_PROGRAM_ID:=FND_GLOBAL.CONC_PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID:=FND_GLOBAL.PROG_APPL_ID;
    if (X_REQUEST_ID = -1 ) then
      X_REQUEST_ID:=OLD_REFERENCES.REQUEST_ID;
      X_PROGRAM_ID:=OLD_REFERENCES.PROGRAM_ID;
      X_PROGRAM_APPLICATION_ID:=OLD_REFERENCES.PROGRAM_APPLICATION_ID;
      X_PROGRAM_UPDATE_DATE:=OLD_REFERENCES.PROGRAM_UPDATE_DATE;
    else
      X_PROGRAM_UPDATE_DATE:=SYSDATE;
    end if;
  else
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
Before_DML(
 p_action=>'UPDATE',
 x_rowid=>X_ROWID,
 x_end_dai_sequence_number=>X_END_DAI_SEQUENCE_NUMBER,
 x_end_dt_alias=>X_END_DT_ALIAS,
 x_fee_cal_type=>X_FEE_CAL_TYPE,
 x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
 x_fee_type=>X_FEE_TYPE,
 x_fee_type_ci_status=>X_FEE_TYPE_CI_STATUS,
 x_retro_dai_sequence_number=>X_RETRO_DAI_SEQUENCE_NUMBER,
 x_retro_dt_alias=>X_RETRO_DT_ALIAS,
 x_rul_sequence_number=>X_RUL_SEQUENCE_NUMBER,
 x_s_chg_method_type=>X_S_CHG_METHOD_TYPE,
 x_start_dai_sequence_number=>X_START_DAI_SEQUENCE_NUMBER,
 x_start_dt_alias=>X_START_DT_ALIAS,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN,
 x_initial_default_amount=>X_INITIAL_DEFAULT_AMOUNT,
 x_acct_hier_id     => x_acct_hier_id,
 x_rec_gl_ccid      => x_rec_gl_ccid,
 x_rev_account_cd   => x_rev_account_cd,
 x_rec_account_cd   => x_rec_account_cd,
 x_ret_gl_ccid      => x_ret_gl_ccid,
 x_ret_account_cd   => x_ret_account_cd,
 x_retention_level_code => x_retention_level_code,
 x_complete_ret_flag => x_complete_ret_flag,
 x_nonzero_billable_cp_flag => x_nonzero_billable_cp_flag,
 x_scope_rul_sequence_num       => x_scope_rul_sequence_num,
 x_elm_rng_order_name      => x_elm_rng_order_name,
 x_max_chg_elements        => x_max_chg_elements
);
  update IGS_FI_F_TYP_CA_INST_ALL set
    FEE_TYPE_CI_STATUS = NEW_REFERENCES.FEE_TYPE_CI_STATUS,
    START_DT_ALIAS = NEW_REFERENCES.START_DT_ALIAS,
    START_DAI_SEQUENCE_NUMBER = NEW_REFERENCES.START_DAI_SEQUENCE_NUMBER,
    END_DT_ALIAS = NEW_REFERENCES.END_DT_ALIAS,
    END_DAI_SEQUENCE_NUMBER = NEW_REFERENCES.END_DAI_SEQUENCE_NUMBER,
    RETRO_DT_ALIAS = NEW_REFERENCES.RETRO_DT_ALIAS,
    RETRO_DAI_SEQUENCE_NUMBER = NEW_REFERENCES.RETRO_DAI_SEQUENCE_NUMBER,
    S_CHG_METHOD_TYPE = NEW_REFERENCES.S_CHG_METHOD_TYPE,
    RUL_SEQUENCE_NUMBER = NEW_REFERENCES.RUL_SEQUENCE_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID=X_REQUEST_ID,
    PROGRAM_ID=X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID=X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE=X_PROGRAM_UPDATE_DATE,
    INITIAL_DEFAULT_AMOUNT=X_INITIAL_DEFAULT_AMOUNT,
    acct_hier_id     = new_references.acct_hier_id,
    rec_gl_ccid      = new_references.rec_gl_ccid,
    rev_account_cd   = new_references.rev_account_cd,
    rec_account_cd   = new_references.rec_account_cd,
    ret_gl_ccid      = new_references.ret_gl_ccid,
    ret_account_cd   = new_references.ret_account_cd,
    retention_level_code = new_references.retention_level_code,
    complete_ret_flag = new_references.complete_ret_flag,
    nonzero_billable_cp_flag = new_references.nonzero_billable_cp_flag,
    scope_rul_sequence_num        = new_references.scope_rul_sequence_num,
    elm_rng_order_name       = new_references.elm_rng_order_name,
    max_chg_elements         = new_references.max_chg_elements
  where ROWID=X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'UPDATE',
 x_rowid => X_ROWID
);
end UPDATE_ROW;
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE_CI_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_END_DT_ALIAS in VARCHAR2,
  X_END_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETRO_DT_ALIAS in VARCHAR2,
  X_RETRO_DAI_SEQUENCE_NUMBER in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_ORG_ID in NUMBER default NULL,
  X_MODE in VARCHAR2 default 'R',
  X_INITIAL_DEFAULT_AMOUNT in NUMBER DEFAULT NULL,
  x_acct_hier_id IN NUMBER DEFAULT NULL,
  x_rec_gl_ccid IN NUMBER DEFAULT NULL,
  x_rev_account_cd IN VARCHAR2 DEFAULT NULL,
  x_rec_account_cd IN VARCHAR2 DEFAULT NULL,
  x_ret_gl_ccid IN NUMBER DEFAULT NULL,
  x_ret_account_cd IN VARCHAR2 DEFAULT NULL,
  x_retention_level_code IN VARCHAR2 DEFAULT NULL,
  x_complete_ret_flag IN VARCHAR2 DEFAULT NULL,
  x_nonzero_billable_cp_flag IN VARCHAR2 DEFAULT NULL,
  X_SCOPE_RUL_SEQUENCE_NUM IN NUMBER DEFAULT NULL,
  X_ELM_RNG_ORDER_NAME IN VARCHAR2 DEFAULT NULL,
  X_MAX_CHG_ELEMENTS IN NUMBER DEFAULT NULL
  ) is
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || gurprsin    16-Aug-2005      Bug# 3392088 , Added a column max_chg_elements as part of CPF build.
  || gurprsin    18-Jun-2005      Bug# 3392088 , Added 2 new columns scope_rul_sequence_num and elm_rng_order_name.
  || svuppala    13-Apr-2005      Bug 4297359 Added new field NONZERO_BILLABLE_CP_FLAG in Fee Type Calendar Instances Table
  || agairola    07-Sep-2004      Enh 3316063: Retention Enhancements changes
  ||  vvutukur        23-Jul-2002  Bug#2425767.removed parameter x_payment_hierarchy_rank
  ||                               and its references(from calls to insert_row and update_row).
  ----------------------------------------------------------------------------*/
  cursor c1 is select rowid from IGS_FI_F_TYP_CA_INST_ALL
     where FEE_TYPE = X_FEE_TYPE
     and FEE_CAL_TYPE = X_FEE_CAL_TYPE
     and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_FEE_TYPE,
     X_FEE_CAL_TYPE,
     X_FEE_CI_SEQUENCE_NUMBER,
     X_FEE_TYPE_CI_STATUS,
     X_START_DT_ALIAS,
     X_START_DAI_SEQUENCE_NUMBER,
     X_END_DT_ALIAS,
     X_END_DAI_SEQUENCE_NUMBER,
     X_RETRO_DT_ALIAS,
     X_RETRO_DAI_SEQUENCE_NUMBER,
     X_S_CHG_METHOD_TYPE,
     X_RUL_SEQUENCE_NUMBER,
     X_ORG_ID,
     X_MODE,
     X_INITIAL_DEFAULT_AMOUNT,
     x_acct_hier_id ,
     x_rec_gl_ccid,
     x_rev_account_cd,
     x_rec_account_cd,
     x_ret_gl_ccid,
     x_ret_account_cd,
     x_retention_level_code,
     x_complete_ret_flag,
     x_nonzero_billable_cp_flag,
     x_scope_rul_sequence_num,
     x_elm_rng_order_name,
     x_max_chg_elements);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_FEE_TYPE,
   X_FEE_CAL_TYPE,
   X_FEE_CI_SEQUENCE_NUMBER,
   X_FEE_TYPE_CI_STATUS,
   X_START_DT_ALIAS,
   X_START_DAI_SEQUENCE_NUMBER,
   X_END_DT_ALIAS,
   X_END_DAI_SEQUENCE_NUMBER,
   X_RETRO_DT_ALIAS,
   X_RETRO_DAI_SEQUENCE_NUMBER,
   X_S_CHG_METHOD_TYPE,
   X_RUL_SEQUENCE_NUMBER,
   X_MODE,
   X_INITIAL_DEFAULT_AMOUNT,
   x_acct_hier_id ,
   x_rec_gl_ccid,
   x_rev_account_cd,
   x_rec_account_cd,
   x_ret_gl_ccid,
   x_ret_account_cd,
   x_retention_level_code,
   x_complete_ret_flag,
   x_nonzero_billable_cp_flag,
   X_SCOPE_RUL_SEQUENCE_NUM,
   X_ELM_RNG_ORDER_NAME,
   X_MAX_CHG_ELEMENTS);
end ADD_ROW;

END igs_fi_f_typ_ca_inst_pkg;

/
