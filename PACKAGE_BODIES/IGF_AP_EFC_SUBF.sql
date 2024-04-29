--------------------------------------------------------
--  DDL for Package Body IGF_AP_EFC_SUBF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_EFC_SUBF" AS
/* $Header: IGFAP32B.pls 120.1 2006/04/09 23:48:34 ridas noship $ */
/*
  ||  Created By :  gmuralid
  ||  Created On :  11 Feb 2003
  ||  Purpose :     EFC Sub Functions Package, Bug# 2758804 , EFC build TD
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || svuppala         16-Nov-2004     Bug # 3416849 Expected Family Contribution Updates 2005-2006
  ||  gmuralid        09-03-2003      BUG# 2833795 - EFC Mismatch Base BUG - Added a extra parameter l_call_type to procedure c_efc
  ||  gmuralid        08-03-2003      BUG# 2833795 - EFC Mismatch Base BUG
  ||  gmuralid        06-03-2003      Modifed Rounding off mechanism
  ||  gmuralid        04-03-2003      BUG#2831089 - Corrected population of intermediate values into isir record
  ||  gmuralid        03-03-2003      BUG#2826603 - Implemented Null Handling In EEA calculation
  ||  gmuralid        03-03-2003      BUG#2826603 - Included negative  and non existant value check in set up cursors including state cursor
  ||  gmuralid        17-02-2003      Included assumed values in sub functions
  ||  (reverse chronological order - newest change first)

*/

  -- SUB FUNCTIONS  for calculating EFC with FORMULA A
  PROCEDURE  a_p_inc ( p_p_inc     OUT NOCOPY    NUMBER)   AS
  /*
  ||  Created By : gmuralid
  ||  Created On : 11 Feb 2003
  ||  Purpose :    Procedure to get Parents Income , Bug# 2758804 , EFC build TD
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||
  ||  (reverse chronological order - newest change first)
 */
       -- Initialize the local variables with the Global variables.
    l_adjusted_gross_income    igf_ap_isir_matched.p_adjusted_gross_income%TYPE;
    l_p_inc_work               NUMBER;
    l_tot_tax_inc              NUMBER;
    l_tot_untax_inc            NUMBER;
    l_tot_inc                  NUMBER;

      -- Cursor to find out NOCOPY the ISIR information for the Student

  BEGIN

    -- Get Parents Adjusted Gross Income( If negative take 0)
    IF NVL(NVL(igf_ap_efc_calc.isir_rec.a_parents_agi,igf_ap_efc_calc.isir_rec.p_adjusted_gross_income),0) <= 0 THEN
         l_adjusted_gross_income := 0;
    ELSE
         l_adjusted_gross_income := NVL(igf_ap_efc_calc.isir_rec.a_parents_agi,igf_ap_efc_calc.isir_rec.p_adjusted_gross_income);
    END IF;

    -- Get Total Parents income earned from work
    -- Father income earned from work + Mother income earned from work

    l_p_inc_work  := NVL(NVL(igf_ap_efc_calc.isir_rec.a_f_work_income,igf_ap_efc_calc.isir_rec.f_income_work),0) +
                     NVL(NVL(igf_ap_efc_calc.isir_rec.a_m_work_income,igf_ap_efc_calc.isir_rec.m_income_work),0);

    -- Get the Parents Taxable income( If Taxable = Adjusted Gross Income Else
    -- = Total Income earned from Work)
    IF igf_ap_efc_calc.isir_rec.p_cal_tax_status IN ('1','2','3') THEN
       l_tot_tax_inc := l_adjusted_gross_income;
    ELSE
       l_tot_tax_inc := l_p_inc_work;
    END IF;

    -- Total Untaxed Income and benifits
    -- Total from FAFSA Worksheet A + Total from FAFSA Worksheet B
    l_tot_untax_inc := NVL(igf_ap_efc_calc.isir_rec.p_income_wsa,0) + NVL(igf_ap_efc_calc.isir_rec.p_income_wsb,0);

    -- Total Income = Total Taxable Income + Total Untaxable Income.
    l_tot_inc := l_tot_tax_inc + l_tot_untax_inc;

    -- Parents total Income = Total Income - Total from FAFSA Worksheet C
    p_p_inc := l_tot_inc - NVL (NVL (igf_ap_efc_calc.isir_rec.a_p_total_wsc,igf_ap_efc_calc.isir_rec.p_income_wsc),0);
    p_p_inc := ROUND(p_p_inc);

    igf_ap_efc_calc.isir_rec.total_income := p_p_inc; --Assignment of intermediate values
    igf_ap_efc_calc.isir_rec.secti := p_p_inc; --Assignment of intermediate values

  EXCEPTION
     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_SUBF.A_P_INC');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
  END a_p_inc;


  PROCEDURE  a_allow_ag_p_inc ( p_p_inc            IN              NUMBER,
                                p_allow_ag_p_inc       OUT NOCOPY  NUMBER)    AS
  /*
  ||  Created By : gmuralid
  ||  Created On : 11 Feb 2003
  ||  Purpose :    Procedure to get allowances against Parents Income , Bug# 2758804 , EFC build TD
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */

    l_p_taxes_paid               igf_ap_isir_matched.p_taxes_paid%TYPE;
    l_state                      igf_lookups_view.lookup_code%TYPE;
    l_tax_allowance              NUMBER;
    l_f_sst                      NUMBER;
    l_m_sst                      NUMBER;
    l_ipa                        NUMBER;
    l_eea                        NUMBER;

    -- Cursor to find the Valid State
    CURSOR    state_cur(cp_state igf_lookups_view.lookup_code%TYPE) IS
       SELECT lookup_code
         FROM igf_lookups_view
        WHERE lookup_type = 'IGF_AP_STATE_CODES'
          AND lookup_code = cp_state;

    -- Cursor to calculate State and other tax allowance
    CURSOR    state_allow_cur(cp_state igf_lookups_view.lookup_code%TYPE) IS
       SELECT tax_rate
         FROM igf_fc_state_tx   txrng
        WHERE txrng.table_code       = 'A1'
          AND (p_p_inc BETWEEN txrng.income_range_start AND txrng.income_range_end)
          AND txrng.state_code       = cp_state
          AND txrng.s_award_year     = igf_ap_efc_calc.p_sys_award_year;

    -- Cursor to calculate Social Security Tax for Father and Mother.
    CURSOR    sst_cur(cp_inc_work  igf_ap_isir_matched.m_income_work%TYPE)  IS
       SELECT tax_rate, amount, tax_rate_excess, amount_excess
         FROM igf_fc_gen_tax_rts  gtxrts
        WHERE gtxrts.table_code    = 'A2'
          AND gtxrts.s_award_year = igf_ap_efc_calc.p_sys_award_year
          AND (cp_inc_work BETWEEN gtxrts.income_range_start AND gtxrts.income_range_end);

      -- Cursor to calculate Income Protection Allowance
    CURSOR    ipa_cur(cp_num_family_member  igf_ap_isir_matched.p_num_family_member%TYPE,
                      cp_num_in_college     igf_ap_isir_matched.p_num_in_college%TYPE) IS
       SELECT ip_allowance_amt
         FROM igf_fc_inc_prct ipa
        WHERE ipa.table_code    = 'A3'
          AND ipa.s_award_year = igf_ap_efc_calc.p_sys_award_year
          AND ipa.people_in_household = cp_num_family_member
          AND ipa.students_in_household = cp_num_in_college ;

    -- Cursor to calculate Employment Expense Allowance:
    CURSOR    eea_cur IS
       SELECT empl_exp_allowance_rate1, empl_exp_allowance_amount1,empl_exp_allowance_rate2, empl_exp_allowance_amount2
         FROM igf_fc_efc_frm_a  efca
        WHERE efca.s_award_year = igf_ap_efc_calc.p_sys_award_year;

    state_rec           state_cur%ROWTYPE;
    state_allow_rec     state_allow_cur%ROWTYPE;
    sst_rec             sst_cur%ROWTYPE;
    ipa_rec             ipa_cur%ROWTYPE;
    eea_rec             eea_cur%ROWTYPE;
    l_parent_cont       NUMBER ;
    l_student_cont      NUMBER ;
    p_n_fam             NUMBER;
    p_n_col             NUMBER;
    p_n_fam1            NUMBER;
    p_n_col1            NUMBER;
    l_state_cd          VARCHAR2(30);


  BEGIN
     -- For Non Tax Filers and with Income Tax Paid Negative should be processed, process with 0
     IF  (   (NVL(igf_ap_efc_calc.isir_rec.p_cal_tax_status,'-1') NOT IN ('1','2','3'))
          OR (NVL(NVL(igf_ap_efc_calc.isir_rec.a_p_us_tax_paid,igf_ap_efc_calc.isir_rec.p_taxes_paid),0) <= 0 ) ) THEN
          l_p_taxes_paid := 0;
     ELSE
          l_p_taxes_paid := NVL(igf_ap_efc_calc.isir_rec.a_p_us_tax_paid,igf_ap_efc_calc.isir_rec.p_taxes_paid);
     END IF;

     -- Process to calculate State and other tax allowance only if Parents Income > 0
     IF  p_p_inc > 0 THEN
         -- To find the proper State process in the order of
         -- Parents state of legal residence  (If invalid then)
         -- Students state of legal residence (If invalid then)
         -- State in the Student mailing address (If invalid then)
         -- Blank or Invalid state

         l_state_cd := igf_ap_efc_calc.isir_rec.p_state_legal_residence;

         IF l_state_cd = 'FC' THEN
           l_state_cd := 'OT';
         END IF;


         OPEN    state_cur(l_state_cd);
         FETCH   state_cur  INTO  state_rec;
         l_state := state_rec.lookup_code;
         CLOSE   state_cur;

         IF l_state IS NULL THEN

            l_state_cd := igf_ap_efc_calc.isir_rec.s_state_legal_residence;

            IF l_state_cd = 'FC' THEN
               l_state_cd := 'OT';
            END IF;

            OPEN  state_cur(l_state_cd);
            FETCH state_cur  INTO  state_rec;
            l_state := state_rec.lookup_code;
            CLOSE state_cur;
         END IF;

         IF l_state IS NULL THEN

            l_state_cd := igf_ap_efc_calc.isir_rec.perm_state;

            IF l_state_cd = 'FC' THEN
              l_state_cd := 'OT';
            END IF;

            OPEN  state_cur(l_state_cd);
            FETCH state_cur  INTO  state_rec;
            l_state := state_rec.lookup_code;
            CLOSE   state_cur;
         END IF;

         IF l_state IS NULL THEN
            l_state := 'BL';
         END IF;

         OPEN state_allow_cur(l_state);
         FETCH state_allow_cur INTO  state_allow_rec;

         IF state_allow_cur%NOTFOUND THEN
            CLOSE  state_allow_cur;
            OPEN state_allow_cur('OT');
            FETCH  state_allow_cur   INTO  state_allow_rec;
            IF  state_allow_cur%NOTFOUND THEN
               CLOSE  state_allow_cur;
               FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_TAX_SETUP');
               FND_MESSAGE.SET_TOKEN('TABLE_NAME','A1');
               IGS_GE_MSG_STACK.ADD;
               RAISE  exception_in_setup;
             END IF;
         END IF;
         CLOSE  state_allow_cur;

         -- Determine the State and other tax allowance
         l_tax_allowance := ( p_p_inc * state_allow_rec.tax_rate ) / 100 ;

         -- State and other tax allowance can not be Negative
         IF ( l_tax_allowance < 0 ) THEN
            l_tax_allowance := 0;
         END IF;

      ELSE
         -- If Parents Income <= 0 then assume Tax Allowance to be 0
         l_tax_allowance := 0;
      END IF;


      igf_ap_efc_calc.isir_rec.state_tax_allow := ROUND(l_tax_allowance); --Assignment of intermediate values
      igf_ap_efc_calc.isir_rec.secstx := ROUND(l_tax_allowance); --Assignment of intermediate values

      -- Calculating the Social Security Tax for Father

      IF NVL(igf_ap_efc_calc.isir_rec.a_f_work_income,igf_ap_efc_calc.isir_rec.f_income_work) IS NOT NULL THEN
         OPEN sst_cur(greatest(NVL(igf_ap_efc_calc.isir_rec.a_f_work_income,igf_ap_efc_calc.isir_rec.f_income_work),0));
         FETCH sst_cur  INTO sst_rec;
         IF sst_cur%NOTFOUND THEN
            CLOSE  sst_cur;
            FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_GEN_TAX_SETUP');
            FND_MESSAGE.SET_TOKEN('TABLE_NAME','A2');
            IGS_GE_MSG_STACK.ADD;
            RAISE  exception_in_setup;
         END IF;
         CLOSE   sst_cur;

         IF sst_rec.tax_rate IS NULL THEN
            l_f_sst := sst_rec.amount +
                     (( sst_rec.tax_rate_excess * (greatest(NVL(igf_ap_efc_calc.isir_rec.a_f_work_income,igf_ap_efc_calc.isir_rec.f_income_work),0) - sst_rec.amount_excess)) / 100 );
         ELSE
            l_f_sst := ( sst_rec.tax_rate * (greatest(NVL(igf_ap_efc_calc.isir_rec.a_f_work_income,igf_ap_efc_calc.isir_rec.f_income_work),0) ) / 100 );
         END IF ;

         -- Social Security Tax can not be Negative
         IF ( l_f_sst < 0 ) THEN
            l_f_sst := 0;
         END IF;
      ELSE
         l_f_sst := 0;
      END IF;

      l_f_sst := ROUND(l_f_sst) ;

      -- Calculating the Social Security Tax for Mother
      IF  NVL(igf_ap_efc_calc.isir_rec.a_m_work_income,igf_ap_efc_calc.isir_rec.m_income_work) IS NOT NULL THEN
         OPEN    sst_cur(greatest(NVL(igf_ap_efc_calc.isir_rec.a_m_work_income,igf_ap_efc_calc.isir_rec.m_income_work),0));
         FETCH   sst_cur  INTO sst_rec;
         IF sst_cur%NOTFOUND THEN
            CLOSE  sst_cur;
            FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_GEN_TAX_SETUP');
            FND_MESSAGE.SET_TOKEN('TABLE_NAME','A2');
            IGS_GE_MSG_STACK.ADD;
            RAISE  exception_in_setup;
         END IF;
         CLOSE   sst_cur;

         IF sst_rec.tax_rate IS NULL THEN
            l_m_sst := sst_rec.amount +
                     (( sst_rec.tax_rate_excess * (greatest(NVL(igf_ap_efc_calc.isir_rec.a_m_work_income,igf_ap_efc_calc.isir_rec.m_income_work),0) - sst_rec.amount_excess)) / 100 );
         ELSE
            l_m_sst := ( sst_rec.tax_rate * (greatest(NVL(igf_ap_efc_calc.isir_rec.a_m_work_income,igf_ap_efc_calc.isir_rec.m_income_work),0) ) / 100) ;
         END IF ;

         -- Social Security Tax can not be Negative
         IF ( l_m_sst < 0 ) THEN
            l_m_sst := 0;
         END IF;
      ELSE
         l_m_sst := 0;
      END IF;

      l_m_sst := ROUND(l_m_sst) ;

     p_n_fam := NVL(igf_ap_efc_calc.isir_rec.a_parents_num_family,igf_ap_efc_calc.isir_rec.p_num_family_member);
     p_n_col := NVL(igf_ap_efc_calc.isir_rec.a_parents_num_college,igf_ap_efc_calc.isir_rec.p_num_in_college);
     IF p_n_fam IS NOT NULL   AND p_n_col IS NOT NULL  THEN
        -- Calculate Income Protection Allowance of Parent
        OPEN ipa_cur(p_n_fam,p_n_col);
        FETCH ipa_cur INTO ipa_rec;

        IF ipa_cur%NOTFOUND THEN
           CLOSE ipa_cur;
           IF( p_n_fam IS NULL) OR (p_n_col IS NULL ) THEN
               FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_INC_PRT_ALW_SETUP');
               FND_MESSAGE.SET_TOKEN('TABLE_NAME','A3');
               IGS_GE_MSG_STACK.ADD;
               RAISE exception_in_setup;
           END IF;

           p_n_fam1 := 0;
           p_n_col1 := 0;

          IF p_n_fam > 6 THEN
             p_n_fam1 := p_n_fam - 6;
             p_n_fam  := 6 ;
          END IF;

          IF p_n_col > 5 THEN
            p_n_col1 := p_n_col - 5;
            p_n_col  := 5 ;
          END IF;

          get_par_stud_cont( igf_ap_efc_calc.p_sys_award_year, l_parent_cont,l_student_cont );

          OPEN ipa_cur(p_n_fam,p_n_col);
          FETCH ipa_cur INTO ipa_rec;
          CLOSE ipa_cur ;
          l_ipa := (ipa_rec.ip_allowance_amt + (p_n_fam1 * l_parent_cont ) ) - ((p_n_col1 * l_student_cont ));
       ELSE
          CLOSE ipa_cur;  --IF IPA CUR FOUND
          l_ipa := ipa_rec.ip_allowance_amt;
       END IF;

     ELSE
        l_ipa := 0;

     END IF;

     igf_ap_efc_calc.isir_rec.income_protection_allow := l_ipa; --Assignment of intermediate values
     igf_ap_efc_calc.isir_rec.secipa := l_ipa; --Assignment of intermediate values

    OPEN eea_cur;
    FETCH eea_cur  INTO  eea_rec;
    IF eea_cur%NOTFOUND THEN
       CLOSE  eea_cur;
       FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_EFCA_SETUP');
       IGS_GE_MSG_STACK.ADD;
       RAISE  exception_in_setup;
    END IF;
    CLOSE eea_cur;

    -- Two working parents: 35% of the lesser of the
    -- earned incomes, or $2,900, whichever is less
    --IF    NVL(igf_ap_efc_calc.isir_rec.a_p_marital_status,igf_ap_efc_calc.isir_rec.p_marital_status) = '1' THEN

    IF   NVL(igf_ap_efc_calc.isir_rec.a_p_marital_status,igf_ap_efc_calc.isir_rec.p_marital_status  ) = '1' THEN
       IF (    NVL(igf_ap_efc_calc.isir_rec.a_f_work_income,igf_ap_efc_calc.isir_rec.f_income_work) IS NOT NULL
           AND NVL(igf_ap_efc_calc.isir_rec.a_m_work_income,igf_ap_efc_calc.isir_rec.m_income_work) IS NOT NULL)
           THEN
           l_eea := LEAST((NVL(eea_rec.empl_exp_allowance_rate2,0) *
                          LEAST(greatest(NVL(igf_ap_efc_calc.isir_rec.a_f_work_income,igf_ap_efc_calc.isir_rec.f_income_work),0),
                          greatest(NVL(igf_ap_efc_calc.isir_rec.a_m_work_income,igf_ap_efc_calc.isir_rec.m_income_work),0))/100),
                          NVL(eea_rec.empl_exp_allowance_amount2,0));

       ELSIF (   (    NVL(igf_ap_efc_calc.isir_rec.a_f_work_income,igf_ap_efc_calc.isir_rec.f_income_work) IS NOT NULL
                  AND NVL(igf_ap_efc_calc.isir_rec.a_m_work_income,igf_ap_efc_calc.isir_rec.m_income_work) IS NULL)
              OR (    NVL(igf_ap_efc_calc.isir_rec.a_f_work_income,igf_ap_efc_calc.isir_rec.f_income_work) IS NULL
                  AND NVL(igf_ap_efc_calc.isir_rec.a_m_work_income,igf_ap_efc_calc.isir_rec.m_income_work) IS NOT NULL))
              THEN
              -- Two-parent families, one working parent EEA is 0.
              l_eea := 0;
       ELSE
          l_eea := 0;

       END IF;


    ELSE
       -- One Parent Family
       -- One-parent families: 35% of earned income,
       -- or $2,900, whichever is less

       l_eea := greatest(NVL (NVL(igf_ap_efc_calc.isir_rec.a_f_work_income,igf_ap_efc_calc.isir_rec.f_income_work),0), 0) ;
       l_eea := greatest(NVL (NVL(igf_ap_efc_calc.isir_rec.a_m_work_income,igf_ap_efc_calc.isir_rec.m_income_work), 0) ,0,l_eea) ;

       l_eea := LEAST(
       (NVL(eea_rec.empl_exp_allowance_rate1,0) * l_eea/100),
       NVL(eea_rec.empl_exp_allowance_amount1,0)
       );

    END IF;


    igf_ap_efc_calc.isir_rec.employment_allow := ROUND(l_eea); --Assignment of intermediate values
    igf_ap_efc_calc.isir_rec.secea := ROUND(l_eea); --Assignment of intermediate values

    -- Allowance against Parents Income
    p_allow_ag_p_inc := ROUND(l_p_taxes_paid) + ROUND(l_tax_allowance) + ROUND(l_f_sst) + ROUND(l_m_sst) + ROUND(l_ipa) + ROUND(l_eea);
