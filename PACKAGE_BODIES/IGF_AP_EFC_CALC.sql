--------------------------------------------------------
--  DDL for Package Body IGF_AP_EFC_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_EFC_CALC" AS
/* $Header: IGFAP25B.pls 120.3 2006/05/31 07:46:46 rajagupt ship $ */
/*
  ||  Created By : pkpatel
  ||  Created On : 10-DEC-2001
  ||  Purpose : Bug No - 2142666 EFC DLD.
  ||            This Package contains procedures for the Concurrent Program EFC Calculation
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||
  ||  masehgal,sgaddama,gmuralid,cdcruz  08-03-2003  BUG# 2833795 - EFC Mismatch Base BUG
  ||
  ||  CDCRUZ          16-DEC-2002     Bug 2691811
  ||                                  The EFC rounding off which was defaulted is now removed
  ||                                  Will be re-introduced once EFC Computation is brought back
  ||                                  Handling of cursor month_calc_cur modified in get_efc_no_of_months
  ||  CDCRUZ          18-OCT-2002     Bug 2613546
  ||                                  Cursor calander_cur modifed by Bug# 2613546 FA105/FA108
  ||  CDCRUZ          04-MAY-2002     Bug 2339982 - Change number precision
  ||                                  to 3rd Decimal place
  ||  nsidana            11/20/2003           FA129 EFC updates for 2004-2005.
*/

  PROCEDURE flush_values(p_isir_rec in out NOCOPY igf_ap_isir_matched%rowtype)  IS
  BEGIN

         IF ( p_isir_rec.primary_efc_type in ('4','5','6') and p_isir_rec.SCA IS NULL) OR
            ( p_isir_rec.primary_efc_type in ('1','2','3'))
            THEN
            p_isir_rec.secti   := NULL;
            p_isir_rec.secati  := NULL;
            p_isir_rec.secstx  := NULL;
            p_isir_rec.secea   := NULL;
            p_isir_rec.secipa  := NULL;
            p_isir_rec.secai   := NULL;
            p_isir_rec.seccai  := NULL;
            p_isir_rec.secdnw  := NULL;
            p_isir_rec.secnw   := NULL;
            p_isir_rec.secapa  := NULL;
            p_isir_rec.secpca  := NULL;
            p_isir_rec.secaai  := NULL;
            p_isir_rec.sectsc  := NULL;
            p_isir_rec.sectpc  := NULL;
            p_isir_rec.secpc   := NULL;
            p_isir_rec.secsti  := NULL;
            p_isir_rec.secsati := NULL;
            p_isir_rec.secsic  := NULL;
            p_isir_rec.secsdnw := NULL;
            p_isir_rec.secsca  := NULL;
            p_isir_rec.secfti  := NULL;
            p_isir_rec.sec_efc_type := NULL ;
            -- manu added secondary_efc
            p_isir_rec.sec_efc_type := NULL ;
         END IF ;
-- code added now today morn - sunday by gautam

         IF ( p_isir_rec.primary_efc_type in ('5','6') AND
             p_isir_rec.simplified_need_test = 'Y' AND
             p_isir_rec.auto_zero_efc IS NULL AND
             p_isir_rec.s_investment_networth IS NULL AND
             p_isir_rec.s_busi_farm_networth IS NULL AND
             p_isir_rec.s_cash_savings IS NULL ) THEN

             p_isir_rec.secti   := NULL;
             p_isir_rec.secati  := NULL;
             p_isir_rec.secstx  := NULL;
             p_isir_rec.secea   := NULL;
             p_isir_rec.secipa  := NULL;
             p_isir_rec.secai   := NULL;
             p_isir_rec.seccai  := NULL;
             p_isir_rec.secdnw  := NULL;
             p_isir_rec.secnw   := NULL;
             p_isir_rec.secapa  := NULL;
             p_isir_rec.secpca  := NULL;
             p_isir_rec.secaai  := NULL;
             p_isir_rec.sectsc  := NULL;
             p_isir_rec.sectpc  := NULL;
             p_isir_rec.secpc   := NULL;
             p_isir_rec.secsti  := NULL;
             p_isir_rec.secsati := NULL;
             p_isir_rec.secsic  := NULL;
             p_isir_rec.secsdnw := NULL;
             p_isir_rec.secsca  := NULL;
             p_isir_rec.secfti  := NULL;
             p_isir_rec.sec_efc_type := NULL ;
             p_isir_rec.sec_alternate_month_1  := NULL;
             p_isir_rec.sec_alternate_month_2  := NULL;
             p_isir_rec.sec_alternate_month_3  := NULL;
             p_isir_rec.sec_alternate_month_4  := NULL;
             p_isir_rec.sec_alternate_month_5  := NULL;
             p_isir_rec.sec_alternate_month_6  := NULL;
             p_isir_rec.sec_alternate_month_7  := NULL;
             p_isir_rec.sec_alternate_month_8  := NULL;
             p_isir_rec.sec_alternate_month_10 := NULL;
             p_isir_rec.sec_alternate_month_11 := NULL;
             p_isir_rec.sec_alternate_month_12 := NULL;
             p_isir_rec.secondary_efc := NULL;
           END IF;
