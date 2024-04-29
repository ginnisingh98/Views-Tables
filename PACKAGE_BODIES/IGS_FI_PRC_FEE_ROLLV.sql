--------------------------------------------------------
--  DDL for Package Body IGS_FI_PRC_FEE_ROLLV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_PRC_FEE_ROLLV" AS
/* $Header: IGSFI10B.pls 120.20 2006/06/19 07:07:10 sapanigr ship $ */

/******************************************************************
Created By        :
Date Created By   :
Purpose           : This package is used for rolling over fee types from one calendar instance to
                    a future calendar instance. Package has been modulated into various functions
                    which will be checking all the validations inorder the fee rollover is carried on
                    successfully. Concurrent Manager is implicitly committing the trasanctions though
                    a COMMIT is not invoked explicitly. Data has to be set up for successful completion
                    of this process. Future Financial Year calendar instance, all Posting Account Codes
                    for the future financial calendar instance are mandatory. Calendar Instance Rollover
                    has to invoked prior to invoking fee rollover process.

Known limitations,
enhancements,
remarks            :
Change History
Who        When          What
sapanigr   14-Jun-2006   Bug 5148913. Functions have been modified to catch all unhandled exceptions and
                         log the respective error message at function level.
sapanigr   03-May-2006   Enh#3924836 Precision Issue. Modified finp_ins_roll_frtns and finp_ins_roll_tprs.
sapanigr   29-Mar-2006   Bug 4606670. Added validation in finp_ins_roll_far and finp_ins_roll_frtns to disallow process to
                         insert values for rates and schedules at FTCI level when they have already been defined at FCFL level and vice versa.
                         Also, added code in finp_prc_fee_rollvr, finp_ins_roll_ftci, finp_ins_roll_fcci and finp_ins_roll_fcfl
                         so that process ends in Warning if validation fails.
akandreg   02-Dec-2005   Bug 4747757. Added cursor cur_chk_version in function finp_ins_roll_uft to
                         handle the issue of rolling over a unit fee trigger when version is
                         not specified at FCFL level.
akandreg   10-Nov-2005   Bugs 4680440 , 4232201 - validation on Charge Method/Rule Seq Num at FCFL level
                         Before rolling over an FTCI, Charge Method/Rule Seq Num is validated whether source FTCI has a value.
                         This is done even for FCFL.
svuppala   09-Sep-2005   Bug 3822813 - The setting of variable l_b_fcfl_not_found to TRUE is removed
                                       in finp_ins_roll_ftci
gurprsin   29-Aug-2005   Bug 3392088, Added max_chg_elements column to the IGS_FI_F_TYP_CA_INST_PKG.Insert_Row
svuppala   22-Aug-2005   Enh 3392095, Added waiver_calc_flag column to the IGS_FI_F_CAT_FEE_LBL_Pkg.Insert_Row
gurprsin   28-Jun-2005   Bug# 3392088 Modified the rollover process to incorporate
                         sub element ranges and rates table rollover.
svuppala   03-Jun-2005   Enh# 3442712 - Modified TBH calls to table IGS_FI_FEE_AS_RATE to include
                         5 new Unit Level Attributes in insert_row method
gurprsin   03-Jun-2005   Enh# 3442712 - Modified TBH calls to table IGS_FI_FTCI_ACCTS to include 4 new Unit Level Attributes i.e. in insert_row method
svuppala   11-Mar-2004   Bug 4224379  - Changed the function 'finp_ins_roll_uft'.
                                        New cursor 'c_alt_cd' is created to get "Alternate code" from
                                        igs_ca_inst_all  and to send as a token in IGS_FI_ROLLOVER_UFT_ERROR.
                                        Added an EXCEPTION to log a message in case of rolling over failure.
agairola   13-Sep-2004   Bug 3316063 - Retention Enhancements Build
pathipat   12-Jul-2004   Bug 3759552 - Added code to roll over Fee Trigger groups, Unit Fee Triggers and Unit Set Fee Triggers
                                       Added functions for the same and corresponding calls in finp_ins_roll_fcfl().
                         Bug 3771151 - Removed references to log table IGS_GE_S_LOG_ENTRY and code to log - IGS_GE_GEN_003.GENP_INS_LOG_ENTRY
                         Bug 3771163 - Removed logging of message IGS_FI_FTCI_NO_REC_FOUND when FTCI has already been rolled over
uudayapr   16-oct-2003   Enh 3117341 Modified finp_ins_roll_ftci Procedure as a  part of audit and special fees build.
pathipat   11-Sep-2003   Enh 3108052 - Add Unit Sets to Rate Table
                         Modified finp_ins_roll_far() - TBH call igs_fi_fee_as_rate_pkg modified
pathipat   26-Jun-2003   Bug:2992967 - Table validation value set for segments
                         Modified finp_prc_fee_rollvr() and finpl_ins_roll_over_ftci_accts()
shtatiko   26-MAY-2003   Enh# 2831572, Added procedures log_parameters and finpl_ins_roll_over_ftci_accts.
                                       Modified procedures finp_ins_roll_ftci, finp_ins_roll_fcci and finp_prc_fee_rollvr.
shtatiko   25-APR-2003   Enh# 2831569, Modified finp_prc_fee_rollvr and finp_ins_roll_anc
pathipat   24-Jan-2003   Bug:2765199 - Modified finp_prc_fee_rollvr
                         Raised l_e_user_Exception instead of app_Exception.raise_exception
                         when validations fail and process has to error out, so that 'Procedure raised unhandled exception'
                         is avoided when a proper error message has been logged.
                         Removed exception sections in finpl_chk_fss,finp_ins_roll_fcci, finp_ins_roll_frtns, finp_ins_roll_fcfl
                         finp_ins_roll_far, finp_ins_roll_er, finp_ins_roll_ctft, finp_ins_roll_cgft, finp_ins_roll_cft,
                         finp_ins_roll_anc
                         Modified exception section in finp_ins_roll_ftci
npalanis    23-OCT-2002  Bug : 2608360
                         residency_status_id parameter is changed to  residency_status_cd
vvutukur 26-Aug-2002   Bug#2531390. Modifications done in functions FINP_INS_ROLL_FTCI,FINP_INS_ROLL_FCCI
                       and FINP_INS_ROLL_FCFL and removed DEFAULT in the package body.
vvutukur 23-Jul-2002   Bug#2425767.Modified functions finp_ins_roll_ftci,finp_ins_roll_fcfl to remove
                       references to payment_hierarchy_rank and modified function finp_ins_roll_frtns to
                       remove references to deduction_amount.
vchappid 10-Jun-2002   Bug#2400315, When the Fee Cat is passed as a parameter and for the source fee period if there are no fee libility
                       defined then the process should log a customized message
vchappid 29-May-2002   Bug#2372030, Function 'finp_ins_roll_anc' was returning FALSE when there are no records in the Ancillary Tables.
                       Should log the error message and should continue with the next rollover category or record.
                       Function 'finp_ins_roll_anc' should be invoked only if the system fee type is 'ANCILLARY'

                       Bug#2384909, Since Function 'finp_ins_roll_anc' was returning FALSE, next rollover category 'finp_ins_roll_revseg'
                       was not getting processed.

                       Bug# 2384909, Checking and Inserting the segments from the table igs_fi_f_type_accts is being done based on
                       fee_cal_type and fee_ci_sequence_number disregarding the fee type. When the same fee_cal_type and
                       fee_ci_sequence_number in different fee types then as many records are inserted, this function was returning FALSE
                       when the record is already exists, returning flase will terminate the process. Process should log the message and
                       should continue with next rollover categories

vchappid 25-Apr-2002   Bug#2329407, removed the reference to the fin_cal_type, fin_ci_sequence_number from the view IGS_FI_F_TYP_CA_INST
                       Reference to the Financial Calendar is removed as a part of SFCR005 Build. Removed the parameters account_cd, fin_cal_type
                       and fin_ci_sequence_number from the function call finp_val_ftci_rqrd
schodava 06-Feb-2002   Enh # 2187247
                       SFCR021 : FCI-LCI Relation
                       Removed the function for Charge Method Apportion rollover finp_ins_roll_cma
Sarakshi 15-Jan-2002   In function finp_ins_roll_ftci,removed the reference of subaccount_id from cursor c_ftci_fss
                       also from the insert_row of igs_fi_f_typ_ca_inst_pkg.Bug:2175865
sarakshi 19-Nov-2001   Added column ret_account_cd,ret_gl_ccid in the select list of cur c_ftci_fss also in
                       the call to the insert row of igs_fi_f_typ_ca_inst_pkg
                       as a prt of sfcr012, bug:2113459
schodava 3-Sep-2001    Bug : 1966961
                       Obsolete Items CCR
                       Removed references of the Account Code link to Financial Calendar
                       Also removed the function finp_ins_roll_fps and calls to it, as the payment schedules
                       functionality is replaced by the New Billing functionality.

Who      When          What
vchappid 17-Aug-2001   Ref: BugNo:1802900, A global X_ROWID has been defined in the package which is passed
                       into the INSERT_ROW TBH calls. This has been removed and variable l_rowid local to the
                       procedures is passed into the TBH calls. Explicit ROLLBACK is added in the outer most
                       procedure since Concurrent Manager is COMMITTING data though unhandled exception is
                       raised. All the calls to IGS_GE_GEN_003.GENP_INS_LOG_ENTRY are commented out, now all
                       comments are logged into the log file
sykrishn  29november2001 Removed the procedure finp_ins_roll_fe  and its calls - as part of obseletion in bug 2126091.

******************************************************************/

  l_v_token1_val                      VARCHAR2(255);
  token2_val                      VARCHAR2(255);

  -- Instead of raising app_Exception.raise_Exception, raised a user_exception
  -- to avoid the logging of 'Unhandled Exception' along with proper error message
  l_e_user_exception              EXCEPTION;

  g_v_gl_installed      igs_fi_control_all.rec_installed%TYPE;
  g_n_segment_num       fnd_id_flex_segments.segment_num%TYPE := NULL;
  cst_warning      CONSTANT        VARCHAR2(7) := 'WARNING';
  g_v_alternate_code    igs_ca_inst_all.alternate_code%TYPE := NULL;

  -- Routine to rollover fee type calendar instances between cal instances
  FUNCTION finp_ins_roll_ftci(
  p_fee_type IN IGS_FI_F_TYP_CA_INST.fee_type%TYPE ,
  p_fee_cat IN IGS_FI_FEE_CAT.fee_cat%TYPE ,
  p_source_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_source_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_dest_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_dest_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_fee_type_ci_status IN IGS_FI_F_TYP_CA_INST.fee_type_ci_status%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_message_warning OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Routine to rollover fee cat calendar instances between cal instances
  FUNCTION finp_ins_roll_fcci(
  p_fee_cat IN IGS_FI_F_CAT_CA_INST.fee_cat%TYPE ,
  p_source_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_source_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_dest_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_dest_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_fee_cat_ci_status IN IGS_FI_F_CAT_CA_INST.fee_cat_ci_status%TYPE ,
  p_fee_liability_status IN IGS_FI_F_CAT_FEE_LBL.fee_liability_status%TYPE ,
  p_fee_type IN IGS_FI_FEE_TYPE.fee_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_message_warning OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Routine to rollover fee retention schedules between cal instances
  FUNCTION finp_ins_roll_frtns(
  p_source_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_source_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_dest_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_dest_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_relation_type IN IGS_FI_FEE_RET_SCHD.s_relation_type%TYPE ,
  p_fee_type IN IGS_FI_FEE_RET_SCHD.fee_type%TYPE ,
  p_fee_cat IN IGS_FI_FEE_RET_SCHD.fee_cat%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Routine to rollover fee encumbrances between cal instances
 /* sykrishn  29november2001 Removed the procedure finp_ins_roll_fe - as part of obseletion in bug 2126091. */
  --
  -- Routine to rollover fee cat fee liabilities between cal instances
  FUNCTION finp_ins_roll_fcfl(
  p_fee_cat IN IGS_FI_F_CAT_FEE_LBL.fee_cat%TYPE ,
  p_source_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_source_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_dest_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_dest_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_fee_type IN IGS_FI_F_CAT_FEE_LBL.fee_type%TYPE ,
  p_fee_liability_status IN IGS_FI_F_CAT_FEE_LBL.fee_liability_status%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_message_warning OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Routine to rollover charge method apportionments between cal instances
  -- Enh # 2187247
  -- SFCR021 : FCI-LCI Relation
  -- Removed the function for Charge Method Apportion rollover

  -- Routine to rollover fee assessment rates between cal instances
  FUNCTION finp_ins_roll_far(
  p_fee_type IN IGS_FI_FEE_AS_RATE.fee_type%TYPE ,
  p_source_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_source_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_dest_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_dest_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_relation_type IN IGS_FI_FEE_AS_RATE.s_relation_type%TYPE ,
  p_fee_cat IN IGS_FI_FEE_AS_RATE.fee_cat%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Routine to rollover elements ranges between cal instances
  FUNCTION finp_ins_roll_er(
  p_fee_type IN IGS_FI_ELM_RANGE.fee_type%TYPE ,
  p_source_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_source_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_dest_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_dest_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_relation_type IN IGS_FI_ELM_RANGE.s_relation_type%TYPE ,
  p_fee_cat IN IGS_FI_ELM_RANGE.fee_cat%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

-- Function to roll over Fee Trigger Groups
FUNCTION finp_ins_roll_trg_grp( p_fee_cat                IN igs_fi_fee_trg_grp.fee_cat%TYPE ,
                                p_source_cal_type        IN igs_ca_inst.cal_type%TYPE ,
                                p_source_sequence_number IN igs_ca_inst.sequence_number%TYPE ,
                                p_dest_cal_type          IN igs_ca_inst.cal_type%TYPE ,
                                p_dest_sequence_number   IN igs_ca_inst.sequence_number%TYPE ,
                                p_fee_type               IN igs_fi_fee_trg_grp.fee_type%TYPE ,
                                p_message_name           OUT NOCOPY fnd_new_messages.message_name%TYPE )  RETURN BOOLEAN;

  --
  -- Routine to rollover IGS_PS_COURSE type fee triggers between cal instances
  FUNCTION finp_ins_roll_ctft(
  p_fee_cat IN IGS_PS_TYPE_FEE_TRG.fee_cat%TYPE ,
  p_source_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_source_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_dest_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_dest_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_fee_type IN IGS_PS_TYPE_FEE_TRG.fee_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Routine to rollover IGS_PS_COURSE group fee triggers between cal instances
  FUNCTION finp_ins_roll_cgft(
  p_fee_cat IN IGS_PS_GRP_FEE_TRG.fee_cat%TYPE ,
  p_source_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_source_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_dest_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_dest_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_fee_type IN IGS_PS_GRP_FEE_TRG.fee_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Routine to rollover IGS_PS_COURSE fee triggers between cal instances
  FUNCTION finp_ins_roll_cft(
  p_fee_cat IN IGS_PS_FEE_TRG.fee_cat%TYPE ,
  p_source_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_source_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_dest_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_dest_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_fee_type IN IGS_PS_FEE_TRG.fee_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

-- Function to roll over Unit Fee Triggers between Calendar Instances
FUNCTION finp_ins_roll_uft( p_fee_cat                IN igs_fi_unit_fee_trg.fee_cat%TYPE ,
                            p_source_cal_type        IN igs_ca_inst.cal_type%TYPE ,
                            p_source_sequence_number IN igs_ca_inst.sequence_number%TYPE ,
                            p_dest_cal_type          IN igs_ca_inst.cal_type%TYPE ,
                            p_dest_sequence_number   IN igs_ca_inst.sequence_number%TYPE ,
                            p_fee_type               IN igs_fi_unit_fee_trg.fee_type%TYPE ,
                            p_message_name           OUT NOCOPY fnd_new_messages.message_name%TYPE )  RETURN BOOLEAN;

-- Function to roll over Unit Set Fee Triggers between Calendar Instances
FUNCTION finp_ins_roll_usft( p_fee_cat                IN igs_en_unitsetfeetrg.fee_cat%TYPE ,
                            p_source_cal_type        IN igs_ca_inst.cal_type%TYPE ,
                            p_source_sequence_number IN igs_ca_inst.sequence_number%TYPE ,
                            p_dest_cal_type          IN igs_ca_inst.cal_type%TYPE ,
                            p_dest_sequence_number   IN igs_ca_inst.sequence_number%TYPE ,
                            p_fee_type               IN igs_en_unitsetfeetrg.fee_type%TYPE ,
                            p_message_name           OUT NOCOPY fnd_new_messages.message_name%TYPE )  RETURN BOOLEAN;

  --
  -- To rollover Ancillary related segments and the rate when the Fee Calendar Instance gets rolled over
  FUNCTION finp_ins_roll_anc(
  p_fee_type IN IGS_FI_ANC_RT_SGMNTS.fee_type%TYPE ,
  p_source_cal_type IN IGS_FI_ANC_RT_SGMNTS.fee_cal_type%TYPE ,
  p_source_ci_sequence_number IN IGS_FI_ANC_RT_SGMNTS.fee_ci_sequence_number%TYPE ,
  p_dest_cal_type IN IGS_FI_ANC_RT_SGMNTS.fee_cal_type%TYPE ,
  p_dest_ci_sequence_number IN IGS_FI_ANC_RT_SGMNTS.fee_ci_sequence_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--
--New function added by kkillams w.r.t. Student Finance Dld bug id: 1882122
--To rollover revenue segments  over for Fee Type Calendar Instances occurs.
--
  FUNCTION finp_ins_roll_revseg(
  p_fee_type                    IN  IGS_FI_F_TYPE_ACCTS_ALL.fee_type%TYPE,
  p_source_cal_type             IN  IGS_CA_INST.cal_type%TYPE,
  p_source_sequence_number      IN  IGS_CA_INST.sequence_number%TYPE,
  p_dest_cal_type               IN  IGS_CA_INST.cal_type%TYPE,
  p_dest_sequence_number        IN  IGS_CA_INST.sequence_number%TYPE,
  p_message_name                OUT NOCOPY VARCHAR2
  )
  RETURN BOOLEAN;

  -- To Rollover Account Table Attribute Records IF System Fee Type is OTHER or TUITION
  -- This has been added as part of Enh# 2831572
  FUNCTION finpl_ins_roll_over_ftci_accts (
    p_v_fee_type              IN  igs_fi_f_type_accts_all.fee_type%TYPE,
    p_v_source_cal_type         IN  igs_ca_inst.cal_type%TYPE,
    p_n_source_sequence_number  IN  igs_ca_inst.sequence_number%TYPE,
    p_v_dest_cal_type           IN  igs_ca_inst.cal_type%TYPE,
    p_n_dest_sequence_number    IN  igs_ca_inst.sequence_number%TYPE
  ) RETURN BOOLEAN;

-- Forward declaration of the finp_ins_roll_tprs procedure
  PROCEDURE finp_ins_roll_tprs(p_v_fee_type             igs_fi_f_typ_ca_inst.fee_type%TYPE,
                               p_v_source_cal_type      igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                               p_n_source_ci_seq_number igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                               p_v_dest_cal_type        igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                               p_n_dest_ci_seq_number   igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                               p_b_status               OUT NOCOPY BOOLEAN,
                               p_v_message_name         OUT NOCOPY VARCHAR2);

  --
  -- Call to  package routine allows the package to be pinned in memory.
  PROCEDURE genp_pin_package
  AS
  BEGIN
        NULL;
  END;

  -- Routine to log input parameters.
  PROCEDURE log_parameters ( p_v_parm_type IN VARCHAR2, p_v_parm_code IN VARCHAR2 )
  AS
  /*----------------------------------------------------------------------------
    Created By : shtatiko
    Created On : 14-MAY-2003 (Added as part of Enh# 2831572)

    Purpose : To log input parameters to the process

    Known limitations, enhancements or remarks :
    Change History :
    Who             When            What
    (reverse chronological order - newest change first)
  ----------------------------------------------------------------------------*/
  BEGIN
    fnd_file.put_line(fnd_file.log, p_v_parm_type || ' : ' || p_v_parm_code );
  END log_parameters;

  --
  -- Routine to process fee structure data rollover between cal instances
  PROCEDURE finp_prc_fee_rollvr(
        errbuf  OUT NOCOPY  VARCHAR2,
        retcode OUT NOCOPY  NUMBER,
        p_rollover_fee_type_ci_ind IN VARCHAR ,
        p_rollover_fee_cat_ci_ind IN VARCHAR ,
        P_Source_Calendar  IN VARCHAR2,
        P_Dest_Calendar IN VARCHAR2 ,
        p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
        p_fee_cat IN IGS_FI_F_CAT_CA_INST.fee_cat%TYPE ,
        p_fee_type_ci_status IN            IGS_FI_F_TYP_CA_INST_ALL.fee_type_ci_status%TYPE ,
        p_fee_cat_ci_status IN             IGS_FI_F_CAT_CA_INST.fee_cat_ci_status%TYPE ,
        p_fee_liability_status IN          IGS_FI_F_CAT_FEE_LBL_ALL.fee_liability_status%TYPE,
        p_org_id  NUMBER
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  sapanigr        29-Mar-2006     Bug 4606670. Process ends in warning if call to finp_ins_roll_ftci or
  ||                                  finp_ins_roll_fcci returns value cst_warning.
  ||  pathipat        26-Jun-2003     Bug:2992967 - Table validation value set for segments
  ||                                  Replaced call to igs_fi_gen_apint.get_flex_val with igs_fi_gen_apint.get_segment_num
  ||  shtatiko        26-MAY-2003     Enh# 2831572, Added code to fetch value of GL installed, chart of accounts
  ||                                  and Sequence Order for the GL_ACCOUNT_TYPE segment qualifier.
  ||  shtatiko        25-APR-2003     Enh# 2831569, Added check for Manage Accounts
  ||                                  System Option. If its value is NULL then this
  ||                                  process cannot be executed.
  ----------------------------------------------------------------------------*/
        gv_other_detail                    VARCHAR2(255);
        p_source_cal_type                  igs_ca_inst.cal_type%TYPE ;
        p_source_sequence_number           igs_ca_inst.sequence_number%TYPE ;
        p_dest_cal_type                    igs_ca_inst.cal_type%TYPE ;
        p_dest_sequence_number             igs_ca_inst.sequence_number%TYPE;
  BEGIN
        --Block for Parameter Validation/Splitting of Parameters

        igs_ge_gen_003.set_org_id(p_org_id);

        retcode:=0;
        BEGIN

        -- Added by Nshee on 26-Apr-2001 during Fee Rollover Testing to show the parameters in the log file generated by the concurrent request
          -- Modified the logging of parameters as part of Enh# 2831572.
          log_parameters ( igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'ROLL_FEE_TYPE'),
                           igs_fi_gen_gl.get_lkp_meaning('YES_NO', p_rollover_fee_type_ci_ind) );
          log_parameters ( igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'ROLL_FEE_CAT'),
                           igs_fi_gen_gl.get_lkp_meaning('YES_NO', p_rollover_fee_cat_ci_ind) );
          log_parameters ( igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'SRC_CAL_INST'),
                           p_source_calendar );
          log_parameters ( igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'DEST_CAL_INST'),
                           p_dest_calendar );
          log_parameters ( igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'FEE_TYPE'),
                           p_fee_type );
          log_parameters ( igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'FEE_CAT'),
                           p_fee_cat );
          log_parameters ( igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'FTCI_STATUS'),
                           p_fee_type_ci_status );
          log_parameters ( igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'FCAT_STATUS'),
                           p_fee_cat_ci_status );
          log_parameters ( igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'FCFL_STATUS'),
                           p_fee_liability_status );
          fnd_file.put_line ( fnd_file.LOG, ' ' );

        -- End of Addition by Nshee on 26-Apr-2001 during Fee Rollover testing to show the parameters in the log file generated by the concurrent request

                p_source_cal_type                :=     RTRIM(SUBSTR(p_source_calendar, 102, 10));
                p_source_sequence_number         :=     TO_NUMBER(RTRIM(SUBSTR(p_source_calendar, 113, 8)));
                p_dest_cal_type                  :=     RTRIM(SUBSTR(p_dest_calendar, 102, 10)); -- TO trim trailing spaces in the right
                p_dest_sequence_number           :=     TO_NUMBER(SUBSTR(p_dest_calendar, 113, 8));
        END;
        --End of Block for Parameter Validation/Splitting of Parameters
  DECLARE
        v_message_name                          VARCHAR2(30);
        v_message_warning                       VARCHAR2(30);
        v_cal_type                              IGS_CA_TYPE.cal_type%TYPE;
        v_prior_ci_sequence_number              IGS_CA_INST.prior_ci_sequence_number%TYPE;
        l_v_message_name     fnd_new_messages.message_name%TYPE;
        l_v_manage_accounts  igs_fi_control.manage_accounts%TYPE;

        CURSOR c_cat IS
                SELECT  cat.cal_type
                FROM    IGS_CA_TYPE     cat
                WHERE   cat.cal_type = p_source_cal_type;
        CURSOR c_ci IS
                SELECT  ci.prior_ci_sequence_number
                FROM    IGS_CA_INST     ci
                WHERE   ci.cal_type = p_dest_cal_type AND
                        ci.sequence_number = p_dest_sequence_number;
        FUNCTION finpl_chk_fss (
                p_fee_structure_status          IN      IGS_FI_FEE_STR_STAT.fee_structure_status%TYPE,
                p_message_name                  OUT NOCOPY      VARCHAR2)
        RETURN BOOLEAN AS
        BEGIN
        DECLARE
                v_s_fee_structure_status                IGS_FI_FEE_STR_STAT.s_fee_structure_status%TYPE;
                CURSOR c_fss (
                        cp_fee_structure_status         IGS_FI_FEE_STR_STAT.fee_structure_status%TYPE) IS
                        SELECT  fss.s_fee_structure_status
                        FROM    IGS_FI_FEE_STR_STAT     fss
                        WHERE   fss.fee_structure_status= cp_fee_structure_status;
        BEGIN
                OPEN c_fss(p_fee_structure_status);
                FETCH c_fss INTO v_s_fee_structure_status;
                IF (c_fss%NOTFOUND) THEN
                        CLOSE c_fss;
                        v_message_name := 'IGS_GE_INVALID_VALUE';
                        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String ('IGS', v_message_name));
                        p_message_name := v_message_name;
                        RETURN FALSE;
                ELSE
                        IF (v_s_fee_structure_status = 'INACTIVE') THEN
                                CLOSE c_fss;
                                v_message_name := 'IGS_FI_STATUS_PARAM_INACTIVE';
                                FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String ('IGS', v_message_name));
                                p_message_name := v_message_name;
                                RETURN FALSE;
                        END IF;
                END IF;
                RETURN TRUE;
        END;
        END finpl_chk_fss;
  BEGIN
        -- This function will control the rollover of all fee structure data underneath
        -- a nominated IGS_CA_INST to beneath another nominated IGS_CA_INST.

        -- Check the value of Manage Accounts System Option value.
        -- If its NULL then this process should error out by logging message.
        igs_fi_com_rec_interface.chk_manage_account ( p_v_manage_acc => l_v_manage_accounts,
                                                      p_v_message_name => l_v_message_name );
        IF l_v_manage_accounts IS NULL THEN
          fnd_message.set_name ( 'IGS', l_v_message_name );
          igs_ge_msg_stack.ADD;
          RAISE l_e_user_exception;
        END IF;

        -- Find whether Oracle General Ledger is installed or not.
        g_v_gl_installed := igs_fi_gen_005.finp_get_receivables_inst;

        -- If Oracle General Ledger is installed then fetch segment number
        -- for the Natural Account Segment
        IF ( g_v_gl_installed = 'Y' ) THEN
          igs_fi_gen_apint.get_segment_num(g_n_segment_num);
        END IF;

        -- 1. Validate the parameters to the routine
        -- Check rollover indicators
        IF (p_rollover_fee_type_ci_ind <> 'Y' AND  p_rollover_fee_cat_ci_ind <> 'Y') THEN
           -- p_rollover_fee_type_ci_ind is duplicatly checked,
           -- changed to p_rollover_fee_cat_ci_ind inline with CALLISTA Code

          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          RAISE l_e_user_exception;    -- Raised user_Exception to avoid error 'Unhandled exception' when proper error has been logged
        END IF;

        -- Check status parameters
        IF (p_rollover_fee_type_ci_ind = 'Y' AND p_fee_type_ci_status IS NOT NULL) THEN
          IF (finpl_chk_fss(p_fee_type_ci_status, v_message_name) = FALSE) THEN
            Fnd_Message.Set_Name ('IGS', v_message_name);
            IGS_GE_MSG_STACK.ADD;
          RAISE l_e_user_exception;
          END IF;
        END IF;

        IF (p_rollover_fee_cat_ci_ind = 'Y') THEN
          IF (p_fee_cat_ci_status IS NOT NULL) THEN
            IF (finpl_chk_fss(p_fee_cat_ci_status,v_message_name) = FALSE) THEN
              Fnd_Message.Set_Name ('IGS', v_message_name);
              IGS_GE_MSG_STACK.ADD;
              RAISE l_e_user_exception;
            END IF;
          END IF;

          IF (p_fee_liability_status IS NOT NULL) THEN
            IF (finpl_chk_fss(p_fee_liability_status,v_message_name) = FALSE) THEN
              Fnd_Message.Set_Name ('IGS', v_message_name);
              IGS_GE_MSG_STACK.ADD;
              RAISE l_e_user_exception;
            END IF;
          END IF;
        END IF;

        -- Can only transfer within the same IGS_CA_TYPE
        IF (p_source_cal_type <> p_dest_cal_type) THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_FI_ROLLOVER_FEE_STRUCTURE');
          IGS_GE_MSG_STACK.ADD;
          RAISE l_e_user_exception;
        END IF;

        -- Check the calendar type exists
        OPEN c_cat;
        FETCH c_cat INTO v_cal_type;
          IF (c_cat%NOTFOUND) THEN
            CLOSE c_cat;
            Fnd_Message.Set_Name ('IGS', 'IGS_GE_VAL_DOES_NOT_XS');
            IGS_GE_MSG_STACK.ADD;
            RAISE l_e_user_exception;
          END IF;
        CLOSE c_cat;

        -- Check destination calendar instance exists
        OPEN c_ci;
        FETCH c_ci INTO v_prior_ci_sequence_number;
          IF (c_ci%NOTFOUND) THEN
            CLOSE c_ci;
            Fnd_Message.Set_Name ('IGS', 'IGS_PS_DEST_CAL_INST_NOT_EXIS');
            IGS_GE_MSG_STACK.ADD;
            RAISE l_e_user_exception;
          END IF;
        CLOSE c_ci;
                -- Validate the destination calendar instance
        IF (IGS_FI_VAL_FCCI.finp_val_ci_fee(p_dest_cal_type,p_dest_sequence_number,v_message_name) = FALSE) THEN
          Fnd_Message.Set_Name ('IGS', v_message_name);
          IGS_GE_MSG_STACK.ADD;
          RAISE l_e_user_exception;
        END IF;

        -- Check destination calendar instance is a
        -- product of the source calendar instance
        IF (v_prior_ci_sequence_number IS NULL OR v_prior_ci_sequence_number <> p_source_sequence_number) THEN
          v_message_name := 'IGS_FI_DEST_CALINST_NOT_ROLLE';
          FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String ('IGS', v_message_name));
        END IF;

        --Get value of Alternate Code and put into Global variable.
        g_v_alternate_code := igs_ca_gen_001.calp_get_alt_cd(p_source_cal_type,
                                                             p_source_sequence_number);

        -- 2. Process the rollover
        IF (p_rollover_fee_type_ci_ind = 'Y') THEN
          -- Rollover fee type calendar instances
          IF (finp_ins_roll_ftci(p_fee_type,
                                 p_fee_cat,
                                 p_source_cal_type,
                                 p_source_sequence_number,
                                 p_dest_cal_type,
                                 p_dest_sequence_number,
                                 p_fee_type_ci_status,
                                 v_message_name,
                                 v_message_warning) = FALSE) THEN
             FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET_STRING('IGS',v_message_name));
             RETURN;
          ELSIF (v_message_warning = cst_warning) THEN
                RETCODE:=1;
          END IF;
        END IF;

        IF (p_rollover_fee_cat_ci_ind = 'Y') THEN
                -- Rollover fee category calendar instances
          IF (finp_ins_roll_fcci(p_fee_cat,
                                 p_source_cal_type,
                                 p_source_sequence_number,
                                 p_dest_cal_type,
                                 p_dest_sequence_number,
                                 p_fee_cat_ci_status,
                                 p_fee_liability_status,
                                 p_fee_type,
                                 v_message_name,
                                 v_message_warning) = FALSE) THEN
             FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET_STRING('IGS',v_message_name));
             RETURN;
          ELSIF (v_message_warning = cst_warning) THEN
                RETCODE:=1;
          END IF;
        END IF;
        fnd_file.put_line( fnd_file.LOG, RPAD('-', 79, '-') );

        --Added by Nshee on 26-Apr-2001 during Fee Rollvr Testing to put the rollover completed successfully message in the log file
        fnd_file.put_line( fnd_file.LOG, ' ' );
        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String ('IGS', 'IGS_FI_ROLLOVER_COMPL_SUCCESS'));
        --End of Addition by Nshee

  EXCEPTION

    -- When user expection is raised, do not raise 'Unhandled exception' error message
    -- since the appropriate error is already getting logged.
    WHEN l_e_user_exception THEN
                ROLLBACK;
                RETCODE:=2;
                IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

    WHEN OTHERS THEN
                -- concurrent manager is committing though an Un-Handled exception is raised
                -- explicitly rollbacking when the process raises Un-Handled exceptions
                -- This is incorporated as fix to Bug#1802900
                ROLLBACK;
                RETCODE:=2;
                ERRBUF:=FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION') || ':' || SQLERRM;
                fnd_file.put_line(fnd_file.log,SUBSTR(SQLERRM,1,300));
                IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
  END;
  END finp_prc_fee_rollvr;
  --
  -- Routine to rollover fee type calendar instances between cal instances
  FUNCTION finp_ins_roll_ftci(
  p_fee_type IN IGS_FI_F_TYP_CA_INST.fee_type%TYPE ,
  p_fee_cat IN IGS_FI_FEE_CAT.fee_cat%TYPE ,
  p_source_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_source_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_dest_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_dest_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_fee_type_ci_status IN IGS_FI_F_TYP_CA_INST.fee_type_ci_status%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_message_warning OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  sapanigr      14-Jun-2006      Bug 5148913. Unhandled exceptions caught and appropriate error message logged.
  ||  sapanigr        29-Mar-2006    Bug 4606670. Out parameter p_message_name assigned dummy value cst_warning
  ||                                 if calls to finp_ins_roll_frtns or finp_ins_roll_far returns this value.
  ||  akandreg      11-Nov-2005   Bugs 4680440 , 4232201 - validation on Charge Method/Rule Seq Num at FCFL level
  ||                              Before rolling over an FTCI, Charge Method/Rule Seq Num is validated whether source FTCI has a value.
  ||                              This is done even for FCFL.
  ||  (reverse chronological order - newest change first)
  ||  svuppala        09-Sep-2005     Bug 3822813 - The setting of variable l_b_fcfl_not_found to TRUE is removed
  ||  svuppala        13-Apr-2005     Bug 4297359 - ER REGISTRATION FEE ISSUE - ASSESSED TO STUDENTS WITH NO LOAD
  ||                                  Modifications to reflect the data model changes (NONZERO_BILLABLE_CP_FLAG) in
  ||                                  Fee Type Calendar Instances Table
  ||  agairola        13-Sep-2004     Bug 3316063 - Retention Enhancements Build
  ||  pathipat        12-Jul-2004     Bug 3771163 - Removed logging of message IGS_FI_FTCI_NO_REC_FOUND
  ||                                  when FTCI has already been rolled over
  ||  uudayapr        16-oct-2003     Enh #3117341 Added Audit and SPECIAL IN SYSTEM FEE TYPE for
  ||                                  Rollover FTCI Accounting Information As a part of  Audit and Special Fees Build.
  ||  shtatiko        26-MAY-2003     Enh# 2831572, finp_ins_roll_revseg procedure is called only IF GL is installed.
  ||                                  Added call to new procedure finpl_ins_roll_over_ftci_accts.
  ||  pathipat        24-Jan-2003     Bug: 2765199 - Modified exception section - removed when others then
  ||  vvutukur        26-Aug-2002  Bug#2531390.The comment in the code regarding the rollover of fee payment
  ||                               schedules is removed to avoid confusion.Removed DEFAULTing values of
  ||                               l_already_rolled,l_fcfl_exists_ind to avoid gscc warnings.
  ||  vvutukur        23-Jul-2002  Bug#2425767.Removed references to payment_hierarchy_rank(from cursor
  ||                               c_ftci_fss and from the call to IGS_FI_F_TYP_CA_INST_PKG.INSERT_ROW).
  ----------------------------------------------------------------------------*/
        gv_other_detail                 VARCHAR2(255);
        l_v_token1_val                 IGS_LOOKUP_VALUES.MEANING%TYPE;
  BEGIN
  DECLARE
        e_resource_busy                 EXCEPTION;
        PRAGMA  EXCEPTION_INIT(e_resource_busy, -54);
                cst_active      CONSTANT        IGS_FI_FEE_STR_STAT.s_fee_structure_status%TYPE :=
                                        'ACTIVE';
                cst_ftci        CONSTANT        IGS_FI_FEE_AS_RATE.s_relation_type%TYPE := 'FTCI';
        v_message_name                  VARCHAR2(30);
        v_message_warning               VARCHAR2(30);
        v_ftci_inserted_ind             BOOLEAN;
        v_ftci_exists_ind               BOOLEAN; -- used for performing rollover of retn schds. etc. IF accnt code is alrdy rolled over.
        v_process_next_ftci             BOOLEAN;
        v_insert_record                 BOOLEAN; -- used for diff bet ins/upd of rec for dest cal type. not reqd now as no upd takes place
        l_already_rolled                BOOLEAN := FALSE;
        l_fcfl_exists_ind               BOOLEAN := TRUE;
        v_fee_cat                       IGS_FI_F_CAT_FEE_LBL.fee_cat%TYPE;
        v_fee_type_ci_status            IGS_FI_F_TYP_CA_INST.fee_type_ci_status%TYPE;
        v_tmp_fee_type                  IGS_FI_F_TYP_CA_INST.fee_type%TYPE;
        v_closed_ind                    IGS_FI_FEE_TYPE.closed_ind%TYPE;
        v_sequence_number               IGS_CA_INST.sequence_number%TYPE;
        v_valid_dai                     BOOLEAN;
        v_dummy                         IGS_CA_DA_INST.dt_alias%TYPE;
        l_n_org_id                      IGS_FI_F_TYP_CA_INST.ORG_ID%type := igs_ge_gen_003.get_org_id;
        l_rowid                         VARCHAR2(25);
        l_b_records_found               BOOLEAN;


        CURSOR c_ftci_fss IS
                SELECT  ftci.fee_type,
                        ftci.fee_type_ci_status,
                        ftci.start_dt_alias,
                        ftci.start_dai_sequence_number,
                        ftci.end_dt_alias,
                        ftci.end_dai_sequence_number,
                        ftci.retro_dt_alias,
                        ftci.retro_dai_sequence_number,
                        ftci.s_chg_method_type,
                        ftci.rul_sequence_number,
                        ftci.initial_default_amount,
