--------------------------------------------------------
--  DDL for Package Body IGF_DB_SF_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_DB_SF_INTEGRATION" AS
/* $Header: IGFDB06B.pls 120.10 2006/08/10 16:56:36 museshad ship $ */
  ------------------------------------------------------------------
  --Created by  :Sarakshi , Oracle IDC
  --Date created:24-Dec-2001
  --
  --Purpose: Package Body contains code for procedures/Functions defined in
  --         package specification . Also body includes Functions/Procedures
  --         private to it .
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --museshad    10-Aug-2006     Bug 5337555. Build FA 163. TBH Impact.
  --svuppala    12-May-2006      Bug 5217319 Added call to format amount by rounding off to currency precision
  --                            in the igf_aw_awd_disb_pkg.update_row (l_disb_paid_amt), igf_aw_award_pkg.update_row
  --                            (l_paid_amt) calls in main_disbursement procedure
  --pmarada     26-JUL-2005     Enh 3392095, modifed as per tution waiver build, passing p_api_version
  --                            parameter value as 2.1 to the igs_fi_credit_pvt.create_credit call
  --svuppala    18-JUL-2005     Enh 4213629 - Impact of automatic generation of the Receipt Number
  --                            changed parameters of igs_fi_credit_pvt.create_credit call
  --ridas       08-Nov-2004     Bug 3021287 If the profile_value = 'TRANSFER'
  --                            then updating COA at the student level

  --ayedubat    14-OCT-04       FA 149 COD-XML Standards build bug # 3416863
  --                            Changed the TBH calls of the packages: IGF_AW_AWD_DISB_PKG and IGF_DB_AWD_DISB_DTL_PKG
  --smadathi    01-JUL-2004     Bug 3735396. GSCC Warning File.Sql.35 was also fixed as part of this bug.
  --                            The variable g_chgadj global to this package body is modified as CONSTANT
  --                            variable. Modified procedure transfer_disb_dtls_to_sf,function validate_persid_grp,
  --                            procedure  main_disbursement
  --pathipat    22-Apr-2004     Enh 3558549 - Commercial Receivables Enhancements build
  --                            Modified call_credits_api() and main_disbursement()
  --veramach    3-NOV-2003      FA 125 Multiple Distr Methods
  --                            Changed signature of igf_aw_award_pkg.update_row(Added adplans_id to the tbh call)
  --                            Changed signature of igf_aw_awd_disb_pkg.update_row(Added attendance_type_code to the tbh call)
  --pathipat    21-Aug-2003     Enh 3076768 - Auto Release of Holds build
  --                            Modified call_credits_api() - added check when return_status = 'S'
  --                            Modified main_disbursement()
  --vvutukur    18-Jul-2003     Enh#3038511.FICR106 Build. Modified procedure transfer_disb_dtls_to_sf.
  --SMADATHI    26-jun-2003     Bug 2852816. Modified procedures call_credits_api,call_charges_api,main_disbursement
  --                            Modified cursor cur_disb select to include fund_code column
  --vvutukur    16-Jun-2003     Enh#2831582.Lockbox Build. Modified the procedure call_credits_api.
  --bkkumar     04-jun-2003     #2858504  Added legacy_record_flag and award_number_txt in the table handler calls for igf_aw_award_pkg.update_row
  --shtatiko    02-MAY-2003     Enh# 2831569, Modified transfer_disb_dtls_to_sf and added check for Manage Accounts
  --                            System Option to cur_disb cursor.
  --vvutukur    08-Apr-2003     Enh#2831554.Internal Credits API Build. Modified function lookup_desc and procedures
  --                            call_credits_api,call_charges_api,main_disbursement,transfer_disb_dtls_to_sf.
  --shtatiko    26-MAR-2003     Bug# 2782124, modified transfer_disb_dtls_to_sf, main_disbursement
  --                            and log_messages.
  --agairola    07-Mar-2003     Bug# 2814089: Following modifications have been done
  --                                          1. Call_Charges_Api procedure modified
  --                                          2. Call_Credits_Api procedure modified
  --                                          3. Added two global variables - g_separator
  --                                             and g_chgadj
  --vvutukur    26-Feb-2003     Enh#2758823.FA117 Build.Modified procedure main_disbursement.
  --smadathi    06-Jan-2003     Bug 2684895. Modified transfer_disb_dtls_to_sf
  --smadathi    31-dec-2002     Bug 2719776. Modified transfer_disb_dtls_to_sf. Modified the
  --                            cursor cur_disb select to remove the Non-mergable view in the select and
  --                            to reduce the Shared memory(M)
  --smadathi    31-dec-2002     Bug 2620359. Modified the procedure main_disbursement
  --smadathi    31-dec-2002     Bug 2620343. Modified function validate_persid_grp
  --vvutukur   13-Dec-2002      Enh#2584741.Modified procedure call_credits_api.
  --vvutukur   20-Nov-2002      Enh#2584986.Modifications done in transfer_disb_dtls_to_sf,main_disbursement,
  --                            call_charges_api,call_credits_api.
  -- adhawan   25-oct-2002      Bug #2613546 Added ALT_PELL_SCHEDULE in igf_aw_award_pkg.update_row
  --jbegum     21-Sep-2002      Bug#2564643 Modified call_credits_api and call_charges_api.
  --smadathi   10-JUL-2002      Bug 2450332. call_credits_api modified.
  --smadathi   03-Jun-2002      Bug 2349394. Added new private function get_bill_desc. Also modified call_credits_api,
  --                            call_charges_api. Modified cur_disb to select fund_id column also.
  --SYkrishn   08-MAY-2002      Procedure main_disbursement - The column DISB_PAID_AMT in the table igf_aw_awd_disb is updated
  --                            with the Cumulation of existing Disb Paid amount with the newly disbursed amount (each iteration)
  --                            instead of overriding with the new value - Bug 2356801.
  --sarakshi    18-Mar-2002     Bug:2144600, added logic for refunding the excess credit amount in
  --                            main_disbursement program unit
  --vchappid    11-Feb-2002     Enh#2191470,modified cursor cur_disb, to include igf_aw_awd_disb table and
  --                            disb_dlt.ld_cal_type, disb_dlt.ld_sequence_number are included in the
  --                            cursor selected columns, removed reference to igf_aw_fund_tp_all and the where
  --                            clause is changed from tp_cal_type, tp_sequence_number to
  --                            disb_dlt.ld_cal_type, disb_dlt.ld_sequence_number
  --
  -------------------------------------------------------------------

  -- Check for Manage Accounts System Option has been added to following cursor
  -- so that transfer of disbursements for non-sponser parties from Financial Aid
  -- is not allowed if Manage Accounts Option has value OTHER.
  CURSOR cur_disb(cp_cal_type           igf_aw_fund_mast_v.ci_cal_type%TYPE,
                  cp_sequence_number    igf_aw_fund_mast_v.ci_sequence_number%TYPE,
                  cp_fund_id            igf_aw_fund_mast_v.fund_id%TYPE,
                  cp_person_id          igf_aw_award_v.person_id%TYPE,
                  cp_tp_cal_type        igf_aw_fund_tp.tp_cal_type%TYPE,
                  cp_tp_sequence_number igf_aw_fund_tp.tp_sequence_number%TYPE,
                  cp_manage_accounts    igs_fi_control_all.manage_accounts%TYPE
                 )  IS
SELECT disb_dlt.award_id,disb_dlt.disb_num,disb_dlt.disb_seq_num,disb_dlt.disb_date,
         fab.person_id,fcat.fed_fund_code fed_fund_code,fnd.fee_type,fnd.party_id,fnd.spnsr_fee_type,
         fcat.sys_fund_type sys_fund_type,fnd.ci_cal_type,fnd.ci_sequence_number,fnd.credit_type_id,
         DECODE(disb_dlt.disb_seq_num,1,disb_dlt.disb_net_amt,disb_dlt.disb_adj_amt) amount,
         NVL(disb_dlt.ld_cal_type,disb.ld_cal_type) ld_cal_type, NVL(disb_dlt.ld_sequence_number,disb.ld_sequence_number) ld_sequence_number,
	 fnd.fund_id, fnd.fund_code fund_code
  FROM   igf_db_awd_disb_dtl disb_dlt,
         igf_aw_awd_disb disb,
         igf_aw_award awd,
         igf_aw_fund_mast fnd,
         igf_aw_fund_cat fcat,
         igf_ap_fa_base_rec fab
  WHERE  disb_dlt.award_id           = disb.award_id
  AND    disb_dlt.disb_num           = disb.disb_num
  AND    disb.award_id               = awd.award_id
  AND    fnd.fund_id                 = awd.fund_id
  AND    fnd.fund_code               = fcat.fund_code
  AND    awd.base_id                 = fab.base_id
  AND    disb_dlt.sf_status          IN ('R','E')
  AND    fnd.ci_cal_type             = cp_cal_type
  AND    fnd.ci_sequence_number      = cp_sequence_number
  AND    (fnd.fund_id                = cp_fund_id OR (cp_fund_id IS NULL))
  AND    (fab.person_id              = cp_person_id OR (cp_person_id IS NULL))
  AND    (disb.ld_cal_type           = cp_tp_cal_type OR (cp_tp_cal_type IS NULL))
  AND    (disb.ld_sequence_number    = cp_tp_sequence_number OR (cp_tp_sequence_number IS NULL))
  AND    ((cp_manage_accounts = 'OTHER' and fcat.sys_fund_type = 'SPONSOR')
          OR (cp_manage_accounts='STUDENT_FINANCE'));

  g_sponsor         CONSTANT  VARCHAR2(10) :='SPONSOR';
  g_aid_adj         CONSTANT  VARCHAR2(10) :='AID_ADJ';
  g_separator       CONSTANT  VARCHAR2(5) := ' : ';
  g_chgadj          CONSTANT  igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_CREDIT_CLASS','CHGADJ');
  g_null            CONSTANT  VARCHAR2(6)  := NULL;
  g_v_currency      igs_fi_control_all.currency_cd%TYPE := NULL;
  g_print_msg       VARCHAR2(200);
  lv_locking_success VARCHAR2(1);

FUNCTION validate_award_year(p_cal_type igf_ap_award_year_v.cal_type%TYPE,
                             p_sequence_number  igf_ap_award_year_v.sequence_number%TYPE)
  RETURN BOOLEAN AS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  24-Dec-2001
  Purpose        :  Validates award year
  Known limitations,enhancements,remarks:
  Change History
  Who     When       What

********************************************************************************************** */

  CURSOR cur_val  IS
  SELECT  'X'
  FROM    igf_ap_award_year_v
  WHERE   cal_type = p_cal_type
  AND     sequence_number = p_sequence_number;
  l_temp  VARCHAR2(1);
BEGIN
  OPEN cur_val;
  FETCH cur_val INTO l_temp;
  IF cur_val%FOUND THEN
    CLOSE cur_val;
    RETURN TRUE;
  ELSE
    CLOSE cur_val;
    RETURN FALSE;
  END IF;
END validate_award_year;

FUNCTION validate_persid_grp(p_persid_grp_id  IN  igs_pe_persid_group_all.group_id%TYPE)
  RETURN BOOLEAN AS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  24-Dec-2001
  Purpose        :  Validates person Id Group

  Known limitations,enhancements,remarks:
  Change History
  Who       When         What
  smadathi  01-JUL-2004  Bug 3735396. Modified the cursor cur_val select to validate
                         existance of input person id group from igs_pe_persid_group_all
  smadathi  31-DEC-2002  Bug 2620343. Modified the cursor cur_val select to fetch
                         the records from view igs_pe_persid_group instead of
                         igs_pe_persid_group_v. This fix is done to remove
                         Non-mergablity due to igs_pe_persid_group_v view and to reduce shared memory
********************************************************************************************** */

  CURSOR cur_val  IS
  SELECT  'X'
  FROM   igs_pe_persid_group_all
  WHERE  group_id = p_persid_grp_id
  AND    TRUNC(create_dt) <= TRUNC(SYSDATE)
  AND    NVL(closed_ind,'N') = 'N';

  l_temp  VARCHAR2(1);