-- till here
         -- GAUTAM ADDED CODE FROM HERE
         IF ( p_isir_rec.primary_efc_type in ('4','5','6') ) THEN

            p_isir_rec.efc_networth := NULL;
            p_isir_rec.discretionary_networth := NULL;
            p_isir_rec.asset_protect_allow := NULL;
            p_isir_rec.sca := NULL;
            p_isir_rec.parents_cont_from_assets := NULL;
            p_isir_rec.sdnw    := NULL;
         END IF;

         IF ( p_isir_rec.primary_efc_type in ('1')) THEN
            -- p_isir_rec.adjusted_available_income := NULL;
            NULL;
         ELSIF (p_isir_rec.primary_efc_type in ('4')) THEN
            p_isir_rec.adjusted_available_income := NULL;
         ELSIF (p_isir_rec.primary_efc_type in ('6')) THEN
            p_isir_rec.adjusted_available_income := NULL;
         END IF;

         --p_isir_rec.auto_zero_efc := NULL ;

  END flush_values;


  FUNCTION get_month_efc ( p_month IN NUMBER )  RETURN NUMBER IS
  m_pcont         NUMBER;
  m_dep_stud_inc  NUMBER;
  p_month_efc     NUMBER;

  BEGIN

     m_pcont        := igf_ap_efc_calc.isir_rec.PARENTS_CONTRIBUTION/9 ;
     m_dep_stud_inc := igf_ap_efc_calc.isir_rec.SIC/9 ;
     p_month_efc    := ROUND(m_pcont) + ROUND(m_dep_stud_inc) ;
     p_month_efc    := p_month_efc * p_month ;
     -- l_m_efc := l_m_efc + isir_rec.SCA;

  RETURN p_month_efc;

  END;

  -- Starts function
  FUNCTION get_efc_no_of_months  ( p_last_end_dt    IN  DATE,
                                   p_base_id        IN  igf_ap_fa_base_rec.base_id%TYPE)
  RETURN NUMBER IS
  /*
  ||  Created By : prabhat.patel@Oracle.com
  ||  Created On : 11-DEC-2001
  ||  Purpose : Bug No - 2142666 EFC DLD.
  ||            This procedure finds the exact number of months not repeating the overlapped terms
  ||            and neglecting the gap between terms.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  masehgal        11-Feb-2003     # 2758804   FACR105   - EFC Engine
  ||                                  Reintroduced the round off factors,
  ||                                  month days calculations as per the build
  ||  rasahoo         31-July-2003    #3024112 Changed the method of calculation for no. of days.
  ||                                  Now it finds the difference between min of start date and max of
  ||                                  end date to get tha no. of days. To revert back the original
  ||                                  method of calculation pliz refer the file version 115.20
  ||  (reverse chronological order - newest change first)
  */

    l_no_of_days   NUMBER := 0;
    l_no_of_months NUMBER := 0;

    -- Cursor to find the User preference of Round-Off Factor, Number of days Divisior
    -- for calculating the Number of Months.
    CURSOR month_calc_cur IS
    SELECT num_days_divisor, roundoff_fact
     FROM igf_ap_efc_v        efc,
          igf_ap_fa_base_rec  fabase
    WHERE efc.ci_cal_type        = fabase.ci_cal_type
      AND efc.ci_sequence_number = fabase.ci_sequence_number
      AND fabase.base_id         = p_base_id;

    -- Cursor to find all the Term/Load Calander the Student is Registered.
    -- Cursor calander_cur modifed by Bug# 2613546 FA105/FA108
    CURSOR calander_cur IS
    SELECT MIN(ci.start_dt) start_dt, MAX(ci.end_dt) end_dt
     FROM igf_aw_coa_itm_terms citsn ,
          igs_ca_inst ci
    WHERE ci.cal_type        =  citsn.ld_cal_type
      AND ci.sequence_number =  citsn.ld_sequence_number
      AND citsn.base_id      =  p_base_id ;

    calander_rec    calander_cur%ROWTYPE;
    month_calc_rec  month_calc_cur%ROWTYPE;

  BEGIN

    OPEN  calander_cur;
    FETCH calander_cur  INTO calander_rec;

    -- If no Data Found return the default value -1
    IF calander_cur%NOTFOUND  THEN
      CLOSE  calander_cur;
      RETURN -1;
    ELSE
      CLOSE calander_cur;
    END IF;

    -- The logic is to find the  no of days the student is registered
    IF p_last_end_dt IS NULL THEN
      l_no_of_days := calander_rec.end_dt - calander_rec.start_dt;
    ELSE
      l_no_of_days := p_last_end_dt - calander_rec.start_dt;
    END IF;

    OPEN  month_calc_cur;
    FETCH month_calc_cur INTO month_calc_rec;
    CLOSE month_calc_cur;

    l_no_of_months := l_no_of_days / NVL(month_calc_rec.num_days_divisor,30);

    IF (month_calc_rec.roundoff_fact = 'RU') THEN
      -- Round UP to the nearest whole number
      l_no_of_months := CEIL( l_no_of_months );
    ELSIF (month_calc_rec.roundoff_fact = 'RD' ) THEN
      -- Round DOWN to the nearest whole number
      l_no_of_months := FLOOR( l_no_of_months );
    ELSE
      -- Round off factor is 'RH', Round to the nearest whole number
      l_no_of_months := ROUND( l_no_of_months );
    END IF;

    RETURN l_no_of_months;

  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_CALC.GET_EFC_NO_OF_MONTHS');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END get_efc_no_of_months;

  FUNCTION chk_reject (p_number  IN   VARCHAR2 ) RETURN BOOLEAN IS
    /*
    ||  Created By : masehgal
    ||  Created On : 11-Feb-2003
    ||  Purpose : check if Rejects can /can't be suppressed
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
  BEGIN

    IF TO_NUMBER (p_number) >0 THEN
      RETURN TRUE ;
    ELSE
      RETURN FALSE ;
    END IF ;
  EXCEPTION
    WHEN VALUE_ERROR THEN
      RETURN FALSE ;
  END chk_reject ;

  PROCEDURE get_efc_frml ( p_isir_rec IN  OUT  NOCOPY    igf_ap_isir_matched%ROWTYPE ,
                           p_formula      OUT  NOCOPY    VARCHAR2 )  AS
    /*
    ||  Created By : masehgal
    ||  Created On : 11-Feb-2003
    ||  Purpose : EFC Formula Determination
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  rajagupt        30-May-2006     Bug #5201271. Dependent student tax return
    ||                                  requirements deleted from edits 3001-3006
    ||                                  for year 2006-2007.
    ||  (reverse chronological order - newest change first)
    */

    l_dep_status  VARCHAR2(30) ;
    l_alternative VARCHAR2(30) ;
    l_dep         VARCHAR2(30) ;

    -- Cursor for Setup information
    CURSOR alt_fact_cur (cp_depend_stat   igf_fc_efc_alt_fac.dependent_status%TYPE,
                         cp_alternative   igf_fc_efc_alt_fac.alternative_code%TYPE)  IS
    SELECT alt.*
      FROM igf_fc_efc_alt_fac alt
     WHERE alt.s_award_year     = p_sys_award_year
       AND alt.dependent_status = cp_depend_stat
       AND alt.alternative_code = cp_alternative ;

    l_alt_fact_rec    alt_fact_cur%ROWTYPE ;
    l_simpified       BOOLEAN   := FALSE ;

  BEGIN -- get_efc_frml

    p_formula    := NULL ;
    l_dep_status := NULL ;
    p_isir_rec.auto_zero_efc := NULL ;

    IF p_isir_rec.dependency_status = 'I' THEN
      l_dep_status := 'INDEPENDENT' ;
    ELSE
      l_dep_status := 'DEPENDENT' ;
    END IF ;

    IF p_isir_rec.dependency_status = 'I' THEN
      --Edit 5004 / 5005 / 5010 / 5011
      IF (    (    NVL(p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members) > 2
               AND NVL(p_isir_rec.a_student_marital_status , p_isir_rec.s_marital_status ) = '2' )
           OR (    NVL(p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members) > 1
               AND NVL(p_isir_rec.a_student_marital_status , p_isir_rec.s_marital_status )  IN ('1' ,'3') )
          )
      THEN
        l_dep_status := 'INDEPENDENT_D' ;
      END IF;
    END IF;

    -- SNT DEPENDENT
    IF l_dep_status = 'DEPENDENT' THEN

      -- Pre simplifiedd Check
      IF (    NVL (p_isir_rec.a_parents_agi   , p_isir_rec.p_adjusted_gross_income )  IS NULL
          AND NVL (p_isir_rec.a_f_work_income , p_isir_rec.f_income_work           )  IS NULL
          AND NVL (p_isir_rec.a_m_work_income , p_isir_rec.m_income_work           )  IS NULL
          AND p_isir_rec.p_income_wsa IS NULL
          AND p_isir_rec.p_income_wsb IS NULL
         )
      THEN
        p_isir_rec.simplified_need_test := 'N' ;
      ELSE

        l_dep  := 'D' ;
        l_alternative := 'SIMPLIFIED' ;
        OPEN  alt_fact_cur (l_dep, l_alternative);
        FETCH alt_fact_cur INTO l_alt_fact_rec ;
        CLOSE alt_fact_cur ;

        --Simplified Need Test for Dependent Model for 0607
 	      IF ( igf_ap_efc_calc.p_sys_award_year IN ('0607') ) THEN

          --Bug #5201271
          IF (
               -- Edit 3001
               ( p_isir_rec.p_type_tax_return IN ('2','4') AND
                 p_isir_rec.p_adjusted_gross_income IS NOT NULL AND
                 NVL ( p_isir_rec.a_parents_agi , p_isir_rec.p_adjusted_gross_income ) < l_alt_fact_rec.alternative_income
               ) OR

              -- EDIT 3002
              ( p_isir_rec.p_tax_return_status = '3' AND
                p_isir_rec.p_type_tax_return IS NULL AND
                ( NVL( NVL( p_isir_rec.a_f_work_income, p_isir_rec.f_income_work), 0) +
                  NVL( NVL( p_isir_rec.a_m_work_income, p_isir_rec.m_income_work), 0)
                ) < l_alt_fact_rec.alternative_income
              ) OR

              -- Edit 3003
              ( p_isir_rec.p_elig_1040aez = '1' AND
                p_isir_rec.p_adjusted_gross_income IS NOT NULL AND
                NVL( p_isir_rec.a_parents_agi, p_isir_rec.p_adjusted_gross_income ) < l_alt_fact_rec.alternative_income
              )
             )
          THEN                           -- Set simplified flag to 'Y'

            p_isir_rec.simplified_need_test := 'Y' ;
          END IF ;

        --Simplified Need Test for Dependent Model for 0506
        ELSIF ( igf_ap_efc_calc.p_sys_award_year IN ('0506') ) THEN

          -- for 0506, assumed value are not used, always use the reported values.
          IF (
               -- Edit 3001
               ( p_isir_rec.p_type_tax_return IN ('2','4') AND
                 ( p_isir_rec.s_type_tax_return IN ('2','4') OR
                   p_isir_rec.s_elig_1040ez = '1' OR
                   ( p_isir_rec.s_tax_return_status = '3' AND p_isir_rec.s_type_tax_return is NULL )
                 ) AND
                 p_isir_rec.p_adjusted_gross_income IS NOT NULL AND
                 NVL ( p_isir_rec.a_parents_agi , p_isir_rec.p_adjusted_gross_income ) < l_alt_fact_rec.alternative_income
               ) OR

              -- EDIT 3002
              ( p_isir_rec.p_tax_return_status = '3' AND
                p_isir_rec.p_type_tax_return IS NULL AND
                ( p_isir_rec.s_type_tax_return IN ('2','4') OR
                  p_isir_rec.s_elig_1040ez = '1' OR
                  ( p_isir_rec.s_tax_return_status = '3' AND p_isir_rec.s_type_tax_return is NULL )
                ) AND
                ( NVL( NVL( p_isir_rec.a_f_work_income, p_isir_rec.f_income_work), 0) +
                  NVL( NVL( p_isir_rec.a_m_work_income, p_isir_rec.m_income_work), 0)
                ) < l_alt_fact_rec.alternative_income
              ) OR

              -- Edit 3003
              ( p_isir_rec.p_elig_1040aez = '1' AND
                ( p_isir_rec.s_type_tax_return IN ('2','4') OR
                  p_isir_rec.s_elig_1040ez = '1' OR
                  ( p_isir_rec.s_tax_return_status = '3'  AND  p_isir_rec.s_type_tax_return is NULL)
                ) AND
                p_isir_rec.p_adjusted_gross_income IS NOT NULL AND
                NVL( p_isir_rec.a_parents_agi, p_isir_rec.p_adjusted_gross_income ) < l_alt_fact_rec.alternative_income
              )
             )
          THEN                           -- Set simplified flag to 'Y'

            p_isir_rec.simplified_need_test := 'Y' ;
          END IF ;

        ELSE

            -- for years less than 0506, assumed value are used, if assumed values are not present then reported values are used.
          IF (
              -- Edit 3001
              ( p_isir_rec.p_type_tax_return IN ('2','4') AND
                ( p_isir_rec.s_type_tax_return IN ('2','4') OR
                  p_isir_rec.s_elig_1040ez = '1'OR
                  ( p_isir_rec.s_tax_return_status = '3' AND p_isir_rec.s_type_tax_return is NULL )
                ) AND
                NVL ( p_isir_rec.a_parents_agi , p_isir_rec.p_adjusted_gross_income ) < l_alt_fact_rec.alternative_income
              ) OR

              -- EDIT 3002
              ( p_isir_rec.p_tax_return_status = '3' AND
                p_isir_rec.p_type_tax_return IS NULL AND
                ( p_isir_rec.s_type_tax_return IN ('2','4') OR
                  p_isir_rec.s_elig_1040ez = '1' OR
                  ( p_isir_rec.s_tax_return_status = '3' AND p_isir_rec.s_type_tax_return is NULL )
                ) AND
                ( NVL( NVL( p_isir_rec.a_f_work_income, p_isir_rec.f_income_work), 0) +
                  NVL( NVL( p_isir_rec.a_m_work_income, p_isir_rec.m_income_work), 0)
                ) < l_alt_fact_rec.alternative_income
              ) OR

              -- Edit 3003
              ( p_isir_rec.p_elig_1040aez = '1' AND
                ( p_isir_rec.s_type_tax_return IN ('2','4') OR
                  p_isir_rec.s_elig_1040ez = '1' OR
                  ( p_isir_rec.s_tax_return_status = '3' AND p_isir_rec.s_type_tax_return is NULL)
                ) AND
                p_isir_rec.p_adjusted_gross_income IS NOT NULL AND
                NVL( p_isir_rec.a_parents_agi, p_isir_rec.p_adjusted_gross_income ) < l_alt_fact_rec.alternative_income
              )
            )
          THEN                           -- Set simplified flag to 'Y'

            p_isir_rec.simplified_need_test := 'Y' ;
          END IF ;

        END IF; -- End of 0607

      END IF ; -- Pre simplified Check

    -- ZERO EFC DEPENDENT
    l_dep         := 'D' ;
    l_alternative := 'AUTO_ZERO' ;
    OPEN  alt_fact_cur ( l_dep, l_alternative ) ;
    FETCH alt_fact_cur INTO l_alt_fact_rec ;
    CLOSE alt_fact_cur ;

        IF ( igf_ap_efc_calc.p_sys_award_year IN ('0607') ) THEN

      -- Bug #5201271
      IF(

          -- Edit 3004
          ( p_isir_rec.p_type_tax_return in ('2','4') AND
            p_isir_rec.p_adjusted_gross_income IS NOT NULL AND
            NVL (p_isir_rec.a_parents_agi , p_isir_rec.p_adjusted_gross_income ) <= l_alt_fact_rec.alternative_income
          ) OR

          -- Edit 3005
          ( p_isir_rec.p_tax_return_status = '3' AND
            p_isir_rec.p_type_tax_return IS NULL AND
            ( NVL( NVL( p_isir_rec.a_f_work_income, p_isir_rec.f_income_work), 0) + NVL( NVL( p_isir_rec.a_m_work_income, p_isir_rec.m_income_work), 0))
              <= l_alt_fact_rec.alternative_income
          ) OR


          -- Edit 3006
          ( p_isir_rec.p_elig_1040aez = '1' AND
            p_isir_rec.p_adjusted_gross_income IS NOT NULL AND
            NVL( p_isir_rec.a_parents_agi, p_isir_rec.p_adjusted_gross_income) <= l_alt_fact_rec.alternative_income )
        )
      THEN
        -- Set Auto Zero EFC to 'Y'
        p_isir_rec.auto_zero_efc := 'Y' ;
      END IF;

    ELSIF ( igf_ap_efc_calc.p_sys_award_year IN ('0506') ) THEN

      -- for 0506, assumed value are not used, always use the reported values.
      IF(

          -- Edit 3004
          ( p_isir_rec.p_type_tax_return in ('2','4') AND
            ( p_isir_rec.s_type_tax_return IN ('2','4') OR
              p_isir_rec.s_elig_1040ez = '1' OR
              ( p_isir_rec.s_tax_return_status = '3' AND p_isir_rec.s_type_tax_return is NULL )
            ) AND
            p_isir_rec.p_adjusted_gross_income IS NOT NULL AND
            NVL (p_isir_rec.a_parents_agi , p_isir_rec.p_adjusted_gross_income ) <= l_alt_fact_rec.alternative_income
          ) OR

          -- Edit 3005
          ( p_isir_rec.p_tax_return_status = '3' AND
            p_isir_rec.p_type_tax_return IS NULL AND
            ( p_isir_rec.s_type_tax_return IN ('2','4') OR
              p_isir_rec.s_elig_1040ez = '1' OR
              ( p_isir_rec.s_tax_return_status = '3' AND p_isir_rec.s_type_tax_return is NULL )
            ) AND
            ( NVL( NVL( p_isir_rec.a_f_work_income, p_isir_rec.f_income_work), 0) + NVL( NVL( p_isir_rec.a_m_work_income, p_isir_rec.m_income_work), 0))
              <= l_alt_fact_rec.alternative_income
          ) OR


          -- Edit 3006
          ( p_isir_rec.p_elig_1040aez = '1' AND
            ( p_isir_rec.s_type_tax_return IN ('2','4') OR
              p_isir_rec.s_elig_1040ez = '1' OR
              ( p_isir_rec.s_tax_return_status = '3' AND p_isir_rec.s_type_tax_return is NULL)
            ) AND
            p_isir_rec.p_adjusted_gross_income IS NOT NULL AND
            NVL( p_isir_rec.a_parents_agi, p_isir_rec.p_adjusted_gross_income) <= l_alt_fact_rec.alternative_income )
        )
      THEN
        -- Set Auto Zero EFC to 'Y'
        p_isir_rec.auto_zero_efc := 'Y' ;
      END IF;

    ELSE

      -- for years less than 0506, assumed value are used, if assumed values are not present then reported values are used.
      IF (
          -- Edit 3004
          ( p_isir_rec.p_type_tax_return in ('2','4') AND
            ( p_isir_rec.s_type_tax_return IN ('2','4') OR
              p_isir_rec.s_elig_1040ez = '1' OR
              ( p_isir_rec.s_tax_return_status = '3' AND p_isir_rec.s_type_tax_return is NULL )
            ) AND
            NVL (p_isir_rec.a_parents_agi , p_isir_rec.p_adjusted_gross_income ) <= l_alt_fact_rec.alternative_income
          ) OR

          -- Edit 3005
          ( p_isir_rec.p_tax_return_status = '3' AND
            p_isir_rec.p_type_tax_return IS NULL AND
            ( p_isir_rec.s_type_tax_return IN ('2','4') OR
              p_isir_rec.s_elig_1040ez = '1' OR
              ( p_isir_rec.s_tax_return_status = '3' AND p_isir_rec.s_type_tax_return is NULL )
            ) AND
            ( NVL( NVL( p_isir_rec.a_f_work_income, p_isir_rec.f_income_work), 0) + NVL( NVL(p_isir_rec.a_m_work_income, p_isir_rec.m_income_work), 0) )
              <= l_alt_fact_rec.alternative_income
          ) OR

          -- Edit 3006
          ( p_isir_rec.p_adjusted_gross_income is not null AND
            p_isir_rec.p_elig_1040aez = '1' AND
            ( p_isir_rec.s_type_tax_return IN ('2','4') OR
              p_isir_rec.s_elig_1040ez = '1' OR
              (p_isir_rec.s_tax_return_status = '3'  AND  p_isir_rec.s_type_tax_return is NULL)
            ) AND
            NVL( p_isir_rec.a_parents_agi, p_isir_rec.p_adjusted_gross_income) <= l_alt_fact_rec.alternative_income
          )
        )
      THEN
        -- Set Auto Zero EFC to 'Y'
        p_isir_rec.auto_zero_efc := 'Y' ;
      END IF ;

    END IF ; -- dependent check
    -- ZERO EFC for DEPENDENT ends

    END IF;
    -- SNT DEPENDENT Ends



    -- SNT INDEPENDENT
    -- manu - checking for both independent single and independent with dependents
    IF l_dep_status IN ('INDEPENDENT','INDEPENDENT_D')  THEN

      -- Pre simplified Check
      IF (    NVL (p_isir_rec.a_student_agi        , p_isir_rec.s_adjusted_gross_income )  is NULL
           AND NVL (p_isir_rec.a_s_income_work      , p_isir_rec.s_income_from_work      )  is NULL
           AND NVL (p_isir_rec.a_spouse_income_work , p_isir_rec.spouse_income_from_work )  is NULL
           AND p_isir_rec.s_toa_amt_from_wsa is NULL
           AND p_isir_rec.s_toa_amt_from_wsb is NULL
          )
      THEN
        p_isir_rec.simplified_need_test := 'N' ;

      ELSE
        l_dep         := 'I' ;
        l_alternative := 'SIMPLIFIED' ;
        OPEN  alt_fact_cur ( l_dep, l_alternative ) ;
        FETCH alt_fact_cur INTO l_alt_fact_rec ;
        CLOSE alt_fact_cur ;

        -- start of 0506
        IF ( igf_ap_efc_calc.p_sys_award_year IN ('0506','0607') ) THEN

          -- for 0506, assumed value are not used, always use the reported values.
          IF (

              -- Edit 3007
              ( p_isir_rec.p_elig_1040aez IN ('2','4') AND
                p_isir_rec.s_adjusted_gross_income IS NOT NULL AND
                NVL( p_isir_rec.a_student_agi, p_isir_rec.s_adjusted_gross_income)  < l_alt_fact_rec.alternative_income
              ) OR

              -- EDIT 3008
              ( p_isir_rec.s_tax_return_status = '3' AND
                p_isir_rec.s_type_tax_return IS NULL AND
                ( NVL( p_isir_rec.a_s_income_work, p_isir_rec.s_income_from_work) + NVL( p_isir_rec.a_spouse_income_work, p_isir_rec.spouse_income_from_work) )
                  < l_alt_fact_rec.alternative_income
              ) OR

              -- Edit 3009

              ( p_isir_rec.s_elig_1040ez = '1' AND
                p_isir_rec.s_adjusted_gross_income IS NOT NULL AND
                NVL (p_isir_rec.a_student_agi, p_isir_rec.s_adjusted_gross_income )  < l_alt_fact_rec.alternative_income
              )

             )
          THEN
            -- Set simplified flag to 'Y'
            p_isir_rec.simplified_need_test := 'Y' ;
          END IF ;

        ELSE
          -- for years less than 0506, assumed value are used, if assumed values are not present then reported values are used.
          IF (
              -- Edit 3007
              ( p_isir_rec.p_elig_1040aez IN ('2','4') AND
                NVL( p_isir_rec.a_student_agi, p_isir_rec.s_adjusted_gross_income) < l_alt_fact_rec.alternative_income
              ) OR

              -- EDIT 3008
              ( p_isir_rec.s_tax_return_status = '3' AND
                p_isir_rec.s_type_tax_return IS NULL AND
                ( NVL( p_isir_rec.a_s_income_work, p_isir_rec.s_income_from_work) + NVL( p_isir_rec.a_spouse_income_work, p_isir_rec.spouse_income_from_work) )
                  < l_alt_fact_rec.alternative_income
              ) OR

              -- Edit 3009
              ( p_isir_rec.s_adjusted_gross_income IS NOT NULL AND
                p_isir_rec.s_elig_1040ez = '1' AND
                NVL (p_isir_rec.a_student_agi, p_isir_rec.s_adjusted_gross_income ) < l_alt_fact_rec.alternative_income
              )
             )
           THEN
             -- Set simplified flag to 'Y'
             p_isir_rec.simplified_need_test := 'Y' ;
          END IF ;

        END IF;         -- End of 0506

      END IF ; -- Pre simplified Check
      -- SNT for INDEPENDENT Ends

      -- ZERO EFC INDEPENDENT
      l_dep         := 'I' ;
      l_alternative := 'AUTO_ZERO' ;
      OPEN  alt_fact_cur ( l_dep, l_alternative ) ;
      FETCH alt_fact_cur INTO l_alt_fact_rec ;
      CLOSE alt_fact_cur ;

      -- start of 0506
      IF ( igf_ap_efc_calc.p_sys_award_year IN ('0506','0607') ) THEN

        IF(
           -- Edit 3010
           ( NVL( p_isir_rec.a_student_marital_status , p_isir_rec.s_marital_status )  = '2' AND
             NVL( p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members ) > 2 AND
             p_isir_rec.s_type_tax_return IN ('2','4') AND
             p_isir_rec.s_adjusted_gross_income IS NOT NULL AND
             NVL ( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) <= l_alt_fact_rec.alternative_income
           ) OR

           -- Edit 3011
           ( NVL( p_isir_rec.a_student_marital_status , p_isir_rec.s_marital_status )  = '2' AND
             NVL ( p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members ) > 2 AND
             p_isir_rec.s_tax_return_status = '3' AND
             p_isir_rec.s_type_tax_return IS NULL AND
             ( NVL( NVL(p_isir_rec.a_s_income_work, p_isir_rec.s_income_from_work), 0) + NVL( NVL( p_isir_rec.a_spouse_income_work, p_isir_rec.spouse_income_from_work), 0) )
               <= l_alt_fact_rec.alternative_income
           ) OR

           -- Edit 3012
           (NVL( p_isir_rec.a_student_marital_status, p_isir_rec.s_marital_status )  = '2' AND
             NVL( p_isir_rec.a_s_num_in_family, p_isir_rec.s_num_family_members ) > 2 AND
             p_isir_rec.s_elig_1040ez = '1' AND
             p_isir_rec.s_adjusted_gross_income IS NOT NULL AND
             NVL ( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) <= l_alt_fact_rec.alternative_income
           ) OR

           -- Edit 3013
           ( NVL(p_isir_rec.a_student_marital_status, p_isir_rec.s_marital_status )  IN ('1','3') AND
             NVL(p_isir_rec.a_s_num_in_family, p_isir_rec.s_num_family_members ) > 1 AND
             p_isir_rec.s_type_tax_return IN ('2','4') AND
             p_isir_rec.s_adjusted_gross_income IS NOT NULL AND
             NVL (p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) <= l_alt_fact_rec.alternative_income
           ) OR

           -- Edit 3014
           ( NVL(p_isir_rec.a_student_marital_status , p_isir_rec.s_marital_status ) IN ('1','3') AND
             NVL(p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members ) > 1 AND
             p_isir_rec.s_tax_return_status = '3' AND
             p_isir_rec.s_type_tax_return is NULL AND
             (NVL (NVL( p_isir_rec.a_s_income_work, p_isir_rec.s_income_from_work), 0) + NVL( NVL( p_isir_rec.a_spouse_income_work, p_isir_rec.spouse_income_from_work), 0) )
              <= l_alt_fact_rec.alternative_income
           ) OR

           -- Edit 3015
           ( NVL(p_isir_rec.a_student_marital_status , p_isir_rec.s_marital_status )  IN ('1','3') AND
             NVL ( p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members ) > 1 AND
             p_isir_rec.s_elig_1040ez = '1' AND
             p_isir_rec.s_adjusted_gross_income IS NOT NULL AND
             NVL ( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) <= l_alt_fact_rec.alternative_income
           )
          )
        THEN
          -- Set Auto Zero EFC to 'Y'
          p_isir_rec.auto_zero_efc := 'Y' ;
        END IF ;

      ELSE

        -- for years less than 0506, assumed value are used, if assumed values are not present then reported values are used.
        IF(
           -- Edit 3010
           ( NVL(p_isir_rec.a_student_marital_status , p_isir_rec.s_marital_status )  = '2' AND
             NVL ( p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members ) > 2 AND
             p_isir_rec.s_type_tax_return IN ('2','4') AND
             NVL ( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) <= l_alt_fact_rec.alternative_income
           ) OR

           -- Edit 3011
           ( NVL(p_isir_rec.a_student_marital_status , p_isir_rec.s_marital_status )  = '2' AND
             NVL ( p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members ) > 2 AND
             p_isir_rec.s_tax_return_status = '3' AND
             p_isir_rec.s_type_tax_return IS NULL AND
             (NVL (NVL (p_isir_rec.a_s_income_work, p_isir_rec.s_income_from_work), 0 ) + NVL( NVL( p_isir_rec.a_spouse_income_work, p_isir_rec.spouse_income_from_work) ,0) )
              <= l_alt_fact_rec.alternative_income
           ) OR

           -- Edit 3012
           ( p_isir_rec.s_adjusted_gross_income IS NOT NULL AND
             NVL(p_isir_rec.a_student_marital_status , p_isir_rec.s_marital_status )  = '2' AND
             NVL ( p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members ) > 2 AND
             p_isir_rec.s_elig_1040ez = '1' AND
             NVL ( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) <= l_alt_fact_rec.alternative_income
           ) OR

           -- Edit 3013
           ( NVL(p_isir_rec.a_student_marital_status , p_isir_rec.s_marital_status )  IN ('1','3') AND
             NVL (p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members ) > 1 AND
             p_isir_rec.s_type_tax_return IN ('2','4') AND
             NVL (p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) <= l_alt_fact_rec.alternative_income
           ) OR

           -- Edit 3014
           ( NVL(p_isir_rec.a_student_marital_status, p_isir_rec.s_marital_status ) IN ('1','3') AND
             NVL(p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members ) > 1 AND
             p_isir_rec.s_tax_return_status = '3' AND
             p_isir_rec.s_type_tax_return is NULL AND
             ( NVL (NVL (p_isir_rec.a_s_income_work, p_isir_rec.s_income_from_work) , 0 ) + NVL( NVL( p_isir_rec.a_spouse_income_work, p_isir_rec.spouse_income_from_work), 0) )
               <= l_alt_fact_rec.alternative_income
           ) OR

           -- Edit 3015
           ( p_isir_rec.s_adjusted_gross_income IS NOT NULL AND
             NVL(p_isir_rec.a_student_marital_status , p_isir_rec.s_marital_status )  IN ('1','3') AND
             NVL ( p_isir_rec.a_s_num_in_family , p_isir_rec.s_num_family_members ) > 1 AND
             p_isir_rec.s_elig_1040ez = '1' AND
             NVL ( p_isir_rec.a_student_agi , p_isir_rec.s_adjusted_gross_income ) <= l_alt_fact_rec.alternative_income
           )
          )
        THEN
          -- Set Auto Zero EFC to 'Y'
          p_isir_rec.auto_zero_efc := 'Y' ;
        END IF ;

      END IF;

    END IF ; -- independent check
    -- ZERO EFC for INDEPENDENT ends

    -- Set the formula codes now :
    IF p_isir_rec.auto_zero_efc = 'Y' THEN
      -- Set the value of P_FORMULA to 0
      -- 0 -> Zero EFC
      p_formula := '0' ;

    ELSIF l_dep_status = 'DEPENDENT' AND p_isir_rec.simplified_need_test <> 'Y' THEN
       --Set the value of P_FORMULA to 1
       --1 -> Dependent Regular (A Regular)
       p_formula := '1' ;

    ELSIF l_dep_status = 'DEPENDENT' AND p_isir_rec.simplified_need_test = 'Y' THEN
       --Set the value of P_FORMULA to 4
       -- 4 -> Dependent Simplified (A Simplified)
       p_formula := '4' ;

    ELSIF l_dep_status = 'INDEPENDENT' AND p_isir_rec.simplified_need_test <> 'Y' THEN
       --Set the value of P_FORMULA to 2
       p_formula := '2' ; -- ( B Regular )

    ELSIF l_dep_status = 'INDEPENDENT' AND p_isir_rec.simplified_need_test = 'Y' THEN
       -- Set the value of P_FORMULA to 5
       -- 5 -> Independent Without Dependents Simplified (B Simplified)
       p_formula := '5' ;

    ELSIF l_dep_status = 'INDEPENDENT_D' AND p_isir_rec.simplified_need_test <> 'Y' THEN
       -- Set the value of P_FORMULA to 3
       -- 3 -> Independent With Dependents Regular (C Regular)
       p_formula := '3' ;

    ELSIF l_dep_status = 'INDEPENDENT_D' AND p_isir_rec.simplified_need_test = 'Y' THEN
       -- Set the value of P_FORMULA to 6
       -- 6 -> Independent With Dependents Simplified (C Simplified)
       p_formula := '6' ;

    END IF ;

    p_isir_rec.primary_efc_type := p_formula ;

    IF p_formula IN ( '4','5','6')  THEN
      p_isir_rec.sec_efc_type     := TO_CHAR( TO_NUMBER(p_formula) -3 )  ;
    ELSE
      p_isir_rec.sec_efc_type     := NULL  ;
    END IF ;

    IF p_formula = '0' THEN
   --   p_isir_rec.auto_zero_efc := 'Y' ;

      IF l_dep_status = 'DEPENDENT' THEN
         p_isir_rec.primary_efc_type := '4' ;
         p_isir_rec.sec_efc_type     := '1'  ;

      ELSIF l_dep_status = 'INDEPENDENT' THEN
         p_isir_rec.primary_efc_type := '5' ;
         p_isir_rec.sec_efc_type     := '2' ;

      ELSIF l_dep_status = 'INDEPENDENT_D' THEN
         p_isir_rec.primary_efc_type := '6' ;
         p_isir_rec.sec_efc_type     := '3' ;

      END IF ;
    END IF ;

  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_CALC.GET_EFC_FRML');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END get_efc_frml ;


  PROCEDURE efc_a  ( p_frml_code     IN            VARCHAR2,
                     p_no_of_months  IN            NUMBER,
                     p_efc           OUT NOCOPY    NUMBER,
                     p_sc_asset      OUT NOCOPY    NUMBER )   AS
  /*
  ||  Created By : masehgal
  ||  Created On : 11-feb-2003
  ||  Purpose :  This is the procedure for calculating EFC for the Student with EFC formula A
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  cdcruz          24-May-2002     New parameter added  p_sc_asset
  ||                                  To compute students contribution from Assets which should not be
  ||                                  Pro Rated - Bug# 2384837
  */
     l_p_inc             NUMBER(12,3) ; -- Parents' Income
     l_allow_ag_p_inc    NUMBER(12,3) ; -- Allowances against Parents' Income
     l_available_income  NUMBER(12,3) ; -- Available Income
     l_p_cont_assets     NUMBER(12,3) ; -- Parents' contribution from Assets
     l_p_aai             NUMBER(12,3) ; -- Parents' Adjustable Available Income
     l_p_cont            NUMBER(12,3) ; -- Parents' Contribution from Income
     l_s_inc             NUMBER(12,3) ; -- Student's Income
     l_allow_ag_s_inc    NUMBER(12,3) ; -- Allowances against Student's Income
     l_s_cont            NUMBER(12,3) ; -- Student's Contribution from Income
     l_s_cont_assets     NUMBER(12,3) ; -- Student's contribution from Assets
     l_p_cont_less_9     NUMBER(12,3) ; -- Parents' Contribution from Income for less than 9 months
     l_s_cont_less_9     NUMBER(12,3) ; -- Student's Contribution from Income for less than 9 months
     l_p_cont_more_9     NUMBER(12,3) ; -- Parents' Contribution from Income for more than 9 months

  BEGIN
      p_sc_asset := null ;

      -- Get the Parents' Income in last year
      igf_ap_efc_subf.a_p_inc(l_p_inc);

      -- Get Allowances against Parents' Income
      igf_ap_efc_subf.a_allow_ag_p_inc ( l_p_inc, l_allow_ag_p_inc ) ;

      -- Get the Parents' Available Income
      igf_ap_efc_subf.a_available_inc( l_p_inc, l_allow_ag_p_inc,l_available_income );

      -- Get Parents' contribution from Assets
      igf_ap_efc_subf.a_p_cont_assets( l_p_cont_assets );

      -- Get Parents' Contribution
      igf_ap_efc_subf.a_p_cont( l_available_income, l_p_cont_assets, l_p_aai, l_p_cont );

      -- Get student's income in 2000
      igf_ap_efc_subf.a_s_inc(l_s_inc);

      -- Get Allowances against Student's income
      igf_ap_efc_subf.a_allow_ag_s_inc( l_s_inc, l_p_aai, l_allow_ag_s_inc );

      -- Get Student's contribution from income
      igf_ap_efc_subf.a_s_cont( l_s_inc, l_allow_ag_s_inc, l_s_cont );

      -- Get Student's contribution from Assets
      igf_ap_efc_subf.a_s_cont_assets ( l_s_cont_assets );

      p_sc_asset := l_s_cont_assets   ;

      -- Get the first 9 Months EFC
      -- Get Parents' contribution for < 9 months
      igf_ap_efc_subf.a_p_cont_less_9( l_p_cont, p_no_of_months, l_p_cont_less_9 );

      -- Get Student's contribution from Available Income for < 9 months
      igf_ap_efc_subf.a_s_cont_less_9 ( l_s_cont, p_no_of_months, l_s_cont_less_9 );

      -- Get Student's EFC for < 9 months
      igf_ap_efc_subf.a_efc_not_9(l_p_cont_less_9, l_s_cont_less_9, l_s_cont_assets, p_efc );

      -- Due to a differential that is coming in the formula which requires
     -- Independent calculation for 9th ,10th , 11th and 12th Month .
     -- The following structure is added.
      IF p_no_of_months > 8 THEN
         -- Get Parents contribution for 9th month
         igf_ap_efc_subf.a_efc(  l_p_cont, l_s_cont, l_s_cont_assets, g_efc_a_9 );
     END IF ;

     IF p_no_of_months > 9 THEN
       -- Get Parents contribution for 10th month
       igf_ap_efc_subf.a_p_cont_more_9(l_p_aai, l_p_cont, 10, l_p_cont_more_9 );
         -- Get Students EFC for > 9 months
       igf_ap_efc_subf.a_efc_not_9(l_p_cont_more_9,l_s_cont, l_s_cont_assets, g_efc_a_10 );
     END IF ;

     IF p_no_of_months > 10 THEN
       -- Get Parents contribution for 11th month
       igf_ap_efc_subf.a_p_cont_more_9(l_p_aai, l_p_cont, 11, l_p_cont_more_9 );
         -- Get Students EFC for 11th month
       igf_ap_efc_subf.a_efc_not_9(l_p_cont_more_9,l_s_cont, l_s_cont_assets, g_efc_a_11 );
     END IF ;


     IF p_no_of_months > 11 THEN
       -- Get Parents contribution for 11th month
       igf_ap_efc_subf.a_p_cont_more_9(l_p_aai, l_p_cont, 12, l_p_cont_more_9 );
         -- Get Students EFC for 12th month
       igf_ap_efc_subf.a_efc_not_9(l_p_cont_more_9,l_s_cont, l_s_cont_assets, g_efc_a_12 );
      END IF;

  EXCEPTION
     WHEN EXCEPTION_IN_SETUP THEN
          APP_EXCEPTION.RAISE_EXCEPTION;
     WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP'||SQLERRM);
          FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_CALC.EFC_A');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
  END efc_a;


  PROCEDURE efc_b  ( p_frml_code     IN           VARCHAR2,
                     p_sec_efc_type  IN            VARCHAR2,
                     p_no_of_months  IN           NUMBER,
                     p_efc           OUT NOCOPY   NUMBER,
                     p_sec_efc       OUT NOCOPY   NUMBER )   AS
  /*
  ||  Created By : masehgal
  ||  Created On : 11-feb-2003
  ||  Purpose : This is the procedure for calculating EFC for the Student with EFC formula B
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    l_s_inc            NUMBER(12,3) ; -- Student/Spouse Income
    l_allow_ag_s_inc   NUMBER(12,3) ; -- Allowance against Student/Spouse income
    l_s_cont           NUMBER(12,3) ; -- Contribution from Available Income
    l_s_cont_assets    NUMBER(12,3) ; -- Student/Spouse contribution from Assets
    l_sec_efc_s_cont_assets    NUMBER(12,3) ; -- Student/Spouse contribution from Assets

  BEGIN

    -- Get Student/Spouse income in 2000
    igf_ap_efc_subf.b_s_inc( l_s_inc );

    -- Get Allowance against Student/Spouse income
    igf_ap_efc_subf.b_allow_ag_s_inc( l_s_inc, l_allow_ag_s_inc );

    -- Get contribution from Available Income
    igf_ap_efc_subf.b_s_cont( l_s_inc, l_allow_ag_s_inc, l_s_cont );

    -- Get Student/Spouse contribution from Assets
    igf_ap_efc_subf.b_s_cont_assets ( l_s_cont_assets );

    l_sec_efc_s_cont_assets := l_s_cont_assets;

    IF ( p_frml_code <> '2' ) THEN
       l_s_cont_assets := 0;
    END IF;

    -- Get Expected Family Contribution for 9 months
    igf_ap_efc_subf.b_efc ( l_s_cont, l_s_cont_assets, p_efc );

    IF ( p_sec_efc_type = '2') THEN
      -- Get Expected Family Contribution for 9 months for secondary efc type 2.
      igf_ap_efc_subf.b_efc ( l_s_cont, l_sec_efc_s_cont_assets, p_sec_efc );
    END IF;

    IF ( p_no_of_months >= 9 ) THEN
      NULL; -- In this case EFC for > 9 months is = 9 month EFC
    ELSE
      -- Get Expected Family Contribution for less than 9 months
      igf_ap_efc_subf.b_efc_less_9( p_no_of_months, p_efc );

      IF ( p_sec_efc_type = '2') THEN
        igf_ap_efc_subf.b_efc_less_9( p_no_of_months, p_sec_efc );
      END IF;
    END IF;

  EXCEPTION
     WHEN EXCEPTION_IN_SETUP THEN
          APP_EXCEPTION.RAISE_EXCEPTION;
     WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_CALC.EFC_B');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;

  END efc_b;


  PROCEDURE efc_c  ( p_frml_code     IN            VARCHAR2,
                     p_sec_efc_type  IN            VARCHAR2,
                     p_no_of_months  IN            NUMBER,
                     p_efc           OUT  NOCOPY   NUMBER,
                     p_sec_efc       OUT  NOCOPY   NUMBER
)   AS
  /*
  ||  Created By : masehgal
  ||  Created On : 11-feb-2003
  ||  Purpose :  This is the procedure for calculating EFC for the Student with EFC formula C.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  l_s_inc             NUMBER(12,3) ; -- Student/Spouse Income
  l_allow_ag_s_inc    NUMBER(12,3) ; -- Allowance against Student/Spouse Income
  l_available_income  NUMBER(12,3) ; -- Available Income
  l_s_cont_assets     NUMBER(12,3) ; -- Student/Spouse contribution from Assets
  l_s_cont           NUMBER(12,3) ; -- Contribution from Available Income

  BEGIN
     -- Get Student/Spouse Income in 2000.
     igf_ap_efc_subf.c_s_inc ( l_s_inc );

     -- Get Allowances against Student/Spouse Income
     igf_ap_efc_subf.c_allow_ag_s_inc ( l_s_inc, l_allow_ag_s_inc );

     -- Get Available Income
     igf_ap_efc_subf.c_available_inc( l_s_inc, l_allow_ag_s_inc, l_available_income );


     -- Get Available Income
--     igf_ap_efc_subf.c_available_inc( l_s_inc, l_allow_ag_s_inc, l_s_cont );

     -- Get Student/Spouse contribution from Assets
     igf_ap_efc_subf.c_s_cont_assets ( l_s_cont_assets );


     IF ( p_frml_code = '6') then
        igf_ap_efc_subf.c_efc ( l_available_income, 0, p_efc , 'P' );
        igf_ap_efc_subf.c_efc ( l_available_income, l_s_cont_assets, p_sec_efc, 'S' );
     ELSE
        igf_ap_efc_subf.c_efc ( l_available_income, l_s_cont_assets, p_efc, 'P' );
     END IF;

     IF ( p_no_of_months >= 9 ) THEN

        NULL; -- In this case EFC for > 9 months is = 9 month EFC
     ELSE

      -- Get Expected Family Contribution for less than 9 months
      igf_ap_efc_subf.c_efc_less_9( p_no_of_months, p_efc );

      IF ( p_sec_efc_type = '3') THEN
        igf_ap_efc_subf.c_efc_less_9( p_no_of_months, p_sec_efc );
      END IF;

    END IF;

  EXCEPTION
     WHEN EXCEPTION_IN_SETUP THEN
          APP_EXCEPTION.RAISE_EXCEPTION;
     WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_CALC.EFC_C');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
  END efc_c;


  PROCEDURE calc_efc_main ( p_isir_rec         IN  OUT  NOCOPY    igf_ap_isir_matched%ROWTYPE ,
                            l_sys_award_year   IN                 VARCHAR2,
                            p_formula          IN                 VARCHAR2 )  AS
  /*
  ||  Created By : masehgal
  ||  Created On : 11-Feb-2003
  ||  Purpose : EFC Formula Determination
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  gmuralid        03-03-2003      BUG# 2826603 Removed width of Number type local variables.Also If EFC value
                                      exceeded 99999, wrapped it back to 99999
  || nsidana         11/20/2003        FA129 EFC updates for 2004-2005.
  ||  (reverse chronological order - newest change first)
  */

  p_efc              NUMBER  := null ;
  p_sec_efc              NUMBER  := null ;
  l_rowid            ROWID;
  l_category         NUMBER;
  l_formula          VARCHAR2(20); -- Regular/Simplified
  l_no_of_months     NUMBER;
  l_no_fabase_months NUMBER;
  l_efc_per_month    NUMBER;
  l_sec_efc_per_month    NUMBER;
  l_efc_1            NUMBER;
  l_efc_2            NUMBER;
  l_efc_3            NUMBER;
  l_efc_4            NUMBER;
  l_efc_5            NUMBER;
  l_efc_6            NUMBER;
  l_efc_7            NUMBER;
  l_efc_8            NUMBER;
  l_efc_9            NUMBER;
  l_efc_10           NUMBER;
  l_efc_11           NUMBER;
  l_efc_12           NUMBER;
  l_efc_s_1          NUMBER;
  l_efc_s_2          NUMBER;
  l_efc_s_3          NUMBER;
  l_efc_s_4          NUMBER;
  l_efc_s_5          NUMBER;
  l_efc_s_6          NUMBER;
  l_efc_s_7          NUMBER;
  l_efc_s_8          NUMBER;
  l_efc_s_9          NUMBER;
  l_efc_s_10         NUMBER;
  l_efc_s_11         NUMBER;
  l_efc_s_12         NUMBER;

  l_sc_assets_fa     NUMBER:= null;
  l_fabase_efc       igf_ap_isir_matched_all.paid_efc%TYPE;
  l_ftype            VARCHAR2(1);
  p_paid_efc         igf_ap_isir_matched_all.paid_efc%TYPE;

  BEGIN -- calc_efc_main

     -- Bug 2394936 ISIR we always calculate For 12 Months , Independent of Enrollment
     l_no_of_months := 12 ;
     l_sc_assets_fa := null ;

       IF  p_formula IN ( '1','2','3' ) THEN
           l_ftype := 'R'; -- Regular
       ELSIF  p_formula IN ( '4','5','6' ) THEN
           l_ftype := 'S'; -- Simplified
       END IF;

       IF ( p_formula = '5' and p_isir_rec.sec_efc_type = '2' ) THEN
          igf_ap_efc_subf.auto_zero_efc(p_isir_rec.primary_efc_type);
          -- AUTO ZERO
          p_sec_efc := 0;
          g_s_efc_a_9  := null ;
          g_s_efc_a_10 := null ;
          g_s_efc_a_11 := null ;
          g_s_efc_a_12 := null ;

       END IF;

       IF ( p_formula = '0' ) THEN
          igf_ap_efc_subf.auto_zero_efc(p_isir_rec.primary_efc_type);
          -- AUTO ZERO
          p_efc := 0;
          g_efc_a_9  := null ;
          g_efc_a_10 := null ;
          g_efc_a_11 := null ;
          g_efc_a_12 := null ;

       ELSIF ( p_formula IN ('1','4')) THEN
          -- Formula A
          g_efc_a_9  := null ;
          g_efc_a_10 := null ;
          g_efc_a_11 := null ;
          g_efc_a_12 := null ;

          efc_a( p_formula, l_no_of_months, p_efc , l_sc_assets_fa);

       ELSIF ( p_formula IN ('2','5') ) THEN -- Formula B
          efc_b( p_formula, p_isir_rec.sec_efc_type,l_no_of_months, p_efc,p_sec_efc);

       ELSIF ( p_formula IN ('3','6') ) THEN -- Formula C
          efc_c( p_formula, p_isir_rec.sec_efc_type, l_no_of_months, p_efc,p_sec_efc) ;

       END IF;

       p_efc :=   LEAST(99999,p_efc);

       -- Get the EFC per month of enrollment
       -- Bug# 2394936 - for worksheet A divide by exact number of months
       -- for other worksheets the calc arrived is always for 9 month
       IF ( p_formula  IN ('1','4')) THEN  -- Formula A
          l_efc_per_month := p_efc / l_no_of_months;
       ELSE
          g_efc_a_9 := p_efc ;
          l_efc_per_month := p_efc / 9 ;
       END IF;

       p_efc := ROUND ( p_efc ) ;

       -- Round off the EFC wrt Bug# 2339982
       l_efc_per_month := ROUND(l_efc_per_month) ;

       -- Bug# 2394936 - EFC will now be calculated for all months
       -- Hence the following code has been removed
       -- Get EFC value for each month

       -- 1/3/5 => REGULAR FORMULA
       IF l_ftype = 'R' THEN
        IF  p_formula IN ('1') THEN  -- Formula A
              l_efc_1 := get_month_efc(1) + NVL(l_sc_assets_fa,0) ;
              l_efc_2 := get_month_efc(2) + NVL(l_sc_assets_fa,0) ;
              l_efc_3 := get_month_efc(3) + NVL(l_sc_assets_fa,0) ;
              l_efc_4 := get_month_efc(4) + NVL(l_sc_assets_fa,0) ;
              l_efc_5 := get_month_efc(5) + NVL(l_sc_assets_fa,0) ;
              l_efc_6 := get_month_efc(6) + NVL(l_sc_assets_fa,0) ;
              l_efc_7 := get_month_efc(7) + NVL(l_sc_assets_fa,0) ;
              l_efc_8 := get_month_efc(8) + NVL(l_sc_assets_fa,0) ;
         ELSE
              l_efc_1 := (l_efc_per_month * 1) + NVL(l_sc_assets_fa,0) ;
              l_efc_2 := (l_efc_per_month * 2) + NVL(l_sc_assets_fa,0) ;
              l_efc_3 := (l_efc_per_month * 3) + NVL(l_sc_assets_fa,0) ;
              l_efc_4 := (l_efc_per_month * 4) + NVL(l_sc_assets_fa,0) ;
              l_efc_5 := (l_efc_per_month * 5) + NVL(l_sc_assets_fa,0) ;
              l_efc_6 := (l_efc_per_month * 6) + NVL(l_sc_assets_fa,0) ;
              l_efc_7 := (l_efc_per_month * 7) + NVL(l_sc_assets_fa,0) ;
              l_efc_8 := (l_efc_per_month * 8) + NVL(l_sc_assets_fa,0) ;
         END IF;

         l_efc_s_1  :=  NULL ;
         l_efc_s_2  :=  NULL ;
         l_efc_s_3  :=  NULL ;
         l_efc_s_4  :=  NULL ;
         l_efc_s_5  :=  NULL ;
         l_efc_s_6  :=  NULL ;
         l_efc_s_7  :=  NULL ;
         l_efc_s_8  :=  NULL ;
         l_efc_s_9  :=  NULL ;
         l_efc_s_10 :=  NULL ;
         l_efc_s_11 :=  NULL ;
         l_efc_s_12 :=  NULL ;

       ELSIF  l_ftype = 'S' THEN   -- SIMPLIFIED FORMULA

         -- primary efc will not include inc from assets
         IF p_formula IN ('4') THEN  -- Formula A
            l_efc_1 := get_month_efc(1) ;
            l_efc_2 := get_month_efc(2) ;
            l_efc_3 := get_month_efc(3) ;
            l_efc_4 := get_month_efc(4) ;
            l_efc_5 := get_month_efc(5) ;
            l_efc_6 := get_month_efc(6) ;
            l_efc_7 := get_month_efc(7) ;
            l_efc_8 := get_month_efc(8) ;
         ELSE

            l_efc_1 := (l_efc_per_month * 1) ;
            l_efc_2 := (l_efc_per_month * 2) ;
            l_efc_3 := (l_efc_per_month * 3) ;
            l_efc_4 := (l_efc_per_month * 4) ;
            l_efc_5 := (l_efc_per_month * 5) ;
            l_efc_6 := (l_efc_per_month * 6) ;
            l_efc_7 := (l_efc_per_month * 7) ;
            l_efc_8 := (l_efc_per_month * 8) ;
        END IF;

        -- secondary efc will include inc from assets
       IF  p_formula IN ('4') THEN  -- Formula A
            l_efc_s_1 := get_month_efc(1) + NVL(l_sc_assets_fa,0) ;
            l_efc_s_2 := get_month_efc(2) + NVL(l_sc_assets_fa,0) ;
            l_efc_s_3 := get_month_efc(3) + NVL(l_sc_assets_fa,0) ;
            l_efc_s_4 := get_month_efc(4) + NVL(l_sc_assets_fa,0) ;
            l_efc_s_5 := get_month_efc(5) + NVL(l_sc_assets_fa,0) ;
            l_efc_s_6 := get_month_efc(6) + NVL(l_sc_assets_fa,0) ;
            l_efc_s_7 := get_month_efc(7) + NVL(l_sc_assets_fa,0) ;
            l_efc_s_8 := get_month_efc(8) + NVL(l_sc_assets_fa,0) ;
        ELSE

      IF (  p_formula in ( '5','6') and p_isir_rec.sec_efc_type in ( '2','3')  ) then


          p_sec_efc :=   LEAST(99999,p_sec_efc);
          g_s_efc_a_9 := p_sec_efc;
                l_sec_efc_per_month := p_sec_efc / 9 ;
                p_sec_efc := ROUND ( p_sec_efc ) ;
          l_sec_efc_per_month := ROUND(l_sec_efc_per_month) ;

            l_efc_s_1 := (l_sec_efc_per_month * 1) + NVL(l_sc_assets_fa,0) ;
            l_efc_s_2 := (l_sec_efc_per_month * 2) + NVL(l_sc_assets_fa,0) ;
            l_efc_s_3 := (l_sec_efc_per_month * 3) + NVL(l_sc_assets_fa,0) ;
            l_efc_s_4 := (l_sec_efc_per_month * 4) + NVL(l_sc_assets_fa,0) ;
            l_efc_s_5 := (l_sec_efc_per_month * 5) + NVL(l_sc_assets_fa,0) ;
            l_efc_s_6 := (l_sec_efc_per_month * 6) + NVL(l_sc_assets_fa,0) ;
            l_efc_s_7 := (l_sec_efc_per_month * 7) + NVL(l_sc_assets_fa,0) ;
            l_efc_s_8 := (l_sec_efc_per_month * 8) + NVL(l_sc_assets_fa,0) ;
      ELSE

         -- formula C TYPE  '6'  and '3'

            l_efc_s_1 := (l_efc_per_month * 1) + NVL(l_sc_assets_fa,0) ;
            l_efc_s_2 := (l_efc_per_month * 2) + NVL(l_sc_assets_fa,0) ;
            l_efc_s_3 := (l_efc_per_month * 3) + NVL(l_sc_assets_fa,0) ;
            l_efc_s_4 := (l_efc_per_month * 4) + NVL(l_sc_assets_fa,0) ;
            l_efc_s_5 := (l_efc_per_month * 5) + NVL(l_sc_assets_fa,0) ;
            l_efc_s_6 := (l_efc_per_month * 6) + NVL(l_sc_assets_fa,0) ;
            l_efc_s_7 := (l_efc_per_month * 7) + NVL(l_sc_assets_fa,0) ;
            l_efc_s_8 := (l_efc_per_month * 8) + NVL(l_sc_assets_fa,0) ;

    END IF;

        END IF;



      END IF;


      -- Bug# 2394936 - EFC for Worksheet B/C will be 9 month for months greater than 9
  IF  p_formula IN ('1','4') THEN  -- Formula A
            IF l_ftype = 'R' THEN
                l_efc_9 :=  g_efc_a_9 + NVL(l_sc_assets_fa,0) ;
            ELSE
                l_efc_9   :=  g_efc_a_9 ;
                  l_efc_s_9 :=  g_efc_a_9 + NVL(l_sc_assets_fa,0) ;

            END IF;
        ELSE
             l_efc_9 := ROUND(g_efc_a_9) ;


             -- plug in the code here ...
             -- manu :- our system does not gets a value for secondary_efc when formula '2','3','5','6' is used.
             IF (    p_isir_rec.dependency_status = 'I'
                 AND l_efc_9 IS NOT NULL
                 AND p_isir_rec.reject_reason_codes IS NULL
                 AND NVL( p_isir_rec.simplified_need_test, 'N') = 'Y'
                 AND NVL( p_isir_rec.auto_zero_efc, 'N') <> 'Y'
                 AND (   p_isir_rec.s_investment_networth IS NOT NULL
                      OR p_isir_rec.s_busi_farm_networth IS NOT NULL
                      OR p_isir_rec.s_cash_savings IS NOT NULL  )
                ) THEN
                  -- populate sec efc value
          if ( p_formula IN ('5','6') AND p_isir_rec.sec_efc_type IN ('2','3') ) then
                    l_efc_s_9 :=  g_s_efc_a_9 + NVL(l_sc_assets_fa,0) ;
                      l_efc_s_9 := ROUND(l_efc_s_9) ;
                else
                      l_efc_s_9 := ROUND(g_efc_a_9) ;
      END IF;

             ELSE
                  -- do not populate field
                  l_efc_s_9 :=  NULL ;
             END IF ;

             -- Upto here ..... as suggested by CARL over con call ;

