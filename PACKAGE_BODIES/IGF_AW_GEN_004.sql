--------------------------------------------------------
--  DDL for Package Body IGF_AW_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_GEN_004" AS
/* $Header: IGFAW13B.pls 120.7 2006/06/06 07:29:33 akomurav noship $ */

  /*************************************************************
  Change History
  Who             When            What
  mnade           6/6/2005        FA 157 - 4382371 - Changes in award notification letter.
                                  Also added get_base_id_for_person  function.
  svuppala     4-Nov-2004    #3416936 FA 134 TBH impacts for newly added columns
  veramach  Oct 2004         FA 152/FA 137 - Changes to wrappers to
                             bring in the awarding period setup
  veramach   02-Sep-2004     bug 3869507 Resolved an issue where freq_attempt of an item was being added wrongly to other items.
  veramach   06-OCT-2003      FA 124
                            Added functions efc_i,is_inas_integrated,need_i,unmetneed_i
  KUMMA      07-jun-2003    2853531, Modified corp_pre_process and build_sql_stmt for adding the dynamic and static group
                            functionality for financial aid system letter
  kumma      24-JUN-2003    2853531, Modified the call to igs_pe_dynamic_persid_group.IGS_GET_DYNAMIC_SQL as earlier it was a procedure
                            and now it is a function
  (reverse chronological order - newest change first)

  ***************************************************************/

  -- bvisvana - bug 3724328 - For Code refactoring (Issue with huge person id groups)
  TYPE temp_person_id IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  temp_person_id_array  temp_person_id;


FUNCTION get_award_data_wrap (
      p_person_id   IN   NUMBER,
      p_fund_id     IN   VARCHAR2,
      p_param1      IN   VARCHAR2,
      p_param2      IN   VARCHAR2 ,
      p_param3      IN   VARCHAR2 ,
      p_param4      IN   VARCHAR2 ,
      p_param5      IN   VARCHAR2 ,
      p_param6      IN   VARCHAR2 ,
      p_param7      IN   VARCHAR2 ,
      p_flag        IN   VARCHAR2,
      p_awd_tot     OUT NOCOPY  NUMBER
   )
      RETURN VARCHAR2;


   FUNCTION get_term_total_wrap (
      p_person_id   IN   NUMBER,
      p_param1      IN   VARCHAR2,
      p_param2      IN   VARCHAR2 ,
      p_param3      IN   VARCHAR2 ,
      p_param4      IN   VARCHAR2 ,
      p_param5      IN   VARCHAR2 ,
      p_param6      IN   VARCHAR2 ,
      p_param7      IN   VARCHAR2 ,
      p_flag        IN   VARCHAR2,
      p_awd_tot     OUT NOCOPY  NUMBER
   )
      RETURN VARCHAR2;


   PROCEDURE award_letter_matrix (
      p_person_id       IN       NUMBER,
      p_param1          IN       VARCHAR2,
      p_param2          IN       VARCHAR2 ,
      p_param3          IN       VARCHAR2 ,
      p_param4          IN       VARCHAR2 ,
      p_param5          IN       VARCHAR2 ,
      p_param6          IN       VARCHAR2 ,
      p_param7          IN       VARCHAR2 ,
      p_flag            IN       VARCHAR2,
      p_return_status   OUT NOCOPY      VARCHAR2
   );


   PROCEDURE missing_items (
      p_person_id       IN       NUMBER,
      p_param1          IN       VARCHAR2,
      p_return_status   OUT NOCOPY      VARCHAR2
   );


  -- mnade 5/28/2005 - Added the common cursors here.

    CURSOR g_c_get_details
    (
      cp_person_id                      igf_ap_fa_base_rec_all.person_id%TYPE,
      cp_fa_cal_type                    igs_ca_inst_all.cal_type%TYPE,
      cp_fa_sequence_number             igs_ca_inst_all.sequence_number%TYPE,
      cp_ld_cal_type                    igs_ca_inst_all.cal_type%TYPE,
      cp_ld_sequence_number             igs_ca_inst_all.sequence_number%TYPE,
      cp_fund_id                        igf_aw_fund_mast.fund_id%TYPE,
      cp_award_prd_cd                   igf_aw_awd_prd_term.award_prd_cd%TYPE
    ) IS
    SELECT
        cai.start_dt,
        cai.alternate_code,
        cai.cal_type,
        cai.sequence_number,
        sum(NVL (disb_gross_amt, 0)) load_total_offered_amt,
        count(distinct awd.award_id) award_count,
        fmast.fund_id fund_id,
        fmast.description fund_name
    FROM
      igf_aw_award_all awd,
      igf_aw_fund_mast fmast,
      igs_ca_inst_all cai,
      igf_aw_awd_disb disb
    WHERE
      fmast.ci_cal_type             = cp_fa_cal_type AND
      fmast.ci_sequence_number      = cp_fa_sequence_number AND
      awd.base_id                   = igf_aw_gen_004.get_base_id_for_person (cp_person_id, cp_fa_cal_type, cp_fa_sequence_number) AND
      awd.fund_id                   = fmast.fund_id AND
      awd.award_status              IN ('ACCEPTED', 'OFFERED') AND
--      awd.notification_status_code  IN ('R', 'F') AND
      awd.award_id                  = disb.award_id AND
      cai.cal_type                  = disb.ld_cal_type AND
      cai.sequence_number           = disb.ld_sequence_number AND
      disb.ld_cal_type              = NVL(cp_ld_cal_type, disb.ld_cal_type) AND
      disb.ld_sequence_number       = NVL(cp_ld_sequence_number, disb.ld_sequence_number) AND
      fmast.fund_id                 = NVL(cp_fund_id, fmast.fund_id)
      AND
      NOT EXISTS
        (SELECT disb.ld_cal_type, disb.ld_sequence_number
        FROM igf_aw_awd_disb disb
        WHERE
          disb.award_id = awd.award_id
        MINUS
        SELECT ld_cal_type, ld_sequence_number
        FROM igf_aw_awd_prd_term apt
        WHERE apt.ci_cal_type         = cp_fa_cal_type AND
              apt.ci_sequence_number  = cp_fa_sequence_number AND
              apt.award_prd_cd        = NVL(cp_award_prd_cd, award_prd_cd))
    GROUP BY
        cai.start_dt,
        cai.alternate_code,
        cai.cal_type,
        cai.sequence_number,
        fmast.fund_id,
        fmast.description
    order by cai.start_dt, fmast.description;

    CURSOR g_c_get_load_cals
    (
      cp_person_id                      igf_ap_fa_base_rec_all.person_id%TYPE,
      cp_fa_cal_type                    igs_ca_inst_all.cal_type%TYPE,
      cp_fa_sequence_number             igs_ca_inst_all.sequence_number%TYPE,
      cp_award_prd_cd                   igf_aw_awd_prd_term.award_prd_cd%TYPE
    ) IS
    SELECT
        DISTINCT
        cai.start_dt,
        cai.alternate_code,
        cai.cal_type,
        cai.sequence_number
    FROM
      igf_aw_award_all awd,
      igf_aw_fund_mast fmast,
      igs_ca_inst_all cai,
      igf_aw_awd_disb disb
    WHERE
      fmast.ci_cal_type             = cp_fa_cal_type AND
      fmast.ci_sequence_number      = cp_fa_sequence_number AND
      awd.base_id                   = igf_aw_gen_004.get_base_id_for_person (cp_person_id, cp_fa_cal_type, cp_fa_sequence_number) AND
      awd.fund_id                   = fmast.fund_id AND
      awd.award_status              IN ('ACCEPTED', 'OFFERED') AND