BEGIN
  OPEN cur_val;
  FETCH cur_val INTO l_temp;
  IF cur_val%FOUND THEN
    CLOSE cur_val;
    RETURN TRUE;
  ELSE
    CLOSE cur_val;
    RETURN FALSE;
  END IF;
END validate_persid_grp;

FUNCTION validate_base_id(p_base_id         igf_ap_fa_con_v.base_id%TYPE,
                          p_cal_type        igf_ap_fa_con_v.ci_cal_type%TYPE,
                          p_sequence_number igf_ap_fa_con_v.ci_sequence_number%TYPE)
  RETURN BOOLEAN AS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  24-Dec-2001
  Purpose        :  Validates base Id

  Known limitations,enhancements,remarks:
  Change History
  Who         When            What
  smadathi    31-dec-2002     Bug 2719776. Modified the cursor cur_val select to fetch
                              the records from view igf_ap_fa_base_rec instead of
                              igf_ap_fa_con_v. This fix is done to remove
                              Non-mergable view exists in the select and to reduce shared memory
                              within the acceptable limit
********************************************************************************************** */

  CURSOR cur_val IS
  SELECT  'X'
  FROM    igf_ap_fa_base_rec
  WHERE   base_id = p_base_id
  AND     ci_cal_type =p_cal_type
  AND     ci_sequence_number=p_sequence_number;
  l_temp  VARCHAR2(1);
BEGIN
  OPEN cur_val;
  FETCH cur_val INTO l_temp;
  IF cur_val%FOUND THEN
    CLOSE cur_val;
    RETURN TRUE;
  ELSE
    CLOSE cur_val;
    RETURN FALSE;
  END IF;
END validate_base_id;

FUNCTION validate_fund_id(p_fund_id IN      igf_aw_fund_mast.fund_id%TYPE,
                          p_cal_type        igf_aw_fund_mast.ci_cal_type%TYPE,
                          p_sequence_number igf_aw_fund_mast.ci_sequence_number%TYPE)
  RETURN BOOLEAN AS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  24-Dec-2001
  Purpose        :  Validates fund Id

  Known limitations,enhancements,remarks:
  Change History
  Who     When       What
********************************************************************************************** */

  CURSOR cur_val IS
  SELECT  'X'
  FROM    igf_aw_fund_mast
  WHERE   fund_id = p_fund_id
  AND     ci_cal_type =p_cal_type
  AND     ci_sequence_number=p_sequence_number;
  l_temp  VARCHAR2(1);
BEGIN
  OPEN cur_val;
  FETCH cur_val INTO l_temp;
  IF cur_val%FOUND THEN
    CLOSE cur_val;
    RETURN TRUE;
  ELSE
    CLOSE cur_val;
    RETURN FALSE;
  END IF;
END validate_fund_id;


  FUNCTION get_bill_desc(p_n_fund_id IN igf_aw_fund_mast.fund_id%TYPE)
  RETURN   VARCHAR2 IS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 03 Jun 2002
  --
  --Purpose: This function erturns the bill description value for the fund
  --         passed as parameter.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ------------------------------------------------------------------
  CURSOR   c_igf_aw_fund_mast(cp_fund_id igf_aw_fund_mast.fund_id%type) IS
  SELECT   bill_desc
  FROM     igf_aw_fund_mast
  WHERE    fund_id = cp_fund_id;

  -- cursor c_igf_aw_fund_mast row type variable
  rec_c_igf_aw_fund_mast  c_igf_aw_fund_mast%ROWTYPE;

  BEGIN
    OPEN    c_igf_aw_fund_mast(p_n_fund_id);
    FETCH   c_igf_aw_fund_mast INTO rec_c_igf_aw_fund_mast;
    CLOSE   c_igf_aw_fund_mast;
    RETURN  rec_c_igf_aw_fund_mast.bill_desc;

  END get_bill_desc;


FUNCTION lookup_desc( p_type IN igf_lookups_view.lookup_type%TYPE,
                      p_code IN igf_lookups_view.lookup_code%TYPE) RETURN VARCHAR2 IS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  24-Dec-2001
  Purpose        :  To fetch the meaning of a corresponding lookup code of a lookup type

  Known limitations,enhancements,remarks:
  Change History
  Who     When         What
vvutukur  08-Apr-2003  Enh#2831554.Internal Credits API Build. Removed cursor cur_desc and its usage and replaced with a call
                       to generic function igf_aw_gen.lookup_desc to fetch the meaning of a lookup.
********************************************************************************************** */

BEGIN
  IF p_code IS NULL THEN
    RETURN NULL;
  ELSE
    RETURN igf_aw_gen.lookup_desc(l_type => p_type,
                                  l_code => p_code
                                  );
  END IF ;
END lookup_desc;

PROCEDURE log_messages ( p_msg_name  VARCHAR2 ,
                         p_msg_val   VARCHAR2
                       ) IS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  24-Dec-2001
  Purpose        :  To log the parameter and other important information

  Known limitations,enhancements,remarks:
  Change History
  Who           When            What
  shtatiko      26-MAR-2003     Bug# 2782124, Changed the message to IGS_FI_CRD_INT_ALL_PARAMETER
                                from IGS_FI_CAL_BALANCES_LOG.
********************************************************************************************** */
BEGIN
  fnd_message.set_name('IGS','IGS_FI_CRD_INT_ALL_PARAMETER');
  fnd_message.set_token('PARM_TYPE',p_msg_name);
  fnd_message.set_token('PARM_CODE' ,p_msg_val);
  fnd_file.put_line(fnd_file.log,fnd_message.get);
END log_messages ;



PROCEDURE call_credits_api(p_cur_disb         IN  cur_disb%ROWTYPE,
                           p_fee_cal_type     IN  igs_ca_inst.cal_type%TYPE,
                           p_fee_ci_sequence_number IN igs_ca_inst.sequence_number%TYPE,
                           p_credit_id        OUT NOCOPY igs_fi_credits_all.credit_id%TYPE,
                           p_status           OUT NOCOPY igf_db_awd_disb_dtl.sf_status%TYPE,
                           p_error_desc       OUT NOCOPY igf_db_awd_disb_dtl.error_desc%TYPE,
                           p_d_gl_date        IN  igs_fi_credits_all.gl_date%TYPE,
                           p_n_source_invoice_id  IN igs_fi_credits_all.source_invoice_id%TYPE
                           )AS
/***********************************************************************************************
  Created by  : Sarakshi,
  Date created: 24-Dec-2001

  Purpose:To calls the credits api.


  Known limitations/enhancements and/or remarks:

  Change History:
  Who         When            What
  pmarada     26-JUL-2005     Enh 3392095, modifed as per tution waiver build, passing p_api_version
                              parameter value as 2.1 to the igs_fi_credit_pvt.create_credit call
  svuppala   18-JUL-2005      Enh 4213629 - Impact of automatic generation of the Receipt Number
                              changed parameters of igs_fi_credit_pvt.create_credit call
                              Added OUT parameter x_credit_number and local variable l_v_credit_number
                              Removed cur_seq cursor and the usage of the cursor.
  pathipat    22-Apr-2004     Enh 3558549 - Commercial Receivables Enhancements build
                              Added param p_n_source_invoice_id
  pathipat    21-Aug-2003     Enh 3076768 - Auto Release of Holds build
                              Modified call_credits_api() - added check when return_status = 'S'
  SMADATHI    26-jun-2003     Bug 2852816.  Removed redundant parameter p_student_sponsor. Modified the creadit description generated
                              when a credit is recorded on the student's account
  vvutukur    16-Jun-2003     Enh#2831582.Lockbox Build. Modified the l_credit_rec record type variable to add 3 new parameters lockbox_interface_id,
                              batch_name,deposit_date.
  vvutukur    08-apr-2003     Enh#2831554.Internal Credits API Build. Removed the call to public credits api, instead added validations of
                              some parameters and placed a call to Private API.Removed finp_get_cur generic procedure which fetches currency code
                              as the same has been moved to procedure transfer_disb_dtls_to_sf
  agairola    07-Mar-2003     Bug# 2814089: Following modifications have been done
                              1. The cursor cur_api has been modified to select person_number
                                 from igs_pe_person_base_v
                              2. For the parameter p_student_sponsor='SPONSOR', the value of the
                                 parameter passed to cur_api is changed to p_cur_disb.person_id.
                              3. The credit description is modified for the sponsor transaction as
                                 Negative Charge Adjustment : Person Number : Full Name
  smadathi   31-dec-2002      Bug 2620349. Modified the cursor cur_api select to fetch
                              the records from view igs_fi_parties_v instead of
                              igs_pe_person_v. This fix is done to remove
                              Non-mergablity due to igs_pe_person_v view and to reduce shared memory
  vvutukur   13-Dec-2002      Enh#2584741.Deposits Build.Modified the call to credits api to remove p_validation_level
                              parameter and add 3 new parameters p_v_check_number,p_v_source_tran_type,p_v_source_tran_ref_number.
  vvutukur   20-Nov-2002      Enh#2584986.Added new IN parameter p_d_gl_date.Passed p_d_gl_date to the call to
                                        igs_fi_credits_api_pub.create_credit.Removed references to igs_fi_cur.Instead defaulted the
                                        currency that is set up in System Options Form and passed the same to the call to
                                        credits api. Also exchange rate is passed as 1.
  jbegum     21-Sep-2002      Bug #2564643 Modified the cursor cur_desc to select only description column
                              and not the subaccount_id column from igs_fi_cr_types table.
                              Also modified the call to igs_fi_credits_api_pub.create_credit.Removed the
                              parameter p_subaccount_id.
  smadathi   10-JUL-2002      Bug 2450332. Call to igs_fi_credits_api_pub.create_credit modified to
                              pass current system date as effective date instead of disbursement date.
  smadathi   03-Jun-2002      Bug 2349394. call to get_bill_desc function is made to get bill description
                              which is passed as parameter to credits API for all funds except sponsor.
  vchappid    11-Feb-2002     Enh#2191470,Un-Commented reference to new parameters introduced in the Credits API
********************************************************************************************** */

  -- Bug #2564643 Modified the cursor cur_desc to select only description column

  CURSOR cur_desc(cp_credit_type_id  igs_fi_cr_types.credit_type_id%TYPE)  IS
  SELECT credit_class
  FROM   igs_fi_cr_types_v
  WHERE  credit_type_id = cp_credit_type_id;
  l_cur_desc cur_desc%ROWTYPE;

  CURSOR cur_api(cp_person_id igs_pe_person_v.person_id%TYPE) IS
  SELECT person_number,full_name
  FROM   igs_pe_person_base_v
  WHERE person_id = cp_person_id;
  l_cur_api  cur_api%ROWTYPE;

  l_credit_activity_id            igs_fi_cr_activities.credit_activity_id%TYPE;
  l_msg_count                     NUMBER(2);
  l_msg_data                      igf_db_awd_disb_dtl.error_desc%TYPE;
  l_attribute_rec                 igs_fi_credits_api_pub.attribute_rec_type;
  l_credit_num                    NUMBER;
  l_person_id                     igs_pe_person_v.person_id%TYPE;
  l_desc                          igs_fi_credits_all.description%TYPE;
  l_amount                        igf_db_awd_disb_dtl.disb_net_amt%TYPE;

  l_v_message_name   fnd_new_messages.message_name%TYPE;
  l_credit_rec       igs_fi_credit_pvt.credit_rec_type;
  l_v_credit_number  igs_fi_credits.credit_number%TYPE;


