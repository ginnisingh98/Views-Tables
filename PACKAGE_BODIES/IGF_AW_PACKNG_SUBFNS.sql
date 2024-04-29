--------------------------------------------------------
--  DDL for Package Body IGF_AW_PACKNG_SUBFNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_PACKNG_SUBFNS" AS
/* $Header: IGFAW09B.pls 120.10 2006/08/04 07:38:08 veramach ship $ */

  /* ------------------------------------------------------------------
  ||  Created By : avenkatr
  ||  Created On : 20-JUN-2001
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  skoppula
  ||    The functionality of this procedure is changed to recieve the loan
  ||    amounts for the student and then compare them against the Federal
  ||    Stafford loan limits setup through IGFAW021.fmb
  ||  museshad      15-Jun-2005     Build# FA157 - Bug# 4382371.
  ||                                Added the parameters - l_awd_period, l_called_from.
  ||                                As of now, these parameters (defaultable) will get passed only
  ||                                when called from the Packaging process (igf_aw_packaging).
  ||                                Passed these paramaters to get_class_stnd()
  ||                                to get the class standing data from anticipated data, if
  ||                                actual data is not available.
  ||  sjadhav       09-Nov-2004     corrected garde level override comparsion
  ||  veramach      11-Oct-2004     Obsoleted get_coa_months,stud_elig_chk
  ||  veramach      11-NOV-2003     FA 125 Multiple distribution methods
  ||                                1.Changed function signature of get_class_stnd to take adplans_id instead of fund_id
  ||                                2.Award start date is chosen based on distribution plan setup instead of fund setup
  ||
  ||  veramach      07-OCT-2003     FA 124
  ||                                1.Removed the procedure get_im_efc
  ||                                2.Added the function is_over_award_occured
  ||  brajendr      20-Dec-2002     Bug # 2706197
  ||                                Modifed the logic for get class standing process, removed the return statement.
  ||
  ||  brajendr      24-Oct-2002     FA105 / FA108 Builds
  ||                                Modified the references of Obsoleted Views
  --------------------------------------------------------------------*/

PROCEDURE check_loan_limits( l_base_id        IN NUMBER,
                             fund_type        IN VARCHAR2,
                             l_award_id       IN NUMBER,
                             l_adplans_id     IN NUMBER,
                             l_aid            IN OUT NOCOPY NUMBER,
                             l_std_loan_tab   IN std_loan_tab DEFAULT NULL,
                             p_msg_name       OUT NOCOPY VARCHAR2,
                             l_awd_period     IN igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL,
                             l_called_from    IN VARCHAR2 DEFAULT 'NON-PACKAGING',
                             p_chk_aggr_limit IN VARCHAR2 DEFAULT 'Y'
                           ) IS
  /*
  ||  Created By : avenkatr
  ||  Created On : 20-JUN-2001
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  bkkumar         14-Jan-04       Bug# 3360702
  ||                                  Added the check for the l_aid to be negative and then returning with the
  ||                                  appropriate message.
  ||  cdcruz          05-feb-03       Bug# 2758804
  ||                                  cursor c_get_status ref changed to pick active isisr
  */

  lv_class_standing        igs_pr_css_class_std_v.class_standing%TYPE;
  lv_course_type           igs_ps_ver_all.course_type%TYPE;

  CURSOR c_fabase_det IS
    SELECT *
    FROM igf_ap_fa_base_rec_all
    WHERE base_id = l_base_id;

  l_fabase_det c_fabase_det%ROWTYPE;

  CURSOR c_get_status  IS
    SELECT dependency_status
    FROM   igf_ap_isir_matched_all
    WHERE  base_id = l_base_id AND
           payment_isir = 'Y'  AND
           system_record_type = 'ORIGINAL';

  l_get_status  c_get_status%ROWTYPE;

  CURSOR c_loan_limit_FFELP ( x_depend_stat igf_ap_isir_matched.dependency_status%TYPE,
                       x_fl_grad_lvl VARCHAR2,
                       x_ci_cal_type Varchar,
                       x_ci_sequence_number Number)  IS
    SELECT subs_annual_lt, tot_annual_lt, subs_aggr_lt, tot_aggr_lt
    FROM igf_aw_loan_limit_all
    WHERE  ci_cal_type = x_ci_cal_type AND
           ci_sequence_number = x_ci_sequence_number AND
           depend_stat = x_depend_stat AND
           ffelp_grade_level = x_fl_grad_lvl;


  CURSOR c_loan_limit_DL( x_depend_stat igf_ap_isir_matched.dependency_status%TYPE,
                       x_ci_cal_type Varchar,
                       x_ci_sequence_number Number,
                       x_dl_grad_lvl VARCHAR2 )  IS
    SELECT subs_annual_lt, tot_annual_lt, subs_aggr_lt, tot_aggr_lt
    FROM igf_aw_loan_limit_all
    WHERE  ci_cal_type = x_ci_cal_type AND
           ci_sequence_number = x_ci_sequence_number AND
           depend_stat = x_depend_stat AND
           dl_grade_level = x_dl_grad_lvl;

   l_loan_limit c_loan_limit_DL%ROWTYPE;

 -- Cursor to fetch the nslds loan aggregates and the transaction process
 -- date from the isir matced table
  CURSOR c_nslds_loans IS SELECT
         NVL(nslds.nslds_agg_subsz_out_prin_bal,0) aggr_subs_loan,
         NVL(nslds.nslds_agg_comb_out_prin_bal,0) aggr_total_loan,
   isir.tran_process_date
   FROM igf_ap_isir_matched_all isir,igf_ap_nslds_data nslds
   WHERE nslds.base_id = l_base_id
   AND isir.isir_id = nslds.isir_id
   ORDER BY TO_NUMBER(nslds.transaction_num_txt) DESC;

  l_nslds_loan_rec   c_nslds_loans%ROWTYPE;