/*
not required   as dependent means formula '1', '4'
those will enter the loop above and not this one ...
             -- My understanding for Dependent Student ....
             IF (    p_isir_rec.dependency_status = 'D'
                 AND p_isir_rec.reject_reason_codes IS NOT NULL
                 AND p_paid_efc IS NOT NULL
                 AND NVL( p_isir_rec.simplified_need_test, 'N') <> 'Y'
                 AND NVL( p_isir_rec.auto_zero_efc, 'N') <> 'Y'
                 AND (   p_isir_rec.p_investment_networth IS NULL
                      OR p_isir_rec.p_business_networth IS NULL
                      OR p_isir_rec.p_cash_saving IS NULL
                      OR p_isir_rec.s_investment_networth IS NULL
                      OR  p_isir_rec.s_busi_farm_networth IS NULL
                      OR p_isir_rec.s_cash_savings IS NULL )
                ) THEN
                  -- populate sec efc value ;
                  l_efc_s_9 := ROUND(g_efc_a_9) ;
             ELSE
                  -- do not populate field
                  l_efc_s_9 :=  NULL ;
             END IF ;
             -- manu :- may need to pull it out if it bombs ....
*/

      END IF;

      IF  p_formula IN ('1','4') THEN  -- Formula A
          IF l_ftype = 'R' THEN
             l_efc_10 :=  g_efc_a_10 + NVL(l_sc_assets_fa,0) ;
          ELSE
             l_efc_10   :=  g_efc_a_10 ;
             l_efc_s_10 :=  g_efc_a_10 + NVL(l_sc_assets_fa,0) ;
          END IF;
      ELSIF  p_formula IN ('0') THEN  -- Auto Zero Formula
             l_efc_10   :=  NULL;
      ELSE
          l_efc_10 := ROUND(g_efc_a_9) ;
           -- For simplified calculate the secondary efc as well
          IF l_ftype <> 'R' THEN
        if ( p_formula in ('5','6') and p_isir_rec.sec_efc_type in ('2','3') ) then
                l_efc_s_10 := ROUND(g_s_efc_a_9) ;
    else
                l_efc_s_10 := ROUND(g_efc_a_9) ;
    end if;
          END IF;

     END IF;

      IF p_formula IN ('1','4') THEN  -- Formula A
         IF l_ftype = 'R' THEN
            l_efc_11 :=  g_efc_a_11 + NVL(l_sc_assets_fa,0) ;
         ELSE
            l_efc_11   :=  g_efc_a_11 ;
            l_efc_s_11 :=  g_efc_a_11 + NVL(l_sc_assets_fa,0) ;
         END IF;
      ELSIF  p_formula IN ('0') THEN  -- Auto Zero Formula
            l_efc_11   :=  NULL;
      ELSE
         l_efc_11 := ROUND(g_efc_a_9) ;
         -- For simplified calculate the secondary efc as well
          IF l_ftype <> 'R' THEN