--      awd.notification_status_code  IN ('R', 'F') AND
      awd.award_id                  = disb.award_id AND
      cai.cal_type                  = disb.ld_cal_type AND
      cai.sequence_number           = disb.ld_sequence_number
      AND
      NOT EXISTS
        (SELECT disb.ld_cal_type, disb.ld_sequence_number
        FROM igf_aw_awd_disb disb
        WHERE
          disb.award_id = awd.award_id
        MINUS
        SELECT ld_cal_type, ld_sequence_number
        FROM igf_aw_awd_prd_term apt
        WHERE apt.ci_cal_type         = cp_fa_cal_type AND
              apt.ci_sequence_number  = cp_fa_sequence_number AND
              apt.award_prd_cd        = NVL(cp_award_prd_cd, award_prd_cd))
    order by cai.start_dt;

  --mnade 5/28/2005 Generic function to get base id and avoid join with igf_ap_base_rec_all
  FUNCTION  get_base_id_for_person (
            p_person_id                      igf_ap_fa_base_rec_all.person_id%TYPE,
            p_fa_cal_type                    igs_ca_inst_all.cal_type%TYPE,
            p_fa_sequence_number             igs_ca_inst_all.sequence_number%TYPE
          ) RETURN NUMBER IS
    CURSOR c_base_id (
            cp_person_id                      igf_ap_fa_base_rec_all.person_id%TYPE,
            cp_fa_cal_type                    igs_ca_inst_all.cal_type%TYPE,
            cp_fa_sequence_number             igs_ca_inst_all.sequence_number%TYPE
            )
      IS
      SELECT
        base.base_id
      FROM igf_ap_fa_base_rec_all base
      WHERE
              person_id                 = cp_person_id
          AND base.ci_cal_type          = cp_fa_cal_type
          AND base.ci_sequence_number   = cp_fa_sequence_number;
    l_c_base_id                               c_base_id%ROWTYPE;

  BEGIN
    OPEN c_base_id (
            cp_person_id                => p_person_id,
            cp_fa_cal_type              => p_fa_cal_type,
            cp_fa_sequence_number       => p_fa_sequence_number
            );
    FETCH c_base_id INTO l_c_base_id;
    CLOSE c_base_id ;
    RETURN l_c_base_id.base_id;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_base_id_for_person;

  PROCEDURE log_to_fnd ( p_v_module       IN VARCHAR2,
                         p_v_log_category IN VARCHAR2,
                         p_v_string       IN VARCHAR2 ) AS
  ------------------------------------------------------------------
  --Created by  : bvisvana, Oracle IDC
  --Date created: 22 May 2006
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ------------------------------------------------------------------
  BEGIN
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_gen_004.'||p_v_module||'.'||p_v_log_category, p_v_string);
    END IF;
  END log_to_fnd;


   FUNCTION get_person_id RETURN person_id_array PIPELINED IS
  ------------------------------------------------------------------
  --Created by  : bvisvana, Oracle IDC
  --Date created: 22 May 2006
  --Known limitations/enhancements and/or remarks:
  --Purpose : This is a pipelined function. The person id are collected in temp_person_id_array and
  --          this temp_person_id_array is transferred into person_id_array through this pipelined function
  --          Using pipelined function you could treat the data in a PLSQL table as a normal table.
  --          You could make a query on those PLSQL similar to a database table.
  --Change History:
  --Who         When            What
  ------------------------------------------------------------------
   BEGIN
    log_to_fnd('get_person_id','debug','Inside the pipelined function -  get_person_id');
    FOR i IN 1..temp_person_id_array.COUNT LOOP
      pipe row(temp_person_id_array(i));
    END LOOP;
    log_to_fnd('get_person_id','debug','Before RETRUN from the pipelined function - get_person_id');
    RETURN;
   END get_person_id;

   PROCEDURE build_sql_stmt (
      p_award_year     IN       VARCHAR2,
      p_sys_ltr_code   IN       VARCHAR2,
      p_select_type    IN       VARCHAR2,
      p_sql_stmt       OUT NOCOPY      VARCHAR2
   ) IS

    l_award_year igf_ap_mis_itms_ltr_v.award_year%TYPE;
   BEGIN

  /*************************************************************
  Created By :Prajeesh
  Date Created on : 05-Feb-2002
  Purpose : This Procedure will accept person id and award year with
            system letter code and select type as input parameter
      and return the select clause to the main procedure
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pkpatel         5-May-2003      Bug 2941138
                                  Modified to use Bind variable
  kumma           7-JUN-2003      2853531, Modified for adding the dynamic and static group functionality for financial aid system letter
  pkpatel         19-AUG-2003     Bug 3104422 passed the Award year as per the system letter, since the underlying views have been modified.
  bvisvana        22-May-2006     Bug 3724328 - For Code refactoring (Issue with huge person id groups).
                                  Removed the p_person_id parameter from the build_sql_stm call and
                                  procedure since the person id are stored in PLSQL table (and treated as PIPELINED function)
  (reverse chronological order - newest change first)
  ***************************************************************/
    fnd_dsql.init;
    fnd_dsql.add_text(' SELECT distinct email_address,person_id,award_year FROM ');

    IF p_sys_ltr_code IN ('FAMISTM','FADISBT') THEN
      l_award_year := igf_gr_gen.get_calendar_desc( RTRIM(SUBSTR(p_award_year,1,10)), TO_NUMBER(RTRIM(SUBSTR(p_award_year,11))));
    ELSE
      l_award_year := p_award_year;
    END IF;

    -- bvisvana - bug 3724328 - For Code refactoring (Issue with huge person id groups)
    -- See the use of pipelined function igf_aw_gen_004.get_person_id();
    log_to_fnd('build_sql_stmt','debug','IT IS LETTER CODE of type '||p_sys_ltr_code||' with select type as '||p_select_type||' and award year = '||l_award_year);
    IF p_sys_ltr_code IN ('FAAWARD', 'FAMISTM','FADISBT') THEN
      IF p_select_type IN ('S','G','A','L') THEN
        IF p_sys_ltr_code='FAAWARD' THEN
          fnd_dsql.add_text(' IGF_AW_PER_LIST_V WHERE person_id IN (select column_value from table(igf_aw_gen_004.get_person_id())');
          fnd_dsql.add_text(') AND award_year =');
          fnd_dsql.add_bind(l_award_year);
        ELSIF p_sys_ltr_code='FAMISTM' THEN
          fnd_dsql.add_text(' IGF_AP_MIS_ITMS_LTR_V WHERE person_id IN (select column_value from table(igf_aw_gen_004.get_person_id())');
          fnd_dsql.add_text(') AND award_year =');
          fnd_dsql.add_bind(l_award_year);
        ELSIF p_sys_ltr_code='FADISBT' THEN
          fnd_dsql.add_text(' IGF_SL_DISB_LTR_V WHERE person_id IN (select column_value from table(igf_aw_gen_004.get_person_id())');
          fnd_dsql.add_text(') AND award_year =');
          fnd_dsql.add_bind(l_award_year);
        END IF;
      END IF;
    END IF;

     p_sql_stmt := fnd_dsql.get_text(FALSE);
     log_to_fnd('build_sql_stmt','debug','SQL Stmt got from build_sql_stmt is '||p_sql_stmt);
   END build_sql_stmt;

   FUNCTION efc_i(
                  l_base_id IN igf_ap_fa_base_rec_all.base_id%TYPE,
                  p_awd_prd_code IN igf_aw_awd_prd_term.award_prd_cd%TYPE
                 ) RETURN NUMBER AS
   ------------------------------------------------------------------
   --Created by  : veramach, Oracle India
   --Date created: 06-OCT-2003
   --
   --Purpose:
   --   Calculate IM EFC.
   --
   --Known limitations/enhancements and/or remarks:
   --
   --Change History:
   --Who         When            What
   -------------------------------------------------------------------

  -- Get the details of EFC
  CURSOR  c_im_efc(
                    cp_base_id igf_aw_award_all.base_id%TYPE
                  ) IS
    SELECT coa_duration_num,
           coa_duration_efc_amt
      FROM igf_ap_css_profile_all
     WHERE active_profile = 'Y'
       AND base_id        = cp_base_id;

  l_im_efc         c_im_efc%ROWTYPE;
  l_im_efc_amt     igf_ap_css_profile_all.coa_duration_efc_amt%TYPE := NULL;

  BEGIN
    IF p_awd_prd_code IS NULL THEN
      OPEN c_im_efc(l_base_id);
      FETCH c_im_efc into l_im_efc;
      IF c_im_efc%FOUND THEN

        IF l_im_efc.coa_duration_num IS NULL THEN
          --im efc is not calculated. SO, defaulting im efc to zero
          CLOSE c_im_efc;
          l_im_efc_amt := 0;
        ELSE
          CLOSE c_im_efc;
          --im efc is calculated.
          l_im_efc_amt := l_im_efc.coa_duration_efc_amt;
        END IF;
      ELSE
        RETURN NULL;
      END IF;
    ELSE
      l_im_efc_amt := igf_ap_uhk_inas_pkg.efc_i_award_prd(l_base_id,p_awd_prd_code);
    END IF;
    RETURN l_im_efc_amt;

  END efc_i;


  -- ADDED BY GMURALID FOR BUG 2737925 ON 8-JAN-2003

   FUNCTION efc_f(
                  l_base_id IN NUMBER,
                  p_awd_prd_code IN igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL
                  )
   RETURN NUMBER
   IS
  /*************************************************************
  Created By : Gautam S.M
  Date Created on : 08-JAN-2003
  Purpose : The function is used for obtaining the efc for a given base id
  Change History
  Who             When            What
  veramach        11-Oct-2004     FA152 Changes to bring in awarding period setup
  veramach        08-Apr-2004     bug 3547237
                                  Added a check that if auto_zero_efc is set to 'Y' in the active_isir,
                                  then EFC returned must be zero
  adhawan         11-feb-2003     Select the efc from the Active isir instead of the payment isir
  2758804                         Modified the c_efc for it .
--rasahoo         05-Aug-2003    #3024112 Changed the parameters in call igf_ap_efc_calc.get_efc_no_of_months
--
  (reverse chronological order - newest change first)
  ***************************************************************/

       CURSOR c_efc(cp_base_id       igf_ap_fa_base_rec_all.base_id%TYPE,
                    cp_months        NUMBER)
       IS
       SELECT DECODE(f.award_fmly_contribution_type,
                      2, DECODE(cp_months, 1 ,isir.sec_alternate_month_1,
                                           2 , isir.sec_alternate_month_2,
                                           3 , isir.sec_alternate_month_3,
                                           4 , isir.sec_alternate_month_4,
                                           5 , isir.sec_alternate_month_5,
                                           6 , isir.sec_alternate_month_6,
                                           7 , isir.sec_alternate_month_7,
                                           8 , isir.sec_alternate_month_8,
                                           9 , isir.secondary_efc,
                                           10, isir.sec_alternate_month_10,
                                           11, isir.sec_alternate_month_11,
                                           12, isir.sec_alternate_month_12),
                         DECODE(cp_months, 1 , isir.primary_alternate_month_1,
                                           2 , isir.primary_alternate_month_2,
                                           3 , isir.primary_alternate_month_3,
                                           4 , isir.primary_alternate_month_4,
                                           5 , isir.primary_alternate_month_5,
                                           6 , isir.primary_alternate_month_6,
                                           7 , isir.primary_alternate_month_7,
                                           8 , isir.primary_alternate_month_8,
                                           9 , isir.primary_efc,
                                           10, isir.primary_alternate_month_10,
                                           11, isir.primary_alternate_month_11,
                                           12, isir.primary_alternate_month_12)
             ) efc,
             isir.primary_efc primary_efc,
             NVL(isir.auto_zero_efc,'N') auto_zero_efc
        FROM igf_ap_isir_matched isir,
             igf_ap_fa_base_rec_all f
       WHERE isir.base_id = cp_base_id
         AND isir.base_id = f.base_id
         AND isir.active_isir='Y';


        l_efc_months         NUMBER ;
        l_efc_rec            c_efc%ROWTYPE ;
        l_awdprd_startdt     DATE;


     CURSOR get_round_off(
                          cp_base_id igf_ap_fa_base_rec.base_id%TYPE
                         ) IS
       SELECT num_days_divisor,
              roundoff_fact
         FROM igf_ap_efc_v efc,
              igf_ap_fa_base_rec_all  fabase
        WHERE efc.ci_cal_type        = fabase.ci_cal_type
          AND efc.ci_sequence_number = fabase.ci_sequence_number
          AND fabase.base_id         = cp_base_id;
     lv_round_off_rec get_round_off%ROWTYPE;

     l_ap_months NUMBER;
     l_ap_start_dt DATE;
     l_ap_end_dt DATE;

     l_ay_months NUMBER;
     l_ay_start_dt DATE;
     l_ay_end_dt DATE;
     l_ap_efc  NUMBER;
     l_tot_efc NUMBER;
     l_tot_months NUMBER;
     l_prior_months NUMBER;
     l_pre_ap_efc NUMBER;

       BEGIN

         IF p_awd_prd_code IS NULL THEN
           l_efc_months := igf_aw_coa_gen.coa_duration(l_base_id,p_awd_prd_code ) ;
           IF l_efc_months >12 OR l_efc_months < 0 THEN
               l_efc_months := 12 ;
           END IF ;
           IF l_efc_months IS NULL OR l_efc_months =0 THEN
             RETURN NULL;
           END IF;
           -- get EFC value for Fed Methodology
           OPEN  c_efc (l_base_id,l_efc_months) ;
           FETCH c_efc INTO l_efc_rec ;
           CLOSE c_efc ;

           IF l_efc_rec.primary_efc = 0 AND l_efc_rec.auto_zero_efc = 'Y' THEN
             RETURN 0;
           ELSE
             RETURN l_efc_rec.efc ;
           END IF;

         ELSE
           -- Step1: months spanning the Award Period where the studend has COA.
           -- start/end date of the award period
           igf_aw_coa_gen.get_coa_months(
                                         p_base_id      => l_base_id,
                                         p_awd_prd_code => p_awd_prd_code,
                                         p_start_dt     => l_ap_start_dt,
                                         p_end_dt       => l_ap_end_dt,
                                         p_coa_months   => l_ap_months
                                        );

           -- Step2: months spanning the Award Year where the studend has COA.
           -- start/end date of the Award Year
           igf_aw_coa_gen.get_coa_months(
                                         p_base_id      => l_base_id,
                                         p_awd_prd_code => NULL,
                                         p_start_dt     => l_ay_start_dt,
                                         p_end_dt       => l_ay_end_dt,
                                         p_coa_months   => l_ay_months
                                        );

           -- Step3: Determine if this is the First AP in the AY
           -- Get the nth month cumulative EFC and return
           OPEN  c_efc(l_base_id,l_ap_months);
           FETCH c_efc INTO l_efc_rec;
           CLOSE c_efc;

           IF l_efc_rec.primary_efc = 0 AND l_efc_rec.auto_zero_efc = 'Y' THEN
             l_ap_efc :=  0;
           ELSE
             l_ap_efc := l_efc_rec.efc;
           END IF;

           IF l_ap_start_dt = l_ay_start_dt THEN
             RETURN l_ap_efc;
           END IF;

           -- Step4 : This is not the first Awarding Period.
           OPEN get_round_off(l_base_id);
           FETCH get_round_off INTO lv_round_off_rec;
           CLOSE get_round_off;

           l_tot_months := (l_ap_end_dt - l_ay_start_dt) / NVL(lv_round_off_rec.num_days_divisor,30);

           IF (lv_round_off_rec.roundoff_fact = 'RU') THEN
             -- Round up to the nearest whole number
             l_tot_months := CEIL( l_tot_months );
           ELSIF (lv_round_off_rec.roundoff_fact = 'RD' ) THEN
             -- Round down to the nearest whole number
             l_tot_months := FLOOR( l_tot_months );
           ELSE
             -- Round off factor is 'RH', Round to the nearest whole number
             l_tot_months := ROUND( l_tot_months );
           END IF;

           -- Step6: Get the months prior to the start of the AP
           l_prior_months := (l_ap_start_dt - l_ay_start_dt) / NVL(lv_round_off_rec.num_days_divisor,30);

           IF (lv_round_off_rec.roundoff_fact = 'RU') THEN
             -- Round up to the nearest whole number
             l_prior_months := CEIL( l_prior_months );
           ELSIF (lv_round_off_rec.roundoff_fact = 'RD' ) THEN
             -- Round down to the nearest whole number
             l_prior_months := FLOOR( l_prior_months );
           ELSE
             -- Round off factor is 'RH', Round to the nearest whole number
             l_prior_months := ROUND( l_prior_months );
           END IF;

           -- get the total cumulative EFC.
           OPEN  c_efc (l_base_id,(LEAST(NVL(l_tot_months,0) ,12) ));
           FETCH c_efc INTO l_efc_rec;
           l_tot_efc := l_efc_rec.efc;
           CLOSE c_efc ;

           -- get the total months ap months prior to start of AP EFC.
           OPEN  c_efc (l_base_id,(LEAST( NVL(l_tot_months,0) - NVL(l_prior_months,0) ,12) ));
           FETCH c_efc INTO l_efc_rec;
           l_pre_ap_efc := l_efc_rec.efc;
           CLOSE c_efc ;

           RETURN (NVL(l_tot_efc,0) - NVL(l_pre_ap_efc,0));
         END IF;

      EXCEPTION
        WHEN OTHERS THEN
          RETURN NULL;
    END efc_f;