-- Cursor to pick up all those awards which have not yet gone into
-- the NSLDS database

  CURSOR c_get_addtnl_awd(
                          cp_awd_date igf_aw_award.award_date%TYPE
                         ) IS
   SELECT SUM (NVL (awd.offered_amt, 0)) loan_amt,
          SUM (DECODE (
                fcat.fed_fund_code,
                'FLS', NVL (awd.offered_amt, 0),
                'DLS', NVL (awd.offered_amt, 0),
                0
             )) subs_loan_amt
     FROM igf_aw_award_all awd,
          igf_aw_fund_mast fm,
          igf_aw_fund_cat_all fcat,
          igf_ap_fa_base_rec_all fa
    WHERE fa.person_id IN (SELECT person_id
                             FROM igf_ap_fa_base_rec_all
                            WHERE base_id = l_base_id)
      AND awd.base_id = fa.base_id
      AND awd.fund_id = fm.fund_id
      AND (   cp_awd_date IS NULL
           OR TRUNC (awd.award_date) >= TRUNC (cp_awd_date))
      AND awd.award_status IN ('OFFERED', 'ACCEPTED')
      AND fcat.fund_code = fm.fund_code
      AND fcat.fed_fund_code IN ('DLS', 'DLU', 'FLS', 'FLU');
   l_addtnl_awd_rec c_get_addtnl_awd%ROWTYPE;

  -- Cursor to check annual loan limits
  CURSOR c_get_anl_awd IS
    SELECT SUM(NVL(awd.offered_amt,0)) loan_amt,
           SUM(DECODE(fcat.fed_fund_code,'FLS',
           NVL(awd.offered_amt,0),'DLS',NVL(awd.offered_amt,0),0)) subs_loan_amt
      FROM igf_aw_award_all awd,
           igf_aw_fund_mast_all fm,
           igf_aw_fund_cat_all fcat
     WHERE awd.base_id = l_base_id
       AND awd.fund_id = fm.fund_id
       AND awd.award_status IN ('OFFERED','ACCEPTED')
       AND fcat.fund_code = fm.fund_code
       AND fcat.fed_fund_code IN ('DLS','DLU','FLS','FLU');

  -- Cursor to determine the start date for the award

  --
  -- cursor to read grade level override
  -- FA 134 Build, Loan Level Grade Level Override Impact
  -- use this value if not null for CommonLine Checks
  CURSOR cur_grade_overide(p_award_id NUMBER) IS
    SELECT override_grade_level_code
      FROM igf_sl_lor_all   lor,
           igf_sl_loans_all loan
     WHERE loan.loan_id  = lor.loan_id
       AND loan.award_id = p_award_id;

  grade_overide_rec cur_grade_overide%ROWTYPE;
  lv_grd_lvl        VARCHAR2(30);

  l_anl_awd_rec     c_get_anl_awd%ROWTYPE;
  l_yr_loan_amt     NUMBER := 0;    -- Current year loan amount
  l_aggr_loan_amt   NUMBER := 0;    -- Aggregate loan amount
  l_yr_subs_amt     NUMBER := 0;    -- Current year subs. loan amount
  l_aggr_subs_amt   NUMBER := 0;    -- Aggregate Subsidized loan amount
  l_nsl_nc_ln_amt   NUMBER := 0;    -- This var. is used in the std_loan table to fetch
  l_nsl_nc_sub_amt  NUMBER := 0;
  l_dl_std_code     igf_ap_class_std_map.dl_std_code%TYPE;
  l_cl_std_code     igf_ap_class_std_map.cl_std_code%TYPE;
  l_aggr_unsb_total   NUMBER;
  l_anul_unsub_total  NUMBER;