--        if ( p_formula = '5' and p_isir_rec.sec_efc_type = '2' ) then
        if ( p_formula in ('5','6') and p_isir_rec.sec_efc_type in ('2','3') ) then
                l_efc_s_11 := ROUND(g_s_efc_a_9) ;
    else
                l_efc_s_11 := ROUND(g_efc_a_9) ;
    end if;
          END IF;
      END IF;

      IF p_formula IN ('1','4') THEN  -- Formula A
         IF l_ftype = 'R' THEN
            l_efc_12 :=  g_efc_a_12 + NVL(l_sc_assets_fa,0) ;
         ELSE
            l_efc_12   :=  g_efc_a_12 ;
            l_efc_s_12 :=  g_efc_a_12 + NVL(l_sc_assets_fa,0) ;
         END IF;
      ELSIF  p_formula IN ('0') THEN  -- Auto Zero Formula
             l_efc_12   :=  NULL;
      ELSE
          l_efc_12 := ROUND(g_efc_a_9) ;
          -- For simplified calculate the secondary efc as well

          IF l_ftype <> 'R' THEN

--               if ( p_formula = '5' and p_isir_rec.sec_efc_type = '2' ) then
        if ( p_formula in ('5','6') and p_isir_rec.sec_efc_type in ('2','3') ) then
                l_efc_s_12 := ROUND(g_s_efc_a_9) ;
    else
                l_efc_s_12 := ROUND(g_efc_a_9) ;
    end if;
          END IF;

      END IF;
      p_paid_efc := l_efc_9;

      l_efc_1   :=   LEAST(99999,l_efc_1) ;
      l_efc_2   :=   LEAST(99999,l_efc_2) ;
      l_efc_3   :=   LEAST(99999,l_efc_3) ;
      l_efc_4   :=   LEAST(99999,l_efc_4) ;
      l_efc_5   :=   LEAST(99999,l_efc_5) ;
      l_efc_6   :=   LEAST(99999,l_efc_6) ;
      l_efc_7   :=   LEAST(99999,l_efc_7) ;
      l_efc_8   :=   LEAST(99999,l_efc_8) ;
      l_efc_9   :=   LEAST(99999,l_efc_9) ;
      l_efc_10  :=   LEAST(99999,l_efc_10) ;
      l_efc_11  :=   LEAST(99999,l_efc_11) ;
      l_efc_12  :=   LEAST(99999,l_efc_12) ;

      l_efc_s_1  :=  LEAST(99999,l_efc_s_1) ;
      l_efc_s_2  :=  LEAST(99999,l_efc_s_2) ;
      l_efc_s_3  :=  LEAST(99999,l_efc_s_3) ;
      l_efc_s_4  :=  LEAST(99999,l_efc_s_4) ;
      l_efc_s_5  :=  LEAST(99999,l_efc_s_5) ;
      l_efc_s_6  :=  LEAST(99999,l_efc_s_6) ;
      l_efc_s_7  :=  LEAST(99999,l_efc_s_7) ;
      l_efc_s_8  :=  LEAST(99999,l_efc_s_8) ;
      l_efc_s_9  :=  LEAST(99999,l_efc_s_9) ;
      l_efc_s_10 :=  LEAST(99999,l_efc_s_10) ;
      l_efc_s_11 :=  LEAST(99999,l_efc_s_11) ;
      l_efc_s_12 :=  LEAST(99999,l_efc_s_12) ;

      p_paid_efc :=  LEAST(99999,p_paid_efc);


       -- Update the isir rowtype variable
       isir_rec.primary_alternate_month_1  := l_efc_1 ;
       isir_rec.primary_alternate_month_2  := l_efc_2 ;
       isir_rec.primary_alternate_month_3  := l_efc_3 ;
       isir_rec.primary_alternate_month_4  := l_efc_4 ;
       isir_rec.primary_alternate_month_5  := l_efc_5 ;
       isir_rec.primary_alternate_month_6  := l_efc_6 ;
       isir_rec.primary_alternate_month_7  := l_efc_7 ;
       isir_rec.primary_alternate_month_8  := l_efc_8 ;
       isir_rec.primary_alternate_month_10 := l_efc_10;
       isir_rec.primary_alternate_month_11 := l_efc_11;
       isir_rec.primary_alternate_month_12 := l_efc_12;
       isir_rec.paid_efc := null;                          -- p_paid_efc;   nsidana 11/20/2003 FA129 EFC updates for 2004-2005.
       isir_rec.primary_efc := p_paid_efc ;

       isir_rec.sec_alternate_month_1  := l_efc_s_1 ;
       isir_rec.sec_alternate_month_2  := l_efc_s_2 ;
       isir_rec.sec_alternate_month_3  := l_efc_s_3 ;
       isir_rec.sec_alternate_month_4  := l_efc_s_4 ;
       isir_rec.sec_alternate_month_5  := l_efc_s_5 ;
       isir_rec.sec_alternate_month_6  := l_efc_s_6 ;
       isir_rec.sec_alternate_month_7  := l_efc_s_7 ;
       isir_rec.sec_alternate_month_8  := l_efc_s_8 ;
       isir_rec.sec_alternate_month_10 := l_efc_s_10;
       isir_rec.sec_alternate_month_11 := l_efc_s_11;
       isir_rec.sec_alternate_month_12 := l_efc_s_12;

       isir_rec.secondary_efc := l_efc_s_9 ;

       flush_values(isir_rec);


    EXCEPTION
      WHEN EXCEPTION_IN_SETUP THEN
           APP_EXCEPTION.RAISE_EXCEPTION;
      WHEN OTHERS THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP'||SQLERRM);
           FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_CALC.CALC_EFC_MAIN');
           IGS_GE_MSG_STACK.ADD;
           APP_EXCEPTION.RAISE_EXCEPTION;

    END calc_efc_main ;