-- ADDED BY GMURALID FOR BUG 2737925 ON 8-JAN-2003

 FUNCTION unmetneed_f(
                      l_base_id IN NUMBER,
                      p_awd_prd_code IN igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL
                     ) RETURN NUMBER IS
 /*************************************************************
  Created By : Gautam S.M
  Date Created on : 0*-JAN-2003
  Purpose : The function is used for obtaining the unmet need for a given base id
  Change History
  Who             When            What
  gmuralid        16-JAN-03       BUG 2737925 included check to see whether award meeting family contribution
                                  is gretaer than efc_f.
  (reverse chronological order - newest change first)
  ***************************************************************/

      l_resource_f NUMBER;
      l_resource_i NUMBER;
      l_unmet_need_f NUMBER;
      l_unmet_need_i NUMBER;
      l_resource_f_fc NUMBER;
      l_resource_i_fc NUMBER;

      BEGIN
         igf_aw_gen_002.get_resource_need(
                                          p_base_id       => l_base_id,
                                          p_resource_f    => l_resource_f,
                                          p_resource_i    => l_resource_i,
                                          p_unmet_need_f  => l_unmet_need_f,
                                          p_unmet_need_i  => l_unmet_need_i,
                                          p_resource_f_fc => l_resource_f_fc,
                                          p_resource_i_fc => l_resource_i_fc,
                                          p_awd_prd_code  => p_awd_prd_code
                                         );

         RETURN l_unmet_need_f;

       EXCEPTION
         WHEN OTHERS THEN
          RETURN NULL;

   END unmetneed_f;

  FUNCTION unmetneed_i(
                       l_base_id IN igf_ap_fa_base_rec_all.base_id%TYPE,
                       p_awd_prd_code IN igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL
                      ) RETURN NUMBER AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 06-SEP-2003
  --
  --Purpose: To calculate unmet need according to institutional methodology
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  l_unmet_need    NUMBER;
  l_resource_f    NUMBER;
  l_resource_i    NUMBER;
  l_unmet_need_f  NUMBER;
  l_unmet_need_i  NUMBER;
  l_resource_f_fc NUMBER;
  l_resource_i_fc NUMBER;

  BEGIN
    igf_aw_gen_002.get_resource_need(
                                     p_base_id       => l_base_id,
                                     p_resource_f    => l_resource_f,
                                     p_resource_i    => l_resource_i,
                                     p_unmet_need_f  => l_unmet_need_f,
                                     p_unmet_need_i  => l_unmet_need_i,
                                     p_resource_f_fc => l_resource_f_fc,
                                     p_resource_i_fc => l_resource_i_fc,
                                     p_awd_prd_code  => p_awd_prd_code
                                    );
    RETURN l_unmet_need_i;
  END unmetneed_i;


  FUNCTION need_f(
                  l_base_id IN NUMBER,
                  p_awd_prd_code IN igf_aw_awd_prd_term.award_prd_cd%TYPE
                 ) RETURN NUMBER IS
  /*************************************************************
  Created By : Gautam S.M
  Date Created on : 08-JAN-2003
  Purpose : The function is used for obtaining the need for a given base id
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

      coa_amt  igf_ap_fa_base_rec_all.coa_f%TYPE;
      need_f   NUMBER;
      l_efc_f  NUMBER;

      BEGIN
        coa_amt := igf_aw_coa_gen.coa_amount(p_base_id => l_base_id,p_awd_prd_code => p_awd_prd_code);
        l_efc_f := igf_aw_gen_004.efc_f(l_base_id => l_base_id,p_awd_prd_code => p_awd_prd_code);
        IF coa_amt > l_efc_f THEN
           need_f := coa_amt - l_efc_f;
        ELSE
           need_f := 0;
        END IF;
        RETURN need_f;

        EXCEPTION
          WHEN OTHERS THEN
            RETURN NULL;
     END need_f;


    FUNCTION need_i(
                    l_base_id IN igf_ap_fa_base_rec_all.base_id%TYPE,
                    p_awd_prd_code IN igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL
                   ) RETURN NUMBER AS
    ------------------------------------------------------------------
    --Created by  : veramach, Oracle India
    --Date created: 06-SEP-2003
    --
    --Purpose: To calculate need according to institutional methodology
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -------------------------------------------------------------------

    coa_amt  igf_ap_fa_base_rec_all.coa_f%TYPE;
    need_i   NUMBER;
    l_efc_i  NUMBER;


    BEGIN
      coa_amt := igf_aw_coa_gen.coa_amount(p_base_id => l_base_id,p_awd_prd_code => p_awd_prd_code);
      l_efc_i := igf_aw_gen_004.efc_i(l_base_id => l_base_id,p_awd_prd_code => p_awd_prd_code);
      IF coa_amt > l_efc_i THEN
         need_i := coa_amt - l_efc_i;
      ELSE
         need_i := 0;
      END IF;
      RETURN need_i;

      EXCEPTION
        WHEN OTHERS THEN
          RETURN NULL;
    END need_i;


  FUNCTION get_headings (
     p_person_id   IN   NUMBER,
     p_param1      IN   VARCHAR2,
     p_param2      IN   VARCHAR2 ,
     p_param3      IN   VARCHAR2 ,
     p_param4      IN   VARCHAR2 ,
     p_param5      IN   VARCHAR2 ,
     p_param6      IN   VARCHAR2 ,
     p_param7      IN   VARCHAR2 ,
     p_flag        IN   VARCHAR2
  )
     RETURN VARCHAR2 IS

   /*************************************************************
  Created By :Prajeesh
  Date Created on : 05-Feb-2002
  Purpose : This Function will get the person id and award year
            load calendards and P-flag as parameter and create
            the header in html format and puts it in the temp
            table. It check if p_flag is 'Y' implies to do
            automatic population then it ignores the load calendars
            and generate the header for all the terms for the person
            with the given award year. If 'N' then it will check
            for the given load calendar and shows only that given
            load calendar
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

     l_term_base_total NUMBER;

     l_header_rec   VARCHAR2(32000);
  BEGIN


    FOR l_c_get_load_cals IN g_c_get_load_cals
        (
          p_person_id,
          ltrim(rtrim(substr(p_param1, 1, 10))),
          to_number(ltrim(rtrim(substr(p_param1, 11)))),
          p_param2
        )
    LOOP                                        -- Get only the alternate codes for load calendars
        l_header_rec := l_header_rec || '<TH>' || l_c_get_load_cals.alternate_code || '</TH>';
    END LOOP;                                   -- END Get only the alternate codes for load calendars

        l_header_rec := l_header_rec || '<TH>Award Total</TH>';
    -- <TH>Award Types</TH>  is there in the select query hence not required here.

--    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
--      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.get_headings.debug.Header',l_header_rec);
--    END IF;

    RETURN l_header_rec;

    EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
   END get_headings;

  FUNCTION get_award_data_wrap (
    p_person_id   IN   NUMBER,
    p_fund_id     IN   VARCHAR2,
    p_param1      IN   VARCHAR2,
    p_param2      IN   VARCHAR2 ,
    p_param3      IN   VARCHAR2 ,
    p_param4      IN   VARCHAR2 ,
    p_param5      IN   VARCHAR2 ,
    p_param6      IN   VARCHAR2 ,
    p_param7      IN   VARCHAR2 ,
    p_flag        IN   VARCHAR2 ,
    p_awd_tot     OUT NOCOPY   NUMBER
  )
      RETURN VARCHAR2 IS

   /*************************************************************
  Created By :Prajeesh
  Date Created on : 05-Feb-2002
  Purpose : This function is used to insert the transaction
            records(disbursement records for the different funds
            in an award year to the given person. It checks if
            p_flag='Y' implies automatic population then it
            gets all the disbursement records for all the terms
            in an given award year.Else if 'N' then it
            generates the records for the given award year
            for different fund codes to the person
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/


    l_fund_found_for_load     BOOLEAN;
    l_fund_total              NUMBER := 0;
    l_data_rec                VARCHAR2(32000);
  BEGIN

    FOR l_c_get_load_cals IN g_c_get_load_cals
        (
          p_person_id,
          ltrim(rtrim(substr(p_param1, 1, 10))),
          to_number(ltrim(rtrim(substr(p_param1, 11)))),
          p_param2
        )
    LOOP                                        -- Get only the alternate codes for load calendars
        l_fund_found_for_load := FALSE;
        FOR l_c_get_details IN g_c_get_details
                (
                  cp_person_id                      => p_person_id,
                  cp_fa_cal_type                    => LTRIM(RTRIM(SUBSTR(p_param1, 1, 10))),
                  cp_fa_sequence_number             => TO_NUMBER(LTRIM(RTRIM(SUBSTR(p_param1, 11)))),
                  cp_ld_cal_type                    => l_c_get_load_cals.cal_type,
                  cp_ld_sequence_number             => l_c_get_load_cals.sequence_number,
                  cp_fund_id                        => p_fund_id,
                  cp_award_prd_cd                   => p_param2
                )
        LOOP                                                -- Iterate for offred amount over terms
          l_data_rec := l_data_rec || '<TD>' || NVL(l_c_get_details.load_total_offered_amt, 0) || '</TD>' ;
          l_fund_total := l_fund_total + NVL(l_c_get_details.load_total_offered_amt, 0);
          l_fund_found_for_load := TRUE;
        END LOOP;                                            -- END Iterate for offred amount over terms
        IF NOT(l_fund_found_for_load) THEN
          l_data_rec := l_data_rec || '<TD>0</TD>' ;
        END IF;
    END LOOP;                                   -- END Get only the alternate codes for load calendars



         --Add the award total
         l_data_rec := l_data_rec || '<TD>' || NVL (TO_CHAR (l_fund_total), '-') || '</TD>';

      p_awd_tot := NVL(l_fund_total,0);

      RETURN l_data_rec;

    EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igf_aw_gen_004.get_award_data_wrap');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
   END get_award_data_wrap;

   FUNCTION get_award_data (
      p_person_id   IN   NUMBER,
      p_fund_id     IN   VARCHAR2,
      p_param1      IN   VARCHAR2,
      p_param2      IN   VARCHAR2 ,
      p_param3      IN   VARCHAR2 ,
      p_param4      IN   VARCHAR2 ,
      p_param5      IN   VARCHAR2 ,
      p_param6      IN   VARCHAR2 ,
      p_param7      IN   VARCHAR2 ,
      p_flag        IN   VARCHAR2

   ) RETURN VARCHAR2 IS

   /*************************************************************
  Created By :Prajeesh
  Date Created on : 05-Feb-2002
  Purpose : This Function is the wrapper for the award data function.
            This function is created mainly to put it in sql statement
            which is inserted INTO the table. As the functions award_data
            wrap has out NOCOPY parameter too thus this wrapper is created to
            remove the out NOCOPY parameter so that it can be used in the
            select clause
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   l_awd_tot NUMBER;
   l_ret_data VARCHAR2(32000);
   BEGIN
           l_ret_data:=get_award_data_wrap ( p_person_id,
                            p_fund_id,
                            p_param1,
                            p_param2,
                            p_param3,
                            p_param4,
                            p_param5,
                            p_param6,
                            p_param7,
                            p_flag,
                            l_awd_tot
                         ) ;

           RETURN l_ret_data;

   EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;

  END get_award_data;


   FUNCTION get_term_total_wrap (
      p_person_id   IN   NUMBER,
      p_param1      IN   VARCHAR2,
      p_param2      IN   VARCHAR2 ,
      p_param3      IN   VARCHAR2 ,
      p_param4      IN   VARCHAR2 ,
      p_param5      IN   VARCHAR2 ,
      p_param6      IN   VARCHAR2 ,
      p_param7      IN   VARCHAR2 ,
      p_flag        IN   VARCHAR2 ,
      p_awd_tot     OUT NOCOPY  NUMBER
      )
      RETURN VARCHAR2 IS

  /*************************************************************
  Created By :Prajeesh
  Date Created on : 05-Feb-2002
  Purpose : This Function gets the total term wise totals and total award total
            If the p_flag='Y' implies automatic population is set implies
            it gets term totals for all the terms for the person in a given award year.
            Else it generates the term total for the given load calendar if
            p_flag='N'
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

     /*Cursor to gethe load calendar details*/

      l_fund_total   NUMBER :=0;
      l_load_total   NUMBER :=0;
      l_data_rec     VARCHAR2 (32000);

   BEGIN

    FOR l_c_get_load_cals IN g_c_get_load_cals
        (
          p_person_id,
          ltrim(rtrim(substr(p_param1, 1, 10))),
          to_number(ltrim(rtrim(substr(p_param1, 11)))),
          p_param2
        )
    LOOP                                        -- Get only the alternate codes for load calendars
      l_load_total := 0;
        FOR l_c_get_details IN g_c_get_details
                (
                  cp_person_id                      => p_person_id,
                  cp_fa_cal_type                    => LTRIM(RTRIM(SUBSTR(p_param1, 1, 10))),
                  cp_fa_sequence_number             => TO_NUMBER(LTRIM(RTRIM(SUBSTR(p_param1, 11)))),
                  cp_ld_cal_type                    => l_c_get_load_cals.cal_type,
                  cp_ld_sequence_number             => l_c_get_load_cals.sequence_number,
                  cp_fund_id                        => NULL,
                  cp_award_prd_cd                   => p_param2
                )
        LOOP                                                -- Iterate for offred amount over terms
          l_load_total := l_load_total +  NVL(l_c_get_details.load_total_offered_amt, 0);
        END LOOP;                                            -- END Iterate for offred amount over terms
        l_data_rec := l_data_rec || '<TD>' || l_load_total || '</TD>' ;
        l_fund_total := l_fund_total + l_load_total;
    END LOOP;                                   -- END Get only the alternate codes for load calendars

         p_awd_tot := NVL(l_fund_total,0);
         l_data_rec :=    l_data_rec
                          || '<TD>' || (l_fund_total) || '<TD>';

      RETURN l_data_rec;

    EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AW_GEN_004.GET_TERM_TOTAL_WRAP');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
   END get_term_total_wrap;

   FUNCTION get_term_total (
      p_person_id   IN   NUMBER,
      p_param1      IN   VARCHAR2,
      p_param2      IN   VARCHAR2 ,
      p_param3      IN   VARCHAR2 ,
      p_param4      IN   VARCHAR2 ,
      p_param5      IN   VARCHAR2 ,
      p_param6      IN   VARCHAR2 ,
      p_param7      IN   VARCHAR2 ,
      p_flag        IN   VARCHAR2

   )
      RETURN VARCHAR2 IS

  /*************************************************************
  Created By :Prajeesh
  Date Created on : 05-Feb-2002
  Purpose :This function is the wrapper for the get_term_total_wrap
           as it return an out NOCOPY variables which cant be used in
           select clause thus a wrapper is created without out NOCOPY
           clause
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   l_ret_data   VARCHAR2(32000);
   l_awd_tot    NUMBER;
   BEGIN
     l_ret_data:=get_term_total_wrap(
                     p_person_id,
                     p_param1,
                     p_param2,
                     p_param3,
                     p_param4,
                     p_param5,
                     p_param6,
                     p_param7,
                     p_flag,
                     l_awd_tot
                  );

     RETURN l_ret_data;

    EXCEPTION
    WHEN OTHERS THEN
     NULL;

   END get_term_total;

  FUNCTION is_inas_integrated RETURN BOOLEAN AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 6-OCT-2003
  --
  --Purpose:
  --   To check if INAS is integrated with the system
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  lv_profile_value   VARCHAR2(10);
  BEGIN
    fnd_profile.get('IGF_AW_INAS_INTEGRATE',lv_profile_value);
    IF lv_profile_value ='Y' THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END is_inas_integrated;

  PROCEDURE award_letter_matrix (
    p_person_id       IN       NUMBER,
    p_param1          IN       VARCHAR2,
    p_param2          IN       VARCHAR2 ,
    p_param3          IN       VARCHAR2 ,
    p_param4          IN       VARCHAR2 ,
    p_param5          IN       VARCHAR2 ,
    p_param6          IN       VARCHAR2 ,
    p_param7          IN       VARCHAR2 ,
    p_flag            IN       VARCHAR2 ,
    p_return_status   OUT NOCOPY      VARCHAR2
  ) IS

  /*************************************************************
  Created By :Prajeesh
  Date Created on : 05-Feb-2002
  Purpose : This is the main award procedure which gets called
            and it inserts the records in temp table for
            the person and award year depending on the values
            in particular format
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
    l_awd_tot       NUMBER DEFAULT 0;
    l_awd_tot_fund  NUMBER DEFAULT -1;

    --Main Cursor for Award Letter to the award details in an given format*/

    CURSOR get_awd_data IS
      SELECT   NULL fund_code,-1 fund_id,
                '<TH>Award Type</TH>' data1,
                igf_aw_gen_004.get_headings (
                   p_person_id,
                   p_param1,
                   p_param2,
                   p_param3,
                   p_param4,
                   p_param5,
                   p_param6,
                   p_param7,
                   p_flag
                ) data2,
                1 seq
       FROM     DUAL
       UNION
       SELECT DISTINCT
          fmast.fund_code, fmast.fund_id, '<TD>' || fmast.description || '</TD>' data1,
          get_award_data (
            p_person_id,
            fmast.fund_id,
            p_param1,
            p_param2,
            p_param3,
            p_param4,
            p_param5,
            p_param6,
            p_param7,
            p_flag
            ) data2,
          2 seq
       FROM
         igf_aw_award_all awd,
         igf_aw_fund_mast fmast,
         igs_ca_inst_all cai,
         igf_aw_awd_disb disb
       WHERE
                        fmast.ci_cal_type             = RTRIM (SUBSTR (p_param1, 1, 10))
         AND            fmast.ci_sequence_number      = TO_NUMBER (RTRIM (SUBSTR (p_param1, 11)))
         AND            awd.base_id                   = igf_aw_gen_004.get_base_id_for_person (p_person_id, RTRIM (SUBSTR (p_param1, 1, 10)), TO_NUMBER (RTRIM (SUBSTR (p_param1, 11))))
         AND            awd.fund_id                   = fmast.fund_id
         AND            awd.award_status              IN ('ACCEPTED', 'OFFERED')