BEGIN

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Parameter List - START');
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','In Param :l_base_id       '|| l_base_id      );
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','In Param :fund_type       '|| fund_type      );
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','In Param :l_award_id      '|| l_award_id     );
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','In Param :l_aid           '|| l_aid          );
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','In Param :l_adplans_id       '|| l_adplans_id      );
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','In Param :l_awd_period       '|| l_awd_period      );
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','In Param :l_called_from      '|| l_called_from     );
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','In Param :p_chk_aggr_limit   '|| p_chk_aggr_limit  );
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Parameter List - END');
  END IF;

  p_msg_name := NULL;

  OPEN c_fabase_det;
  FETCH c_fabase_det INTO l_fabase_det;
  CLOSE c_fabase_det;

  OPEN  cur_grade_overide(l_award_id);
  FETCH cur_grade_overide INTO grade_overide_rec;
  CLOSE cur_grade_overide;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','grade_overide  '|| grade_overide_rec.override_grade_level_code);
  END IF;
  --
  -- If there is not grade level override record
  -- or if grade level override is null then derive class
  -- standing
  --
  IF grade_overide_rec.override_grade_level_code IS NULL THEN
      lv_class_standing := get_class_stnd(l_base_id,
                                          l_fabase_det.person_id,
                                          l_adplans_id,
                                          l_award_id,
                                          lv_course_type,
                                          l_awd_period,
                                          l_called_from);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','lv_class_standing:'||lv_class_standing);
      END IF;
      IF lv_class_standing IS NULL THEN
        p_msg_name := 'IGF_AW_CLS_STD_NOT_FND';
        l_aid := 0;
        RETURN;
      END IF;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','calling dl cl std code with parameters - base_id: ' ||l_base_id|| ', class standing: ' ||lv_class_standing|| ', course type: ' ||lv_course_type);
      END IF;

    igf_sl_lar_creation.get_dl_cl_std_code(l_base_id,
                                           lv_class_standing,
                                           lv_course_type,
                                           l_dl_std_code,
                                           l_cl_std_code);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','after dl cl std code');
      END IF;

    IF l_dl_std_code IS NULL AND l_cl_std_code IS NULL THEN
      p_msg_name := 'IGF_AW_CLSSTD_MAP_NOT_FND';
      l_aid := 0;
      RETURN;
    END IF;
  END IF;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_dl_std_code: '||l_dl_std_code||' l_cl_std_code: '||l_cl_std_code);
  END IF;

  OPEN c_get_status ;
  FETCH c_get_status INTO l_get_status;
  IF c_get_status%NOTFOUND THEN
    CLOSE c_get_status;
    p_msg_name := 'IGF_AW_DEP_STAT_NOT_FND';
    l_aid := 0;
    RETURN;
  END IF;
  CLOSE c_get_status;

  -- Fetching the aggregate loans (Subsidized and combined)

  OPEN c_nslds_loans;
  FETCH c_nslds_loans INTO l_nslds_loan_rec;
  IF c_nslds_loans%NOTFOUND THEN
    fnd_message.set_name('IGF','IGF_AW_NSLDS_NOT_FND');
    igs_ge_msg_stack.add;
  END IF;
  CLOSE c_nslds_loans;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_nslds_loan_rec.aggr_subs_loan: '||l_nslds_loan_rec.aggr_subs_loan);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_nslds_loan_rec.aggr_total_loan: '||l_nslds_loan_rec.aggr_total_loan);
  END IF;

  IF l_std_loan_tab IS NOT NULL AND l_std_loan_tab.COUNT > 0 THEN -- check whether the table parameter is passed with rows

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_std_loan_tab.COUNT:'||l_std_loan_tab.COUNT);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Inside the pl-sql tab IF');
    END IF;


    FOR i IN 1..l_std_loan_tab.COUNT LOOP

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Inside the pl-sql tab loop');
      END IF;

      l_yr_loan_amt := NVL(l_yr_loan_amt,0) + NVL(l_std_loan_tab(i).award_amount,0);

      -- Log
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','added, to l_yr_loan_amt,award:'||NVL(l_std_loan_tab(i).award_amount,0)||' from:'||l_std_loan_tab(i).fund_code);
      END IF;

      IF l_std_loan_tab(i).award_date  >= l_nslds_loan_rec.tran_process_date THEN
       l_nsl_nc_ln_amt := NVL(l_nsl_nc_ln_amt,0) + NVL(l_std_loan_tab(i).award_amount,0);

       -- Log
       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','added, to l_nsl_nc_ln_amt,award:'||NVL(l_std_loan_tab(i).award_amount,0)||' from:'||l_std_loan_tab(i).fund_code);
       END IF;
      END IF;

      IF l_std_loan_tab(i).fed_fund_code IN ('FLS','DLS') THEN
       l_yr_subs_amt := NVL(l_yr_subs_amt,0) + NVL(l_std_loan_tab(i).award_amount,0);
       -- Log
       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','added, to l_yr_subs_amt,award:'||NVL(l_std_loan_tab(i).award_amount,0)||' from:'||l_std_loan_tab(i).fund_code);
       END IF;

       IF l_std_loan_tab(i).award_date  >= l_nslds_loan_rec.tran_process_date THEN
        l_nsl_nc_sub_amt := NVL(l_nsl_nc_sub_amt,0) + NVL(l_std_loan_tab(i).award_amount,0);

        -- Log
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','added, to l_nsl_nc_sub_amt,award:'||NVL(l_std_loan_tab(i).award_amount,0)||' from:'||l_std_loan_tab(i).fund_code);
        END IF;
       END IF;
      END IF;
    END LOOP;  -- End for loop of student table

  ELSE

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Inside the pl-sql tab ELSE');
    END IF;

    OPEN c_get_anl_awd;
    FETCH c_get_anl_awd INTO l_anl_awd_rec;
    CLOSE c_get_anl_awd;

    l_yr_loan_amt := NVL(l_anl_awd_rec.loan_amt,0);
    l_yr_subs_amt := NVL(l_anl_awd_rec.subs_loan_amt,0);

    OPEN c_get_addtnl_awd(l_nslds_loan_rec.tran_process_date);
    FETCH c_get_addtnl_awd INTO l_addtnl_awd_rec;
    CLOSE c_get_addtnl_awd;

    l_nsl_nc_ln_amt  := NVL(l_addtnl_awd_rec.loan_amt,0);
    l_nsl_nc_sub_amt := NVL(l_addtnl_awd_rec.subs_loan_amt,0);

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_yr_loan_amt:'||l_yr_loan_amt);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_yr_subs_amt:'||l_yr_subs_amt);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_nsl_nc_ln_amt:'||l_nsl_nc_ln_amt);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_nsl_nc_sub_amt:'||l_nsl_nc_sub_amt);
    END IF;

 END IF; --End of table parameter check

 l_aggr_loan_amt := NVL(l_nslds_loan_rec.aggr_total_loan,0) + NVL(l_nsl_nc_ln_amt,0);
 l_aggr_subs_amt := NVL(l_nslds_loan_rec.aggr_subs_loan,0) + NVL(l_nsl_nc_sub_amt,0);
 -- here the unsub aggregate and subsidized amounts are calculated to be used ahead.
 l_aggr_unsb_total := l_aggr_loan_amt - l_aggr_subs_amt;
 l_anul_unsub_total := l_yr_loan_amt - l_yr_subs_amt;

 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_aggr_loan_amt:'||l_aggr_loan_amt);
   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_aggr_subs_amt:'||l_aggr_subs_amt);
   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_aggr_unsb_total:'||l_aggr_unsb_total);
   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_anul_unsub_total:'||l_anul_unsub_total);
 END IF;

  /*  Added by svuppala as part of bug: 3416936 */
  IF (l_fabase_det.adnl_unsub_loan_elig_flag ='Y' AND l_get_status.dependency_status ='D') THEN
      l_get_status.dependency_status := 'I';
  END IF;

  IF grade_overide_rec.override_grade_level_code IS NOT NULL THEN
    IF fund_type IN ('DLP','DLS','DLU') THEN
       l_dl_std_code := grade_overide_rec.override_grade_level_code;
    END IF;
    IF fund_type IN ('FLP','FLS','FLU','ALT') THEN
      l_cl_std_code := grade_overide_rec.override_grade_level_code;
    END IF;
  END IF;

  IF fund_type IN ('DLP','DLS','DLU') THEN
     OPEN c_loan_limit_dl(l_get_status.dependency_status,l_fabase_det.ci_cal_type,l_fabase_det.ci_sequence_number,l_dl_std_code);
     FETCH c_loan_limit_dl INTO l_loan_limit;
  END IF;

  IF fund_type IN ('FLP','FLS','FLU','ALT') THEN
     OPEN c_loan_limit_ffelp(l_get_status.dependency_status,l_cl_std_code,l_fabase_det.ci_cal_type,l_fabase_det.ci_sequence_number);
     FETCH c_loan_limit_ffelp INTO l_loan_limit;
  END IF;

  IF (fund_type IN ('DLP','DLS','DLU') AND c_loan_limit_dl%FOUND)
  OR (fund_type IN ('FLP','FLS','FLU','ALT') AND c_loan_limit_ffelp%FOUND) THEN

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Stafford loan limits(as in setup) for fund '||fund_type||':');
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_loan_limit.tot_aggr_lt:'||l_loan_limit.tot_aggr_lt);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_loan_limit.tot_annual_lt:'||l_loan_limit.tot_annual_lt);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_loan_limit.subs_aggr_lt:'||l_loan_limit.subs_aggr_lt);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_loan_limit.subs_annual_lt:'||l_loan_limit.subs_annual_lt);
      END IF;

      -- Subs+Unsubs Aggr limit check
      /* Check if loan is within aggregate loan limits and adjust the amount accordingly */
      IF p_chk_aggr_limit = 'Y' THEN

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Total Aggr limit check - START');
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Total Aggr already received by student= ' ||NVL(l_aggr_loan_amt,0));
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Permissible Total Aggr(as in setup)= ' ||NVL(l_loan_limit.tot_aggr_lt,0));
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_aid(current loan amt)= ' ||NVL(l_aid,0));
        END IF;

      IF (( NVL(l_aggr_loan_amt,0) + NVL(l_aid,0)) > NVL(l_loan_limit.tot_aggr_lt,0) ) THEN
        l_aid := NVL(l_loan_limit.tot_aggr_lt,0) - NVL(l_aggr_loan_amt,0);
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Aggr l_aid(after adjustment): '||l_aid );
      END IF;

      -- if the l_aid is less than 0 it means that already the limits have been exhausted so just set the
      -- appropriate the message and return.
      IF l_aid < 0 THEN
         p_msg_name := 'IGF_AW_AGGR_LMT_ERR';
         IF c_loan_limit_dl%ISOPEN THEN
           CLOSE c_loan_limit_dl;
         END IF;
         IF c_loan_limit_ffelp%ISOPEN THEN
           CLOSE c_loan_limit_ffelp;
         END IF;

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Total Aggr limit check FAILED with IGF_AW_AGGR_LMT_ERR');
         END IF;

         RETURN;
      END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Total Aggr limit check PASSED');
        END IF;
      END IF;   -- <<p_chk_aggr_limit>>

      -- Subs+Unsubs Annual limit check
      /* Check if loan is within annual loan limits and adjust the amount accordingly*/
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Total Annual limit check - START');
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Total Annual already received by student= ' ||NVL(l_yr_loan_amt,0));
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Permissible Total Annual(as in setup)= ' ||NVL(l_loan_limit.tot_annual_lt,0));
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_aid(current loan amt)= ' ||NVL(l_aid,0));
      END IF;

      IF (( NVL(l_yr_loan_amt,0) + NVL(l_aid,0)) > NVL(l_loan_limit.tot_annual_lt,0) ) THEN
          l_aid := NVL(l_loan_limit.tot_annual_lt,0) -  NVL(l_yr_loan_amt,0);
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Annual l_aid(after adjustment) : '||l_aid );
      END IF;

      IF l_aid < 0 THEN
         p_msg_name := 'IGF_AW_ANNUAL_LMT_ERR';

         IF c_loan_limit_dl%ISOPEN THEN
           CLOSE c_loan_limit_dl;
         END IF;

         IF c_loan_limit_ffelp%ISOPEN THEN
           CLOSE c_loan_limit_ffelp;
         END IF;

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Total Annual limit check FAILED with IGF_AW_ANNUAL_LMT_ERR');
         END IF;

         RETURN;
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Total Annual limit check PASSED');
      END IF;

      /* Check if loan is a subsidized loan and then check whether annual and aggregate
         subisidzed loan limits are met for the student and adjust the aid accordingly */
      IF fund_type IN('DLS','FLS') THEN
        -- Subsidized Aggr limit check
        IF p_chk_aggr_limit = 'Y' THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Subs Aggr limit check - START');
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Subs Aggr already received by student= ' ||NVL(l_aggr_subs_amt,0));
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Permissible Subs Aggr (as in setup)= ' ||NVL(l_loan_limit.subs_aggr_lt,0));
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_aid(current loan amt)= ' ||NVL(l_aid,0));
      END IF;

        IF (( NVL(l_aggr_subs_amt,0) + NVL(l_aid,0)) > NVL(l_loan_limit.subs_aggr_lt,0)) THEN

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_aggr_subs_amt + aid > l_loan_limit.subs_aggr_lt');
          END IF;

          l_aid := NVL(l_loan_limit.subs_aggr_lt,0) -  NVL(l_aggr_subs_amt,0);
        END IF;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Subs Aggr l_aid(after adjustment) : '||l_aid );
          END IF;

        IF l_aid < 0 THEN
           p_msg_name := 'IGF_AW_SUB_AGGR_LMT_ERR';
           IF c_loan_limit_dl%ISOPEN THEN
             CLOSE c_loan_limit_dl;
           END IF;
           IF c_loan_limit_ffelp%ISOPEN THEN
             CLOSE c_loan_limit_ffelp;
           END IF;

             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Subs Aggr limit check FAILED with IGF_AW_SUB_AGGR_LMT_ERR');
             END IF;

           RETURN;
        END IF;

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Subs Aggr limit check PASSED');
         END IF;
        END IF;   -- <<p_chk_aggr_limit>>

        -- Subsidized Annual limit check
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Subs Annual limit check - START');
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Subs Annual already received by student= ' ||NVL(l_yr_subs_amt,0));
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Permissible Subs Annual (as in setup)= ' ||NVL(l_loan_limit.subs_annual_lt,0));
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_aid(current loan amt)= ' ||NVL(l_aid,0));
        END IF;

        IF (( NVL(l_yr_subs_amt,0) + NVL(l_aid,0))  > NVL(l_loan_limit.subs_annual_lt,0)) THEN

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_yr_subs_amt + aid > l_loan_limit.subs_annual_lt');
          END IF;

           l_aid := NVL(l_loan_limit.subs_annual_lt,0) -  NVL(l_yr_subs_amt,0);
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Subs Annual l_aid(after adjustment) : '||l_aid );
        END IF;

        IF l_aid < 0 THEN
           p_msg_name := 'IGF_AW_SUB_LMT_ERR';
           IF c_loan_limit_dl%ISOPEN THEN
             CLOSE c_loan_limit_dl;
           END IF;
           IF c_loan_limit_ffelp%ISOPEN THEN
             CLOSE c_loan_limit_ffelp;
           END IF;

           IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Subs Annual limit check FAILED with IGF_AW_SUB_LMT_ERR');
           END IF;

           RETURN;
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Subs Annual limit check PASSED');
      END IF;
      END IF; -- << fund_type IN('DLS','FLS') >>

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','l_aid:'||l_aid);
      END IF;

    ELSIF (fund_type IN ('DLP','DLS','DLU') AND c_loan_limit_dl%NOTFOUND)
       OR (fund_type IN ('FLP','FLS','FLU','ALT') AND c_loan_limit_ffelp%NOTFOUND)  THEN
      p_msg_name := 'IGF_AW_LOAN_LMT_NOT_FND';
      l_aid := 0;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.check_loan_limits.debug','Stafford loan limits not defined, msg is IGF_AW_LOAN_LMT_NOT_FND');
    END IF;
    END IF;

    IF c_loan_limit_dl%ISOPEN THEN
      CLOSE c_loan_limit_dl;
    END IF;
    IF c_loan_limit_ffelp%ISOPEN THEN
      CLOSE c_loan_limit_ffelp;
    END IF;

  IF l_aid < 0 THEN
    l_aid := 0;
  END IF;
  --  Commonline Loans