PROCEDURE calculate_efc (p_isir_rec         IN  OUT  NOCOPY    igf_ap_isir_matched%ROWTYPE ,
                         p_ignore_warnings  IN                 VARCHAR2 ,
                         p_sys_batch_yr     IN                 VARCHAR2 ,
                         p_return_status        OUT  NOCOPY    VARCHAR2 ) AS
  /*
  ||  Created By : masehgal
  ||  Created On : 11-Feb-2003
  ||  Purpose : Main EFC Engine
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  p_formula       VARCHAR2(30) := NULL ;
  p_reject_codes  VARCHAR2(300) := NULL ;
  l_len_rejects   NUMBER       := NULL ;
  l_curr_pos      NUMBER       := 1 ;




  BEGIN -- calculate_efc

     -- Reset the values to be computed/assumed  only if the ignore warnings flag is not set
     IF NVL(p_ignore_warnings, 'N') <> 'Y' THEN
     -- Reset the computed values
        p_isir_rec.paid_efc                    := NULL;
        p_isir_rec.primary_efc                 := NULL;
        p_isir_rec.secondary_efc               := NULL;
        p_isir_rec.fed_pell_grant_efc_type     := NULL;
        p_isir_rec.primary_efc_type            := NULL;
        p_isir_rec.sec_efc_type                := NULL;
        p_isir_rec.primary_alternate_month_1   := NULL;
        p_isir_rec.primary_alternate_month_2   := NULL;
        p_isir_rec.primary_alternate_month_3   := NULL;
        p_isir_rec.primary_alternate_month_4   := NULL;
        p_isir_rec.primary_alternate_month_5   := NULL;
        p_isir_rec.primary_alternate_month_6   := NULL;
        p_isir_rec.primary_alternate_month_7   := NULL;
        p_isir_rec.primary_alternate_month_8   := NULL;
        p_isir_rec.primary_alternate_month_10  := NULL;
        p_isir_rec.primary_alternate_month_11  := NULL;
        p_isir_rec.primary_alternate_month_12  := NULL;
        p_isir_rec.sec_alternate_month_1       := NULL;
        p_isir_rec.sec_alternate_month_2       := NULL;
        p_isir_rec.sec_alternate_month_3       := NULL;
        p_isir_rec.sec_alternate_month_4       := NULL;
        p_isir_rec.sec_alternate_month_5       := NULL;
        p_isir_rec.sec_alternate_month_6       := NULL;
        p_isir_rec.sec_alternate_month_7       := NULL;
        p_isir_rec.sec_alternate_month_8       := NULL;
        p_isir_rec.sec_alternate_month_10      := NULL;
        p_isir_rec.sec_alternate_month_11      := NULL;
        p_isir_rec.sec_alternate_month_12      := NULL;
        p_isir_rec.total_income                := NULL;
        p_isir_rec.allow_total_income          := NULL;
        p_isir_rec.state_tax_allow             := NULL;
        p_isir_rec.employment_allow            := NULL;
        p_isir_rec.income_protection_allow     := NULL;
        p_isir_rec.available_income            := NULL;
        p_isir_rec.contribution_from_ai        := NULL;
        p_isir_rec.discretionary_networth      := NULL;
        p_isir_rec.efc_networth                := NULL;
        p_isir_rec.asset_protect_allow         := NULL;
        p_isir_rec.parents_cont_from_assets    := NULL;
        p_isir_rec.adjusted_available_income   := NULL;
        p_isir_rec.total_student_contribution  := NULL;
        p_isir_rec.total_parent_contribution   := NULL;
        p_isir_rec.parents_contribution        := NULL;
        p_isir_rec.student_total_income        := NULL;
        p_isir_rec.sati                        := NULL;
        p_isir_rec.sic                         := NULL;
        p_isir_rec.sdnw                        := NULL;
        p_isir_rec.sca                         := NULL;
        p_isir_rec.fti                         := NULL;
        p_isir_rec.secti                       := NULL;
        p_isir_rec.secati                      := NULL;
        p_isir_rec.secstx                      := NULL;
        p_isir_rec.secea                       := NULL;
        p_isir_rec.secipa                      := NULL;
        p_isir_rec.secai                       := NULL;
        p_isir_rec.seccai                      := NULL;
        p_isir_rec.secdnw                      := NULL;
        p_isir_rec.secnw                       := NULL;
        p_isir_rec.secapa                      := NULL;
        p_isir_rec.secpca                      := NULL;
        p_isir_rec.secaai                      := NULL;
        p_isir_rec.sectsc                      := NULL;
        p_isir_rec.sectpc                      := NULL;
        p_isir_rec.secpc                       := NULL;
        p_isir_rec.secsti                      := NULL;
        p_isir_rec.secsati                     := NULL;
        p_isir_rec.secsic                      := NULL;
        p_isir_rec.secsdnw                     := NULL;
        p_isir_rec.secsca                      := NULL;
        p_isir_rec.secfti                      := NULL;
        p_isir_rec.a_citizenship               := NULL;
        p_isir_rec.a_student_marital_status    := NULL;
        p_isir_rec.a_student_agi               := NULL;
        p_isir_rec.a_s_us_tax_paid             := NULL;
        p_isir_rec.a_s_income_work             := NULL;
        p_isir_rec.a_spouse_income_work        := NULL;
        p_isir_rec.a_s_total_wsc               := NULL;
        p_isir_rec.a_date_of_birth             := NULL;
        p_isir_rec.a_student_married           := NULL;
        p_isir_rec.a_have_children             := NULL;
        p_isir_rec.a_s_have_dependents         := NULL;
        p_isir_rec.a_va_status                 := NULL;
        p_isir_rec.a_s_num_in_family           := NULL;
        p_isir_rec.a_s_num_in_college          := NULL;
        p_isir_rec.a_p_marital_status          := NULL;
        p_isir_rec.a_father_ssn                := NULL;
        p_isir_rec.a_mother_ssn                := NULL;
--        p_isir_rec.a_parents_num_family        := NULL;
--        p_isir_rec.a_parents_num_college       := NULL;
        p_isir_rec.a_parents_agi               := NULL;
        p_isir_rec.a_p_us_tax_paid             := NULL;
        p_isir_rec.a_f_work_income             := NULL;
        p_isir_rec.a_m_work_income             := NULL;
        p_isir_rec.a_p_total_wsc               := NULL;
        p_isir_rec.payment_isir                := NULL;
        p_isir_rec.receipt_status              := NULL;
        p_isir_rec.isir_receipt_completed      := NULL;
       /* p_isir_rec.system_record_type          := NULL; This value need not be nullified. */
        p_isir_rec.primary_efc_type            := NULL;
        p_isir_rec.sec_efc_type                := NULL;
        p_isir_rec.p_cal_tax_status            := NULL;
        p_isir_rec.s_cal_tax_status            := NULL;
        p_isir_rec.reject_reason_codes         := NULL;
     END IF ;

     p_sys_award_year := p_sys_batch_yr ;


     -- If P_IGNORE_WARNINGS = 'Y' then this is a second call from the ISIR Modify Page
     -- with the users decision to ignore warnings and proceed with the EFC Calculation.
     -- Move to Step CALC_EFC_MAIN
     IF NVL(p_ignore_warnings, 'N') <> 'Y' THEN
        -- do Model Determination, Assumption Edits,
        igf_ap_assumption_reject_edits.assume_values ( p_isir_rec,
                                                       p_sys_award_year ) ;
     END IF;

     -- Formula Determination
     get_efc_frml ( p_isir_rec,
                    p_formula ) ;

     -- Reject Edits before going to CALC_EFC_MAIN
     IF NVL(p_ignore_warnings, 'N') <> 'Y' THEN
        -- do Reject Edits, set return status
        igf_ap_assumption_reject_edits.reject_edits ( p_isir_rec     ,
                                                      p_sys_award_year ,
                                                      p_reject_codes ) ;
