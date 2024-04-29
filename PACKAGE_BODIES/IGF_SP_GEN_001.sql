--------------------------------------------------------
--  DDL for Package Body IGF_SP_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SP_GEN_001" AS
/* $Header: IGFSP04B.pls 120.1 2006/05/15 23:51:26 svuppala noship $ */

 ------------------------------------------------------------------------------------
  --Created by  : smanglm ( Oracle IDC)
  --Date created: 2002/01/11
  --
  --Purpose:  Created as part of the build for DLD Sponsorship
  --          This package has generic fucntion which can be used by the system.
  --          They are;
  --          i)    get_credit_points
  --          ii)   get_program_charge
  --          iii)  check_unit_attempt
  --          iv)   check_min_att_type
  --          v)    get_fee_cls_charge
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --smadathi    17-May-2002     Bug 2369173. The function get_program_charge
  --                            was modified.
  --svuppala    16-May-2006     Bug 5194095 .Removed the functionS get_program_charge,get_fee_cls_charge.
  --                            Created procedures get_sponsor_amts, log_to_fnd.
  -------------------------------------------------------------------------------------

  -- Procedure for enabling statement level logging
  PROCEDURE log_to_fnd (
    p_v_module IN VARCHAR2,
    p_v_string IN VARCHAR2
  );

PROCEDURE get_sponsor_amts (
                             p_n_person_id      IN  hz_parties.party_id%TYPE,
                             p_v_fee_cal_type   IN  igs_ca_inst_all.cal_type%TYPE,
                             p_n_fee_seq_number IN  igs_ca_inst_all.sequence_number%TYPE,
                             p_v_fund_code      IN  igf_aw_fund_cat_all.fund_code%TYPE,
                             p_v_ld_cal_type    IN  igs_ca_inst_all.cal_type%TYPE,
                             p_n_ld_seq_number  IN  igs_ca_inst_all.sequence_number%TYPE,
                             p_v_fee_class      IN  igs_fi_fee_type_all.fee_class%TYPE,
                             p_v_course_cd      IN  igs_fi_inv_int_all.course_cd%TYPE,
                             p_v_unit_cd        IN  igs_ps_unit_ofr_opt.unit_cd%TYPE,
                             p_n_unit_ver_num   IN  igs_ps_unit_ofr_opt_all.version_number%TYPE,
                             x_eligible_amount  OUT NOCOPY NUMBER,
                             x_new_spnsp_amount OUT NOCOPY NUMBER
                           ) AS
-----------------------------------------------------------------------------------
  --Created by  : svuppala ( Oracle IDC)
  --Date created: 28-Apr-2006
  --
  --Purpose:  Created as part of Bug 4658908.
  --          To determine both the new sponsor amount and the sponsor amount that can be given to student,
  --          Fee calendar type and fee calendar sequence number combination so
  --          that Sponsor amount does not exceed the total charge amount of the charges.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------------------------

-- cursor is used if Fee Class parameter has not been passed (Total Sponsor amount case)
CURSOR cur_get_all_charges (
                             cp_n_person_id      IN  hz_parties.party_id%TYPE,
                             cp_v_fee_cal_type   IN  igs_ca_inst_all.cal_type%TYPE,
                             cp_n_fee_seq_number IN  igs_ca_inst_all.sequence_number%TYPE
                           ) IS
SELECT   inv.invoice_id, inv.invoice_amount
FROM     igs_fi_inv_int_all inv
WHERE    inv.person_id    = cp_n_person_id
AND      inv.fee_cal_type = cp_v_fee_cal_type
AND      inv.fee_ci_sequence_number = cp_n_fee_seq_number
AND      inv.transaction_type NOT IN ('RETENTION','REFUND','AID_ADJ','WAIVER_ADJ','SPONSOR','PAY_PLAN');

-- cursor is used if course code or unit code and version number parameters are not passed.
CURSOR cur_get_charges_no_coursecd (
                                    cp_n_person_id      IN  hz_parties.party_id%TYPE,
                                    cp_v_fee_cal_type   IN  igs_ca_inst_all.cal_type%TYPE,
                                    cp_n_fee_seq_number IN  igs_ca_inst_all.sequence_number%TYPE,
                                    cp_v_fee_class      IN  igs_fi_fee_type_all.fee_class%TYPE
                                  ) IS
SELECT   inv.invoice_id, inv.invoice_amount
FROM     igs_fi_inv_int_all inv,
         igs_fi_fee_type_all ft