--   p_allow_ag_p_inc := ROUND( p_allow_ag_p_inc);

    igf_ap_efc_calc.isir_rec.allow_total_income := p_allow_ag_p_inc; --Assignment of intermediate values
    igf_ap_efc_calc.isir_rec.secati := p_allow_ag_p_inc; --Assignment of intermediate values


  EXCEPTION
     WHEN exception_in_setup THEN
          RAISE igf_ap_efc_calc.exception_in_setup; -- Exception to be handled in the Calling Procedures
     WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_SUBF.A_ALLOW_AG_P_INC');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
  END a_allow_ag_p_inc;


  PROCEDURE  a_available_inc ( p_p_inc            IN              NUMBER,
                               p_allow_ag_p_inc   IN              NUMBER,
                               p_available_income     OUT NOCOPY  NUMBER)     AS
  /*
  ||  Created By : gmuralid
  ||  Created On : 11 Feb 2003
  ||  Purpose :    Procedure to get available Income , Bug# 2758804 , EFC build TD
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
  BEGIN
     -- Total Income - Total Allowance
     p_available_income := p_p_inc - p_allow_ag_p_inc;
     p_available_income := ROUND( p_available_income);


     igf_ap_efc_calc.isir_rec.available_income := p_available_income; --Assignment of intermediate values
     igf_ap_efc_calc.isir_rec.secai := p_available_income; --Assignment of intermediate values

  END a_available_inc;



  PROCEDURE get_age_older_parent(age_older_parent   OUT NOCOPY NUMBER) AS
    /*
  ||  Created By : nsidana
  ||  Created On : 11/20/2003
  ||  Purpose :    Procedure to get the age of the older parent. This is introduced as part of
  ||                       FA129 build.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)

 */
      l_fathers_age NUMBER(3)   := NULL;
      l_mothers_age NUMBER(3) := NULL;
      l_base_date   DATE;

  BEGIN

    IF igf_ap_efc_calc.p_sys_award_year IN ( '0405','0506','0607') THEN

      IF igf_ap_efc_calc.p_sys_award_year = '0405' THEN
        l_base_date := TO_DATE('31-12-2004','DD-MM-YYYY');
      ELSIF igf_ap_efc_calc.p_sys_award_year = '0506' THEN
        l_base_date := TO_DATE('31-12-2005','DD-MM-YYYY');
       ELSIF igf_ap_efc_calc.p_sys_award_year = '0607' THEN
        l_base_date := TO_DATE('31-12-2006','DD-MM-YYYY');
      END IF;

      IF (igf_ap_efc_calc.isir_rec.father_step_father_birth_date IS NOT NULL )
      THEN
  --            l_fathers_age := FLOOR((l_base_date - igf_ap_efc_calc.isir_rec.father_step_father_birth_date)/365);
        l_fathers_age := FLOOR((TO_NUMBER(TO_CHAR(l_base_date,'YYYY')) - TO_NUMBER(TO_CHAR(igf_ap_efc_calc.isir_rec.father_step_father_birth_date,'YYYY'))));
      END IF;

      IF (igf_ap_efc_calc.isir_rec.mother_step_mother_birth_date IS NOT NULL)
      THEN
  --            l_mothers_age := FLOOR ((l_base_date - igf_ap_efc_calc.isir_rec.mother_step_mother_birth_date)/365);
        l_mothers_age := FLOOR ((TO_NUMBER(TO_CHAR(l_base_date,'YYYY') - TO_NUMBER(TO_CHAR(igf_ap_efc_calc.isir_rec.mother_step_mother_birth_date,'YYYY')))));
      END IF;

      IF l_fathers_age IS NULL AND l_mothers_age IS NULL THEN
        age_older_parent := NULL;
      ELSIF NVL(l_fathers_age , 0) >  NVL(l_mothers_age , 0) THEN
        age_older_parent := l_fathers_age;
      ELSE
        age_older_parent := l_mothers_age;
      END IF;
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_SUBF.GET_AGE_OLDER_PARENT');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
  END get_age_older_parent ;


  PROCEDURE  a_p_cont_assets ( p_p_cont_assets    OUT NOCOPY    NUMBER)   AS
  /*
  ||  Created By : gmuralid
  ||  Created On : 11 Feb 2003
  ||  Purpose :    Procedure to get Parents Contribution from assets , Bug# 2758804 , EFC build TD
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || nsidana        11/20/2003       FA129 EFC updates for 2004-2005.
  ||  (reverse chronological order - newest change first)

 */
   l_investment_networth    igf_ap_isir_matched.p_investment_networth%TYPE;
   l_business_networth      igf_ap_isir_matched.p_business_networth%TYPE;
   l_adj_business_networth  NUMBER;
   l_cash_saving            igf_ap_isir_matched.p_cash_saving%TYPE;
   l_net_worth              NUMBER;
   l_age_parent             NUMBER;
   l_edu_sav_assets         igf_fc_ast_pc_dt.parent2_allowance%TYPE;
   l_d_net_worth            NUMBER;

   -- Cursor to find the Setting for Formula A
   CURSOR    efcA_cur IS
      SELECT A5_default_age, parent_asset_conv_rate
        FROM igf_fc_efc_frm_a   efca
       WHERE efca.s_award_year = igf_ap_efc_calc.p_sys_award_year;

   -- Cursor to calculate Asset Protection Allowance
   CURSOR     asset_cur(cp_age_older_parent  igf_fc_ast_pc_dt.older_parent_age%TYPE) IS
       SELECT parent1_allowance, parent2_allowance
         FROM igf_fc_ast_pc_dt   apdt
        WHERE apdt.s_award_year = igf_ap_efc_calc.p_sys_award_year
          AND apdt.table_code = 'A5'
          AND apdt.older_parent_age = cp_age_older_parent;

   -- Cursor to calculate Adjusted Net worth of Business/farm
   CURSOR    business_networth_cur(cp_business_networth  igf_ap_isir_matched.p_business_networth%TYPE)  IS
      SELECT tax_rate, amount, tax_rate_excess, amount_excess
        FROM igf_fc_gen_tax_rts  gtxrts
       WHERE gtxrts.table_code    = 'A4'
         AND gtxrts.s_award_year  = igf_ap_efc_calc.p_sys_award_year
         AND (cp_business_networth BETWEEN gtxrts.income_range_start AND gtxrts.income_range_end);

    business_networth_rec   business_networth_cur%ROWTYPE;
    efcA_rec                efcA_cur%ROWTYPE;
    asset_rec               asset_cur%ROWTYPE;

  BEGIN

    -- Get Net worth of investments( Can not be Negative)
    IF  NVL(igf_ap_efc_calc.isir_rec.p_investment_networth,0) <= 0 THEN
        l_investment_networth := 0;
    ELSE
        l_investment_networth := igf_ap_efc_calc.isir_rec.p_investment_networth;
    END IF;

    -- Get Net Worth of business/investments farm(Can not be Negative)
    IF  NVL(igf_ap_efc_calc.isir_rec.p_business_networth,0) <= 0 THEN
        l_business_networth := 0;
    ELSE
        l_business_networth := igf_ap_efc_calc.isir_rec.p_business_networth;
    END IF;

    -- Get Adjusted net worth of Business/Farm
    OPEN business_networth_cur(l_business_networth);
    FETCH business_networth_cur   INTO  business_networth_rec;
    IF business_networth_cur%NOTFOUND THEN
       CLOSE  business_networth_cur;
       FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_GEN_TAX_SETUP');
       FND_MESSAGE.SET_TOKEN('TABLE_NAME','A4');
       IGS_GE_MSG_STACK.ADD;
       RAISE  exception_in_setup;
    END IF;
    CLOSE business_networth_cur;

    IF  business_networth_rec.tax_rate IS NULL THEN
        l_adj_business_networth := business_networth_rec.amount +
                                   (( business_networth_rec.tax_rate_excess * (l_business_networth - business_networth_rec.amount_excess)) / 100 );
    ELSE
        l_adj_business_networth := ( business_networth_rec.tax_rate * l_business_networth ) / 100 ;
    END IF ;

    l_adj_business_networth := ROUND(l_adj_business_networth) ;

    -- Get Cash, Savings and Checking
    IF igf_ap_efc_calc.isir_rec.p_cash_saving  IS NULL THEN
       l_cash_saving := 0;
    ELSE
       l_cash_saving := igf_ap_efc_calc.isir_rec.p_cash_saving;
    END IF;

    -- Get Net Worth
	 -- (Investment Net worth + Adjusted Business Net Worth + Cash Saving)
    l_net_worth := l_investment_networth + l_adj_business_networth + l_cash_saving ;

    igf_ap_efc_calc.isir_rec.efc_networth := l_net_worth; --Assignment of intermediate values
    igf_ap_efc_calc.isir_rec.secnw := l_net_worth; --Assignment of intermediate values

    -- If parent Age is not specified then get the Default Age for Formula A
    IF (igf_ap_efc_calc.p_sys_award_year = '0304' ) THEN
      l_age_parent := igf_ap_efc_calc.isir_rec.age_older_parent;
    ELSIF (igf_ap_efc_calc.p_sys_award_year = '0405') THEN
      igf_ap_efc_subf.get_age_older_parent(l_age_parent);
    ELSIF (igf_ap_efc_calc.p_sys_award_year = '0506') THEN
      igf_ap_efc_subf.get_age_older_parent(l_age_parent);
    ELSIF (igf_ap_efc_calc.p_sys_award_year = '0607') THEN
      igf_ap_efc_subf.get_age_older_parent(l_age_parent);
    END IF;

    IF (l_age_parent IS NULL) THEN
      l_age_parent := NVL(efca_rec.A5_default_age,45);
    ELSIF (l_age_parent < 25) THEN
      l_age_parent := 25;
    ELSIF (l_age_parent > 65) THEN
      l_age_parent := 65;
    END IF;

    -- Get Education savings and Asset Protection Allowance
    OPEN asset_cur(l_age_parent);
    FETCH asset_cur  INTO  asset_rec;
    IF asset_cur%NOTFOUND THEN
       CLOSE  asset_cur;
       FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_ASSET_SETUP');
       FND_MESSAGE.SET_TOKEN('TABLE_NAME','A5');
       IGS_GE_MSG_STACK.ADD;
       RAISE  exception_in_setup;
    END IF;
    CLOSE asset_cur;

    IF  NVL(igf_ap_efc_calc.isir_rec.a_p_marital_status,igf_ap_efc_calc.isir_rec.p_marital_status) = '1' THEN
        l_edu_sav_assets := NVL(asset_rec.parent2_allowance,0);
    ELSE
        l_edu_sav_assets := NVL(asset_rec.parent1_allowance,0);
    END IF;

    igf_ap_efc_calc.isir_rec.asset_protect_allow := l_edu_sav_assets; --Assignment of intermediate values
    igf_ap_efc_calc.isir_rec.secapa := l_edu_sav_assets; --Assignment of intermediate values

    -- Get Discretionary Net Worth
    l_d_net_worth := l_net_worth - l_edu_sav_assets ;
    igf_ap_efc_calc.isir_rec.discretionary_networth := l_d_net_worth; --Assignment of intermediate values
    igf_ap_efc_calc.isir_rec.secdnw := l_d_net_worth; --Assignment of intermediate values

    -- Get the Setting for Formula A
    OPEN  efca_cur;
    FETCH efca_cur  INTO  efca_rec;
    IF efca_cur%NOTFOUND THEN
       CLOSE  efca_cur;
       FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_EFCA_SETUP');
       IGS_GE_MSG_STACK.ADD;
       RAISE  exception_in_setup;
    END IF;
    CLOSE efca_cur;

    -- Get Contribution from Assets
    p_p_cont_assets := l_d_net_worth * NVL(efcA_rec.parent_asset_conv_rate,0)/100;

    IF p_p_cont_assets < 0 THEN
	    p_p_cont_assets := 0;
    END IF;

   p_p_cont_assets   := ROUND( p_p_cont_assets );


   igf_ap_efc_calc.isir_rec.parents_cont_from_assets := p_p_cont_assets; --Assignment of intermediate values
   igf_ap_efc_calc.isir_rec.secpca := p_p_cont_assets; --Assignment of intermediate values

  EXCEPTION
     WHEN exception_in_setup THEN
          RAISE igf_ap_efc_calc.exception_in_setup; -- Exception to be handled in the Calling Procedures
     WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_SUBF.A_P_CONT_ASSETS');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
  END a_p_cont_assets;


  PROCEDURE  a_p_cont ( p_available_income IN             NUMBER,
                        p_p_cont_assets    IN             NUMBER,
                        p_p_aai               OUT NOCOPY  NUMBER,
                        p_p_cont              OUT NOCOPY  NUMBER)  AS
  /*
  ||  Created By : gmuralid
  ||  Created On : 11 Feb 2003
  ||  Purpose :    Procedure to get Parents Contribution , Bug# 2758804 , EFC build TD
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */

    l_p_cont_aai            NUMBER;

    -- Cursor to calculate Parents Contribution from AAI
    CURSOR    p_cont_aai_cur(cp_p_aai NUMBER)  IS
       SELECT tax_rate, amount, tax_rate_excess, amount_excess
         FROM igf_fc_gen_tax_rts  gtxrts
        WHERE gtxrts.s_award_year = igf_ap_efc_calc.p_sys_award_year
          AND gtxrts.table_code   = 'A6'
          AND (cp_p_aai BETWEEN gtxrts.income_range_start AND gtxrts.income_range_end);

    p_cont_aai_rec    p_cont_aai_cur%ROWTYPE;

  BEGIN
     -- Get Adjusted Available Income
     -- ( Available Income + Contribution from Assets)

     p_p_aai := p_available_income + p_p_cont_assets;

     igf_ap_efc_calc.isir_rec.adjusted_available_income := p_p_aai; --Assignment of intermediate values
     igf_ap_efc_calc.isir_rec.secaai := p_p_aai; --Assignment of intermediate values


     -- Get Total Parents contribution from Adjusted Available Income
     OPEN p_cont_aai_cur(p_p_aai);
     FETCH p_cont_aai_cur   INTO  p_cont_aai_rec;
     IF p_cont_aai_cur%NOTFOUND THEN
        CLOSE  p_cont_aai_cur;
        FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_GEN_TAX_SETUP');
        FND_MESSAGE.SET_TOKEN('TABLE_NAME','A6');
        IGS_GE_MSG_STACK.ADD;
        RAISE  exception_in_setup;
     END IF;
     CLOSE p_cont_aai_cur;

     IF p_cont_aai_rec.tax_rate IS NULL THEN
        l_p_cont_aai := p_cont_aai_rec.amount +
                       (( p_cont_aai_rec.tax_rate_excess * (p_p_aai - p_cont_aai_rec.amount_excess)) / 100 );
     ELSE
        l_p_cont_aai := ( p_cont_aai_rec.tax_rate * p_p_aai ) / 100 ;
     END IF ;

     -- Total Parents contribution from Adjusted Available Income
     -- (Can not be Negative)
     IF l_p_cont_aai < 0 THEN
        l_p_cont_aai := 0;
     END IF;

     -- Get parents contribution (Total Parents contribution from AAI/Number in college in 2001-02)
     -- (Can not be Negative)
         p_p_cont := ROUND(l_p_cont_aai)/ NVL(NVL(igf_ap_efc_calc.isir_rec.a_parents_num_college,igf_ap_efc_calc.isir_rec.p_num_in_college),1);

	  IF p_p_cont < 0 THEN
        p_p_cont := 0;

          END IF;

     p_p_cont := ROUND( p_p_cont );

     igf_ap_efc_calc.isir_rec.parents_contribution := p_p_cont;  --Assignment of intermediate values
     igf_ap_efc_calc.isir_rec.secpc := p_p_cont;  --Assignment of intermediate values

     l_p_cont_aai := ROUND( l_p_cont_aai );

     igf_ap_efc_calc.isir_rec.total_parent_contribution :=  l_p_cont_aai; --Assignment of intermediate values
     igf_ap_efc_calc.isir_rec.sectpc :=  l_p_cont_aai; --Assignment of intermediate values

  EXCEPTION
     WHEN EXCEPTION_IN_SETUP THEN
          RAISE igf_ap_efc_calc.exception_in_setup; -- Exception to be handled in the Calling Procedures
     WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_SUBF.A_P_CONT');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
  END a_p_cont;


  PROCEDURE  a_s_inc ( p_s_inc      OUT NOCOPY    NUMBER)    AS
  /*
  ||  Created By : gmuralid
  ||  Created On : 11 Feb 2003
  ||  Purpose :    Procedure to get Students Income , Bug# 2758804 , EFC build TD
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
   -- Initialize the local variables with the Global variables.

    l_adjusted_gross_income    igf_ap_isir_matched.s_adjusted_gross_income%TYPE;
    l_s_inc_work               NUMBER;
    l_tot_tax_inc              NUMBER;
    l_tot_untax_inc            NUMBER;
    l_tot_inc                  NUMBER;

  BEGIN
     -- Get Student's Adjusted Gross Income(If negative take 0)
     IF NVL(NVL(igf_ap_efc_calc.isir_rec.a_student_agi,igf_ap_efc_calc.isir_rec.s_adjusted_gross_income),0) <= 0 THEN
        l_adjusted_gross_income := 0;
     ELSE
        l_adjusted_gross_income := NVL(igf_ap_efc_calc.isir_rec.a_student_agi,igf_ap_efc_calc.isir_rec.s_adjusted_gross_income);
     END IF;

     -- Get Student's income earned from work
     l_s_inc_work  := NVL(NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work),0);

     -- Get the Student's Taxable income( If Taxable Then Adjusted Gross Income Else
     -- Income earned from Work)
     IF igf_ap_efc_calc.isir_rec.s_cal_tax_status IN ('1','2','3') THEN
        l_tot_tax_inc := l_adjusted_gross_income;
     ELSE
        l_tot_tax_inc := l_s_inc_work;
     END IF;

     -- Total Untaxed Income and benefits
     -- Total from FAFSA Worksheet A + Total from FAFSA Worksheet B
     l_tot_untax_inc := NVL(igf_ap_efc_calc.isir_rec.s_toa_amt_from_wsa,0) +
                        NVL(igf_ap_efc_calc.isir_rec.s_toa_amt_from_wsb,0);

     -- Total Income = Total Taxable Income + Total Untaxable Income.
     l_tot_inc := NVL(l_tot_tax_inc,0) + NVL(l_tot_untax_inc,0);

     -- Student's total Income = Total Income - Total from FAFSA Worksheet C
     p_s_inc := l_tot_inc - NVL(NVL(igf_ap_efc_calc.isir_rec.a_s_total_wsc,igf_ap_efc_calc.isir_rec.s_toa_amt_from_wsc),0);
     p_s_inc := ROUND( p_s_inc );

     igf_ap_efc_calc.isir_rec.student_total_income := p_s_inc; --Assignment of intermediate values
     igf_ap_efc_calc.isir_rec.secsti := p_s_inc; --Assignment of intermediate values

     igf_ap_efc_calc.isir_rec.fti := igf_ap_efc_calc.isir_rec.student_total_income + igf_ap_efc_calc.isir_rec.total_income;
     igf_ap_efc_calc.isir_rec.secfti := igf_ap_efc_calc.isir_rec.student_total_income + igf_ap_efc_calc.isir_rec.total_income;


  EXCEPTION
     WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_SUBF.A_S_INC');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
  END a_s_inc;


  PROCEDURE a_allow_ag_s_inc ( p_s_inc            IN     NUMBER,
                               p_p_aai            IN     NUMBER,
                               p_allow_ag_s_inc   OUT NOCOPY    NUMBER)    AS
  /*
  ||  Created By : gmuralid
  ||  Created On : 11 Feb 2003
  ||  Purpose :    Procedure to get Allowances against Student's Income , Bug# 2758804 , EFC build TD
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    -- Initialize the local variables with the Global variables.

    l_s_taxes_paid               igf_ap_isir_matched.p_taxes_paid%TYPE;
    l_state                      igf_lookups_view.lookup_code%TYPE;
    l_tax_allowance              NUMBER;
    l_s_sst                      NUMBER;
    l_ipa                        NUMBER;
    l_p_aai                      NUMBER;
    l_state_cd                   VARCHAR2(30);

    -- Cursor to find the Valid State
    CURSOR    state_cur(cp_state igf_lookups_view.lookup_code%TYPE) IS
       SELECT lookup_code
         FROM igf_lookups_view
        WHERE lookup_type = 'IGF_AP_STATE_CODES'
          AND lookup_code = cp_state;

    -- Cursor to calculate State and other tax allowance
    CURSOR    state_allow_cur(cp_state igf_lookups_view.lookup_code%TYPE) IS
       SELECT tax_rate
         FROM igf_fc_state_tx    txrng
        WHERE txrng.s_award_year  = igf_ap_efc_calc.p_sys_award_year
          AND txrng.table_code    = 'A7'
          AND txrng.state_code    = cp_state;

    -- Cursor to calculate Social Security Tax for Father and Mother.

    CURSOR    sst_cur(cp_inc_work  igf_ap_isir_matched.m_income_work%TYPE)  IS
       SELECT tax_rate, amount, tax_rate_excess, amount_excess
         FROM igf_fc_gen_tax_rts  gtxrts
        WHERE gtxrts.table_code    = 'A2'
          AND gtxrts.s_award_year = igf_ap_efc_calc.p_sys_award_year
          AND (cp_inc_work BETWEEN gtxrts.income_range_start AND gtxrts.income_range_end);

      -- Cursor to calculate Income Protection Allowance
    CURSOR    ipa_cur IS
       SELECT stud_inc_prot_allowance
         FROM igf_fc_efc_frm_a  efca
        WHERE efca.s_award_year = igf_ap_efc_calc.p_sys_award_year;

    state_rec          state_cur%ROWTYPE;
    state_allow_rec    state_allow_cur%ROWTYPE;
    sst_rec            sst_cur%ROWTYPE;
    ipa_rec            ipa_cur%ROWTYPE;
  BEGIN


  -- For Non Tax Filers OR with Income Tax Paid Negative should be processed, process with 0
    IF     ((NVL(igf_ap_efc_calc.isir_rec.s_cal_tax_status,'-1') NOT IN ('1','2','3'))
        OR ( NVL (NVL (igf_ap_efc_calc.isir_rec.a_s_us_tax_paid,igf_ap_efc_calc.isir_rec.s_fed_taxes_paid),0) <= 0))
        THEN
        l_s_taxes_paid := 0;
    ELSE
        l_s_taxes_paid := NVL(igf_ap_efc_calc.isir_rec.a_s_us_tax_paid,igf_ap_efc_calc.isir_rec.s_fed_taxes_paid);
    END IF;

    -- Process to calculate State and other tax allowance only if Student's Income > 0
    IF  p_s_inc > 0 THEN
        -- To find the proper State process in the order of
        -- Students state of legal residence (If invalid then)
        -- State in the Students mailing address (If invalid then)	  -- Parents state of legal residence  (If invalid then)
        -- Blank or Invalid state

        l_state_cd := igf_ap_efc_calc.isir_rec.s_state_legal_residence;
        IF l_state_cd = 'FC' THEN
          l_state_cd := 'OT';
        END IF;

        OPEN    state_cur(l_state_cd);
        FETCH   state_cur  INTO  state_rec;
        l_state := state_rec.lookup_code;
        CLOSE   state_cur;

        IF l_state IS NULL THEN

           l_state_cd := igf_ap_efc_calc.isir_rec.perm_state;

           IF l_state_cd = 'FC' THEN
              l_state_cd := 'OT';
           END IF;

           OPEN    state_cur(l_state_cd);
           FETCH   state_cur  INTO  state_rec;
           l_state := state_rec.lookup_code;
           CLOSE   state_cur;
        END IF;

        IF l_state IS NULL THEN

           l_state_cd :=  igf_ap_efc_calc.isir_rec.p_state_legal_residence;
           IF l_state_cd = 'FC' THEN
              l_state_cd := 'OT';
           END IF;

           OPEN    state_cur(l_state_cd);
           FETCH state_cur  INTO  state_rec;
           l_state := state_rec.lookup_code;
           CLOSE   state_cur;
        END IF;

        IF l_state IS NULL THEN
           l_state := 'BL';
        END IF;

        OPEN state_allow_cur(l_state);
        FETCH  state_allow_cur   INTO  state_allow_rec;
        IF state_allow_cur%NOTFOUND THEN
           CLOSE  state_allow_cur;
           OPEN state_allow_cur('OT');
           FETCH  state_allow_cur   INTO  state_allow_rec;
           IF state_allow_cur%NOTFOUND THEN
                CLOSE  state_allow_cur;
                FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_TAX_SETUP');
                FND_MESSAGE.SET_TOKEN('TABLE_NAME','A7');
                IGS_GE_MSG_STACK.ADD;
               RAISE  exception_in_setup;
           END IF;
        END IF;
        CLOSE  state_allow_cur;

        -- Determine the State and other tax allowance
        l_tax_allowance := ( p_s_inc * state_allow_rec.tax_rate ) / 100 ;

        -- State and other tax allowance can not be Negative
        IF ( l_tax_allowance < 0 ) THEN
           l_tax_allowance := 0;
        END IF;

     ELSE -- If Student's Income <= 0 then assume Tax Allowance to be 0
        l_tax_allowance := 0;
     END IF;

     l_tax_allowance := ROUND(l_tax_allowance) ;

     -- Calculating the Social Security Tax for Student
     IF NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work) IS NOT NULL THEN
        OPEN    sst_cur(greatest(NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work),0));
        FETCH   sst_cur  INTO sst_rec;
        IF sst_cur%NOTFOUND THEN
           CLOSE  sst_cur;
           FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_GEN_TAX_SETUP');
           FND_MESSAGE.SET_TOKEN('TABLE_NAME','A2');
           IGS_GE_MSG_STACK.ADD;
           RAISE  exception_in_setup;
        END IF;
        CLOSE   sst_cur;

        IF sst_rec.tax_rate IS NULL THEN
           l_s_sst := sst_rec.amount +
                     (( sst_rec.tax_rate_excess * (greatest(NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work),0) - sst_rec.amount_excess)) / 100 );
        ELSE
           l_s_sst := ( sst_rec.tax_rate * (greatest(NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work),0) ) / 100 );
        END IF ;

        -- Social Security Tax can not be Negative
        IF ( l_s_sst < 0 ) THEN
           l_s_sst := 0;
        END IF;

     ELSE
        l_s_sst := 0;
     END IF;

     l_s_sst := ROUND(l_s_sst) ;

     -- Calculating the Income Protection Allowance for Student
     OPEN     ipa_cur;
     FETCH    ipa_cur  INTO  ipa_rec;
     IF ipa_cur%NOTFOUND THEN
        CLOSE  ipa_cur;
        FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_EFCA_SETUP');
        IGS_GE_MSG_STACK.ADD;
        RAISE  exception_in_setup;
     END IF;

     l_ipa := NVL(ipa_rec.stud_inc_prot_allowance,0);
     CLOSE    ipa_cur;

     -- Allowance for parents negative Adjusted Available Income (If Its negative,
     -- enter as a positive number. If Its zero or positive, enter zero)
     IF  p_p_aai >= 0 THEN
         l_p_aai := 0;
     ELSE
         l_p_aai := -p_p_aai;
     END IF;

     -- Allowance against Student's Income
     p_allow_ag_s_inc := ROUND(l_s_taxes_paid) + ROUND(l_tax_allowance) + ROUND(l_s_sst) + ROUND(l_ipa) + ROUND(l_p_aai) ;
    -- p_allow_ag_s_inc := ROUND( p_allow_ag_s_inc);

     igf_ap_efc_calc.isir_rec.sati := p_allow_ag_s_inc;  --Assignment of intermediate values
     igf_ap_efc_calc.isir_rec.secsati := p_allow_ag_s_inc; --Assignment of intermediate values

  EXCEPTION
     WHEN exception_in_setup THEN
          RAISE igf_ap_efc_calc.exception_in_setup; -- Exception to be handled in the Calling Procedures
     WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_SUBF.A_ALLOW_AG_S_INC');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
     END a_allow_ag_s_inc;


 PROCEDURE  a_s_cont ( p_s_inc            IN             NUMBER,
                       p_allow_ag_s_inc   IN             NUMBER,
                       p_s_cont              OUT NOCOPY  NUMBER)    AS
  /*
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
    l_available_income         NUMBER;

     -- Cursor to Find the Default Setting for Formula A
    CURSOR    efcA_cur IS
       SELECT stud_available_income
         FROM igf_fc_efc_frm_a  efca
        WHERE efca.s_award_year = igf_ap_efc_calc.p_sys_award_year;
    efcA_rec     efcA_cur%ROWTYPE;

  BEGIN
     l_available_income := p_s_inc - p_allow_ag_s_inc;

     OPEN     efcA_cur;
     FETCH    efcA_cur  INTO  efcA_rec;
     IF efcA_cur%NOTFOUND THEN
        CLOSE  efcA_cur;
        FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_EFCA_SETUP');
        IGS_GE_MSG_STACK.ADD;
        RAISE  exception_in_setup;
     END IF;
     CLOSE    efcA_cur;

     p_s_cont := (l_available_income * NVL(efcA_rec.stud_available_income,0)) / 100;

     IF p_s_cont < 0 THEN
        p_s_cont := 0;
     END IF;

     p_s_cont := ROUND( p_s_cont );

     igf_ap_efc_calc.isir_rec.sic := p_s_cont; --Assignment of intermediate values
     igf_ap_efc_calc.isir_rec.secsic := p_s_cont; --Assignment of intermediate values

  EXCEPTION
     WHEN exception_in_setup THEN
          RAISE igf_ap_efc_calc.exception_in_setup; -- Exception to be handled in the Calling Procedures
     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_SUBF.A_S_CONT');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

  END a_s_cont;


  PROCEDURE  a_s_cont_assets  ( p_s_cont_assets    OUT NOCOPY    NUMBER)    AS
  /*
  ||  Created By : gmuralid
  ||  Created On : 11 Feb 2003
  ||  Purpose :    Procedure to get Student's Contribution From Assets , Bug# 2758804 , EFC build TD
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
   l_investment_networth    igf_ap_isir_matched.p_investment_networth%TYPE;
   l_business_networth      igf_ap_isir_matched.p_business_networth%TYPE;
   l_cash_saving            igf_ap_isir_matched.p_cash_saving%TYPE;
   l_net_worth              NUMBER;

   -- Cursor to find the Default Setting for Formula A
   CURSOR    efcA_cur IS
      SELECT stud_asset_assessment_rate
        FROM igf_fc_efc_frm_a   efca
       WHERE efca.s_award_year = igf_ap_efc_calc.p_sys_award_year;

    efcA_rec                efcA_cur%ROWTYPE;

  BEGIN
     -- Get Net worth of investments( Can not be Negative)
     IF  NVL(igf_ap_efc_calc.isir_rec.s_investment_networth,0) <= 0 THEN
         l_investment_networth := 0;
     ELSE
         l_investment_networth := igf_ap_efc_calc.isir_rec.s_investment_networth;
     END IF;

     -- Get Net Worth of business/investments farm(Can not be Negative)
     IF NVL(igf_ap_efc_calc.isir_rec.s_busi_farm_networth,0) <= 0 THEN
        l_business_networth := 0;
     ELSE
        l_business_networth := igf_ap_efc_calc.isir_rec.s_busi_farm_networth;
     END IF;

     -- Get Cash, Savings and Checking
     l_cash_saving := NVL(igf_ap_efc_calc.isir_rec.s_cash_savings,0);

     -- Get the Default Setting for Formula A
     OPEN  efcA_cur;
     FETCH efcA_cur  INTO  efcA_rec;
     IF efcA_cur%NOTFOUND THEN
	     CLOSE  efcA_cur;
        FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_EFCA_SETUP');
        IGS_GE_MSG_STACK.ADD;
        RAISE  exception_in_setup;
     END IF;
     CLOSE    efcA_cur;

     -- Get Net Worth
     l_net_worth := l_investment_networth + l_business_networth + l_cash_saving;

     igf_ap_efc_calc.isir_rec.sdnw := l_net_worth; --Assignment of intermediate values
     igf_ap_efc_calc.isir_rec.secsdnw := l_net_worth;   --Assignment of intermediate values

     -- Get Contribution from Assets
     p_s_cont_assets := l_net_worth * NVL(efcA_rec.stud_asset_assessment_rate,0)/100;
     p_s_cont_assets := ROUND( p_s_cont_assets );

     igf_ap_efc_calc.isir_rec.sca := p_s_cont_assets;  --Assignment of intermediate values
     igf_ap_efc_calc.isir_rec.secsca := p_s_cont_assets; --Assignment of intermediate values

  EXCEPTION
     WHEN exception_in_setup THEN
          RAISE igf_ap_efc_calc.exception_in_setup; -- Exception to be handled in the Calling Procedures
     WHEN OTHERS THEN
	       FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_SUBF.A_S_CONT_ASSETS');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
  END a_s_cont_assets;


  PROCEDURE  a_efc  ( p_p_cont           IN             NUMBER,
                      p_s_cont           IN             NUMBER,
                      p_s_cont_assets    IN             NUMBER,
                      p_efc                 OUT NOCOPY  NUMBER)   AS
  /*
  ||  Created By : gmuralid
  ||  Created On : 11 Feb 2003
  ||  Purpose :    Procedure to get EFC from formula A , Bug# 2758804 , EFC build TD
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
  BEGIN
--      p_efc := p_p_cont + p_s_cont + p_s_cont_assets;
      -- Students Contribution from Assets is not taken .
      p_efc := p_p_cont + p_s_cont ;
      IF p_efc < 0 THEN
         p_efc := 0;
      END IF;
  END a_efc;


  PROCEDURE  a_p_cont_less_9 ( p_p_cont           IN              NUMBER,
                               p_no_of_months     IN              NUMBER,
                               p_p_cont_less_9        OUT NOCOPY  NUMBER)   AS
  /*
  ||  Created By : gmuralid
  ||  Created On : 11 Feb 2003
  ||  Purpose :    Procedure to get Parents Contribution for student enrolled for less than 9 months , Bug# 2758804 , EFC build TD
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */

    l_p_cont_per_mon   NUMBER;

  BEGIN
     -- Get Parents contribution per month
     l_p_cont_per_mon := p_p_cont / 9 ;

     -- Parents contribution for less than 9 months Enrollment
     p_p_cont_less_9 := l_p_cont_per_mon * p_no_of_months;

  END a_p_cont_less_9;


  PROCEDURE  a_s_cont_less_9 ( p_s_cont           IN     NUMBER,
                               p_no_of_months     IN     NUMBER,
                               p_s_cont_less_9    OUT NOCOPY     NUMBER)   AS
  /*
  ||  Created By : gmuralid
  ||  Created On : 11 Feb 2003
  ||  Purpose :    Procedure to get students Contribution for student enrolled for less than 9 months , Bug# 2758804 , EFC build TD
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
    l_s_cont_per_month   NUMBER;
  BEGIN
     -- Students contribution from AI per month
     l_s_cont_per_month := p_s_cont / 9 ;

     -- Student contribution from AI for less than 9 month enrollment
     p_s_cont_less_9 := l_s_cont_per_month * p_no_of_months ;

  END a_s_cont_less_9;


  PROCEDURE  a_efc_not_9 ( p_p_cont_not_9      IN             NUMBER,
                           p_s_cont_not_9      IN             NUMBER,
                           p_s_cont_assets     IN             NUMBER,
                           p_efc                  OUT NOCOPY  NUMBER)   AS
  /*
  ||  Created By : gmuralid
  ||  Created On : 11 Feb 2003
  ||  Purpose :    Procedure to get EFC for student enrolled other than 9 months , Bug# 2758804 , EFC build TD
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
  BEGIN

     --    p_efc := p_p_cont_not_9 + p_s_cont_not_9 + p_s_cont_assets ;
     --  Students contribution from Assets not considered for approtioning
     --  Ref Bug# 2384837

     p_efc := p_p_cont_not_9 + p_s_cont_not_9 ;
     IF p_efc < 0 THEN
        p_efc := 0;
     END IF;

  END a_efc_not_9;


  PROCEDURE  a_p_cont_more_9 ( p_p_aai            IN             NUMBER,
                               p_p_cont           IN             NUMBER,
                               p_no_of_months     IN             NUMBER,
                               p_p_cont_more_9       OUT NOCOPY  NUMBER)    AS
  /*
  ||  Created By : gmuralid
  ||  Created On : 11 Feb 2003
  ||  Purpose :    Procedure to get parents contribution for student enrolled more than 9 months , Bug# 2758804 , EFC build TD
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */

    l_aai_more_9       NUMBER;
    l_p_cont_aai       NUMBER;
    l_p_cont           NUMBER;
    l_p_cont_diff      NUMBER;
    l_p_cont_per_month NUMBER;
    l_p_cont_adj       NUMBER;

    -- Cursor to find the Default Setting for Formula A
    CURSOR    efcA_cur IS
       SELECT income_protection_diff_9
         FROM igf_fc_efc_frm_a   efca
        WHERE efca.s_award_year = igf_ap_efc_calc.p_sys_award_year;


    -- Cursor to calculate Parents Contribution from AAI
    CURSOR    p_cont_aai_cur(cp_p_aai NUMBER)  IS
       SELECT tax_rate, amount, tax_rate_excess, amount_excess
         FROM igf_fc_gen_tax_rts  gtxrts
        WHERE gtxrts.table_code   = 'A6'
          AND gtxrts.s_award_year = igf_ap_efc_calc.p_sys_award_year
          AND (cp_p_aai BETWEEN gtxrts.income_range_start AND gtxrts.income_range_end);

    p_cont_aai_rec    p_cont_aai_cur%ROWTYPE;
    efcA_rec          efcA_cur%ROWTYPE;

  BEGIN
     -- Get the Default Setting for Formula A
     OPEN efcA_cur;
     FETCH efcA_cur INTO efcA_rec;
     IF efcA_cur%NOTFOUND THEN
        CLOSE  efcA_cur;
        FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_EFCA_SETUP');
        IGS_GE_MSG_STACK.ADD;
        RAISE  exception_in_setup;
     END IF;
     CLOSE efcA_cur;

     -- Get Adjusted Available Income for more than 9 months
     --  ( Parents AAI + Difference between the income protection allowance for a
     --                   family of four and a family of five, with one in college)
     l_aai_more_9 := p_p_aai + NVL(efcA_rec.income_protection_diff_9,0);

    -- Get Total Parents contribution from Adjusted Available Income
    OPEN p_cont_aai_cur(l_aai_more_9);
    FETCH p_cont_aai_cur   INTO  p_cont_aai_rec;
    IF p_cont_aai_cur%NOTFOUND THEN
       CLOSE  p_cont_aai_cur;
       FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_GEN_TAX_SETUP');
       FND_MESSAGE.SET_TOKEN('TABLE_NAME','A6');
       IGS_GE_MSG_STACK.ADD;
       RAISE  exception_in_setup;
       END IF;
    CLOSE    p_cont_aai_cur;

    IF p_cont_aai_rec.tax_rate IS NULL THEN
       l_p_cont_aai := p_cont_aai_rec.amount +
                       (( p_cont_aai_rec.tax_rate_excess * (l_aai_more_9 - p_cont_aai_rec.amount_excess)) / 100 );
    ELSE
       l_p_cont_aai := ( p_cont_aai_rec.tax_rate * l_aai_more_9 ) / 100 ;
    END IF ;

    -- Total Parents contribution from Adjusted Available Income
    -- (Can not be Negative)
    IF l_p_cont_aai < 0 THEN
       l_p_cont_aai := 0;
    END IF;

    l_p_cont_aai := ROUND(l_p_cont_aai) ;

    -- Get parents contribution (Total Parents contribution from AAI/Number in college in 2001-02)
    l_p_cont := ROUND(l_p_cont_aai / NVL(NVL(igf_ap_efc_calc.isir_rec.a_parents_num_college,igf_ap_efc_calc.isir_rec.p_num_in_college),1));

    -- Difference Between Calculated Parents contribution and Standard Parents Contribution(For 9 months)
    l_p_cont_diff := l_p_cont - p_p_cont;

    -- Parents contribution per month
    l_p_cont_per_month := ROUND(l_p_cont_diff / 12);

    -- Adjustment to parents contribution
    -- for months that exceed 9
    l_p_cont_adj := ROUND(l_p_cont_per_month * (p_no_of_months -9));

    --Parents contribution for MORE than 9-month enrollment
    p_p_cont_more_9 := p_p_cont + l_p_cont_adj;


  EXCEPTION
     WHEN exception_in_setup THEN
          RAISE igf_ap_efc_calc.exception_in_setup; -- Exception to be handled in the Calling Procedures
     WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_SUBF.A_P_CONT_MORE_9');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
  END a_p_cont_more_9;


  -- SUB FUNCTIONS  for calculating EFC with FORMULA B

  PROCEDURE  b_s_inc ( p_s_inc   OUT NOCOPY    NUMBER)    AS
  /*
  ||  Created By : gmuralid
  ||  Created On : 11 Feb 2003
  ||  Purpose :    Procedure to get students Income for formula B , Bug# 2758804 , EFC build TD
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */

    l_adjusted_gross_income    igf_ap_isir_matched.s_adjusted_gross_income%TYPE;
    l_s_inc_work               NUMBER;
    l_tot_tax_inc              NUMBER;
    l_tot_untax_inc            NUMBER;
    l_tot_inc                  NUMBER;

  BEGIN
     -- Get Student's and spouse's Adjusted Gross Income( If negative take 0)
     IF NVL(NVL(igf_ap_efc_calc.isir_rec.a_student_agi,igf_ap_efc_calc.isir_rec.s_adjusted_gross_income),0) <= 0 THEN
        l_adjusted_gross_income := 0;
     ELSE
        l_adjusted_gross_income := NVL(igf_ap_efc_calc.isir_rec.a_student_agi,igf_ap_efc_calc.isir_rec.s_adjusted_gross_income);
     END IF;


     -- Get Student's and Spouse's Toatal income earned from work
     l_s_inc_work  := NVL(NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work),0) + NVL(NVL(igf_ap_efc_calc.isir_rec.a_spouse_income_work,igf_ap_efc_calc.isir_rec.spouse_income_from_work),0);

     -- Get the Student's Taxable income( If Taxable = Adjusted Gross Income Else
     -- = Income earned from Work)



     IF igf_ap_efc_calc.isir_rec.s_cal_tax_status IN ('1','2','3') THEN
        l_tot_tax_inc := l_adjusted_gross_income;
     ELSE
        l_tot_tax_inc := l_s_inc_work;
     END IF;


     -- Total Untaxed Income and benefits
     -- Total from FAFSA Worksheet A + Total from FAFSA Worksheet B
     l_tot_untax_inc := NVL(igf_ap_efc_calc.isir_rec.s_toa_amt_from_wsa,0) +
                        NVL(igf_ap_efc_calc.isir_rec.s_toa_amt_from_wsb,0);


     -- Total Income = Total Taxable Income + Total Untaxable Income.
     l_tot_inc := l_tot_tax_inc + l_tot_untax_inc;


     -- Student's total Income = Total Income - Total from FAFSA Worksheet C
     p_s_inc := l_tot_inc - NVL(NVL(igf_ap_efc_calc.isir_rec.a_s_total_wsc,igf_ap_efc_calc.isir_rec.s_toa_amt_from_wsc),0);

     p_s_inc := ROUND( p_s_inc );


     igf_ap_efc_calc.isir_rec.total_income := p_s_inc; --Assignment of intermediate values
     igf_ap_efc_calc.isir_rec.secti := p_s_inc; --Assignment of intermediate values

     igf_ap_efc_calc.isir_rec.fti := p_s_inc;
     igf_ap_efc_calc.isir_rec.secfti := p_s_inc;

  EXCEPTION

     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_SUBF.B_S_INC');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

  END b_s_inc;


  PROCEDURE  b_allow_ag_s_inc ( p_s_inc           IN             NUMBER,
                                p_allow_ag_s_inc     OUT NOCOPY  NUMBER)  AS
  /*
  ||  Created By :  gmuralid
  ||  Created On :  11 Feb 2003
  ||  Purpose :     Procedure to get allowances against students Income for formula B , Bug# 2758804 , EFC build TD
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */

    l_s_taxes_paid               igf_ap_isir_matched.p_taxes_paid%TYPE;
    l_state                      igf_lookups_view.lookup_code%TYPE;
    l_tax_allowance              NUMBER;
    l_s_sst                      NUMBER;
    l_spouse_sst                 NUMBER;
    l_ipa                        NUMBER;
    l_eea                        NUMBER;
    l_state_cd                   VARCHAR2(30);

     -- Cursor to find the Valid State
    CURSOR    state_cur(cp_state igf_lookups_view.lookup_code%TYPE) IS
       SELECT lookup_code
         FROM igf_lookups_view
        WHERE lookup_type = 'IGF_AP_STATE_CODES'
          AND lookup_code = cp_state;

    -- Cursor to calculate State and other tax allowance
    CURSOR    state_allow_cur(cp_state igf_lookups_view.lookup_code%TYPE) IS
       SELECT tax_rate
         FROM igf_fc_state_tx    txrng
        WHERE txrng.table_code   = 'B1'
          AND txrng.s_award_year = igf_ap_efc_calc.p_sys_award_year
          AND txrng.state_code   = cp_state;

     -- Cursor to calculate Social Security Tax for Student and Spouse.
    CURSOR    sst_cur(cp_inc_work  igf_ap_isir_matched.s_income_from_work%TYPE)  IS
       SELECT tax_rate, amount, tax_rate_excess, amount_excess
         FROM igf_fc_gen_tax_rts  gtxrts
        WHERE gtxrts.table_code    = 'B2'
          AND gtxrts.s_award_year = igf_ap_efc_calc.p_sys_award_year
          AND (cp_inc_work BETWEEN gtxrts.income_range_start AND gtxrts.income_range_end);

      -- Cursor to find the Default values defined for Formula B.
    CURSOR     efcB_cur IS
       SELECT  unmarried_stud_ipa_amt, mss_half_time_ipa_amt,married_stud_ipa_amt, unmarried_stud_eea_amt,
               married_one_work_eea_amt,married_two_work_eea_rate, married_two_work_eea_amt
         FROM  igf_fc_efc_frm_b  efcb
        WHERE  efcb.s_award_year = igf_ap_efc_calc.p_sys_award_year;

    state_rec                 state_cur%ROWTYPE;
    state_allow_rec           state_allow_cur%ROWTYPE;
    sst_rec                   sst_cur%ROWTYPE;
    efcB_rec                  efcB_cur%ROWTYPE;

  BEGIN

     -- For Non Tax Filers OR with Income Tax Paid Negative should be processed, process with 0
     IF  ((NVL(igf_ap_efc_calc.isir_rec.s_cal_tax_status,'-1') NOT IN ('1','2','3')) OR (NVL(NVL(igf_ap_efc_calc.isir_rec.a_s_us_tax_paid,igf_ap_efc_calc.isir_rec.s_fed_taxes_paid),0) <= 0)) THEN
         l_s_taxes_paid := 0;
     ELSE
         l_s_taxes_paid := NVL(igf_ap_efc_calc.isir_rec.a_s_us_tax_paid,igf_ap_efc_calc.isir_rec.s_fed_taxes_paid);
     END IF;

     -- Process to calculate State and other tax allowance only if Student's Income > 0
     IF  p_s_inc > 0 THEN
         -- To find the proper State process in the order of
         -- Students state of legal residence (If invalid then)
         -- State in the Students mailing address (If invalid then)
         -- Blank or Invalid state
         l_state_cd := igf_ap_efc_calc.isir_rec.s_state_legal_residence;

     IF l_state_cd = 'FC' THEN
           l_state_cd := 'OT';
         END IF;

         OPEN state_cur(l_state_cd);
         FETCH state_cur  INTO  state_rec;
         l_state := state_rec.lookup_code;
         CLOSE   state_cur;

         IF l_state IS NULL THEN

            l_state_cd := igf_ap_efc_calc.isir_rec.perm_state;
            IF l_state_cd = 'FC' THEN
              l_state_cd := 'OT';
            END IF;

            OPEN    state_cur(l_state_cd);
            FETCH   state_cur  INTO  state_rec;
            l_state := state_rec.lookup_code;
            CLOSE   state_cur;
         END IF;

         IF l_state IS NULL THEN
            l_state := 'BL';
         END IF;

         OPEN   state_allow_cur(l_state);
         FETCH  state_allow_cur   INTO  state_allow_rec;
         IF state_allow_cur%NOTFOUND THEN
            CLOSE  state_allow_cur;
            OPEN state_allow_cur('OT');
            FETCH  state_allow_cur   INTO  state_allow_rec;
            IF state_allow_cur%NOTFOUND THEN
              CLOSE  state_allow_cur;
              FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_TAX_SETUP');
              FND_MESSAGE.SET_TOKEN('TABLE_NAME','B1');
              IGS_GE_MSG_STACK.ADD;
              RAISE  exception_in_setup;
            END IF;
         END IF;
         CLOSE  state_allow_cur;

         -- Determine the State and other tax allowance
         l_tax_allowance := ( p_s_inc * state_allow_rec.tax_rate ) / 100 ;

      ELSE
         -- If Student's Income <= 0 then assume Tax Allowance to be 0
         l_tax_allowance := 0;
      END IF;

      l_tax_allowance := ROUND(l_tax_allowance) ;

      igf_ap_efc_calc.isir_rec.state_tax_allow := l_tax_allowance;
      igf_ap_efc_calc.isir_rec.secstx :=  l_tax_allowance;
      --from here

      -- Calculating the Social Security Tax for Student
      IF NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work) IS NOT NULL THEN
         OPEN    sst_cur(greatest(NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work),0));
         FETCH   sst_cur  INTO sst_rec;
         IF sst_cur%NOTFOUND THEN
            CLOSE  sst_cur;
            FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_GEN_TAX_SETUP');
            FND_MESSAGE.SET_TOKEN('TABLE_NAME','A2');
            IGS_GE_MSG_STACK.ADD;
            RAISE  exception_in_setup;
         END IF;
         CLOSE   sst_cur;

         IF sst_rec.tax_rate IS NULL THEN
            l_s_sst := sst_rec.amount +
                     (( sst_rec.tax_rate_excess * (greatest(NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work),0) - sst_rec.amount_excess)) / 100 );
         ELSE
            l_s_sst := ( sst_rec.tax_rate * (greatest(NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work),0)) / 100 );
         END IF ;

         -- Social Security Tax can not be Negative
         IF ( l_s_sst < 0 ) THEN
            l_s_sst := 0;
         END IF;
      ELSE
         l_s_sst := 0;
      END IF;

      l_s_sst := ROUND(l_s_sst) ;


      -- Calculating the Social Security Tax for Spouse
      IF NVL(igf_ap_efc_calc.isir_rec.a_spouse_income_work,igf_ap_efc_calc.isir_rec.spouse_income_from_work) IS NOT NULL THEN
         OPEN    sst_cur(greatest(NVL(igf_ap_efc_calc.isir_rec.a_spouse_income_work,igf_ap_efc_calc.isir_rec.spouse_income_from_work),0));
         FETCH   sst_cur  INTO sst_rec;
         IF sst_cur%NOTFOUND THEN
            CLOSE  sst_cur;
            FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_GEN_TAX_SETUP');
            FND_MESSAGE.SET_TOKEN('TABLE_NAME','B2');
            IGS_GE_MSG_STACK.ADD;
            RAISE  exception_in_setup;
         END IF;
         CLOSE   sst_cur;

         IF sst_rec.tax_rate IS NULL THEN


            l_spouse_sst := sst_rec.amount +
                            (( sst_rec.tax_rate_excess * (greatest(NVL(igf_ap_efc_calc.isir_rec.a_spouse_income_work,igf_ap_efc_calc.isir_rec.spouse_income_from_work),0) - sst_rec.amount_excess)) / 100 );


         ELSE
            l_spouse_sst := ( sst_rec.tax_rate * (greatest(NVL(igf_ap_efc_calc.isir_rec.a_spouse_income_work,igf_ap_efc_calc.isir_rec.spouse_income_from_work),0) ) / 100 );
         END IF ;

         -- Social Security Tax can not be Negative
         IF ( l_spouse_sst < 0 ) THEN
            l_spouse_sst := 0;
         END IF;
      ELSE
         l_spouse_sst := 0;
      END IF;

      l_spouse_sst := ROUND(l_spouse_sst) ;


      -- To find the Default values defined for EFC Formula B
      OPEN efcB_cur;
      FETCH efcB_cur  INTO  efcB_rec;
      IF efcB_cur%NOTFOUND THEN
         CLOSE  efcB_cur;
         FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_EFCB_SETUP');
         IGS_GE_MSG_STACK.ADD;
         RAISE  exception_in_setup;
      END IF;
      CLOSE efcB_cur;
      -- Calculate the Income Protection Allowance
      IF NVL ( igf_ap_efc_calc.isir_rec.a_student_marital_status , igf_ap_efc_calc.isir_rec.s_marital_status ) IN  ( '1','3') THEN
         l_ipa := NVL(efcB_rec.unmarried_stud_ipa_amt,0);
      ELSIF  NVL ( igf_ap_efc_calc.isir_rec.a_student_marital_status , igf_ap_efc_calc.isir_rec.s_marital_status ) = '2' THEN
            IF NVL(igf_ap_efc_calc.isir_rec.a_s_num_in_college,igf_ap_efc_calc.isir_rec.s_num_in_college) = 2 THEN
                l_ipa := NVL(efcB_rec.mss_half_time_ipa_amt,0);
            ELSIF NVL(igf_ap_efc_calc.isir_rec.a_s_num_in_college,igf_ap_efc_calc.isir_rec.s_num_in_college) < 2 THEN
                l_ipa := NVL(efcB_rec.married_stud_ipa_amt,0);
            ELSE
               l_ipa := 0 ;
            END IF ;
      ELSE
         l_ipa := 0 ;
      END IF ;