--         AND            awd.notification_status_code  IN ('R', 'F')
         AND            awd.award_id                  = disb.award_id
         AND            cai.cal_type                  = disb.ld_cal_type
         AND            cai.sequence_number           = disb.ld_sequence_number
         AND            NVL (awd.offered_amt, 0) > 0
         AND
         NOT EXISTS
           (SELECT disb.ld_cal_type, disb.ld_sequence_number
           FROM igf_aw_awd_disb disb
           WHERE
             disb.award_id = awd.award_id
           MINUS
           SELECT ld_cal_type, ld_sequence_number
           FROM igf_aw_awd_prd_term apt
           WHERE          apt.ci_cal_type               = RTRIM (SUBSTR (p_param1, 1, 10))
                  AND     apt.ci_sequence_number        = TO_NUMBER (RTRIM (SUBSTR (p_param1, 11)))
                  AND     apt.award_prd_cd              = NVL(p_param2, award_prd_cd))
         UNION
         SELECT   NULL fund_code,-1 fund_id,
                  '<TD>Term Total</TD>' data1,
                  igf_aw_gen_004.get_term_total (
                     p_person_id,
                     p_param1,
                     p_param2,
                     p_param3,
                     p_param4,
                     p_param5,
                     p_param6,
                     p_param7,
                     p_flag
                  ) data2,
                  3 seq
         FROM     DUAL
         ORDER BY seq;

      /*get the rowid for the person in temp table for deletion*/
      CURSOR get_pers_del IS
             SELECT lttmp.rowid row_id FROM
             igf_aw_awd_ltr_tmp lttmp
             WHERE
             person_id            = p_person_id AND
             ci_cal_type          = RTRIM (SUBSTR (p_param1, 1, 10)) AND
             ci_sequence_number   = TO_NUMBER (RTRIM (SUBSTR (p_param1, 11)));

      l_get_pers_del    get_pers_del%ROWTYPE;


      l_fund_code       VARCHAR2 (30);
      l_fund_desc       VARCHAR2 (80);
      i                 NUMBER;
      l_return_status   VARCHAR2 (1)   ;
      l_message         VARCHAR2 (512);
      l_awd_count       NUMBER;
      l_ret_data        VARCHAR2(32000);
      l_rowid           ROWID;
   BEGIN
      l_return_status := 'S';

       --First delete the existing record for the person in temp table
      OPEN get_pers_del;
      LOOP
      FETCH get_pers_del INTO l_get_pers_del;
      EXIT WHEN get_pers_del%NOTFOUND;

        igf_aw_awd_ltr_tmp_pkg.delete_row (
                                           x_rowid      => l_get_pers_del.row_id
                                          );
      END LOOP;
      CLOSE get_pers_del;

      FOR get_award_data_rec IN get_awd_data
      LOOP
        igf_aw_awd_ltr_tmp_pkg.insert_row (
                             x_rowid                     =>  l_rowid,
                             x_line_id                   =>  get_awd_data%ROWCOUNT,
                             x_person_id                 =>  p_person_id,
                             x_fund_code                 =>  get_award_data_rec.fund_code,
                             x_fund_description          =>  get_award_data_rec.data1,
                             x_award_name                =>  get_award_data_rec.data1,
                             x_ci_cal_type               =>  RTRIM (SUBSTR (p_param1,1,10)),
                             x_ci_sequence_number        =>  TO_NUMBER (RTRIM (SUBSTR (p_param1,11))),
                             x_award_total               =>  l_awd_tot,
                             x_term_amount_text          =>  get_award_data_rec.data2,
                             x_mode                      =>  'R'
                             );
      END LOOP;

    p_return_status := l_return_status;




   EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igf_aw_gen_004.award_letter_matrix' || SQLERRM);
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
   END award_letter_matrix;

   PROCEDURE corp_pre_process (
      p_document_id    IN       NUMBER ,
      p_select_type    IN       VARCHAR2 ,
      p_sys_ltr_code   IN       VARCHAR2 ,
      p_person_id      IN       NUMBER ,
      p_list_id        IN       NUMBER ,
      p_letter_type    IN       VARCHAR2 ,
      p_parameter_1    IN       VARCHAR2 ,
      p_parameter_2    IN       VARCHAR2 ,
      p_parameter_3    IN       VARCHAR2 ,
      p_parameter_4    IN       VARCHAR2 ,
      p_parameter_5    IN       VARCHAR2 ,
      p_parameter_6    IN       VARCHAR2 ,
      p_parameter_7    IN       VARCHAR2 ,
      p_parameter_8    IN       VARCHAR2 ,
      p_parameter_9    IN       VARCHAR2 ,
      p_flag           IN       VARCHAR2 ,
      p_sql_stmt       OUT NOCOPY      VARCHAR2,
      p_exception      OUT NOCOPY      VARCHAR2
   ) IS

   /*************************************************************
  Created By :Prajeesh
  Date Created on : 05-Feb-2002
  Purpose : This Procedure is the main procedure for pre processing
            for both missing items letter and award processing.
            It gets the valid persons after pre processing and
            generates the sql statement with the valid persons and
            this select statement is sent to the main concurrent
            manager called procedure
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ridas           07-Feb-2006     Bug #5021084. Replaced function IGS_GET_DYNAMIC_SQL with GET_DYNAMIC_SQL.
  rajagupt        05-Oct-2005     Bug#4644213 - Award Notification Letter. Return if p_person_id is NULL and p_select_type is 'S'
                                  and if p_list_id is NULL and p_select_type is "G".
  bvisvana        04-Sep-2005     FA 157 - Bug # 4382371 - Award Notification Letter.
                                  Make a return without forming the sql stmt if the person_id = '-9999999'
  veramach        15-Apr-2004     bug 3543089
                                  Changed sizes of variables to allow more person_ids to be processed.
                                  Also added a error message in the EXCEPTION section
  masehgal        14-Jun-2002     # 2413695  Changed message to
                                  'IGF','IGF_AW_NO_LIST'
  kumma           7-JUN-2003      2853531, Modified for adding the dynamic and static group functionality for financial aid system letter
                                  Removed the cursor c_query that was fetching query from jtf_fm_queries_all , instead make a call to IGS_CO_API.get_list_query
  asbala          19-AUG-2003     3098262:Added check to select only active members for static person_id group
  (reverse chronological order - newest change first)
  ***************************************************************/

      CURSOR c_map IS
           SELECT document_id,name
           FROM igs_co_mapping_v
           WHERE map_id=p_list_id;

     CURSOR c_att_id(cp_itm_id ibc_citems_v.citem_id%TYPE) IS
          SELECT attach_fid
    FROM ibc_citems_v
    WHERE CITEM_ID = cp_itm_id;

     --Cursor to check that if p_list_id represents a static or a dynamic person id group
     CURSOR c_file_name IS
          SELECT file_name
    FROM igs_pe_persid_group_all
    WHERE group_id = p_list_id;  --Here p_List id is representing group_id for Financial Aid System Letter




      l_return_status   VARCHAR2 (1);
      l_file_name       igs_pe_persid_group_all.file_name%TYPE;
      lv_ret_sql        VARCHAR2(32767);
      lv_status         VARCHAR2(1);
      lv_count          NUMBER;
      lv_data           VARCHAR2(500);

      l_static_group    VARCHAR2(1) ;

      TYPE cur_query IS REF CURSOR;

      l_query_desc     cur_query;
      p_person         VARCHAR2(32767);
      l_query_str      VARCHAR2(32767);
      l_person_id      NUMBER;
      l_count          NUMBER  DEFAULT 0;
      l_list_numb      igs_co_mapping.document_id%TYPE;
      l_list_name      igs_co_mapping_v.name%TYPE;
      l_attach_fid     ibc_citems_v.attach_fid%TYPE;
      l_query_text     VARCHAR2(32767);
      lv_sql_code      NUMBER;
      lv_group_type    igs_pe_persid_group_v.group_type%TYPE;

   BEGIN

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.corp_pre_process.debug','Document Name                                   '|| NVL(p_document_id , -99));
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.corp_pre_process.debug','Selection Criteria                              '|| NVL(p_select_type , 'NULL'));
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.corp_pre_process.debug','derived Letter Code -> FAAWARD/FAMISTM/FADISBT  '|| NVL(p_sys_ltr_code, 'NULL'));
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.corp_pre_process.debug','Person ID                                       '|| NVL(p_person_id   , -99));
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.corp_pre_process.debug','List Name -> Person ID Group                    '|| NVL(p_list_id     , -99));
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.corp_pre_process.debug','derived Letter Code -> FAAWARD/FAMISTM/FADISBT  '|| NVL(p_letter_type , 'NULL'));
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.corp_pre_process.debug','Award Year                                      '|| NVL(p_parameter_1 , 'NULL'));
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.corp_pre_process.debug','Awarding period                                 '|| NVL(p_parameter_2 , 'NULL'));
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.corp_pre_process.debug','p_parameter_3                                   '|| NVL(p_parameter_3 , 'NULL'));
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.corp_pre_process.debug','p_parameter_3                                   '|| NVL(p_parameter_4 , 'NULL'));
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.corp_pre_process.debug','p_parameter_3                                   '|| NVL(p_parameter_5 , 'NULL'));
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.corp_pre_process.debug','p_parameter_3                                   '|| NVL(p_parameter_6 , 'NULL'));
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.corp_pre_process.debug','p_parameter_3                                   '|| NVL(p_parameter_7 , 'NULL'));
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.corp_pre_process.debug','Not Used                                        '|| NVL(p_parameter_8 , 'NULL'));
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.corp_pre_process.debug','Not Used                                        '|| NVL(p_parameter_9 , 'NULL'));
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.corp_pre_process.debug','Override Flag                                   '|| NVL(p_flag        , 'NULL'));
      END IF;

      l_static_group    := 'Y';

      IF p_sys_ltr_code = 'FAAWARD' THEN                                  -- Process FAAWARD Letter
        p_person := '-9999999' ;
        IF p_select_type = 'S'    THEN                                -- Select Type - S-Person/G-Group/A-Auto select
          IF p_person_id IS NULL THEN
            fnd_message.set_name('IGF','IGF_AW_NOTI_LTR_NO_PERS_NUM');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
            p_exception := 'Y';
            RETURN;
          END IF;
          OPEN l_query_desc FOR select DISTINCT p_person_id person_id FROM DUAL;
        ELSIF  p_select_type = 'G'    THEN                                -- Select Type - S-Person/G-Group/A-Auto select
          IF p_list_id IS NULL THEN
            fnd_message.set_name('IGF','IGF_AW_NOTI_LTR_NO_PERS_GRP');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
            p_exception := 'Y';
            RETURN;
          END IF;

          --Bug #5021084. Replaced function IGS_GET_DYNAMIC_SQL with GET_DYNAMIC_SQL
	        l_query_str := igs_pe_dynamic_persid_group.get_dynamic_sql(p_list_id ,lv_status,lv_group_type);

          IF lv_status <> 'S' THEN
            FND_MESSAGE.SET_NAME('IGF','IGF_AW_NO_QUERY');
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            p_exception := 'Y';
            RETURN;
          END IF;

          --Bug #5021084. Passing Group ID if the group type is STATIC.
          IF lv_group_type = 'STATIC' THEN
            OPEN l_query_desc FOR l_query_str USING p_list_id;              --Here p_list id is representing group_id for Financial Aid System Letter
          ELSIF lv_group_type = 'DYNAMIC' THEN
            OPEN l_query_desc FOR l_query_str;
          END IF;

        ELSIF p_select_type = 'A'     THEN                                -- Select Type - S-Person/G-Group/A-Auto select
          -- select all students who have any award in ready to send state.
          OPEN l_query_desc FOR
                                  SELECT
                                      DISTINCT  base.person_id
                                  FROM
                                    igf_aw_award_all awd,
                                    igf_aw_fund_mast fmast,
                                    igs_ca_inst_all cai,
                                    igf_aw_awd_disb disb,
                                    igf_ap_fa_base_rec_all base
                                  WHERE
                                    fmast.ci_cal_type             = LTRIM(RTRIM(SUBSTR(p_parameter_1, 1, 10))) AND
                                    fmast.ci_sequence_number      = TO_NUMBER(LTRIM(RTRIM(SUBSTR(p_parameter_1, 11)))) AND
                                    awd.base_id                   = base.base_id AND
                                    awd.fund_id                   = fmast.fund_id AND
                                    awd.award_status              IN ('ACCEPTED', 'OFFERED') AND
                                    awd.notification_status_code  IN ('R', 'F') AND
                                    awd.award_id                  = disb.award_id AND
                                    cai.cal_type                  = disb.ld_cal_type AND
                                    cai.sequence_number           = disb.ld_sequence_number
                                    AND
                                    NOT EXISTS
                                      (SELECT disb.ld_cal_type, disb.ld_sequence_number
                                      FROM igf_aw_awd_disb disb
                                      WHERE
                                        disb.award_id = awd.award_id
                                      MINUS
                                      SELECT ld_cal_type, ld_sequence_number
                                      FROM igf_aw_awd_prd_term apt
                                      WHERE apt.ci_cal_type = LTRIM(RTRIM(SUBSTR(p_parameter_1, 1, 10))) AND
                                        apt.ci_sequence_number = TO_NUMBER(LTRIM(RTRIM(SUBSTR(p_parameter_1, 11)))) AND
                                        apt.award_prd_cd = NVL(p_parameter_2, award_prd_cd));
        END IF;                                                           -- END Select Type - S-Person/G-Group/A-Auto select
        l_count := 0;     -- bvisvana - bug 3724328 - For Code refactoring (Issue with huge person id groups)
        LOOP                                                              -- Process all selected students for award letter creation and update their state as well.
        FETCH l_query_desc INTO l_person_id;
        EXIT WHEN l_query_desc%NOTFOUND;

          award_letter_matrix (
                                l_person_id,
                                p_parameter_1,
                                p_parameter_2,
                                p_parameter_3,
                                p_parameter_4,
                                p_parameter_5,
                                p_parameter_6,
                                p_parameter_7,
                                p_flag,
                                l_return_status
                              );
          IF l_return_status = 'S' THEN
               -- bvisvana - bug 3724328 - For Code refactoring (Issue with huge person id groups)
              -- p_person := p_person || ', ' || l_person_id;
              l_count := l_count + 1;
              temp_person_id_array(l_count) := l_person_id;
          END IF;
        END LOOP;                                                         -- END Process all selected students for award letter creation and update their state as well.
        CLOSE l_query_desc;

        -- bvisvana - bug 3724328 - For Code refactoring (Issue with huge person id groups).Removed the check for '-9999999',instead checked for l_count > 0
        --FA 157 - Award Notification Letter. Added the below IF condition.
        -- If there are no persons, then the query wouldn't have any data for the personn_id IN () clause or person_id clause.
        -- We RETURN so that in the calling program the 'sql_stmt is NOT NULL' check handles that and prints a message instead
        IF l_count = 0 THEN
          log_to_fnd('corp_pre_process','debug','No person available to process request. So returning.');
          RETURN;
        END IF;
        log_to_fnd('corp_pre_process','debug','Calling build_sql_stmt..This is for FAAWARD.');
        build_sql_stmt (
                          p_parameter_1,
                          p_sys_ltr_code,
                          p_select_type,
                          p_sql_stmt
                          );
        log_to_fnd('corp_pre_process','debug','After build_sql_stmt. Before return to the Pre processing method of IGSCO21B.pls ');
        RETURN;
      END IF;                                                             -- END Process FAAWARD Letter

      l_count := 0;
      IF p_select_type = 'S'
      THEN
         IF p_sys_ltr_code = 'FAMISTM'
         THEN
            missing_items (p_person_id, p_parameter_1, l_return_status);

            IF l_return_status = 'S'
            THEN
                -- bvisvana - bug 3724328 - For Code refactoring (Issue with huge person id groups)
                l_count := l_count + 1;
                temp_person_id_array(l_count) := p_person_id;

               build_sql_stmt (
                  p_parameter_1,
                  p_sys_ltr_code,
                  p_select_type,
                  p_sql_stmt
               );
            END IF;

         ELSIF p_sys_ltr_code = 'FADISBT' THEN
           -- bvisvana - bug 3724328 - For Code refactoring (Issue with huge person id groups)
           l_count := l_count + 1;
           temp_person_id_array(l_count) := p_person_id;

           build_sql_stmt (
                  p_parameter_1,
                  p_sys_ltr_code,
                  p_select_type,
                  p_sql_stmt
               );
         END IF;
      ELSIF p_select_type = 'L' THEN
         OPEN c_map;
         FETCH c_map INTO l_list_numb,l_list_name;
         CLOSE c_map;

   OPEN c_att_id(l_list_numb);
         FETCH c_att_id INTO l_attach_fid;
         CLOSE c_att_id;

   IF c_att_id%NOTFOUND OR l_attach_fid IS NULL THEN
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_NO_LIST');
        FND_MESSAGE.SET_TOKEN('LIST', l_list_name);
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        p_exception := 'Y';
        RETURN;
   END IF;

    --fetching query
    IGS_CO_GEN_004.get_list_query(l_attach_fid,l_query_text);

      IF p_flag='N' AND p_sys_ltr_code = 'FAAWARD' THEN
         IF p_parameter_2 IS NULL  THEN
      FND_MESSAGE.SET_NAME('IGF','IGF_AW_SF_PARAM_ERR_DTL');--Bug ID 2539299
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      p_exception := 'Y';
      RETURN;
          END IF;
       END IF;

     IF l_query_text IS NULL
     THEN
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_NO_LIST');
        FND_MESSAGE.SET_TOKEN('LIST', l_list_name);
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        p_exception := 'Y';
        RETURN;
     END IF;

     l_query_str :=    'SELECT distinct person_id FROM '
        || '('
        || l_query_text
        || ')';

     OPEN l_query_desc FOR l_query_str;
     l_count := 0; -- bvisvana - bug 3724328 - For Code refactoring (Issue with huge person id groups)
     LOOP
        FETCH l_query_desc INTO l_person_id;

        EXIT WHEN l_query_desc%NOTFOUND;

        IF p_sys_ltr_code = 'FAAWARD'
        THEN
           award_letter_matrix (
        l_person_id,
        p_parameter_1,
        p_parameter_2,
        p_parameter_3,
        p_parameter_4,
        p_parameter_5,
        p_parameter_6,
        p_parameter_7,
        p_flag,
        l_return_status
           );
        ELSIF p_sys_ltr_code = 'FAMISTM'
        THEN
           missing_items (l_person_id, p_parameter_1, l_return_status);

        ELSIF p_sys_ltr_code = 'FADISBT'
        THEN
      l_return_status := 'S';
        END IF;

        IF l_return_status = 'S'
        THEN
           l_count :=   l_count + 1;

           /*IF l_count = 1 THEN
            p_person := l_person_id;
           ELSE
            p_person :=    p_person
              || ','
              || l_person_id;
           END IF;*/
           temp_person_id_array(l_count) := l_person_id;
        END IF;
     END LOOP;
     CLOSE l_query_desc;

    -- bvisvana - bug 3724328 - For Code refactoring (Issue with huge person id groups)
    IF l_count > 0 THEN
    -- IF p_person IS NOT NULL THEN
     log_to_fnd('corp_pre_process','debug','select type = L ..Calling build_sql_stmt');
     build_sql_stmt (
        p_parameter_1,
        p_sys_ltr_code,
        p_select_type,
        p_sql_stmt
     );
          END IF;

