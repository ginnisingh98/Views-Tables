--------------------------------------------------------
--  DDL for Package Body IGS_FI_FEE_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_FEE_TYPE_PKG" AS
 /* $Header: IGSSI37B.pls 120.3 2005/09/22 05:43:39 appldev ship $*/


  l_rowid VARCHAR2(25);
  old_references IGS_FI_FEE_TYPE_ALL%RowType;
  new_references IGS_FI_FEE_TYPE_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_fee_type IN VARCHAR2 ,
    x_s_fee_type IN VARCHAR2 ,
    x_s_fee_trigger_cat IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
    x_optional_payment_ind IN VARCHAR2 ,
    x_closed_ind IN VARCHAR2 ,
    x_comments IN VARCHAR2 ,
    x_org_id IN NUMBER ,
    x_fee_class IN VARCHAR2 ,     --Bug 2175865
    x_designated_payment_flag IN VARCHAR2,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS
/*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  shtatiko        30-MAY-2003     Enh# 2831582, Added new column designated_payment_flag
  ||  smvk         02-Sep-2002        Removed the Default value in the parameters to overcome File.Pkg.22 gscc warnings.
  ||                                  As a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
  ----------------------------------------------------------------------------*/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_FEE_TYPE_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.

    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.fee_type := x_fee_type;
    new_references.s_fee_type := x_s_fee_type;
    new_references.s_fee_trigger_cat := x_s_fee_trigger_cat;
    new_references.description := x_description;
    new_references.optional_payment_ind := x_optional_payment_ind;
    new_references.closed_ind := x_closed_ind;
    new_references.comments := x_comments;
    new_references.org_id := x_org_id;
    new_references.fee_class := x_fee_class;               --Bug 2175865
    new_references.designated_payment_flag := x_designated_payment_flag;
    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;

  END Set_Column_Values;

  -- Trigger description :-

  -- "OSS_TST".trg_ft_br_iud

  -- BEFORE INSERT OR DELETE OR UPDATE

  -- ON IGS_FI_FEE_TYPE_ALL

  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN

    ) AS
  /*---------------------------------------------------------------------------
   CHANGE HISTORY:
   WHO        WHEN           WHAT
   svuppala   09-SEP-2005  Bug#3286824 Modify cursors cur_docactiveft_count and c_ft to have one cursor c_act_ft
                           Made check for DOCUMENT and REFUND once.
   vvutukur   03-Dec-2003  Bug#3249288.Modified cursor cur_optfeeflag_set to remove additional condition
                           on optional_fee_flag.
   uudayapr   15-oct-2003  Enh #3117341 Modified by adding the token to IGS_FI_ANC_TRG_CAT message
   smvk       02-Sep-2002  Removed the Default value in the parameters to overcome File.Pkg.22 gscc warnings.
                           As a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
   vvutukur   24-Jun-2002  Added cursor cur_docactiveft_count and related validation
                           to throw error message if user tries to save two active fee type
                           records with system fee type 'DOCUMENT'.
   smvk       13-Mar-2002    checking System Fee Trigger Category as INSTITUTN and
                            and only one active fee type having system fee type as
                            Refunds for a subaccount w.r.t Bug # 2144600
  ----------------------------------------------------------------------------*/

  CURSOR cur_optfeeflag_set(p_fee_type varchar2) is
         SELECT 'x'
         FROM igs_fi_inv_int
         WHERE fee_type = p_fee_type;

 ---cursor to get the number of active fee types of system fee type 'DOCUMENT' and 'REFUND' system fee type
  CURSOR cur_act_ft(cp_s_fee_type IN igs_fi_fee_type.s_fee_type%TYPE,
                    cp_fee_type IN igs_fi_fee_type.fee_type%TYPE) IS
   SELECT count('x')
   FROM   igs_fi_fee_type
   WHERE  s_fee_type = cp_s_fee_type
   AND    fee_type <> cp_fee_type
   AND    closed_ind='N';


  -- Added for Refunds Build Enh BugNo:2144600
  l_count                        NUMBER;
  l_optfeeflag cur_optfeeflag_set%rowtype;
  v_message_name varchar2(30);

  l_desc igs_lookup_values.meaning%TYPE;

  BEGIN