WHERE    inv.person_id    = cp_n_person_id
AND      inv.fee_cal_type = cp_v_fee_cal_type
AND      inv.fee_ci_sequence_number = cp_n_fee_seq_number
AND      inv.transaction_type NOT IN ('RETENTION','REFUND','AID_ADJ','WAIVER_ADJ','SPONSOR','PAY_PLAN')
AND      ft.fee_type = inv.fee_type
AND      ft.fee_class = cp_v_fee_class;

CURSOR cur_get_charges_with_coursecd ( cp_n_person_id      IN  hz_parties.party_id%TYPE,
                                       cp_v_fee_cal_type   IN  igs_ca_inst_all.cal_type%TYPE,
                                       cp_n_fee_seq_number IN  igs_ca_inst_all.sequence_number%TYPE,
                                       cp_v_fee_class      IN  igs_fi_fee_type_all.fee_class%TYPE,
                                       cp_v_course_cd      IN  igs_fi_inv_int_all.course_cd%TYPE
                                     ) IS
SELECT   inv.invoice_id, inv.invoice_amount
FROM     igs_fi_inv_int_all inv,
         igs_fi_fee_type_all ft
WHERE    inv.person_id    = cp_n_person_id
AND      inv.fee_cal_type = cp_v_fee_cal_type
AND      inv.fee_ci_sequence_number = cp_n_fee_seq_number
AND      inv.transaction_type <> 'RETENTION'
AND      inv.course_cd = cp_v_course_cd
AND      ft.fee_type = inv.fee_type
AND      ft.fee_class = cp_v_fee_class;

CURSOR cur_get_charges_for_unit (
                                  cp_n_person_id      IN  hz_parties.party_id%TYPE,
                                  cp_v_fee_cal_type   IN  igs_ca_inst_all.cal_type%TYPE,
                                  cp_n_fee_seq_number IN  igs_ca_inst.sequence_number%TYPE,
                                  cp_v_fee_class      IN igs_fi_fee_type_all.fee_class%TYPE,
                                  cp_v_unit_cd        IN igs_ps_unit_ver_all.unit_cd%TYPE,
                                  cp_n_unit_ver_num   IN  igs_ps_unit_ver_all.version_number%TYPE
                                ) IS
SELECT   inv.invoice_id, inv.invoice_amount
FROM     igs_fi_inv_int_all inv,
         igs_fi_invln_int_all invln,
         igs_fi_fee_type_all ft,
         igs_ps_unit_ofr_opt_all uoo
WHERE    inv.person_id    = cp_n_person_id
AND      inv.fee_cal_type = cp_v_fee_cal_type
AND      inv.fee_ci_sequence_number =cp_n_fee_seq_number
AND      inv.transaction_type <> 'RETENTION'
AND      invln.invoice_id   = inv.invoice_id
AND      ft.fee_type        = inv.fee_type
AND      ft.fee_class       = cp_v_fee_class
AND      uoo.uoo_id         = invln.uoo_id
AND      uoo.unit_cd        = cp_v_unit_cd
AND      uoo.version_number = cp_n_unit_ver_num;


CURSOR   cur_neg_chg_adj(cp_n_invoice_id  igs_fi_inv_int_all.invoice_id%TYPE)
IS
SELECT   appl.amount_applied AS amount_applied
FROM     igs_fi_applications appl,
         igs_fi_credits_all crd,
         igs_fi_cr_types_all cr
WHERE    appl.invoice_id         = cp_n_invoice_id
AND      appl.application_type   = 'APP'
AND      crd.credit_id           = appl.credit_id
AND      crd.credit_type_id      = cr.credit_type_id
AND      cr.credit_class         = 'CHGADJ';

CURSOR   cur_waiver_credit(cp_n_invoice_id     IN  igs_fi_inv_int_all.invoice_id%TYPE,
                           cp_v_fee_cal_type   IN  igs_ca_inst_all.cal_type%TYPE,
                           cp_n_fee_seq_number IN  igs_ca_inst_all.sequence_number%TYPE)
IS
SELECT   igs_fi_gen_007.get_sum_appl_amnt (appl.application_id) amount_applied , application_id
FROM     igs_fi_applications appl,
         igs_fi_credits_all crd,
         igs_fi_cr_types_all cr