BEGIN
  p_error_desc :=NULL;

  --fetching the credit type description
  OPEN cur_desc(p_cur_disb.credit_type_id);
  FETCH cur_desc INTO l_cur_desc;
  IF cur_desc%NOTFOUND THEN
    l_cur_desc.credit_class   :=NULL;
  END IF;
  CLOSE cur_desc;

  -- for the sponsor records
  IF p_cur_disb.sys_fund_type = g_sponsor THEN
    -- if the disbursement amount is greater than zero, credit will be created
    -- for the student and if the disbursement amount is less than zero, credit
    -- will be created for sponsor
    IF NVL(p_cur_disb.amount,0) < 0 THEN
      l_person_id := p_cur_disb.party_id;
      -- for credit created on the sponsor account would be negative charge
      -- adjustment : person number : full name of the student
      OPEN cur_api(p_cur_disb.person_id);
      FETCH cur_api INTO l_cur_api;
      IF cur_api%NOTFOUND THEN
        l_desc := NULL;
      ELSE
        l_desc := substr(g_chgadj||g_separator||l_cur_api.person_number||g_separator||l_cur_api.full_name,1,240);
      END IF;
      CLOSE cur_api;
    ELSE
      -- description will be credit class meaning of credit type linked to sponsor : sponsor code
      l_desc      := l_cur_desc.credit_class ||g_separator|| p_cur_disb.fund_code;
      l_person_id := p_cur_disb.person_id;
    END IF;
  ELSE
    -- for the other financial aid records, credit will be created for the student
    l_person_id := p_cur_disb.person_id;
    -- get_bill_desc function returns the bill description for the fund. This
    -- bill description will be passed as parameter to credits API for all funds
    -- except sponsor.
    l_desc :=  get_bill_desc(p_cur_disb.fund_id);
  END IF;

  IF NVL(p_cur_disb.amount,0) < 0 THEN
     l_amount := (-1)*p_cur_disb.amount;
  ELSE
     l_amount := p_cur_disb.amount;
  END IF;


  -- Calling Credits API to insert data in the credits table in student finance.
  l_attribute_rec.p_attribute_category := NULL;
  l_attribute_rec.p_attribute1         := NULL;
  l_attribute_rec.p_attribute2         := NULL;
  l_attribute_rec.p_attribute3         := NULL;
  l_attribute_rec.p_attribute4         := NULL;
  l_attribute_rec.p_attribute5         := NULL;
  l_attribute_rec.p_attribute6         := NULL;
  l_attribute_rec.p_attribute7         := NULL;
  l_attribute_rec.p_attribute8         := NULL;
  l_attribute_rec.p_attribute9         := NULL;
  l_attribute_rec.p_attribute10        := NULL;
  l_attribute_rec.p_attribute11        := NULL;
  l_attribute_rec.p_attribute12        := NULL;
  l_attribute_rec.p_attribute13        := NULL;
  l_attribute_rec.p_attribute14        := NULL;
  l_attribute_rec.p_attribute15        := NULL;
  l_attribute_rec.p_attribute16        := NULL;
  l_attribute_rec.p_attribute17        := NULL;
  l_attribute_rec.p_attribute18        := NULL;
  l_attribute_rec.p_attribute19        := NULL;
  l_attribute_rec.p_attribute20        := NULL;

  l_credit_rec.p_credit_status              := 'CLEARED';
  l_credit_rec.p_credit_source              := p_cur_disb.fed_fund_code;
  l_credit_rec.p_party_id                   := l_person_id;
  l_credit_rec.p_credit_type_id             := p_cur_disb.credit_type_id;
  l_credit_rec.p_credit_instrument          := 'AID';
  l_credit_rec.p_description                := l_desc;
  l_credit_rec.p_amount                     := l_amount;
  l_credit_rec.p_currency_cd                := g_v_currency;
  l_credit_rec.p_exchange_rate              := 1;
  l_credit_rec.p_transaction_date           := TRUNC(SYSDATE);
  l_credit_rec.p_effective_date             := TRUNC(SYSDATE);
  l_credit_rec.p_source_transaction_id      := g_null;
  l_credit_rec.p_receipt_lockbox_number     := g_null;
  l_credit_rec.p_credit_card_code           := g_null;
  l_credit_rec.p_credit_card_holder_name    := g_null;
  l_credit_rec.p_credit_card_number         := g_null;
  l_credit_rec.p_credit_card_expiration_date := g_null;
  l_credit_rec.p_credit_card_approval_code  := g_null;
  l_credit_rec.p_invoice_id                 := null;
  l_credit_rec.p_awd_yr_cal_type            := p_cur_disb.ci_cal_type;
  l_credit_rec.p_awd_yr_ci_sequence_number  := p_cur_disb.ci_sequence_number;
  l_credit_rec.p_fee_cal_type               := p_fee_cal_type;
  l_credit_rec.p_fee_ci_sequence_number     := p_fee_ci_sequence_number;
  l_credit_rec.p_check_number               := g_null;
  l_credit_rec.p_source_tran_type           := g_null;
  l_credit_rec.p_source_tran_ref_number     := g_null;
  l_credit_rec.p_gl_date                    := p_d_gl_date;
  l_credit_rec.p_v_credit_card_payee_cd     := NULL;
  l_credit_rec.p_v_credit_card_status_code  := NULL;
  l_credit_rec.p_v_credit_card_tangible_cd  := NULL;
  l_credit_rec.p_lockbox_interface_id       := g_null;
  l_credit_rec.p_batch_name                 := g_null;
  l_credit_rec.p_deposit_date               := g_null;
  l_credit_rec.p_invoice_id                 := p_n_source_invoice_id;

  --Create a credit by calling the Private Credits API with p_validation_level as fnd_api.g_valid_level_none.
  igs_fi_credit_pvt.create_credit(  p_api_version          => 2.1,
                                    p_init_msg_list        => fnd_api.g_true,
                                    p_commit               => fnd_api.g_false,
                                    p_validation_level     => fnd_api.g_valid_level_none,
                                    x_return_status        => p_status,
                                    x_msg_count            => l_msg_count,
                                    x_msg_data             => l_msg_data,
                                    p_credit_rec           => l_credit_rec,
                                    p_attribute_record     => l_attribute_rec,
                                    x_credit_id            => p_credit_id,
                                    x_credit_activity_id   => l_credit_activity_id,
                                    x_credit_number        => l_v_credit_number
                                    );
  IF  p_status <> 'S' THEN
    fnd_message.set_encoded(l_msg_data);
    p_error_desc:= fnd_message.get;
  ELSE
    IF l_msg_count <> 0 THEN
       fnd_message.set_encoded(l_msg_data);
       p_error_desc:= fnd_message.get;
    END IF;
  END IF;

END call_credits_api;


PROCEDURE  call_charges_api(p_cur_disb        IN  cur_disb%ROWTYPE,
                            p_fee_cal_type    IN  igs_ca_inst.cal_type%TYPE,
                            p_fee_ci_sequence_number IN igs_ca_inst.sequence_number%TYPE,
                            p_invoice_id      OUT NOCOPY igs_fi_inv_int_all.invoice_id%TYPE,
                            p_status          OUT NOCOPY igf_db_awd_disb_dtl.sf_status%TYPE,
                            p_error_desc      OUT NOCOPY igf_db_awd_disb_dtl.error_desc%TYPE,
                            p_d_gl_date       IN  igs_fi_credits_all.gl_date%TYPE
                            )AS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  24-Dec-2001
  Purpose        :  To create charges.

  Known limitations,enhancements,remarks:
  Change History
  Who         When            What
  SMADATHI    26-jun-2003     Bug 2852816. Removed redundant parameter p_student_sponsor. Modified the charges description when
                              downward adjustment exists
  vvutukur    11-Apr-2003     Enh#2831554.Internal Credits API Build. Removed finp_get_cur generic procedure which fetches currency code
                              as the same has been moved to procedure transfer_disb_dtls_to_sf.
  agairola    07-Mar-2003     Bug# 2814089: Following modifications have been done
                              1. The cursor cur_api has been modified to select person_number
                                 from igs_pe_person_base_v
                              2. For the parameter p_student_sponsor='SPONSOR', the value of the
                                 parameter passed to cur_api is changed to p_cur_disb.person_id.
                              3. The invoice description is modified for the sponsor transaction as
                                 Person Number : Full Name
  smadathi   31-dec-2002      Bug 2620349. Modified the cursor cur_api select to fetch
                              the records from view igs_fi_parties_v instead of
                              igs_pe_person_v. This fix is done to remove
                              Non-mergablity due to igs_pe_person_v view and to reduce shared memory
  vvutukur   20-Nov-2002      Enh#2584986.Added new IN parameter p_d_gl_date to this procedure.Passed p_d_gl_date to
                              the call to igs_fi_charges_api_pvt.create_charge.
  jbegum     21-Sep-2002      Bug #2564643 Modified the cursor cur_desc to select only description column
                              and not the subaccount_id column from igs_fi_cr_types table.
                              Also modified the record structure being passed to igs_fi_charges_api_pvt.create_charge.
                              Removed the field l_chg_rec.p_subaccount_id .
  smadathi   03-Jun-2002      Bug 2349394. call to get_bill_desc function is made to get bill description
                              which is passed as parameter to charges API for all funds except sponsor.
  vchappid    11-Feb-2002     Enh#2191470, Un-Commented reference to Fee Cal parameters in the Charges API invoking
                              Fee Cal Parameters Derived for the Load Cal are passed for charges Creation
********************************************************************************************** */

  -- Bug #2564643 Modified the cursor cur_desc to select only description column

  CURSOR cur_desc(cp_credit_type_id  igs_fi_cr_types.credit_type_id%TYPE)  IS
  SELECT description
  FROM   igs_fi_cr_types
  WHERE  credit_type_id = cp_credit_type_id;
  l_cur_desc cur_desc%ROWTYPE;

  CURSOR cur_api(cp_person_id igs_pe_person_v.person_id%TYPE) IS
  SELECT person_number,full_name
  FROM igs_pe_person_base_v
  WHERE person_id = cp_person_id;
  l_cur_api  cur_api%ROWTYPE;

  CURSOR  c_igs_fi_fee_type (cp_v_fee_type igs_fi_fee_type_all.fee_type%TYPE) IS
  SELECT  description
  FROM    igs_fi_fee_type
  WHERE   fee_type = cp_v_fee_type;

  rec_c_igs_fi_fee_type c_igs_fi_fee_type%ROWTYPE;


  l_chg_rec             igs_fi_charges_api_pvt.header_rec_type;
  l_chg_line_tbl        igs_fi_charges_api_pvt.line_tbl_type;
  l_line_tbl            igs_fi_charges_api_pvt.line_id_tbl_type;
  l_invoice_id          igs_fi_inv_int.invoice_id%TYPE;
  l_msg_count           NUMBER(5);
  l_msg_data            igf_db_awd_disb_dtl.error_desc%TYPE;
  l_var                 NUMBER(5) := 0;
  l_count               NUMBER(5);
  l_msg                 igf_db_awd_disb_dtl.error_desc%TYPE;
  l_person_id           igs_pe_person_v.person_id%TYPE;
  l_fee_type            igf_aw_fund_mast.fee_type%TYPE;
  l_invoice_desc        igs_fi_inv_int.invoice_desc%TYPE;
  l_amount              igf_db_awd_disb_dtl.disb_net_amt%TYPE;
  l_transaction_type    igs_lookups_view.lookup_code%TYPE;

  l_v_currency      igs_fi_control_all.currency_cd%TYPE;
  l_v_message_name  fnd_new_messages.message_name%TYPE;
  l_n_waiver_amount igs_fi_credits_all.amount%TYPE;