EXCEPTION
  WHEN OTHERS THEN

    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','igf_aw_packng_subfns.check_loan_limits');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION ;

END check_loan_limits;

  PROCEDURE get_fed_efc(
                        l_base_id      IN          NUMBER,
                        l_awd_prd_code IN     igf_aw_awd_prd_term.award_prd_cd%TYPE,
                        l_efc_f        OUT NOCOPY  NUMBER,
                        l_pell_efc     OUT NOCOPY  NUMBER,
                        l_efc_ay       OUT NOCOPY  NUMBER
                       ) IS
    /*
    ||  Created By : avenkatr
    ||  Created On : 07-JUN-2001
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  veramach       08-Apr-2004      bug 3547237
    ||                                  Enforced a check that if auto_zero_efc is set to 'Y' in the active_isir,
    ||                                  then the EFC must be zero
    ||  brajendr        03-Dec-2003     FA 128 Isir Update
    ||                                  Modified the logic for deriving the PELL EFC
    ||
    || rasahoo        27-Nov-2003       FA 128 Isir Update
    ||                                  Changed the query string 'qry_str'
    ||
    ||  cdcruz          05-feb-03       Bug# 2758804 FACR105
    ||                                  cursor c_isir_id ref changed to pick active isisr
    */

    CURSOR c_isir_id ( x_base_id igf_ap_fa_base_rec.base_id%TYPE ) IS
    SELECT isir_id,
           primary_efc,
           NVL(auto_zero_efc,'N') auto_zero_efc
      FROM igf_ap_isir_matched
     WHERE base_id = x_base_id
       AND active_isir = 'Y';

    l_isir_id   c_isir_id%ROWTYPE;

    CURSOR c_pell_efc ( cp_base_id igf_ap_fa_base_rec.base_id%TYPE ) IS
    SELECT DECODE(fa.award_fmly_contribution_type, 2, isir.secondary_efc, isir.primary_efc) pell_efc
      FROM igf_ap_fa_base_rec_all fa,
           igf_ap_isir_matched_all isir
     WHERE fa.base_id = isir.base_id
       AND fa.base_id = cp_base_id
       AND isir.active_isir = 'Y';

    lc_pell_efc   c_pell_efc%ROWTYPE;

    -- Get the details of
    CURSOR get_awd_fmly_contrib_type(cp_base_id igf_ap_fa_base_rec.base_id%TYPE) IS
    SELECT award_fmly_contribution_type
      FROM igf_ap_fa_base_rec_all
     WHERE base_id = cp_base_id;

    lv_awd_fmly_contrib_type igf_ap_fa_base_rec.award_fmly_contribution_type%TYPE;

    cur_rec   NUMBER;
    rows      NUMBER;
    qry_str   VARCHAR2(200);

    l_coa_months NUMBER;

    CURSOR c_efc(
                 cp_isir_id               igf_ap_isir_matched_all.isir_id%TYPE,
                 cp_months_num            NUMBER,
                 cp_awd_fmly_contrib_type igf_ap_fa_base_rec_all.award_fmly_contribution_type%TYPE
              ) IS
     SELECT DECODE (
               cp_awd_fmly_contrib_type,
               2, DECODE (
                  cp_months_num,
                  1, isir.sec_alternate_month_1,
                  2, isir.sec_alternate_month_2,
                  3, isir.sec_alternate_month_3,
                  4, isir.sec_alternate_month_4,
                  5, isir.sec_alternate_month_5,
                  6, isir.sec_alternate_month_6,
                  7, isir.sec_alternate_month_7,
                  8, isir.sec_alternate_month_8,
                  9, isir.secondary_efc,
                  10, isir.sec_alternate_month_10,
                  11, isir.sec_alternate_month_11,
                  12, isir.sec_alternate_month_12
               ),
               DECODE (
                  cp_months_num,
                  1, isir.primary_alternate_month_1,
                  2, isir.primary_alternate_month_2,
                  3, isir.primary_alternate_month_3,
                  4, isir.primary_alternate_month_4,
                  5, isir.primary_alternate_month_5,
                  6, isir.primary_alternate_month_6,
                  7, isir.primary_alternate_month_7,
                  8, isir.primary_alternate_month_8,
                  9, isir.primary_efc,
                  10, isir.primary_alternate_month_10,
                  11, isir.primary_alternate_month_11,
                  12, isir.primary_alternate_month_12
               )
            ) efc
       FROM igf_ap_isir_matched isir
      WHERE isir.isir_id = cp_isir_id;

  BEGIN

    OPEN c_isir_id( l_base_id );
    FETCH c_isir_id INTO l_isir_id ;

    IF c_isir_id%NOTFOUND THEN
      l_efc_f    := NULL;
      l_pell_efc := NULL;
      l_efc_ay   := NULL;

    ELSE

      l_efc_f    := NULL;
      l_pell_efc := NULL;
      l_efc_ay   := NULL;
      --
      -- Derive the NON-PELL EFC
      --

      /*
        If primary_efc is zero and auto_zero_efc='Y', then EFC for all months should be zero
      */
      IF l_isir_id.primary_efc = 0 AND NVL(l_isir_id.auto_zero_efc,'*') = 'Y' THEN
        l_efc_f := 0;
        l_pell_efc := 0;
        l_efc_ay := 0;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.get_fed_efc.debug','since auto_zero_efc=Y, returning zero');
        END IF;
        RETURN;
      END IF;

      -- Get the Awarding Family contribution type to corresponsing months EFC
      lv_awd_fmly_contrib_type := NULL;
      OPEN get_awd_fmly_contrib_type(l_base_id);
      FETCH get_awd_fmly_contrib_type INTO lv_awd_fmly_contrib_type;
      CLOSE get_awd_fmly_contrib_type;

      l_coa_months := igf_aw_coa_gen.coa_duration(l_base_id,l_awd_prd_code);
      IF l_coa_months > 12 OR l_coa_months < 0 THEN
        l_coa_months := 12;
      END IF;

      IF l_coa_months IS NULL OR l_coa_months = 0 THEN
        l_efc_f    := NULL;
        l_efc_ay   := NULL;
      ELSE
        -- If the EFC Type is set to SECONDARY, then use Seconday months, else use Primary months
        OPEN c_efc(l_isir_id.isir_id,l_coa_months,lv_awd_fmly_contrib_type);
        FETCH c_efc INTO l_efc_ay;
        CLOSE c_efc;
      END IF;
      --
      -- Derive the PELL EFC
      --
      lc_pell_efc := NULL;
      OPEN c_pell_efc( l_base_id );
      FETCH c_pell_efc INTO lc_pell_efc;
      IF c_pell_efc%FOUND THEN
        l_pell_efc := lc_pell_efc.pell_efc;
      END IF;
      CLOSE c_pell_efc;

    END IF;
    CLOSE c_isir_id ;

    IF l_awd_prd_code IS NOT NULL THEN
      l_efc_f := igf_aw_gen_004.efc_f(l_base_id,l_awd_prd_code);
    ELSE
      l_efc_f := NULL;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.get_fed_efc.debug','l_efc_f: '||l_efc_f||' l_pell_efc: '||l_pell_efc);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AW_PACKNG_SUBFNS.GET_FED_EFC '||SQLERRM);
      IGS_GE_MSG_STACK.ADD;
      l_efc_f    := NULL;
      l_pell_efc := NULL;
      l_efc_ay   := NULL;
  END get_fed_efc;