WHERE    appl.invoice_id            = cp_n_invoice_id
AND      appl.application_type      = 'APP'
AND      crd.credit_id              = appl.credit_id
AND      crd.status                 = 'CLEARED'
AND      crd.fee_cal_type           = cp_v_fee_cal_type
AND      crd.fee_ci_sequence_number = cp_n_fee_seq_number
AND      crd.credit_type_id         = cr.credit_type_id
AND      cr.credit_class            = 'WAIVER';

CURSOR   cur_sponsor_credit(cp_n_invoice_id      IN  igs_fi_inv_int_all.invoice_id%TYPE,
                            cp_v_fee_cal_type    IN  igs_ca_inst_all.cal_type%TYPE,
                            cp_n_fee_seq_number  IN  igs_ca_inst.sequence_number%TYPE,
                            cp_v_ld_cal_type     IN  igs_ca_inst_all.cal_type%TYPE,
                            cp_n_ld_seq_number   IN  igs_ca_inst.sequence_number%TYPE,
                            cp_v_fund_code       IN  igf_aw_fund_cat_all.fund_code%TYPE)
IS
SELECT   appl.amount_applied AS amount_applied, appl.credit_id as credit_id
FROM     igs_fi_applications appl,
         igs_fi_credits_all crd,
         igs_fi_cr_types_all cr
WHERE    appl.invoice_id            = cp_n_invoice_id
AND      appl.application_type      = 'APP'
AND      crd.credit_id              = appl.credit_id
AND      crd.fee_cal_type           = cp_v_fee_cal_type
AND      crd.fee_ci_sequence_number = cp_n_fee_seq_number
AND      crd.status                 = 'CLEARED'
AND      crd.credit_type_id         = cr.credit_type_id
AND      cr.credit_class            = 'SPNSP'
AND      NOT EXISTS (
SELECT   '1'
FROM     igf_db_awd_disb_dtl_all disb_dtl
       , igf_aw_awd_disb_all disb
       , igf_aw_award_all awd
       , igf_aw_fund_mast_all fmast
WHERE   disb_dtl.sf_credit_id   =  crd.credit_id
AND     disb.award_id           =  disb_dtl.award_id
AND     disb.disb_num           =  disb_dtl.disb_num
AND     disb.ld_cal_type        =  cp_v_ld_cal_type
AND     disb.ld_sequence_number =  cp_n_ld_seq_number
AND     awd.award_id            =  disb.award_id
AND     fmast.fund_id           =  awd.fund_id
AND     fmast.fund_code         =  cp_v_fund_code
AND     ROWNUM = 1
);


-- PL/SQL record for the Invoice Information
  TYPE invoice_rec IS RECORD(invoice_id      igs_fi_inv_int_all.invoice_id%TYPE,
                             invoice_amount  igs_fi_inv_int_all.invoice_amount%TYPE );
  TYPE invoice_table_type IS TABLE OF invoice_rec INDEX BY PLS_INTEGER;
  l_v_invoice_info             invoice_table_type;
  l_n_invoice_amt              igs_fi_inv_int_all.invoice_amount%TYPE;
  l_n_invoice_id               igs_fi_inv_int_all.invoice_id%TYPE;
  l_n_chgadj_amt               igs_fi_inv_int_all.invoice_amount%TYPE;
  l_n_net_invoice_amt          igs_fi_inv_int_all.invoice_amount%TYPE;
  l_n_wavapp_amt               igs_fi_inv_int_all.invoice_amount%TYPE;
  l_n_spnsp_amt                igs_fi_inv_int_all.invoice_amount%TYPE;
  l_n_eligible_spnsp_amt       igs_fi_inv_int_all.invoice_amount%TYPE;
  l_new_spnsp_amount           igs_fi_inv_int_all.invoice_amount%TYPE;
  l_n_cntr NUMBER;
  l_v_found VARCHAR(1);