/*
      -- Calculate the Income Protection Allowance
      IF igf_ap_efc_calc.isir_rec.s_marital_status = '2' THEN -- Married Student
      	-- Both Student and Spouse enrolled at least 1/2 time
         IF NVL(igf_ap_efc_calc.isir_rec.a_s_num_in_family,igf_ap_efc_calc.isir_rec.s_num_family_members) = 2 AND NVL(igf_ap_efc_calc.isir_rec.a_s_num_in_college,igf_ap_efc_calc.isir_rec.s_num_in_college) = 2 THEN
            l_ipa := NVL(efcB_rec.mss_half_time_ipa_amt,0);

            -- Only one of Student and Spouse enrolled at least 1/2 time
         ELSIF NVL(igf_ap_efc_calc.isir_rec.a_s_num_in_family,igf_ap_efc_calc.isir_rec.s_num_family_members) = 2 AND NVL(igf_ap_efc_calc.isir_rec.a_s_num_in_college,igf_ap_efc_calc.isir_rec.s_num_in_college) = 1 THEN
            l_ipa := NVL(efcB_rec.married_stud_ipa_amt,0);
         ELSE
            -- If both of the above conditions failed
            l_ipa := 0;
         END IF;
      ELSE -- Student is unmarried / Separated
         l_ipa := NVL(efcB_rec.unmarried_stud_ipa_amt,0);
      END IF;*/

      igf_ap_efc_calc.isir_rec.income_protection_allow := l_ipa;
      igf_ap_efc_calc.isir_rec.secipa := l_ipa;


      -- Calculate the Employment Expense Allowance
      IF NVL ( igf_ap_efc_calc.isir_rec.a_student_marital_status , igf_ap_efc_calc.isir_rec.s_marital_status ) = '2' THEN -- Married Student
         -- If only one out of them is working
         IF    (    (NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work) IS NULL
                AND  NVL(igf_ap_efc_calc.isir_rec.a_spouse_income_work,igf_ap_efc_calc.isir_rec.spouse_income_from_work) IS NOT NULL)
            OR (     NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work) IS NOT NULL
                AND NVL(igf_ap_efc_calc.isir_rec.a_spouse_income_work,igf_ap_efc_calc.isir_rec.spouse_income_from_work) IS NULL))
            THEN
            l_eea := NVL(efcB_rec.married_one_work_eea_amt,0);

            -- If both of them are working
         ELSIF (    NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work) IS NOT NULL
                AND NVL(igf_ap_efc_calc.isir_rec.a_spouse_income_work,igf_ap_efc_calc.isir_rec.spouse_income_from_work) IS NOT NULL)
                THEN
                l_eea := LEAST((NVL(efcB_rec.married_two_work_eea_rate,0) *
                         LEAST(greatest(NVL(igf_ap_efc_calc.isir_rec.a_spouse_income_work,igf_ap_efc_calc.isir_rec.spouse_income_from_work),0),
                               greatest(NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work),0)) /100),NVL(efcB_rec.married_two_work_eea_amt,0));

         -- If both of the above conditions are failed
         ELSE
            l_eea := 0;
         END IF;
      ELSE -- Student is unmarried / Separated
         l_eea := NVL(efcB_rec.unmarried_stud_eea_amt,0);
      END IF;

      igf_ap_efc_calc.isir_rec.employment_allow := ROUND(l_eea);
      igf_ap_efc_calc.isir_rec.secea := ROUND(l_eea);

      -- Allowance against Student's Income
      p_allow_ag_s_inc := ROUND(l_s_taxes_paid) + ROUND(l_tax_allowance) + ROUND(l_s_sst) + ROUND(l_spouse_sst) + ROUND(l_ipa) + ROUND(l_eea) ;
    --   p_allow_ag_s_inc := ROUND( p_allow_ag_s_inc );

      igf_ap_efc_calc.isir_rec.allow_total_income := p_allow_ag_s_inc;  --Assignment of intermediate values
      igf_ap_efc_calc.isir_rec.secati := p_allow_ag_s_inc; --Assignment of intermediate values

  EXCEPTION
     WHEN exception_in_setup THEN
          RAISE igf_ap_efc_calc.exception_in_setup; -- Exception to be handled in the Calling Procedures
     WHEN OTHERS THEN
	     FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_SUBF.B_ALLOW_AG_S_INC');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
  END b_allow_ag_s_inc;


  PROCEDURE  b_s_cont ( p_s_inc             IN             NUMBER,
                        p_allow_ag_s_inc    IN             NUMBER,
                        p_s_cont               OUT NOCOPY  NUMBER)    AS
  /*
  ||  Created By :  gmuralid
  ||  Created On :  11 Feb 2003
  ||  Purpose :     Procedure to get students contribution for formula B , Bug# 2758804 , EFC build TD
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
    l_available_income         NUMBER;

     -- Cursor to Find the Default Setting for Formula B
    CURSOR    efcB_cur IS
       SELECT stud_available_income
         FROM igf_fc_efc_frm_b  efcb
        WHERE efcb.s_award_year = igf_ap_efc_calc.p_sys_award_year;

    efcB_rec     efcB_cur%ROWTYPE;

  BEGIN
     l_available_income := p_s_inc - p_allow_ag_s_inc;

     OPEN efcB_cur;
     FETCH efcB_cur  INTO  efcB_rec;
     IF efcB_cur%NOTFOUND THEN
        CLOSE  efcB_cur;
        FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_EFCB_SETUP');
        IGS_GE_MSG_STACK.ADD;
        RAISE  exception_in_setup;
     END IF;
     CLOSE efcB_cur;

     p_s_cont := (l_available_income * NVL(efcB_rec.stud_available_income,0)) / 100;
     p_s_cont := ROUND( p_s_cont );

--     igf_ap_efc_calc.isir_rec.sic := p_s_cont; --Assignment of intermediate values
--     igf_ap_efc_calc.isir_rec.secsic := p_s_cont; --Assignment of intermediate values

       igf_ap_efc_calc.isir_rec.available_income := l_available_income;
       igf_ap_efc_calc.isir_rec.secai := l_available_income;

       igf_ap_efc_calc.isir_rec.contribution_from_ai :=p_s_cont;
       igf_ap_efc_calc.isir_rec.seccai := p_s_cont;


  EXCEPTION
     WHEN exception_in_setup THEN
          RAISE igf_ap_efc_calc.exception_in_setup; -- Exception to be handled in the Calling Procedures
     WHEN OTHERS THEN
	       FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_SUBF.B_S_CONT');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;

  END b_s_cont;


  PROCEDURE  b_s_cont_assets ( p_s_cont_assets     OUT NOCOPY    NUMBER)  AS
  /*
  ||  Created By :  gmuralid
  ||  Created On :  11 Feb 2003
  ||  Purpose :     Procedure to get students contribution from assets for formula B , Bug# 2758804 , EFC build TD
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */

   l_investment_networth    igf_ap_isir_matched.p_investment_networth%TYPE;
   l_business_networth      igf_ap_isir_matched.p_business_networth%TYPE;
   l_adj_business_networth  NUMBER;
   l_cash_saving            igf_ap_isir_matched.p_cash_saving%TYPE;
   l_net_worth              NUMBER;
   l_age_student            NUMBER;
   l_asset_pro_allow        igf_fc_ast_pc_dt.parent2_allowance%TYPE;
   l_d_net_worth            NUMBER;

  -- Cursor to find the Setting for Formula B
    CURSOR    efcB_cur IS
       SELECT stud_asset_conv_rate
         FROM igf_fc_efc_frm_b   efcb
        WHERE efcb.s_award_year = igf_ap_efc_calc.p_sys_award_year;

  -- Cursor to calculate Asset Protection Allowance
    CURSOR    asset_cur(cp_age_student  igf_fc_ast_pc_dt.older_parent_age%TYPE) IS
       SELECT parent1_allowance, parent2_allowance
         FROM igf_fc_ast_pc_dt   apdt
        WHERE apdt.table_code       = 'B4'         --gmuralid table code I think needs to be B4 , it was A5
          AND apdt.older_parent_age = cp_age_student
          AND apdt.s_award_year     = igf_ap_efc_calc.p_sys_award_year;

  -- Cursor to calculate Adjusted Net worth of Business/farm

    CURSOR    business_networth_cur(cp_business_networth  igf_ap_isir_matched.p_business_networth%TYPE)  IS
       SELECT tax_rate, amount, tax_rate_excess, amount_excess
         FROM igf_fc_gen_tax_rts  gtxrts
        WHERE gtxrts.table_code    = 'B3'  --gmuralid Table code i think needs to be B3, it was A4
          AND gtxrts.s_award_year =  igf_ap_efc_calc.p_sys_award_year
          AND (cp_business_networth BETWEEN gtxrts.income_range_start AND gtxrts.income_range_end);

    business_networth_rec   business_networth_cur%ROWTYPE;
    efcB_rec                efcB_cur%ROWTYPE;
    asset_rec               asset_cur%ROWTYPE;
    l_base_date          DATE;

  BEGIN

    IF igf_ap_efc_calc.p_sys_award_year ='0304' THEN
      l_base_Date := to_date('31-12-2003', 'DD-MM-YYYY');
    ELSIF igf_ap_efc_calc.p_sys_award_year ='0405' THEN
      l_base_Date := to_date('31-12-2004', 'DD-MM-YYYY');
    ELSIF igf_ap_efc_calc.p_sys_award_year ='0506' THEN
      l_base_Date := to_date('31-12-2005', 'DD-MM-YYYY');
    ELSIF igf_ap_efc_calc.p_sys_award_year ='0607' THEN
      l_base_Date := to_date('31-12-2006', 'DD-MM-YYYY');
    ELSE
      l_base_Date := to_date('31-12-2002', 'dd-MM-YYYY');
    END IF;

    -- Get Net worth of investments( Can not be Negative)
    IF NVL(igf_ap_efc_calc.isir_rec.s_investment_networth,0) <= 0 THEN
      l_investment_networth := 0;
    ELSE
      l_investment_networth := igf_ap_efc_calc.isir_rec.s_investment_networth;
    END IF;

    -- Get Net Worth of business/investments farm(Can not be Negative)
    IF NVL(igf_ap_efc_calc.isir_rec.s_busi_farm_networth,0) <= 0 THEN
      l_business_networth := 0;
    ELSE
      l_business_networth := igf_ap_efc_calc.isir_rec.s_busi_farm_networth;
    END IF;

    -- Get Adjusted net worth of Business/Farm(Using B3 as both contains the same Information)
    OPEN business_networth_cur(l_business_networth);
    FETCH business_networth_cur   INTO  business_networth_rec;
    IF business_networth_cur%NOTFOUND THEN
      CLOSE business_networth_cur;
      FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_GEN_TAX_SETUP');
      FND_MESSAGE.SET_TOKEN('TABLE_NAME','B3'); --made B3 from A4 by gmuralid
      IGS_GE_MSG_STACK.ADD;
      RAISE exception_in_setup;
    END IF;
    CLOSE business_networth_cur;

    IF business_networth_rec.tax_rate IS NULL THEN
      l_adj_business_networth := business_networth_rec.amount +
                                (( business_networth_rec.tax_rate_excess * (l_business_networth - business_networth_rec.amount_excess)) / 100 );
    ELSE
      l_adj_business_networth := ( business_networth_rec.tax_rate * l_business_networth ) / 100 ;
    END IF ;

    -- Get Cash, Savings and Checking
    IF igf_ap_efc_calc.isir_rec.s_cash_savings  IS NULL THEN
      l_cash_saving := 0;
    ELSE
      l_cash_saving := igf_ap_efc_calc.isir_rec.s_cash_savings;
    END IF;

    -- Get Net Worth
    -- (Investment Net worth + Adjusted Business Net Worth + Cash Saving)
    l_net_worth := l_investment_networth + l_adj_business_networth + l_cash_saving ;

    igf_ap_efc_calc.isir_rec.efc_networth := ROUND(l_net_worth);
    igf_ap_efc_calc.isir_rec.secnw  := ROUND(l_net_worth);

    -- Get the Student's Age. If the Date of Birth is not specified in the ISIR then stop the Processing of the Student.
    IF igf_ap_efc_calc.isir_rec.date_of_birth IS NOT NULL THEN