/*===============================================================================*/
     --Logic for Person Id Group
      ELSIF p_select_type = 'G' THEN

    IF p_list_id IS NULL OR p_person_id IS NOT NULL THEN
    FND_MESSAGE.SET_NAME('IGF','IGF_AW_WRNG_PRAM_PG_ID');
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    p_exception := 'Y';
          RETURN;
    END IF;



          OPEN c_file_name;
    FETCH c_file_name INTO l_file_name;
    CLOSE c_file_name;

    IF l_file_name IS NOT NULL THEN
       --Dynamic Person Id Group
       l_static_group := 'N';
       --igs_pe_dynamic_persid_group.igs_get_dynamic_sql(p_list_id ,l_query_str,lv_status,lv_count,lv_data);

       --Bug #5021084. Replaced function IGS_GET_DYNAMIC_SQL with GET_DYNAMIC_SQL
       lv_group_type := NULL;
       l_query_str := igs_pe_dynamic_persid_group.get_dynamic_sql(p_list_id ,lv_status,lv_group_type);

       IF lv_status <> 'S' THEN
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_NO_QUERY');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        p_exception := 'Y';
        RETURN;
       END IF;
    ELSE
    l_static_group := 'Y';
         -- Static Person Id Group
         l_query_str := ' SELECT  distinct  person_id FROM   igs_pe_prsid_grp_mem_all WHERE  group_id = :l_group_id AND sysdate BETWEEN start_date AND NVL(end_date,sysdate)';
    END IF;


    IF p_flag='N' AND p_sys_ltr_code = 'FAAWARD' THEN
      IF p_parameter_2 IS NULL  THEN
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_SF_PARAM_ERR_DTL');--Bug ID 2539299
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        p_exception := 'Y';
        RETURN;
      END IF;
    END IF;

    IF l_static_group  = 'N' THEN
      --Bug #5021084. Passing Group ID if the group type is STATIC.
      IF lv_group_type = 'STATIC' THEN
        OPEN l_query_desc FOR l_query_str USING p_list_id; --Here p_list id is representing group_id
      ELSIF lv_group_type = 'DYNAMIC' THEN
        OPEN l_query_desc FOR l_query_str;
      END IF;
    ELSE
      OPEN l_query_desc FOR l_query_str USING p_list_id;  --Here p_list id is representing group_id for Financial Aid System Letter
    END IF;

    l_count := 0; -- bvisvana - bug 3724328 - For Code refactoring (Issue with huge person id groups)
    LOOP

        FETCH l_query_desc INTO l_person_id;

        EXIT WHEN l_query_desc%NOTFOUND;
        IF p_sys_ltr_code = 'FAAWARD' THEN
             award_letter_matrix (
          l_person_id,
          p_parameter_1,
          p_parameter_2,
          p_parameter_3,
          p_parameter_4,
          p_parameter_5,
          p_parameter_6,
          p_parameter_7,
          p_flag,
          l_return_status
             );
        ELSIF p_sys_ltr_code = 'FAMISTM' THEN
             missing_items (l_person_id, p_parameter_1, l_return_status);
        ELSIF p_sys_ltr_code = 'FADISBT' THEN
      l_return_status := 'S';
        END IF;

        IF l_return_status = 'S' THEN

           l_count :=   l_count  + 1;

           /*IF l_count = 1 THEN
        p_person := l_person_id;
           ELSE
        p_person :=    p_person
              || ','
              || l_person_id;
           END IF;*/
           temp_person_id_array(l_count) := l_person_id;
        END IF;
     END LOOP;
     CLOSE l_query_desc;

    -- bvisvana - bug 3724328 - For Code refactoring (Issue with huge person id groups)
    IF l_count > 0 THEN
    --IF p_person IS NOT NULL THEN
     log_to_fnd('corp_pre_process','debug','select type = G ..Calling build_sql_stmt');
     build_sql_stmt (
        p_parameter_1,
        p_sys_ltr_code,
        p_select_type,
        p_sql_stmt
     );
          END IF;