BEGIN
  p_error_desc := NULL;

  --fetching the invoice description
  OPEN cur_desc(p_cur_disb.credit_type_id);
  FETCH cur_desc INTO l_cur_desc;
  IF cur_desc%NOTFOUND THEN
    l_cur_desc.description   :=NULL;
  END IF;
  CLOSE cur_desc;

  -- for the sponsor records
  IF p_cur_disb.sys_fund_type = g_sponsor THEN
    -- if the disbursement amount is greater than zero, charge will be created
    -- for the sponsor (fee type = sponsor, Transaction type = sponsor) and if the disbursement amount is less than zero, charge
    -- will be created for student (fee type = adjustment fee type, Transaction type = AID_ADJ)
    IF NVL(p_cur_disb.amount,0) > 0 THEN
      l_person_id := p_cur_disb.party_id;
      l_fee_type  := p_cur_disb.spnsr_fee_type;
      l_transaction_type := g_sponsor;
      -- for credit created on the sponsor account would be negative charge
      -- adjustment : person number : full name of the student
      OPEN cur_api(p_cur_disb.person_id);
      FETCH cur_api INTO l_cur_api;
      IF cur_api%NOTFOUND THEN
        l_invoice_desc := NULL;
      ELSE
        l_invoice_desc := substr(l_cur_api.person_number||g_separator||l_cur_api.full_name,1,240);
      END IF;
      CLOSE cur_api;
    ELSE
      OPEN  c_igs_fi_fee_type(p_cur_disb.fee_type);
      FETCH c_igs_fi_fee_type INTO rec_c_igs_fi_fee_type;
      IF c_igs_fi_fee_type%NOTFOUND THEN
        l_invoice_desc := NULL;
      ELSE
        -- description will be description of adjustment  fee type linked to sponsor : sponsor code
        l_invoice_desc     :=  rec_c_igs_fi_fee_type.description || g_separator || p_cur_disb.fund_code   ;
      END IF;
      l_person_id        := p_cur_disb.person_id;
      l_fee_type         := p_cur_disb.fee_type;
      l_transaction_type := g_aid_adj;
    END IF;
  ELSE
    -- for the other financial aid records, credit will be created for the student
    l_person_id := p_cur_disb.person_id;
    -- get_bill_desc function returns the bill description for the fund. This
    -- bill description will be passed as parameter to credits API for all funds
    -- except sponsor.
    l_invoice_desc     := get_bill_desc(p_cur_disb.fund_id);
    l_fee_type         := p_cur_disb.fee_type;
    l_transaction_type := g_aid_adj;
  END IF;

  IF p_cur_disb.amount < 0 THEN
     l_amount := (-1)*p_cur_disb.amount;
  ELSE
     l_amount := p_cur_disb.amount;
  END IF;

  -- Bug #2564643 .Removed assigning of l_chg_rec.p_subaccount_id with value of l_cur_desc.subaccount_id

  l_chg_rec.p_person_id                := l_person_id;
  l_chg_rec.p_fee_type                 := l_fee_type;
  l_chg_rec.p_fee_cat                  := NULL;
  l_chg_rec.p_fee_cal_type             := p_fee_cal_type; -- Enh#2191470, Passing the Derived Fee Cal Type for the Load Cal Type
  l_chg_rec.p_fee_ci_sequence_number   := p_fee_ci_sequence_number; -- Enh#2191470, Passing the Derived Fee Cal Type for the Load Cal Type
  l_chg_rec.p_course_cd                := NULL;
  l_chg_rec.p_attendance_type          := NULL;
  l_chg_rec.p_attendance_mode          := NULL;
  l_chg_rec.p_invoice_amount           := l_amount;
  l_chg_rec.p_invoice_creation_date    := TRUNC(SYSDATE);
  l_chg_rec.p_invoice_desc             := l_invoice_desc;
  l_chg_rec.p_transaction_type         := l_transaction_type;
  l_chg_rec.p_currency_cd              := g_v_currency;
  l_chg_rec.p_exchange_rate            := 1;
  l_chg_rec.p_effective_date           := p_cur_disb.disb_date;
  l_chg_rec.p_waiver_flag              := NULL;
  l_chg_rec.p_waiver_reason            := NULL;
  l_chg_rec.p_source_transaction_id    := NULL;


  l_chg_line_tbl(1).p_s_chg_method_type         := NULL;
  l_chg_line_tbl(1).p_description               := l_cur_desc.description;
  l_chg_line_tbl(1).p_chg_elements              := 1;
  l_chg_line_tbl(1).p_amount                    := l_amount;
  l_chg_line_tbl(1).p_unit_attempt_status       := NULL;
  l_chg_line_tbl(1).p_eftsu                     := NULL;
  l_chg_line_tbl(1).p_credit_points             := NULL;
  l_chg_line_tbl(1).p_org_unit_cd               := NULL;
  l_chg_line_tbl(1).p_attribute_category        := NULL;
  l_chg_line_tbl(1).p_attribute1                := NULL;
  l_chg_line_tbl(1).p_attribute2                := NULL;
  l_chg_line_tbl(1).p_attribute3                := NULL;
  l_chg_line_tbl(1).p_attribute4                := NULL;
  l_chg_line_tbl(1).p_attribute5                := NULL;
  l_chg_line_tbl(1).p_attribute6                := NULL;
  l_chg_line_tbl(1).p_attribute7                := NULL;
  l_chg_line_tbl(1).p_attribute8                := NULL;
  l_chg_line_tbl(1).p_attribute9                := NULL;
  l_chg_line_tbl(1).p_attribute10               := NULL;
  l_chg_line_tbl(1).p_attribute11               := NULL;
  l_chg_line_tbl(1).p_attribute12               := NULL;
  l_chg_line_tbl(1).p_attribute13               := NULL;
  l_chg_line_tbl(1).p_attribute14               := NULL;
  l_chg_line_tbl(1).p_attribute15               := NULL;
  l_chg_line_tbl(1).p_attribute16               := NULL;
  l_chg_line_tbl(1).p_attribute17               := NULL;
  l_chg_line_tbl(1).p_attribute18               := NULL;
  l_chg_line_tbl(1).p_attribute19               := NULL;
  l_chg_line_tbl(1).p_attribute20               := NULL;
  l_chg_line_tbl(1).p_location_cd               := NULL;
  l_chg_line_tbl(1).p_uoo_id                    := NULL;
  l_chg_line_tbl(1).p_d_gl_date                 := p_d_gl_date;

  igs_fi_charges_api_pvt.create_charge(p_api_version      => 2.0,
                                       p_init_msg_list    => 'T',
                                       p_commit           => 'F',
                                       p_validation_level => NULL,
                                       p_header_rec       => l_chg_rec,
                                       p_line_tbl         => l_chg_line_tbl,
                                       x_invoice_id       => p_invoice_id,
                                       x_line_id_tbl      => l_line_tbl,
                                       x_return_status    => p_status,
                                       x_msg_count        => l_msg_count,
                                       x_msg_data         => l_msg_data,
                                       x_waiver_amount    => l_n_waiver_amount);

  IF p_status <> 'S' THEN
    IF l_msg_count = 1 THEN
      fnd_message.set_encoded(l_msg_data);
      p_error_desc:= fnd_message.get;
    ELSE
      FOR l_count IN 1 .. l_msg_count LOOP
        l_msg := fnd_msg_pub.get(p_msg_index => l_count, p_encoded => 'T');
        fnd_message.set_encoded (l_msg);
        p_error_desc:= p_error_desc||'- '|| fnd_message.get;
      END LOOP;
    END IF;
  END IF;
END call_charges_api;

PROCEDURE  main_disbursement(
                              p_rec_disb  IN cur_disb%ROWTYPE,
                              p_d_gl_date IN igs_fi_credits_all.gl_date%TYPE
                             ) AS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  24-Dec-2001
  Purpose        :

  Known limitations,enhancements,remarks:
  Change History
  Who         When            What
  svuppala    12-May-2006      Bug 5217319 Added call to format amount by rounding off to currency precision
                              in igf_aw_awd_disb_pkg.update_row , igf_aw_award_pkg.update_row calls
  smadathi    01-JUL-2004     Bug 3735396. GSCC Warning File.Sql.35 was fixed as part of this bug. The initialization
                              of local variable l_status in the procedure declaration was removed and the same
			      was initialized at the starting of this procedure.
  pathipat    22-Apr-2004     Enh 3558549 - Commercial Receivables Enhancements
                              Modified calls to call_credits_api() - added new parameter p_n_source_invoice_id
  veramach    3-NOV-2003      FA 125 Multiple Distr Methods
                              Changed signature of igf_aw_award_pkg.update_row(Added adplans_id to the tbh call)
                              Changed signature of igf_aw_awd_disb_pkg.update_row(Added attendance_type_code to the tbh call)
  pathipat    23-Aug-2003     Enh 3076768 - Automatic Release of Holds build
                              Added code to log message is holds release failed in call to Credits API
  SMADATHI    26-jun-2003     Bug 2852816. Removed parameter  p_student_sponsor from the calls to  call_credits_api,call_charges_api
  vvutukur    10-Apr-2003     Enh#2831554.Internal Credits API Build. Added validations for Fee,Load,Award Calendar Instances,credit type,
                              credit source,credit class.Added logic such that the disb. record's sf_status and error_desc fields gets updated with
                              appropriate values.
                              error description fields
  shtatiko    26-MAR-2003     Bug# 2782124, Changed the logging of results from tabular format to
                              form layout.
  vvutukur    26-Feb-2003     Enh#2758823.FA117 Build. Modified the call to igf_db_awd_disb_dtl_pkg.update_row to pass TRUNC(SYSDATE)
                              instead of SYSDATE for the parameter x_sf_status_date.
  smadathi    31-dec-2002     Bug 2620359. Modified the cursor cur_person to fetch the person number
                              from igs_pe_person_base_v instead of the igs_pe_person. This is done
                              due to Non-Meargability and higher value of shared memory beyong the acceptable limit
  vvutukur    20-Nov-2002     Enh#2584986.Added new parameter p_d_gl_date.Also modified the calls to call_charges_api
                              and call_credits_api to pass this p_d_gl_date parameter.Also added this p_d_gl_date
                              parameter to the call to igs_fi_prc_refunds.process_plus.
  SYkrishn    08-MAY-2002     The column DISB_PAID_AMT in the table igf_aw_awd_disb is updated with the Cumulation of existing Disb Paid amount
                              with the newly disbursed amount (each iteration) instead of overriding with the new value - Bug 2356801.
  sarakshi    18-Mar-2002     Bug:2144600, added logic for refunding the excess credit amount
  vchappid    11-Feb-2002     Enh#2191470, Un-Commented reference to Fee Cal parameters in the Charges API invoking
                              Fee Cal Parameters Derived for the Load Cal are passed for charges Creation