--       l_age_student := FLOOR(MONTHS_BETWEEN(l_base_date,igf_ap_efc_calc.isir_rec.date_of_birth)/12); -- confirmed with ches and pdf , made 31/12/2003
      l_age_student := FLOOR((TO_NUMBER(TO_CHAR(l_base_date,'YYYY')) - TO_NUMBER(TO_CHAR(igf_ap_efc_calc.isir_rec.date_of_birth,'YYYY'))));

    ELSE
      FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_DOB_SPECIFIED');
      IGS_GE_MSG_STACK.ADD;
      RAISE  exception_in_setup;
    END IF;

    IF l_age_student < 25 THEN
      l_age_student := 25 ;
    ELSIF l_age_student > 65 THEN
      l_age_student := 65;
    END IF ;

    -- Get Education savings and Asset Protection Allowance(Using B4 as both contains the same Information)
    OPEN     asset_cur(l_age_student);
    FETCH    asset_cur  INTO  asset_rec;
    IF asset_cur%NOTFOUND THEN
       CLOSE  asset_cur;
       FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_ASSET_SETUP');
       FND_MESSAGE.SET_TOKEN('TABLE_NAME','B4');
       IGS_GE_MSG_STACK.ADD;
       RAISE  exception_in_setup;
    END IF;
    CLOSE    asset_cur;

    IF NVL ( igf_ap_efc_calc.isir_rec.a_student_marital_status , igf_ap_efc_calc.isir_rec.s_marital_status ) = '2' THEN
      l_asset_pro_allow := NVL(asset_rec.parent2_allowance,0);
    ELSE
      l_asset_pro_allow := NVL(asset_rec.parent1_allowance,0);
    END IF;


    igf_ap_efc_calc.isir_rec.asset_protect_allow := l_asset_pro_allow;
    igf_ap_efc_calc.isir_rec.secapa  := l_asset_pro_allow;

    -- Get Discretionary Net Worth
    l_d_net_worth := l_net_worth - l_asset_pro_allow ;

    igf_ap_efc_calc.isir_rec.discretionary_networth := ROUND(l_d_net_worth);
    igf_ap_efc_calc.isir_rec.secdnw := ROUND(l_d_net_worth);

    -- Get the Setting for Formula B
    OPEN efcB_cur;
    FETCH efcB_cur  INTO  efcB_rec;
    IF efcB_cur%NOTFOUND THEN
       CLOSE  efcB_cur;
       FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_EFCB_SETUP');
       IGS_GE_MSG_STACK.ADD;
       RAISE  exception_in_setup;
    END IF;
    CLOSE    efcB_cur;

    -- Get Contribution from Assets
    p_s_cont_assets := l_d_net_worth * NVL(efcB_rec.stud_asset_conv_rate,0) / 100;

    IF p_s_cont_assets < 0 THEN
      p_s_cont_assets := 0;
    END IF;

    p_s_cont_assets:= ROUND( p_s_cont_assets );

    igf_ap_efc_calc.isir_rec.sca := p_s_cont_assets; --Assignment of intermediate values
    igf_ap_efc_calc.isir_rec.secsca := p_s_cont_assets; --Assignment of intermediate values

  EXCEPTION
     WHEN exception_in_setup THEN
          RAISE igf_ap_efc_calc.exception_in_setup; -- Exception to be handled in the Calling Procedures
     WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_SUBF.B_S_CONT_ASSETS');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;

  END b_s_cont_assets;


  PROCEDURE  b_efc ( p_s_cont            IN              NUMBER,
                     p_s_cont_assets     IN              NUMBER,
                     p_efc                   OUT NOCOPY  NUMBER)    AS
  /*
  ||  Created By :  gmuralid
  ||  Created On :  11 Feb 2003
  ||  Purpose :     Procedure to get efc from formula B , Bug# 2758804 , EFC build TD
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
    l_s_cont             NUMBER;

  BEGIN
     l_s_cont := p_s_cont + p_s_cont_assets;

     p_efc := ROUND(l_s_cont) / NVL(NVL(igf_ap_efc_calc.isir_rec.a_s_num_in_college,igf_ap_efc_calc.isir_rec.s_num_in_college),1);
     p_efc:= ROUND(p_efc);
     IF p_efc < 0 THEN
        p_efc := 0;
     END IF;

   END b_efc;


  PROCEDURE  b_efc_less_9 ( p_no_of_months      IN             NUMBER,
                            p_efc               IN OUT NOCOPY  NUMBER)    AS
  /*
  ||  Created By :  gmuralid
  ||  Created On :  11 Feb 2003
  ||  Purpose :     Procedure to get efc from formula B for less than 9 months, Bug# 2758804 , EFC build TD
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */

    l_efc_per_month   NUMBER;

  BEGIN
     -- To determine the EFC per month


     l_efc_per_month := p_efc / 9;

     -- Get EFC for no of months of enrollment
     p_efc := l_efc_per_month * p_no_of_months ;

  END b_efc_less_9;


  -- SUB FUNCTIONS  for calculating EFC with FORMULA C

  PROCEDURE  c_s_inc ( p_s_inc     OUT NOCOPY    NUMBER)    AS
  /*
  ||  Created By :gmuralid
  ||  Created On :11 Feb 2003
  ||  Purpose :   Procedure to get students income for formula C, Bug# 2758804 , EFC build TD
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
  -- Initialize the local variables with the Global variables.

    l_adjusted_gross_income    igf_ap_isir_matched.s_adjusted_gross_income%TYPE;
    l_s_inc_work               NUMBER;
    l_tot_tax_inc              NUMBER;
    l_tot_untax_inc            NUMBER;
    l_tot_inc                  NUMBER;

      -- Cursor to find out the ISIR information for the Student
   BEGIN

      -- Get Student's and spouse's Adjusted Gross Income( If negative take 0)
      IF NVL(NVL(igf_ap_efc_calc.isir_rec.a_student_agi,igf_ap_efc_calc.isir_rec.s_adjusted_gross_income),0) <= 0 THEN
         l_adjusted_gross_income := 0;
      ELSE
         l_adjusted_gross_income := NVL(igf_ap_efc_calc.isir_rec.a_student_agi,igf_ap_efc_calc.isir_rec.s_adjusted_gross_income);
      END IF;

      -- Get Student's and Spouse's Toatal income earned from work
      l_s_inc_work  := NVL(NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work),0) +
                       NVL(NVL(igf_ap_efc_calc.isir_rec.a_spouse_income_work,igf_ap_efc_calc.isir_rec.spouse_income_from_work),0);

      -- Get the Student's Taxable income( If Taxable = Adjusted Gross Income Else
      -- = Income earned from Work)
      IF igf_ap_efc_calc.isir_rec.s_cal_tax_status IN ('1','2','3') THEN
         l_tot_tax_inc := l_adjusted_gross_income;
      ELSE
         l_tot_tax_inc := l_s_inc_work;
      END IF;

      -- Total Untaxed Income and benefits
      -- Total from FAFSA Worksheet A + Total from FAFSA Worksheet B
      l_tot_untax_inc := NVL(igf_ap_efc_calc.isir_rec.s_toa_amt_from_wsa,0) + NVL(igf_ap_efc_calc.isir_rec.s_toa_amt_from_wsb,0);

      -- Total Income = Total Taxable Income + Total Untaxable Income.
      l_tot_inc := l_tot_tax_inc + l_tot_untax_inc;

      -- Student's total Income = Total Income - Total from FAFSA Worksheet C
      p_s_inc := l_tot_inc - NVL(NVL(igf_ap_efc_calc.isir_rec.a_s_total_wsc,igf_ap_efc_calc.isir_rec.s_toa_amt_from_wsc),0);

      igf_ap_efc_calc.isir_rec.total_income := p_s_inc;  --Assignment of intermediate values
      igf_ap_efc_calc.isir_rec.secti := p_s_inc;  --Assignment of intermediate values

      igf_ap_efc_calc.isir_rec.fti := p_s_inc;
      igf_ap_efc_calc.isir_rec.secfti := p_s_inc;


  EXCEPTION

     WHEN OTHERS THEN
	       FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_SUBF.C_S_INC');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
  END c_s_inc;


  PROCEDURE  c_allow_ag_s_inc ( p_s_inc             IN              NUMBER,
                                p_allow_ag_s_inc        OUT NOCOPY  NUMBER)     AS
  /*
  ||  Created By : gmuralid
  ||  Created On : 11 Feb 2003
  ||  Purpose :    Procedure to get allowances against students income for formula C, Bug# 2758804 , EFC build TD
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
       -- Initialize the local variables with the Global variables.

    l_s_taxes_paid               igf_ap_isir_matched.p_taxes_paid%TYPE;
    l_state                      igf_lookups_view.lookup_code%TYPE;
    l_tax_allowance              NUMBER;
    l_s_sst                      NUMBER;
    l_spouse_sst                 NUMBER;
    l_ipa                        NUMBER;
    l_eea                        NUMBER;

     -- Cursor to find the Valid State
    CURSOR    state_cur(cp_state igf_lookups_view.lookup_code%TYPE) IS
       SELECT lookup_code
         FROM igf_lookups_view
        WHERE lookup_type = 'IGF_AP_STATE_CODES'
          AND lookup_code = cp_state;

     -- Cursor to calculate State and other tax allowance(Use of table A1 instead C1 as both have same Information)
    CURSOR    state_allow_cur(cp_state igf_lookups_view.lookup_code%TYPE) IS
       SELECT tax_rate
         FROM igf_fc_state_tx   txrng
        WHERE txrng.table_code       = 'C1'
          AND txrng.state_code       = cp_state
          AND txrng.s_award_year     = igf_ap_efc_calc.p_sys_award_year
          AND (p_s_inc BETWEEN txrng.income_range_start AND txrng.income_range_end) ;

     -- Cursor to calculate Social Security Tax for Student and Spouse.(Use of table A2 instead C2 as both have same Information)
    CURSOR    sst_cur(cp_inc_work  igf_ap_isir_matched.s_income_from_work%TYPE)  IS
       SELECT tax_rate, amount, tax_rate_excess, amount_excess
         FROM igf_fc_gen_tax_rts  gtxrts
        WHERE gtxrts.table_code    = 'C2'
          AND gtxrts.s_award_year  = igf_ap_efc_calc.p_sys_award_year
          AND (cp_inc_work BETWEEN gtxrts.income_range_start AND gtxrts.income_range_end);

      -- Cursor to calculate Income Protection Allowance(Use of table C3 )
      CURSOR    ipa_cur(cp_num_family_member  igf_ap_isir_matched.p_num_family_member%TYPE,
                        cp_num_in_college     igf_ap_isir_matched.p_num_in_college%TYPE) IS
       SELECT ip_allowance_amt
         FROM igf_fc_inc_prct     ipa
        WHERE ipa.table_code            = 'C3'
          AND ipa.people_in_household   = cp_num_family_member
          AND ipa.students_in_household = cp_num_in_college
          AND ipa.s_award_year          = igf_ap_efc_calc.p_sys_award_year;

      -- Cursor to find the Default values defined for Formula C.
    CURSOR    efcC_cur IS
       SELECT eea_mrd_2_wrk_rate, eea_mrd_2_wrk_amt,
              eea_mrd_1_wrk_rate, eea_mrd_1_wrk_amt
         FROM igf_fc_efc_frm_c  efcc
        WHERE efcc.s_award_year = igf_ap_efc_calc.p_sys_award_year;

    state_rec                 state_cur%ROWTYPE;
    state_allow_rec           state_allow_cur%ROWTYPE;
    sst_rec                   sst_cur%ROWTYPE;
    ipa_rec                   ipa_cur%ROWTYPE;
    efcC_rec                  efcC_cur%ROWTYPE;
    l_stud_fam_cont           NUMBER ;
    l_stud_col_cont           NUMBER ;
    s_n_fam                   NUMBER ;
    s_n_fam1                  NUMBER ;
    s_n_col                   NUMBER ;
    s_n_col1                  NUMBER ;
    l_state_cd                VARCHAR2(30);

  BEGIN
     -- For Non Tax Filers OR with Income Tax Paid Negative should be processed, process with 0
     IF    ((NVL(igf_ap_efc_calc.isir_rec.s_cal_tax_status,'-1') NOT IN ('1','2','3'))
        OR  (NVL(NVL(igf_ap_efc_calc.isir_rec.a_s_us_tax_paid,igf_ap_efc_calc.isir_rec.s_fed_taxes_paid),0) <= 0))
        THEN
        l_s_taxes_paid := 0;
    ELSE
        l_s_taxes_paid := NVL(igf_ap_efc_calc.isir_rec.a_s_us_tax_paid,igf_ap_efc_calc.isir_rec.s_fed_taxes_paid);
    END IF;

      -- Process to calculate State and other tax allowance only if Student's Income > 0
    IF  p_s_inc > 0 THEN
          -- To find the proper State process in the order of
          -- Students state of legal residence (If invalid then)
          -- State in the Students mailing address (If invalid then)
          -- Blank or Invalid state
          l_state_cd :=  igf_ap_efc_calc.isir_rec.s_state_legal_residence;

          IF l_state_cd = 'FC' THEN
            l_state_cd := 'OT';
          END IF;

          OPEN    state_cur(l_state_cd);
          FETCH   state_cur  INTO  state_rec;
          l_state := state_rec.lookup_code;
          CLOSE   state_cur;

          IF l_state IS NULL THEN

             l_state_cd := igf_ap_efc_calc.isir_rec.perm_state;

             IF l_state_cd = 'FC' THEN
               l_state_cd := 'OT';
             END IF;

             OPEN    state_cur(l_state_cd);
             FETCH   state_cur  INTO  state_rec;
             l_state := state_rec.lookup_code;
             CLOSE   state_cur;
          END IF;

          IF l_state IS NULL THEN
             l_state := 'BL';
          END IF;

          OPEN   state_allow_cur(l_state);
          FETCH  state_allow_cur   INTO  state_allow_rec;
          IF state_allow_cur%NOTFOUND THEN
             CLOSE  state_allow_cur;
             OPEN state_allow_cur('OT');
             FETCH  state_allow_cur   INTO  state_allow_rec;
             IF state_allow_cur%NOTFOUND THEN
               CLOSE  state_allow_cur;
               FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_TAX_SETUP');
               FND_MESSAGE.SET_TOKEN('TABLE_NAME','C1');
               IGS_GE_MSG_STACK.ADD;
               RAISE  exception_in_setup;
             END IF;
           END IF;
          CLOSE  state_allow_cur;

          -- Determine the State and other tax allowance
          l_tax_allowance := ( p_s_inc * state_allow_rec.tax_rate) / 100 ;

          -- State and other tax allowance can not be Negative
          IF ( l_tax_allowance < 0 ) THEN
               l_tax_allowance := 0;
          END IF;

       ELSE -- If Student's Income <= 0 then assume Tax Allowance to be 0
          l_tax_allowance := 0;
       END IF;

       igf_ap_efc_calc.isir_rec.state_tax_allow := ROUND(l_tax_allowance);
       igf_ap_efc_calc.isir_rec.secstx := ROUND(l_tax_allowance);


       -- Calculating the Social Security Tax for Student
       IF NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work) IS NOT NULL THEN
          OPEN    sst_cur(greatest(NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work),0));
          FETCH   sst_cur  INTO sst_rec;
          IF sst_cur%NOTFOUND THEN
             CLOSE  sst_cur;
             FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_GEN_TAX_SETUP');
             FND_MESSAGE.SET_TOKEN('TABLE_NAME','C2');
             IGS_GE_MSG_STACK.ADD;
             RAISE  exception_in_setup;
          END IF;
          CLOSE   sst_cur;

          IF sst_rec.tax_rate IS NULL THEN
             l_s_sst := sst_rec.amount +
                       (( sst_rec.tax_rate_excess * (greatest(NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work),0) - sst_rec.amount_excess)) / 100 );
          ELSE
             l_s_sst := ( sst_rec.tax_rate * (greatest(NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work),0) ) / 100 );
          END IF ;

          -- Social Security Tax can not be Negative
          IF ( l_s_sst < 0 ) THEN
             l_s_sst := 0;
          END IF;
       ELSE
          l_s_sst := 0;
       END IF;

       -- Calculating the Social Security Tax for Spouse
       IF NVL(igf_ap_efc_calc.isir_rec.a_spouse_income_work,igf_ap_efc_calc.isir_rec.spouse_income_from_work) IS NOT NULL THEN
          OPEN    sst_cur(greatest(NVL(igf_ap_efc_calc.isir_rec.a_spouse_income_work,igf_ap_efc_calc.isir_rec.spouse_income_from_work),0));
          FETCH   sst_cur  INTO sst_rec;
          IF sst_cur%NOTFOUND THEN
             CLOSE  sst_cur;
             FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_GEN_TAX_SETUP');
             FND_MESSAGE.SET_TOKEN('TABLE_NAME','C2');
             IGS_GE_MSG_STACK.ADD;
             RAISE  exception_in_setup;
          END IF;
          CLOSE   sst_cur;

          IF sst_rec.tax_rate IS NULL THEN
             l_spouse_sst := sst_rec.amount +
                            (( sst_rec.tax_rate_excess * (greatest(NVL(igf_ap_efc_calc.isir_rec.a_spouse_income_work,igf_ap_efc_calc.isir_rec.spouse_income_from_work),0) - sst_rec.amount_excess)) / 100 );
          ELSE
             l_spouse_sst := ( sst_rec.tax_rate * greatest(NVL(igf_ap_efc_calc.isir_rec.a_spouse_income_work,igf_ap_efc_calc.isir_rec.spouse_income_from_work),0) ) / 100 ;
          END IF ;

          -- Social Security Tax can not be Negative
          IF ( l_spouse_sst < 0 ) THEN
             l_spouse_sst := 0;
          END IF;
       ELSE
          l_spouse_sst := 0;
       END IF;


       s_n_fam :=  NVL(igf_ap_efc_calc.isir_rec.a_s_num_in_family,igf_ap_efc_calc.isir_rec.s_num_family_members);
       s_n_col := NVL(igf_ap_efc_calc.isir_rec.a_s_num_in_college,igf_ap_efc_calc.isir_rec.s_num_in_college);

       IF s_n_fam IS NOT NULL   AND  s_n_col IS NOT NULL   THEN
          -- Calculate Income Protection Allowance of Student
          OPEN     ipa_cur(s_n_fam,s_n_col);
          FETCH    ipa_cur  INTO  ipa_rec;
          IF ipa_cur%NOTFOUND THEN
             CLOSE ipa_cur;
             IF( s_n_fam IS NULL) OR (s_n_col IS NULL ) THEN
                 FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_INC_PRT_ALW_SETUP');
                 FND_MESSAGE.SET_TOKEN('TABLE_NAME','C3');
                 IGS_GE_MSG_STACK.ADD;
                 RAISE exception_in_setup;
             END IF;

             s_n_fam1 := 0;
             s_n_col1 := 0;

             IF s_n_fam > 6 THEN
                s_n_fam1 := s_n_fam - 6;
                s_n_fam  := 6 ;
             END IF;

             IF s_n_col > 5 THEN
                s_n_col1 := s_n_col - 5;
                s_n_col  := 5 ;
             END IF;

             get_par_stud_cont( igf_ap_efc_calc.p_sys_award_year, l_stud_fam_cont,l_stud_col_cont );

             OPEN ipa_cur(s_n_fam,s_n_col);
             FETCH ipa_cur INTO ipa_rec;
             CLOSE ipa_cur ;
             l_ipa := (ipa_rec.ip_allowance_amt + (s_n_fam1 * l_stud_fam_cont ) ) - ((s_n_col1 * l_stud_col_cont ));
         ELSE -- IPA CUR FOUND
              CLOSE ipa_cur;
              l_ipa := ipa_rec.ip_allowance_amt;
         END IF;
      ELSE
        l_ipa := 0;
      END IF;

      igf_ap_efc_calc.isir_rec.income_protection_allow := l_ipa;
      igf_ap_efc_calc.isir_rec.secipa := l_ipa;


       -- To find the Default values defined for EFC Formula C( To determine the Employment Expense Allowance)
       OPEN     efcC_cur;
       FETCH    efcC_cur  INTO  efcC_rec;
       IF efcC_cur%NOTFOUND THEN
          CLOSE  efcC_cur;
          FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_EFCC_SETUP');
          IGS_GE_MSG_STACK.ADD;
          RAISE  exception_in_setup;
       END IF;
       CLOSE    efcC_cur;

       -- Calculate the Employment Expense Allowance
       IF NVL ( igf_ap_efc_calc.isir_rec.a_student_marital_status , igf_ap_efc_calc.isir_rec.s_marital_status ) = '2' THEN  -- Married Student
          -- If only one out of them is working
          IF    (    (NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work) IS NULL
                 AND  NVL(igf_ap_efc_calc.isir_rec.a_spouse_income_work,igf_ap_efc_calc.isir_rec.spouse_income_from_work) IS NOT NULL)
             OR (     NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work) IS NOT NULL
                 AND NVL(igf_ap_efc_calc.isir_rec.a_spouse_income_work,igf_ap_efc_calc.isir_rec.spouse_income_from_work) IS NULL))
             THEN
             l_eea := 0;
             -- If both of them are working
          ELSIF (    NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work) IS NOT NULL
                 AND NVL(igf_ap_efc_calc.isir_rec.a_spouse_income_work,igf_ap_efc_calc.isir_rec.spouse_income_from_work) IS NOT NULL)
                 THEN
                 l_eea := LEAST((NVL(efcC_rec.eea_mrd_2_wrk_rate,0) *
                          LEAST(greatest(NVL(igf_ap_efc_calc.isir_rec.a_spouse_income_work,igf_ap_efc_calc.isir_rec.spouse_income_from_work),0),
                                greatest(NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work),0))
	                        /100),NVL(efcC_rec.eea_mrd_2_wrk_amt,0));

          -- If both of the above conditions are failed
          ELSE
             l_eea := 0;
          END IF;
       ELSE -- Student is unmarried / Separated( One Parent Family)
          l_eea := LEAST((NVL(efcC_rec.eea_mrd_1_wrk_rate,0) *
                   NVL(greatest(NVL(igf_ap_efc_calc.isir_rec.a_s_income_work,igf_ap_efc_calc.isir_rec.s_income_from_work),0),0)/100),
	                    NVL(efcC_rec.eea_mrd_1_wrk_amt,0));
       END IF;

       igf_ap_efc_calc.isir_rec.employment_allow := ROUND(l_eea);
       igf_ap_efc_calc.isir_rec.secea := ROUND(l_eea);


       -- Allowance against Student's Income
       p_allow_ag_s_inc := ROUND(l_s_taxes_paid) + ROUND(l_tax_allowance) + ROUND(l_s_sst) + ROUND(l_spouse_sst) + ROUND(l_ipa) + ROUND(l_eea);
   --    p_allow_ag_s_inc := ROUND( p_allow_ag_s_inc );

       igf_ap_efc_calc.isir_rec.allow_total_income := p_allow_ag_s_inc;    --Assignment of intermediate values
       igf_ap_efc_calc.isir_rec.secati := p_allow_ag_s_inc; --Assignment of intermediate values


  EXCEPTION
     WHEN exception_in_setup THEN
          RAISE igf_ap_efc_calc.exception_in_setup; -- Exception to be handled in the Calling Procedures
     WHEN OTHERS THEN        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_SUBF.C_ALLOW_AG_S_INC');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

  END c_allow_ag_s_inc;


  PROCEDURE  c_available_inc ( p_s_inc             IN     NUMBER,
                               p_allow_ag_s_inc    IN     NUMBER,
                               p_available_income  OUT NOCOPY    NUMBER)    AS
  /*
  ||  Created By : gmuralid
  ||  Created On : 11 Feb 2003
  ||  Purpose :    Procedure to get available income for formula C, Bug# 2758804 , EFC build TD
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */

  BEGIN

    p_available_income := p_s_inc - p_allow_ag_s_inc;
    p_available_income := ROUND( p_available_income);

    igf_ap_efc_calc.isir_rec.available_income := p_available_income;     --Assignment of intermediate values
    igf_ap_efc_calc.isir_rec.secai := p_available_income;  --Assignment of intermediate values


  END c_available_inc;


  PROCEDURE  c_s_cont_assets ( p_s_cont_assets     OUT NOCOPY    NUMBER)    AS
  /*
  ||  Created By : gmuralid
  ||  Created On : 11 Feb 2003
  ||  Purpose :    Procedure to get students contribution from assets for formula C, Bug# 2758804 , EFC build TD
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
   -- Initialize the local variables with the Global variables.

   l_investment_networth    igf_ap_isir_matched.p_investment_networth%TYPE;
   l_business_networth      igf_ap_isir_matched.p_business_networth%TYPE;
   l_adj_business_networth  NUMBER;
   l_cash_saving            igf_ap_isir_matched.p_cash_saving%TYPE;
   l_net_worth              NUMBER;
   l_age_student            NUMBER;
   l_asset_pro_allow        igf_fc_ast_pc_dt.parent2_allowance%TYPE;
   l_d_net_worth            NUMBER;

  -- Cursor to find the Setting for Formula C
    CURSOR    efcC_cur IS
       SELECT stud_asset_conv_rate
         FROM igf_fc_efc_frm_c   efcc
        WHERE efcc.s_award_year = igf_ap_efc_calc.p_sys_award_year;

  -- Cursor to calculate Asset Protection Allowance(Using the A5 instead of C5 as both contains the same Information)
    CURSOR    asset_cur(cp_age_student  igf_fc_ast_pc_dt.older_parent_age%TYPE) IS
       SELECT parent1_allowance, parent2_allowance
         FROM igf_fc_ast_pc_dt apdt
        WHERE apdt.table_code = 'C5'
          AND apdt.older_parent_age = cp_age_student
          AND apdt.s_award_year = igf_ap_efc_calc.p_sys_award_year;

  -- Cursor to calculate Adjusted Net worth of Business/farm(Using the A4 instead of C4 as both contains the same Information)
    CURSOR    business_networth_cur(cp_business_networth  igf_ap_isir_matched.p_business_networth%TYPE)  IS
       SELECT tax_rate, amount, tax_rate_excess, amount_excess
         FROM igf_fc_gen_tax_rts  gtxrts
        WHERE gtxrts.table_code    = 'C4'
          AND gtxrts.s_award_year = igf_ap_efc_calc.p_sys_award_year
          AND (cp_business_networth BETWEEN gtxrts.income_range_start AND gtxrts.income_range_end);

    business_networth_rec   business_networth_cur%ROWTYPE;
    efcC_rec                efcC_cur%ROWTYPE;
    asset_rec               asset_cur%ROWTYPE;
    l_base_Date          DATE;

  BEGIN

    IF igf_ap_efc_calc.p_sys_award_year ='0304' THEN
      l_base_Date := to_date('31-12-2003', 'DD-MM-YYYY');
    ELSIF igf_ap_efc_calc.p_sys_award_year ='0405' THEN
      l_base_Date := to_date('31-12-2004', 'DD-MM-YYYY');
    ELSIF igf_ap_efc_calc.p_sys_award_year ='0506' THEN
      l_base_Date := to_date('31-12-2005', 'DD-MM-YYYY');
    ELSIF igf_ap_efc_calc.p_sys_award_year ='0607' THEN
      l_base_Date := to_date('31-12-2006', 'DD-MM-YYYY');
    ELSE
      l_base_Date := to_date('31-12-2002', 'dd-MM-YYYY');
    END IF;

    -- Get Net worth of investments( Can not be Negative)
    IF NVL(igf_ap_efc_calc.isir_rec.s_investment_networth,0) <= 0 THEN
      l_investment_networth := 0;
    ELSE
      l_investment_networth := igf_ap_efc_calc.isir_rec.s_investment_networth;
    END IF;

    -- Get Net Worth of business/investments farm(Can not be Negative)
    IF NVL(igf_ap_efc_calc.isir_rec.s_busi_farm_networth,0) <= 0 THEN
      l_business_networth := 0;
    ELSE
      l_business_networth := igf_ap_efc_calc.isir_rec.s_busi_farm_networth;
    END IF;

    -- Get Adjusted net worth of Business/Farm
    OPEN     business_networth_cur(l_business_networth);
    FETCH    business_networth_cur   INTO  business_networth_rec;
    IF business_networth_cur%NOTFOUND THEN
      CLOSE  business_networth_cur;
      FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_GEN_TAX_SETUP');
      FND_MESSAGE.SET_TOKEN('TABLE_NAME','C4');
      IGS_GE_MSG_STACK.ADD;
      RAISE  exception_in_setup;
    END IF;
    CLOSE    business_networth_cur;

    IF business_networth_rec.tax_rate IS NULL THEN
      l_adj_business_networth := business_networth_rec.amount +
                              (( business_networth_rec.tax_rate_excess * (l_business_networth - business_networth_rec.amount_excess)) / 100 );
    ELSE
      l_adj_business_networth := ( business_networth_rec.tax_rate * l_business_networth ) / 100 ;
    END IF ;

    -- Get Cash, Savings and Checking
    l_cash_saving := NVL(igf_ap_efc_calc.isir_rec.s_cash_savings,0);

    -- Get Net Worth
    -- (Investment Net worth + Adjusted Business Net Worth + Cash Saving)
    l_net_worth := l_investment_networth + l_adj_business_networth + l_cash_saving ;

    igf_ap_efc_calc.isir_rec.efc_networth := ROUND(l_net_worth);
    igf_ap_efc_calc.isir_rec.secnw := ROUND(l_net_worth);

    -- Get the Student's Age. If the Date of Birth is not specified in the ISIR then stop the Processing of the Student.
    IF igf_ap_efc_calc.isir_rec.date_of_birth IS NOT NULL THEN
--       l_age_student := FLOOR(MONTHS_BETWEEN(l_base_date,igf_ap_efc_calc.isir_rec.date_of_birth)/12);
      l_age_student := FLOOR((TO_NUMBER(TO_CHAR(l_base_date,'YYYY')) - TO_NUMBER(TO_CHAR(igf_ap_efc_calc.isir_rec.date_of_birth,'YYYY'))));
    ELSE
      FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_DOB_SPECIFIED');
      IGS_GE_MSG_STACK.ADD;
      RAISE  exception_in_setup;
    END IF;

    IF l_age_student < 25 THEN
      l_age_student := 25 ;
    ELSIF l_age_student > 65 THEN
      l_age_student := 65;
    END IF ;

    -- Get Education savings and Asset Protection Allowance(Using the A5 instead of C5 as both contains the same Information)
    OPEN     asset_cur(l_age_student);
    FETCH    asset_cur  INTO  asset_rec;
    IF asset_cur%NOTFOUND THEN
      CLOSE  asset_cur;
      FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_ASSET_SETUP');
      FND_MESSAGE.SET_TOKEN('TABLE_NAME','C5');
      IGS_GE_MSG_STACK.ADD;
      RAISE  exception_in_setup;
    END IF;
    CLOSE    asset_cur;

    IF NVL ( igf_ap_efc_calc.isir_rec.a_student_marital_status , igf_ap_efc_calc.isir_rec.s_marital_status ) = '2' THEN
      l_asset_pro_allow := NVL(asset_rec.parent2_allowance,0);
    ELSE
      l_asset_pro_allow := NVL(asset_rec.parent1_allowance,0);
    END IF;

    igf_ap_efc_calc.isir_rec.asset_protect_allow := l_asset_pro_allow;
    igf_ap_efc_calc.isir_rec.secapa := l_asset_pro_allow;

    -- Get Discretionary Net Worth
    l_d_net_worth := l_net_worth - l_asset_pro_allow ;

    igf_ap_efc_calc.isir_rec.discretionary_networth := ROUND(l_d_net_worth) ;
    igf_ap_efc_calc.isir_rec.secdnw := ROUND(l_d_net_worth);


    -- Get the Setting for Formula C
    OPEN     efcC_cur;
    FETCH    efcC_cur  INTO  efcC_rec;
    IF efcC_cur%NOTFOUND THEN
      CLOSE  efcC_cur;
      FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_EFCC_SETUP');
      IGS_GE_MSG_STACK.ADD;
      RAISE  exception_in_setup;
    END IF;
    CLOSE    efcC_cur;

    -- Get Contribution from Assets
    p_s_cont_assets := l_d_net_worth * NVL(efcC_rec.stud_asset_conv_rate,0) / 100;

    IF p_s_cont_assets < 0 THEN
      p_s_cont_assets := 0;
    END IF;

    p_s_cont_assets  := ROUND( p_s_cont_assets);

    igf_ap_efc_calc.isir_rec.sca := p_s_cont_assets ;      --Assignment of intermediate values
    igf_ap_efc_calc.isir_rec.secsca := p_s_cont_assets ;   --Assignment of intermediate values

  EXCEPTION
     WHEN exception_in_setup THEN
          RAISE igf_ap_efc_calc.exception_in_setup; -- Exception to be handled in the Calling Procedures
     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_SUBF.C_S_CONT_ASSETS');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

  END c_s_cont_assets;


  PROCEDURE  c_efc ( p_available_income  IN             NUMBER,
                     p_s_cont_assets     IN             NUMBER,
                     p_efc                  OUT NOCOPY  NUMBER,
                     l_call_type         IN VARCHAR2 )    AS
  /*
  ||  Created By : gmuralid
  ||  Created On : 11 Feb 2003
  ||  Purpose :    Procedure to get efc by using formula C, Bug# 2758804 , EFC build TD
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
      -- Initialize the local variables with the Global variables.
      -- l_call_type = P/S to compute for primary or secondary

    l_aai            NUMBER;
    l_cont_aai       NUMBER;

     -- Cursor to calculate Student's Contribution from AAI
    CURSOR    cont_aai_cur(cp_aai NUMBER)  IS
       SELECT tax_rate, amount, tax_rate_excess, amount_excess
         FROM igf_fc_gen_tax_rts  gtxrts
        WHERE gtxrts.table_code    = 'C6'
          AND gtxrts.s_award_year= igf_ap_efc_calc.p_sys_award_year
          AND (cp_aai BETWEEN gtxrts.income_range_start AND gtxrts.income_range_end);

    cont_aai_rec      cont_aai_cur%ROWTYPE;

  BEGIN
     -- Get Adjusted Available Income
     -- ( Available Income + Contribution from Assets)

        l_aai := p_available_income + p_s_cont_assets;

        igf_ap_efc_calc.isir_rec.adjusted_available_income := l_aai;
        igf_ap_efc_calc.isir_rec.secaai  := l_aai;


     -- Get Total students contribution from Adjusted Available Income
     OPEN     cont_aai_cur(l_aai);
     FETCH    cont_aai_cur   INTO  cont_aai_rec;
     IF cont_aai_cur%NOTFOUND THEN
        CLOSE  cont_aai_cur;
        FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_GEN_TAX_SETUP');
        FND_MESSAGE.SET_TOKEN('TABLE_NAME','C6');
        IGS_GE_MSG_STACK.ADD;
        RAISE  exception_in_setup;
     END IF;
     CLOSE    cont_aai_cur;

     IF cont_aai_rec.tax_rate IS NULL THEN
        l_cont_aai := cont_aai_rec.amount +
                      (( cont_aai_rec.tax_rate_excess * (l_aai - cont_aai_rec.amount_excess)) / 100 );
     ELSE
        l_cont_aai := ( cont_aai_rec.tax_rate * l_aai ) / 100 ;
     END IF ;

     -- Total students contribution from Adjusted Available Income
     -- (Can not be Negative)
     IF l_cont_aai < 0 THEN
        l_cont_aai := 0;
     END IF;

        IF l_call_type = 'P' THEN

        igf_ap_efc_calc.isir_rec.total_student_contribution := ROUND(l_cont_aai); --- ROUND(NVL(p_s_cont_assets,0));

        ELSE

        igf_ap_efc_calc.isir_rec.sectsc  := ROUND(l_cont_aai);

        END IF;

     -- Get parents contribution (Total Parents contribution from AAI/Number in college in 2001-02)
	  -- (Can not be Negative)

     p_efc := ROUND(l_cont_aai) / NVL(NVL(igf_ap_efc_calc.isir_rec.a_s_num_in_college,igf_ap_efc_calc.isir_rec.s_num_in_college),1);
     p_efc := ROUND(p_efc);

	  IF p_efc < 0 THEN
	     p_efc := 0;
	  END IF;
  EXCEPTION
     WHEN exception_in_setup THEN
          RAISE igf_ap_efc_calc.exception_in_setup; -- Exception to be handled in the Calling Procedures
     WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_SUBF.C_EFC');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;

  END c_efc;


  PROCEDURE  c_efc_less_9 ( p_no_of_months      IN             NUMBER,
                            p_efc               IN OUT NOCOPY  NUMBER)  AS
  /*
  ||  Created By : gmuralid
  ||  Created On : 11 Feb 2003
  ||  Purpose :    Procedure to get efc for less than 9 months using formula C, Bug# 2758804 , EFC build TD
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */

    l_efc_per_month    NUMBER;

  BEGIN

     -- To determine the EFC per month
    l_efc_per_month := p_efc / 9;

     -- Get EFC for no of months of enrollment
    p_efc := l_efc_per_month * p_no_of_months ;

  END c_efc_less_9;

  FUNCTION efc_cutoff_date ( p_sys_award_year IN VARCHAR2 )
  RETURN DATE IS
   /*
   ||  Created By : gmuralid
   ||  Created On : 11 Feb 2003
   ||  Purpose :    Procedure to get efc cut off date, Bug# 2758804 , EFC build TD
   ||
   ||  Known limitations, enhancements or remarks :
   ||
   ||  Change History :
   ||  Who             When            What
   ||  nsidana        11/18/2003     FA129 EFC updates for 2004-2005.
   ||
   ||  (reverse chronological order - newest change first)
  */

  l_date DATE;

  BEGIN

    IF p_sys_award_year = '0304' THEN
       l_date := TO_DATE('01/01/1980','DD/MM/YYYY');
    ELSIF p_sys_award_year = '0405' THEN
       l_date := TO_DATE('01/01/1981','DD/MM/YYYY');
    ELSIF p_sys_award_year = '0506' THEN
       l_date := TO_DATE('01/01/1982','DD/MM/YYYY');
    ELSIF p_sys_award_year = '0607' THEN
       l_date := TO_DATE('01/01/1983','DD/MM/YYYY');
    ELSE
       l_date := TO_DATE('01/01/1979','DD/MM/YYYY');
    END IF;
       RETURN (l_date);

    EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_SUBF.EFC_CUTOFF_DATE');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

  END efc_cutoff_date;

  PROCEDURE get_par_stud_cont( p_sys_award_year IN            VARCHAR2,
                               p_parent_cont       OUT NOCOPY NUMBER,
                               p_student_cont      OUT NOCOPY NUMBER) AS
   /*
   ||  Created By : gmuralid
   ||  Created On : 11 Feb 2003
   ||  Purpose :    Procedure to get award year specific parent student contributions for table A3 and C3
   ||               Bug# 2758804 , EFC build TD
   ||  Known limitations, enhancements or remarks :
   ||  Change History :
   ||  Who             When            What
   ||  (reverse chronological order - newest change first)
  */

  BEGIN

    IF p_sys_award_year = '0304' THEN
       p_parent_cont  := 3230 ;
       p_student_cont := 2290 ;
    ELSIF p_sys_award_year = '0506' THEN
       p_parent_cont  := 3320 ;
       p_student_cont := 2360 ;
    ELSIF p_sys_award_year = '0607' THEN
       p_parent_cont  := 3460;
       p_student_cont := 2460;
    END IF;

    EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_SUBF.GET_PAR_STUD_CONT');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

  END get_par_stud_cont ;

 PROCEDURE auto_zero_efc ( p_primary_efc_type  IN VARCHAR2)
 AS
 /*
   ||  Created By : gmuralid
   ||  Created On : 11 Feb 2003
   ||  Purpose :    Procedure to get award year specific parent student contributions for table A3 and C3
   ||               Bug# 2758804 , EFC build TD
   ||  Known limitations, enhancements or remarks :
   ||  Change History :
   ||  Who             When            What
   ||  (reverse chronological order - newest change first)
  */
 p_p_inc NUMBER;
 p_s_inc NUMBER;

 BEGIN

 IF p_primary_efc_type = '4'  THEN
   igf_ap_efc_subf.a_p_inc(p_p_inc);
   igf_ap_efc_subf.a_s_inc( p_s_inc);
 ELSIF p_primary_efc_type = '5' THEN
   igf_ap_efc_subf.b_s_inc( p_s_inc);
 ELSIF p_primary_efc_type = '6' THEN
   igf_ap_efc_subf.c_s_inc( p_s_inc);
 END IF;

 END auto_zero_efc;

END igf_ap_efc_subf;

/