-- Validate Fee Type system trigger category

        IF (p_updating AND (old_references.s_fee_trigger_cat) <>
                        (new_references.s_fee_trigger_cat) ) THEN
                IF IGS_FI_VAL_FT.finp_val_ft_trig (
                                new_references.fee_type,
                                new_references.s_fee_trigger_cat,
                                old_references.s_fee_trigger_cat,
                                v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
                IF IGS_FI_VAL_FT.finp_val_ft_sftc (
                                new_references.fee_type,
                                new_references.s_fee_trigger_cat,
                                old_references.s_fee_trigger_cat,
                                v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
        END IF;

        -- Validate Fee Type system fee type and system trigger category
        IF (p_inserting OR (p_updating AND
                (((old_references.s_fee_type) <> (new_references.s_fee_type))  OR
                ((old_references.s_fee_trigger_cat) <> (new_references.s_fee_trigger_cat))))) THEN
                IF IGS_FI_VAL_FT.finp_val_ft_sft_trig (
                                new_references.s_fee_type,
                                new_references.s_fee_trigger_cat,
                                v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
        END IF;

        -- Validate Fee Type optional payment indicator

        IF (p_updating AND (old_references.optional_payment_ind) <>
                        (new_references.optional_payment_ind) ) THEN
                IF IGS_FI_VAL_FT.finp_val_ft_opt_pymt (
                                new_references.fee_type,
                                new_references.optional_payment_ind,
                                v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
/*  Bug- 1989694, SF012_DLD-Account History and Payment
    When Optional_Fee_Flag column in IGS_INV_INT_ALL Table is set then error out NOCOPY
    that Optional_Payment_ind cannot be changed */

          Open cur_optfeeflag_set(new_references.fee_type);
          fetch cur_optfeeflag_set into l_optfeeflag;
          IF cur_optfeeflag_set%FOUND THEN
             CLOSE cur_optfeeflag_set;
             Fnd_Message.Set_Name('IGS','IGS_FI_CANT_MODIFY_OPT_IND');
             IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
          CLOSE cur_optfeeflag_set;
        END IF;

--Throw error in case if more than one active fee types can exist with system fee type as 'DOCUMENT' or 'REFUND'.
  IF (p_inserting OR (p_updating AND old_references.closed_ind <> new_references.closed_ind)) THEN

    IF new_references.s_fee_type IN ('DOCUMENT','REFUND') AND
       new_references.closed_ind='N' THEN

      OPEN cur_act_ft(cp_s_fee_type => new_references.s_fee_type,
                      cp_fee_type => new_references.fee_type);
      FETCH cur_act_ft INTO l_count;
      CLOSE cur_act_ft;

      IF NVL(l_count,0) >= 1 THEN
         --If system fee type is of Refund
         IF new_references.s_fee_type = 'REFUND' THEN
           fnd_message.set_name('IGS','IGS_FI_REFUND_FEE');
         --If system fee type is of Document
         ELSIF new_references.s_fee_type = 'DOCUMENT' THEN
           fnd_message.set_name('IGS','IGS_FI_DOC_TYP_NOT_MORE_ONE');
         END IF;
         igs_ge_msg_stack.add;
         app_exception.raise_exception;
      END IF;
    END IF;
  END IF;

    -- Checking for System Fee Type Refund to have System Fee Trigger Category as 'INSTITUTN' only
    IF p_inserting OR p_updating THEN
      IF new_references.s_fee_type = 'REFUND' THEN
        IF new_references.s_fee_trigger_cat <> 'INSTITUTN' THEN
           --got the lookup meaning and added token to the
           --message IGS_FI_ANC_TRG_CAT.
           fnd_Message.Set_Name('IGS','IGS_FI_ANC_TRG_CAT');
           fnd_message.set_token('S_FEE_TRIG_CAT', igs_fi_gen_gl.get_lkp_meaning(p_v_lookup_type => 'IGS_FI_LOCKBOX',
                                                                                 p_v_lookup_code => 'INSTITUTION'));
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;
    END IF;


  END BeforeRowInsertUpdateDelete1;

  PROCEDURE BeforeRowInsertUpdate2(
                                 p_inserting IN BOOLEAN ,
                                 p_updating  IN BOOLEAN ,
                                 p_deleteing IN BOOLEAN
                                 )AS

  --HISTORY
  --Who        When          What
  --smvk       02-Sep-200    Removed the Default value in the parameters to overcome File.Pkg.22 gscc warnings.
  --                         As a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
  --vvutukur   15-Jul-2002   Removed cursor cur_ft and related code as multiple fee classes can be attached to the
  --                         single subaccount that exists in the system,for bug#2432134.
  --vvutukur   15-1-2002     created the procedure for Bug 2175865


  --Cursor to check if the fee type has been used for creation of charge.
    CURSOR cur_ft_chrg(
                       cp_new_fee_type VARCHAR2
                      ) IS
      SELECT 'x'
      FROM   igs_fi_inv_int
      WHERE  fee_type = cp_new_fee_type;

    l_var   VARCHAR2(1);
    BEGIN

      --Validate if the fee type has been used for creation of a charge
      IF(p_updating) THEN
        --Validations if the fee type has been used for creation of a charge if fee class is modified.
        IF (NVL(new_references.fee_class,'NULL') <> NVL(old_references.fee_class,'NULL')) THEN
          OPEN cur_ft_chrg(new_references.fee_type);
          FETCH cur_ft_chrg INTO l_var;
          IF(cur_ft_chrg%FOUND) THEN
            CLOSE cur_ft_chrg;
            FND_MESSAGE.SET_NAME('IGS','IGS_FI_FEE_CLASS_USED');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;
          CLOSE cur_ft_chrg;
        END IF;
      END IF;

  END BeforeRowInsertUpdate2;

  -- Trigger description :-
  -- "OSS_TST".trg_ft_ar_u_hist
  -- AFTER UPDATE
  -- ON IGS_FI_FEE_TYPE_ALL
  -- FOR EACH ROW

  PROCEDURE AfterRowUpdate2(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
/*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  shtatiko        30-MAY-2003     Enh# 2831582, Added new column designated_payment_flag
  ||  smvk         02-Sep-2002        Removed the Default value in the parameters to overcome File.Pkg.22 gscc warnings.
  ||                                  As a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
  ----------------------------------------------------------------------------*/

  BEGIN
        -- create a history

        IGS_FI_GEN_002.FINP_INS_FT_HIST(old_references.fee_type,
                new_references.s_fee_type,
                old_references.s_fee_type,
                new_references.s_fee_trigger_cat,
                old_references.s_fee_trigger_cat,
                new_references.description,
                old_references.description,
                new_references.optional_payment_ind,
                old_references.optional_payment_ind,
                new_references.closed_ind,
                old_references.closed_ind,
                new_references.fee_class,
                old_references.fee_class,
                new_references.designated_payment_flag,
                old_references.designated_payment_flag,
                new_references.last_updated_by,
                old_references.last_updated_by,
                new_references.last_update_date,
                old_references.last_update_date,
                new_references.comments,
                old_references.comments);

  END AfterRowUpdate2;

   PROCEDURE Check_Constraints (
   Column_Name                IN        VARCHAR2,
   Column_Value         IN        VARCHAR2
   )AS
  /*---------------------------------------------------------------------------
   CHANGE HISTORY:
   WHO        WHEN           WHAT
   pmarada     28-jul-2005   Enh 3392095, added waiver_adj to the system fee type validation
   uudayapr   15-oct-2003   Enh# 3117341.Audit and special fees build added AUDIT,SPECIAL in
                                the list of valid values of system fee type and system fee trigger category.
   vvutukur   06-Sep-2003   Enh#3045007.Payment Plans Build. Added PAY_PLAN also in the list
                            of valid system fee types.
   shtatiko   02-JUN-2003   Enh# 2831582, Added check for new column designated_payment_flag.
   vvutukur   13-may-2002   removed upper case check on fee_type column.bug#2344826.
   agairola   22-Mar-2002   Added the validation for System Fee Types LATE, FINANCE, REFUND, DOCUMENT,
                            AID_ADJ to have the Optional Payment Indicator as Y
   smvk       13-Mar-2002   Added REFUND as valid System fee Type, checking SFTC as INSTITUTN and
                            and only one active fee type having system fee type for a subaccount
                            w.r.t Bug # 2144600
   vvutukur   21-feb-2002    removed comments part for bug:2107967.
  ----------------------------------------------------------------------------*/
   BEGIN
   IF Column_Name is NULL THEN
             NULL;
     ELSIF upper(Column_Name) = 'S_FEE_TYPE' then
             new_references.s_fee_type := Column_Value;
     ELSIF upper(Column_Name) = 'OPTIONAL_PAYMENT_IND' then
             new_references.optional_payment_ind := Column_Value;
     ELSIF upper(Column_Name) = 'CLOSED_IND' then
             new_references.closed_ind := Column_Value;
     ELSIF upper(Column_Name) = 'DESCRIPTION' then
             new_references.description:= Column_Value;
     ELSIF upper(Column_Name) = 'OPTIONAL_PAYMENT_IND' then
             new_references.optional_payment_ind := Column_Value;
     ELSIF upper(Column_Name) = 'S_FEE_TRIGGER_CAT' then
             new_references.s_fee_trigger_cat := Column_Value;
     ELSIF UPPER(column_name) = 'DESIGNATED_PAYMENT_FLAG' THEN
       new_references.designated_payment_flag := column_value;
  END IF;

  -- As part of the enhancement bug #1715208 new_references.s_fee_type  <> 'ANCILLARY' was also added in the
  -- And condition of the IF statement.Thus making ANCILLARY a valid System fee type.
  -- 'REFUND' is also added  as per the Enhancement Bug no: 2144600

          IF upper(Column_Name) = 'S_FEE_TYPE' OR
                             column_name is NULL THEN
                            IF new_references.s_fee_type <> 'HECS' AND
                             new_references.s_fee_type <> 'TUITION' AND
                             new_references.s_fee_type <> 'OTHER' AND
                           new_references.s_fee_type <> 'TUTNFEE' AND
                           new_references.s_fee_type  <> 'EXTERNAL' AND
                           new_references.s_fee_type  <> 'LATE' AND
                           new_references.s_fee_type  <> 'INTEREST' AND
                           new_references.s_fee_type  <> 'ANCILLARY' AND
                           new_references.s_fee_type  <> 'DOCUMENT' AND  -- add by kkillams w.r.t. bug no:2212964
                           new_references.s_fee_type  <> 'REFUND' AND         -- added w.r.t. Bug No: 2144600
                           new_references.s_fee_type  <> 'SPONSOR' AND
                           new_references.s_fee_type  <> 'AID_ADJ' AND
                           new_references.s_fee_type  <> 'PAY_PLAN' AND
                           new_references.s_fee_type  <> 'AUDIT' AND
                           new_references.s_fee_type  <> 'SPECIAL' AND
                           new_references.s_fee_type  <> 'WAIVER_ADJ' THEN
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                            END IF;
        END IF;
  IF (upper(Column_Name) = 'OPTIONAL_PAYMENT_IND' OR
     column_name is NULL) THEN
                     IF new_references.optional_payment_ind <> 'Y' AND
                           new_references.optional_payment_ind <> 'N'
                           THEN
                                     Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                     App_Exception.Raise_Exception;
                     END IF;
  END IF;
  IF (upper(Column_Name) = 'CLOSED_IND' OR
     column_name is NULL) THEN
         IF(new_references.closed_ind <> 'Y' AND
           new_references.closed_ind <> 'N') THEN
            Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
             END IF;
  END IF;
  IF (upper(Column_Name) = 'S_FEE_TRIGGER_CAT' OR
      column_name is NULL) THEN
      IF new_references.s_fee_trigger_cat <> 'INSTITUTN' AND
         new_references.s_fee_trigger_cat <> 'COURSE' AND
         new_references.s_fee_trigger_cat <> 'UNIT' AND
         new_references.s_fee_trigger_cat <> 'COMPOSITE' AND
         new_references.s_fee_trigger_cat <> 'UNITSET' AND
         new_references.s_fee_trigger_cat <> 'AUDIT' AND
         new_references.s_fee_trigger_cat <> 'SPECIAL' THEN

           Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
      END IF;
  END IF;

-- If the Optional Payment Indicator is set for Refunds,Finance, Late Charges etc. System Fee Types
-- then raise error
  IF (upper(Column_Name) = 'OPTIONAL_PAYMENT_IND' OR
      column_name IS NULL) THEN
    IF new_references.optional_payment_ind = 'Y' THEN
      IF new_references.s_fee_type IN ('REFUND',
                                       'LATE',
                                       'INTEREST',
                                       'SPONSOR',
                                       'AID_ADJ',
                                       'DOCUMENT') THEN
        fnd_message.set_name('IGS',
                             'IGS_FI_CANNOT_SET_OPT');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
  END IF;

  IF ( UPPER(column_name) = 'DESIGNATED_PAYMENT_FLAG'
       OR column_name is NULL) THEN
    IF( new_references.designated_payment_flag <> 'Y'
        AND new_references.designated_payment_flag <> 'N' ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
  END IF;

END Check_Constraints;


--created procedure as part of Bug 2175865
PROCEDURE check_parent_existance AS

--HISTORY
--Created by :  vvutukur
--Purpose    :  for Bug 2175865
--Who         When           What
--

  BEGIN

    --  Check for parent existance of fee class
    IF ((old_references.fee_class = new_references.fee_class)
        OR (new_references.fee_class IS NULL)) THEN
      NULL;
    ELSE
      IF NOT igs_lookups_view_pkg.get_pk_for_validation('FEE_CLASS',
                                                        new_references.fee_class) THEN
        FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
END check_parent_existance;


FUNCTION get_pk_for_validation (
    x_fee_type IN VARCHAR2
    ) RETURN BOOLEAN AS
  ------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --pathipat    11-Feb-2003     Enh 2747325 - Locking Issues build
  --                            Removed FOR UPDATE NOWAIT clause in cur_rowid
  -------------------------------------------------------------------
  CURSOR cur_rowid IS
   SELECT   rowid
   FROM     igs_fi_fee_type_all
   WHERE    fee_type = x_fee_type ;

  lv_rowid cur_rowid%ROWTYPE;

  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
       CLOSE cur_rowid;
       RETURN(TRUE);
    ELSE
       CLOSE cur_rowid;
       RETURN(FALSE);
    END IF;
END get_pk_for_validation;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2,
    x_fee_type IN VARCHAR2,
    x_s_fee_type IN VARCHAR2,
    x_s_fee_trigger_cat IN VARCHAR2,
    x_description IN VARCHAR2,
    x_optional_payment_ind IN VARCHAR2,
    x_closed_ind IN VARCHAR2,
    x_comments IN VARCHAR2,
    x_org_id IN NUMBER,
    x_fee_class  IN VARCHAR2,       --Bug 2175865
    x_designated_payment_flag IN VARCHAR2,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER
  ) AS
  ------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --shtatiko    30-MAY-2003     Enh# 2831582, Added new column designated_payment_flag
  --pathipat    11-Feb-2003     Enh 2747325 - Locking Issues build
  --                            Removed code for p_action = 'DELETE' and
  --                            'VALIDATE_DELETE'
  -------------------------------------------------------------------

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_fee_type,
      x_s_fee_type,
      x_s_fee_trigger_cat,
      x_description,
      x_optional_payment_ind,
      x_closed_ind,
      x_comments,
      x_org_id,
      x_fee_class,          --Bug 2175865
      x_designated_payment_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE, p_updating =>FALSE , p_deleting =>FALSE);
      IF Get_PK_For_Validation ( new_references.fee_type )THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;

      --by vvutukur for Bug 2175865

      BeforeRowInsertUpdate2 ( p_inserting => TRUE, p_updating => FALSE, p_deleteing =>FALSE);
      Check_Constraints;
      check_parent_existance;           --Bug 2175865
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE, p_updating => TRUE , p_deleting =>FALSE);

      --by vvutukur for Bug 2175865
      BeforeRowInsertUpdate2 ( p_inserting => FALSE, p_updating => TRUE, p_deleteing =>FALSE);

      Check_Constraints;
      check_parent_existance;           --Bug 2175865
   ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation ( new_references.fee_type ) THEN
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

  BEGIN



    l_rowid := x_rowid;

    IF (p_action = 'UPDATE') THEN

      -- Call all the procedures related to After Update.

      AfterRowUpdate2 (p_inserting => FALSE, p_updating => TRUE, p_deleting => FALSE);
    END IF;
  END After_DML;


-- shtatiko        30-MAY-2003     Enh# 2831582, Added new column designated_payment_flag
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_S_FEE_TYPE in VARCHAR2,
  X_S_FEE_TRIGGER_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OPTIONAL_PAYMENT_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_FEE_CLASS  in VARCHAR2,       --Bug 2175865
  X_DESIGNATED_PAYMENT_FLAG IN VARCHAR2
  ) AS
    cursor C is select ROWID from IGS_FI_FEE_TYPE_ALL
      where FEE_TYPE = X_FEE_TYPE;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if (X_MODE = 'I') then
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
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;



 Before_DML(
  p_action=>'INSERT',
  x_rowid=>X_ROWID,
  x_closed_ind=>NVL(X_CLOSED_IND,'N'),
  x_comments=>X_COMMENTS,
  x_description=>X_DESCRIPTION,
  x_fee_type=>X_FEE_TYPE,
  x_optional_payment_ind=>NVL(X_OPTIONAL_PAYMENT_IND,'N'),
  x_s_fee_trigger_cat=>NVL(X_S_FEE_TRIGGER_CAT,'INSTITUTN'),
  x_s_fee_type=>NVL(X_S_FEE_TYPE,'OTHER'),
  x_org_id => igs_ge_gen_003.get_org_id,
  x_fee_class => X_FEE_CLASS,            --Bug 2175865
  x_designated_payment_flag => x_designated_payment_flag,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
);

  insert into IGS_FI_FEE_TYPE_ALL (
    FEE_TYPE,
    S_FEE_TYPE,
    S_FEE_TRIGGER_CAT,
    DESCRIPTION,
    OPTIONAL_PAYMENT_IND,
    CLOSED_IND,
    COMMENTS,
    ORG_ID,
    FEE_CLASS,            --Bug 2175865
    DESIGNATED_PAYMENT_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.FEE_TYPE,
    NEW_REFERENCES.S_FEE_TYPE,
    NEW_REFERENCES.S_FEE_TRIGGER_CAT,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.OPTIONAL_PAYMENT_IND,
    NEW_REFERENCES.CLOSED_IND,
    NEW_REFERENCES.COMMENTS,
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.FEE_CLASS,         --Bug 2175865
    NEW_REFERENCES.DESIGNATED_PAYMENT_FLAG,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

-- shtatiko        30-MAY-2003     Enh# 2831582, Added new column designated_payment_flag
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_S_FEE_TYPE in VARCHAR2,
  X_S_FEE_TRIGGER_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OPTIONAL_PAYMENT_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_FEE_CLASS  IN VARCHAR2,  --Bug 2175865
  X_DESIGNATED_PAYMENT_FLAG IN VARCHAR2
) AS
  cursor c1 is select
      S_FEE_TYPE,
      S_FEE_TRIGGER_CAT,
      DESCRIPTION,
      OPTIONAL_PAYMENT_IND,
      CLOSED_IND,
      COMMENTS,
      FEE_CLASS,                    --Bug 2175865
      designated_payment_flag
    from IGS_FI_FEE_TYPE_ALL
    where ROWID = X_ROWID
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

  if ( (tlinfo.S_FEE_TYPE = X_S_FEE_TYPE)
      AND (tlinfo.S_FEE_TRIGGER_CAT = X_S_FEE_TRIGGER_CAT)
      AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND (tlinfo.OPTIONAL_PAYMENT_IND = X_OPTIONAL_PAYMENT_IND)
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
     -- BUG 2175865 by vvutukur
      AND ((tlinfo.FEE_CLASS = X_FEE_CLASS)
          OR ((tlinfo.FEE_CLASS IS NULL) AND (X_FEE_CLASS IS NULL)))
      AND ((tlinfo.DESIGNATED_PAYMENT_FLAG = X_DESIGNATED_PAYMENT_FLAG)
          OR ((tlinfo.DESIGNATED_PAYMENT_FLAG IS NULL) AND (X_DESIGNATED_PAYMENT_FLAG IS NULL)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

-- shtatiko        30-MAY-2003     Enh# 2831582, Added new column designated_payment_flag
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_S_FEE_TYPE in VARCHAR2,
  X_S_FEE_TRIGGER_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OPTIONAL_PAYMENT_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2,
  X_FEE_CLASS in VARCHAR2,        --Bug 2175865
  X_DESIGNATED_PAYMENT_FLAG IN VARCHAR2
  ) is
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
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
  else
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;



 Before_DML(
  p_action=>'UPDATE',
  x_rowid=>X_ROWID,
  x_closed_ind=>X_CLOSED_IND,
  x_comments=>X_COMMENTS,
  x_description=>X_DESCRIPTION,
  x_fee_type=>X_FEE_TYPE,
  x_optional_payment_ind=>X_OPTIONAL_PAYMENT_IND,
  x_s_fee_trigger_cat=>X_S_FEE_TRIGGER_CAT,
  x_s_fee_type=>X_S_FEE_TYPE,
  x_fee_class => X_FEE_CLASS,             --Bug 2175865
  x_designated_payment_flag => x_designated_payment_flag,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
);


  update IGS_FI_FEE_TYPE_ALL set
    S_FEE_TYPE = NEW_REFERENCES.S_FEE_TYPE,
    S_FEE_TRIGGER_CAT = NEW_REFERENCES.S_FEE_TRIGGER_CAT,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    OPTIONAL_PAYMENT_IND = NEW_REFERENCES.OPTIONAL_PAYMENT_IND,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    FEE_CLASS = NEW_REFERENCES.FEE_CLASS,           --Bug 2175865
    designated_payment_flag = new_references.designated_payment_flag,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;



After_DML (
 p_action => 'UPDATE',
 x_rowid => X_ROWID
);
END update_row;

-- shtatiko        30-MAY-2003     Enh# 2831582, Added new column designated_payment_flag
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_S_FEE_TYPE in VARCHAR2,
  X_S_FEE_TRIGGER_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OPTIONAL_PAYMENT_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_FEE_CLASS in VARCHAR2,         --Bug 2175865
  X_DESIGNATED_PAYMENT_FLAG IN VARCHAR2
  ) AS
  CURSOR c1 is SELECT rowid FROM igs_fi_fee_type_all
     WHERE FEE_TYPE = X_FEE_TYPE
  ;
begin
  OPEN c1;
  FETCH c1 INTO X_ROWID;
  IF (c1%NOTFOUND) THEN
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_FEE_TYPE,
     X_S_FEE_TYPE,
     X_S_FEE_TRIGGER_CAT,
     X_DESCRIPTION,
     X_OPTIONAL_PAYMENT_IND,
     X_CLOSED_IND,
     X_COMMENTS,
     X_MODE,
     X_ORG_ID,
     X_FEE_CLASS,       --Bug 2175865
     X_DESIGNATED_PAYMENT_FLAG );
    RETURN;
  END IF;
  CLOSE c1;
  UPDATE_ROW (
  X_ROWID,
   X_FEE_TYPE,
   X_S_FEE_TYPE,
   X_S_FEE_TRIGGER_CAT,
   X_DESCRIPTION,
   X_OPTIONAL_PAYMENT_IND,
   X_CLOSED_IND,
   X_COMMENTS,
   X_MODE,
   X_FEE_CLASS,      --Bug 2175865
   X_DESIGNATED_PAYMENT_FLAG );
END add_row;


END igs_fi_fee_type_pkg;

/