-- This has to be removed before final version release .....
p_isir_rec.reject_reason_codes := p_reject_codes ;

        -- Check if there are any reject reasons
        IF p_reject_codes is NOT NULL THEN
           -- If reject reasons present then check if there are non suppressable rejects
           l_len_rejects := LENGTH (p_reject_codes) ;
           l_curr_pos    := 1 ;
           p_return_status := 'W' ;
           LOOP
           EXIT WHEN l_curr_pos >= l_len_rejects ;
               -- check if any of the reject reasons is a numeric code
               -- if yes then it is non suppressable
               IF chk_reject( SUBSTR ( p_reject_codes, l_curr_pos , 2 )) THEN
                  -- numeric value exists
                  -- throw error message, raise exception
                  p_return_status := 'E' ;
                  RAISE EXCEPTION_IN_REJECTS ;
               END IF ;
           l_curr_pos := l_curr_pos + 2 ;
           END LOOP ;

           -- alphanumeric value exists
           -- throw error message, raise exception
           p_return_status := 'W' ;
           RAISE EXCEPTION_IN_REJECTS ;

        ELSE
           p_return_status := 'S' ;
        END IF ; -- chk for NULL reject codes
     END IF ;   -- chk for ignore warning flag

     isir_rec := p_isir_rec ;

     -- Call main efc calcuation engine
     -- once here means the rejects are to be rejected