/*===============================================================================*/

      END IF;

    EXCEPTION
    WHEN OTHERS THEN
      lv_sql_code := SQLCODE;
      IF lv_sql_code = -06502 THEN
        fnd_message.set_name('IGF','IGF_AW_PERS_OVFLOW');
      ELSE
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','igf_aw_gen_004.corp_pre_process - ' || SQLERRM);
      END IF;
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;

   END corp_pre_process;

   PROCEDURE missing_items (
      p_person_id       IN       NUMBER,
      p_param1          IN       VARCHAR2,
      p_return_status   OUT NOCOPY      VARCHAR2
   ) IS

   /*************************************************************
  Created By :Prajeesh
  Date Created on : 05-Feb-2002
  Purpose : This procedure is mainly for the Preprocessing
            for the missing items. It checks if any items
            is not corresponded for the person and satisfies
            the validations like sum of min frequency with
            the correspondence date is greater than sysdate and
            max notifications has not exceeded for atleast
            one item. Then that person is sent a notification
            with all missing details
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    /* Main Cursor to Get the incomplete items*/
      CURSOR c_tdcur(l_base_id igf_ap_fa_base_rec_all.base_id%TYPE) IS
         SELECT tdii.base_id,
                tdii.item_sequence_number,
                tdii.add_date,
                tdii.status_date,
                tdii.corsp_date,
                tdii.corsp_count,
                tdii.inactive_flag,
                tdii.freq_attempt,
                tdii.max_attempt
         FROM   igf_ap_td_item_inst tdii
         WHERE  NVL(tdii.inactive_flag,'N') = 'N'
         AND    tdii.status               IN ('INC', 'REQ')
         AND    tdii.base_id              = l_base_id;

       /* Cursor to get the baseid for a given person id in an award year*/

       CURSOR c_base IS
              SELECT fabase.base_id
              FROM
              igf_ap_fa_base_rec_all fabase
              WHERE  person_id                    = p_person_id AND
                     fabase.ci_cal_type           = RTRIM (SUBSTR (p_param1, 1, 10))   AND
                     fabase.ci_sequence_number    = TO_NUMBER (RTRIM (SUBSTR (p_param1, 11)));

      l_tdrec         c_tdcur%ROWTYPE;
      l_base          igf_ap_fa_base_rec_all.base_id%TYPE;
      l_newcorsp_dt   igf_ap_td_item_inst_all.corsp_date%TYPE;
      l_new_cnt       NUMBER;
   BEGIN

      -- Get the Baseid for the person in an award year

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.missing_items.debug','p_person_id:'||p_person_id);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.missing_items.debug','p_param1:'||p_param1);
      END IF;

      OPEN c_base;
      FETCH c_base INTO l_base;
      CLOSE c_base;


      OPEN c_tdcur(l_base);
      --For each record check if correspondenc date exists or sum of frequncy and correspondence date is lesser than
      -- sysdate or has not reached the max notifications for atleast on todo item then return success and the person is sent the mail

      LOOP

         FETCH c_tdcur INTO l_tdrec;
         EXIT WHEN c_tdcur%NOTFOUND;
         IF l_tdrec.corsp_date IS NULL THEN
            p_return_status := 'S';
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.missing_items.debug','p_return_status(1):'||p_return_status);
            END IF;
            EXIT;
         ELSE
            l_newcorsp_dt := l_tdrec.corsp_date + NVL (l_tdrec.freq_attempt, 0);
            l_new_cnt     := NVL(l_tdrec.corsp_count, 0) + 1;

            IF (l_tdrec.max_attempt IS NOT NULL AND l_new_cnt <= l_tdrec.max_attempt AND l_newcorsp_dt <= SYSDATE) OR (l_tdrec.max_attempt IS NULL AND l_newcorsp_dt <= SYSDATE) THEN
               p_return_status := 'S';
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.missing_items.debug','p_return_status(2):'||p_return_status);
               END IF;
               EXIT;
            ELSE
               p_return_status := 'F';

            END IF;
         END IF;
      END LOOP;

      CLOSE c_tdcur;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.missing_items.debug','p_return_status:'||p_return_status);
      END IF;
    EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igf_aw_gen_004.missing_items');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
   END missing_items;

   PROCEDURE loan_disbursement_update (
      p_person_id    IN   NUMBER,
      p_award_year   IN   VARCHAR2
   ) IS

  /*************************************************************
  Created By :Prajeesh
  Date Created on : 05-Feb-2002
  Purpose : This Procedure is the Post processing Procedure
            for loan disbursement. AFter sending a mail.
            It updates the notification date with current
            date for each disbursement record for the person
            in an award year
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  /*Cursor to get the disbursement records for the person in an award year*/

    CURSOR cur_loan_disb_rec IS
       SELECT disb.rowid row_id,disb.*
       FROM
       igf_db_awd_disb_dtl_all disb
       WHERE award_id IN (SELECT award_id
                         FROM igf_aw_award_all aw,
                         igf_ap_fa_base_rec_all fbase
                         WHERE fbase.base_id            = aw.base_id AND
                               fbase.person_id          = p_person_id AND
                               fbase.ci_cal_type        = RTRIM(SUBSTR(p_award_year,1,10)) AND
                               fbase.ci_sequence_number = TO_NUMBER(RTRIM(SUBSTR(p_award_year,11))));
    l_cur_loan_disb_rec  cur_loan_disb_rec%ROWTYPE;

   BEGIN
     /* Update the notification date as sysdate for the disbursement records*/
     OPEN cur_loan_disb_rec;
     LOOP
      FETCH cur_loan_disb_rec INTO l_cur_loan_disb_rec;
      EXIT WHEN cur_loan_disb_rec%NOTFOUND;
      igf_db_awd_disb_dtl_pkg.update_row (
        X_Mode                              => 'R',
        x_rowid                             => l_cur_loan_disb_rec.row_id,
        x_award_id                          => l_cur_loan_disb_rec.award_id,
        x_disb_num                          => l_cur_loan_disb_rec.disb_num,
        x_disb_seq_num                      => l_cur_loan_disb_rec.disb_seq_num,
        x_disb_gross_amt                    => l_cur_loan_disb_rec.disb_gross_amt,
        x_fee_1                             => l_cur_loan_disb_rec.fee_1,
        x_fee_2                             => l_cur_loan_disb_rec.fee_2,
        x_disb_net_amt                      => l_cur_loan_disb_rec.disb_net_amt,
        x_disb_adj_amt                      => l_cur_loan_disb_rec.disb_adj_amt,
        x_disb_date                         => l_cur_loan_disb_rec.disb_date,
        x_fee_paid_1                        => l_cur_loan_disb_rec.fee_paid_1,
        x_fee_paid_2                        => l_cur_loan_disb_rec.fee_paid_2,
        x_disb_activity                     => l_cur_loan_disb_rec.disb_activity,
        x_disb_batch_id                     => l_cur_loan_disb_rec.disb_batch_id,
        x_disb_ack_date                     => l_cur_loan_disb_rec.disb_ack_date,
        x_booking_batch_id                  => l_cur_loan_disb_rec.booking_batch_id,
        x_booked_date                       => l_cur_loan_disb_rec.booked_date,
        x_disb_status                       => l_cur_loan_disb_rec.disb_status,
        x_disb_status_date                  => l_cur_loan_disb_rec.disb_status_date,
        x_sf_status                         => l_cur_loan_disb_rec.sf_status,   -- Accepted
        x_sf_status_date                    => l_cur_loan_disb_rec.sf_status_date,
        x_sf_invoice_num                    => l_cur_loan_disb_rec.sf_invoice_num,
        x_spnsr_credit_id       => l_cur_loan_disb_rec.spnsr_credit_id,
        x_spnsr_charge_id       => l_cur_loan_disb_rec.spnsr_charge_id,
        x_sf_credit_id          => l_cur_loan_disb_rec.sf_credit_id,
        x_error_desc          => l_cur_loan_disb_rec.error_desc,
        x_notification_date                 => TRUNC(SYSDATE),
        x_interest_rebate_amt               => l_cur_loan_disb_rec.interest_rebate_amt,
	x_ld_cal_type         =>        l_cur_loan_disb_rec.ld_cal_type,
        x_ld_sequence_number  =>        l_cur_loan_disb_rec.ld_sequence_number
      );

    END LOOP;
    CLOSE cur_loan_disb_rec;
    EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igf_aw_gen_004.loan_disbursement_update');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;

   END loan_disbursement_update;

   PROCEDURE missing_items_update (
      p_person_id    IN   NUMBER,
      p_award_year   IN   VARCHAR2
   ) IS

   /*************************************************************
  Created By :Prajeesh
  Date Created on : 05-Feb-2002
  Purpose : This Procedure is for the post processing. It updates
            the correspondence date and count and also the
            correspondence text is made active Y
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  --bkkumar       04-jun-2003      Bug #2858504
  --                               Added legacy_record_flag
  --                               in the table handler calls for igf_ap_td_item_inst_pkg.update_row
  (reverse chronological order - newest change first)
  ***************************************************************/

  /*Cursor to get the incomplete to items for the person in an award year*/

    CURSOR cur_incomp_items
           IS
           SELECT tdii.rowid row_id,tdii.*
           FROM
           igf_ap_td_item_inst_all tdii,
           igf_ap_fa_base_rec_all facon
           WHERE
           facon.base_id              = tdii.base_id AND
           NVL(tdii.inactive_flag,'N')='N' AND
           tdii.status IN ('INC','REQ') AND
           facon.person_id            = p_person_id AND
           facon.ci_cal_type          = RTRIM(SUBSTR(p_award_year,1,10)) AND
           facon.ci_sequence_number   = TO_NUMBER(RTRIM(SUBSTR(p_award_year,11)));
   l_cur_incomp_items  cur_incomp_items%ROWTYPE;

   /*Cursor to get the correspondence text for the person*/

    CURSOR cur_corr_text
           IS
           SELECT ctext.rowid row_id,ctext.*
           FROM
           igf_ap_st_corr_text ctext
           WHERE
           ctext.active = 'N' AND
           ctext.base_id IN (SELECT base_id
                                    FROM
                                    igf_ap_fa_base_rec_all where person_id=p_person_id);

   l_cur_corr_text cur_corr_text%ROWTYPE;


   BEGIN

     /*Update the correspondence text for the person as active Y thus it cant be changed again*/

     OPEN cur_corr_text;
     LOOP
      FETCH cur_corr_text INTO l_cur_corr_text;
      EXIT WHEN cur_corr_text%NOTFOUND;

     igf_ap_st_corr_text_pkg.update_row (
      x_mode                              => 'R',
      x_rowid                             => l_cur_corr_text.row_id,
      x_corsp_id                          => l_cur_corr_text.corsp_id,
      x_base_id                           => l_cur_corr_text.base_id,
      x_custom_text                       => l_cur_corr_text.custom_text,
      x_run_date                          => TRUNC(SYSDATE),
      x_active                            => 'Y'
      );
     END LOOP;
     CLOSE cur_corr_text;

     /*Increment the incomplete to do items correspondence count with 1 and
       update the correspondence date with sysdate*/

     OPEN cur_incomp_items;
     LOOP
     FETCH cur_incomp_items INTO l_cur_incomp_items;
     EXIT WHEN cur_incomp_items%NOTFOUND;

      igf_ap_td_item_inst_pkg.update_row (
        x_rowid                            => l_cur_incomp_items.row_id,
        x_base_id                          => l_cur_incomp_items.base_id,
        x_item_sequence_number             => l_cur_incomp_items.item_sequence_number,
        x_status                           => l_cur_incomp_items.status,
        x_status_date                      => l_cur_incomp_items.status_date,
        x_add_date                         => l_cur_incomp_items.add_date,
        x_corsp_date                       => TRUNC(SYSDATE),
        x_corsp_count                      => NVL(l_cur_incomp_items.corsp_count,0) + 1,
        x_inactive_flag                    => l_cur_incomp_items.inactive_flag,
   x_required_for_application         => l_cur_incomp_items.required_for_application,
   x_freq_attempt                     => l_cur_incomp_items.freq_attempt,
   x_max_attempt                      => l_cur_incomp_items.max_attempt,
        x_mode                             => 'R',
        x_legacy_record_flag               => l_cur_incomp_items.legacy_record_flag,
        x_clprl_id                         => l_cur_incomp_items.clprl_id
        );
     END LOOP;
     CLOSE cur_incomp_items;

    EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AW_GEN_004.mising_items_update');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
   END missing_items_update;

 FUNCTION get_award_desc(
  p_person_id IN NUMBER,
  p_cal_type IN VARCHAR2,
  p_sequence_number IN NUMBER
  ) RETURN VARCHAR2 IS

 /*************************************************************
  Created By :Prajeesh
  Date Created on : 05-Feb-2002
  Purpose : This function is used in award letter view to get
            the award description and message in given format
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  /*This function is used in View to get the award message and award description in desired format*/

  CURSOR cur_table_data IS
  SELECT   DECODE (lt.fund_description,
           '<B>Award Type</B>', '<TABLE BORDER=1><TR><TD>' || lt.fund_description || '</TD><TD><B>Award Message</B></TD></TR>',
           '-', '</TABLE>',
     '<TR><TD>' || NVL (lt.fund_description, '-') || '</TD><TD>' || NVL (fmast.awd_notice_txt, '-') || '</TD></TR>') award_description
  FROM     igf_aw_awd_ltr_tmp lt,
           igf_aw_fund_mast_all fmast
  WHERE    lt.fund_code = fmast.fund_code(+)
  AND      lt.ci_cal_type = fmast.ci_cal_type(+)
  AND      lt.ci_sequence_number = fmast.ci_sequence_number(+)
  AND      lt.person_id = p_person_id
  AND      lt.ci_cal_type = p_cal_type
  AND      lt.ci_sequence_number = p_sequence_number
  ORDER BY line_id;

  l_return_data VARCHAR2(32000);