********************************************************************************************** */
  CURSOR cur_person(cp_person_id  igs_pe_person_v.person_id%TYPE) IS
  SELECT person_number
  FROM igs_pe_person_base_v
  WHERE person_id=cp_person_id;
  l_cur_person cur_person%ROWTYPE;

  CURSOR cur_cr_type(cp_credit_type_id igs_fi_cr_types_all.credit_type_name%TYPE) IS
    SELECT credit_type_name
    FROM   igs_fi_cr_types_all
    WHERE  credit_type_id = cp_credit_type_id;

  l_v_cr_type_name  igs_fi_cr_types_all.credit_type_name%TYPE;

  CURSOR cur_awd(cp_award_id igf_aw_award.award_id%TYPE) IS
  SELECT a.rowid,a.*
  FROM   igf_aw_award a
  WHERE  award_id=cp_award_id;
  l_rec_awd   cur_awd%ROWTYPE;

  CURSOR cur_awd_disb(cp_award_id  igf_aw_awd_disb.award_id%TYPE,
                      cp_disb_num  igf_aw_awd_disb.disb_num%TYPE) IS
  SELECT a.rowid,a.*
  FROM   igf_aw_awd_disb a
  WHERE  award_id=cp_award_id
  AND    disb_num=cp_disb_num;
  l_rec_awd_disb   cur_awd_disb%ROWTYPE;

  CURSOR cur_borrower(cp_award_id igf_aw_awd_disb.award_id%TYPE) IS
  SELECT lor.p_person_id
  FROM   igf_sl_loans lon ,igf_sl_lor lor
  WHERE  lon.award_id=cp_award_id
  AND    lon.loan_id=lor.loan_id;
  l_borrower  igf_sl_lor.p_person_id%TYPE;

  CURSOR cur_disb_dtl (cp_award_id igf_db_awd_disb_dtl.award_id%TYPE,
                       cp_disb_num igf_db_awd_disb_dtl.disb_num%TYPE,
                       cp_disb_seq_num igf_db_awd_disb_dtl.disb_seq_num%TYPE) IS
  SELECT a.rowid,a.*
  FROM   igf_db_awd_disb_dtl a
  WHERE  award_id=cp_award_id
  AND    disb_num=cp_disb_num
  AND    disb_seq_num=cp_disb_seq_num;
  l_rec_disb_dtl  cur_disb_dtl%ROWTYPE;
  l_status               igf_db_awd_disb_dtl.sf_status%TYPE;
  l_error_desc           igf_db_awd_disb_dtl.error_desc%TYPE :=NULL;
  l_sf_credit_id         igf_db_awd_disb_dtl.sf_credit_id%TYPE    := NULL;
  l_sf_invoice_num       igf_db_awd_disb_dtl.sf_invoice_num%TYPE  := NULL;
  l_spnsr_credit_id      igf_db_awd_disb_dtl.spnsr_credit_id%TYPE := NULL;
  l_spnsr_charge_id      igf_db_awd_disb_dtl.spnsr_charge_id%TYPE := NULL;
  l_paid_amt             igf_aw_award.paid_amt%TYPE;
  l_disb_paid_amt        igf_aw_awd_disb.disb_paid_amt%TYPE;
  l_status_code          igf_db_awd_disb_dtl.sf_status%TYPE;
  l_log_status           igf_lookups_view.meaning%TYPE;
  l_flag1                BOOLEAN :=TRUE;
  l_flag2                BOOLEAN :=TRUE;
  l_flag3                BOOLEAN :=TRUE;
  l_refunds              BOOLEAN :=FALSE;
  l_ref_status           BOOLEAN :=TRUE;
  l_ref_err_msg          fnd_new_messages.message_name%TYPE :=NULL;

  -- Start of Modification for Enh#2191470
  l_fee_cal_type            igs_ca_inst.cal_type%TYPE;
  l_fee_ci_sequence_number  igs_ca_inst.sequence_number%TYPE;
  l_message_name            fnd_new_messages.message_name%TYPE;
  -- End of Modification for Enh#2191470

  l_v_credit_class          igs_fi_cr_types_all.credit_class%TYPE;
  l_b_return_status         BOOLEAN;

  l_v_holds_message         fnd_new_messages.message_text%TYPE := NULL;