FUNCTION get_class_stnd(
                        p_base_id     IN  igf_ap_fa_base_rec.base_id%TYPE,
                        p_person_id   IN  igf_ap_fa_base_rec.person_id%TYPE,
                        p_adplans_id  IN  NUMBER,
                        p_award_id    IN  igf_aw_award_all.award_id%TYPE,
                        p_course_type OUT NOCOPY igs_ps_ver_all.course_type%TYPE,
                        p_awd_period  IN igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL,
                        p_called_from IN VARCHAR2 DEFAULT 'NON-PACKAGING'
                       ) RETURN CHAR IS

  /*
  ||  Created By : skoppula
  ||  Created On : 29-MAY-2002
  ||  Purpose : This function checks whether the minimum start date of the load calendar
  ||            that is attached to the fund falls with in the current term. If it falls
  ||            then it returns the actual class standig, otherwise it returns the class
  ||            standing as on the minimum start date of the load calendar
  ||            that is attached to the fund
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  museshad      21-Oct-2005     Added the check to ensure that p_award_id is not null when
  ||                                deriving Class Standing.
  ||  museshad      16-Sep-2005     Bug 4604393
  ||                                Modified the logic for deriving predictive/actual Class Standing
  ||  museshad      02-Jun-2005     Build# FA157 - Bug# 4382371.
  ||                                Use anticipated data for Class Standing and Program type if actual
  ||                                data is not available, when called from Packaging
  ||                                concurent process.
  ||                                Added the parameters - p_awd_period, p_called_from in the signature
  ||  bkkumar       14-Jan-04       Bug# 3360702
  ||                                Added one new award_id parameter and changed the fund_id parameter to adplans_id
  ||
  ||  veramach      11-NOV-2003     FA 125 Multiple distribution methods
  ||                                1.Changed function signature to take adplans_id instead of fund_id
  ||                                2.Award start date is chosen based on distribution plan setup instead of fund setup
  ||  rasahoo       01-09-2003      Removed cursor C_GET_PROG and all its references.
  ||                                called genric API to get the values of coloumns used in cursor C_GET_PROG
  ||
  ||  brajendr      20-Dec-2002     Bug # 2706197
  ||                                Modifed the logic for get class standing process, removed the return statement.
  */

   -- Cursor that fetches the key program from fa base h

   l_acad_cal_type      igs_ca_inst.cal_type%TYPE;
   l_acad_seq_num       igs_ca_inst.sequence_number%TYPE;
   l_message            VARCHAR2(4000);

   -- Cursor that fetched the current enrolled term for
   -- student
   CURSOR c_enrl_dtl_cur IS SELECT
        ci.cal_type        enrl_load_cal_type,
        ci.sequence_number enrl_load_seq_num ,
        ci.alternate_code  enrolled_term ,
  TRUNC(ci.start_dt) enrolled_start_dt,
  TRUNC(ci.end_dt)   enrolled_end_dt
        FROM
        igs_ca_inst ci,
        igs_ca_type cty
        WHERE cty.s_cal_cat = 'LOAD'
        AND   cty.cal_type  = ci.cal_type
        AND   (ci.cal_type, ci.sequence_number)
        IN
        (
                SELECT sup_cal_type,
                sup_ci_sequence_number
                FROM igs_ca_inst_rel
                WHERE sub_cal_type           = l_acad_cal_type
                AND   sub_ci_sequence_number = l_acad_seq_num
                UNION
                SELECT sub_cal_type,
                sub_ci_sequence_number
                FROM igs_ca_inst_rel
                WHERE sup_cal_type           = l_acad_cal_type
                AND   sup_ci_sequence_number = l_acad_seq_num
        )
        AND
        TRUNC(SYSDATE) BETWEEN TRUNC(ci.start_dt) AND TRUNC(ci.end_dt)
        ORDER BY ci.start_dt;

  l_enrl_dt_rec           c_enrl_dtl_cur%ROWTYPE;

  CURSOR c_get_awd_dt(
                      cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE
                     ) IS
    SELECT MIN(terms.start_date) start_dt
      FROM igf_aw_dp_terms_v terms
     WHERE terms.adplans_id = cp_adplans_id;

  CURSOR c_get_min_date(
                          cp_award_id igf_aw_award_all.award_id%TYPE
                         )IS
    SELECT igf_aw_packaging.get_term_start_date(awd.base_id, disb.ld_cal_type, disb.ld_sequence_number) start_dt
      FROM igf_aw_awd_disb_v disb,
           igf_aw_award_all awd
     WHERE disb.award_id = cp_award_id
       AND disb.award_id = awd.award_id
    ORDER BY igf_aw_packaging.get_term_start_date(awd.base_id, disb.ld_cal_type, disb.ld_sequence_number);

   -- museshad (Bug# 4604393)
   -- Get the start date of the earliest term in the (COA + DP) matching terms
   CURSOR c_get_ear_term_st_date(
                                  cp_base_id          igf_ap_fa_base_rec_all.base_id%TYPE,
                                  cp_adplans_id       NUMBER
                                )
   IS
      SELECT  igf_aw_packaging.get_term_start_date(cp_base_id, dp_terms.ld_cal_type, dp_terms.ld_sequence_number) ear_term_start_date
      FROM
              igf_aw_coa_term_tot_v coa_terms,
              igf_aw_dp_terms dp_terms,
              igf_aw_awd_dist_plans adplans
      WHERE
              dp_terms.ld_cal_type         =   coa_terms.ld_cal_type
        AND   dp_terms.ld_sequence_number  =   coa_terms.ld_sequence_number
        AND   dp_terms.adplans_id          =   adplans.adplans_id
        AND   coa_terms.base_id            =   cp_base_id
        AND   dp_terms.adplans_id          =   cp_adplans_id
      ORDER BY igf_aw_packaging.get_term_start_date(cp_base_id, dp_terms.ld_cal_type, dp_terms.ld_sequence_number) ASC;

   -- Get the start date of the earliest term in the DP matching terms
   CURSOR c_get_ear_term_st_date_dp(
                                    cp_base_id          igf_ap_fa_base_rec_all.base_id%TYPE,
                                    cp_adplans_id       igf_aw_awd_dist_plans.adplans_id%TYPE
                                   ) IS
     SELECT igf_aw_packaging.get_term_start_date(cp_base_id, dp_terms.ld_cal_type, dp_terms.ld_sequence_number) ear_term_start_date
       FROM igf_aw_dp_terms dp_terms,
            igf_aw_awd_dist_plans adplans
      WHERE dp_terms.adplans_id = adplans.adplans_id
        AND dp_terms.adplans_id = cp_adplans_id
      ORDER BY igf_aw_packaging.get_term_start_date(cp_base_id, dp_terms.ld_cal_type, dp_terms.ld_sequence_number) ASC;

  -- Gets start date of the eariest term in the award
  CURSOR c_get_ear_term_st_date_awd(
                                    cp_award_id igf_aw_award_all.award_id%TYPE
                                   ) IS
    SELECT igf_aw_packaging.get_term_start_date(awd.base_id, disb.ld_cal_type, disb.ld_sequence_number) ear_term_start_date
    FROM igf_aw_awd_disb_all disb,
           igf_aw_award_all awd
    WHERE awd.award_id = cp_award_id
       AND awd.award_id = disb.award_id
    ORDER BY igf_aw_packaging.get_term_start_date(awd.base_id, disb.ld_cal_type, disb.ld_sequence_number) ASC;

   l_ear_term_start_date    DATE;
   l_pred_flag              VARCHAR2(1);
   -- museshad (Bug# 4604393)

   l_awd_dt_rec            c_get_awd_dt%ROWTYPE;
   l_class_standing        igs_pr_css_class_std_v.class_standing%TYPE := NULL;
   l_course_cd             VARCHAR2(10);
   l_ver_number            NUMBER;

   -- Getting anticipated Class standing
   -- Scans all the terms (starting from the earliest) in the awarding period
   -- for a valid anticipated class standing. The first term that has a valid anticipated
   -- class standing data is taken into consideration. The ROWNUM predicate is
   -- added to avoid scanning other terms in the awarding period.
   CURSOR c_get_ant_class_stnd(
                                cp_base_id          igf_ap_fa_base_rec_all.base_id%TYPE,
                                cp_awd_per          igf_aw_awd_prd_term.award_prd_cd%TYPE
                              )
   IS
      SELECT ant_data.class_standing class_standing,
             ant_data.ld_cal_type load_cal_type,
             ant_data.ld_sequence_number load_seq_num
      FROM
            igf_aw_awd_prd_term awd_per,
            igs_ca_inst_all cal_inst,
            igf_ap_fa_ant_data ant_data,
            igf_ap_fa_base_rec_all fabase
      WHERE
            awd_per.ld_cal_type         =   cal_inst.cal_type           AND
            awd_per.ld_sequence_number  =   cal_inst.sequence_number    AND
            ant_data.ld_cal_type        =   awd_per.ld_cal_type         AND
            ant_data.ld_sequence_number =   awd_per.ld_sequence_number  AND
            awd_per.ci_cal_type         =   fabase.ci_cal_type          AND
            awd_per.ci_sequence_number  =   fabase.ci_sequence_number   AND
            fabase.base_id              =   cp_base_id                  AND
            awd_per.award_prd_cd        =   cp_awd_per                  AND
            ant_data.base_id            =   cp_base_id                  AND
            ant_data.class_standing IS NOT NULL
      ORDER BY igf_aw_packaging.get_term_start_date(cp_base_id, awd_per.ld_cal_type, awd_per.ld_sequence_number) ASC;

   l_get_ant_class_stnd_rec c_get_ant_class_stnd%ROWTYPE;

   -- Getting anticipated Prog type
   -- Scans all the terms (starting from the earliest) in the awarding period
   -- for a valid anticipated Prog type. The first term that has a valid anticipated
   -- Prog type data is taken into consideration. The ROWNUM predicate is
   -- added to avoid scanning other terms in the awarding period.
   CURSOR c_get_ant_prog_type(
                                cp_base_id          igf_ap_fa_base_rec_all.base_id%TYPE,
                                cp_awd_per          igf_aw_awd_prd_term.award_prd_cd%TYPE
                              )
   IS
      SELECT ant_data.program_type prog_type,
             ant_data.ld_cal_type load_cal_type,
             ant_data.ld_sequence_number load_seq_num
      FROM
            igf_aw_awd_prd_term awd_per,
            igs_ca_inst_all cal_inst,
            igf_ap_fa_ant_data ant_data,
            igf_ap_fa_base_rec_all fabase
      WHERE
            awd_per.ld_cal_type         =   cal_inst.cal_type           AND
            awd_per.ld_sequence_number  =   cal_inst.sequence_number    AND
            ant_data.ld_cal_type        =   awd_per.ld_cal_type         AND
            ant_data.ld_sequence_number =   awd_per.ld_sequence_number  AND
            awd_per.ci_cal_type         =   fabase.ci_cal_type          AND
            awd_per.ci_sequence_number  =   fabase.ci_sequence_number   AND
            fabase.base_id              =   cp_base_id                  AND
            awd_per.award_prd_cd        =   cp_awd_per                  AND
            ant_data.base_id            =   cp_base_id                  AND
            ant_data.program_type IS NOT NULL
      ORDER BY igf_aw_packaging.get_term_start_date(cp_base_id, awd_per.ld_cal_type, awd_per.ld_sequence_number) ASC;

   l_get_ant_prog_type_rec c_get_ant_prog_type%ROWTYPE;

   -- Get the award year Calendar details
   CURSOR c_get_cal_det(cp_base_id  igf_ap_fa_base_rec.base_id%TYPE)
   IS
      SELECT ci_cal_type, ci_sequence_number
      FROM igf_ap_fa_base_rec
      WHERE base_id = cp_base_id;

   l_get_cal_det_rec  c_get_cal_det%ROWTYPE;
   l_ld_cal_type      igs_ca_inst.cal_type%TYPE;
   l_ld_seq_num       igs_ca_inst.sequence_number%TYPE;

BEGIN

   -- Call generic API get_key_program to get the cource code
   igf_ap_gen_001.get_key_program(p_base_id,l_course_cd,l_ver_number);
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.get_class_stnd.debug',
                              'key_program_course_cd:'||l_course_cd||'key_program_version_number'||l_ver_number);
   END IF;
   igs_en_gen_015.get_academic_cal( p_person_id,l_course_cd,l_acad_cal_type,l_acad_seq_num,l_message);
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.get_class_stnd.debug',
                    'l_acad_cal_type:'||l_acad_cal_type||'l_acad_seq_num'||l_acad_seq_num||'l_message'||l_message);
   END IF;


  OPEN c_enrl_dtl_cur;
  FETCH c_enrl_dtl_cur INTO l_enrl_dt_Rec;
  CLOSE c_enrl_dtl_cur;

  -- if the adplans_id is null use the award_id parameter otherwise adplans_id
  IF p_adplans_id IS NULL THEN
    OPEN c_get_min_date(p_award_id);
    FETCH c_get_min_date INTO l_awd_dt_rec;
    IF c_get_min_date%NOTFOUND THEN
      CLOSE c_get_min_date;
      RETURN l_class_standing;
    END IF;
    CLOSE c_get_min_date;

  ELSE
    OPEN c_get_awd_dt(p_adplans_id);
    FETCH c_get_awd_dt INTO l_awd_dt_rec;
    IF c_get_awd_dt%NOTFOUND THEN
      CLOSE c_get_awd_dt;
       RETURN l_class_standing;
    END IF;
    CLOSE c_get_awd_dt;
  END IF;

  -- museshad (Bug# 4604393)
  -- Derive Class Standing
  l_ear_term_start_date := NULL;
  IF igf_aw_gen_003.check_coa(p_base_id,p_awd_period) THEN
    OPEN c_get_ear_term_st_date(p_base_id, p_adplans_id);
    FETCH c_get_ear_term_st_date INTO l_ear_term_start_date;
    CLOSE c_get_ear_term_st_date;
  ELSE
    OPEN c_get_ear_term_st_date_dp(p_base_id, p_adplans_id);
    FETCH c_get_ear_term_st_date_dp INTO l_ear_term_start_date;
    CLOSE c_get_ear_term_st_date_dp;
  END IF;

  IF l_ear_term_start_date IS NOT NULL THEN

    IF l_ear_term_start_date > TRUNC(SYSDATE) THEN
      -- Predictive Class Standing
      l_pred_flag := 'Y';

      -- Log message
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,
                      'igf.plsql.igf_aw_packng_subfns.get_class_stnd.debug',
                      'Computing PREDICTIVE class standing for date ' || TO_CHAR(l_ear_term_start_date, 'DD-MON-YYYY'));
      END IF;
    ELSE
      -- Actual Class Standing
      l_pred_flag := 'N';

      -- Log message
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,
                      'igf.plsql.igf_aw_packng_subfns.get_class_stnd.debug',
                      'Computing ACTUAL class standing for date ' || TO_CHAR(l_ear_term_start_date, 'DD-MON-YYYY'));
      END IF;
    END IF;

    -- Get Class Standing
    l_class_standing := igs_pr_get_class_std.get_class_standing(
                                                                p_person_id               =>  p_person_id,
                                                                p_course_cd               =>  l_course_cd,
                                                                p_predictive_ind          =>  l_pred_flag,
                                                                p_effective_dt            =>  l_ear_term_start_date,
                                                                p_load_cal_type           =>  NULL,
                                                                p_load_ci_sequence_number =>  NULL
                                                               );

    -- Log message
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,
                    'igf.plsql.igf_aw_packng_subfns.get_class_stnd.debug',
                    'Class Standing= ' || l_class_standing);
    END IF;
  ELSIF p_award_id IS NOT NULL THEN
    /*
      If terms cannot be found from adplans_id, use award_id
    */
    OPEN c_get_ear_term_st_date_awd(p_award_id);
    FETCH c_get_ear_term_st_date_awd INTO l_ear_term_start_date;
    CLOSE c_get_ear_term_st_date_awd;

    IF l_ear_term_start_date IS NOT NULL AND l_ear_term_start_date > TRUNC(SYSDATE) THEN
      l_pred_flag := 'Y';
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.get_class_stnd.debug','computing predictive class standing for'||TO_CHAR(l_ear_term_start_date));
      END IF;
    ELSE
      l_pred_flag := 'N';
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_packng_subfns.get_class_stnd.debug','computing actual class standing for'||TO_CHAR(l_ear_term_start_date));
      END IF;
    END IF;

    -- Get Class Standing
    l_class_standing := igs_pr_get_class_std.get_class_standing(
                                                                p_person_id               =>  p_person_id,
                                                                p_course_cd               =>  l_course_cd,
                                                                p_predictive_ind          =>  l_pred_flag,
                                                                p_effective_dt            =>  l_ear_term_start_date,
                                                                p_load_cal_type           =>  NULL,
                                                                p_load_ci_sequence_number =>  NULL
                                                               );
  END IF;
  -- museshad (Bug# 4604393)



  -- Call generic API get_enrl_program_type to get Program Type
  p_course_type := igf_ap_gen_001.get_enrl_program_type(p_base_id);

  -- If actual Prog type is not available, then get it from anticipated data
  -- We will get anticipated Prog type when -
  --  1. Enrollment (Actual) Prog type data is not available
  --     Note: We don't look into Admissions for Prog type, bcoz Admissions does not provide
  --           this information.
  --  2. Profile option permits to consider anticipated data
  --  3. Call is from Packaging concurent process
  IF (p_course_type IS NULL) AND (igf_aw_coa_gen.canUseAnticipVal) AND (p_called_from = 'PACKAGING') THEN

      -- Anticipated data is defined at the term level. But the Packaging concurrent process
      -- works at the awarding period level. We will scan each term (starting from the earliest)
      -- in the awarding period and get its anticipated data. If Prog type is found for a
      -- term, we will not consider the remaining terms.

      OPEN c_get_ant_prog_type(
                                 cp_base_id          =>  p_base_id,
                                 cp_awd_per          =>  p_awd_period
                               );
      FETCH c_get_ant_prog_type INTO l_get_ant_prog_type_rec;

      IF (c_get_ant_prog_type%FOUND) THEN
        -- Found anticipated Prog type
        p_course_type := l_get_ant_prog_type_rec.prog_type;

        -- Log message
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,
                        'igf.plsql.igf_aw_packng_subfns.get_class_stnd.debug',
                        'Actual Prog type not available, but found anticipated Prog type.');
          fnd_log.string(fnd_log.level_statement,
                        'igf.plsql.igf_aw_packng_subfns.get_class_stnd.debug',
                        'Base Id: ' ||NVL(p_base_id,'')|| '. Anticipated Prog type=' ||p_course_type|| ', Term cal type=' ||l_get_ant_prog_type_rec.load_cal_type|| ', Term sequence number=' ||l_get_ant_prog_type_rec.load_seq_num);
        END IF;
      ELSE
        -- Anticipated Prog type is not defined in
        -- any of the terms in the awarding period.
        p_course_type := NULL;

        -- Log message
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,
                        'igf.plsql.igf_aw_packng_subfns.get_class_stnd.debug',
                        'Both actual and anticipated Prog type is not available for - ' ||'Base Id: ' ||NVL(p_base_id,'')|| ' for any of the terms in the awarding period: ' ||p_awd_period);
        END IF;
      END IF;   -- End (c_get_ant_prog_type%FOUND)

      CLOSE c_get_ant_prog_type;
  END IF;

  -- If actual Class Standing is not available, then get it from anticipated data
  -- We will get anticipated Class Standing when -
  --  1. Enrollment (Actual) Class Standing data is not available
  --     Note: We don't look into Admissions for Class Standing, bcoz Admissions does not provide
  --           this information.
  --  2. Profile option permits to consider anticipated data
  --  3. Call is from Packaging concurent process
  IF (l_class_standing IS NULL) AND (igf_aw_coa_gen.canUseAnticipVal) AND (p_called_from = 'PACKAGING') THEN

    -- Anticipated data is defined at the term level. But the Packaging concurrent process
    -- works at the awarding period level. We will scan each term (starting from the earliest)
    -- in the awarding period and get its anticipated data. If class standing is found for a
    -- term, we will not consider the remaining terms.

    OPEN c_get_ant_class_stnd(
                               cp_base_id          =>  p_base_id,
                               cp_awd_per          =>  p_awd_period
                             );
    FETCH c_get_ant_class_stnd INTO l_get_ant_class_stnd_rec;

    IF (c_get_ant_class_stnd%FOUND) THEN
      -- Found anticipated Class Standing
      l_class_standing := l_get_ant_class_stnd_rec.class_standing;

      -- Log message
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,
                      'igf.plsql.igf_aw_packng_subfns.get_class_stnd.debug',
                      'Actual class standing data not available, but found anticipated class standing.');
        fnd_log.string(fnd_log.level_statement,
                      'igf.plsql.igf_aw_packng_subfns.get_class_stnd.debug',
                      'Base Id: ' ||NVL(p_base_id,'')|| '. Anticipated class standing =' ||l_class_standing|| ', Term cal type=' ||l_get_ant_class_stnd_rec.load_cal_type|| ', Term sequence number=' ||l_get_ant_class_stnd_rec.load_seq_num);
      END IF;

      CLOSE c_get_ant_class_stnd;
      RETURN l_class_standing;
    END IF;
    CLOSE c_get_ant_class_stnd;

    -- Anticipated class standing is not defined in any of the terms in the
    -- awarding period.
    l_class_standing := NULL;

    -- Log message
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,
                    'igf.plsql.igf_aw_packng_subfns.get_class_stnd.debug',
                    'Both actual and anticipated class standing is not available for - ' ||'Base Id: ' ||NVL(p_base_id,'')|| ' for any of the terms in the awarding period: ' ||p_awd_period);
    END IF;
  END IF;   -- End of (l_class_standing IS NULL) AND (igf_aw_coa_gen.canUseAnticipVal) AND (p_called_from = 'PACKAGING')

  RETURN l_class_standing;
END get_class_stnd;

FUNCTION is_over_award_occured(
                               p_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
                               p_mthd_type    VARCHAR2 ,
                               p_awd_prd_code igf_aw_awd_prd_term.award_prd_cd%TYPE
                              ) RETURN BOOLEAN AS
------------------------------------------------------------------
--Created by  : veramach, Oracle India
--Date created: 07-OCT-2003
--
--Purpose: To check if over award occurs for a person
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-------------------------------------------------------------------

l_unmetneed NUMBER;
l_award     NUMBER;

BEGIN
  l_unmetneed := NULL;
  l_award     := NULL;

  l_unmetneed := igf_aw_gen_004.unmetneed_f(p_base_id,p_awd_prd_code);
  l_award     := igf_aw_coa_gen.award_amount(p_base_id,p_awd_prd_code);

  IF NVL(p_mthd_type,'ISIR') = 'ISIR' THEN
    IF NVL(l_award,0) <> 0 AND l_unmetneed < 0 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  ELSIF NVL(p_mthd_type,'ISIR') = 'PROFILE' THEN
    IF NVL(l_award,0) <> 0 AND l_unmetneed < 0 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END IF;

END is_over_award_occured;

END igf_aw_packng_subfns;

/