--  not to be done if CARLs Comments are to be included
--  p_reject_codes := NULL ;

     calc_efc_main ( isir_rec   ,
                     p_sys_award_year ,
                     p_formula ) ;

     p_isir_rec := isir_rec ;

     -- once here means the rejects were not to be considered and therefore the return status should be 'S'
     p_return_status := 'S' ;
/*
     -- Flush out secondary efc here ....
     -- For Dependent or Independent or Both ???  Yet to clarify ....
     -- Also ask abt the reject reasons being not null .... this is not mentioned in the FD ....
     -- Nor is the Auto Zero Flag mentioned in the FD .... ENQUIRE .....
     IF (    p_isir_rec.dependency_status = 'I'
         AND p_isir_rec.primary_efc IS NOT NULL
         AND p_isir_rec.reject_reason_codes IS NOT NULL
         AND NVL( p_isir_rec.simplified_need_test, 'N') <> 'Y'
         AND NVL( p_isir_rec.auto_zero_efc, 'N') <> 'Y'
         AND (   p_isir_rec.s_investment_networth IS NULL
              OR p_isir_rec.s_busi_farm_networth IS NULL
              OR p_isir_rec.s_cash_savings IS NULL  )
        ) THEN
          -- populate sec efc value
     ELSE
          -- do not populate field
          p_isir_rec.secondary_efc :=  NULL ;
     END IF ;
     -- Upto here ..... as suggested by CARL over con call ;

     -- My understanding for Dependent Student ....
     IF (    p_isir_rec.dependency_status = 'D'
         AND p_reject_codes IS NOT NULL
         AND p_isir_rec.primary_efc IS NOT NULL
         AND NVL( p_isir_rec.simplified_need_test, 'N') <> 'Y'
         AND NVL( p_isir_rec.auto_zero_efc, 'N') <> 'Y'
         AND (   p_isir_rec.p_investment_networth IS NULL
              OR p_isir_rec.p_business_networth IS NULL
              OR p_isir_rec.p_cash_saving IS NULL
              OR p_isir_rec.s_investment_networth IS NULL
              OR  p_isir_rec.s_busi_farm_networth IS NULL
              OR p_isir_rec.s_cash_savings IS NULL )
        ) THEN
          -- populate sec efc value ;
     ELSE
          -- do not populate field
          p_isir_rec.secondary_efc :=  NULL ;
     END IF ;

*/





  EXCEPTION
     WHEN EXCEPTION_IN_REJECTS THEN
          RETURN ;

     WHEN EXCEPTION_IN_SETUP THEN
          APP_EXCEPTION.RAISE_EXCEPTION;

     WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP'||SQLERRM);
          FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_EFC_CALC.CALCULATE_EFC');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;

  END calculate_efc ;

END igf_ap_efc_calc;

/