BEGIN
  SAVEPOINT S1;
  -- status variable being initialized to value 'S'.
  l_status  := 'S';
  --Load Calendar Instance is associated with each disbursement. Check if the Load Calendar instance is currently active.
  --else, log the error message and skip processing the same record and continue with the next record.
  IF p_rec_disb.ld_cal_type IS NOT NULL AND p_rec_disb.ld_sequence_number IS NOT NULL THEN
    IF NOT igs_fi_crdapi_util.validate_cal_inst( p_v_cal_type            => p_rec_disb.ld_cal_type,
                                                 p_n_ci_sequence_number  => p_rec_disb.ld_sequence_number,
                                                 p_v_s_cal_cat           => 'LOAD'
                                                ) THEN
      fnd_message.set_name('IGS','IGS_FI_LOAD_CAL_NOT_ACTIVE');
      l_error_desc := fnd_message.get;
      l_status := 'E';
    END IF;
  END IF;

  -- Derive the Fee Period for the passed Load Calendar Period, if there is no
  -- relation defined between a Fee and Load Calendars then Log an error and exit out NOCOPY of the Process
  -- If there is a relation defined then the OUT NOCOPY parameters l_fee_cal_type, l_fee_ci_seq will have
  -- the Fee Period Instance
  IF l_status = 'S' THEN
    IF NOT igs_fi_gen_001.finp_get_lfci_reln( p_rec_disb.ld_cal_type,
                                              p_rec_disb.ld_sequence_number,
                                              'LOAD',
                                              l_fee_cal_type,
                                              l_fee_ci_sequence_number,
                                              l_message_name) THEN
      IF l_message_name <> 'IGS_FI_NO_RELN_EXISTS' THEN
      l_error_desc := fnd_message.get_string('IGS',l_message_name);
      l_status := 'E';
      ELSE
        fnd_message.set_name('IGS','IGS_FI_NO_FEE_LOAD_REL');
        fnd_message.set_token('AWARD_ID',p_rec_disb.award_id);
        fnd_message.set_token('DISB_NUM',p_rec_disb.disb_num);
        fnd_message.set_token('LOAD_CAL',p_rec_disb.ld_cal_type);
        fnd_message.set_token('LOAD_SEQ_NUM',p_rec_disb.ld_sequence_number);
        l_error_desc := fnd_message.get;
        l_status := 'E';
      END IF;
    END IF;
  END IF;

  --Check if the Fee Calendar instance is currently active.
  --else, log the error message and skip processing the same record and continue with the next record.
  IF l_status = 'S' THEN
    IF l_fee_cal_type IS NOT NULL AND l_fee_ci_sequence_number IS NOT NULL THEN
      IF NOT igs_fi_crdapi_util.validate_cal_inst( p_v_cal_type            => l_fee_cal_type,
                                                   p_n_ci_sequence_number  => l_fee_ci_sequence_number,
                                                   p_v_s_cal_cat           => 'FEE'
                                                  ) THEN
        fnd_message.set_name('IGS','IGS_FI_FCI_NOTFOUND');
        l_error_desc := fnd_message.get;
        l_status := 'E';
      END IF;
    END IF;
  END IF;

  --The Credit Source parameter, associated with the disbursement records, has to be a valid lookup code for the lookup type 'IGF_AW_FED_FUND'.
  --else, log the error message and skip processing the same record and continue with the next record.
  IF l_status = 'S' THEN
    IF NOT igs_fi_crdapi_util.validate_igf_lkp( p_v_lookup_type  => 'IGF_AW_FED_FUND',
                                                p_v_lookup_code  => p_rec_disb.fed_fund_code) THEN
      fnd_message.set_name('IGS','IGS_FI_CAPI_CRD_SRC_NULL');
      fnd_message.set_token('CR_SOURCE',igf_aw_gen.lookup_desc('IGF_AW_FED_FUND',p_rec_disb.fed_fund_code));
      l_error_desc := fnd_message.get;
      l_status := 'E';
    END IF;
  END IF;

  --Check if the credit type associated with the disbursement record is active as on the current system date.
  --else, log the error message and skip processing the same record and continue with the next record.
  IF l_status = 'S' THEN
    igs_fi_crdapi_util.validate_credit_type( p_n_credit_type_id  => p_rec_disb.credit_type_id,
                                             p_v_credit_class    => l_v_credit_class,
                                             p_b_return_stat     => l_b_return_status
                                            );
    IF l_b_return_status = FALSE THEN
      OPEN cur_cr_type(p_rec_disb.credit_type_id);
      FETCH cur_cr_type INTO l_v_cr_type_name;
      CLOSE cur_cr_type;

      fnd_message.set_name('IGS','IGS_FI_CAPI_CR_TYPE_INVALID');
      fnd_message.set_token('CR_TYPE',l_v_cr_type_name);
      l_error_desc := fnd_message.get;
      l_status := 'E';
    END IF;
  END IF;

  --If credit class is External or Internal Financial Aid, Fee Calendar Instance and Award Calendar Instances are mandatory.
  --If any one of them is null, then log the error message and skip processing the same record and continue with the next record.
  IF l_status = 'S' THEN
    IF l_v_credit_class IN ('EXTFA','INTFA') THEN
      IF p_rec_disb.ci_cal_type IS NULL OR p_rec_disb.ci_sequence_number IS NULL OR l_fee_cal_type IS NULL OR l_fee_ci_sequence_number IS NULL THEN
        fnd_message.set_name('IGS','IGS_FI_FPAY_MAND');
        l_error_desc := fnd_message.get;
        l_status := 'E';
      END IF;
    END IF;
  END IF;

  --If the disbursement records has Award Calendar Instance, then check if the Award Calendar instance is currently active.
  --else, log the error message and skip processing the same record and continue with the next record.
  IF l_status = 'S' THEN
    IF p_rec_disb.ci_cal_type IS NOT NULL AND p_rec_disb.ci_sequence_number IS NOT NULL THEN
      IF NOT igs_fi_crdapi_util.validate_cal_inst( p_v_cal_type            => p_rec_disb.ci_cal_type,
                                                   p_n_ci_sequence_number  => p_rec_disb.ci_sequence_number,
                                                   p_v_s_cal_cat           => 'AWARD'
                                                  ) THEN
        fnd_message.set_name('IGS','IGS_FI_INV_AWD_YR');
        l_error_desc := fnd_message.get;
        l_status := 'E';
      END IF;
    END IF;
  END IF;

  IF l_status = 'S' THEN
    IF NVL(p_rec_disb.amount,0) >0 THEN
      IF p_rec_disb.sys_fund_type = g_sponsor THEN
        --Create a charge transaction in Sponsor account
        call_charges_api(p_rec_disb,
                         l_fee_cal_type,
                         l_fee_ci_sequence_number,
                         l_spnsr_charge_id,
                         l_status,
                         l_error_desc,
                         p_d_gl_date
                         );
      END IF;

      --Create a credit transaction in Student account
      -- The invoice_id of the charge created above is inserted
      -- into the Credits table as source_invoice_id
      IF l_status = 'S' THEN
         call_credits_api(p_rec_disb,
                          l_fee_cal_type,
                          l_fee_ci_sequence_number,
                          l_sf_credit_id,
                          l_status,
                          l_error_desc,
                          p_d_gl_date,
                          l_spnsr_charge_id
                          );
         IF l_status = 'S' AND l_error_desc IS NOT NULL THEN
            l_v_holds_message := l_error_desc;
         END IF;
      END IF;

    ELSIF NVL(p_rec_disb.amount,0) < 0 THEN
      --Create a charge transaction in Student account
      call_charges_api(p_rec_disb,
                       l_fee_cal_type,
                       l_fee_ci_sequence_number,
                       l_sf_invoice_num,
                       l_status,
                       l_error_desc,
                       p_d_gl_date
                       );
      IF p_rec_disb.sys_fund_type = g_sponsor  AND l_status = 'S' THEN
        -- Create a credit transaction in Sponsor account
        -- The invoice_id of the charge created above is inserted
        -- into the Credits table as source_invoice_id
        call_credits_api(p_rec_disb,
                         l_fee_cal_type,
                         l_fee_ci_sequence_number,
                         l_spnsr_credit_id,
                         l_status,
                         l_error_desc,
                         p_d_gl_date,
                         l_sf_invoice_num
                         );
        IF l_status = 'S' AND l_error_desc IS NOT NULL THEN
           l_v_holds_message := l_error_desc;
        END IF;
      END IF;
    ELSE
      l_status:='ZERO';
    END IF;
  END IF;

  IF l_status <> 'S' THEN
    IF l_status =  'ZERO' THEN
      l_error_desc      :=fnd_message.get_string ('IGF','IGF_DB_ZERO_AMOUNT');
    END IF;
    --If any of the creation of charge or credit failed
    l_log_status := lookup_desc('IGF_AW_LOOKUPS_MSG','ERROR')  ;
    l_sf_credit_id    := NULL;
    l_sf_invoice_num  := NULL;
    l_spnsr_credit_id := NULL;
    l_spnsr_charge_id := NULL;
    l_status_code     := 'E';
    ROLLBACK TO S1;
  ELSE
  --If none of the creation of charge or credit failed
    l_log_status  := lookup_desc('IGF_AW_LOOKUPS_MSG','POSTED');
    l_status_code := 'P';

    --Update Award Table
    OPEN cur_awd(p_rec_disb.award_id);
    FETCH cur_awd INTO l_rec_awd;
    CLOSE cur_awd;
    l_paid_amt := NVL(l_rec_awd.paid_amt,0) + p_rec_disb.amount;

    BEGIN
      -- Bug 5217319 Added call to format amount by rounding off to currency precision for l_paid_amt
      igf_aw_award_pkg.update_row( X_ROWID               => l_rec_awd.rowid,
                                   X_AWARD_ID            => l_rec_awd.award_id,
                                   X_FUND_ID             => l_rec_awd.fund_id,
                                   X_BASE_ID             => l_rec_awd.base_id,
                                   X_OFFERED_AMT         => l_rec_awd.offered_amt,
                                   X_ACCEPTED_AMT        => l_rec_awd.accepted_amt,
                                   X_PAID_AMT            => igs_fi_gen_gl.get_formatted_amount(l_paid_amt),
                                   X_PACKAGING_TYPE      => l_rec_awd.packaging_type,
                                   X_BATCH_ID            => l_rec_awd.batch_id,
                                   X_MANUAL_UPDATE       => l_rec_awd.manual_update,
                                   X_RULES_OVERRIDE      => l_rec_awd.rules_override,
                                   X_AWARD_DATE          => l_rec_awd.award_date,
                                   X_AWARD_STATUS        => l_rec_awd.award_status,
                                   X_ATTRIBUTE_CATEGORY  => l_rec_awd.attribute_category,
                                   X_ATTRIBUTE1          => l_rec_awd.attribute1,
                                   X_ATTRIBUTE2          => l_rec_awd.attribute2,
                                   X_ATTRIBUTE3          => l_rec_awd.attribute3,
                                   X_ATTRIBUTE4          => l_rec_awd.attribute4,
                                   X_ATTRIBUTE5          => l_rec_awd.attribute5,
                                   X_ATTRIBUTE6          => l_rec_awd.attribute6,
                                   X_ATTRIBUTE7          => l_rec_awd.attribute7,
                                   X_ATTRIBUTE8          => l_rec_awd.attribute8,
                                   X_ATTRIBUTE9          => l_rec_awd.attribute9,
                                   X_ATTRIBUTE10         => l_rec_awd.attribute10,
                                   X_ATTRIBUTE11         => l_rec_awd.attribute11,
                                   X_ATTRIBUTE12         => l_rec_awd.attribute12,
                                   X_ATTRIBUTE13         => l_rec_awd.attribute13,
                                   X_ATTRIBUTE14         => l_rec_awd.attribute14,
                                   X_ATTRIBUTE15         => l_rec_awd.attribute15,
                                   X_ATTRIBUTE16         => l_rec_awd.attribute16,
                                   X_ATTRIBUTE17         => l_rec_awd.attribute17,
                                   X_ATTRIBUTE18         => l_rec_awd.attribute18,
                                   X_ATTRIBUTE19         => l_rec_awd.attribute19,
                                   X_ATTRIBUTE20         => l_rec_awd.attribute20,
                                   X_RVSN_ID             => l_rec_awd.rvsn_id,
                                   x_ALT_PELL_SCHEDULE   => l_rec_awd.alt_pell_schedule,
                                   X_MODE                => 'R',
                                   X_AWARD_NUMBER_TXT    => l_rec_awd.award_number_txt,
                                   X_LEGACY_RECORD_FLAG  => NULL,
                                   x_adplans_id          => l_rec_awd.adplans_id,
                                   x_lock_award_flag     => l_rec_awd.lock_award_flag,
                                   x_app_trans_num_txt   => l_rec_awd.app_trans_num_txt,
                                   x_awd_proc_status_code => l_rec_awd.awd_proc_status_code,
                                   x_notification_status_code	=> l_rec_awd.notification_status_code,
                                   x_notification_status_date	=> l_rec_awd.notification_status_date,
                                   x_publish_in_ss_flag       => l_rec_awd.publish_in_ss_flag
                                 );
    EXCEPTION
      WHEN OTHERS THEN
        l_flag1:= FALSE;
    END;

    IF l_flag1 THEN
      --Update Disbursement Table
      OPEN cur_awd_disb(p_rec_disb.award_id,p_rec_disb.disb_num);
      FETCH cur_awd_disb INTO l_rec_awd_disb;
      CLOSE cur_awd_disb;
      /*
      The column DISB_PAID_AMT in the table igf_aw_awd_disb is updated with the Cumulation of existing Disb Paid amount
       with the newly disbursed amount (each iteration) instead of overriding with the new value - Bug 2356801.
      */
      l_disb_paid_amt :=  NVL(l_rec_awd_disb.disb_paid_amt,0) + p_rec_disb.amount;

      /*
        Bug 5080692. Disb Date should be the date on which the transaction is posted to student account.
        Thus X_DISB_DATE should always be updated with SYSDATE.
      */

      BEGIN
        -- Bug 5217319 Added call to format amount by rounding off to currency precision for l_disb_paid_amt
        igf_aw_awd_disb_pkg.update_row( X_ROWID                   => l_rec_awd_disb.rowid,
                                        X_AWARD_ID                => l_rec_awd_disb.award_id,
                                        X_DISB_NUM                => l_rec_awd_disb.disb_num,
                                        X_TP_CAL_TYPE             => l_rec_awd_disb.tp_cal_type,
                                        X_TP_SEQUENCE_NUMBER      => l_rec_awd_disb.tp_sequence_number,
                                        X_DISB_GROSS_AMT          => l_rec_awd_disb.disb_gross_amt,
                                        X_FEE_1                   => l_rec_awd_disb.fee_1,
                                        X_FEE_2                   => l_rec_awd_disb.fee_2,
                                        X_DISB_NET_AMT            => l_rec_awd_disb.disb_net_amt,
                                        X_DISB_DATE               => TRUNC(SYSDATE),
                                        X_TRANS_TYPE              => l_rec_awd_disb.trans_type,
                                        X_ELIG_STATUS             => l_rec_awd_disb.elig_status,
                                        X_ELIG_STATUS_DATE        => l_rec_awd_disb.elig_status_date,
                                        X_AFFIRM_FLAG             => l_rec_awd_disb.affirm_flag,
                                        X_HOLD_REL_IND            => l_rec_awd_disb.hold_rel_ind,
                                        X_MANUAL_HOLD_IND         => l_rec_awd_disb.manual_hold_ind,
                                        X_DISB_STATUS             => l_rec_awd_disb.disb_status,
                                        X_DISB_STATUS_DATE        => l_rec_awd_disb.disb_status_date,
                                        X_LATE_DISB_IND           => l_rec_awd_disb.late_disb_ind,
                                        X_FUND_DIST_MTHD          => l_rec_awd_disb.fund_dist_mthd,
                                        X_PREV_REPORTED_IND       => l_rec_awd_disb.prev_reported_ind,
                                        X_FUND_RELEASE_DATE       => l_rec_awd_disb.fund_release_date,
                                        X_FUND_STATUS             => l_rec_awd_disb.fund_status,
                                        X_FUND_STATUS_DATE        => l_rec_awd_disb.fund_status_date,
                                        X_FEE_PAID_1              => l_rec_awd_disb.fee_paid_1,
                                        X_FEE_PAID_2              => l_rec_awd_disb.fee_paid_2,
                                        X_CHEQUE_NUMBER           => l_rec_awd_disb.cheque_number,
                                        X_LD_CAL_TYPE             => l_rec_awd_disb.ld_cal_type,
                                        X_LD_SEQUENCE_NUMBER      => l_rec_awd_disb.ld_sequence_number,
                                        X_DISB_ACCEPTED_AMT       => l_rec_awd_disb.disb_accepted_amt,
                                        X_DISB_PAID_AMT           => igs_fi_gen_gl.get_formatted_amount(l_disb_paid_amt),
                                        X_RVSN_ID                 => l_rec_awd_disb.rvsn_id,
                                        X_INT_REBATE_AMT          => l_rec_awd_disb.int_rebate_amt,
                                        X_FORCE_DISB              => l_rec_awd_disb.force_disb,
                                        X_MIN_CREDIT_PTS          => l_rec_awd_disb.min_credit_pts,
                                        X_DISB_EXP_DT             => l_rec_awd_disb.disb_exp_dt,
                                        X_VERF_ENFR_DT            => l_rec_awd_disb.verf_enfr_dt,
                                        X_FEE_CLASS               => l_rec_awd_disb.fee_class,
                                        X_SHOW_ON_BILL            => l_rec_awd_disb.show_on_bill,
                                        X_MODE                    => 'R',
                                        x_attendance_type_code    => l_rec_awd_disb.attendance_type_code,
                                        x_base_attendance_type_code => l_rec_awd_disb.base_attendance_type_code,
                                        x_payment_prd_st_date       => l_rec_awd_disb.payment_prd_st_date,
                                        x_change_type_code          => l_rec_awd_disb.change_type_code,
                                        x_fund_return_mthd_code     => l_rec_awd_disb.fund_return_mthd_code,
                                        x_direct_to_borr_flag       => l_rec_awd_disb.direct_to_borr_flag
                                      );
      EXCEPTION
        WHEN OTHERS THEN
          l_flag2:= FALSE;
      END;
    END IF;


    --setting the call to refunds procedure flag to TRUE
    l_refunds:=TRUE;

    --If any of the above two update fails then rollback
    IF ((l_flag1=FALSE) OR (l_flag2=FALSE)) THEN
      ROLLBACK TO S1;
      l_log_status      := lookup_desc('IGF_AW_LOOKUPS_MSG','ERROR')  ;
      l_status_code     :='E';
      l_sf_invoice_num  :=NULL;
      l_sf_credit_id    :=NULL;
      l_spnsr_credit_id :=NULL;
      l_spnsr_charge_id :=NULL;

      l_error_desc:=fnd_message.get;
      IF l_error_desc IS NULL THEN
        l_error_desc:=fnd_message.get_string('IGF','IGF_DB_UPDATE_FAILED');
      END IF;
      --setting the call to refunds procedure flag to FALSE
      l_refunds:=FALSE;
    END IF;

  END IF;

  --Update disbursement detail table
  OPEN cur_disb_dtl(p_rec_disb.award_id,p_rec_disb.disb_num,p_rec_disb.disb_seq_num);
  FETCH cur_disb_dtl INTO l_rec_disb_dtl;
  CLOSE cur_disb_dtl;
  BEGIN
    igf_db_awd_disb_dtl_pkg.update_row( X_ROWID               => l_rec_disb_dtl.rowid,
                                        X_AWARD_ID            => l_rec_disb_dtl.award_id,
                                        X_DISB_NUM            => l_rec_disb_dtl.disb_num,
                                        X_DISB_SEQ_NUM        => l_rec_disb_dtl.disb_seq_num,
                                        X_DISB_GROSS_AMT      => l_rec_disb_dtl.disb_gross_amt,
                                        X_FEE_1               => l_rec_disb_dtl.fee_1,
                                        X_FEE_2               => l_rec_disb_dtl.fee_2,
                                        X_DISB_NET_AMT        => l_rec_disb_dtl.disb_net_amt,
                                        X_DISB_ADJ_AMT        => l_rec_disb_dtl.disb_adj_amt,
                                        X_DISB_DATE           => l_rec_disb_dtl.disb_date,
                                        X_FEE_PAID_1          => l_rec_disb_dtl.fee_paid_1,
                                        X_FEE_PAID_2          => l_rec_disb_dtl.fee_paid_2,
                                        X_DISB_ACTIVITY       => l_rec_disb_dtl.disb_activity,
                                        X_DISB_BATCH_ID       => NULL, -- obsolete
                                        X_DISB_ACK_DATE       => NULL, -- obsolete
                                        X_BOOKING_BATCH_ID    => NULL, -- obsolete
                                        X_BOOKED_DATE         => NULL, -- obsolete
                                        X_DISB_STATUS         => NULL, -- obsolete
                                        X_DISB_STATUS_DATE    => NULL, -- obsolete
                                        X_SF_STATUS           => l_status_code,
                                        X_SF_STATUS_DATE      => TRUNC(SYSDATE),
                                        X_SF_INVOICE_NUM      => l_sf_invoice_num,
                                        X_SF_CREDIT_ID        => l_sf_credit_id,
                                        X_SPNSR_CREDIT_ID     => l_spnsr_credit_id,
                                        X_SPNSR_CHARGE_ID     => l_spnsr_charge_id,
                                        X_ERROR_DESC          => l_error_desc,
                                        X_MODE                => 'R' ,
                                        x_NOTIFICATION_DATE   => l_rec_disb_dtl.notification_date,
                                        X_INTEREST_REBATE_AMT   => l_rec_disb_dtl.interest_rebate_amt,
					x_ld_cal_type		=> l_rec_disb_dtl.ld_cal_type,
					x_ld_sequence_number    => l_rec_disb_dtl.ld_sequence_number
                                      );
  EXCEPTION
    WHEN OTHERS THEN
      l_flag3:= FALSE;
  END;

  --Added as a part of Refunds Build, bug:2144600
  --Refunds to be created if amount>0 and fedral fund code in DLP/FLP
  IF ((l_refunds=TRUE) AND (l_flag3=TRUE)) THEN
    BEGIN
      IF ((p_rec_disb.amount > 0)  AND (p_rec_disb.fed_fund_code IN ('DLP','FLP'))) THEN
        OPEN cur_borrower(p_rec_disb.award_id);
        FETCH cur_borrower INTO l_borrower;
        CLOSE cur_borrower;

        igs_fi_prc_refunds.process_plus(p_credit_id   =>  l_sf_credit_id,
                                        p_borrower_id =>  l_borrower,
                                        p_err_message =>  l_ref_err_msg,
                                        p_status      =>  l_ref_status,
                                        p_d_gl_date   =>  p_d_gl_date
                                        );
        IF l_ref_err_msg IS NOT NULL THEN
          fnd_message.set_name('IGS',l_ref_err_msg);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.log,fnd_message.get_string('IGF','IGF_DB_REFUND_NOT_CREATE'));
    END;
  END IF;

  --If the above update fails then rollback the entire transaction else commit
  IF l_flag3 THEN
    COMMIT;
  ELSE
    ROLLBACK TO S1;
  END IF;

  --Logging the data information
  OPEN cur_person(p_rec_disb.person_id);
  FETCH cur_person INTO l_cur_person;
  CLOSE cur_person;

  -- Following log format modification has been done as part of Bug fix 2782124
  log_messages(lookup_desc('IGF_AW_LOOKUPS_MSG','PERSON_NUMBER'),l_cur_person.person_number);
  log_messages(lookup_desc('IGF_AW_LOOKUPS_MSG','DISBURSEMENT_DATE'),p_rec_disb.disb_date);
  log_messages(lookup_desc('IGF_AW_LOOKUPS_MSG','DISB_AMOUNT'),p_rec_disb.amount);
  log_messages(lookup_desc('IGF_AW_LOOKUPS_MSG','STATUS'),l_log_status);
  fnd_file.put_line(fnd_file.LOG,'  ' || l_error_desc );
  -- Log any messages due to failure to release holds, provided its not already logged as l_error_desc
  IF (l_v_holds_message IS NOT NULL) AND (l_v_holds_message <> NVL(l_error_desc,'NULL'))THEN
     fnd_file.put_line(fnd_file.LOG,'  ' || l_v_holds_message );
  END IF;
  fnd_file.put_line(fnd_file.log, ' ');