BEGIN
  FOR rec_data IN cur_table_data
  LOOP
   l_return_data := l_return_data||rec_data.award_description;
  END LOOP;
  RETURN l_return_data;

 EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;

END get_award_desc;


   PROCEDURE award_letter_update (
      p_person_id    IN   NUMBER,
      p_award_year   IN   VARCHAR2,
      p_award_prd_cd IN   VARCHAR
   ) IS

   /*************************************************************
  Created By :Prajeesh
  Date Created on : 05-Feb-2002
  Purpose : This Procedure is post processing one. It updates
            the notification status and status date after
            sending the letter. Status is made sent
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
   rasahoo        18-NOV-2003     FA 128 - ISIR update 2004-05
                                  added new parameter award_fmly_contribution_type to
                                  igf_ap_fa_base_rec_pkg.update_row
  ugummall        25-SEP-2003     FA 126 Multiple FA Offices
                                  added new parameter assoc_org_num to
                                  igf_ap_fa_base_rec_pkg.update_row call.

  masehgal        11-Nov-2002     FA 101 - SAP Obsoletion
                                  removed packaging hold

  masehgal        25-Sep-2002     FA 104 - To Do Enhancements
                                  Added manual_disb_hold in FA Base update

  (reverse chronological order - newest change first)
  ***************************************************************/

   BEGIN

    -- Update award notification status to s = Sent.
     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.award_letter_update.debug', 'p_person_id       - ' || p_person_id);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.award_letter_update.debug', 'p_award_year      - ' || p_award_year);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_004.award_letter_update.debug', 'p_award_prd_cd    - ' || p_award_prd_cd);
     END IF;

    igf_aw_gen.update_notification_status (
                            p_cal_type                  => RTRIM (SUBSTR (p_award_year,1,10)),
                            p_seq_num                   => TO_NUMBER (RTRIM (SUBSTR (p_award_year, 11))),
                            p_awarding_period           => p_award_prd_cd,
                            p_base_id                   => igf_aw_gen_004.get_base_id_for_person (p_person_id, RTRIM (SUBSTR (p_award_year, 1, 10)), TO_NUMBER (RTRIM (SUBSTR (p_award_year, 11)))),
                            p_notification_status_code  => 'S',
                            p_notification_status_date  => TRUNC(SYSDATE),
                            p_called_from               => 'IGFAW13B'
                            ) ;

    EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AW_GEN_004.AWARD_LETTER_UPDATE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;

   END award_letter_update ;



   FUNCTION get_corr_cust_text(p_person_id   IN NUMBER)
   /*************************************************************
  Created By :Prajeesh
  Date Created on : 05-Feb-2002
  Purpose : This Function is used in view to get the
            correspondence text for the person
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
   RETURN VARCHAR2 IS
      l_data_text  VARCHAR2(32000);
      CURSOR c_cust_text IS
             SELECT corr.custom_text
             FROM
             igf_ap_st_corr_text corr,
             igf_ap_fa_base_rec_all fbase
             WHERE
             fbase.base_id       =  corr.base_id AND
             fbase.person_id     =  p_person_id AND
             corr.active         =  'Y';

   BEGIN
      OPEN c_cust_text;
      FETCH c_cust_text INTO l_data_text;
      CLOSE c_cust_text;
      RETURN l_data_text;

    EXCEPTION
    WHEN OTHERS THEN
      NULL;

   END get_corr_cust_text;
END igf_aw_gen_004;

/