BEGIN

  log_to_fnd(p_v_module => 'get_sponsor_amts',
             p_v_string => ' Entered Procedure get_sponsor_amts: The input parameters are '||
                           ' p_v_fee_cal_type     : '  || p_v_fee_cal_type      ||
                           ' p_n_fee_seq_number   : '  || p_n_fee_seq_number    ||
                           ' p_v_fund_code        : '  || p_v_fund_code         ||
                           ' p_v_ld_cal_type      : '  || p_v_ld_cal_type       ||
                           ' p_n_ld_seq_number    : '  || p_n_ld_seq_number     ||
                           ' p_v_fee_class        : '  || p_v_fee_class         ||
                           ' p_n_person_id        : '  || p_n_person_id         ||
                           ' p_v_course_cd        : '  || p_v_course_cd         ||
                           ' p_v_unit_cd          : '  || p_v_unit_cd           ||
                           ' p_n_unit_ver_num     : '  || p_n_unit_ver_num
             );
   IF p_v_fee_class IS NULL THEN
      OPEN cur_get_all_charges(p_n_person_id, p_v_fee_cal_type, p_n_fee_seq_number);
      FETCH cur_get_all_charges BULK COLLECT INTO l_v_invoice_info;
      CLOSE cur_get_all_charges;
   ELSIF p_v_unit_cd IS NOT NULL AND p_n_unit_ver_num IS NOT NULL THEN
      OPEN cur_get_charges_for_unit(p_n_person_id, p_v_fee_cal_type, p_n_fee_seq_number, p_v_fee_class, p_v_unit_cd, p_n_unit_ver_num);
      FETCH cur_get_charges_for_unit BULK COLLECT INTO l_v_invoice_info;
      CLOSE cur_get_charges_for_unit;
   ELSIF p_v_course_cd IS NOT NULL THEN
      OPEN cur_get_charges_with_coursecd( p_n_person_id, p_v_fee_cal_type, p_n_fee_seq_number, p_v_fee_class , p_v_course_cd );
      FETCH cur_get_charges_with_coursecd BULK COLLECT INTO l_v_invoice_info;
      CLOSE cur_get_charges_with_coursecd;
   ELSE
      OPEN cur_get_charges_no_coursecd( p_n_person_id, p_v_fee_cal_type, p_n_fee_seq_number, p_v_fee_class );
      FETCH cur_get_charges_no_coursecd BULK COLLECT INTO l_v_invoice_info;
      CLOSE cur_get_charges_no_coursecd;
   END IF;

  IF l_v_invoice_info.COUNT = 0 THEN

    log_to_fnd(p_v_module => 'get_sponsor_amts',
               p_v_string => 'Both x_new_spnsp_amount, x_eligible_amount  are  0'
            );

      x_eligible_amount  := 0;
      x_new_spnsp_amount := 0;
      RETURN;
  END IF;
  l_n_eligible_spnsp_amt := 0;
  l_new_spnsp_amount     := 0;
  FOR l_n_cntr in l_v_invoice_info.FIRST..l_v_invoice_info.LAST
  LOOP
     l_n_invoice_amt := l_v_invoice_info(l_n_cntr).invoice_amount;
     l_n_invoice_id  := l_v_invoice_info(l_n_cntr).invoice_id;

     log_to_fnd(p_v_module => 'get_sponsor_amts',
                p_v_string => 'Context Charge id     : '||l_n_invoice_id ||
                              'Context Charge Amount : '||l_n_invoice_amt
                              );

     l_n_chgadj_amt := 0;

     FOR  rec_neg_chg_adj IN cur_neg_chg_adj( l_n_invoice_id )
     LOOP
         l_n_chgadj_amt := l_n_chgadj_amt + rec_neg_chg_adj.amount_applied;
     END LOOP;
     log_to_fnd(p_v_module => 'get_sponsor_amts',
                p_v_string => 'Sum of -ve Charge Adj. Credits : ' || l_n_chgadj_amt );

     l_n_net_invoice_amt :=  l_n_invoice_amt - l_n_chgadj_amt;
     l_n_wavapp_amt := 0;

     FOR  rec_waiver_credit IN cur_waiver_credit( l_n_invoice_id , p_v_fee_cal_type, p_n_fee_seq_number)
     LOOP
         l_n_wavapp_amt := l_n_wavapp_amt + rec_waiver_credit.amount_applied;
     END LOOP;
     log_to_fnd(p_v_module => 'get_sponsor_amts',
                p_v_string => 'Sum of Waiver Credits : ' || l_n_wavapp_amt );
     l_n_spnsp_amt := 0;

     FOR  rec_sponsor_credit IN cur_sponsor_credit( l_n_invoice_id , p_v_fee_cal_type, p_n_fee_seq_number, p_v_ld_cal_type, p_n_ld_seq_number, p_v_fund_code)
     LOOP
           l_n_spnsp_amt := l_n_spnsp_amt + rec_sponsor_credit.amount_applied;
     END LOOP;
     log_to_fnd(p_v_module => 'get_sponsor_amts',
                p_v_string => 'Sum of Sponsorship Credits : ' || l_n_wavapp_amt );


   l_new_spnsp_amount     := l_new_spnsp_amount + ( l_n_net_invoice_amt - l_n_wavapp_amt );

   l_n_eligible_spnsp_amt := l_n_eligible_spnsp_amt + (l_n_net_invoice_amt - l_n_wavapp_amt - l_n_spnsp_amt);


   END LOOP;
   log_to_fnd(p_v_module => 'get_sponsor_amts',
              p_v_string => 'New Sponsorship amount : ' || l_new_spnsp_amount );

   log_to_fnd(p_v_module => 'get_sponsor_amts',
              p_v_string => 'Eligible Sponsorship amount : ' || l_n_eligible_spnsp_amt );

   x_new_spnsp_amount := l_new_spnsp_amount;
   x_eligible_amount  := l_n_eligible_spnsp_amt;