END main_disbursement;

PROCEDURE transfer_disb_dtls_to_sf(
                   errbuf             OUT NOCOPY   VARCHAR2,
                   retcode            OUT NOCOPY   NUMBER,
                   p_award_year       IN    VARCHAR2,
                   p_base_id          IN    igf_ap_fa_con_v.base_id%TYPE,
                   p_person_group_id  IN    igs_pe_persid_group_v.group_id%TYPE,
                   p_fund_id          IN    igf_aw_fund_mast.fund_id%TYPE,
                   p_term_calendar    IN    VARCHAR2,
                   p_d_gl_date        IN    VARCHAR2
                  ) AS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  24-Dec-2001
  Purpose        :

  Known limitations,enhancements,remarks:
  Change History
  Who        When           What
  ridas      07-FEB-2006    Bug #5021084. Replaced function IGS_GET_DYNAMIC_SQL with GET_DYNAMIC_SQL
  sapanigr   16-SEP-2005    Modified the cursor, cur_fund to select the fund_code rather than description
                            for the bug# 3810157
  smadathi   01-JUL-2004    Bug 3735396. The logic to handle both static and dynamic person group id
                            incorporated.
  vvutukur   18-Jul-2003    Enh#3038511.FICR106 Build. Added call to generic procedure
                            igs_fi_crdapi_util.get_award_year_status to validate Award Year Status.
  rasahoo    30-june-2003   Removed the cursor cur_ld_cal as it is not used any where.
  shtatiko   02-MAY-2003    Enh# 2831569, Added check for Manage Accounts System Option before running this process.
                            If its value is NULL then process will error out.
  vvutukur   11-Apr-2003    Enh#2831554.Internal Credits API Build. Added validations for currency code and credit instrument 'AID'.
  shtatiko   26-MAR-2003    Bug# 2782124, Removed logging of header in the log file as log format
                            is changed from tabular to form layout.
  smadathi    06-Jan-2003     Bug 2684895. Removed the logging of person group id. Instead
                              used call to igs_fi_gen_005.finp_get_prsid_grp_code to
                              log person group code.
  smadathi    31-dec-2002     Bug 2719776. Modified the cursor cur_person select to fetch
                              the records from view igf_ap_fa_base_rec and igs_pe_person_base_v
                              instead of igf_ap_fa_con_v. This fix is done to remove
                              Non-mergable view exists in the select and to reduce shared memory
                              within the acceptable limit
  smadathi  31-DEC-2002     Bug 2719776. Logic has been modified to raise user defined exception
                            when invalid GL date is passed to the concurrent process. The similar
                            logic has been implemented for invalid values passed to the rest of
                            the concurrent parameters. Henceforth, the whenever invalid values for the concurrent
                            parameteres are provided, control will be transferred to the user defined exception part
                            and un handled exception will not appear in the log file
  vvutukur   20-Nov-2002    Enh#2584986.Added p_d_gl_date parameter to transfer_disb_dtls_to_sf and validations
                            corresponding to this parameter.
  vchappid   11-Feb-2002    Enh#2191470,When the Load Cal Parameter is passed, then check if there exists a
                            superior Fee Cal relation, if there is no relation set then log error
                            and abort the process
********************************************************************************************** */

  CURSOR cur_person IS
  SELECT pe.person_number person_number ,
         fabase.person_id person_id
  FROM   igf_ap_fa_base_rec fabase,
         igs_pe_person_base_v pe
  WHERE  fabase.person_id = pe.person_id
  AND    base_id= p_base_id;
  l_cur_person cur_person%ROWTYPE;

  CURSOR cur_fund IS
  SELECT fund_code
  FROM   igf_aw_fund_mast
  WHERE  fund_id = p_fund_id;
  l_cur_fund   cur_fund%ROWTYPE;

  CURSOR cur_base(cp_person_id          igf_ap_fa_base_rec_all.person_id%TYPE,
                  cp_ci_cal_type        igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                  cp_ci_sequence_number igf_ap_fa_base_rec_all.ci_sequence_number%TYPE)
                      IS
  SELECT base_id
  FROM   igf_ap_fa_base_rec
  WHERE  person_id = cp_person_id
  AND    ci_cal_type = cp_ci_cal_type
  AND    ci_sequence_number = cp_ci_sequence_number;

  l_cur_base   cur_base%ROWTYPE;

  -- declaration of Ref cursor and ref cursor variable type
  TYPE typ_ref_cur_persid_grp IS REF CURSOR;
  c_ref_personid_grp typ_ref_cur_persid_grp;

  -- declaration of variables to receive values returned from get_dynamic_sql callout
  -- l_v_dynamicsql: to receive the value of dynamic sql
  -- l_v_status    : to receive outbound parameter p_status
  l_v_dynamicsql          VARCHAR2(32767);
  l_v_status              VARCHAR2(1);

  l_n_person_id            hz_parties.party_id%TYPE;
  l_rec_disb               cur_disb%ROWTYPE;
  l_cal_type               igf_ap_award_year_v.cal_type%TYPE;
  l_sequence_number        igf_ap_award_year_v.sequence_number%TYPE;
  l_record_count           NUMBER :=0;
  l_ld_cal_type            igf_aw_awd_ld_cal_v.ld_cal_type%TYPE;
  l_ld_sequence_number     igf_aw_awd_ld_cal_v.ld_sequence_number%TYPE;

  l_v_message_name         fnd_new_messages.message_name%TYPE;
  l_v_closing_status       gl_period_statuses.closing_status%TYPE;
  l_d_gl_date              igs_fi_credits_all.gl_date%TYPE;

  l_exp_err_exception      EXCEPTION;
  l_v_curr_desc            fnd_currencies_tl.name%TYPE;
  l_v_manage_accounts      igs_fi_control_all.manage_accounts%TYPE;
  l_v_awd_yr_status_cd     igf_ap_batch_aw_map.award_year_status_code%TYPE;
  lv_profile_value         VARCHAR2(30);
  lv_person_id             igf_ap_fa_base_rec_all.person_id%TYPE;
  lv_group_type            igs_pe_persid_group_v.group_type%TYPE;

BEGIN

  igf_aw_gen.set_org_id(NULL) ;           --  sets the orgid
  retcode := 0 ;                          -- initialises the out NOCOPY parameter to 0