-- Added by kkillams ,w.r.t Student Finanace (Finance Accounting) DLD bug#1882122
                        ftci.acct_hier_id,
                        ftci.rec_gl_ccid,
                        ftci.rev_account_cd,
                        ftci.rec_account_cd,
--Added by Sarakshi,as a part of SFCR012 bug:2113459
                        ftci.ret_account_cd,
                        ftci.ret_gl_ccid,
                        ftci.retention_level_code,
                        ftci.complete_ret_flag,
--Added by svuppala,as a part of bug:4295379
                        ftci.nonzero_billable_cp_flag,
--Added by gurprsin,as a part of bug:3392088
                        ftci.scope_rul_sequence_num,
                        ftci.elm_rng_order_name,
                        ftci.max_chg_elements
                FROM    IGS_FI_F_TYP_CA_INST    ftci,
                        IGS_FI_FEE_STR_STAT     fss
                WHERE   (p_fee_type IS NULL OR
                        ftci.fee_type = p_fee_type) AND
                        ftci.fee_cal_type = p_source_cal_type AND
                        ftci.fee_ci_sequence_number = p_source_sequence_number AND
                        ftci.fee_type_ci_status = fss.fee_structure_status AND
                        fss.s_fee_structure_status = cst_active;
        CURSOR c_ft (
                cp_fee_type             IGS_FI_F_TYP_CA_INST.fee_type%TYPE) IS
                SELECT  ft.closed_ind, ft.s_fee_type
                FROM    IGS_FI_FEE_TYPE ft
                WHERE   ft.fee_type = cp_fee_type;

                l_s_fee_type igs_fi_fee_type.s_fee_type%TYPE;

  -- This cursor is changed as a part of SFCR005 (Enh #1966961)
        CURSOR c_ftci (
                cp_fee_type             IGS_FI_F_TYP_CA_INST.fee_type%TYPE) IS
                SELECT  'x'
                FROM    IGS_FI_F_TYP_CA_INST    ftci
                WHERE   ftci.fee_type = cp_fee_type AND
                        ftci.fee_cal_type = p_dest_cal_type AND
                        ftci.fee_ci_sequence_number = p_dest_sequence_number;
        CURSOR c_fcfl (
                cp_fee_type             IGS_FI_F_CAT_FEE_LBL.fee_type%TYPE) IS
                SELECT  fcfl.fee_cat
                FROM    IGS_FI_F_CAT_FEE_LBL    fcfl
                WHERE   fcfl.fee_cat = p_fee_cat AND
                        fcfl.fee_cal_type = p_source_cal_type AND
                        fcfl.fee_ci_sequence_number = p_source_sequence_number AND
                        fcfl.fee_type = cp_fee_type;

        CURSOR c_dai (
                        cp_dt_alias             IGS_CA_DA_INST.dt_alias%TYPE,
                        cp_sequence_number      IGS_CA_DA_INST.sequence_number%TYPE,
                        cp_cal_type             IGS_CA_DA_INST.cal_type%TYPE,
                        cp_ci_sequence_number   IGS_CA_DA_INST.ci_sequence_number%TYPE) IS
                        SELECT  DT_ALIAS
                        FROM    IGS_CA_DA_INST
                        WHERE   dt_alias  = cp_dt_alias AND
                                sequence_number = cp_sequence_number AND
                                cal_type = cp_cal_type AND
                                ci_sequence_number = cp_ci_sequence_number;

    l_b_status     BOOLEAN;
    l_v_retention_level_code     igs_fi_f_typ_ca_inst.retention_level_code%TYPE;
  BEGIN
        -- This function will roll all IGS_FI_F_TYP_CA_INST records underneath a
        -- nominated IGS_CA_INST to beneath another nominated IGS_CA_INST.
        -- It also controls the rollover of;
        -- * fee_refund_schedule
        -- * IGS_FI_FEE_RET_SCHD
        -- * IGS_FI_FEE_ENCMB
        -- * IGS_FI_CHG_MTH_APP
        -- * IGS_FI_FEE_AS_RATE
        -- * IGS_FI_ELM_RANGE
        -- The assumption is being made that the "destination" IGS_CA_INST
        -- is open and active - it is the responsibility of the calling routine
        -- to check for this.
        -- IGS_GE_NOTE: If some of the IGS_FI_F_TYP_CA_INST records already exist then
        -- these may be updated IF the assiciated IGS_FI_ACC link has not been
        -- previously established via the rollover, and it is now possible to do so.
        --------------------------------------------------------------------------
        p_message_name := Null;

        l_b_records_found := FALSE;

        -- 1. Process the fee type calendar instance records
        -- matching the source calendar instance
        FOR v_ftci_fss_rec IN c_ftci_fss LOOP
                v_process_next_ftci := FALSE;
                v_ftci_inserted_ind := FALSE;
                v_ftci_exists_ind := FALSE;
                v_insert_record := FALSE;
                l_fcfl_exists_ind := TRUE;
                l_b_records_found := TRUE;

                fnd_file.put_line( fnd_file.LOG, RPAD('-', 79, '-') );
                log_parameters ( igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'FEE_TYPE'), v_ftci_fss_rec.fee_type );

                -- Rollover of Fee Type Calendar Instance is prevented if
                -- the Charge Method has not been defined at Fee Type Calendar Instance level.
                IF v_ftci_fss_rec.s_chg_method_type IS NULL OR v_ftci_fss_rec.rul_sequence_number IS NULL THEN
                        FND_MESSAGE.SET_NAME('IGS', 'IGS_FI_NO_ROLL_CHG_METHOD');
                        FND_MESSAGE.SET_TOKEN('FTCI_FCFL',IGS_FI_GEN_GL.get_lkp_meaning('IGS_FI_LOCKBOX','FTCI'));
                        fnd_file.put_line(fnd_file.log,fnd_message.Get);
                        v_process_next_ftci := TRUE;
                END IF;
                -- Check the fee type IS a liablility of the fee category
                -- when fee category is specified
                IF p_fee_cat IS NOT NULL THEN
                        OPEN c_fcfl(v_ftci_fss_rec.fee_type);
                        FETCH c_fcfl INTO v_fee_cat;
                        IF (c_fcfl%NOTFOUND) THEN
                                -- process next IGS_FI_F_TYP_CA_INST
                                v_process_next_ftci := TRUE;
                                l_fcfl_exists_ind := FALSE;
                        END IF;
                        CLOSE c_fcfl;
                END IF;
                IF (v_process_next_ftci = FALSE) THEN
                        -- Check the fee type is open
                        OPEN c_ft(v_ftci_fss_rec.fee_type);
                        FETCH c_ft INTO v_closed_ind, l_s_fee_type;
                        CLOSE c_ft;
                        IF (v_closed_ind = 'Y') THEN
                                FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String ('IGS', 'IGS_FI_FEETYPE_CLOSED'));
                                -- process next IGS_FI_F_TYP_CA_INST
                                v_process_next_ftci := TRUE;
                        END IF;
                END IF;

                -- This is changed as a part of CCR SFCR005 (Enh # 1966961)
                IF (v_process_next_ftci = FALSE) THEN
                        -- Check for the existence of the IGS_FI_F_TYP_CA_INST
                        -- record under the destination calendar.
                        OPEN c_ftci(v_ftci_fss_rec.fee_type);
                        FETCH c_ftci INTO v_dummy;
                        IF (c_ftci%FOUND) THEN
                                CLOSE c_ftci;
                          l_already_rolled := TRUE;
                          FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String ('IGS','IGS_FI_FEETYPE_CALINST_ROLL'));

                                v_ftci_exists_ind := TRUE;
                                v_insert_record := FALSE;
                                -- when the FTCI was rolled over, it's IGS_FI_ACC
                                -- may not have been able to be carried through.
                                -- The rollover process will again attempt to
                                -- establish the IGS_FI_ACC link.
                                v_process_next_ftci := TRUE;
                        ELSE
                                CLOSE c_ftci;
                                v_insert_record := TRUE;
                        END IF;
                END IF;

                IF (v_process_next_ftci = FALSE  AND v_insert_record = TRUE ) THEN
                        v_valid_dai := TRUE;
                        -- Check for the existence of the start dai
                        -- record under the destination calendar
                        OPEN c_dai(     v_ftci_fss_rec.start_dt_alias,
                                        v_ftci_fss_rec.start_dai_sequence_number,
                                        p_dest_cal_type,
                                        p_dest_sequence_number);
                        FETCH c_dai INTO        v_dummy;
                        IF (c_dai%NOTFOUND) THEN
                                CLOSE c_dai;
                                v_valid_dai := FALSE;
                                l_v_token1_val := v_ftci_fss_rec.start_dt_alias ||','||TO_CHAR(v_ftci_fss_rec.start_dai_sequence_number);
                                FND_MESSAGE.SET_NAME('IGS', 'IGS_FI_F_TYP_SDTA_DOSNT_EXST');
                                FND_MESSAGE.SET_TOKEN('TOKEN1',l_v_token1_val);
                                FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.get);

                        ELSE
                                CLOSE c_dai;
                        END IF;
                        -- Check for the existence of the end dai
                        -- record under the destination calendar
                        OPEN c_dai(     v_ftci_fss_rec.end_dt_alias,
                                        v_ftci_fss_rec.end_dai_sequence_number,
                                        p_dest_cal_type,
                                        p_dest_sequence_number);
                        FETCH c_dai INTO        v_dummy;
                        IF (c_dai%NOTFOUND) THEN
                                CLOSE c_dai;
                                v_valid_dai := FALSE;

                                l_v_token1_val := v_ftci_fss_rec.end_dt_alias ||','||TO_CHAR(v_ftci_fss_rec.end_dai_sequence_number);
                                FND_MESSAGE.SET_NAME('IGS', 'IGS_FI_F_TYP_EDTA_DOSNT_EXST'); --new message
                                FND_MESSAGE.SET_TOKEN('TOKEN1',l_v_token1_val);
                                fnd_file.put_line(fnd_file.log,fnd_message.Get);
                        ELSE
                                CLOSE c_dai;
                        END IF;
                        IF v_ftci_fss_rec.retro_dt_alias IS NOT NULL THEN
                                -- Check for the existence of the retro dai
                                -- record under the destination calendar
                                OPEN c_dai(     v_ftci_fss_rec.retro_dt_alias,
                                                v_ftci_fss_rec.retro_dai_sequence_number,
                                                p_dest_cal_type,
                                                p_dest_sequence_number);
                                FETCH c_dai INTO        v_dummy;
                                IF (c_dai%NOTFOUND) THEN
                                        CLOSE c_dai;
                                        v_valid_dai := FALSE;
                                        l_v_token1_val := v_ftci_fss_rec.retro_dt_alias ||','||TO_CHAR(v_ftci_fss_rec.retro_dai_sequence_number);
                                        FND_MESSAGE.SET_NAME('IGS', 'IGS_FI_F_TYP_RDTA_DOSNT_EXST'); --new mwssage
                                        FND_MESSAGE.SET_TOKEN('TOKEN1',l_v_token1_val);
                                        fnd_file.put_line(fnd_file.log,fnd_message.Get);
                                ELSE
                                        CLOSE c_dai;
                                END IF;
                        END IF;
                        IF v_valid_dai = FALSE THEN
                                v_process_next_ftci := TRUE;
                        END IF;
                END IF;
                IF (v_process_next_ftci = FALSE  AND v_insert_record = TRUE ) THEN
                        IF (p_fee_type_ci_status IS NOT NULL) THEN
                                v_fee_type_ci_status := p_fee_type_ci_status;
                        ELSE
                                v_fee_type_ci_status := v_ftci_fss_rec.fee_type_ci_status;
                        END IF;
                        -- Validate the required data has been entered for
                        -- the Fee Type calendar status
                        IF IGS_FI_VAL_FTCI.finp_val_ftci_rqrd (
                                        p_dest_cal_type,
                                        p_dest_sequence_number,
                                        v_ftci_fss_rec.fee_type,
                                        NULL,
                                        NULL,
                                        v_ftci_fss_rec.s_chg_method_type,
                                        v_ftci_fss_rec.rul_sequence_number,
                                        v_fee_type_ci_status,
                                        v_message_name) = FALSE THEN

                                FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET_STRING('IGS',v_message_name));

                                v_process_next_ftci := TRUE;
                        ELSE
                                l_rowid := NULL;  -- initialise l_rowid to null before passing into the TBH
                                                  -- l_rowid with a value will throw Un-Handled Exception
                                IGS_FI_F_TYP_CA_INST_PKG.INSERT_ROW(
                                        X_ROWID=>l_rowid,
                                        X_FEE_TYPE=>v_ftci_fss_rec.fee_type,
                                        X_FEE_CAL_TYPE=>p_dest_cal_type,
                                        X_FEE_CI_SEQUENCE_NUMBER=>p_dest_sequence_number,
                                        X_FEE_TYPE_CI_STATUS=>v_fee_type_ci_status,
                                        X_START_DT_ALIAS=>v_ftci_fss_rec.start_dt_alias,
                                        X_START_DAI_SEQUENCE_NUMBER=>v_ftci_fss_rec.start_dai_sequence_number,
                                        X_END_DT_ALIAS=>v_ftci_fss_rec.end_dt_alias,
                                        X_END_DAI_SEQUENCE_NUMBER=>v_ftci_fss_rec.end_dai_sequence_number,
                                        X_RETRO_DT_ALIAS=>v_ftci_fss_rec.retro_dt_alias,
                                        X_RETRO_DAI_SEQUENCE_NUMBER=>v_ftci_fss_rec.retro_dai_sequence_number,
                                        X_S_CHG_METHOD_TYPE=>v_ftci_fss_rec.s_chg_method_type,
                                        X_RUL_SEQUENCE_NUMBER=>v_ftci_fss_rec.rul_sequence_number,
-- Added by kkillams ,w.r.t Student Finanace (Finance Accounting) DLD bug#1882122
                                        X_ACCT_HIER_ID   =>v_ftci_fss_rec.acct_hier_id,
                                        X_REC_GL_CCID    =>v_ftci_fss_rec.rec_gl_ccid,
                                        X_REV_ACCOUNT_CD =>v_ftci_fss_rec.rev_account_cd,
                                        X_REC_ACCOUNT_CD =>v_ftci_fss_rec.rec_account_cd,
-- Added by Nishikant , to include the following new field for enhancement bug#1851586
                                        X_INITIAL_DEFAULT_AMOUNT=>v_ftci_fss_rec.initial_default_amount,
                                        X_MODE=>'R',
                                        X_ORG_ID => l_n_org_id,
--Added by sarakshi, as a part of SFCR012, bug:2113459
                                        X_RET_ACCOUNT_CD =>v_ftci_fss_rec.ret_account_cd,
                                        X_RET_GL_CCID =>v_ftci_fss_rec.ret_gl_ccid,
                                        X_RETENTION_LEVEL_CODE => v_ftci_fss_rec.retention_level_code,
                                        X_COMPLETE_RET_FLAG => v_ftci_fss_rec.complete_ret_flag,
--Added by svuppala,as a part of bug:4295379
                                        X_NONZERO_BILLABLE_CP_FLAG  => v_ftci_fss_rec.nonzero_billable_cp_flag,
--Added by gurprsin,as a part of bug:3392088
                                        X_SCOPE_RUL_SEQUENCE_NUM    => v_ftci_fss_rec.scope_rul_sequence_num,
                                        X_ELM_RNG_ORDER_NAME        => v_ftci_fss_rec.elm_rng_order_name,
                                        X_MAX_CHG_ELEMENTS          => v_ftci_fss_rec.max_chg_elements
                                        );
                                v_ftci_inserted_ind := TRUE;
                                FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET_STRING('IGS','IGS_FI_FEETYPE_CALINST_ROLLED'));
                        END IF;
                END IF;

                IF (v_ftci_inserted_ind = TRUE  OR v_ftci_exists_ind = TRUE ) THEN
                        -- Identify the Retention Level from FTCI.
                        l_v_retention_level_code := NVL(v_ftci_fss_rec.retention_level_code,'FEE_PERIOD');

                        -- If the Retention Level is Fee Period, then call the existing Retention Schedules
                        -- Rollover Process
                        IF l_v_retention_level_code = 'FEE_PERIOD' THEN
                          IF (IGS_FI_PRC_FEE_ROLLV.finp_ins_roll_frtns(
                                                                   p_source_cal_type,
                                                                   p_source_sequence_number,
                                                                   p_dest_cal_type,
                                                                   p_dest_sequence_number,
                                                                   cst_ftci,
                                                                   v_ftci_fss_rec.fee_type,
                                                                   NULL,
                                                                   v_message_name) = FALSE) THEN
                                  p_message_name := v_message_name;
                                  RETURN FALSE;
                          ELSIF (v_message_name = cst_warning) THEN
                                  p_message_warning := v_message_name;
                          END IF;
                        -- If the Retention Level is Teaching Period, then call the new
                        -- procedure for Rollover Teaching Period Retention Schedule
                        ELSIF l_v_retention_level_code = 'TEACH_PERIOD' THEN
                          finp_ins_roll_tprs(p_v_fee_type             => v_ftci_fss_rec.fee_type,
                                             p_v_source_cal_type      => p_source_cal_type,
                                             p_n_source_ci_seq_number => p_source_sequence_number,
                                             p_v_dest_cal_type        => p_dest_cal_type,
                                             p_n_dest_ci_seq_number   => p_dest_sequence_number,
                                             p_b_status               => l_b_status,
                                             p_v_message_name         => v_message_name);
                          IF NOT l_b_status THEN
                            p_message_name := v_message_name;
                            RETURN FALSE;
                          END IF;
                        END IF;
                        -- rollover related fee encumbrances
                        --sykrishn  29november2001 Removed the procedure finp_ins_roll_fe - as part of obseletion in bug 2126091.
                        -- rollover related charge method apportionments
                        -- Enh # 2187247 : SFCR021 : FCI-LCI Relation
                        -- Removed the call to function for Charge Method Apportion rollover

                -- rollover related fee_assessment rates
                        IF (IGS_FI_PRC_FEE_ROLLV.finp_ins_roll_far(
                                                                v_ftci_fss_rec.fee_type,
                                                                p_source_cal_type,
                                                                p_source_sequence_number,
                                                                p_dest_cal_type,
                                                                p_dest_sequence_number,
                                                                cst_ftci,
                                                                NULL,
                                                                v_message_name) = FALSE) THEN
                                p_message_name := v_message_name;
                                RETURN FALSE;
                        ELSIF (v_message_name = cst_warning) THEN
                                p_message_warning := v_message_name;
                        END IF;
                        -- rollover related elements ranges
                        IF (IGS_FI_PRC_FEE_ROLLV.finp_ins_roll_er(
                                                                v_ftci_fss_rec.fee_type,
                                                                p_source_cal_type,
                                                                p_source_sequence_number,
                                                                p_dest_cal_type,
                                                                p_dest_sequence_number,
                                                                cst_ftci,
                                                                NULL,
                                                                v_message_name) = FALSE) THEN
                                p_message_name := v_message_name;
                                RETURN FALSE;
                        ELSIF (v_message_name = cst_warning) THEN
                                p_message_warning := v_message_name;
                        END IF;
                        -- rollover Ancillary related segments and rates, call made to new function defined during build
                        IF (l_s_fee_type = 'ANCILLARY') THEN
                          IF (IGS_FI_PRC_FEE_ROLLV.finp_ins_roll_anc(
                                                                v_ftci_fss_rec.fee_type,
                                                                p_source_cal_type,
                                                                p_source_sequence_number,
                                                                p_dest_cal_type,
                                                                p_dest_sequence_number,
                                                                v_message_name) = FALSE) THEN
                                p_message_name := v_message_name;
                                RETURN FALSE;
                          END IF;
                        END IF;
                        -- rollover of fee type revenue segments
                        -- This Revenue Segements Rollover should be done only IF Oracle General Ledger is installed
                        IF (g_v_gl_installed = 'Y' AND IGS_FI_PRC_FEE_ROLLV.finp_ins_roll_revseg(
                                                                v_ftci_fss_rec.fee_type,
                                                                p_source_cal_type,
                                                                p_source_sequence_number,
                                                                p_dest_cal_type,
                                                                p_dest_sequence_number,
                                                                v_message_name) = FALSE) THEN
                                p_message_name := v_message_name;
                                RETURN FALSE;
                        END IF;

                        -- Rollover FTCI Accounting Information IF the System Fee Type is OTHER or TUITION
                        --Enh #3117341 Added AUDIT and SPECIAL as valid values for System Fee Type as a part
                        --             AUDIT and SPECIAL FEES build.
                        --             and the finpl_ins_roll_over_ftci_accts should be invoked for
                        --             sysytem fee type of 'OTHER', 'TUTNFEE','AUDIT' and for fee type of
                        --             SPECIAL it should be invoked ONLY When GL IS NOT INSTALLED in the sysytem.
                        IF (l_s_fee_type IN ( 'OTHER', 'TUTNFEE','AUDIT','SPECIAL' ) ) THEN

                           IF l_s_fee_type = 'SPECIAL' THEN -- the rollover
                             IF (g_v_gl_installed <> 'Y') THEN
                                IF (finpl_ins_roll_over_ftci_accts(
                                v_ftci_fss_rec.fee_type,
                                p_source_cal_type,
                                p_source_sequence_number,
                                p_dest_cal_type,
                                p_dest_sequence_number) = FALSE ) THEN
                                     RETURN TRUE;  -- Returning TRUE because all the error messages, IF any are logged in the called procedure itself
                                END IF; --ending part of finpl_ins_roll_over_ftci_accts .
                             END IF;    --ending part of check for general ledger is installed.
                           ELSE  --Else part l_s_fee_type = 'SPECIAL'
                              IF (finpl_ins_roll_over_ftci_accts(
                                v_ftci_fss_rec.fee_type,
                                p_source_cal_type,
                                p_source_sequence_number,
                                p_dest_cal_type,
                                p_dest_sequence_number) = FALSE ) THEN
                                     RETURN TRUE;  -- Returning TRUE because all the error messages, IF any are logged in the called procedure itself
                              END IF;
                           END IF; --ending part of check for special fee type
                        END IF;
                END IF;
                -- To show a message when there are no records available in fee type calendar instance table to rollover
                IF  (v_insert_record = FALSE OR l_already_rolled) THEN
                  IF p_fee_cat IS NOT NULL THEN
                    IF NOT l_fcfl_exists_ind THEN
                      fnd_file.put_line( fnd_file.LOG, fnd_message.get_string ('IGS', 'IGS_FI_NO_FEE_LIB_FOUND') );
                    END IF;
                    -- Removed logging of message IGS_FI_FTCI_NO_REC_FOUND in case the FTCI have already been rolled over
                    -- as part of Bug 3038365
                  END IF;
                END IF;

        END LOOP;

        -- To show a message when there are no records available in fee type calendar instance table to rollover
        IF  ( l_b_records_found = FALSE) THEN
          p_message_name := 'IGS_FI_FTCI_NO_REC_FOUND';
          RETURN FALSE;
        END IF;

        RETURN TRUE;
  EXCEPTION
    WHEN e_resource_busy THEN
                v_message_name := 'IGS_FI_FEETYPE_CALINST_LOCKED';
                p_message_name := v_message_name;
                RETURN FALSE;

    WHEN OTHERS THEN
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
       fnd_message.set_name('IGS','IGS_FI_ROLLOVER_FTCI_ERROR');
       fnd_message.set_token('FEE_TYPE',p_fee_type);
       fnd_message.set_token('FEE_CAL_TYPE',p_source_cal_type);
       fnd_message.set_token('ALT_CODE',g_v_alternate_code);
       fnd_file.put_line (fnd_file.log, fnd_message.get);

  END;
  END finp_ins_roll_ftci;
  --
  -- Routine to rollover fee cat calendar instances between cal instances
  FUNCTION finp_ins_roll_fcci(
  p_fee_cat IN IGS_FI_F_CAT_CA_INST.fee_cat%TYPE ,
  p_source_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_source_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_dest_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_dest_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_fee_cat_ci_status IN IGS_FI_F_CAT_CA_INST.fee_cat_ci_status%TYPE ,
  p_fee_liability_status IN IGS_FI_F_CAT_FEE_LBL.fee_liability_status%TYPE ,
  p_fee_type IN IGS_FI_FEE_TYPE.fee_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_message_warning OUT NOCOPY VARCHAR2 )
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  sapanigr        14-Jun-2006    Bug 5148913. Unhandled exceptions caught and appropriate error message logged.
  ||  sapanigr        29-Mar-2006    Bug 4606670. Out parameter p_message_name assigned dummy value cst_warning
  ||                                 if calls to finp_ins_roll_frtns or finp_ins_roll_fcfl returns this value.
  ||  shtatiko        02-JUN-2003     Enh# 2831582, Logged all messages in context of a Fee Category.
  ||  pathipat        24-Jan-2003     Bug: 2765199 - Removed exception section
  ||  vvutukur        26-Aug-2002  Bug#2531390.The comment in the code regarding the rollover of fee payment
  ||                               schedules is removed to avoid confusion.
  ----------------------------------------------------------------------------*/
  RETURN BOOLEAN AS
        gv_other_detail                 VARCHAR2(255);
  BEGIN
  DECLARE
     cst_active CONSTANT        IGS_FI_FEE_STR_STAT.s_fee_structure_status%TYPE :='ACTIVE';
     cst_fcci   CONSTANT        IGS_FI_FEE_AS_RATE.s_relation_type%TYPE := 'FCCI';
        v_message_name                  VARCHAR2(30);
        v_message_warning               VARCHAR2(30);
        v_fcci_inserted_ind             BOOLEAN;
        v_fcci_exists_ind               BOOLEAN;
        v_process_next_fcci             BOOLEAN;
        v_fee_cat                       IGS_FI_F_CAT_CA_INST.fee_cat%TYPE;
        v_fee_type                      IGS_FI_F_CAT_FEE_LBL.fee_type%TYPE;
        v_fee_cat_ci_status             IGS_FI_F_CAT_CA_INST.fee_cat_ci_status%TYPE;
        v_valid_dai                     BOOLEAN;
        v_dummy                         IGS_CA_DA_INST.dt_alias%TYPE;
        l_rowid                         VARCHAR2(25);

        CURSOR c_fcci_fss IS
                SELECT  fcci.fee_cat,
                        fcci.fee_cat_ci_status,
                        fcci.start_dt_alias,
                        fcci.start_dai_sequence_number,
                        fcci.end_dt_alias,
                        fcci.end_dai_sequence_number,
                        fcci.retro_dt_alias,
                        fcci.retro_dai_sequence_number
                FROM    IGS_FI_F_CAT_CA_INST    fcci,
                        IGS_FI_FEE_STR_STAT     fss,
                        IGS_FI_FEE_CAT          fc
                WHERE   (p_fee_cat IS NULL OR
                        fcci.fee_cat = p_fee_cat) AND
                        fcci.fee_cal_type = p_source_cal_type AND
                        fcci.fee_ci_sequence_number = p_source_sequence_number AND
                        fcci.fee_cat_ci_status = fss.fee_structure_status AND
                                fss.s_fee_structure_status = cst_active AND
                        fc.fee_cat = fcci.fee_cat AND
                        fc.closed_ind = 'N';
        CURSOR c_fcci (
                cp_fee_cat              IGS_FI_F_CAT_CA_INST.fee_cat%TYPE) IS
                SELECT  fcci.fee_cat
                FROM    IGS_FI_F_CAT_CA_INST    fcci
                WHERE   fcci.fee_cat= cp_fee_cat AND
                        fcci.fee_cal_type = p_dest_cal_type AND
                        fcci.fee_ci_sequence_number = p_dest_sequence_number;
        CURSOR c_fcfl (
                cp_fee_cat              IGS_FI_F_CAT_FEE_LBL.fee_cat%TYPE) IS
                SELECT  fcfl.fee_type
                FROM    IGS_FI_F_CAT_FEE_LBL    fcfl
                WHERE   fcfl.fee_cat = cp_fee_cat AND
                        fcfl.fee_cal_type = p_source_cal_type AND
                        fcfl.fee_ci_sequence_number = p_source_sequence_number AND
                        fcfl.fee_type = p_fee_type;
        CURSOR c_dai (
                        cp_dt_alias             IGS_CA_DA_INST.dt_alias%TYPE,
                        cp_sequence_number      IGS_CA_DA_INST.sequence_number%TYPE,
                        cp_cal_type             IGS_CA_DA_INST.cal_type%TYPE,
                        cp_ci_sequence_number   IGS_CA_DA_INST.ci_sequence_number%TYPE) IS
                        SELECT  dt_alias
                        FROM    IGS_CA_DA_INST
                        WHERE   dt_alias = cp_dt_alias AND
                                sequence_number = cp_sequence_number AND
                                cal_type = cp_cal_type AND
                                ci_sequence_number = cp_ci_sequence_number;
  BEGIN
        -- This function will roll all IGS_FI_F_CAT_CA_INST records underneath a
        -- nominated IGS_CA_INST to beneath another nominated IGS_CA_INST.
        -- It also controls the rollover of
        -- * fee_refund_schedule
        -- * IGS_FI_FEE_RET_SCHD
        -- * IGS_FI_FEE_ENCMB
        -- * IGS_FI_F_CAT_FEE_LBL
        -- The assumption is being made that the "destination" IGS_CA_INST
        -- is open and active - it is the responsibility of the calling routine
        -- to check for this.
        -- IGS_GE_NOTE: If some of the IGS_FI_F_CAT_CA_INST records already exist then
        -- these will remain unaltered.
        --------------------------------------------------------------------------
        p_message_name := Null;
        -- 1. Process the fee cat calendar instance records
        -- matching the source calendar instance.
        FOR v_fcci_fss_rec IN c_fcci_fss LOOP
                v_fcci_inserted_ind := FALSE;
                v_fcci_exists_ind := FALSE;
                v_process_next_fcci := FALSE;

                fnd_file.put_line( fnd_file.LOG, RPAD('-', 79, '-') );
                log_parameters ( igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'FEE_CAT'), v_fcci_fss_rec.fee_cat );

                -- Check the fee type is a liablility of the fee category
                -- when fee type is specified
                IF p_fee_type IS NOT NULL THEN
                        OPEN c_fcfl(v_fcci_fss_rec.fee_cat);
                        FETCH c_fcfl INTO v_fee_type;
                        IF (c_fcfl%NOTFOUND) THEN
                                -- process next IGS_FI_F_CAT_CA_INST
                                v_process_next_fcci := TRUE;
                        END IF;
                        CLOSE c_fcfl;
                END IF;
                IF (v_process_next_fcci = FALSE) THEN
                        -- Check for the existence of the IGS_FI_F_CAT_CA_INST
                        -- record under the destination calendar
                        OPEN c_fcci(v_fcci_fss_rec.fee_cat);
                        FETCH c_fcci INTO v_fee_cat;
                        IF (c_fcci%FOUND) THEN
                                CLOSE c_fcci;
                                FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET_STRING('IGS','IGS_FI_FEECAT_CALINST_ROLL'));
                                v_fcci_exists_ind := TRUE;
                        ELSE
                                CLOSE c_fcci;
                                -- Check for the existence of the start dai
                                -- record under the destination calendar
                                OPEN c_dai(     v_fcci_fss_rec.start_dt_alias,
                                                v_fcci_fss_rec.start_dai_sequence_number,
                                                p_dest_cal_type,
                                                p_dest_sequence_number);
                                FETCH c_dai INTO        v_dummy;
                                IF (c_dai%NOTFOUND) THEN
                                        CLOSE c_dai;
                                        v_process_next_fcci := TRUE;
                                        l_v_token1_val := v_fcci_fss_rec.start_dt_alias ||','||TO_CHAR(v_fcci_fss_rec.start_dai_sequence_number);
                                        FND_MESSAGE.SET_NAME('IGS', 'IGS_FI_F_CAT_SDTA_DOSNT_EXST'); --new mwssage
                                        FND_MESSAGE.SET_TOKEN('TOKEN1',l_v_token1_val);
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get);
                                ELSE
                                        CLOSE c_dai;
                                END IF;
                                -- Check for the existence of the end dai
                                -- record under the destination calendar
                                OPEN c_dai(     v_fcci_fss_rec.end_dt_alias,
                                                v_fcci_fss_rec.end_dai_sequence_number,
                                                p_dest_cal_type,
                                                p_dest_sequence_number);
                                FETCH c_dai INTO        v_dummy;
                                IF (c_dai%NOTFOUND) THEN
                                        CLOSE c_dai;
                                        v_process_next_fcci := TRUE;
                                        l_v_token1_val := v_fcci_fss_rec.end_dt_alias ||','||TO_CHAR(v_fcci_fss_rec.end_dai_sequence_number);
                                        FND_MESSAGE.SET_NAME('IGS', 'IGS_FI_F_CAT_EDTA_DOSNT_EXST'); --new mwssage
                                        FND_MESSAGE.SET_TOKEN('TOKEN1',l_v_token1_val);
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get);
                                ELSE
                                        CLOSE c_dai;
                                END IF;
                                IF v_fcci_fss_rec.retro_dt_alias IS NOT NULL THEN
                                        -- Check for the existence of the retro dai
                                        -- record under the destination calendar
                                        OPEN c_dai(     v_fcci_fss_rec.retro_dt_alias,
                                                        v_fcci_fss_rec.retro_dai_sequence_number,
                                                        p_dest_cal_type,
                                                        p_dest_sequence_number);
                                        FETCH c_dai INTO        v_dummy;
                                        IF (c_dai%NOTFOUND) THEN
                                                CLOSE c_dai;
                                                v_process_next_fcci := TRUE;
                                                l_v_token1_val := v_fcci_fss_rec.retro_dt_alias ||','||TO_CHAR(v_fcci_fss_rec.retro_dai_sequence_number);
                                                FND_MESSAGE.SET_NAME('IGS', 'IGS_FI_F_CAT_RDTA_DOSNT_EXST'); --new mwssage
                                                FND_MESSAGE.SET_TOKEN('TOKEN1',l_v_token1_val);
                                                FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get);

                                        ELSE
                                                CLOSE c_dai;
                                        END IF;
                                END IF;
                        END IF;
                        IF (v_process_next_fcci = FALSE AND v_fcci_exists_ind = FALSE) THEN
                                IF (p_fee_cat_ci_status IS NOT NULL) THEN
                                        v_fee_cat_ci_status := p_fee_cat_ci_status;
                                ELSE
                                        v_fee_cat_ci_status := v_fcci_fss_rec.fee_cat_ci_status;
                                END IF;
                                IF IGS_FI_VAL_FCCI.finp_val_fss_closed (
                                        v_fee_cat_ci_status,
                                        v_message_name) = FALSE THEN
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET_STRING('IGS',v_message_name));
                                        v_process_next_fcci := TRUE;
                                END IF;
                                IF IGS_FI_VAL_FCCI.finp_val_fcci_active (
                                        v_fee_cat_ci_status,
                                        p_dest_cal_type,
                                        p_dest_sequence_number,
                                        v_message_name) = FALSE THEN

                                        FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET_STRING('IGS',v_message_name));
                                        v_process_next_fcci := TRUE;
                                END IF;
                        END IF;
                        IF (v_process_next_fcci = FALSE AND v_fcci_exists_ind = FALSE) THEN
                                l_rowid :=NULL;-- initialise l_rowid to null before passing into the TBH
                                               -- l_rowid with a value will throw Un-Handled Exception
                                IGS_FI_F_CAT_CA_INST_PKG.INSERT_ROW(
                                        X_ROWID=>l_rowid,
                                        X_FEE_CAT=>v_fcci_fss_rec.fee_cat,
                                        X_FEE_CAL_TYPE=>p_dest_cal_type,
                                        X_FEE_CI_SEQUENCE_NUMBER=>p_dest_sequence_number,
                                        X_FEE_CAT_CI_STATUS=>v_fee_cat_ci_status,
                                        X_START_DT_ALIAS=>v_fcci_fss_rec.start_dt_alias,
                                        X_START_DAI_SEQUENCE_NUMBER=>v_fcci_fss_rec.start_dai_sequence_number,
                                        X_END_DT_ALIAS=>v_fcci_fss_rec.end_dt_alias,
                                        X_END_DAI_SEQUENCE_NUMBER=>v_fcci_fss_rec.end_dai_sequence_number,
                                        X_RETRO_DT_ALIAS=>v_fcci_fss_rec.retro_dt_alias,
                                        X_RETRO_DAI_SEQUENCE_NUMBER=>v_fcci_fss_rec.retro_dai_sequence_number,
                                        X_MODE=>'R'
                                        );
                                v_fcci_inserted_ind := TRUE;
                                FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET_STRING('IGS','IGS_FI_FEECAT_CALINST_ROLLED'));
                        END IF;
                END IF;
                IF (v_fcci_inserted_ind = TRUE OR v_fcci_exists_ind = TRUE) THEN

                        -- rollover related fee retention schedule
                        IF (finp_ins_roll_frtns(
                                                p_source_cal_type,
                                                p_source_sequence_number,
                                                p_dest_cal_type,
                                                p_dest_sequence_number,
                                                cst_fcci,
                                                NULL,
                                                v_fcci_fss_rec.fee_cat,
                                                v_message_name) = FALSE) THEN
                                p_message_name := v_message_name;
                                RETURN FALSE;
                        ELSIF (v_message_name = cst_warning) THEN
                                p_message_warning := v_message_name;
                        END IF;
                        -- rollover related fee encumbrances
                        --sykrishn  29november2001 Removed the procedure finp_ins_roll_fe - as part of obseletion in bug 2126091.
                        -- rollover related fee category fee liabilities
                        IF (finp_ins_roll_fcfl(
                                                v_fcci_fss_rec.fee_cat,
                                                p_source_cal_type,
                                                p_source_sequence_number,
                                                p_dest_cal_type,
                                                p_dest_sequence_number,
                                                p_fee_type,
                                                p_fee_liability_status,
                                                v_message_name,
                                                v_message_warning) = FALSE) THEN
                                p_message_name := v_message_name;
                                RETURN FALSE;
                        ELSIF (v_message_warning = cst_warning) THEN
                                p_message_warning := v_message_warning;
                        END IF;
                END IF;
        END LOOP;
        RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
       fnd_message.set_name('IGS','IGS_FI_ROLLOVER_FCCI_ERROR');
       fnd_message.set_token('FEE_CAT',p_fee_cat);
       fnd_message.set_token('FEE_CAL_TYPE',p_source_cal_type);
       fnd_message.set_token('ALT_CODE',g_v_alternate_code);
       fnd_file.put_line (fnd_file.log, fnd_message.get);
  END;
  END finp_ins_roll_fcci;
  --

  -- Routine to rollover fee retention schedules between cal instances
  FUNCTION finp_ins_roll_frtns(
  p_source_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_source_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_dest_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_dest_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_relation_type IN IGS_FI_FEE_RET_SCHD.s_relation_type%TYPE ,
  p_fee_type IN IGS_FI_FEE_RET_SCHD.fee_type%TYPE ,
  p_fee_cat IN IGS_FI_FEE_RET_SCHD.fee_cat%TYPE ,
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
  ||  sapanigr       14-Jun-2006    Bug 5148913. Unhandled exceptions at insert row caught and appropriate error message logged.
  ||  sapanigr        03-May-2006   Enh#3924836 Precision Issue. Amount values being inserted into IGS_FI_FEE_RET_SCHD
  ||                                is now rounded off to currency precision
  ||  sapanigr        29-Mar-2006   Bug# 4606670 Added check finp_val_frtns_creat. This validates that
  ||                                when schedule defined at FTCI level, they cannot also be
  ||                                defined at FCFL level and vice-versa.
  ||  pathipat        24-Jan-2003     Bug: 2765199 - Removed exception section
  ||  vvutukur        24-Jul-2002  Bug#2425767.Removed deduction_amount from select of cursor c_frtns_source,
  ||                               removed x_deduction_amount parameter from call to IGS_FI_FEE_RET_SCHD_PKG.INSERT_ROW.
  ----------------------------------------------------------------------------*/
        gv_other_detail         VARCHAR2(255);
  BEGIN
        DECLARE
                v_record_inserted_ind           BOOLEAN;
                v_record_exists_ind             BOOLEAN;
                v_valid_insert                  BOOLEAN;
                v_message_name                  VARCHAR2(30);
                v_sequence_number               IGS_FI_FEE_RET_SCHD.sequence_number%TYPE;
                v_fee_type                      IGS_FI_FEE_RET_SCHD.fee_type%TYPE;
                v_fee_cat                       IGS_FI_FEE_RET_SCHD.fee_cat%TYPE;
                v_schedule_number               IGS_FI_FEE_RET_SCHD.schedule_number%TYPE;
                v_dummy                         IGS_CA_DA_INST.dt_alias%TYPE;
                l_rowid                         VARCHAR2(25);
                l_b_ftci_fcci_clash_ind         BOOLEAN := TRUE;

                CURSOR c_frtns_source IS
                        SELECT  frtns.sequence_number,
                                frtns.fee_type,
                                frtns.fee_cat,
                                frtns.schedule_number,
                                frtns.dt_alias,
                                frtns.dai_sequence_number,
                                frtns.retention_percentage,
                                frtns.retention_amount
                        FROM    IGS_FI_FEE_RET_SCHD     frtns
                        WHERE   frtns.fee_cal_type = p_source_cal_type AND
                                frtns.fee_ci_sequence_number = p_source_sequence_number AND
                                frtns.s_relation_type = p_relation_type AND
                                (frtns.fee_type = p_fee_type OR
                                p_fee_type IS NULL) AND
                                (frtns.fee_cat = p_fee_cat OR
                                p_fee_cat IS NULL);
                CURSOR c_frtns_dest (
                        cp_sequence_number      IGS_FI_FEE_RET_SCHD.sequence_number%TYPE) IS
                        SELECT  frtns.fee_type,
                                frtns.fee_cat,
                                frtns.schedule_number
                        FROM    IGS_FI_FEE_RET_SCHD     frtns
                        WHERE   frtns.fee_cal_type = p_dest_cal_type AND
                                frtns.fee_ci_sequence_number = p_dest_sequence_number AND
                                frtns.s_relation_type = p_relation_type AND
                                frtns.sequence_number = cp_sequence_number;
                CURSOR c_frtns_dest_u (
                        cp_fee_type             IGS_FI_FEE_RET_SCHD.fee_type%TYPE,
                        cp_fee_cat              IGS_FI_FEE_RET_SCHD.fee_cat%TYPE,
                        cp_schedule_number      IGS_FI_FEE_RET_SCHD.schedule_number%TYPE) IS
                        SELECT  frtns.sequence_number
                        FROM    IGS_FI_FEE_RET_SCHD     frtns
                        WHERE   frtns.fee_cal_type = p_dest_cal_type AND
                                frtns.fee_ci_sequence_number = p_dest_sequence_number AND
                                NVL(frtns.fee_type, 'NULL') = NVL(cp_fee_type, 'NULL') AND
                                NVL(frtns.fee_cat, 'NULL') = NVL(cp_fee_cat, 'NULL') AND
                                frtns.schedule_number = cp_schedule_number;
                CURSOR c_dai (
                        cp_dt_alias             IGS_CA_DA_INST.dt_alias%TYPE,
                        cp_sequence_number      IGS_CA_DA_INST.sequence_number%TYPE,
                        cp_cal_type             IGS_CA_DA_INST.cal_type%TYPE,
                        cp_ci_sequence_number   IGS_CA_DA_INST.ci_sequence_number%TYPE) IS
                        SELECT  dt_alias
                        FROM    IGS_CA_DA_INST
                        WHERE   dt_alias = cp_dt_alias AND
                                sequence_number = cp_sequence_number AND
                                cal_type = cp_cal_type AND
                                ci_sequence_number = cp_ci_sequence_number;
        BEGIN
                -- This function will roll all IGS_FI_FEE_RET_SCHD records underneath a
                -- nominated IGS_CA_INST to beneath another nominated IGS_CA_INST.
                -- The assumption is being made that the "destination" IGS_CA_INST
                -- is open and active - it is the responsibility of the calling routine to
                -- check for this.
                -- IGS_GE_NOTE: If some of the IGS_FI_FEE_RET_SCHD records already exist then
                -- these will remain unaltered.
                p_message_name := Null;
                -- 1. Process the fee retention schedule records matching the source calendar
                -- instance
                v_record_inserted_ind := FALSE;
                v_record_exists_ind := FALSE;

                  FOR v_frtns_source_rec IN c_frtns_source LOOP
                          v_valid_insert := TRUE;
                          -- Check for the existence of the IGS_FI_FEE_RET_SCHD
                          -- record under the destination calendar
                          OPEN c_frtns_dest(v_frtns_source_rec.sequence_number);
                          FETCH c_frtns_dest INTO v_fee_type,
                                                  v_fee_cat,
                                                  v_schedule_number;
                          IF (c_frtns_dest%FOUND) THEN
                                  CLOSE c_frtns_dest;
                                  IF (NVL(v_frtns_source_rec.fee_type, 'NULL') = NVL(v_fee_type, 'NULL') AND
                                          NVL(v_frtns_source_rec.fee_cat, 'NULL') = NVL(v_fee_cat, 'NULL')) THEN
                                          v_record_exists_ind := TRUE;
                                  ELSE
                                      FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET_STRING('IGS','IGS_FI_FEE_RETN_SCH_CLASHES'));
                                  END IF;
                          ELSE
                                  CLOSE c_frtns_dest;
                                  -- check the new schedule will be unique
                                  OPEN c_frtns_dest_u(    v_frtns_source_rec.fee_type,
                                                          v_frtns_source_rec.fee_cat,
                                                          v_frtns_source_rec.schedule_number);
                                  FETCH c_frtns_dest_u INTO v_sequence_number;
                                  IF (c_frtns_dest_u%FOUND) THEN
                                          CLOSE c_frtns_dest_u;
                                          v_valid_insert := FALSE;
                                          FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET_STRING('IGS','IGS_FI_FEE_RETN_SCH_CLASHES'));

                                  ELSE
                                          CLOSE c_frtns_dest_u;
                                          -- Check for the existence of the IGS_CA_DA_INST
                                          -- record under the destination calendar
                                          OPEN c_dai(     v_frtns_source_rec.dt_alias,
                                                          v_frtns_source_rec.dai_sequence_number,
                                                          p_dest_cal_type,
                                                          p_dest_sequence_number);
                                          FETCH c_dai INTO        v_dummy;
                                          IF (c_dai%NOTFOUND) THEN
                                                  CLOSE c_dai;
                                                  v_valid_insert := FALSE;

                                                  l_v_token1_val := v_frtns_source_rec.dt_alias ||','||TO_CHAR(v_frtns_source_rec.dai_sequence_number);
                                                  token2_val := ' RELATION_TYPE:' || p_relation_type ||
                                                                ', SEQUENCE_NUMBER:' || TO_CHAR(v_frtns_source_rec.sequence_number)||
                                                                ', SCHEDULE_NUMBER:' || TO_CHAR(v_frtns_source_rec.schedule_number);
                                                  FND_MESSAGE.SET_NAME('IGS', 'IGS_FI_F_R_SCH_DTA_DOSNT_EXST'); --new mwssage
                                                  FND_MESSAGE.SET_TOKEN('TOKEN1',l_v_token1_val);
                                                  FND_MESSAGE.SET_TOKEN('TOKEN2',token2_val);
                                                  FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);
                                          ELSE
                                                  CLOSE c_dai;
                                          END IF;
                                  END IF;
                                  IF v_valid_insert THEN
                                    BEGIN
                                      -- When schedule to be defined at FTCI level, proceed only if not
                                      -- defined at FCFL level and vice-versa.
                                      IF  (l_b_ftci_fcci_clash_ind) THEN
                                        IF IGS_FI_VAL_FRTNS.finp_val_frtns_creat(
                                                      p_fee_type,
                                                      p_dest_cal_type,
                                                      p_dest_sequence_number,
                                                      p_relation_type,
                                                      v_message_name) THEN
                                          l_rowid := NULL;-- initialise l_rowid to null before passing into the TBH
                                                          -- l_rowid with a value will throw Un-Handled Exception
                                                          -- Call to igs_fi_gen_gl.get_formatted_amount formats ret_amount by rounding off to currency precision
                                          IGS_FI_FEE_RET_SCHD_PKG.INSERT_ROW(
                                                  X_ROWID=>l_rowid,
                                                  X_FEE_CAL_TYPE=>p_dest_cal_type,
                                                  X_SEQUENCE_NUMBER=>v_frtns_source_rec.sequence_number,
                                                  X_FEE_CI_SEQUENCE_NUMBER=>p_dest_sequence_number,
                                                  X_S_RELATION_TYPE=>p_relation_type,
                                                  X_FEE_CAT=>v_frtns_source_rec.fee_cat,
                                                  X_FEE_TYPE=>v_frtns_source_rec.fee_type,
                                                  X_SCHEDULE_NUMBER=>v_frtns_source_rec.schedule_number,
                                                  X_DT_ALIAS=>v_frtns_source_rec.dt_alias,
                                                  X_DAI_SEQUENCE_NUMBER=>v_frtns_source_rec.dai_sequence_number,
                                                  X_RETENTION_PERCENTAGE=>v_frtns_source_rec.retention_percentage,
                                                  X_RETENTION_AMOUNT=>igs_fi_gen_gl.get_formatted_amount(v_frtns_source_rec.retention_amount),
                                                  X_MODE=>'R'
                                                  );
                                          v_record_inserted_ind := TRUE;
                                        ELSE
                                              IF (v_message_name= 'IGS_FI_FEE_RETN_SCH_FEECAT') THEN
                                                        fnd_message.set_name('IGS', 'IGS_FI_FRETS_FTCI_FCFL_EXIST');
                                                        fnd_message.set_token('SOURCE', igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FCFL'));
                                                        fnd_message.set_token('DESTINATION', igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FTCI'));
                                                        fnd_file.put_line(fnd_file.log, fnd_message.get);
                                              ELSIF (v_message_name= 'IGS_FI_FEE_RETN_SCH_FEETYPE') THEN
                                                        fnd_message.set_name('IGS', 'IGS_FI_FRETS_FTCI_FCFL_EXIST');
                                                        fnd_message.set_token('SOURCE', igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FTCI'));
                                                        fnd_message.set_token('DESTINATION', igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FCFL'));
                                                        fnd_file.put_line(fnd_file.log, fnd_message.get);
                                              END IF;
                                              p_message_name := cst_warning;
                                              l_b_ftci_fcci_clash_ind := FALSE;
                                        END IF;
                                      END IF;
                                    EXCEPTION
                                       WHEN OTHERS THEN
                                         IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
                                          fnd_message.set_name('IGS','IGS_FI_ROLLOVER_FRTNS_ERROR');
                                          fnd_message.set_token('FEE_CAT',p_fee_cat);
                                          fnd_message.set_token('FEE_TYPE',p_fee_type);
                                          fnd_message.set_token('FEE_CAL_TYPE',p_source_cal_type);
                                          fnd_message.set_token('ALT_CODE',g_v_alternate_code);
                                          fnd_message.set_token('DT_ALIAS',v_frtns_source_rec.dt_alias);
                                          fnd_file.put_line (fnd_file.log, fnd_message.get);
                                    END;
                                  END IF;
                          END IF;
                  END LOOP;
                  -- 2. Check IF records rolled over
                  IF (v_record_exists_ind = TRUE) THEN
                          FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET_STRING('IGS','IGS_FI_FEE_RETN_SCH_ROLLED'));
                  END IF;
                  IF (v_record_inserted_ind = TRUE) THEN
                          FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET_STRING('IGS','IGS_FI_FEERET_SCH_ROLLED'));
                  END IF;
                RETURN TRUE;
        END;


  END finp_ins_roll_frtns;
  --
  -- Routine to rollover fee encumbrances between cal instances
--sykrishn  29november2001 Removed the procedure finp_ins_roll_fe - as part of obseletion in bug 2126091.
  --
  -- Routine to rollover fee cat fee liabilities between cal instances
  FUNCTION finp_ins_roll_fcfl(
  p_fee_cat IN IGS_FI_F_CAT_FEE_LBL.fee_cat%TYPE ,
  p_source_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_source_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_dest_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_dest_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_fee_type IN IGS_FI_F_CAT_FEE_LBL.fee_type%TYPE ,
  p_fee_liability_status IN IGS_FI_F_CAT_FEE_LBL.fee_liability_status%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_message_warning OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  sapanigr        14-Jun-2006    Bug 5148913. Unhandled exceptions at insert row caught and appropriate error message logged.
  ||  sapanigr        29-Mar-2006    Bug 4606670. Out parameter p_message_name assigned dummy value cst_warning
  ||                                 if calls to finp_ins_roll_frtns or finp_ins_roll_far returns this value.
  ||  akandreg        10-Nov-2005    Bugs 4680440 , 4232201 - Validation on Charge Method/Rule Seq Num at FCFL level
  ||                                 Before rolling over an FCFL, validate whether Charge Method/Rule Seq Num has a value at source.
  ||  svuppala        22-Aug-2005    Enh 3392095, Added waiver_calc_flag column to the IGS_FI_F_CAT_FEE_LBL_Pkg.Insert_Row
  ||                                 Modified cursor c_fcfl_fss to get waiver_calc_flag
  ||  pathipat        12-Jul-2004    Bug 3759552 - Added code to roll over Fee Trig Groups, Unit Triggers
  ||                                 and Unit Set Triggers.
  ||  pathipat        24-Jan-2003    Bug: 2765199 - Removed exception section
  ||  vvutukur        26-Aug-2002  Bug#2531390.The comment in the code regarding the rollover of fee payment
  ||                               schedules is removed to avoid confusion.
  ||  vvutukur        23-Jul-2002  Bug#2425767.Removed references to payment_hierarchy_rank(from cursor
  ||                               c_fcfl_fss and from the call to IGS_FI_F_CAT_FEE_LBL_PKG.INSERT_ROW).
  ----------------------------------------------------------------------------*/
        gv_other_detail                 VARCHAR2(255);
        l_v_token1_val                 IGS_LOOKUP_VALUES.MEANING%TYPE;
  BEGIN
  DECLARE
        cst_active      CONSTANT        IGS_FI_FEE_STR_STAT.s_fee_structure_status%TYPE :=
                                        'ACTIVE';
        cst_fcfl        CONSTANT        IGS_FI_FEE_AS_RATE.s_relation_type%TYPE := 'FCFL';
        v_message_name                  VARCHAR2(30);
        v_message_warning               VARCHAR2(30);
        v_fcfl_inserted_ind             BOOLEAN;
        v_fcfl_exists_ind               BOOLEAN;
        v_fee_type                      IGS_FI_FEE_TYPE.fee_type%TYPE;
        v_fee_liability_status          IGS_FI_F_CAT_FEE_LBL.fee_liability_status%TYPE;
        v_next_fcfl                     BOOLEAN;
        v_valid_dai                     BOOLEAN;
        v_dummy                         IGS_CA_DA_INST.dt_alias%TYPE;
        l_n_org_id                      IGS_FI_F_CAT_FEE_LBL.ORG_ID%type := igs_ge_gen_003.get_org_id;
        l_rowid                         VARCHAR2(25);
        CURSOR c_fcfl_fss IS
                SELECT  fcfl.fee_type,
                        fcfl.fee_liability_status,
                        fcfl.start_dt_alias,
                        fcfl.start_dai_sequence_number,
                        fcfl.s_chg_method_type,
                        fcfl.rul_sequence_number,
                        fcfl.fee_cat,
                        fcfl.waiver_calc_flag
                FROM    IGS_FI_F_CAT_FEE_LBL            fcfl,
                        IGS_FI_FEE_STR_STAT     fss
                WHERE   fcfl.fee_cat = p_fee_cat AND
                        fcfl.fee_cal_type = p_source_cal_type AND
                        fcfl.fee_ci_sequence_number = p_source_sequence_number AND
                        (fcfl.fee_type = p_fee_type OR
                        p_fee_type IS NULL) AND
                        fcfl.fee_liability_status = fss.fee_structure_status AND
                        fss.s_fee_structure_status = cst_active;
        CURSOR c_fcfl (
                cp_fee_type     IGS_FI_F_CAT_FEE_LBL.fee_type%TYPE) IS
                SELECT  fcfl.fee_type
                FROM    IGS_FI_F_CAT_FEE_LBL    fcfl
                WHERE   fcfl.fee_cat = p_fee_cat AND
                        fcfl.fee_cal_type = p_dest_cal_type AND
                        fcfl.fee_ci_sequence_number = p_dest_sequence_number AND
                        fcfl.fee_type = cp_fee_type;
        CURSOR c_ftci (
                cp_fee_type     IGS_FI_F_TYP_CA_INST.fee_type%TYPE) IS
                SELECT  ftci.fee_type
                FROM    IGS_FI_F_TYP_CA_INST    ftci
                WHERE   ftci.fee_type = cp_fee_type AND
                        ftci.fee_cal_type = p_dest_cal_type AND
                        ftci.fee_ci_sequence_number = p_dest_sequence_number;
        CURSOR c_dai (
                cp_dt_alias             IGS_CA_DA_INST.dt_alias%TYPE,
                cp_sequence_number      IGS_CA_DA_INST.sequence_number%TYPE,
                cp_cal_type             IGS_CA_DA_INST.cal_type%TYPE,
                cp_ci_sequence_number   IGS_CA_DA_INST.ci_sequence_number%TYPE) IS
                SELECT  dt_alias
                FROM    IGS_CA_DA_INST
                WHERE   dt_alias = cp_dt_alias AND
                        sequence_number = cp_sequence_number AND
                        cal_type = cp_cal_type AND
                        ci_sequence_number = cp_ci_sequence_number;
  BEGIN
        -- This function will roll all IGS_FI_F_CAT_FEE_LBL records underneath a
        -- nominated IGS_CA_INST to beneath another nominated IGS_CA_INST.
        -- It also controls the rollovr of
        -- * fee_refund_schedule
        -- * IGS_FI_FEE_RET_SCHD
        -- * IGS_FI_FEE_ENCMB
        -- * IGS_FI_CHG_MTH_APP
        -- * IGS_FI_FEE_AS_RATE
        -- * IGS_FI_ELM_RANGE
        -- The assumption is being made that the "destination" IGS_CA_INST
        -- is open and active - it is the responsibility of the calling routine
        -- to check for this.
        -- IGS_GE_NOTE: If some of the IGS_FI_F_CAT_FEE_LBL records already exist then
        -- these will remain unaltered.
        p_message_name := Null;
        -- 1. Process the fee category fee liability records matching the
        -- source calendar instance.
        FOR v_fcfl_fss_rec IN c_fcfl_fss LOOP
                v_fcfl_inserted_ind := FALSE;
                v_fcfl_exists_ind := FALSE;

                -- Rollover of Fee Category Fee Liability is prevented if
                -- the Charge Method has been defined at Fee Category Fee Liability level.

                  IF v_fcfl_fss_rec.s_chg_method_type IS NOT NULL OR v_fcfl_fss_rec.rul_sequence_number IS NOT NULL then
                        l_v_token1_val := IGS_FI_GEN_GL.get_lkp_meaning('IGS_FI_LOCKBOX','FCFL') ;
                        FND_MESSAGE.SET_NAME('IGS', 'IGS_FI_NO_ROLL_CHG_METHOD');
                        FND_MESSAGE.SET_TOKEN('FTCI_FCFL',l_v_token1_val);
                        fnd_file.put_line(fnd_file.log,fnd_message.Get);
                        v_next_fcfl := TRUE;
                  END IF;
                -- Check for the existence of the IGS_FI_F_CAT_FEE_LBL
                -- record under the destination calendar

                OPEN    c_fcfl(
                                v_fcfl_fss_rec.fee_type);
                FETCH   c_fcfl  INTO    v_fee_type;

                IF (c_fcfl%FOUND) THEN
                        CLOSE   c_fcfl;
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS','IGS_FI_FEECAT_FEE_LIAB_ROLLED'));
                        v_fcfl_exists_ind := TRUE;
                ELSE
                        CLOSE   c_fcfl;
                        v_next_fcfl := FALSE;
                        IF (p_fee_liability_status IS NOT NULL) THEN
                                v_fee_liability_status := p_fee_liability_status;
                        ELSE
                                v_fee_liability_status := v_fcfl_fss_rec.fee_liability_status;
                        END IF;
                        -- Check for the existence of the IGS_FI_F_TYP_CA_INST
                        -- record under the destination calendar
                        OPEN    c_ftci( v_fcfl_fss_rec.fee_type);
                        FETCH   c_ftci  INTO    v_fee_type;
                        IF (c_ftci%NOTFOUND) THEN
                                -- process next IGS_FI_F_CAT_FEE_LBL
                                        v_next_fcfl := TRUE;
                        END IF;
                        CLOSE   c_ftci;
                        -- validate status
                        IF (v_next_fcfl = FALSE) THEN
                                IF (IGS_FI_VAL_FCFL.finp_val_fcfl_active(
                                                        v_fee_liability_status,
                                                        p_dest_cal_type,
                                                        p_dest_sequence_number,
                                                        v_message_name) = FALSE) THEN
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS',v_message_name));
                                        -- process next IGS_FI_F_CAT_FEE_LBL
                                        v_next_fcfl := TRUE;
                                END IF;
                        END IF;
                        IF (v_next_fcfl = FALSE) THEN
                                        IF (IGS_FI_VAL_FCFL.finp_val_fcfl_status(
                                                        p_dest_cal_type,
                                                        p_dest_sequence_number,
                                                        p_fee_cat,
                                                        v_fcfl_fss_rec.fee_type,
                                                        v_fee_liability_status,
                                                        v_message_name) = FALSE) THEN
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS',v_message_name));
                                        -- process next IGS_FI_F_CAT_FEE_LBL
                                        v_next_fcfl := TRUE;
                                END IF;
                        END IF;
                        IF (v_next_fcfl = FALSE) THEN
                                        v_valid_dai := TRUE;
                                IF v_fcfl_fss_rec.start_dt_alias IS NOT NULL THEN
                                        -- Check for the existence of the start dai
                                        -- record under the destination calendar
                                        OPEN c_dai(     v_fcfl_fss_rec.start_dt_alias,
                                                        v_fcfl_fss_rec.start_dai_sequence_number,
                                                        p_dest_cal_type,
                                                        p_dest_sequence_number);
                                        FETCH c_dai INTO        v_dummy;
                                        IF (c_dai%NOTFOUND) THEN
                                                        CLOSE c_dai;
                                                v_valid_dai := FALSE;

                                                l_v_token1_val := v_fcfl_fss_rec.start_dt_alias ||','||TO_CHAR(v_fcfl_fss_rec.start_dai_sequence_number);
                                                FND_MESSAGE.SET_NAME('IGS', 'IGS_FI_F_CAT_F_LIA_DOSNT_EXST'); --new mwssage
                                                FND_MESSAGE.SET_TOKEN('TOKEN1',l_v_token1_val);
                                                FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get);
                                        ELSE
                                                CLOSE c_dai;
                                        END IF;
                                END IF;
                                IF v_valid_dai THEN
                                  BEGIN
                                        l_rowid := NULL; -- initialise l_rowid to null before passing into the TBH
                                                         -- l_rowid with a value will throw Un-Handled Exception
                                        IGS_FI_F_CAT_FEE_LBL_PKG.INSERT_ROW(
                                                X_ROWID=>l_rowid,
                                                X_FEE_CAT=>p_fee_cat,
                                                X_FEE_CI_SEQUENCE_NUMBER=>p_dest_sequence_number,
                                                X_FEE_TYPE=>v_fcfl_fss_rec.fee_type,
                                                X_FEE_CAL_TYPE=>p_dest_cal_type,
                                                X_FEE_LIABILITY_STATUS=>v_fee_liability_status,
                                                X_START_DT_ALIAS=>v_fcfl_fss_rec.start_dt_alias,
                                                X_START_DAI_SEQUENCE_NUMBER=>v_fcfl_fss_rec.start_dai_sequence_number,
                                                X_S_CHG_METHOD_TYPE=>v_fcfl_fss_rec.s_chg_method_type,
                                                X_RUL_SEQUENCE_NUMBER=>v_fcfl_fss_rec.rul_sequence_number,
                                                X_WAIVER_CALC_FLAG => v_fcfl_fss_rec.waiver_calc_flag,
                                                X_MODE=>'R'
                                                );

                                        v_fcfl_inserted_ind := TRUE;
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS','IGS_FI_FEECAT_FEELIAB_ROLLED'));
                                   EXCEPTION
                                     WHEN OTHERS THEN
                                       IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
                                        fnd_message.set_name('IGS','IGS_FI_ROLLOVER_FCFL_ERROR');
                                        fnd_message.set_token('FEE_CAT',p_fee_cat);
                                        fnd_message.set_token('FEE_TYPE',v_fcfl_fss_rec.fee_type);
                                        fnd_message.set_token('FEE_CAL_TYPE',p_source_cal_type);
                                        fnd_message.set_token('ALT_CODE',g_v_alternate_code);
                                        fnd_file.put_line (fnd_file.log, fnd_message.get);
                                  END;
                                END IF;
                        END IF;
                END IF;
                IF (v_fcfl_inserted_ind = TRUE OR v_fcfl_exists_ind = TRUE) THEN

                        -- rollover related fee retention schedule
                        IF (IGS_FI_PRC_FEE_ROLLV.finp_ins_roll_frtns(
                                                                p_source_cal_type,
                                                                p_source_sequence_number,
                                                                p_dest_cal_type,
                                                                p_dest_sequence_number,
                                                                cst_fcfl,
                                                                v_fcfl_fss_rec.fee_type,
                                                                v_fcfl_fss_rec.fee_cat,
                                                                v_message_name) = FALSE) THEN
                                p_message_name := v_message_name;
                                RETURN FALSE;
                        ELSIF (v_message_name = cst_warning) THEN
                                p_message_warning := v_message_name;
                        END IF;
                        -- rollover related fee encumbrances
--                      sykrishn  29november2001 Removed the procedure finp_ins_roll_fe - as part of obseletion in bug 2126091.

                          -- rollover related charge method apportionments
                          -- Enh # 2187247 : SFCR021 : FCI-LCI Relation
                          -- Removed the call to function for Charge Method Apportion rollover

                        -- rollover related fee assessment rates
                        IF (IGS_FI_PRC_FEE_ROLLV.finp_ins_roll_far(
                                                                v_fcfl_fss_rec.fee_type,
                                                                p_source_cal_type,
                                                                p_source_sequence_number,
                                                                p_dest_cal_type,
                                                                p_dest_sequence_number,
                                                                cst_fcfl,
                                                                v_fcfl_fss_rec.fee_cat,
                                                                v_message_name) = FALSE) THEN
                                p_message_name := v_message_name;
                                RETURN FALSE;
                        ELSIF (v_message_name = cst_warning) THEN
                                p_message_warning := v_message_name;
                        END IF;
                        -- rollover related elements ranges
                        IF (IGS_FI_PRC_FEE_ROLLV.finp_ins_roll_er(
                                                                v_fcfl_fss_rec.fee_type,
                                                                p_source_cal_type,
                                                                p_source_sequence_number,
                                                                p_dest_cal_type,
                                                                p_dest_sequence_number,
                                                                cst_fcfl,
                                                                v_fcfl_fss_rec.fee_cat,
                                                                v_message_name) = FALSE) THEN
                                p_message_name := v_message_name;
                                RETURN FALSE;
                        ELSIF (v_message_name = cst_warning) THEN
                                p_message_warning := v_message_name;
                        END IF;

                        -- Roll over Fee Trigger Groups
                        IF (finp_ins_roll_trg_grp( p_fee_cat                 => v_fcfl_fss_rec.fee_cat,
                                                   p_source_cal_type         => p_source_cal_type,
                                                   p_source_sequence_number  => p_source_sequence_number,
                                                   p_dest_cal_type           => p_dest_cal_type,
                                                   p_dest_sequence_number    => p_dest_sequence_number,
                                                   p_fee_type                => v_fcfl_fss_rec.fee_type,
                                                   p_message_name            => v_message_name) = FALSE) THEN
                                  p_message_name := v_message_name;
                                  RETURN FALSE;
                        END IF;

                        -- rollover related IGS_PS_COURSE type fee triggers
                        IF (IGS_FI_PRC_FEE_ROLLV.finp_ins_roll_ctft(
                                                                v_fcfl_fss_rec.fee_cat,
                                                                p_source_cal_type,
                                                                p_source_sequence_number,
                                                                p_dest_cal_type,
                                                                p_dest_sequence_number,
                                                                v_fcfl_fss_rec.fee_type,
                                                                v_message_name) = FALSE) THEN
                                p_message_name := v_message_name;
                                RETURN FALSE;
                        END IF;
                        -- rollover related IGS_PS_COURSE group fee triggers
                        IF (IGS_FI_PRC_FEE_ROLLV.finp_ins_roll_cgft(
                                                                v_fcfl_fss_rec.fee_cat,
                                                                p_source_cal_type,
                                                                p_source_sequence_number,
                                                                p_dest_cal_type,
                                                                p_dest_sequence_number,
                                                                v_fcfl_fss_rec.fee_type,
                                                                v_message_name) = FALSE) THEN
                                p_message_name := v_message_name;
                                RETURN FALSE;
                        END IF;
                        -- rollover related IGS_PS_COURSE fee triggers
                        IF (IGS_FI_PRC_FEE_ROLLV.finp_ins_roll_cft(
                                                                v_fcfl_fss_rec.fee_cat,
                                                                p_source_cal_type,
                                                                p_source_sequence_number,
                                                                p_dest_cal_type,
                                                                p_dest_sequence_number,
                                                                v_fcfl_fss_rec.fee_type,
                                                                v_message_name) = FALSE) THEN
                                p_message_name := v_message_name;
                                RETURN FALSE;
                        END IF;

                        -- Roll over Unit Fee Triggers
                        IF (finp_ins_roll_uft( p_fee_cat                 => v_fcfl_fss_rec.fee_cat,
                                               p_source_cal_type         => p_source_cal_type,
                                               p_source_sequence_number  => p_source_sequence_number,
                                               p_dest_cal_type           => p_dest_cal_type,
                                               p_dest_sequence_number    => p_dest_sequence_number,
                                               p_fee_type                => v_fcfl_fss_rec.fee_type,
                                               p_message_name            => v_message_name) = FALSE) THEN
                                p_message_name := v_message_name;
                                RETURN FALSE;
                        END IF;

                        -- Roll over Unit Set Fee Triggers
                        IF (finp_ins_roll_usft( p_fee_cat                 => v_fcfl_fss_rec.fee_cat,
                                               p_source_cal_type          => p_source_cal_type,
                                               p_source_sequence_number   => p_source_sequence_number,
                                               p_dest_cal_type            => p_dest_cal_type,
                                               p_dest_sequence_number     => p_dest_sequence_number,
                                               p_fee_type                 => v_fcfl_fss_rec.fee_type,
                                               p_message_name             => v_message_name) = FALSE) THEN
                                p_message_name := v_message_name;
                                RETURN FALSE;
                        END IF;
                END IF;
        END LOOP;
        RETURN TRUE;
  END;
  END finp_ins_roll_fcfl;
  --
  -- Routine to rollover charge method apportionments between cal instances
  -- Enh # 2187247
  -- SFCR021 : FCI-LCI Relation
  -- Removed the function for Charge Method Apportion rollover
  --
  -- Routine to rollover fee assessment rates between cal instances
  FUNCTION finp_ins_roll_far(
  p_fee_type IN IGS_FI_FEE_AS_RATE.fee_type%TYPE ,
  p_source_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_source_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_dest_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_dest_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_relation_type IN IGS_FI_FEE_AS_RATE.s_relation_type%TYPE ,
  p_fee_cat IN IGS_FI_FEE_AS_RATE.fee_cat%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  /*******************************************************************/
  --Change History
  --Who        When          What
  --sapanigr   14-Jun-2006   Bug 5148913. Unhandled exceptions at insert row caught and appropriate
  --                         error message logged.
  --sapanigr   29-Mar-2006   Bug# 4606670 Added check finp_val_far_create. This validates that
  --                         when rates defined at FTCI level, they cannot also be
  --                         defined at FCFL level and vice-versa.
  --svuppala   03-Jun-2005   Enh# 3442712 Added Unit Program Type Level, Unit Mode, Unit Code,
  --                          Unit Version and Unit Level
  --pathipat   11-Sep-2003   Enh 3108052 - Add Unit Sets to Rate Table
  --                         Modified cursor c_far_source, call to igs_fi_fee_as_rate_pkg.insert_row
  /*******************************************************************/
     gv_other_detail         VARCHAR2(255);
  BEGIN
        DECLARE
                v_record_inserted_ind           BOOLEAN;
                v_record_exists_ind             BOOLEAN;
                v_message_name                  VARCHAR2(30);
                v_rate_number                   IGS_FI_FEE_AS_RATE.rate_number%TYPE;
                v_logical_delete_dt             IGS_FI_FEE_AS_RATE.logical_delete_dt%TYPE;
                v_FAR_ID                        NUMBER;
                l_rowid                         VARCHAR2(25);
                l_b_ftci_fcci_clash_ind BOOLEAN := TRUE;
                CURSOR c_far_source IS
                        SELECT  far.fee_type,
                                far.rate_number,
                                far.fee_cat,
                                far.location_cd,
                                far.attendance_type,
                                far.attendance_mode,
                                far.order_of_precedence,
                                far.govt_hecs_payment_option,
                                far.govt_hecs_cntrbtn_band,
                                far.chg_rate,
                                far.unit_class,
                                far.residency_status_cd,
                                far.course_cd,
                                far.version_number,
                                far.org_party_id,
                                far.class_standing,
                                far.unit_set_cd,
                                far.us_version_number,
                                far.unit_cd,
                                far.unit_version_number,
                                far.unit_level,
                                far.unit_type_id,
                                far.unit_mode
                        FROM    IGS_FI_FEE_AS_RATE      far
                        WHERE   far.fee_type = p_fee_type AND
                                far.fee_cal_type = p_source_cal_type AND
                                far.fee_ci_sequence_number = p_source_sequence_number AND
                                far.s_relation_type = p_relation_type AND
                                far.logical_delete_dt is NULL AND
                                (far.fee_cat = p_fee_cat OR p_fee_cat IS NULL);
                CURSOR c_far_dest (
                        cp_rate_number          IGS_FI_FEE_AS_RATE.rate_number%TYPE) IS
                        SELECT  far.rate_number,
                                far.logical_delete_dt
                        FROM    IGS_FI_FEE_AS_RATE      far
                        WHERE   far.fee_type = p_fee_type AND
                                far.fee_cal_type = p_dest_cal_type AND
                                far.fee_ci_sequence_number = p_dest_sequence_number AND
                                far.s_relation_type = p_relation_type AND
                                far.rate_number = cp_rate_number;
        BEGIN
                -- This function will roll all IGS_FI_FEE_AS_RATE records underneath a
                -- nominated IGS_CA_INST to beneath another nominated IGS_CA_INST.
                -- The assumption is being made that the "destination" IGS_CA_INST
                -- is open and active - it is the responsibility of the calling routine to
                -- check for this.
                -- IGS_GE_NOTE: If some of the IGS_FI_FEE_AS_RATE records already exist then these will
                -- remain unaltered.
                p_message_name := Null;
                -- 1. Process the fee assessment rate records matching the source calendar
                -- instance
                v_record_inserted_ind := FALSE;
                v_record_exists_ind := FALSE;

                  FOR v_far_source_rec IN c_far_source LOOP
                          -- Check for the existence of the IGS_FI_FEE_AS_RATE
                          -- record under the destination calendar
                          OPEN c_far_dest(v_far_source_rec.rate_number);
                          FETCH c_far_dest INTO   v_rate_number,
                                                  v_logical_delete_dt;
                          IF (c_far_dest%FOUND) THEN
                               CLOSE c_far_dest;
                               IF (v_logical_delete_dt IS NULL) THEN
                                       v_record_exists_ind := TRUE;
                               END IF;
                          ELSE
                               CLOSE c_far_dest;
                               BEGIN
                                 IF (l_b_ftci_fcci_clash_ind) THEN -- check flag
                                   -- When rates to be defined at FTCI level, proceed only
                                   -- if not defined at FCFL level and vice-versa.
                                   IF igs_fi_val_far.finp_val_far_create(p_fee_type,
                                                         p_dest_cal_type,
                                                         p_dest_sequence_number,
                                                         p_relation_type,
                                                         v_message_name) THEN
                                        l_rowid := NULL; -- initialise l_rowid to null before passing into the TBH
                                                         -- l_rowid with a value will throw Un-Handled Exception
                                        IGS_FI_FEE_AS_RATE_PKG.INSERT_ROW(
                                                X_ROWID                      => l_rowid,
                                                x_FAR_ID                     => v_FAR_ID,
                                                X_FEE_TYPE                   => v_far_source_rec.fee_type,
                                                X_FEE_CAL_TYPE               => p_dest_cal_type,
                                                X_FEE_CI_SEQUENCE_NUMBER     => p_dest_sequence_number,
                                                X_S_RELATION_TYPE            => p_relation_type,
                                                X_RATE_NUMBER                => v_far_source_rec.rate_number,
                                                X_FEE_CAT                    => v_far_source_rec.fee_cat,
                                                X_LOCATION_CD                => v_far_source_rec.location_cd,
                                                X_ATTENDANCE_TYPE            => v_far_source_rec.attendance_type,
                                                X_ATTENDANCE_MODE            => v_far_source_rec.attendance_mode,
                                                X_ORDER_OF_PRECEDENCE        => v_far_source_rec.order_of_precedence,
                                                X_GOVT_HECS_PAYMENT_OPTION   => v_far_source_rec.govt_hecs_payment_option,
                                                X_GOVT_HECS_CNTRBTN_BAND     => v_far_source_rec.govt_hecs_cntrbtn_band,
                                                X_CHG_RATE                   => v_far_source_rec.chg_rate,
                                                X_LOGICAL_DELETE_DT          => NULL,
                                                X_RESIDENCY_STATUS_CD        => v_far_source_rec.residency_status_cd,
                                                X_COURSE_CD                  => v_far_source_rec.course_cd,
                                                X_VERSION_NUMBER             => v_far_source_rec.version_number,
                                                X_ORG_PARTY_ID               => v_far_source_rec.org_party_id,
                                                X_CLASS_STANDING             => v_far_source_rec.class_standing,
                                                X_MODE                       => 'R',
                                                x_unit_set_cd                => v_far_source_rec.unit_set_cd,
                                                x_us_version_number          => v_far_source_rec.us_version_number,
                                                x_unit_cd                    => v_far_source_rec.unit_cd,
                                                x_unit_version_number        => v_far_source_rec.unit_version_number,
                                                x_unit_level                 => v_far_source_rec.unit_level ,
                                                x_unit_type_id               => v_far_source_rec.unit_type_id,
                                                x_unit_class                 => v_far_source_rec.unit_class ,
                                                x_unit_mode                  => v_far_source_rec.unit_mode
                                                );
                                        v_record_inserted_ind := TRUE;
                                   ELSE
                                          IF (v_message_name= 'IGS_FI_ASSRATES_NOT_DEFINED') THEN
                                                    fnd_message.set_name('IGS', 'IGS_FI_FAR_FTCI_FCFL_EXIST');
                                                    fnd_message.set_token('SOURCE', igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FCFL'));
                                                    fnd_message.set_token('DESTINATION', igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FTCI'));
                                                    fnd_file.put_line(fnd_file.log, fnd_message.get);
                                          ELSIF (v_message_name= 'IGS_FI_ASSRATES_NOT_DFNED_FEE') THEN
                                                    fnd_message.set_name('IGS', 'IGS_FI_FAR_FTCI_FCFL_EXIST');
                                                    fnd_message.set_token('SOURCE', igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FTCI'));
                                                    fnd_message.set_token('DESTINATION', igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FCFL'));
                                                    fnd_file.put_line(fnd_file.log, fnd_message.get);
                                          END IF;
                                          p_message_name := cst_warning;
                                          l_b_ftci_fcci_clash_ind := FALSE;
                                   END IF;
                                 END IF;
                               EXCEPTION
                                  WHEN OTHERS THEN
                                    IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
                                     fnd_message.set_name('IGS','IGS_FI_ROLLOVER_FAR_ERROR');
                                     fnd_message.set_token('FEE_CAT',v_far_source_rec.fee_cat);
                                     fnd_message.set_token('FEE_TYPE',p_fee_type);
                                     fnd_message.set_token('FEE_CAL_TYPE',p_source_cal_type);
                                     fnd_message.set_token('ALT_CODE',g_v_alternate_code);
                                     fnd_message.set_token('RATE_NUMBER',v_far_source_rec.rate_number);
                                     fnd_file.put_line (fnd_file.log, fnd_message.get);
                               END;
                          END IF;
                  END LOOP;
                        -- 2. Check IF records rolled over
                        IF (v_record_exists_ind = TRUE) THEN
                                                FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS','IGS_FI_FEEASS_RATE_ROLLED'));
                        END IF;
                        IF (v_record_inserted_ind = TRUE) THEN
                                                FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS','IGS_FI_FEEASS_RATES_ROLLED'));
                        END IF;
                RETURN TRUE;
        END;
  END finp_ins_roll_far;
  --
  -- Routine to rollover elements ranges between cal instances

  FUNCTION finp_ins_roll_er(
  p_fee_type IN IGS_FI_ELM_RANGE.fee_type%TYPE ,
  p_source_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_source_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_dest_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_dest_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_relation_type IN IGS_FI_ELM_RANGE.s_relation_type%TYPE ,
  p_fee_cat IN IGS_FI_ELM_RANGE.fee_cat%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  /*******************************************************************/
  --Change History
  --Who        When          What
  --sapanigr   14-Jun-2006   Bug 5148913. Unhandled exceptions at insert row caught and appropriate
  --                         error message logged.
  --gurprsin   28-Jun-2005   Bug# 3392088 Modified the rollover process to incorporate
  --                         sub element ranges and rates table rollover.
/*******************************************************************/
        gv_other_detail         VARCHAR2(255);
  BEGIN
        DECLARE
                v_er_record_inserted_ind        BOOLEAN;
                v_er_record_exists_ind          BOOLEAN;
                v_err_record_inserted_ind       BOOLEAN;
                v_err_record_exists_ind         BOOLEAN;
                v_message_name                  VARCHAR2(30);
                v_range_number                  IGS_FI_ELM_RANGE.range_number%TYPE;
                v_logical_delete_dt             IGS_FI_ELM_RANGE.logical_delete_dt%TYPE;
                v_er_id                         NUMBER;
                v_err_id                        NUMBER;
                l_rowid                         VARCHAR2(25);
                l_sub_er_id                     VARCHAR2(25);
                l_sub_err_id                     VARCHAR2(25);

                v_ser_logical_delete_dt         IGS_FI_SUB_ELM_RNG.logical_delete_date%TYPE;
                v_sert_logical_delete_dt        IGS_FI_SUB_ER_RT.logical_delete_date%TYPE;

                v_ser_record_exists_ind         BOOLEAN;
                v_sert_record_exists_ind        BOOLEAN;
                v_ser_record_inserted_ind       BOOLEAN;
                v_sert_record_inserted_ind      BOOLEAN;

                l_c_v_sert_rec                  VARCHAR2(1);
                l_c_v_rates_exist               VARCHAR2(1);

                cst_incremental                 CONSTANT       VARCHAR2(11)    :=   'INCREMENTAL';

                v_sert_rate_number                        IGS_FI_SUB_ER_RT.far_id%TYPE := NULL;

                CURSOR c_er_source IS
                        SELECT  er.range_number,
                                er.fee_cat,
                                er.lower_range,
                                er.upper_range,
                                er.s_chg_method_type,
                                er.er_id
                        FROM    IGS_FI_ELM_RANGE        er
                        WHERE   er.fee_type = p_fee_type AND
                                er.fee_cal_type = p_source_cal_type AND
                                er.fee_ci_sequence_number = p_source_sequence_number AND
                                er.s_relation_type = p_relation_type AND
                                er.logical_delete_dt is NULL AND
                                (fee_cat = p_fee_cat OR
                                p_fee_cat IS NULL);
                --Included selection of er_id in the cursor select query as a part of CPF build . Bug #3392088
                CURSOR c_er_dest (
                        cp_range_number         IGS_FI_ELM_RANGE.range_number%TYPE) IS
                        SELECT  er.er_id,
                                er.range_number,
                                er.logical_delete_dt
                        FROM    IGS_FI_ELM_RANGE        er
                        WHERE   er.fee_type = p_fee_type AND
                                er.fee_cal_type = p_dest_cal_type AND
                                er.fee_ci_sequence_number = p_dest_sequence_number AND
                                er.s_relation_type = p_relation_type AND
                                er.range_number = cp_range_number;
                CURSOR c_err_source (
                        cp_range_number         IGS_FI_ELM_RANGE.range_number%TYPE) IS
                        SELECT  err.rate_number,
                                err.fee_cat
                        FROM    IGS_FI_ELM_RANGE_RT err
                        WHERE   err.fee_type = p_fee_type AND
                                err.fee_cal_type = p_source_cal_type AND
                                err.fee_ci_sequence_number = p_source_sequence_number AND
                                err.s_relation_type = p_relation_type AND
                                err.range_number = cp_range_number AND
                                err.logical_delete_dt IS NULL;
                CURSOR c_err_dest (
                        cp_range_number         IGS_FI_ELM_RANGE_RT.range_number%TYPE,
                        cp_rate_number          IGS_FI_ELM_RANGE_RT.rate_number%TYPE) IS
                        SELECT  err.range_number,
                                err.logical_delete_dt
                        FROM    IGS_FI_ELM_RANGE_RT err
                        WHERE   err.fee_type = p_fee_type AND
                                err.fee_cal_type = p_dest_cal_type AND
                                err.fee_ci_sequence_number = p_dest_sequence_number AND
                                err.s_relation_type = p_relation_type AND
                                err.range_number = cp_range_number AND
                                err.rate_number = cp_rate_number;
                --Added as a part of CPF build . Bug #3392088
                CURSOR c_ser_source (cp_er_id             IGS_FI_SUB_ELM_RNG.er_id%TYPE) IS
                       SELECT er_id,
                              sub_er_id,
                             sub_range_num,
                             sub_chg_method_code,
                             sub_lower_range,
                             sub_upper_range
                       FROM IGS_FI_SUB_ELM_RNG ser
                       WHERE ser.er_id = cp_er_id AND
                             ser.logical_delete_date IS NULL;

                CURSOR c_ser_dest (
                       cp_er_id                 IGS_FI_SUB_ELM_RNG.er_id%TYPE,
                       cp_sub_range_num         IGS_FI_SUB_ELM_RNG.sub_range_num%TYPE) IS
                       SELECT sub_er_id,logical_delete_date
                       FROM  IGS_FI_SUB_ELM_RNG ser
                       WHERE ser.er_id = cp_er_id AND
                             ser.sub_range_num = cp_sub_range_num;


                CURSOR c_sert_source (
                       cp_sub_er_id              IGS_FI_SUB_ER_RT.sub_er_id%TYPE) IS
                       SELECT sub_er_id,
                              far_id,
                              create_date
                       FROM  IGS_FI_SUB_ER_RT sert
                       WHERE sert.sub_er_id = cp_sub_er_id AND
                             sert.logical_delete_date IS NULL;

                CURSOR c_sert_dest (
                       cp_sub_er_id              IGS_FI_SUB_ER_RT.sub_er_id%TYPE,
                       cp_far_id                 IGS_FI_SUB_ER_RT.far_id%TYPE) IS

                       SELECT 'X'
                       FROM  IGS_FI_SUB_ER_RT sert
                       WHERE sert.sub_er_id = cp_sub_er_id AND
                             sert.far_id = cp_far_id;

                CURSOR c_err_exists IS
                       SELECT  'X'
                       FROM    IGS_FI_ELM_RANGE_RT err
                       WHERE   err.fee_type = p_fee_type AND
                               err.fee_cal_type = p_source_cal_type AND
                               err.fee_ci_sequence_number = p_source_sequence_number AND
                               err.s_relation_type = p_relation_type AND
                               (err.fee_cat = p_fee_cat OR p_fee_cat IS NULL) AND
                               err.logical_delete_dt IS NULL;

                CURSOR c_serr_exists IS
                       SELECT  'X'
                       FROM    IGS_FI_SUB_ER_RT serr,
                               IGS_FI_FEE_AS_RATE far
                       WHERE   far.fee_type = p_fee_type AND
                               far.fee_cal_type = p_source_cal_type AND
                               far.fee_ci_sequence_number = p_source_sequence_number AND
                               far.s_relation_type = p_relation_type AND
                               (far.fee_cat = p_fee_cat OR p_fee_cat IS NULL) AND
                               far.far_id = serr.far_id AND
                               serr.logical_delete_date IS NULL;

                CURSOR c_far_exists IS
                       SELECT  'X'
                       FROM    IGS_FI_FEE_AS_RATE far
                       WHERE   far.fee_type = p_fee_type AND
                               far.fee_cal_type = p_dest_cal_type AND
                               far.fee_ci_sequence_number = p_dest_sequence_number AND
                               far.s_relation_type = p_relation_type AND
                               (far.fee_cat = p_fee_cat OR p_fee_cat IS NULL) AND
                               far.logical_delete_dt IS NULL;

                CURSOR c_sert_far_id_to_rt_num(cp_far_id IGS_FI_SUB_ER_RT.far_id%TYPE) IS
                       SELECT  rate_number
                       FROM    IGS_FI_FEE_AS_RATE far
                       WHERE   far.far_id = cp_far_id;

        BEGIN
                -- This function will roll all IGS_FI_ELM_RANGE and associated
                -- IGS_FI_ELM_RANGE_RT records underneath a
                -- nominated IGS_CA_INST to beneath another nominated IGS_CA_INST.
                -- The assumption is being made that the "destination" IGS_CA_INST
                -- is open and active - it is the responsibility of the calling routine to
                -- check for this.
                -- IGS_GE_NOTE: If some of the elemets_range/IGS_FI_ELM_RANGE_RT records already
                -- exist then these will remain unaltered.
                p_message_name := Null;
                -- 1. Process the elements range records matching the source calendar instance
                v_er_record_inserted_ind := FALSE;
                v_er_record_exists_ind := FALSE;
                v_err_record_inserted_ind := FALSE;
                v_err_record_exists_ind := FALSE;

                v_sert_record_inserted_ind := FALSE;
                v_sert_record_exists_ind := FALSE;
                v_ser_record_inserted_ind := FALSE;
                v_ser_record_exists_ind := FALSE;

                -- Check whether fee assessment rates exist for the destination. If not then log message and return
                OPEN c_far_exists;
                FETCH c_far_exists INTO l_c_v_rates_exist;

                OPEN c_err_exists;
                FETCH c_err_exists INTO l_c_v_rates_exist;

                OPEN c_serr_exists;
                FETCH c_serr_exists INTO l_c_v_rates_exist;

                IF c_far_exists%NOTFOUND AND (c_err_exists%FOUND OR c_serr_exists%FOUND) THEN
                  fnd_message.set_name('IGS', 'IGS_FI_ER_FAR_NOSETUP');
                  fnd_file.put_line(fnd_file.log, fnd_message.get);
                  p_message_name := cst_warning;
                  CLOSE c_serr_exists;
                  CLOSE c_err_exists;
                  CLOSE c_far_exists;
                  RETURN TRUE;
                END IF;

                CLOSE c_serr_exists;
                CLOSE c_err_exists;
                CLOSE c_far_exists;

                FOR v_er_source_rec IN c_er_source LOOP

                        v_er_id := NULL;

                        -- Check for the existence of the IGS_FI_ELM_RANGE
                        -- record under the destination calendar
                        OPEN c_er_dest(v_er_source_rec.range_number);
                        FETCH c_er_dest INTO    v_er_id,
                                                v_range_number,
                                                v_logical_delete_dt;
                        IF (c_er_dest%FOUND) THEN
                             CLOSE c_er_dest;
                             IF (v_logical_delete_dt IS NULL) THEN
                                v_er_record_exists_ind := TRUE;
                             --Added as a part of CPF build . Bug #3392088
                             ELSE
                                v_er_id := NULL;
                             END IF;
                        ELSE

                             CLOSE c_er_dest;
                             BEGIN
                                l_rowid :=NULL; -- initialise l_rowid to null before passing into the TBH
                                                -- l_rowid with a value will throw Un-Handled Exception

                                IGS_FI_EL_RNG_PKG.INSERT_ROW(
                                        X_ROWID=>l_rowid,
                                        X_ER_ID => v_er_id,
                                        X_FEE_TYPE=>p_fee_type,
                                        X_FEE_CAL_TYPE=>p_dest_cal_type,
                                        X_FEE_CI_SEQUENCE_NUMBER=>p_dest_sequence_number,
                                        X_S_RELATION_TYPE=>p_relation_type,
                                        X_RANGE_NUMBER=>v_er_source_rec.range_number,
                                        X_FEE_CAT=>v_er_source_rec.fee_cat,
                                        X_LOWER_RANGE=>v_er_source_rec.lower_range,
                                        X_UPPER_RANGE=>v_er_source_rec.upper_range,
                                        X_S_CHG_METHOD_TYPE=>v_er_source_rec.s_chg_method_type,
                                        X_LOGICAL_DELETE_DT=>NULL,
                                        X_MODE=>'R'
                                        );
                                v_er_record_inserted_ind := TRUE;
                             EXCEPTION
                                  WHEN OTHERS THEN
                                       IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
                                       fnd_message.set_name('IGS','IGS_FI_ROLLOVER_ER_ERROR');
                                       fnd_message.set_token('FEE_CAT',v_er_source_rec.fee_cat);
                                       fnd_message.set_token('FEE_TYPE',p_fee_type);
                                       fnd_message.set_token('FEE_CAL_TYPE',p_source_cal_type);
                                       fnd_message.set_token('ALT_CODE',g_v_alternate_code);
                                       fnd_message.set_token('RANGE_NUMBER',v_er_source_rec.range_number);
                                       fnd_file.put_line (fnd_file.log, fnd_message.get);
                             END;
                        END IF;

                        --Added as a part of CPF build . Bug #3392088
                        IF v_er_source_rec.s_chg_method_type = cst_incremental THEN

                          IF  v_er_id IS NOT NULL THEN

                            FOR v_ser_source_rec IN c_ser_source(v_er_source_rec.er_id) LOOP

                              l_sub_er_id := NULL;

                              OPEN c_ser_dest(v_er_id,v_ser_source_rec.sub_range_num);
                              FETCH c_ser_dest INTO l_sub_er_id,v_ser_logical_delete_dt;

                              IF(c_ser_dest%FOUND) THEN
                                CLOSE c_ser_dest;
                                IF (v_ser_logical_delete_dt IS NULL) THEN
                                    v_ser_record_exists_ind := TRUE;
                                ELSE
                                  l_sub_er_id := NULL;
                                END IF;

                              ELSE
                                CLOSE c_ser_dest;

                                BEGIN
                                     l_rowid :=NULL;      -- initialise l_rowid to null before passing into the TBH
                                                          -- l_rowid with a value will throw Un-Handled Exception
                                     --insert a row into IGS_FI_SUB_ELM_RNG;
                                     IGS_FI_SUB_ELM_RNG_PKG.INSERT_ROW(
                                         x_rowid=> l_rowid,
                                         x_sub_er_id => l_sub_er_id,
                                         x_er_id     => v_er_id,
                                         x_sub_range_num => v_ser_source_rec.sub_range_num,
                                         x_sub_lower_range => v_ser_source_rec.sub_lower_range,
                                         x_sub_upper_range => v_ser_source_rec.sub_upper_range,
                                         x_sub_chg_method_code => v_ser_source_rec.sub_chg_method_code,
                                         x_logical_delete_date => NULL,
                                         x_mode => 'R'
                                        );
                                      v_ser_record_inserted_ind := TRUE;
                                EXCEPTION
                                  WHEN OTHERS THEN
                                       IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
                                       fnd_message.set_name('IGS','IGS_FI_ROLLOVER_SUB_ER_ERROR');
                                       fnd_message.set_token('FEE_CAT',v_er_source_rec.fee_cat);
                                       fnd_message.set_token('FEE_TYPE',p_fee_type);
                                       fnd_message.set_token('FEE_CAL_TYPE',p_source_cal_type);
                                       fnd_message.set_token('ALT_CODE',g_v_alternate_code);
                                       fnd_message.set_token('RANGE_NUMBER',v_er_source_rec.range_number);
                                       fnd_message.set_token('SUB_RANGE_NUMBER',v_ser_source_rec.sub_range_num);
                                       fnd_file.put_line (fnd_file.log, fnd_message.get);
                                END;
                              END IF;

                              IF l_sub_er_id IS NOT NULL THEN

                                FOR v_sert_source_rec IN c_sert_source(v_ser_source_rec.sub_er_id) LOOP

                                  OPEN c_sert_dest(l_sub_er_id, v_sert_source_rec.far_id);
                                  FETCH c_sert_dest INTO l_c_v_sert_rec;
                                  IF(c_sert_dest%FOUND) THEN
                                     CLOSE c_sert_dest;
                                     IF (v_sert_logical_delete_dt IS NULL) THEN
                                         v_sert_record_exists_ind := TRUE;
                                     END IF;

                                  ELSE
                                    CLOSE c_sert_dest;
                                    BEGIN
                                         l_rowid :=NULL;      -- initialise l_rowid to null before passing into the TBH
                                                              -- l_rowid with a value will throw Un-Handled Exception
                                         l_sub_err_id :=NULL;  -- initialise l_rowid to null before passing into the TBH
                                                              -- l_rowid with a value will throw Un-Handled Exception

                                         --insert the record into IGS_FI_SUB_ER_RT;
                                         IGS_FI_SUB_ER_RT_PKG.INSERT_ROW(
                                             x_rowid => l_rowid,
                                             x_sub_err_id => l_sub_err_id,
                                             x_sub_er_id => l_sub_er_id,
                                             x_far_id => v_sert_source_rec.far_id,
                                             x_create_date => v_sert_source_rec.create_date,
                                             x_logical_delete_date => NULL,
                                             x_mode => 'R'
                                            );

                                         v_sert_record_inserted_ind := TRUE;
                                    EXCEPTION
                                      WHEN OTHERS THEN
                                          OPEN c_sert_far_id_to_rt_num(v_sert_source_rec.far_id);
                                          FETCH c_sert_far_id_to_rt_num INTO v_sert_rate_number;
                                          CLOSE c_sert_far_id_to_rt_num;

                                          IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
                                          fnd_message.set_name('IGS','IGS_FI_ROLL_SUB_ER_RT_ERROR');
                                          fnd_message.set_token('FEE_TYPE',p_fee_type);
                                          fnd_message.set_token('FEE_CAL_TYPE',p_source_cal_type);
                                          fnd_message.set_token('ALT_CODE',g_v_alternate_code);
                                          fnd_message.set_token('RANGE_NUMBER',v_er_source_rec.range_number);
                                          fnd_message.set_token('SUB_RANGE_NUMBER',v_ser_source_rec.sub_range_num);
                                          fnd_message.set_token('RATE_NUMBER',v_sert_rate_number);
                                          fnd_file.put_line (fnd_file.log, fnd_message.get);
                                    END;
                                  END IF;
                                END LOOP;

                              END IF; --End of processing Sub Range Rate Records

                            END LOOP;

                          END IF; --End of processing Sub Range Records

                        ELSE
                          -- Process the elements range rate records
                          -- matching the elements range
                          FOR v_err_source_rec IN c_err_source(v_er_source_rec.range_number) LOOP
                                  -- Check for the existence of the IGS_FI_ELM_RANGE_RT record
                                  -- under the rolled over elements range
                                  OPEN c_err_dest(
                                                  v_er_source_rec.range_number,
                                                  v_err_source_rec.rate_number);
                                  FETCH c_err_dest INTO   v_range_number,
                                                          v_logical_delete_dt;
                                  IF (c_err_dest%FOUND) THEN
                                       CLOSE c_err_dest;
                                       IF (v_logical_delete_dt IS NULL) THEN
                                               v_err_record_exists_ind := TRUE;
                                       END IF;
                                  ELSE
                                       CLOSE c_err_dest;
                                       BEGIN
                                          l_rowid :=NULL;  -- initialise l_rowid to null before passing into the TBH
                                                           -- l_rowid with a value will throw Un-Handled Exception
                                          IGS_FI_ELM_RANGE_RT_PKG.INSERT_ROW(
                                                  X_ROWID=>l_rowid,
                                                  X_ERR_ID => v_err_id,
                                                  X_FEE_TYPE=>p_fee_type,
                                                  X_FEE_CAL_TYPE=>p_dest_cal_type,
                                                  X_FEE_CI_SEQUENCE_NUMBER=>p_dest_sequence_number,
                                                  X_S_RELATION_TYPE=>p_relation_type,
                                                  X_RANGE_NUMBER=>v_er_source_rec.range_number,
                                                  X_RATE_NUMBER=>v_err_source_rec.rate_number,
                                                  X_CREATE_DT=>SYSDATE,
                                                  X_FEE_CAT=>v_err_source_rec.fee_cat,
                                                  X_LOGICAL_DELETE_DT=>NULL,
                                                  X_MODE=>'R'
                                                  );
                                          v_err_record_inserted_ind := TRUE;
                                       EXCEPTION
                                         WHEN OTHERS THEN
                                             IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
                                             fnd_message.set_name('IGS','IGS_FI_ROLLOVER_ER_RT_ERROR');
                                             fnd_message.set_token('FEE_TYPE',p_fee_type);
                                             fnd_message.set_token('FEE_CAL_TYPE',p_source_cal_type);
                                             fnd_message.set_token('ALT_CODE',g_v_alternate_code);
                                             fnd_message.set_token('RANGE_NUMBER',v_er_source_rec.range_number);
                                             fnd_message.set_token('RATE_NUMBER',v_err_source_rec.rate_number);
                                             fnd_file.put_line (fnd_file.log, fnd_message.get);
                                       END;
                                  END IF;
                          END LOOP;
                        END IF;
                END LOOP;
                -- 2. Check IF records rolled over
                IF (v_er_record_exists_ind = TRUE) THEN
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS','IGS_FI_ELERNG_ROLLED'));
                END IF;
                IF (v_err_record_exists_ind = TRUE) THEN
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS','IGS_FI_ELERNG_ALREADY_ROLLED'));
                END IF;
                IF (v_er_record_inserted_ind = TRUE) THEN
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS','IGS_FI_ELEMENT_RANGE_ROLLED'));
                END IF;
                IF (v_err_record_inserted_ind = TRUE) THEN
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS','IGS_FI_ELERNG_RATES_ROLLED'));
                END IF;

                IF (v_ser_record_exists_ind = TRUE) THEN
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS','IGS_FI_SER_ALREADY_ROLLED'));
                END IF;
                IF (v_sert_record_exists_ind = TRUE) THEN
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS','IGS_FI_SERT_ALREADY_ROLLED'));
                END IF;
                IF (v_ser_record_inserted_ind = TRUE) THEN
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS','IGS_FI_SER_ROLLED'));
                END IF;
                IF (v_sert_record_inserted_ind = TRUE) THEN
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS','IGS_FI_SERT_ROLLED'));
                END IF;

                RETURN TRUE;
        END;
  END finp_ins_roll_er;
  --
  -- Routine to rollover IGS_PS_COURSE type fee triggers between cal instances
  FUNCTION finp_ins_roll_ctft(
  p_fee_cat IN IGS_PS_TYPE_FEE_TRG.fee_cat%TYPE ,
  p_source_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_source_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_dest_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_dest_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_fee_type IN IGS_PS_TYPE_FEE_TRG.fee_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  /*******************************************************************/
  --Change History
  --Who        When          What
  --sapanigr   14-Jun-2006   Bug 5148913. Unhandled exceptions at insert row caught and appropriate
  --                         error message logged.
  /*******************************************************************/
        gv_other_detail         VARCHAR2(255);
  BEGIN
        DECLARE
                v_course_type                   IGS_PS_TYPE_FEE_TRG.course_type%TYPE;
                v_logical_delete_dt             IGS_PS_TYPE_FEE_TRG.logical_delete_dt%TYPE;
                v_record_inserted_ind           BOOLEAN;
                v_record_exists_ind             BOOLEAN;
                v_message_name                  VARCHAR2(30);
                l_rowid                         VARCHAR2(25);
                CURSOR c_ctft_source IS
                        SELECT  ctft.course_type
                        FROM    IGS_PS_TYPE_FEE_TRG     ctft
                        WHERE   ctft.fee_cat = p_fee_cat AND
                                ctft.fee_cal_type = p_source_cal_type AND
                                ctft.fee_ci_sequence_number = p_source_sequence_number AND
                                ctft.fee_type = p_fee_type AND
                                ctft.logical_delete_dt IS NULL;
                CURSOR c_ctft_dest (
                        cp_course_type          IGS_PS_TYPE_FEE_TRG.COURSE_TYPE%TYPE) IS
                        SELECT  ctft.COURSE_TYPE,
                                ctft.logical_delete_dt
                        FROM    IGS_PS_TYPE_FEE_TRG     ctft
                        WHERE   ctft.fee_cat = p_fee_cat AND
                                ctft.fee_cal_type = p_dest_cal_type AND
                                ctft.fee_ci_sequence_number = p_dest_sequence_number AND
                                ctft.fee_type = p_fee_type AND
                                ctft.COURSE_TYPE = cp_course_type;
                                X_SYSDATE DATE;
        BEGIN
                -- This function will roll all IGS_PS_TYPE_FEE_TRG records underneath a
                -- nominated IGS_CA_INST to beneath another nominated IGS_CA_INST.
                -- The assumption is being made that the "destination" IGS_CA_INST
                -- is open and active - it is the responsibility of the calling routine to
                -- check for this.
                -- IGS_GE_NOTE: If some of the IGS_PS_TYPE_FEE_TRG records already exist then these
                -- will remain unaltered.
                p_message_name := Null;
                -- 1. Process the IGS_PS_COURSE type fee trigger records matching the source
                -- calendar instance
                v_record_inserted_ind := FALSE;
                v_record_exists_ind := FALSE;
                FOR v_ctft_source_rec IN c_ctft_source LOOP
                        -- Check for the existence of the IGS_PS_TYPE_FEE_TRG
                        -- record under the destination calendar
                        OPEN c_ctft_dest(v_ctft_source_rec.course_type);
                        FETCH c_ctft_dest INTO  v_course_type,
                                                v_logical_delete_dt;
                        IF (c_ctft_dest%FOUND) THEN
                          CLOSE c_ctft_dest;
                          IF v_logical_delete_dt IS NULL THEN
                                  v_record_exists_ind := TRUE;
                          END IF;
                        ELSE
                          CLOSE c_ctft_dest;
                          BEGIN
                                X_SYSDATE:=SYSDATE;
                                l_rowid := NULL;  -- initialise l_rowid to null before passing into the TBH
                                                  -- l_rowid with a value will throw Un-Handled Exception
                                IGS_PS_TYPE_FEE_TRG_PKG.INSERT_ROW(
                                        X_ROWID=>l_rowid,
                                        X_FEE_CAT=>p_fee_cat,
                                        X_FEE_TYPE=>p_fee_type,
                                        X_CREATE_DT=>X_SYSDATE,
                                        X_COURSE_TYPE=>v_ctft_source_rec.course_type,
                                        X_FEE_CI_SEQUENCE_NUMBER=>p_dest_sequence_number,
                                        X_FEE_CAL_TYPE=>p_dest_cal_type,
                                        X_LOGICAL_DELETE_DT=>NULL,
                                        X_MODE=>'R'
                                        );
                                v_record_inserted_ind := TRUE;
                          EXCEPTION
                             WHEN OTHERS THEN
                                  IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
                                  fnd_message.set_name('IGS','IGS_FI_ROLLOVER_CTFT_ERROR');
                                  fnd_message.set_token('FEE_CAT',p_fee_cat);
                                  fnd_message.set_token('FEE_TYPE',p_fee_type);
                                  fnd_message.set_token('FEE_CAL_TYPE',p_source_cal_type);
                                  fnd_message.set_token('ALT_CODE',g_v_alternate_code);
                                  fnd_message.set_token('COURSE_TYPE',v_ctft_source_rec.course_type);
                                  fnd_file.put_line (fnd_file.log, fnd_message.get);
                          END;
                        END IF;
                END LOOP;
                -- 2. Check IF records rolled over
                IF (v_record_exists_ind = TRUE) THEN
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS','IGS_FI_PRG_TYPE_FEETRG_ROLLED'));
                END IF;
                IF (v_record_inserted_ind = TRUE) THEN
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS','IGS_FI_PRGTYPE_FEETRG_ROLLED'));
                END IF;
                RETURN TRUE;
        END;
  END finp_ins_roll_ctft;
  --
  -- Routine to rollover IGS_PS_COURSE group fee triggers between cal instances
  FUNCTION finp_ins_roll_cgft(
  p_fee_cat IN IGS_PS_GRP_FEE_TRG.fee_cat%TYPE ,
  p_source_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_source_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_dest_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_dest_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_fee_type IN IGS_PS_GRP_FEE_TRG.fee_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  /*******************************************************************/
  --Change History
  --Who        When          What
  --sapanigr   14-Jun-2006   Bug 5148913. Unhandled exceptions at insert row caught and appropriate
  --                         error message logged.
  /*******************************************************************/
        gv_other_detail         VARCHAR2(255);
  BEGIN
        DECLARE
                v_course_group_cd               IGS_PS_GRP_FEE_TRG.course_group_cd%TYPE;
                v_logical_delete_dt             IGS_PS_GRP_FEE_TRG.logical_delete_dt%TYPE;
                v_record_inserted_ind           BOOLEAN;
                v_record_exists_ind             BOOLEAN;
                v_message_name                  VARCHAR2(30);
                l_rowid                         VARCHAR2(25);
                CURSOR c_cgft_source IS
                        SELECT  cgft.course_group_cd
                        FROM    IGS_PS_GRP_FEE_TRG      cgft
                        WHERE   cgft.fee_cat = p_fee_cat AND
                                cgft.fee_cal_type = p_source_cal_type AND
                                cgft.fee_ci_sequence_number = p_source_sequence_number AND
                                cgft.fee_type = p_fee_type AND
                                cgft.logical_delete_dt IS NULL;
                CURSOR c_cgft_dest (
                        cp_course_group_cd              IGS_PS_GRP_FEE_TRG.course_group_cd%TYPE) IS
                        SELECT  cgft.course_group_cd,
                                cgft.logical_delete_dt
                        FROM    IGS_PS_GRP_FEE_TRG      cgft
                        WHERE   cgft.fee_cat = p_fee_cat AND
                                cgft.fee_cal_type = p_dest_cal_type AND
                                cgft.fee_ci_sequence_number = p_dest_sequence_number AND
                                cgft.fee_type = p_fee_type AND
                                cgft.course_group_cd = cp_course_group_cd;
                                X_SYSDATE DATE;
        BEGIN
                -- This function will roll all IGS_PS_GRP_FEE_TRG records underneath a
                -- nominated IGS_CA_INST to beneath another nominated IGS_CA_INST.
                -- The assumption is being made that the "destination" IGS_CA_INST
                -- is open and active - it is the responsibility of the calling routine to
                -- check for this.
                -- IGS_GE_NOTE: If some of the IGS_PS_GRP_FEE_TRG records already exist then
                -- these will remain unaltered.
                p_message_name := Null;
                -- 1. Process the IGS_PS_COURSE group fee trigger records matching the source
                -- calendar instance
                v_record_inserted_ind := FALSE;
                v_record_exists_ind := FALSE;
                FOR v_cgft_source_rec IN c_cgft_source LOOP
                        -- Check for the existence of the IGS_PS_GRP_FEE_TRG
                        -- record under the destination calendar
                        OPEN c_cgft_dest(v_cgft_source_rec.course_group_cd);
                        FETCH c_cgft_dest INTO  v_course_group_cd,
                                                v_logical_delete_dt;
                        IF (c_cgft_dest%FOUND) THEN
                             CLOSE c_cgft_dest;
                             IF v_logical_delete_dt IS NULL THEN
                                     v_record_exists_ind := TRUE;
                             END IF;
                        ELSE
                             CLOSE c_cgft_dest;
                             BEGIN
                                X_SYSDATE := SYSDATE;
                                l_rowid := NULL; -- initialise l_rowid to null before passing into the TBH
                                                 -- l_rowid with a value will throw Un-Handled Exception
                                IGS_PS_GRP_FEE_TRG_PKG.INSERT_ROW(
                                        X_ROWID=>l_rowid,
                                        X_FEE_CAT=>p_fee_cat,
                                        X_CREATE_DT=>X_SYSDATE,
                                        X_COURSE_GROUP_CD=>v_cgft_source_rec.course_group_cd,
                                        X_FEE_CAL_TYPE=>p_dest_cal_type,
                                        X_FEE_TYPE=>p_fee_type,
                                        X_FEE_CI_SEQUENCE_NUMBER=>p_dest_sequence_number,
                                        X_LOGICAL_DELETE_DT=>NULL,
                                        X_MODE=>'R'
                                        );
                                v_record_inserted_ind := TRUE;
                             EXCEPTION
                                WHEN OTHERS THEN
                                     IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
                                     fnd_message.set_name('IGS','IGS_FI_ROLLOVER_CGFT_ERROR');
                                     fnd_message.set_token('FEE_CAT',p_fee_cat);
                                     fnd_message.set_token('FEE_TYPE',p_fee_type);
                                     fnd_message.set_token('FEE_CAL_TYPE',p_source_cal_type);
                                     fnd_message.set_token('ALT_CODE',g_v_alternate_code);
                                     fnd_message.set_token('COURSE_GROUP_CD',v_cgft_source_rec.course_group_cd);
                                     fnd_file.put_line (fnd_file.log, fnd_message.get);
                             END;
                        END IF;
                END LOOP;
                -- 2. Check IF records rolled over
                IF (v_record_exists_ind = TRUE) THEN
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS','IGS_FI_PRG_GRP_FEETRG_ROLLED'));
                END IF;
                IF (v_record_inserted_ind = TRUE) THEN
                        v_message_name := 'IGS_FI_PRGGRP_FEETRG_ROLLED';
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS','IGS_FI_PRGGRP_FEETRG_ROLLED'));
                END IF;
                RETURN TRUE;
        END;
  END finp_ins_roll_cgft;
  --
  -- Routine to rollover IGS_PS_COURSE fee triggers between cal instances
  FUNCTION finp_ins_roll_cft(
  p_fee_cat IN IGS_PS_FEE_TRG.fee_cat%TYPE ,
  p_source_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_source_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_dest_cal_type IN IGS_CA_INST.cal_type%TYPE ,
  p_dest_sequence_number IN IGS_CA_INST.sequence_number%TYPE ,
  p_fee_type IN IGS_PS_FEE_TRG.fee_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  /*******************************************************************/
  --Change History
  --Who        When          What
  --sapanigr   14-Jun-2006   Bug 5148913. Unhandled exceptions at insert row caught and appropriate
  --                         error message logged.
  /*******************************************************************/
        gv_other_detail         VARCHAR2(255);
  BEGIN
        DECLARE
                v_course_cd                     IGS_PS_FEE_TRG.course_cd%TYPE;
                v_sequence_number               IGS_PS_FEE_TRG.sequence_number%TYPE;
                v_logical_delete_dt             IGS_PS_FEE_TRG.logical_delete_dt%TYPE;
                v_record_inserted_ind           BOOLEAN;
                v_record_exists_ind             BOOLEAN;
                v_message_name                  VARCHAR2(30);
                l_rowid                         VARCHAR2(25);
                CURSOR c_cft_source IS
                        SELECT  cft.course_cd,
                                cft.sequence_number,
                                cft.version_number,
                                cft.cal_type,
                                cft.location_cd,
                                cft.attendance_mode,
                                cft.attendance_type,
                                cft.fee_trigger_group_number
                        FROM    IGS_PS_FEE_TRG  cft
                        WHERE   cft.fee_cat = p_fee_cat AND
                                cft.fee_cal_type = p_source_cal_type AND
                                cft.fee_ci_sequence_number = p_source_sequence_number AND
                                cft.fee_type = p_fee_type AND
                                cft.logical_delete_dt IS NULL;
                CURSOR c_cft_dest (
                        cp_course_cd            IGS_PS_FEE_TRG.course_cd%TYPE,
                        cp_sequence_number      IGS_PS_FEE_TRG.sequence_number%TYPE) IS
                        SELECT  cft.course_cd,
                                cft.sequence_number,
                                cft.logical_delete_dt
                        FROM    IGS_PS_FEE_TRG  cft
                        WHERE   cft.fee_cat = p_fee_cat AND
                                cft.fee_cal_type = p_dest_cal_type AND
                                cft.fee_ci_sequence_number = p_dest_sequence_number AND
                                cft.fee_type = p_fee_type AND
                                cft.course_cd = cp_course_cd AND
                                cft.sequence_number = cp_sequence_number;
        BEGIN
                -- This function will roll all IGS_PS_FEE_TRG records underneath a
                -- nominated IGS_CA_INST to beneath another nominated IGS_CA_INST.
                -- The assumption is being made that the "destination" IGS_CA_INST
                -- is open and active - it is the responsibility of the calling routine to
                -- check for this.
                -- IGS_GE_NOTE: If some of the IGS_PS_FEE_TRG records already exist then these will
                -- remain unaltered.
                p_message_name := Null;
                -- 1. Process the IGS_PS_COURSE fee trigger records matching the source calendar
                -- instance
                v_record_inserted_ind := FALSE;
                v_record_exists_ind := FALSE;
                FOR v_cft_source_rec IN c_cft_source LOOP
                        -- Check for the existence of the IGS_PS_FEE_TRG
                        -- record under the destination calendar
                        OPEN c_cft_dest(
                                        v_cft_source_rec.course_cd,
                                        v_cft_source_rec.sequence_number);
                        FETCH c_cft_dest INTO   v_course_cd,
                                                v_sequence_number,
                                                v_logical_delete_dt;
                        IF (c_cft_dest%FOUND) THEN
                             CLOSE c_cft_dest;
                             IF v_logical_delete_dt IS NULL THEN
                                     v_record_exists_ind := TRUE;
                             END IF;
                        ELSE
                             CLOSE c_cft_dest;
                             BEGIN
                                l_rowid := NULL; -- initialise l_rowid to null before passing into the TBH
                                                 -- l_rowid with a value will throw Un-Handled Exception
                                IGS_PS_FEE_TRG_PKG.INSERT_ROW(
                                        X_ROWID=>l_rowid,
                                        X_FEE_CAT=>p_fee_cat,
                                        X_FEE_TYPE=>p_fee_type,
                                        X_COURSE_CD=>v_cft_source_rec.course_cd,
                                        X_SEQUENCE_NUMBER=>v_cft_source_rec.sequence_number,
                                        X_FEE_CI_SEQUENCE_NUMBER=>p_dest_sequence_number,
                                        X_FEE_CAL_TYPE=>p_dest_cal_type,
                                        X_VERSION_NUMBER=>v_cft_source_rec.version_number,
                                        X_CAL_TYPE=>v_cft_source_rec.cal_type,
                                        X_LOCATION_CD=>v_cft_source_rec.location_cd,
                                        X_ATTENDANCE_MODE=>v_cft_source_rec.attendance_mode,
                                        X_ATTENDANCE_TYPE=>v_cft_source_rec.attendance_type,
                                        X_CREATE_DT=>SYSDATE,
                                        X_FEE_TRIGGER_GROUP_NUMBER=>v_cft_source_rec.fee_trigger_group_number,
                                        X_LOGICAL_DELETE_DT=>NULL,
                                        X_MODE=>'R'
                                        );
                                v_record_inserted_ind := TRUE;
                             EXCEPTION
                                WHEN OTHERS THEN
                                     IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
                                     fnd_message.set_name('IGS','IGS_FI_ROLLOVER_CFT_ERROR');
                                     fnd_message.set_token('FEE_CAT',p_fee_cat);
                                     fnd_message.set_token('FEE_TYPE',p_fee_type);
                                     fnd_message.set_token('FEE_CAL_TYPE',p_source_cal_type);
                                     fnd_message.set_token('ALT_CODE',g_v_alternate_code);
                                     fnd_message.set_token('COURSE_CD',v_cft_source_rec.course_cd);
                                     fnd_file.put_line (fnd_file.log, fnd_message.get);
                             END;
                        END IF;
                END LOOP;
                -- 2. Check IF records rolled over
                IF (v_record_exists_ind = TRUE) THEN
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS','IGS_FI_PRG_FEETRG_ROLLED'));
                END IF;
                IF (v_record_inserted_ind = TRUE) THEN
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS','IGS_FI_PRGFEE_TRG_ROLLED'));
                END IF;
                RETURN TRUE;
        END;
  END finp_ins_roll_cft;

  FUNCTION finp_ins_roll_anc(
  p_fee_type IN IGS_FI_ANC_RT_SGMNTS.fee_type%TYPE ,
  p_source_cal_type IN IGS_FI_ANC_RT_SGMNTS.fee_cal_type%TYPE ,
  p_source_ci_sequence_number IN IGS_FI_ANC_RT_SGMNTS.fee_ci_sequence_number%TYPE ,
  p_dest_cal_type IN IGS_FI_ANC_RT_SGMNTS.fee_cal_type%TYPE ,
  p_dest_ci_sequence_number IN IGS_FI_ANC_RT_SGMNTS.fee_ci_sequence_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
  /*************************************************************
  Created By :Nilotpal.Shee
  Date Created By :18-Apr-2001
  Purpose :To rollover Ancillary related segments and rates when the roll over for Fee Type Calendar Instances occurs.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sapanigr        14-Jun-2006     Bug 5148913. Unhandled exceptions at insert row caught and appropriate
                                  error message logged.
  shtatiko        25-APR-2003     Enh# 2831569, Modified code so that function will log the message as soon as
                                  it enocounters error ( IGS_FI_RT_SGMNTS_DS_NT_XS and IGS_FI_ANC_RTS_DS_NT_XS ).
                                  And so function will always returns TRUE.
  pathipat        24-Jan-2003     Bug: 2765199 - Removed exception section
  vvutukur        02-Sep-2002     Bug#2531390.Used assignment operator by removing DEFAULT clause to
                                  avoid gscc warnings.
  vchappid        29-May-2002     This function was returning FALSE when there are no records in the Ancillary Tables.
                                  IF false is returned then the process is terminated and will not carry-on with the
                                  Fee Categories rollover.

  (reverse chronological order - newest change first)
  ***************************************************************/
        gv_other_detail                 VARCHAR2(255);

  BEGIN
        DECLARE
                v_record_inserted_ind           BOOLEAN;
                v_sgmnts_record_exists_ind      BOOLEAN;
                v_rates_record_exists_ind       BOOLEAN;
                v_message_name                  VARCHAR2(30);
                v_rt_sgmnts_flag BOOLEAN := FALSE;
                v_rates_flag BOOLEAN := FALSE;
                l_rowid                   VARCHAR2(25);
                l_rowid2                   VARCHAR2(25);
                -- cursor to check whether records are present to be rolled over in the Ancillary rate segments table
                CURSOR c_cur_source_sgmnts IS
                        SELECT  *
                        FROM    IGS_FI_ANC_RT_SGMNTS sfars
                        WHERE   sfars.fee_type = p_fee_type AND
                                sfars.fee_cal_type = p_source_cal_type AND
                                sfars.fee_ci_sequence_number = p_source_ci_sequence_number;
                -- cursor to check whether records are present to be rolled over in the Ancillary rates table
                CURSOR c_cur_source_rates IS
                        SELECT  *
                        FROM    IGS_FI_ANC_RATES sfnr
                        WHERE   sfnr.fee_type = p_fee_type AND
                                sfnr.fee_cal_type = p_source_cal_type AND
                                sfnr.fee_ci_sequence_number = p_source_ci_sequence_number;
                -- cursor to check whether records have already been rolled over in the Ancillary rate segments table
                CURSOR c_cur_dest_sgmnts IS
                        SELECT  *
                        FROM    IGS_FI_ANC_RT_SGMNTS dfars
                        WHERE   dfars.fee_type = p_fee_type AND
                                dfars.fee_cal_type = p_dest_cal_type AND
                                dfars.fee_ci_sequence_number = p_dest_ci_sequence_number;
                -- cursor to check whether records have already been rolled over in the Ancillary rates table
                CURSOR c_cur_dest_rates IS
                        SELECT  *
                        FROM    IGS_FI_ANC_RATES dfnr
                        WHERE   dfnr.fee_type = p_fee_type AND
                                dfnr.fee_cal_type = p_dest_cal_type AND
                                dfnr.fee_ci_sequence_number = p_dest_ci_sequence_number;
                v_cur_dest_sgmnts_rec c_cur_dest_sgmnts%ROWTYPE;
                v_cur_dest_rates_rec c_cur_dest_rates%ROWTYPE;
                l_ancillary_rate_id IGS_FI_ANC_RATES.ancillary_rate_id%TYPE;
                l_anc_rate_segment_id IGS_FI_ANC_RT_SGMNTS.anc_rate_segment_id%TYPE;
                l_ancillary_attributes IGS_FI_ANC_RT_SGMNTS.ancillary_attributes%TYPE;

        BEGIN
                -- This function will roll over all Ancillary Segments and Ancillary Rates within a
                -- particular FTCI combination.(fee_type, Fee_cal_type and fee_ci_sequence_number).
                -- The assumption is being made as per the DLD that a successful rollover is the one when both
                -- Ancillary Segments and Ancillary Rates are rolled over i.e., when records are inserted in
                -- both the tables IGS_FI_ANC_RT_SGMNTS and IGS_FI_ANC_RATES.
                p_message_name := NULL;
                v_record_inserted_ind := FALSE;
                v_sgmnts_record_exists_ind      := FALSE;
                v_rates_record_exists_ind       := FALSE;
                OPEN c_cur_dest_sgmnts;
                FETCH c_cur_dest_sgmnts INTO v_cur_dest_sgmnts_rec;
                IF (c_cur_dest_sgmnts%FOUND) THEN
                        -- This means that rollover has already happened, no rollover needs to happen
                        v_sgmnts_record_exists_ind := TRUE;
                        IF (v_sgmnts_record_exists_ind = TRUE) THEN
                                  FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS','IGS_FI_ANC_SGMNTS_ROLLED'));
                        END IF;
                ELSE
                        OPEN c_cur_dest_rates;
                        FETCH c_cur_dest_rates INTO v_cur_dest_rates_rec;
                        -- Check for the existence of records in the rates IGS_FI_ANC_RATES
                        -- for the given FTCI (fee type, calendar type and sequence number)
                        IF (c_cur_dest_rates%FOUND) THEN
                                -- This means that rollover has already happened, no rollover needs to happen
                                v_rates_record_exists_ind := TRUE;
                                IF (v_rates_record_exists_ind = TRUE) THEN
                                  FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS','IGS_FI_ANC_RATES_ROLLED'));
                                END IF;
                        ELSE
                                -- Insert into the table when records exist in the source cursor of rate segments
                                FOR v_cur_source_sgmnts_rec IN c_cur_source_sgmnts LOOP
                                v_rt_sgmnts_flag := TRUE;
                                v_record_inserted_ind := TRUE;
                                l_rowid := NULL;  -- initialise l_rowid to null before passing into the TBH
                                                  -- l_rowid with a value will throw Un-Handled Exception
                                  BEGIN
                                       IGS_FI_ANC_RT_SGMNTS_PKG.INSERT_ROW(
                                               X_ROWID=>l_rowid,
                                               X_ANC_RATE_SEGMENT_ID=>l_anc_rate_segment_id,
                                               X_FEE_TYPE=>p_fee_type,
                                               X_FEE_CAL_TYPE=>p_dest_cal_type,
                                               X_FEE_CI_SEQUENCE_NUMBER=>p_dest_ci_sequence_number,
                                               X_ANCILLARY_ATTRIBUTES=>l_ancillary_attributes,
                                               X_ANCILLARY_SEGMENTS=>v_cur_source_sgmnts_rec.ancillary_segments,
                                               X_ENABLED_FLAG=>v_cur_source_sgmnts_rec.enabled_flag,
                                               X_MODE=>'R'
                                               );
                                  EXCEPTION
                                      WHEN OTHERS THEN
                                          IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
                                          fnd_message.set_name('IGS','IGS_FI_ROLLOVER_ANC_ERROR');
                                          fnd_message.set_token('FEE_TYPE',p_fee_type);
                                          fnd_message.set_token('FEE_CAL_TYPE',p_source_cal_type);
                                          fnd_message.set_token('ALT_CODE',g_v_alternate_code);
                                          fnd_file.put_line (fnd_file.log, fnd_message.get);
                                  END;
                                END LOOP;
                                -- Exit IF there is no record found in the cursor.

                                IF (v_rt_sgmnts_flag = FALSE) THEN
                                  v_message_name:='IGS_FI_RT_SGMNTS_DS_NT_XS';
                                  p_message_name:=v_message_name;
                                  fnd_file.put_line (fnd_file.LOG, fnd_message.get_string ('IGS', p_message_name));
                                END IF;
                                -- Insert into the table when records exist in the source cursor of rates
                                -- and only insert when segments are defined in the ancillary segments tables
                                IF v_rt_sgmnts_flag THEN
                                  FOR v_cur_source_rates_rec IN c_cur_source_rates LOOP
                                    v_rates_flag  := TRUE;
                                    l_rowid2 := NULL;  -- initialise l_rowid2 to null before passing into the TBH
                                                   -- l_rowid2 with a value will throw Un-Handled Exception
                                    BEGIN
                                      IGS_FI_ANC_RATES_PKG.INSERT_ROW(
                                          X_ROWID=>l_rowid2,
                                          X_ANCILLARY_RATE_ID=>l_ancillary_rate_id,
                                          X_FEE_TYPE=>p_fee_type,
                                          X_FEE_CAL_TYPE=>p_dest_cal_type,
                                          X_FEE_CI_SEQUENCE_NUMBER=>p_dest_ci_sequence_number,
                                          X_ANCILLARY_ATTRIBUTE1=>v_cur_source_rates_rec.ancillary_attribute1,
                                          X_ANCILLARY_ATTRIBUTE2=>v_cur_source_rates_rec.ancillary_attribute2,
                                          X_ANCILLARY_ATTRIBUTE3=>v_cur_source_rates_rec.ancillary_attribute3,
                                          X_ANCILLARY_ATTRIBUTE4=>v_cur_source_rates_rec.ancillary_attribute4,
                                          X_ANCILLARY_ATTRIBUTE5=>v_cur_source_rates_rec.ancillary_attribute5,
                                          X_ANCILLARY_ATTRIBUTE6=>v_cur_source_rates_rec.ancillary_attribute6,
                                          X_ANCILLARY_ATTRIBUTE7=>v_cur_source_rates_rec.ancillary_attribute7,
                                          X_ANCILLARY_ATTRIBUTE8=>v_cur_source_rates_rec.ancillary_attribute8,
                                          X_ANCILLARY_ATTRIBUTE9=>v_cur_source_rates_rec.ancillary_attribute9,
                                          X_ANCILLARY_ATTRIBUTE10=>v_cur_source_rates_rec.ancillary_attribute10,
                                          X_ANCILLARY_ATTRIBUTE11=>v_cur_source_rates_rec.ancillary_attribute11,
                                          X_ANCILLARY_ATTRIBUTE12=>v_cur_source_rates_rec.ancillary_attribute12,
                                          X_ANCILLARY_ATTRIBUTE13=>v_cur_source_rates_rec.ancillary_attribute13,
                                          X_ANCILLARY_ATTRIBUTE14=>v_cur_source_rates_rec.ancillary_attribute14,
                                          X_ANCILLARY_ATTRIBUTE15=>v_cur_source_rates_rec.ancillary_attribute15,
                                          X_ANCILLARY_CHG_RATE=>v_cur_source_rates_rec.ancillary_chg_rate,
                                          X_ENABLED_FLAG=>v_cur_source_rates_rec.enabled_flag,
                                          X_MODE=>'R'
                                          );
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
                                            fnd_message.set_name('IGS','IGS_FI_ROLLOVER_ANC_RT_ERROR');
                                            fnd_message.set_token('FEE_TYPE',p_fee_type);
                                            fnd_message.set_token('FEE_CAL_TYPE',p_source_cal_type);
                                            fnd_message.set_token('ALT_CODE',g_v_alternate_code);
                                            fnd_file.put_line (fnd_file.log, fnd_message.get);
                                    END;
                                  END LOOP;
                                  -- Exit IF there is no record found in the cursor.
                                  IF (v_rates_flag = FALSE) THEN
                                        v_message_name:='IGS_FI_ANC_RTS_DS_NT_XS';
                                        p_message_name:=v_message_name;
                                        fnd_file.put_line (fnd_file.LOG, fnd_message.get_string ('IGS', p_message_name));
                                  END IF;
                                END IF; -- v_rt_sgmnts_flag IF close
                        -- Close all open cursors.
                        CLOSE c_cur_dest_rates;
                        END IF;
                CLOSE c_cur_dest_sgmnts;
                END IF;
                -- Only when both the inserts are successful return the message of successful rollover
                IF (v_record_inserted_ind = TRUE) THEN
                        FND_FILE.PUT_LINE (FND_FILE.LOG, Fnd_Message.Get_String('IGS','IGS_FI_ANC_ROLLS'));
                END IF;
                -- Return True when everything is successful
                RETURN TRUE;
  END;
  END finp_ins_roll_anc;
  FUNCTION finp_ins_roll_revseg(
  p_fee_type                    IN  IGS_FI_F_TYPE_ACCTS_ALL.fee_type%TYPE,
  p_source_cal_type             IN  IGS_CA_INST.cal_type%TYPE,
  p_source_sequence_number      IN  IGS_CA_INST.sequence_number%TYPE,
  p_dest_cal_type               IN  IGS_CA_INST.cal_type%TYPE,
  p_dest_sequence_number        IN  IGS_CA_INST.sequence_number%TYPE,
  p_message_name                OUT NOCOPY VARCHAR2
  )
  RETURN BOOLEAN AS
  /*************************************************************
  Created By :kkillams
  Date Created By :16-August-2001
  Purpose :To rollover revenue segments  over for Fee Type Calendar Instances occurs.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sapanigr        14-Jun-2006     Bug 5148913. Unhandled exceptions at insert row caught and appropriate
                                  error message logged.
  vchappid        29-May-2002     Bug# 2384909, Checking and Inserting the segments from the table igs_fi_f_type_accts
                                  is being done based on fee_cal_type and fee_ci_sequence_number disregarding the fee type
                                  When the same fee_cal_type and fee_ci_sequence_number in different fee types then as many
                                  records are inserted,
                                  this function was returning FALSE when the record is already exists, returning flase will terminate
                                  the process. Process should log the message and should continue with next rollover categories
  ***************************************************************/
  CURSOR cur_chk_ex_revsegs IS SELECT 1 FROM igs_fi_f_type_accts
                                        WHERE fee_type = p_fee_type AND
                                              fee_cal_type= p_dest_cal_type AND
                                              fee_ci_sequence_number= p_dest_sequence_number;
  CURSOR cur_roll_segs       IS SELECT * FROM igs_fi_f_type_accts
                                         WHERE fee_type = p_fee_type AND
                                               fee_cal_type= p_source_cal_type AND
                                               fee_ci_sequence_number= p_source_sequence_number;
  l_rowid           VARCHAR2(25);
  l_fee_type_accid  igs_fi_f_type_accts.fee_type_account_id%TYPE;
  l_chk_exists      cur_chk_ex_revsegs%ROWTYPE;
  l_roll_segs       cur_roll_segs%ROWTYPE;

  BEGIN

     OPEN cur_chk_ex_revsegs;
     FETCH cur_chk_ex_revsegs INTO l_chk_exists;
     IF cur_chk_ex_revsegs%FOUND THEN
        p_message_name :='IGS_FI_REV_SEGS_ROLL_EXISTS';
        CLOSE cur_chk_ex_revsegs;
     ELSE
       OPEN cur_roll_segs;
       LOOP
         FETCH cur_roll_segs INTO l_roll_segs;
         EXIT WHEN cur_roll_Segs%NOTFOUND;
           BEGIN
             igs_fi_f_type_accts_pkg.insert_row (
                                                   x_rowid                         => l_rowid,
                                                   x_fee_type_account_id           => l_fee_type_accid,
                                                   x_fee_type                      => p_fee_type,
                                                   x_fee_cal_type                  => p_dest_cal_type,
                                                   x_fee_ci_sequence_number        => p_dest_sequence_number,
                                                   x_segment                       => l_roll_segs.segment,
                                                   x_segment_num                   => l_roll_segs.segment_num,
                                                   x_segment_value                 => l_roll_segs.segment_value,
                                                   x_mode                          => 'R'
                                                 );
            l_rowid := null; -- initialise l_rowid to null before passing into the TBH
                             -- l_rowid with a value will throw Un-Handled Exception
            l_fee_type_accid:= null;
           EXCEPTION
               WHEN OTHERS THEN
                   IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
                   fnd_message.set_name('IGS','IGS_FI_ROLLOVER_REVSEG_ERROR');
                   fnd_message.set_token('FEE_TYPE',p_fee_type);
                   fnd_message.set_token('FEE_CAL_TYPE',p_source_cal_type);
                   fnd_message.set_token('ALT_CODE',g_v_alternate_code);
                   fnd_file.put_line (fnd_file.log, fnd_message.get);
           END;
       END LOOP;
       CLOSE cur_roll_segs;
     END IF;
     RETURN TRUE;
  END finp_ins_roll_revseg;

  FUNCTION finpl_ins_roll_over_ftci_accts (
    p_v_fee_type                IN  igs_fi_f_type_accts_all.fee_type%TYPE,
    p_v_source_cal_type         IN  igs_ca_inst.cal_type%TYPE,
    p_n_source_sequence_number  IN  igs_ca_inst.sequence_number%TYPE,
    p_v_dest_cal_type           IN  igs_ca_inst.cal_type%TYPE,
    p_n_dest_sequence_number    IN  igs_ca_inst.sequence_number%TYPE
  ) RETURN BOOLEAN AS
  /*************************************************************
  Created By :      shtatiko
  Date Created By : 14-MAY-2003

  Purpose : To Rollover Account Table Attribute Records.
            This Function is called only IF the System Fee Type of Source FTCI is OTHER or TUITION

  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sapanigr        14-Jun-2006     Bug 5148913. Unhandled exceptions at insert row caught and appropriate
                                  error message logged.
  gurprsin        30-MAY-2005     Enh# 3442712 Added 4 unit level Columns like unit_level,
                                  unit_mode,unit_class,unit_type_id to TBH call of igs_fi_ftci_accts_pkg
                                  in insert row method
  pathipat        26-Jun-2003     Bug:2992967 - Table validation value set for segments
                                  Removed cur_rev_account_Seg and its usage. Added call to
                                  fnd_flex_keyval.validate_segs()
  ***************************************************************/
  CURSOR cur_ftci_accts(cp_v_fee_type           igs_fi_f_typ_ca_inst.fee_type%TYPE,
                        cp_v_fee_cal_type       igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                        cp_n_fee_ci_seq_number  igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE) IS
  SELECT *
  FROM igs_fi_ftci_accts
  WHERE fee_type = cp_v_fee_type
  AND   fee_cal_type = cp_v_fee_cal_type
  AND   fee_ci_sequence_number = cp_n_fee_ci_seq_number
  ORDER BY order_sequence;
  l_rec_ftci_accts cur_ftci_accts%ROWTYPE;

  CURSOR cur_rev_account_cd(cp_v_rev_acct_cd igs_fi_f_typ_ca_inst.rev_account_cd%TYPE) IS
  SELECT closed_ind
  FROM igs_fi_acc
  WHERE account_cd = cp_v_rev_acct_cd;
  l_rec_rev_account_cd cur_rev_account_cd%ROWTYPE;

  TYPE inactive_acc_tab_type IS TABLE OF igs_fi_ftci_accts.order_sequence%TYPE INDEX BY BINARY_INTEGER;
  l_v_natural_account_segment igs_fi_ftci_accts.natural_account_segment%TYPE := NULL;
  l_v_revenue_account_cd      igs_fi_ftci_accts.rev_account_cd%TYPE := NULL;
  l_n_acct_id                 igs_fi_ftci_accts.acct_id%TYPE;
  l_b_inactive_account        BOOLEAN;
  l_b_records_found           BOOLEAN;
  tab_inactive_acc            inactive_acc_tab_type;
  l_n_cntr                    PLS_INTEGER ;
  l_v_rowid                   VARCHAR2(25) := NULL;
  l_b_enabled                 BOOLEAN;

  BEGIN


    -- Check IF the user has already created the accounting information in the destination fee calendar instance.
    OPEN cur_ftci_accts ( p_v_fee_type, p_v_dest_cal_type, p_n_dest_sequence_number );
    FETCH cur_ftci_accts INTO l_rec_ftci_accts;
    IF ( cur_ftci_accts%FOUND )THEN
      CLOSE cur_ftci_accts;
      fnd_message.set_name ( 'IGS', 'IGS_FI_FTCI_ACCTS_SETUP_EXISTS' );
      fnd_file.put_line ( fnd_file.LOG, fnd_message.get );
      RETURN TRUE;
    END IF;
    CLOSE cur_ftci_accts;

    l_b_records_found := FALSE;     -- Flag which tells whether Accounting information is defined at source FTCI
    l_b_inactive_account := FALSE;  -- This will be made TRUE IF any of the accounting segment at source FTCI is inactive.
    l_n_cntr := 0;                  -- This holds the number of records with inactive accounting segments

    -- Fetch the accounting information for the source calendar instance and loop across each record identified
    FOR l_rec_ftci_accts IN cur_ftci_accts ( p_v_fee_type, p_v_source_cal_type, p_n_source_sequence_number )
    LOOP
      l_b_records_found := TRUE;
      -- If Oracle General Ledger is Installed then check whether the Natural Account Segment is active or not.
      IF (g_v_gl_installed = 'Y') THEN
        l_v_natural_account_segment := l_rec_ftci_accts.natural_account_segment;

        -- If segment_num is NULL, then do not validate, set flag as FALSE
        IF g_n_segment_num IS NULL THEN
           l_b_enabled := FALSE;
        ELSE
           l_b_enabled := fnd_flex_keyval.validate_segs( operation        => 'CHECK_SEGMENTS',
                                                      appl_short_name  => 'SQLGL',
                                                      key_flex_code    => 'GL#',
                                                      structure_number => igs_fi_gen_007.get_coa_id,
                                                      displayable      => g_n_segment_num,
                                                      allow_nulls      => TRUE,
                                                      vrule            => 'GL_ACCOUNT\nGL_ACCOUNT_TYPE\nI\nAPPL=IGS;NAME=IGS_FI_ACC_REV\nR',
                                                      concat_segments  => l_v_natural_account_segment
                                                    );
        END IF;
        -- If there is an invalid segment then insert NULL for Natural Account Segment
        -- l_b_enabled will be FALSE IF the segment is incorrect/not of type Revenue
        IF (l_b_enabled = FALSE) THEN
          l_v_natural_account_segment := NULL;
          l_b_inactive_account := TRUE;
          l_n_cntr := l_n_cntr + 1;
          tab_inactive_acc(l_n_cntr) := l_rec_ftci_accts.order_sequence;
        END IF;
      ELSE
        -- If Oracle General Ledger is not Installed then check whether the Revenue Account Cd is active or not.
        l_v_revenue_account_cd := l_rec_ftci_accts.rev_account_cd;
        OPEN cur_rev_account_cd( l_rec_ftci_accts.rev_account_cd );
        FETCH cur_rev_account_cd INTO l_rec_rev_account_cd;
        IF ( cur_rev_account_cd%NOTFOUND
             OR l_rec_rev_account_cd.closed_ind = 'Y' ) THEN
          -- NULL should be inserted for Revenue Account Cd IF identified Revenue Account Cd is inactive
          l_v_revenue_account_cd := NULL;
          l_b_inactive_account := TRUE;
          l_n_cntr := l_n_cntr + 1;
          tab_inactive_acc(l_n_cntr) := l_rec_ftci_accts.order_sequence;
        END IF;
        CLOSE cur_rev_account_cd;
      END IF;

      l_v_rowid := NULL;
      l_n_acct_id := NULL;
      -- Rollover Account Attribute Record
      --Added 4 unit based parameters.
      BEGIN
           igs_fi_ftci_accts_pkg.insert_row (
             x_rowid                   => l_v_rowid,
             x_acct_id                 => l_n_acct_id,
             x_fee_type                => l_rec_ftci_accts.fee_type,
             x_fee_cal_type            => p_v_dest_cal_type,
             x_fee_ci_sequence_number  => p_n_dest_sequence_number,
             x_order_sequence          => l_rec_ftci_accts.order_sequence,
             x_natural_account_segment => l_v_natural_account_segment,
             x_rev_account_cd          => l_v_revenue_account_cd,
             x_location_cd             => l_rec_ftci_accts.location_cd,
             x_attendance_type         => l_rec_ftci_accts.attendance_type,
             x_attendance_mode         => l_rec_ftci_accts.attendance_mode,
             x_course_cd               => l_rec_ftci_accts.course_cd,
             x_crs_version_number      => l_rec_ftci_accts.crs_version_number,
             x_unit_cd                 => l_rec_ftci_accts.unit_cd,
             x_unit_version_number     => l_rec_ftci_accts.unit_version_number,
             x_org_unit_cd             => l_rec_ftci_accts.org_unit_cd,
             x_residency_status_cd     => l_rec_ftci_accts.residency_status_cd,
             x_uoo_id                  => l_rec_ftci_accts.uoo_id,
             x_mode                    => 'R',
             x_unit_level              => l_rec_ftci_accts.unit_level,
             x_unit_type_id            => l_rec_ftci_accts.unit_type_id,
             x_unit_mode               => l_rec_ftci_accts.unit_mode,
             x_unit_class              => l_rec_ftci_accts.unit_class
           );
      EXCEPTION
         WHEN OTHERS THEN
              IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
              fnd_message.set_name('IGS','IGS_FI_ROLL_FTCI_ACCTS_ERROR');
              fnd_message.set_token('FEE_TYPE',p_v_fee_type);
              fnd_message.set_token('FEE_CAL_TYPE',p_v_source_cal_type);
              fnd_message.set_token('ALT_CODE',g_v_alternate_code);
              fnd_file.put_line (fnd_file.log, fnd_message.get);
      END;

    END LOOP;

    IF ( l_b_records_found ) THEN
      -- If Rollover is successful then log the same.
      fnd_message.set_name ( 'IGS', 'IGS_FI_ROLL_FTCI_ACCTS_SUCCESS' );
      fnd_file.put_line ( fnd_file.LOG, fnd_message.get );
    ELSE
      -- If No Accounting Information is defined at Source FTCI.
      fnd_message.set_name ( 'IGS', 'IGS_FI_FTCI_ACCTS_NO_SETUP' );
      fnd_file.put_line ( fnd_file.LOG, fnd_message.get );
    END IF;

    IF ( l_b_inactive_account ) THEN
      fnd_file.put_line ( fnd_file.LOG, ' ' );
      fnd_message.set_name ( 'IGS', 'IGS_FI_FTCI_ACCTS_INVALID' );
      fnd_file.put_line ( fnd_file.LOG, fnd_message.get );
      FOR l_n_cntr IN tab_inactive_acc.FIRST..tab_inactive_acc.LAST LOOP
        log_parameters ( igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'SEQUENCE'),
                         tab_inactive_acc(l_n_cntr));
      END LOOP;
    END IF;
    RETURN TRUE;

  END finpl_ins_roll_over_ftci_accts;


FUNCTION finp_ins_roll_trg_grp( p_fee_cat                IN igs_fi_fee_trg_grp.fee_cat%TYPE ,
                                p_source_cal_type        IN igs_ca_inst.cal_type%TYPE ,
                                p_source_sequence_number IN igs_ca_inst.sequence_number%TYPE ,
                                p_dest_cal_type          IN igs_ca_inst.cal_type%TYPE ,
                                p_dest_sequence_number   IN igs_ca_inst.sequence_number%TYPE ,
                                p_fee_type               IN igs_fi_fee_trg_grp.fee_type%TYPE ,
                                p_message_name           OUT NOCOPY fnd_new_messages.message_name%TYPE )  RETURN BOOLEAN AS
/*************************************************************
  Created By      : Priya Athipatla
  Date Created By : 12-Jul-2004
  Purpose         : To rollover Fee Trigger Groups
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  sapanigr        14-Jun-2006     Bug 5148913. Unhandled exceptions at insert row caught and appropriate
                                  error message logged.
***************************************************************/
    l_n_fee_trigger_group_number  igs_fi_fee_trg_grp.fee_trigger_group_number%TYPE;
    l_d_logical_delete_dt         igs_fi_fee_trg_grp.logical_delete_dt%TYPE;
    l_b_record_inserted_ind       BOOLEAN := FALSE;
    l_b_record_exists_ind         BOOLEAN := FALSE;
    l_v_message_name              fnd_new_messages.message_name%TYPE;
    l_rowid                       ROWID := NULL;

     -- Cursor to obtain data from Source Calendar Instance
     CURSOR c_trg_grp_source IS
       SELECT  fee_trigger_group_number,
               description,
               comments
       FROM    igs_fi_fee_trg_grp
       WHERE   fee_cat                = p_fee_cat
       AND     fee_cal_type           = p_source_cal_type
       AND     fee_ci_sequence_number = p_source_sequence_number
       AND     fee_type               = p_fee_type
       AND     logical_delete_dt IS NULL;

     -- Cursor to check IF data already exists in Destination Calendar Instance
     CURSOR c_trg_grp_dest (cp_fee_trigger_group_number   igs_fi_fee_trg_grp.fee_trigger_group_number%TYPE) IS
       SELECT  fee_trigger_group_number,
               logical_delete_dt
       FROM    igs_fi_fee_trg_grp
       WHERE   fee_cat                  = p_fee_cat
       AND     fee_cal_type             = p_dest_cal_type
       AND     fee_ci_sequence_number   = p_dest_sequence_number
       AND     fee_type                 = p_fee_type
       AND     fee_trigger_group_number = cp_fee_trigger_group_number;


BEGIN

        -- This function will roll all Fee Trigger Group records underneath a nominated Calendar Instance to
        -- beneath another nominated Calendar Instance. The assumption is being made that the "destination" Calendar Instance
        -- is open and active - it is the responsibility of the calling routine to check for this.
        p_message_name := NULL;

        -- Process the fee trigger group records matching the source calendar instance
        l_b_record_inserted_ind := FALSE;
        l_b_record_exists_ind   := FALSE;

        FOR l_trg_grp_source_rec IN c_trg_grp_source LOOP
            -- Check for the existence of the Fee Trigger Group record under the destination calendar
            OPEN c_trg_grp_dest(l_trg_grp_source_rec.fee_trigger_group_number);
            FETCH c_trg_grp_dest INTO  l_n_fee_trigger_group_number, l_d_logical_delete_dt;
            IF (c_trg_grp_dest%FOUND) THEN
               CLOSE c_trg_grp_dest;
               IF l_d_logical_delete_dt IS NULL THEN
                  l_b_record_exists_ind := TRUE;
               END IF;
            ELSE
               CLOSE c_trg_grp_dest;
               l_rowid := NULL;
                 BEGIN
                    igs_fi_fee_trg_grp_pkg.insert_row( x_rowid                      => l_rowid,
                                                       x_fee_cat                    => p_fee_cat,
                                                       x_fee_trigger_group_number   => l_trg_grp_source_rec.fee_trigger_group_number,
                                                       x_fee_cal_type               => p_dest_cal_type,
                                                       x_fee_ci_sequence_number     => p_dest_sequence_number,
                                                       x_fee_type                   => p_fee_type,
                                                       x_description                => l_trg_grp_source_rec.description,
                                                       x_logical_delete_dt          => NULL,
                                                       x_comments                   => l_trg_grp_source_rec.comments,
                                                       x_mode                       => 'R');
                    l_b_record_inserted_ind := TRUE;
                 EXCEPTION
                    WHEN OTHERS THEN
                         IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
                         fnd_message.set_name('IGS','IGS_FI_ROLLOVER_TRG_GRP_ERROR');
                         fnd_message.set_token('FEE_CAT',p_fee_cat);
                         fnd_message.set_token('FEE_TYPE',p_fee_type);
                         fnd_message.set_token('FEE_CAL_TYPE',p_source_cal_type);
                         fnd_message.set_token('ALT_CODE',g_v_alternate_code);
                         fnd_message.set_token('FEE_TRIGGER_GROUP_NUMBER',l_trg_grp_source_rec.fee_trigger_group_number);
                         fnd_file.put_line (fnd_file.log, fnd_message.get);
                 END;
            END IF;
        END LOOP;

        IF (l_b_record_exists_ind = TRUE) THEN
            -- Display message that the Fee Trigger Group record already exist
            fnd_message.set_name('IGS','IGS_FI_TRG_GRP_EXISTS');
            fnd_file.put_line (fnd_file.log, fnd_message.get);
        END IF;
        IF (l_b_record_inserted_ind = TRUE) THEN
            -- Display message that the Fee Trigger Group record have been successfully rolled over
            fnd_message.set_name('IGS','IGS_FI_TRG_GRP_ROLLED');
            fnd_file.put_line (fnd_file.log, fnd_message.get);
        END IF;
        RETURN TRUE;

END finp_ins_roll_trg_grp;


FUNCTION finp_ins_roll_uft( p_fee_cat                IN igs_fi_unit_fee_trg.fee_cat%TYPE ,
                            p_source_cal_type        IN igs_ca_inst.cal_type%TYPE ,
                            p_source_sequence_number IN igs_ca_inst.sequence_number%TYPE ,
                            p_dest_cal_type          IN igs_ca_inst.cal_type%TYPE ,
                            p_dest_sequence_number   IN igs_ca_inst.sequence_number%TYPE ,
                            p_fee_type               IN igs_fi_unit_fee_trg.fee_type%TYPE ,
                            p_message_name           OUT NOCOPY fnd_new_messages.message_name%TYPE )  RETURN BOOLEAN AS
/*************************************************************
  Created By      : Priya Athipatla
  Date Created By : 12-Jul-2004
  Purpose         : To rollover Unit Fee Triggers
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  akandreg        02-Dec-2005     Bug 4747757. Added cursor cur_chk_version to handle the
                                  issue of rolling over a unit fee trigger when version is
                                  not specified at FCFL level.
  svuppala        11-March-2004   Bug 4224379 - New cursor 'c_alt_cd' is created to get "Alternate code" from
                                  igs_ca_inst_all  and to send as a token in IGS_FI_ROLLOVER_UFT_ERROR.
                                  Added an EXCEPTION to log a message in case of rolling over failure.
  (reverse chronological order - newest change first)
***************************************************************/
    l_v_unit_cd                       igs_fi_unit_fee_trg.unit_cd%TYPE;
    l_v_sequence_number               igs_fi_unit_fee_trg.sequence_number%TYPE;
    l_d_logical_delete_dt             igs_fi_unit_fee_trg.logical_delete_dt%TYPE;
    l_b_record_inserted_ind           BOOLEAN := FALSE;
    l_b_record_exists_ind             BOOLEAN := FALSE;
    l_v_message_name                  fnd_new_messages.message_name%TYPE;
    l_rowid                           ROWID := NULL;
    l_v_alt_code                      igs_ca_inst_all.alternate_code%TYPE;

     -- Cursor to obtain data from Source Calendar Instance
     CURSOR c_uft_source IS
       SELECT  uft.unit_cd,
               uft.sequence_number,
               uft.version_number,
               uft.cal_type,
               uft.ci_sequence_number,
               uft.location_cd,
               uft.unit_class,
               uft.create_dt,
               uft.fee_trigger_group_number

       FROM    igs_fi_unit_fee_trg  uft
       WHERE   uft.fee_cat                = p_fee_cat
       AND     uft.fee_cal_type           = p_source_cal_type
       AND     uft.fee_ci_sequence_number = p_source_sequence_number
       AND     uft.fee_type               = p_fee_type
       AND     uft.logical_delete_dt IS NULL;


     CURSOR c_alt_cd (cp_cal_type         igs_fi_unit_fee_trg.cal_type%TYPE,
                       cp_ci_sequence_number  igs_fi_unit_fee_trg.ci_sequence_number%TYPE) IS
       SELECT  cinst.alternate_code
       FROM    igs_ca_inst_all cinst
       WHERE   cinst.cal_type = cp_cal_type
       AND     cinst.sequence_number = cp_ci_sequence_number;

     -- Cursor to check IF data already exists in Destination Calendar Instance
     CURSOR c_uft_dest (cp_unit_cd          igs_fi_unit_fee_trg.unit_cd%TYPE,
                        cp_sequence_number  igs_fi_unit_fee_trg.sequence_number%TYPE) IS
       SELECT  uft.unit_cd,
               uft.sequence_number,
               uft.logical_delete_dt
       FROM    igs_fi_unit_fee_trg  uft
       WHERE   uft.fee_cat                = p_fee_cat
       AND     uft.fee_cal_type           = p_dest_cal_type
       AND     uft.fee_ci_sequence_number = p_dest_sequence_number
       AND     uft.fee_type               = p_fee_type
       AND     uft.unit_cd                = cp_unit_cd
       AND     uft.sequence_number        = cp_sequence_number;

    CURSOR cur_chk_version(cp_v_unit_cd  igs_fi_unit_fee_trg.unit_cd%TYPE,cp_v_unit_version_number igs_fi_unit_fee_trg.version_number%TYPE) IS
        SELECT  'x'
        FROM igs_ps_unit_ver psv,
             igs_ps_unit_stat stat
        WHERE psv.unit_cd = cp_v_unit_cd
        AND (psv.version_number = cp_v_unit_version_number OR cp_v_unit_version_number IS NULL)
        AND  psv.unit_status = stat.unit_status
        AND  stat.s_unit_status IN ('ACTIVE','PLANNED');

      l_v_chk_version   VARCHAR2(1);

BEGIN

        -- This function will roll all Unit Fee Trigger records underneath a nominated Calendar Instance to
        -- beneath another nominated Calendar Instance. The assumption is being made that the "destination" Calendar Instance
        -- is open and active - it is the responsibility of the calling routine to check for this.
        p_message_name := NULL;
        l_v_alt_code  := NULL;
        -- Process the Unit fee trigger records matching the source calendar instance
        l_b_record_inserted_ind := FALSE;
        l_b_record_exists_ind   := FALSE;

        FOR l_uft_source_rec IN c_uft_source LOOP
            -- Check for the existence of the Unit Fee Trigger record under the destination calendar
            OPEN c_uft_dest(l_uft_source_rec.unit_cd,l_uft_source_rec.sequence_number);
            FETCH c_uft_dest INTO   l_v_unit_cd, l_v_sequence_number, l_d_logical_delete_dt;
            IF (c_uft_dest%FOUND) THEN
               CLOSE c_uft_dest;
               IF l_d_logical_delete_dt IS NULL THEN
                  l_b_record_exists_ind := TRUE;
               END IF;
            ELSE
               CLOSE c_uft_dest;
               l_rowid := NULL;
               BEGIN
                   OPEN cur_chk_version(l_uft_source_rec.unit_cd,l_uft_source_rec.version_number);
                   FETCH cur_chk_version INTO l_v_chk_version;
                   IF cur_chk_version%NOTFOUND THEN
                      CLOSE cur_chk_version;
                      fnd_message.set_name('IGS','IGS_PS_UNITVER_ST_ACTIVEPLANN');
                      igs_ge_msg_stack.add;
                      app_exception.raise_exception;
                   END IF;
                   CLOSE cur_chk_version;

                  igs_fi_unit_fee_trg_pkg.insert_row( x_rowid                      => l_rowid,
                                                      x_fee_cat                    => p_fee_cat,
                                                      x_fee_cal_type               => p_dest_cal_type,
                                                      x_fee_ci_sequence_number     => p_dest_sequence_number,
                                                      x_unit_cd                    => l_uft_source_rec.unit_cd,
                                                      x_sequence_number            => l_uft_source_rec.sequence_number,
                                                      x_fee_type                   => p_fee_type,
                                                      x_version_number             => l_uft_source_rec.version_number,
                                                      x_cal_type                   => l_uft_source_rec.cal_type,
                                                      x_ci_sequence_number         => l_uft_source_rec.ci_sequence_number,
                                                      x_location_cd                => l_uft_source_rec.location_cd,
                                                      x_unit_class                 => l_uft_source_rec.unit_class,
                                                      x_create_dt                  => SYSDATE,
                                                      x_fee_trigger_group_number   => l_uft_source_rec.fee_trigger_group_number,
                                                      x_logical_delete_dt          => NULL,
                                                      x_mode                       => 'R');

                   l_b_record_inserted_ind := TRUE;

                 EXCEPTION
                  WHEN OTHERS THEN
                    IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
                    IF ((l_uft_source_rec.cal_type IS NOT NULL) AND (l_uft_source_rec.ci_sequence_number IS NOT NULL)) THEN
                       OPEN  c_alt_cd(l_uft_source_rec.cal_type,l_uft_source_rec.ci_sequence_number);
                       FETCH c_alt_cd INTO  l_v_alt_code;
                       CLOSE c_alt_cd;
                    END IF;

                     fnd_message.set_name('IGS','IGS_FI_ROLLOVER_UFT_ERROR');
                     fnd_message.set_token('UNIT_CD',l_uft_source_rec.unit_cd);
                     IF (l_uft_source_rec.version_number IS NULL) THEN
                         fnd_message.set_token('VER_NUM',IGS_FI_GEN_GL.GET_LKP_MEANING('IGS_FI_LOCKBOX','NULL_VALUE'));
                     ELSE
                         fnd_message.set_token('VER_NUM',l_uft_source_rec.version_number);
                     END IF;
                     fnd_message.set_token('CAL_TYPE',NVL(l_uft_source_rec.cal_type,IGS_FI_GEN_GL.GET_LKP_MEANING('IGS_FI_LOCKBOX','NULL_VALUE')));
                     fnd_message.set_token('ALT_CODE',NVL(l_v_alt_code,IGS_FI_GEN_GL.GET_LKP_MEANING('IGS_FI_LOCKBOX','NULL_VALUE')));
                     fnd_message.set_token('LOC_CD', NVL(l_uft_source_rec.location_cd,IGS_FI_GEN_GL.GET_LKP_MEANING('IGS_FI_LOCKBOX','NULL_VALUE')));
                     fnd_message.set_token('UNIT_CLASS', NVL(l_uft_source_rec.unit_class,IGS_FI_GEN_GL.GET_LKP_MEANING('IGS_FI_LOCKBOX','NULL_VALUE')));
                     fnd_message.set_token('CR_DATE',l_uft_source_rec.create_dt);
                     fnd_file.put_line (fnd_file.log, fnd_message.get);

               END;

            END IF;
        END LOOP;

        IF (l_b_record_exists_ind = TRUE) THEN
            -- Display message that the Unit Triggers already exist
            fnd_message.set_name('IGS','IGS_FI_UNIT_TRG_EXISTS');
            fnd_file.put_line (fnd_file.log, fnd_message.get);
        END IF;
        IF (l_b_record_inserted_ind = TRUE) THEN
            -- Display message that the Unit Fee Triggers have been successfully rolled over
            fnd_message.set_name('IGS','IGS_FI_UNIT_TRG_ROLLED');
            fnd_file.put_line (fnd_file.log, fnd_message.get);
        END IF;

        RETURN TRUE;

END finp_ins_roll_uft;


FUNCTION finp_ins_roll_usft( p_fee_cat                IN igs_en_unitsetfeetrg.fee_cat%TYPE ,
                            p_source_cal_type        IN igs_ca_inst.cal_type%TYPE ,
                            p_source_sequence_number IN igs_ca_inst.sequence_number%TYPE ,
                            p_dest_cal_type          IN igs_ca_inst.cal_type%TYPE ,
                            p_dest_sequence_number   IN igs_ca_inst.sequence_number%TYPE ,
                            p_fee_type               IN igs_en_unitsetfeetrg.fee_type%TYPE ,
                            p_message_name           OUT NOCOPY fnd_new_messages.message_name%TYPE )  RETURN BOOLEAN AS
/*************************************************************
  Created By      : Priya Athipatla
  Date Created By : 12-Jul-2004
  Purpose         : To rollover Unit Set Fee Triggers
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  sapanigr        14-Jun-2006     Bug 5148913. Unhandled exceptions at insert row caught and appropriate
                                  error message logged.
***************************************************************/
    l_v_unit_set_cd             igs_en_unitsetfeetrg.unit_set_cd%TYPE;
    l_v_version_number          igs_en_unitsetfeetrg.version_number%TYPE;
    l_d_logical_delete_dt       igs_en_unitsetfeetrg.logical_delete_dt%TYPE;
    l_b_record_inserted_ind     BOOLEAN := FALSE;
    l_b_record_exists_ind       BOOLEAN := FALSE;
    l_v_message_name            fnd_new_messages.message_name%TYPE;
    l_rowid                     ROWID := NULL;
    l_d_create_dt               igs_en_unitsetfeetrg.create_dt%TYPE;

     -- Cursor to obtain data from Source Calendar Instance
     CURSOR c_usft_source IS
       SELECT  uft.unit_set_cd,
               uft.version_number,
               uft.fee_trigger_group_number
       FROM    igs_en_unitsetfeetrg  uft
       WHERE   uft.fee_cat                = p_fee_cat
       AND     uft.fee_cal_type           = p_source_cal_type
       AND     uft.fee_ci_sequence_number = p_source_sequence_number
       AND     uft.fee_type               = p_fee_type
       AND     uft.logical_delete_dt IS NULL;

     -- Cursor to check IF data already exists in Destination Calendar Instance
     CURSOR c_usft_dest (cp_unit_set_cd        igs_en_unitsetfeetrg.unit_set_cd%TYPE,
                        cp_version_number     igs_en_unitsetfeetrg.version_number%TYPE) IS
       SELECT  uft.unit_set_cd,
               uft.version_number,
               uft.logical_delete_dt
       FROM    igs_en_unitsetfeetrg  uft
       WHERE   uft.fee_cat                = p_fee_cat
       AND     uft.fee_cal_type           = p_dest_cal_type
       AND     uft.fee_ci_sequence_number = p_dest_sequence_number
       AND     uft.fee_type               = p_fee_type
       AND     uft.unit_set_cd            = cp_unit_set_cd
       AND     uft.version_number         = cp_version_number;

BEGIN

        -- This function will roll all Unit Set Fee Trigger records underneath a nominated Calendar Instance to
        -- beneath another nominated Calendar Instance. The assumption is being made that the "destination" Calendar Instance
        -- is open and active - it is the responsibility of the calling routine to check for this.

        p_message_name := NULL;

        -- Process the Unit fee trigger records matching the source calendar instance
        l_b_record_inserted_ind := FALSE;
        l_b_record_exists_ind   := FALSE;

        FOR l_usft_source_rec IN c_usft_source LOOP
            -- Check for the existence of the Unit Set Fee Trigger record under the destination calendar
            OPEN c_usft_dest(l_usft_source_rec.unit_set_cd,l_usft_source_rec.version_number);
            FETCH c_usft_dest INTO   l_v_unit_set_cd, l_v_version_number, l_d_logical_delete_dt;
            IF (c_usft_dest%FOUND) THEN
               CLOSE c_usft_dest;
               IF l_d_logical_delete_dt IS NULL THEN
                  l_b_record_exists_ind := TRUE;
               END IF;
            ELSE
               CLOSE c_usft_dest;
               l_rowid := NULL;
               l_d_create_dt := SYSDATE;
               BEGIN
                  igs_en_unitsetfeetrg_pkg.insert_row( x_rowid                      => l_rowid,
                                                       x_fee_cat                    => p_fee_cat,
                                                       x_fee_cal_type               => p_dest_cal_type,
                                                       x_fee_ci_sequence_number     => p_dest_sequence_number,
                                                       x_fee_type                   => p_fee_type,
                                                       x_unit_set_cd                => l_usft_source_rec.unit_set_cd,
                                                       x_version_number             => l_usft_source_rec.version_number,
                                                       x_create_dt                  => l_d_create_dt,
                                                       x_fee_trigger_group_number   => l_usft_source_rec.fee_trigger_group_number,
                                                       x_logical_delete_dt          => NULL,
                                                       x_mode                       => 'R');
                    l_b_record_inserted_ind := TRUE;
                EXCEPTION
                   WHEN OTHERS THEN
                        IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
                        fnd_message.set_name('IGS','IGS_FI_ROLLOVER_USFT_ERROR');
                        fnd_message.set_token('FEE_CAT',p_fee_cat);
                        fnd_message.set_token('FEE_TYPE',p_fee_type);
                        fnd_message.set_token('FEE_CAL_TYPE',p_source_cal_type);
                        fnd_message.set_token('ALT_CODE',g_v_alternate_code);
                        fnd_message.set_token('UNIT_SET_CD',l_usft_source_rec.unit_set_cd);
                        fnd_message.set_token('VERSION_NUMBER',l_usft_source_rec.version_number);
                        fnd_file.put_line (fnd_file.log, fnd_message.get);
                END;
            END IF;
        END LOOP;

        IF (l_b_record_exists_ind = TRUE) THEN
            -- Display message that the Unit Set Triggers already exist
            fnd_message.set_name('IGS','IGS_FI_USET_TRG_EXISTS');
            fnd_file.put_line (fnd_file.log, fnd_message.get);
        END IF;
        IF (l_b_record_inserted_ind = TRUE) THEN
            -- Display message that the Unit Set Fee Triggers have been successfully rolled over
            fnd_message.set_name('IGS','IGS_FI_USET_TRG_ROLLED');
            fnd_file.put_line (fnd_file.log, fnd_message.get);
        END IF;
        RETURN TRUE;

END finp_ins_roll_usft;

  PROCEDURE finp_ins_roll_tprs(p_v_fee_type             igs_fi_f_typ_ca_inst.fee_type%TYPE,
                               p_v_source_cal_type      igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                               p_n_source_ci_seq_number igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                               p_v_dest_cal_type        igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                               p_n_dest_ci_seq_number   igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                               p_b_status               OUT NOCOPY BOOLEAN,
                               p_v_message_name         OUT NOCOPY VARCHAR2) AS
  /****************************************************************
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 13-SEP-2004
  ||  Purpose : This procedure will rollover the FTCI+TP retention schedules
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  sapanigr     14-Jun-2006     Bug 5148913. Unhandled exceptions at insert row caught and appropriate
  ||                               error message logged.
  ||  sapanigr     03-May-2006     Enh#3924836 Precision Issue. Amount values being inserted into igs_fi_tp_ret_schd
  ||                               is now rounded off to currency precision
  *****************************************************************/

    -- Cursor for identifying Distinct Teaching Periods
    CURSOR cur_dist_tp(cp_fee_cal_type         igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                       cp_fee_ci_seq_num       igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                       cp_fee_type             igs_fi_f_typ_ca_inst.fee_type%TYPE) IS
      SELECT DISTINCT teach_cal_type,
                      teach_ci_sequence_number
      FROM  igs_fi_tp_ret_schd
      WHERE fee_cal_type = cp_fee_cal_type
      AND   fee_ci_sequence_number = cp_fee_ci_seq_num
      AND   fee_type = cp_fee_type
      AND   (teach_cal_type IS NOT NULL AND teach_ci_sequence_number IS NOT NULL);

    -- Cursor for identifying the Rolled Over Instance of Teaching Period
    CURSOR cur_roll_tp(cp_cal_type             igs_ca_inst.cal_type%TYPE,
                       cp_seq_number           igs_ca_inst.sequence_number%TYPE) IS
      SELECT cal_type,
             sequence_number
      FROM   igs_ca_inst
      WHERE  cal_type = cp_cal_type
      AND    prior_ci_sequence_number = cp_seq_number;

    -- Cursor for identifying the Retention Schedules
    CURSOR cur_ret_schdl(cp_fee_cal_type         igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                         cp_fee_ci_seq_num       igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                         cp_fee_type             igs_fi_f_typ_ca_inst.fee_type%TYPE,
                         cp_teach_cal_type       igs_ca_inst.cal_type%TYPE,
                         cp_teach_seq_num        igs_ca_inst.sequence_number%TYPE) IS
      SELECT *
      FROM igs_fi_tp_ret_schd
      WHERE fee_cal_type  = cp_fee_cal_type
      AND   fee_ci_sequence_number = cp_fee_ci_seq_num
      AND   fee_type = cp_fee_type
      AND   teach_cal_type = cp_teach_cal_type
      AND   teach_ci_sequence_number = cp_teach_seq_num;

    -- Cursor for validating IF the Load calendar Instance has the Rolled Over
    -- Teaching period associated
    CURSOR cur_load_teach(cp_load_cal_type        igs_ca_inst.cal_type%TYPE,
                          cp_load_seq_number      igs_ca_inst.sequence_number%TYPE,
                          cp_teach_cal_type       igs_ca_inst.cal_type%TYPE,
                          cp_teach_seq_number     igs_ca_inst.sequence_number%TYPE) IS
      SELECT 'x'
      FROM igs_ca_load_to_teach_v
      WHERE load_cal_type = cp_load_cal_type
      AND   load_ci_sequence_number = cp_load_seq_number
      AND   teach_cal_type = cp_teach_cal_type
      AND   teach_ci_sequence_number = cp_teach_seq_number;

    -- Cursor for validating IF the Date Alias Instance exists for the Rolled Over
    -- Teaching Period.
    CURSOR cur_dai_exist(cp_dt_alias            igs_ca_da_inst.dt_alias%TYPE,
                         cp_dai_seq_num         igs_ca_da_inst.sequence_number%TYPE,
                         cp_teach_cal_type      igs_ca_da_inst.cal_type%TYPE,
                         cp_teach_seq_num       igs_ca_da_inst.ci_sequence_number%TYPE) IS
      SELECT dt_alias,
             sequence_number
      FROM igs_ca_da_inst
      WHERE cal_type = cp_teach_cal_type
      AND   ci_sequence_number = cp_teach_seq_num
      AND   dt_alias = cp_dt_alias
      AND   sequence_number = cp_dai_seq_num;

    l_rec_roll_tp   cur_roll_tp%ROWTYPE;
    l_var           VARCHAR2(1);

    l_v_load_cal_type        igs_ca_inst.cal_type%TYPE;
    l_n_load_seq_num         igs_ca_inst.sequence_number%TYPE;
    l_b_ret_val              BOOLEAN;
    l_v_message_name         fnd_new_messages.message_name%TYPE;
    l_b_rec_found            BOOLEAN;
    l_n_ret_id               igs_fi_tp_ret_schd.ftci_teach_retention_id%TYPE;
    l_v_rowid                VARCHAR2(25);
    l_b_prc_rollover         BOOLEAN;
    l_rec_dai                cur_dai_exist%ROWTYPE;

    l_rec_ret_schdl          cur_ret_schdl%ROWTYPE;

    l_v_fp_alt_cd            igs_ca_inst.alternate_code%TYPE;
    l_v_dest_teach_alt_cd    igs_ca_inst.alternate_code%TYPE;
    l_v_teach_alt_cd         igs_ca_inst.alternate_code%TYPE;
    l_v_teach_label          igs_lookup_values.meaning%TYPE;

  BEGIN

-- Establish Savepoint for the main procedure
    SAVEPOINT SP_ROLLTP_MAIN;

    p_b_status := TRUE;
    p_v_message_name := NULL;

    l_b_rec_found := FALSE;

-- Get the Load Calendar Instance for the Destination Fee Period passed as Input
    l_b_ret_val := igs_fi_gen_001.finp_get_lfci_reln(p_cal_type                => p_v_dest_cal_type,
                                                     p_ci_sequence_number      => p_n_dest_ci_seq_number,
                                                     p_cal_category            => 'FEE',
                                                     p_ret_cal_type            => l_v_load_cal_type,
                                                     p_ret_ci_sequence_number  => l_n_load_seq_num,
                                                     p_message_name            => l_v_message_name);

-- If the function does not return True, the return the procedure by setting the status
-- to false and the message appropriately
    IF NOT l_b_ret_val THEN
      IF l_v_message_name IS NOT NULL THEN
        p_b_status := FALSE;
        p_v_message_name := l_v_message_name;
        RETURN;
      END IF;
    END IF;

-- Get the label value for the Teaching Period
    l_v_teach_label := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                     'TEACH_CAL_ALT_CD');

-- Get the Alternate Code for the Destination Fee period
    l_v_fp_alt_cd := igs_ca_gen_001.calp_get_alt_cd(p_cal_type        => p_v_dest_cal_type,
                                                    p_sequence_number => p_n_dest_ci_seq_number);

-- Loop across all the distinct Teaching period for the Source FTCI.
-- These teaching periods are selected from the Retention Schedules table IGS_FI_TP_RET_SCHD
    FOR rec_dist_tp IN cur_dist_tp(p_v_source_cal_type,
                                   p_n_source_ci_seq_number,
                                   p_v_fee_type) LOOP
      BEGIN

-- Establish Savepoint
        SAVEPOINT SP_ROLL_TP;
        l_b_rec_found := TRUE;
        l_b_prc_rollover := TRUE;

-- Get the alternate Code for the Teaching Period
        l_v_teach_alt_cd := igs_ca_gen_001.calp_get_alt_cd(p_cal_type        => rec_dist_tp.teach_cal_type,
                                                       p_sequence_number => rec_dist_tp.teach_ci_sequence_number);

-- Log the Teaching Period details in the log file
        fnd_file.new_line(fnd_file.log);
        fnd_file.put_line(fnd_file.log,
                          l_v_teach_label||':'||l_v_teach_alt_cd);

-- Validation for the Rolled Over Instance of the Teaching Period.
        OPEN cur_roll_tp(rec_dist_tp.teach_cal_type,
                         rec_dist_tp.teach_ci_sequence_number);
        FETCH cur_roll_tp INTO l_rec_roll_tp;
        IF cur_roll_tp%NOTFOUND THEN
          l_b_prc_rollover := FALSE;
          fnd_message.set_name('IGS',
                               'IGS_FI_TPRS_NO_TP_ROLL');
          fnd_message.set_token('ALT_CD',
                                l_v_teach_alt_cd);
          fnd_file.put_line(fnd_file.log,
                            fnd_message.get);
        END IF;
        CLOSE cur_roll_tp;

        IF l_b_prc_rollover THEN

-- Validation for the Teaching Period retention schedule already been rolled over
          OPEN cur_ret_schdl(p_v_dest_cal_type,
                             p_n_dest_ci_seq_number,
                             p_v_fee_type,
                             l_rec_roll_tp.cal_type,
                             l_rec_roll_tp.sequence_number);
          FETCH cur_ret_schdl INTO l_rec_ret_schdl;
          IF cur_ret_schdl%FOUND THEN
            l_b_prc_rollover := FALSE;
            fnd_message.set_name('IGS',
                                 'IGS_FI_TP_RET_SCHD_ROLLED');
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;
          CLOSE cur_ret_schdl;
        END IF;

        IF l_b_prc_rollover THEN

-- Validation for the Rolled Over teaching Period associated to the Load Period of
-- the Destination Fee Period
          OPEN cur_load_teach(l_v_load_cal_type,
                              l_n_load_seq_num,
                              l_rec_roll_tp.cal_type,
                              l_rec_roll_tp.sequence_number);
          FETCH cur_load_teach INTO l_var;
          IF cur_load_teach%NOTFOUND THEN
            l_b_prc_rollover := FALSE;
            l_v_dest_teach_alt_cd := igs_ca_gen_001.calp_get_alt_cd(l_rec_roll_tp.cal_type,
                                                                    l_rec_roll_tp.sequence_number);
            fnd_message.set_name('IGS',
                                 'IGS_FI_TPRS_NO_TP_FTCI_REL');
            fnd_message.set_token('ALT_CD',
                                  l_v_teach_alt_cd);
            fnd_message.set_token('TEACH_ALT_CD',
                                  l_v_dest_teach_alt_cd);
            fnd_message.set_token('FEE_ALT_CD',
                                  l_v_fp_alt_cd);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;
          CLOSE cur_load_teach;
        END IF;

        IF l_b_prc_rollover THEN

-- Loop across the Retention Schedules defined for the Source FTCI and the
-- teaching period in context

          FOR rec_ret_schd IN cur_ret_schdl(p_v_source_cal_type,
                                            p_n_source_ci_seq_number,
                                            p_v_fee_type,
                                            rec_dist_tp.teach_cal_type,
                                            rec_dist_tp.teach_ci_sequence_number) LOOP

-- Check IF the Rolled Over Date Alias exists with the Rolled Over Teaching Period
            OPEN cur_dai_exist(rec_ret_schd.dt_alias,
                               rec_ret_schd.dai_sequence_number,
                               l_rec_roll_tp.cal_type,
                               l_rec_roll_tp.sequence_number);
            FETCH cur_dai_exist INTO l_rec_dai;
            IF cur_dai_exist%NOTFOUND THEN
              CLOSE cur_dai_exist;
              l_b_prc_rollover := FALSE;
              fnd_message.set_name('IGS',
                                   'IGS_FI_TPRS_NO_DT_ALIAS_ROLL');
              fnd_message.set_token('ALT_CD',
                                    l_v_teach_alt_cd);
              fnd_message.set_token('DATE_ALIAS',
                                    rec_ret_schd.dt_alias);
              fnd_file.put_line(fnd_file.log,
                                fnd_message.get);
              EXIT;
            END IF;
            CLOSE cur_dai_exist;

-- Insert the record for the New Teaching Period.
-- Added call to format ret_amount by rounding off to currency precision
            IF l_b_prc_rollover THEN
              l_v_rowid := null;
              l_n_ret_id := null;
              igs_fi_tp_ret_schd_pkg.insert_row(x_rowid                     => l_v_rowid,
                                                x_ftci_teach_retention_id   => l_n_ret_id,
                                                x_teach_cal_type            => l_rec_roll_tp.cal_type,
                                                x_teach_ci_sequence_number  => l_rec_roll_tp.sequence_number,
                                                x_fee_cal_type              => p_v_dest_cal_type,
                                                x_fee_ci_sequence_number    => p_n_dest_ci_seq_number,
                                                x_fee_type                  => p_v_fee_type,
                                                x_dt_alias                  => l_rec_dai.dt_alias,
                                                x_dai_sequence_number       => l_rec_dai.sequence_number,
                                                x_ret_percentage            => rec_ret_schd.ret_percentage,
                                                x_ret_amount                => igs_fi_gen_gl.get_formatted_amount(rec_ret_schd.ret_amount));
            END IF;

          END LOOP;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO SP_ROLL_TP;
          l_b_prc_rollover := FALSE;
          IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
          fnd_message.set_name('IGS','IGS_FI_ROLLOVER_TPRS_ERROR');
          fnd_message.set_token('FEE_TYPE',p_v_fee_type);
          fnd_message.set_token('FEE_CAL_TYPE',p_v_source_cal_type);
          fnd_message.set_token('ALT_CODE',g_v_alternate_code);
          fnd_message.set_token('TEACH_CAL_TYPE',rec_dist_tp.teach_cal_type);
          fnd_message.set_token('TEACH_CI_ALT_CODE',l_v_teach_alt_cd);
          fnd_message.set_token('DT_ALIAS',l_rec_dai.dt_alias);
          fnd_file.put_line (fnd_file.log, fnd_message.get);
      END;


-- If the Rollover validations have failed, then set
-- the status to False else log the success message in the log file
      IF l_b_prc_rollover THEN
        fnd_message.set_name('IGS',
                             'IGS_FI_ROLL_TP_FTCI');
        fnd_file.put_line(fnd_file.log,
                          fnd_message.get);
      END IF;
    END LOOP;


-- If no records were found, then return from the procedure
-- with status as False and no record found message.
    IF NOT l_b_rec_found THEN
      p_v_message_name := 'IGS_FI_TPRS_NO_REC_FOUND';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO SP_ROLLTP_MAIN;
      p_b_status := FALSE;
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get_string('IGS',
                                               'IGS_GE_UNHANDLED_EXCEPTION')||':'||sqlerrm);
  END finp_ins_roll_tprs;

END igs_fi_prc_fee_rollv;

/