END get_sponsor_amts;


  FUNCTION check_unit_attempt
              (p_person_id                IN  igs_pe_person.person_id%TYPE,
               p_ld_cal_type              IN  igs_ca_inst.cal_type%TYPE,
               p_ld_ci_sequence_number    IN  igs_ca_inst.sequence_number%TYPE,
               p_course_cd                IN  igs_ps_ver.course_cd%TYPE,
               p_course_version_number    IN  igs_ps_ver.version_number%TYPE,
               p_unit_cd                  IN  igs_ps_unit_ver.unit_cd%TYPE,
               p_unit_version_number      IN  igs_ps_unit_ver.version_number%TYPE,
               p_msg_count                OUT NOCOPY NUMBER,
               p_msg_data                 OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN
  AS
  -----------------------------------------------------------------------------------
  --Created by  : smanglm ( Oracle IDC)
  --Date created: 2002/01/11
  --
  --Purpose:  Created as part of the build for DLD Sponsorship
  --          check_unit_attempt: checks whether the student is actively enrolled in
  --          the given unit or not.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------------------------
    /*
      cursor to see whether the student is actively enrolled in the unit or not
    */
    CURSOR c_enroll (cp_person_id igs_pe_person.person_id%TYPE,
                     cp_course_cd igs_en_su_attempt.course_cd%TYPE,
                     cp_unit_cd igs_en_su_attempt.unit_cd%TYPE,
                     cp_unit_version_number igs_en_su_attempt.version_number%TYPE,
                     cp_ld_cal_type igs_ca_inst.cal_type%TYPE,
                     cp_ld_ci_sequence_number igs_ca_inst.sequence_number%TYPE) IS
           SELECT 'x'
           FROM igs_en_su_attempt
           WHERE person_id = cp_person_id
           AND   course_cd = cp_course_cd
           AND   unit_attempt_status IN ('ENROLLED', 'COMPLETED')
           AND   unit_cd  = cp_unit_cd
           AND   version_number = cp_unit_version_number
           AND  (cal_type, ci_sequence_number) IN (SELECT teach_cal_type, teach_ci_sequence_number
                                                   FROM igs_ca_load_to_teach_v
                                                   WHERE load_cal_type = cp_ld_cal_type
                                                   AND   load_ci_sequence_number = cp_ld_ci_sequence_number);
    l_enroll c_enroll%ROWTYPE;
  BEGIN
    /*
      Check whether the student is actively enrolled in the unit or not.
      Always unit is attached to a teaching period.
      So check whether is teaching period falls under the given load calendar.
    */
    OPEN c_enroll (p_person_id,
                   p_course_cd,
                   p_unit_cd,
                   p_unit_version_number,
                   p_ld_cal_type,
                   p_ld_ci_sequence_number);
    FETCH c_enroll INTO l_enroll;
    IF c_enroll%NOTFOUND THEN
       p_msg_count := NVL(p_msg_count,0) + 1;
       p_msg_data  := 'IGF_SP_SUA_NOT_ELGB';
       CLOSE c_enroll;
       RETURN FALSE;
    ELSE
       CLOSE c_enroll;
       RETURN TRUE;
    END IF;

  END check_unit_attempt;

PROCEDURE log_to_fnd (
  p_v_module IN VARCHAR2,
  p_v_string IN VARCHAR2
) AS
------------------------------------------------------------------
--Created by  : svuppala, Oracle IDC
--Date created: 16-May-2006
--
-- Purpose:
-- Invoked     : from within API
-- Function    : Private procedure for logging all the statement level
--               messages
-- Parameters  : p_v_module   : IN parameter. Required.
--               p_v_string   : IN parameter. Required.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
BEGIN

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_sp_gen_001.'||p_v_module, p_v_string);
  END IF;
END log_to_fnd;


END igf_sp_gen_001;

/