--Logging the parameters
  --Getting the person_number from base_id
  IF p_base_id IS NOT NULL THEN
    OPEN cur_person;
    FETCH cur_person INTO l_cur_person;
    CLOSE cur_person;
  ELSE
    l_cur_person.person_number:=NULL;
    l_cur_person.person_id    :=NULL;
  END IF;

  --Getting the fund description
  IF p_fund_id IS NOT NULL THEN
    OPEN  cur_fund;
    FETCH cur_fund INTO l_cur_fund;
    CLOSE cur_fund;
  ELSE
    l_cur_fund.fund_code :=NULL;
  END IF;

  --Getting the load calendar
  IF p_term_calendar IS NOT NULL THEN
    l_ld_cal_type :=RTRIM(SUBSTR(p_term_calendar,1,10));
    l_ld_sequence_number := TO_NUMBER(RTRIM(SUBSTR(p_term_calendar,12)));
    -- Check for existance of relation with Fee Cal is done after logging parameters.
  ELSE
    l_ld_cal_type       :=NULL;
    l_ld_sequence_number:=NULL;
  END IF;

  --Convert the parameter p_d_gl_date from VARCHAR2 to DATE datatype.
  l_d_gl_date := IGS_GE_DATE.IGSDATE(p_d_gl_date);

  log_messages(lookup_desc('IGF_AW_LOOKUPS_MSG','AWARD_YEAR'),p_award_year);
  log_messages(lookup_desc('IGF_AW_LOOKUPS_MSG','PERSON_NUMBER'),l_cur_person.person_number );
  log_messages(lookup_desc('IGF_AW_LOOKUPS_MSG','PERSON_GROUP'),igs_fi_gen_005.finp_get_prsid_grp_code(p_person_group_id));
  log_messages(lookup_desc('IGF_AW_LOOKUPS_MSG','FUND_CODE'),l_cur_fund.fund_code);
  log_messages(lookup_desc('IGF_AW_LOOKUPS_MSG','TERM'),l_ld_cal_type||'  '||l_ld_sequence_number);
  log_messages(igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','GL_DATE'),l_d_gl_date);
  fnd_file.put_line(fnd_file.log,' ');

  -- Get the value of "Manage Accounts" System Option value.
  -- If this value is NULL then this process should error out.
  igs_fi_com_rec_interface.chk_manage_account ( p_v_manage_acc   => l_v_manage_accounts,
                                                p_v_message_name => l_v_message_name );
  IF l_v_manage_accounts IS NULL THEN
    fnd_message.set_name ( 'IGS', l_v_message_name );
    fnd_file.put_line( fnd_file.LOG, fnd_message.get );
    RAISE l_exp_err_exception;
  END IF;

  IF p_term_calendar IS NOT NULL THEN
    -- Start of modification Enh#2191470
    -- If the Load Calendar instance is passed then check whether a relation exists with the Fee Cal
    IF (igs_fi_gen_001.finp_chk_lfci_reln( l_ld_cal_type,
                                           l_ld_sequence_number,
                                           'LOAD')= 'FALSE') THEN
      fnd_message.set_name('IGS','IGS_FI_NO_RELN_EXISTS');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE l_exp_err_exception;
    END IF;
  END IF;
  -- End of modification Enh#2191470

  --Validating if all the mandatory parameter are passed
  IF (p_award_year IS NULL) THEN
    fnd_message.set_name('IGS','IGS_FI_PARAMETER_NULL');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    RAISE l_exp_err_exception;
  END IF;

  --GL Date parameter is mandatory to this concurrent job, hence it is passed as null, error out NOCOPY the job.
  IF p_d_gl_date IS NULL THEN
    fnd_message.set_name('IGS','IGS_FI_PARAMETER_NULL');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    RAISE l_exp_err_exception;
  END IF;

  --Getting cal type and  sequence number
  l_cal_type :=RTRIM(SUBSTR(p_award_year,1,10));
  l_sequence_number := TO_NUMBER(RTRIM(SUBSTR(p_award_year,11)));

--Validating award year
    IF NOT validate_award_year(l_cal_type,l_sequence_number) THEN
      fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE l_exp_err_exception;
    END IF;

  l_v_message_name := NULL;
  --Validate the Award Year Status. If the status is not open, log the message in log file and
  --complete the process with error.
  igs_fi_crdapi_util.get_award_year_status( p_v_awd_cal_type     =>  l_cal_type,
                                            p_n_awd_seq_number   =>  l_sequence_number,
                                            p_v_awd_yr_status    =>  l_v_awd_yr_status_cd,
                                            p_v_message_name     =>  l_v_message_name
                                           );
  IF l_v_message_name IS NOT NULL THEN
    IF l_v_message_name = 'IGF_SP_INVALID_AWD_YR_STATUS' THEN
      fnd_message.set_name('IGF',l_v_message_name);
    ELSE
      fnd_message.set_name('IGS',l_v_message_name);
    END IF;
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    RAISE l_exp_err_exception;
  END IF;

--Validating person Id and person id group cannot be present at a same time
  IF p_base_id IS NOT NULL AND p_person_group_id IS NOT NULL THEN
    fnd_message.set_name('IGS','IGS_FI_PRS_OR_PRSIDGRP');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    RAISE l_exp_err_exception;
  END IF;

--Validating person id group
  IF p_person_group_id IS NOT NULL THEN
    IF NOT validate_persid_grp(p_person_group_id) THEN
      fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE l_exp_err_exception;
    END IF;
  END IF;

--Validating base_id
  IF p_base_id IS NOT NULL THEN
    IF NOT validate_base_id(p_base_id,l_cal_type,l_sequence_number) THEN
      fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE l_exp_err_exception;
    END IF;
  END IF;

--Validating fund_code
  IF p_fund_id IS NOT NULL THEN
    IF NOT validate_fund_id(p_fund_id,l_cal_type,l_sequence_number) THEN
      fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE l_exp_err_exception;
    END IF;
  END IF;

  --Validate the GL Date.
  igs_fi_gen_gl.get_period_status_for_date(p_d_date            => l_d_gl_date,
                                           p_v_closing_status  => l_v_closing_status,
                                           p_v_message_name    => l_v_message_name
                                           );
  IF l_v_message_name IS NOT NULL THEN
    fnd_message.set_name('IGS',l_v_message_name);
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    RAISE l_exp_err_exception;
  END IF;

  --Error out  the concurrent process if the GL Date is not a valid one.
  IF l_v_closing_status IN ('C','N','W') THEN
    fnd_message.set_name('IGS','IGS_FI_INVALID_GL_DATE');
    fnd_message.set_token('GL_DATE',l_d_gl_date);
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    RAISE l_exp_err_exception;
  END IF;

  l_v_message_name := NULL;
  --Capture the default currency that is set up in System Options Form.
  igs_fi_gen_gl.finp_get_cur( p_v_currency_cd    => g_v_currency,
                              p_v_curr_desc      => l_v_curr_desc,
                              p_v_message_name   => l_v_message_name
                             );
  IF l_v_message_name IS NOT NULL THEN
    fnd_message.set_name('IGS',l_v_message_name);
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    RAISE l_exp_err_exception;
  END IF;

  --Check if the credit instrument - 'AID' is valid and active lookup code for the 'IGS_FI_CREDIT_INSTRUMENT' lookup type
  --as on the current system date.
  --if not valid, then log the error message and skip processing the same record and continue with the next record.
  IF NOT igs_fi_crdapi_util.validate_igs_lkp( p_v_lookup_type  => 'IGS_FI_CREDIT_INSTRUMENT',
                                              p_v_lookup_code  => 'AID') THEN
    fnd_message.set_name('IGS','IGS_FI_CAPI_CRD_INSTR_NULL');
    fnd_message.set_token('CR_INSTR',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_CREDIT_INSTRUMENT','AID'));
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    RAISE l_exp_err_exception;
  END IF;

  --To check whether the profile value is set to a value of 'When Transfers are made to student finance' or not
  fnd_profile.get('IGF_AW_LOCK_COA',lv_profile_value);

  g_print_msg :=  NULL;

  IF p_base_id IS NOT NULL THEN
   --When base id is provided
    FOR l_rec_disb IN cur_disb(l_cal_type,
                               l_sequence_number,
                               p_fund_id,
                               l_cur_person.person_id,
                               l_ld_cal_type,
                               l_ld_sequence_number,
                               l_v_manage_accounts) LOOP
      main_disbursement(l_rec_disb,
                        l_d_gl_date);
      l_record_count := l_record_count + 1;
    END LOOP;

    --lock COA at the student level
    IF lv_profile_value = 'TRANSFER' THEN

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_sf_integration.transfer_disb_dtls_to_sf.debug','calling igf_aw_coa_gen.doLock for person_id '||l_cur_person.person_id);
        END IF;

        OPEN cur_base(l_cur_person.person_id,l_cal_type,l_sequence_number);
        FETCH cur_base INTO l_cur_base;
        CLOSE cur_base;

        IF NOT igf_aw_coa_gen.isCOALocked(l_cur_base.base_id) THEN
          lv_locking_success := igf_aw_coa_gen.doLock(l_cur_base.base_id);

          IF lv_locking_success = 'Y' THEN
             fnd_message.set_name('IGF','IGF_AW_STUD_COA_LOCK');
             fnd_message.set_token('PERSON_NUM',igf_gr_gen.get_per_num (l_cur_base.base_id));
             fnd_file.put_line(fnd_file.log,RPAD(' ',10) ||fnd_message.get);
             lv_locking_success := 'N' ;
          END IF;
        END IF;

    END IF;


  ELSIF p_person_group_id IS NOT NULL THEN
    --Bug #5021084. Replaced function IGS_GET_DYNAMIC_SQL with GET_DYNAMIC_SQL
    l_v_dynamicsql := igs_pe_dynamic_persid_group.get_dynamic_sql(p_groupid => p_person_group_id,
                                                                  p_status  => l_v_status,
                                                                  p_group_type => lv_group_type);

    -- if the above call out returns an error status, the error message is logged in the
    -- log file and process errors out
    IF l_v_status <> 'S' THEN
      fnd_message.set_name('IGF','IGF_AP_INVALID_QUERY');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE l_exp_err_exception;
    END IF;

    --Bug #5021084. Passing Group ID if the group type is STATIC.
    IF lv_group_type = 'STATIC' THEN
      OPEN c_ref_personid_grp FOR l_v_dynamicsql USING p_person_group_id;
    ELSIF lv_group_type = 'DYNAMIC' THEN
      OPEN c_ref_personid_grp FOR l_v_dynamicsql;
    END IF;

    LOOP
      FETCH c_ref_personid_grp INTO l_n_person_id;
      EXIT WHEN c_ref_personid_grp%NOTFOUND;

      FOR l_rec_disb IN cur_disb(l_cal_type,
                                 l_sequence_number,
                                 p_fund_id,
                                 l_n_person_id,
                                 l_ld_cal_type,
                                 l_ld_sequence_number,
                                 l_v_manage_accounts) LOOP
        main_disbursement(l_rec_disb,
                          l_d_gl_date);
        l_record_count := l_record_count + 1;
      END LOOP;

      --lock COA at the student level
      IF lv_profile_value = 'TRANSFER' THEN

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_sf_integration.transfer_disb_dtls_to_sf.debug','calling igf_aw_coa_gen.doLock for person_id '||l_n_person_id);
          END IF;

        OPEN cur_base(l_n_person_id,l_cal_type,l_sequence_number);
        FETCH cur_base INTO l_cur_base;
        CLOSE cur_base;

        IF NOT igf_aw_coa_gen.isCOALocked(l_cur_base.base_id) THEN
          lv_locking_success := igf_aw_coa_gen.doLock(l_cur_base.base_id);

          IF lv_locking_success = 'Y' THEN
             fnd_message.set_name('IGF','IGF_AW_STUD_COA_LOCK');
             fnd_message.set_token('PERSON_NUM',igf_gr_gen.get_per_num (l_cur_base.base_id));
             fnd_file.put_line(fnd_file.log,RPAD(' ',10) ||fnd_message.get);
             lv_locking_success := 'N' ;
          END IF;
        END IF;
      END IF;

    END LOOP;
    CLOSE c_ref_personid_grp;
  ELSE
    lv_person_id  := NULL;

    --When neither of base id nor group id is provided
    FOR l_rec_disb IN cur_disb(l_cal_type,
                               l_sequence_number,
                               p_fund_id,
                               NULL,
                               l_ld_cal_type,
                               l_ld_sequence_number,
                               l_v_manage_accounts) LOOP
      main_disbursement(l_rec_disb,
                        l_d_gl_date);
      l_record_count := l_record_count + 1;

      IF g_print_msg IS NOT NULL AND lv_person_id<>l_rec_disb.person_id THEN
        fnd_file.put_line(fnd_file.log,RPAD(' ',10) ||g_print_msg);
        g_print_msg := NULL;
        FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
      END IF;

      --lock COA at the student level
      IF lv_profile_value = 'TRANSFER' THEN
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_sf_integration.transfer_disb_dtls_to_sf.debug','calling igf_aw_coa_gen.doLock for person_id '||lv_person_id);
          END IF;

        OPEN cur_base(lv_person_id,l_cal_type,l_sequence_number);
        FETCH cur_base INTO l_cur_base;
        CLOSE cur_base;

        IF NOT igf_aw_coa_gen.isCOALocked(l_cur_base.base_id) THEN
          lv_locking_success := igf_aw_coa_gen.doLock(l_cur_base.base_id);

          IF lv_locking_success = 'Y' THEN
             fnd_message.set_name('IGF','IGF_AW_STUD_COA_LOCK');
             fnd_message.set_token('PERSON_NUM',igf_gr_gen.get_per_num (l_cur_base.base_id));
             fnd_file.put_line(fnd_file.log,RPAD(' ',10) ||fnd_message.get);
             lv_locking_success := 'N' ;
          END IF;
        END IF;


          lv_person_id  :=  l_rec_disb.person_id;


      END IF;
    END LOOP;

    --lock COA at the student level
    IF g_print_msg IS NOT NULL THEN
      fnd_file.put_line(fnd_file.log,RPAD(' ',10) ||g_print_msg);
    END IF;

  END IF;

  fnd_file.put_line(fnd_file.log,fnd_message.get_string('IGS','IGS_GE_TOTAL_REC_PROCESSED')||TO_CHAR(l_record_count));

  EXCEPTION
    WHEN l_exp_err_exception THEN
      retcode := 2;
    WHEN OTHERS THEN
      retcode := 2;
      errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION') || ' : ' ||sqlerrm;
      igs_ge_msg_stack.conc_exception_hndl;
END transfer_disb_dtls_to_sf;

END igf_db_sf_integration;

/
