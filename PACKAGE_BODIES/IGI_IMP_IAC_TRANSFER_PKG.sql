--------------------------------------------------------
--  DDL for Package Body IGI_IMP_IAC_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IMP_IAC_TRANSFER_PKG" AS
-- $Header: igiimtdb.pls 120.39.12000000.2 2007/10/16 14:28:21 sharoy ship $

    --
    -- Define Global Package Variables
    --
    GLOBAL_CURRENT_PROC        VARCHAR2(50) ;
    IGI_IMP_TFR_ERROR          EXCEPTION ;


 --===========================FND_LOG.START=====================================

 g_state_level NUMBER;
 g_proc_level  NUMBER;
 g_event_level NUMBER;
 g_excep_level NUMBER;
 g_error_level NUMBER;
 g_unexp_level NUMBER;
 g_path        VARCHAR2(100);

 --===========================FND_LOG.END=======================================


    PROCEDURE set_interface_ctrl_status( p_book_type_code VARCHAR2 ,
                                         p_category_id    NUMBER ,
                                         p_status         VARCHAR2
                                     )
    IS
    BEGIN

        UPDATE igi_imp_iac_interface_ctrl ct
        SET    ct.transfer_status = p_status
        WHERE  ct.book_type_code  = p_book_type_code
        AND    ct.category_id     = p_category_id ;


        RETURN ;

    EXCEPTION
        WHEN OTHERS THEN
              igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => g_path||'set_interface_ctrl_status');
	      raise igi_imp_tfr_error ;
    END;

FUNCTION Validate_Assets(p_book_type_code in VARCHAR2,
                             p_category_id NUMBER)
RETURN BOOLEAN AS
  CURSOR C_Assets
  IS
  SELECT *
  FROM   igi_imp_iac_interface ii
  WHERE  ii.book_type_code   = p_book_type_code
    AND  ii.category_id      = p_Category_id
    AND  ii.transferred_flag = 'N'
    AND  nvl(ii.valid_flag,'N')      = 'N';

        -- Variables

  l_assets_valid              BOOLEAN;
  cumm_reval_rate             NUMBER;
  total_depreciation          NUMBER;
  l_deprn_per_period_hist     NUMBER;
  l_remaining_periods         NUMBER;
  l_elapsed_periods           NUMBER;
  l_elapsed_periods_curr_yr   NUMBER;
  l_max_backlog               NUMBER;
  l_adjusted_cost             NUMBER;
  l_general_fund              NUMBER;
  l_reval_reserve             NUMBER;
  l_deprn_exp_mhca            NUMBER;
  l_ytd_mhca                  NUMBER;
  l_min_backlog               NUMBER;
  l_operating_account_cost    NUMBER;
  l_operating_account_backlog NUMBER;
  l_depreciate                VARCHAR2(3);
  l_salvage_correction        NUMBER;

  l_errbuf                    VARCHAR2(250);

BEGIN
   l_assets_valid := TRUE;

   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		          p_full_path => g_path||'Validate_Assets',
		          p_string => 'Starting Assets Validation');

          fnd_file.put_line(fnd_file.log, 'The following assets are invalid:');

 FOR arec in C_Assets LOOP

    SELECT depreciate_flag
    INTO l_depreciate
    FROM fa_books
    WHERE book_type_code = arec.book_type_code
    AND asset_id = arec.asset_id
    AND date_ineffective is NULL;               -- Bug 5383551

     cumm_reval_rate := arec.cost_mhca / arec.cost_hist ;

    IF ( arec.hist_salvage_value <> 0) THEN
    	l_salvage_correction := 1 + (arec.hist_salvage_value / (arec.cost_hist - arec.hist_salvage_value ));
    ELSE
	    l_salvage_correction := 1;
    END IF;

    total_depreciation := arec.accum_deprn_hist * (cumm_reval_rate-1) * l_salvage_correction + arec.accum_deprn_hist;

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		          p_full_path => g_path||'Validate_Assets',
		          p_string => 'Processing Asset: '||arec.asset_id);

    IF upper(l_depreciate) = 'NO' THEN

	   IF(arec.backlog_mhca <> 0 OR arec.accum_deprn_mhca <> 0) THEN
             igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		      p_full_path => g_path||'Validate_Assets',
		      p_string => 'Error: Non_Depreciating asset provided with Depreciation figures');

            FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_NON _DEP');
            l_errbuf := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

       	    l_assets_valid := FALSE;
       	    goto Next_Record;
	   END IF;
--
-- Bug 5393607
-- ==========
-- Downward revaluation forces following check to fail.
/**************************************************
    ELSE

         IF ( ( (arec.backlog_mhca + arec.accum_deprn_mhca) > (total_depreciation + 0.02) )OR
    	   ((arec.backlog_mhca + arec.accum_deprn_mhca) < (total_depreciation - 0.02) )) THEN

             igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		      p_full_path => g_path||'Validate_Assets',
		      p_string => 'Error: Sum of Backlog Accumulated Depreciation and'||
                   'Revalued Accumulated Depreciation not correct.');

            FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_INV_DEP_RATIO');
            l_errbuf := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

       	    l_assets_valid := FALSE;
       	    goto Next_Record;
        END IF;
********************************************/
    END IF;

    SELECT decode(
             fab.conversion_date,
             NULL,
             fab.life_in_months - floor(months_between(
                fdp.CALENDAR_PERIOD_CLOSE_DATE,
                fab.prorate_date)),
             fab.life_in_months - floor(months_between(
                fdp.CALENDAR_PERIOD_CLOSE_DATE,
                fab.deprn_start_date)))
    INTO   l_remaining_periods
    FROM   fa_books fab, fa_deprn_periods fdp
    WHERE  fab.book_type_code = arec.book_type_code
    AND    fdp.book_type_code = arec.book_type_code
    AND    fab.asset_id = arec.asset_id
    AND    fab.date_ineffective is null
    AND    fdp.PERIOD_CLOSE_DATE is null;

    IF (l_remaining_periods <= 0) THEN
	   l_remaining_periods := 0;
    	l_elapsed_periods := arec.life_in_months;
    ELSE
	   l_elapsed_periods := arec.life_in_months - l_remaining_periods;
    END IF;

     l_deprn_per_period_hist := arec.accum_deprn_hist / l_elapsed_periods;

     SELECT (period_num - 1)
     INTO l_elapsed_periods_curr_yr
     FROM fa_deprn_periods
     WHERE book_type_code = arec.book_type_code
       AND PERIOD_CLOSE_DATE IS NULL;

     IF (cumm_reval_rate > 1) THEN

      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
      p_full_path => g_path||'Validate_Assets',
      p_string => 'Revalued cost > Historic Cost');

        /**************************************************
        IF (arec.backlog_mhca < 0) THEN

           igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
           p_full_path => g_path||'Validate_Assets',
  	       p_string => 'Error: Backlog Accumulated Depreciation has to be greater' ||
             ' than or equal to zero, when revalued cost is greater than historic cost.');

           FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_BACKLOG_NEG');
           l_errbuf := FND_MESSAGE.GET;
           fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

           l_assets_valid := FALSE;
       	   goto Next_Record;
        END IF;
        ***************************************************/

        IF (arec.operating_account_cost <> 0) THEN

           igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
           p_full_path => g_path||'Validate_Assets',
  	       p_string => 'Error: Operating Account must be 0. ');

           FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_OP_COST_NOT_ZERO');
           l_errbuf := FND_MESSAGE.GET;
           fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

           l_assets_valid := FALSE;
       	   goto Next_Record;
        END IF;

        l_max_backlog := (cumm_reval_rate - 1) * (l_elapsed_periods - l_elapsed_periods_curr_yr) * l_deprn_per_period_hist;

        /*************************************************
          IF (arec.backlog_mhca > (l_max_backlog + 0.1)) THEN

          igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
          p_full_path => g_path||'Validate_Assets',
	      p_string => 'Error: Backlog value greater than the max value permissable');

           FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_MAX_BACKLOG');
           l_errbuf := FND_MESSAGE.GET;
           fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

           l_assets_valid := FALSE;
   	       goto Next_Record;
        END IF;
        ***************************************************/

        IF (arec.operating_account_backlog = 0) THEN -- Upliftment

          igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
          p_full_path => g_path||'Validate_Assets',
	      p_string => 'Asset has undergone Upliftment.');

           l_adjusted_cost := arec.cost_mhca - arec.cost_hist;

	       l_general_fund := arec.accum_deprn_mhca - arec.accum_deprn_hist;

	       IF ( (arec.general_fund_mhca > (l_general_fund + 0.1)) OR
                 (arec.general_fund_mhca < (l_general_fund - 0.1)) ) THEN

	          igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
              p_full_path => g_path||'Validate_Assets',
	          p_string => 'Error: Invalid value for General Fund');

              FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_INV_GEN_FUND');
              l_errbuf := FND_MESSAGE.GET;
              fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

		      l_assets_valid := FALSE;
		      goto Next_Record;
		   END IF;

	       l_reval_reserve := l_adjusted_cost - arec.backlog_mhca - arec.general_fund_mhca;

	       IF( (arec.reval_reserve_mhca > (l_reval_reserve + 0.1)) OR
              (arec.reval_reserve_mhca < (l_reval_reserve - 0.1)) )THEN

   	          igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
              p_full_path => g_path||'Validate_Assets',
	          p_string => 'Error: Invalid value for Reval Reserve');

              FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_INV_REVAL_RES');
              l_errbuf := FND_MESSAGE.GET;
              fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

		     l_assets_valid := FALSE;
          	 goto Next_Record;
     	   END IF;
       ELSE -- Mixed Revaluation, Cumm Reval Rate > 1

          igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
          p_full_path => g_path||'Validate_Assets',
          p_string => 'Asset has undergone Mixed Revaluation');

          /***********************************************************
          IF (arec.operating_account_backlog < 0) THEN

             igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
             p_full_path => g_path||'Validate_Assets',
             p_string => 'Error: Invalid value for Operating Account Backlog');

              FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_OP_BACKLOG_POS');
              l_errbuf := FND_MESSAGE.GET;
              fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

	        l_assets_valid := FALSE;
       	    goto Next_Record;

          END IF;
          ***********************************************************/

	      l_general_fund := arec.accum_deprn_mhca - arec.accum_deprn_hist +
                                                 arec.operating_account_backlog;

	      IF ( (arec.general_fund_mhca > (l_general_fund + 0.1))
                    OR (arec.general_fund_mhca < (l_general_fund - 0.1)) ) THEN

   	          igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
              p_full_path => g_path||'Validate_Assets',
	          p_string => 'Error: Invalid value for General Fund');

              FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_INV_GEN_FUND');
              l_errbuf := FND_MESSAGE.GET;
              fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

		     l_assets_valid := FALSE;
		     goto Next_Record;
		  END IF;

	      l_reval_reserve := l_adjusted_cost - arec.backlog_mhca -
                        arec.general_fund_mhca + arec.operating_account_backlog;

	      IF( (arec.reval_reserve_mhca > (l_reval_reserve + 0.1))
                 OR (arec.reval_reserve_mhca < (l_reval_reserve - 0.1)) )THEN

   	          igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
              p_full_path => g_path||'Validate_Assets',
	          p_string => 'Error: Invalid value for Reval Reserve');

              FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_INV_REVAL_RES');
              l_errbuf := FND_MESSAGE.GET;
              fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

		    l_assets_valid := FALSE;
            goto Next_Record;
		  END IF;
       END IF;

      l_deprn_exp_mhca := arec.deprn_exp_hist * cumm_reval_rate;

-- Commented the following YTD validation logic as part of fix for Bug 5372707

/********************************
      l_ytd_mhca := arec.ytd_hist + ( (l_deprn_exp_mhca - arec.deprn_exp_hist) *
                                                     l_elapsed_periods_curr_yr);

      IF ( (arec.ytd_mhca > (l_ytd_mhca + 0.1)) OR
                     (arec.ytd_mhca < (l_ytd_mhca - 0.1)) ) THEN

   	          igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
              p_full_path => g_path||'Validate_Assets',
	          p_string => 'Error: Invalid value for Revalued YTD Depreciation');

              FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_INV_YTD');
              l_errbuf := FND_MESSAGE.GET;
              fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

	     l_assets_valid := FALSE;
	     goto Next_Record;
	  END IF;
********************************/

-- End Bug 5372707

      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
      p_full_path => g_path||'Validate_Assets',
      p_string => 'Asset has valid values. Setting Valid_Flag to Y');

	  UPDATE igi_imp_iac_interface
	  SET deprn_exp_mhca = l_deprn_exp_mhca,
	      general_fund_per_mhca = arec.deprn_exp_mhca - arec.deprn_exp_hist,
              operating_account_mhca = (arec.operating_account_cost - arec.operating_account_backlog),
	      nbv_mhca = arec.cost_mhca - arec.accum_deprn_mhca - arec.backlog_mhca,
	      valid_flag ='Y'
      WHERE book_type_code = arec.book_type_code
      AND asset_id = arec.asset_id;

   ELSIF (cumm_reval_rate < 1) THEN

      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
      p_full_path => g_path||'Validate_Assets',
      p_string => 'Revalued cost < Historic Cost');

        /***************************************
        IF (arec.backlog_mhca > 0) THEN

           igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
           p_full_path => g_path||'Validate_Assets',
  	       p_string => 'Error: Backlog Accumulated Depreciation has to be less' ||
             ' than or equal to zero, when revalued cost is lesser than historic cost.');

           FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_BACKLOG_POS');
           l_errbuf := FND_MESSAGE.GET;
           fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

           l_assets_valid := FALSE;
       	   goto Next_Record;
        END IF;
        ***************************************/

	 IF (arec.reval_reserve_mhca <> 0) THEN

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
        p_full_path => g_path||'Validate_Assets',
        p_string => 'Error: Invalid value for Reval Reserve');

        FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_REVAL_RES_NOT_ZERO');
        l_errbuf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

		l_assets_valid := FALSE;
		goto Next_Record;
	 END IF;

	 l_min_backlog := (cumm_reval_rate - 1) * (l_elapsed_periods -
                          l_elapsed_periods_curr_yr) * l_deprn_per_period_hist;

        /*****************************************
        IF (arec.backlog_mhca < (l_min_backlog - 0.1)) THEN

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
        p_full_path => g_path||'Validate_Assets',
        p_string => 'Error: Backlog value less than permissable value');

        FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_MIN_BACKLOG');
        l_errbuf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

		l_assets_valid := FALSE;
		goto Next_Record;
 	 END IF;
        *******************************************/

	 IF ( arec.general_fund_mhca <> 0) THEN --Mixed Revaluation, Cumm Reval Rate < 1

       IF (arec.general_fund_mhca < 0) THEN

          igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
          p_full_path => g_path||'Validate_Assets',
          p_string => 'Error: Invalid value for General Fund');

          FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_GEN_FUND_NEG');
          l_errbuf := FND_MESSAGE.GET;
          fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

	     l_assets_valid := FALSE;
       	 goto Next_Record;

       END IF;

        l_operating_account_backlog := arec.backlog_mhca  + arec.general_fund_mhca;

        IF ( (arec.operating_account_backlog > (l_operating_account_backlog + 0.1)) OR
	   	   (arec.operating_account_backlog < (l_operating_account_backlog - 0.1)) ) THEN

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => g_path||'Validate_Assets',
            p_string => 'Error: Invalid value for Operating Account Backlog');

            FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_INV_OP_BACKLOG');
            l_errbuf := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

      	    l_assets_valid := FALSE;
		    goto Next_Record;
    	END IF;
	 ELSE -- Asset Impairment
        l_operating_account_backlog := arec.backlog_mhca;

    	IF ( (arec.operating_account_backlog > (l_operating_account_backlog + 0.1)) OR
	   	   (arec.operating_account_backlog < (l_operating_account_backlog - 0.1)) ) THEN

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => g_path||'Validate_Assets',
            p_string => 'Error: Invalid value for Operating Account Backlog');

            FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_INV_OP_BACKLOG');
            l_errbuf := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

  		    l_assets_valid := FALSE;
		    goto Next_Record;
    	END IF;
	 END IF;

	l_operating_account_cost := arec.cost_mhca - arec.cost_hist;

	IF ( (arec.operating_account_cost > (l_operating_account_cost + 0.1)) OR
		(arec.operating_account_cost < (l_operating_account_cost - 0.1)) ) THEN

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
        p_full_path => g_path||'Validate_Assets',
        p_string => 'Error: Invalid value for Operating Account Cost');

        FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_INV_OP_COST');
        l_errbuf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

		l_assets_valid := FALSE;
		goto Next_Record;
	END IF;

	  l_deprn_exp_mhca := arec.deprn_exp_hist * cumm_reval_rate;

-- Commented the following YTD validation logic as part of fix for Bug 5372707
/***********************************
	  l_ytd_mhca := arec.ytd_hist + ( (l_deprn_exp_mhca - arec.deprn_exp_hist) *
                                                   l_elapsed_periods_curr_yr);

	  IF ( (arec.ytd_mhca > (l_ytd_mhca + 0.1)) OR
            (arec.ytd_mhca < (l_ytd_mhca - 0.1)) ) THEN

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
        p_full_path => g_path||'Validate_Assets',
        p_string => 'Error: Invalid value for Revalued YTD Depreciation');

        FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_INV_YTD');
        l_errbuf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

		l_assets_valid := FALSE;
		goto Next_Record;
	  END IF;
************************************/

-- End Bug 5372707

      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
      p_full_path => g_path||'Validate_Assets',
      p_string => 'Asset has valid values. Setting Valid_Flag to Y');

 	 UPDATE igi_imp_iac_interface
     SET deprn_exp_mhca = l_deprn_exp_mhca,
         general_fund_per_mhca = arec.deprn_exp_mhca - arec.deprn_exp_hist,
         operating_account_mhca = (arec.operating_account_cost - arec.operating_account_backlog),
         nbv_mhca = arec.cost_mhca - arec.accum_deprn_mhca - arec.backlog_mhca,
         valid_flag = 'Y'
     WHERE book_type_code = arec.book_type_code
     AND asset_id = arec.asset_id;

   ELSE -- cumm_reval_rate = 1
	  IF (arec.reval_reserve_mhca <> 0) THEN

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
        p_full_path => g_path||'Validate_Assets',
        p_string => 'Error: Invalid value for Reval Reserve');

        FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_NET_RES_NOT_ZERO');
        l_errbuf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

		l_assets_valid := FALSE;
		goto Next_Record;
  	  END IF;

	/***************************************
         IF (arec.backlog_mhca <> 0) THEN

         igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
         p_full_path => g_path||'Validate_Assets',
         p_string => 'Error: Invalid value for Reval Backlog Depreciation');

        FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_ACC_BLOG_NOT_ZERO');
        l_errbuf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

		l_assets_valid := FALSE;
		goto Next_Record;
        END IF;
        ***************************************/

	  IF (arec.ytd_mhca <> arec.ytd_hist) THEN

         igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
         p_full_path => g_path||'Validate_Assets',
         p_string => 'Error: Invalid value for Revalued YTD Depreciation');

        FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_YTD_NOT_EQUAL');
        l_errbuf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

		l_assets_valid := FALSE;
		goto Next_Record;
      END IF;
     /**********************
      IF (arec.accum_deprn_mhca <> arec.accum_deprn_hist) THEN

         igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
         p_full_path => g_path||'Validate_Assets',
         p_string => 'Error: Invalid value for Revalued Accumulated Depreciation');

        FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_ACC_DEP_NOT_EQUAL');
        l_errbuf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

		l_assets_valid := FALSE;
		goto Next_Record;
 	  END IF;
       ***********************/
	  IF (arec.operating_account_cost <> 0) THEN

         igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
         p_full_path => g_path||'Validate_Assets',
         p_string => 'Error: Invalid value for Operating Account Cost');

        FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_OP_CST_NOT_ZERO');
        l_errbuf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

		l_assets_valid := FALSE;
		goto Next_Record;
	  END IF;
         /**************************
	  IF (arec.operating_account_backlog <> 0) THEN

         igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
         p_full_path => g_path||'Validate_Assets',
         p_string => 'Error: Invalid value for Operating Account Backlog');

        FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_OP_BLOG_NOT_ZERO');
        l_errbuf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

		l_assets_valid := FALSE;
		goto Next_Record;
	  END IF;
	  IF (arec.general_fund_mhca <> 0) THEN

         igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
         p_full_path => g_path||'Validate_Assets',
         p_string => 'Error: Invalid value for General Fund');

        FND_MESSAGE.SET_NAME('IGI', 'IGI_IMP_IAC_GEN_FUND_NOT_ZERO');
        l_errbuf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, arec.asset_id||': '||l_errbuf);

		 l_assets_valid := FALSE;
		 goto Next_Record;
	  END IF;
          **************************/

      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
      p_full_path => g_path||'Validate_Assets',
      p_string => 'Asset has valid values. Setting Valid_Flag to Y');

      UPDATE igi_imp_iac_interface
      SET deprn_exp_mhca = arec.deprn_exp_hist,
          operating_account_mhca = (arec.operating_account_cost - arec.operating_account_backlog),
          nbv_mhca = arec.nbv_hist,
          valid_flag = 'Y'
      WHERE book_type_code = arec.book_type_code
      AND asset_id = arec.asset_id;
   END IF;
   <<NEXT_RECORD>>
   null;
 END LOOP;

 COMMIT WORK;

 igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		          p_full_path => g_path||'Validate_Assets',
		          p_string => 'End of Asset Validation');

 RETURN l_assets_valid;

 EXCEPTION
    WHEN OTHERS THEN
       igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
	   p_full_path => g_path||'Validate_Assets',
	   p_string => 'Error while Validating assets..');

	   RETURN FALSE;
END Validate_Assets;

    FUNCTION Trxns_In_Open_Period(p_book_type_code in VARCHAR2)
    RETURN BOOLEAN AS

        CURSOR C_Fa_Period_Counter
        IS
        SELECT  max(period_counter)
        from fa_deprn_periods
        where book_type_code=p_book_type_code;

        CURSOR C_Imp_Period_Counter
        IS
        SELECT period_counter
        FROM igi_imp_iac_controls
        where book_type_code=p_book_type_code;

        CURSOR C_Trxn
        IS
        SELECT count(*)
        FROM   fa_transaction_headers ft ,
                  fa_deprn_periods dp
        WHERE  ft.book_type_Code        = P_book_type_code
        AND    dp.book_type_Code        = P_book_type_code
        AND    dp.period_close_Date     IS NULL
        AND    ft.date_effective        >= dp.period_open_date ;


       	--variables

       	l_fa_period_counter      NUMBER;
       	l_imp_period_counter     NUMBER;
       	l_count                  NUMBER;

    BEGIN

	OPEN C_Fa_Period_Counter;
	FETCH C_Fa_Period_Counter INTO l_fa_period_counter;
	CLOSE C_Fa_Period_Counter;

	OPEN C_Imp_Period_Counter;
	FETCH C_Imp_Period_Counter INTO l_imp_period_counter;
	CLOSE C_Imp_Period_Counter;

	IF (l_imp_period_counter<>l_fa_period_counter)
	THEN
	    RETURN FALSE;
	ELSE
	    --Check for trxns in open period
            OPEN  c_trxn;
            FETCH c_trxn INTO l_count;
            CLOSE c_trxn;

	    IF l_count>0 THEN
		RETURN FALSE;
	    ELSE
		RETURN TRUE;
	    END IF;
	END IF;

    EXCEPTION
	WHEN OTHERS THEN
	    igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => g_path||'trxns_in_open_period');
            RETURN FALSE ;
    END Trxns_In_Open_Period;

    FUNCTION   Prorate_for_Det_Balances (
                                    p_book_type_code          VARCHAR2 ,
                                    p_category_id             NUMBER   ,
                                    p_asset_id                NUMBER   ,
                                    p_net_book_value          NUMBER   ,
                                    p_adjusted_cost           NUMBER   ,
                                    p_operating_acct          NUMBER   ,
                                    p_reval_reserve           NUMBER   ,
                                    p_deprn_amount            NUMBER   ,
                                    p_ytd_deprn               NUMBER   ,
                                    p_deprn_reserve           NUMBER   ,
                                    p_backlog_deprn_reserve   NUMBER   ,
                                    p_general_fund            NUMBER   ,
                                    p_prd_rec                 igi_iac_types.prd_rec ,
                                    p_current_reval_factor    NUMBER   ,
                                    p_cumulative_reval_factor NUMBER   ,
                                    p_adj_id                  NUMBER   ,
                                    p_run_book                VARCHAR2   ,
                                    p_op_ac_cost              NUMBER   ,
                                    p_op_ac_backlog           NUMBER   ,
                                    p_hist_deprn_amount       NUMBER   ,
                                    p_hist_deprn_ytd          NUMBER   ,
                                    p_hist_deprn_reserve      NUMBER   ,
                                    p_errbuf        OUT NOCOPY       VARCHAR2 )
    RETURN BOOLEAN AS

    --
    --  Variables to store values remaining after allocating to det balances
    --

    CURSOR C_fiscal_year(p_period_counter in NUMBER)
    IS
    SELECT fiscal_year
    FROM  fa_deprn_periods
    WHERE book_type_code = p_book_type_code AND
          period_counter = p_period_counter-1;

    CURSOR  C_all_dist( p_fiscal_year in NUMBER)
    IS
    SELECT
    	dh.units_assigned,
    	dp.calendar_period_open_date,
	dp.period_counter,
	dh.distribution_id,
	dh.code_combination_id,
	dh.date_ineffective
    FROM
        fa_distribution_history dh,
	fa_deprn_periods  dp
    WHERE
          dh.asset_id= p_asset_id 				                AND
	  dh.book_type_code=p_book_type_code	 				AND
	  (nvl(dh.date_ineffective,dp.period_open_date)>=dp.period_open_date) 	AND
	  dp.Book_type_code=p_book_type_code 	        			AND
	  dp.fiscal_year=p_fiscal_year                   			AND
	  dp.period_num=(SELECT min(period_num)
	                 FROM fa_deprn_periods
               	         WHERE  fiscal_year=p_fiscal_year and
               	         	book_type_code=p_book_type_code);

    CURSOR C_period_counter
    IS
    SELECT  period_counter
    FROM    igi_imp_iac_controls
    WHERE   Book_Type_Code = p_run_book;

    CURSOR C_counter(p_distribution_id  in number
            	    ,p_fiscal_year   in   NUMBER)
    IS
    SELECT     dp.period_counter
    FROM       fa_deprn_periods dp,
               fa_distribution_history dh
    WHERE     (dh.date_ineffective between dp.period_open_date  and dp.period_close_date)      AND
               dp.book_type_code=p_book_type_code		        		       AND
               dp.fiscal_year=p_fiscal_year                                                    AND
               dh.book_type_code=p_book_type_code                                            AND
               dh.distribution_id=p_distribution_id;

    CURSOR C_ytd_dist(p_distribution_id in NUMBER)
    IS
    SELECT  ytd_deprn
    FROM    fa_deprn_detail
    WHERE
        distribution_id=p_distribution_id         AND
        book_type_code =p_book_type_code          AND
        asset_id  =p_asset_id                     AND
 -- Bug 3575041 start (1) --
        period_counter=(select max(period_counter)
				from fa_deprn_detail
				where distribution_id = p_distribution_id
				and   book_type_code  = p_book_type_code
		        and   asset_id        = p_asset_id ) ;

 -- Bug 3575041 start (1) --

    CURSOR C_ytd_asset(p_max_period_counter in number)
    IS
    SELECT    ytd_deprn
    FROM      fa_deprn_summary
    WHERE     asset_id=p_asset_id                AND
              book_type_code=p_book_type_code    AND
              period_counter=p_max_period_counter-1;

    CURSOR C_units
    IS
    SELECT current_units
    FROM fa_additions
    WHERE   asset_id=p_asset_id;

    CURSOR C_active_dists
    IS
    SELECT count(*)
    FROM   fa_distribution_history
    WHERE book_type_code=p_book_type_code    AND
          asset_id=p_asset_id		       AND
          date_ineffective IS NULL;

        l_net_book_value             NUMBER  ;
        l_adjusted_cost              NUMBER  ;
        l_operating_acct             NUMBER  ;
        l_reval_reserve              NUMBER  ;
        l_deprn_amount               NUMBER  ;
        l_ytd_deprn                  NUMBER  ;
        l_deprn_reserve              NUMBER  ;
        l_backlog_deprn_reserve      NUMBER  ;
        l_general_fund               NUMBER  ;
        l_op_ac_cost                 NUMBER  ;
        l_op_ac_backlog              NUMBER  ;
        l_hist_deprn_amount          NUMBER  ;
        l_hist_deprn_ytd             NUMBER  ;
        l_hist_deprn_reserve         NUMBER  ;
      	l_period_counter	     NUMBER  ;
     --
     --  Initialize the remaining values
     --
        l_rem_net_book_value          NUMBER;
        l_rem_adjusted_cost           NUMBER;
        l_rem_operating_acct          NUMBER;
        l_rem_reval_reserve           NUMBER;
        l_rem_deprn_amount            NUMBER;
        l_rem_deprn_reserve           NUMBER;
        l_rem_backlog_deprn_reserve   NUMBER;
        l_rem_general_fund            NUMBER;
        l_rem_op_ac_cost              NUMBER;
        l_rem_op_ac_backlog           NUMBER;
        l_rem_hist_deprn_amount       NUMBER;
        l_rem_hist_deprn_reserve      NUMBER;

    --
    --  Variables to store values to go into det balances
    --
        l_det_adjustment_cost            NUMBER;
        l_det_net_book_value             NUMBER;
        l_det_reval_reserve_cost         NUMBER;
        l_det_reval_reserve_backlog      NUMBER;
        l_det_reval_reserve_gen_fund     NUMBER;
        l_det_reval_reserve_net          NUMBER;
        l_det_operating_acct_cost        NUMBER;
        l_det_operating_acct_backlog     NUMBER;
        l_det_operating_acct_net         NUMBER;
        l_det_operating_acct_ytd         NUMBER;
        l_det_deprn_period               NUMBER;
        l_det_deprn_reserve              NUMBER;
        l_det_deprn_reserve_backlog      NUMBER;
        l_det_general_fund_per           NUMBER;
        l_det_general_fund_acc           NUMBER;
        l_det_last_reval_date            DATE  ;
        l_det_current_reval_factor       NUMBER;
        l_det_cumulative_reval_factor    NUMBER;
        l_det_op_ac_cost                 NUMBER;
        l_det_op_ac_backlog              NUMBER;
        l_det_hist_deprn_amount          NUMBER;
        l_det_hist_deprn_reserve         NUMBER;
        l_det_deprn_ytd                  NUMBER;
        l_det_hist_deprn_ytd             NUMBER;
    --
    --  Miscellaneous Variables
    --
        l_dists_processed                NUMBER;
        l_total_dists                    NUMBER;
        l_dists_tab                      igi_iac_types.dist_amt_tab ;
        l_prorate_factor                 NUMBER;
        l_ytd_prorate_factor	         NUMBER;
        l_out_rowid                      VARCHAR2(240) ;
    	l_fiscal_year			 NUMBER(4);
        l_max_period_counter	         NUMBER;
    	l_dist_ytd_deprn		 NUMBER;
    	l_asset_ytd_deprn		 NUMBER;
    	l_total_units			 NUMBER;
    	l_count				 NUMBER;
        l_inactive_counter		 NUMBER;
        l_flag   			 VARCHAR2(1);
        l_all_dist                       c_all_dist%rowtype;
        l_index                          NUMBER;

	l_YTD_prorate_dists_tab 	igi_iac_types.prorate_dists_tab;
	l_YTD_prorate_dists_idx 	binary_integer;
	idx_YTD            		binary_integer;

  -- Bug 3575041 start(2) --

   CURSOR C_Get_Deprn_Flag is
   SELECT depreciate_flag
   FROM FA_BOOKS
   WHERE book_type_code = p_book_type_code
   AND asset_id         = p_asset_id
   AND transaction_header_id_out is NULL;

  l_depreciate_flag FA_BOOKS.depreciate_flag%TYPE;

  -- Bug 3575041 end(2) --

   BEGIN

        l_net_book_value              := 0 ;
        l_adjusted_cost               := 0 ;
        l_operating_acct              := 0 ;
        l_reval_reserve               := 0 ;
        l_deprn_amount                := 0 ;
        l_ytd_deprn                   := 0 ;
        l_deprn_reserve               := 0 ;
        l_backlog_deprn_reserve       := 0 ;
        l_general_fund                := 0 ;
        l_op_ac_cost                  := 0 ;
        l_op_ac_backlog               := 0 ;
        l_hist_deprn_amount           := 0 ;
        l_hist_deprn_ytd              := 0 ;
        l_hist_deprn_reserve          := 0 ;
      	l_period_counter	      := p_prd_rec.period_counter;
     --
     --  Initialize the remaining values
     --
        l_rem_net_book_value          := p_net_book_value           ;
        l_rem_adjusted_cost           := p_adjusted_cost            ;
        l_rem_operating_acct          := p_operating_acct           ;
        l_rem_reval_reserve           := p_reval_reserve            ;
        l_rem_deprn_amount            := p_deprn_amount             ;
        l_rem_deprn_reserve           := p_deprn_reserve            ;
        l_rem_backlog_deprn_reserve   := p_backlog_deprn_reserve    ;
        l_rem_general_fund            := p_general_fund             ;
        l_rem_op_ac_cost              := p_op_ac_cost               ;
        l_rem_op_ac_backlog           := p_op_ac_backlog            ;
        l_rem_hist_deprn_amount       := p_hist_deprn_amount        ;
        l_rem_hist_deprn_reserve      := p_hist_deprn_reserve       ;

    --
    --  Variables to store values to go into det balances
    --
        l_det_adjustment_cost             := 0 ;
        l_det_net_book_value              := 0 ;
        l_det_reval_reserve_cost          := 0 ;
        l_det_reval_reserve_backlog       := 0 ;
        l_det_reval_reserve_gen_fund      := 0 ;
        l_det_reval_reserve_net           := 0 ;
        l_det_operating_acct_cost         := 0 ;
        l_det_operating_acct_backlog      := 0 ;
        l_det_operating_acct_net          := 0 ;
        l_det_operating_acct_ytd          := 0 ;
        l_det_deprn_period                := 0 ;
        l_det_deprn_reserve               := 0 ;
        l_det_deprn_reserve_backlog       := 0 ;
        l_det_general_fund_per            := 0 ;
        l_det_general_fund_acc            := 0 ;

        l_det_current_reval_factor        := 0 ;
        l_det_cumulative_reval_factor     := 0 ;
        l_det_op_ac_cost                  := 0 ;
        l_det_op_ac_backlog               := 0 ;
        l_det_hist_deprn_amount           := 0 ;
        l_det_hist_deprn_reserve          := 0 ;
        l_det_deprn_ytd                   := 0 ;
        l_det_hist_deprn_ytd              := 0 ;
    --
    --  Miscellaneous Variables
    --
        l_dists_processed                 := 0 ;
        l_total_dists                     := 0 ;
        l_prorate_factor                  := 0 ;
        l_ytd_prorate_factor	          :=0;

        l_index                           :=1;



        l_depreciate_flag  := NULL;


	OPEN C_PERIOD_COUNTER;
	FETCH C_PERIOD_COUNTER into l_max_period_counter;
	close c_period_counter;

	OPEN C_fiscal_year(l_max_period_counter);
	FETCH C_fiscal_year into l_fiscal_year;
	CLOSE C_fiscal_year;

	OPEN C_units;
	FETCH C_units INTO l_total_units;
	CLOSE C_units;

        OPEN C_active_dists;
        FETCH C_active_dists  INTO l_total_dists;
        CLOSE C_active_dists;

        OPEN C_ytd_asset   (l_max_period_counter);
        FETCH C_ytd_asset INTO  l_asset_ytd_deprn;
        CLOSE C_ytd_asset;

    l_det_last_reval_date            := p_prd_rec.period_end_date;
    l_det_current_reval_factor       := p_current_reval_factor ;
    l_det_cumulative_reval_factor    := p_cumulative_reval_factor ;

      -- Bug 3575041 start (3) --

        OPEN C_Get_Deprn_Flag;
        FETCH C_Get_Deprn_Flag INTO l_depreciate_flag;
    	CLOSE C_Get_Deprn_Flag;

      -- Bug 3575041 end (3) --


        IF NOT IGI_IAC_REVAL_UTILITIES.prorate_all_dists_YTD ( fp_asset_id              => p_asset_id
                       , fp_book_type_code         => p_book_type_code
                       , fp_current_period_counter => l_max_period_counter - 1
                       , fp_prorate_dists_tab      => l_YTD_prorate_dists_tab
                       , fp_prorate_dists_idx      => l_YTD_prorate_dists_idx
                       )
        THEN
            igi_iac_debug_pkg.debug_other_string(g_error_level,g_path,'+error IGI_IAC_REVAL_UTILITIES.prorate_all_dists_YTD');
            return false;
        END IF;

	FOR l_all_dist IN C_all_dist  (l_fiscal_year )
	LOOP
            --
            --  Initialize the values
            --
            l_net_book_value          := p_net_book_value           ;
            l_adjusted_cost           := p_adjusted_cost            ;
            l_operating_acct          := p_operating_acct           ;
            l_reval_reserve           := p_reval_reserve            ;
            l_deprn_amount            := p_deprn_amount             ;
            l_deprn_reserve           := p_deprn_reserve            ;
            l_backlog_deprn_reserve   := p_backlog_deprn_reserve    ;
            l_general_fund            := p_general_fund             ;
            l_op_ac_cost              := p_op_ac_cost               ;
            l_op_ac_backlog           := p_op_ac_backlog            ;
            l_hist_deprn_amount       := p_hist_deprn_amount        ;
            l_hist_deprn_reserve      := p_hist_deprn_reserve       ;
            l_ytd_deprn               := p_ytd_deprn                ;
            l_hist_deprn_ytd          := p_hist_deprn_ytd           ;

  	    --
  	    --  Get the prorate factors
  	    --
	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => 'Getting Prorate Factor for Active Distributions...');

	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => 'Start of prorate to detail');

            GLOBAL_CURRENT_PROC  := 'PRORATE_FOR_DET_BALANCES > ' ;

            l_ytd_prorate_factor := 0;
            idx_YTD := l_YTD_prorate_dists_tab.FIRST;
            WHILE idx_YTD <= l_YTD_prorate_dists_tab.LAST LOOP
                IF l_all_dist.distribution_id = l_YTD_prorate_dists_tab(idx_YTD).distribution_id THEN
                    l_ytd_prorate_factor := l_YTD_prorate_dists_tab(idx_YTD).ytd_prorate_factor;
                    EXIT;
                END  IF;
                idx_ytd := l_YTD_prorate_dists_tab.Next(idx_ytd);
            END LOOP;

 	    IF (l_all_dist.date_ineffective IS NULL)			--Active Distribution
 	    THEN

 		l_flag:=NULL;

      		--
      		--  Process each active distribution and create det balances
      		--
	        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			           p_full_path => g_path||'prorate_for_det_balances',
			           p_string => 'Processing each active distribution ...');

        	--Calculating the proration factors

         	IF (nvl(l_total_units,0)=0)
         	THEN
	            l_prorate_factor:= 0;
         	ELSE
                    l_prorate_factor:= (l_all_dist.units_assigned/l_total_units);
         	END IF;

	        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			           p_full_path => g_path||'prorate_for_det_balances',
			           p_string => 'Processing distribution ---------> '|| l_all_dist.distribution_id);

		IF l_index <> l_total_dists THEN
	            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			               p_full_path => g_path||'prorate_for_det_balances',
			               p_string => 'This is not the last active distribution...');
       		    --
       		    --  Not the last distribution
       		    --
        	    l_det_adjustment_cost            := p_adjusted_cost * l_prorate_factor ;
        	    l_det_net_book_value             := p_net_book_value * l_prorate_factor ;
        	    l_det_operating_acct_cost        := p_op_ac_cost   * l_prorate_factor ;
    		    l_det_operating_acct_backlog     := p_op_ac_backlog * l_prorate_factor ;
	    	    l_det_operating_acct_net         := l_det_operating_acct_cost - l_det_operating_acct_backlog ;
		        l_det_operating_acct_ytd         := 0 ; --?? ;
        	    l_det_deprn_period               := p_deprn_amount * l_prorate_factor ;
        	    l_det_deprn_reserve              := p_deprn_reserve * l_prorate_factor ;
        	    l_det_deprn_reserve_backlog      := p_backlog_deprn_reserve * l_prorate_factor ;
        	    l_det_reval_reserve_backlog      := nvl(l_det_deprn_reserve_backlog,0) -
                                            		nvl(l_det_operating_acct_backlog,0) ;
		        l_det_reval_reserve_gen_fund     := p_general_fund * l_prorate_factor ;
    		    l_det_reval_reserve_net          := p_reval_reserve * l_prorate_factor ;
	    	    l_det_reval_reserve_cost         := l_det_reval_reserve_net + l_det_reval_reserve_gen_fund +
    	                                    		l_det_reval_reserve_backlog ;
        	    l_det_general_fund_acc           := p_general_fund * l_prorate_factor ;

        	    IF ( l_det_general_fund_acc <> 0 )
        	    THEN
		    	l_det_general_fund_per       := p_deprn_amount * l_prorate_factor ;
		    ELSE
		    	l_det_general_fund_per       := 0 ;
		    END IF;


        	    l_det_hist_deprn_amount          := p_hist_deprn_amount * l_prorate_factor ;
           	    l_det_hist_deprn_reserve         := p_hist_deprn_reserve * l_prorate_factor ;


 		ELSE
                --
                --  Value allocation for the last distribution
                --
	            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			               p_full_path => g_path||'prorate_for_det_balances',
			               p_string => 'This is the last active distribution...');

        	    l_det_adjustment_cost            := l_rem_adjusted_cost ;
        	    l_det_net_book_value             := l_rem_net_book_value  ;
        	    l_det_operating_acct_cost        := l_rem_op_ac_cost ;
        	    l_det_operating_acct_backlog     := l_rem_op_ac_backlog ;
        	    l_det_operating_acct_net         := l_det_operating_acct_cost - l_det_operating_acct_backlog ;
        	    l_det_operating_acct_ytd         := 0 ; --?? ;
        	    l_det_deprn_period               := l_rem_deprn_amount ;
        	    l_det_deprn_reserve              := l_rem_deprn_reserve  ;
        	    l_det_deprn_reserve_backlog      := l_rem_backlog_deprn_reserve ;
    		    l_det_reval_reserve_backlog      := nvl(l_det_deprn_reserve_backlog,0) -
                                            		nvl(l_det_operating_acct_backlog,0) ;
	    	    l_det_reval_reserve_gen_fund     := l_rem_general_fund  ;
	 	        l_det_reval_reserve_net          := l_rem_reval_reserve ;
		        l_det_reval_reserve_cost         := l_det_reval_reserve_net + l_det_reval_reserve_gen_fund +
		                                    		l_det_reval_reserve_backlog ;
        	    l_det_general_fund_acc           := l_rem_general_fund ;

        	    IF ( l_det_general_fund_acc <> 0 )
        	    THEN
               		l_det_general_fund_per           := l_rem_deprn_amount ;
        	    ELSE
               		l_det_general_fund_per           := 0 ;
        	    END IF;

        	    l_det_last_reval_date             := p_prd_rec.period_end_date ;
        	    l_det_current_reval_factor        := p_current_reval_factor ;
        	    l_det_cumulative_reval_factor     := p_cumulative_reval_factor ;
        	    l_det_hist_deprn_amount           := l_rem_hist_deprn_amount ;
        	    l_det_hist_deprn_reserve          := l_rem_hist_deprn_reserve ;

   		END IF;

        	l_det_deprn_ytd                   := p_ytd_deprn * l_ytd_prorate_factor ;

		--Bug 3575041 start (4) --

		 IF l_depreciate_flag ='YES' THEN
			l_det_hist_deprn_ytd              := p_hist_deprn_ytd * l_ytd_prorate_factor ;
		 ELSE
            OPEN C_ytd_dist(l_all_dist.distribution_id);
 			FETCH C_ytd_dist INTO l_det_hist_deprn_ytd;
            CLOSE C_ytd_dist;
		 END IF;

		--Bug 3575041 end (4) --



    		l_index:=l_index+1;

        	l_rem_net_book_value          := l_rem_net_book_value          - l_det_net_book_value ;
        	l_rem_adjusted_cost           := l_rem_adjusted_cost           - l_det_adjustment_cost ;
        	l_rem_operating_acct          := l_rem_operating_acct          - l_det_operating_acct_net ;
        	l_rem_reval_reserve           := l_rem_reval_reserve           - l_det_reval_reserve_net ;
        	l_rem_deprn_amount            := l_rem_deprn_amount            - l_det_deprn_period ;
        	l_rem_deprn_reserve           := l_rem_deprn_reserve           - l_det_deprn_reserve ;
        	l_rem_backlog_deprn_reserve   := l_rem_backlog_deprn_reserve   - l_det_deprn_reserve_backlog ;
        	l_rem_general_fund            := l_rem_general_fund            - l_det_general_fund_acc ;
        	l_rem_op_ac_cost              := l_rem_op_ac_cost              - l_det_op_ac_cost       ;
        	l_rem_op_ac_backlog           := l_rem_op_ac_backlog           - l_det_op_ac_backlog    ;
        	l_rem_hist_deprn_amount       := l_rem_hist_deprn_amount       - l_det_hist_deprn_amount ;
        	l_rem_hist_deprn_reserve      := l_rem_hist_deprn_reserve      - l_det_hist_deprn_reserve ;

	    ELSE      --Inactive Distribution

     		l_flag:='N';

                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			           p_full_path => g_path||'prorate_for_det_balances',
			           p_string => 'Processing inactive distribution ---------> '|| l_all_dist.distribution_id);

                l_det_adjustment_cost            := 0;
                l_det_net_book_value             := 0;
    	        l_det_operating_acct_cost        := 0 ;
	            l_det_operating_acct_backlog     := 0 ;
	            l_det_operating_acct_net         := 0 ;
	            l_det_operating_acct_ytd         := 0 ;
                l_det_deprn_period               := 0 ;
                l_det_deprn_reserve              := 0;
                l_det_deprn_reserve_backlog      := 0 ;
    	        l_det_reval_reserve_backlog      := 0;
	            l_det_reval_reserve_gen_fund     := 0;
	            l_det_reval_reserve_net          := 0;
	            l_det_reval_reserve_cost         := 0;
                l_det_general_fund_acc           := 0;
                l_det_general_fund_per           := 0 ;
                l_det_hist_deprn_amount          := 0 ;
                l_det_hist_deprn_reserve         := 0 ;
                l_det_deprn_ytd                  := p_ytd_deprn * l_ytd_prorate_factor ;

		--Bug 3575041 start (5) --

		 IF l_depreciate_flag ='YES' THEN
        	    l_det_hist_deprn_ytd              := p_hist_deprn_ytd * l_ytd_prorate_factor ;
		 ELSE
            OPEN C_ytd_dist(l_all_dist.distribution_id);
        	FETCH C_ytd_dist INTO l_det_hist_deprn_ytd;
            CLOSE C_ytd_dist;
		 END IF;

		--Bug 3575041 end (5) --

	    END IF;

            --
            -- Round the values
            --
            IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_det_adjustment_cost          ,
                                                      p_book_type_code )) THEN
                   null;
            END IF;
            IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_det_net_book_value           ,
                                                      p_book_type_code )) THEN
                   null;
            END IF;
            IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_det_reval_reserve_cost       ,
                                                      p_book_type_code )) THEN
                   null;
            END IF;
            IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_det_reval_reserve_backlog    ,
                                                      p_book_type_code )) THEN
                   null;
            END IF;
            IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_det_reval_reserve_gen_fund   ,
                                                      p_book_type_code )) THEN
                   null;
            END IF;
            IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_det_reval_reserve_net        ,
                                                      p_book_type_code )) THEN
                   null;
            END IF;
           IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_det_operating_acct_cost      ,
                                                      p_book_type_code )) THEN
                   null;
            END IF;
            IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_det_operating_acct_backlog   ,
                                                      p_book_type_code )) THEN
                   null;
            END IF;
            IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_det_operating_acct_net       ,
                                                      p_book_type_code )) THEN
                   null;
            END IF;
            IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_det_operating_acct_ytd       ,
                                                      p_book_type_code )) THEN
                   null;
            END IF;
            IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_det_deprn_period             ,
                                                      p_book_type_code )) THEN
                   null;
            END IF;
            IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_det_deprn_ytd                ,
                                                      p_book_type_code )) THEN
                   null;
            END IF;
            IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_det_deprn_reserve            ,
                                                      p_book_type_code )) THEN
                   null;
            END IF;
            IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_det_deprn_reserve_backlog    ,
                                                      p_book_type_code )) THEN
                   null;
            END IF;
            IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_det_general_fund_per         ,
                                                      p_book_type_code )) THEN
                   null;
            END IF;
            IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_det_general_fund_acc         ,
                                                      p_book_type_code )) THEN
                   null;
            END IF;
            IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_det_op_ac_cost               ,
                                                      p_book_type_code )) THEN
                   null;
            END IF;
            IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_det_op_ac_backlog            ,
                                                      p_book_type_code )) THEN
                   null;
            END IF;
            IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_det_hist_deprn_amount        ,
                                                      p_book_type_code )) THEN
                   null;
            END IF;
            IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_det_hist_deprn_ytd          ,
                                                      p_book_type_code )) THEN
                   null;
            END IF;
            IF NOT( Igi_Iac_Common_Utils.Iac_Round (  l_det_hist_deprn_reserve      ,
                                                      p_book_type_code )) THEN
                   null;
            END IF;


            --
            --    Create rows in igi_iac_det_balances
            --

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 -------- Detail Balances values --------');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 |    adjustment_cost            => '
					   || rpad( l_det_adjustment_cost  ,20,' ') ||'          |');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 |    net_book_value             => '
					   || rpad( l_det_net_book_value  ,20,' ') ||'          |');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 |    reval_reserve_cost         => '
					   || rpad( l_det_reval_reserve_cost  ,20,' ') ||'          |');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 |    reval_reserve_backlog      => '
					   || rpad( l_det_reval_reserve_backlog  ,20,' ') ||'          |');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 |    reval_reserve_gen_fund     => '
					   || rpad( l_det_reval_reserve_gen_fund  ,20,' ') ||'          |');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 |    reval_reserve_net          => '
					   || rpad( l_det_reval_reserve_net  ,20,' ') ||'          |');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 |    operating_acct_cost        => '
					   || rpad( l_det_operating_acct_cost  ,20,' ') ||'          |');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 |    operating_acct_backlog     => '
					   || rpad( l_det_operating_acct_backlog  ,20,' ') ||'          |');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 |    operating_acct_net         => '
					   || rpad( l_det_operating_acct_net  ,20,' ') ||'          |');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 |    operating_acct_ytd         => '
					   || rpad( l_det_operating_acct_ytd  ,20,' ') ||'          |');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 |    deprn_period               => '
					   || rpad( l_det_deprn_period  ,20,' ') ||'          |');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 |    deprn_ytd                  => '
					   || rpad( l_det_deprn_ytd  ,20,' ') ||'          |');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 |    deprn_reserve              => '
					   || rpad( l_det_deprn_reserve  ,20,' ') ||'          |');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 |    deprn_reserve_backlog      => '
					   || rpad( l_det_deprn_reserve_backlog  ,20,' ') ||'          |');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 |    general_fund_per           => '
					   || rpad( l_det_general_fund_per  ,20,' ') ||'          |');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 |    general_fund_acc           => '
					   || rpad( l_det_general_fund_acc  ,20,' ') ||'          |');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 |    last_reval_date            => '
					   || rpad( l_det_last_reval_date  ,20,' ') ||'          |');


            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 |    current_reval_factor       => '
					   || rpad( l_det_current_reval_factor  ,20,' ') ||'          |');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 |    cumulative_reval_factor    => '
				           || rpad( l_det_cumulative_reval_factor  ,20,' ') ||'          |');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 ----------------------------------------');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => 'Creating Detail Balances record ....');


            igi_iac_det_balances_pkg.insert_row (
                 x_rowid                      => l_out_rowid ,
                 x_adjustment_id              => p_adj_id ,
                 x_asset_id                   => p_asset_id ,
                 x_distribution_id            => l_all_dist.distribution_id ,
                 x_book_type_code             => p_book_type_code ,
                 x_period_counter             => l_period_counter ,
                 x_adjustment_cost            => l_det_adjustment_cost ,
                 x_net_book_value             => l_det_net_book_value ,
                 x_reval_reserve_cost         => l_det_reval_reserve_cost ,
                 x_reval_reserve_backlog      => l_det_reval_reserve_backlog ,
                 x_reval_reserve_gen_fund     => l_det_reval_reserve_gen_fund ,
                 x_reval_reserve_net          => l_det_reval_reserve_net ,
                 x_operating_acct_cost        => l_det_operating_acct_cost ,
                 x_operating_acct_backlog     => l_det_operating_acct_backlog ,
                 x_operating_acct_net         => l_det_operating_acct_net ,
                 x_operating_acct_ytd         => l_det_operating_acct_ytd ,
                 x_deprn_period               => l_det_deprn_period ,
                 x_deprn_ytd                  => l_det_deprn_ytd ,
                 x_deprn_reserve              => l_det_deprn_reserve ,
                 x_deprn_reserve_backlog      => l_det_deprn_reserve_backlog ,
                 x_general_fund_per           => l_det_general_fund_per ,
                 x_general_fund_acc           => l_det_general_fund_acc ,
                 x_last_reval_date            => l_det_last_reval_date ,
                 x_current_reval_factor       => l_det_current_reval_factor ,
                 x_cumulative_reval_factor    => l_det_cumulative_reval_factor ,
                 x_active_flag                => l_flag ,
                 x_mode                       => 'R' );

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 -------- Historic Deprn Balances values --------');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 |    deprn_period               => '
					   || rpad( l_det_hist_deprn_amount  ,20,' ') ||'          |');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 |    deprn_ytd                  => '
					   || rpad( l_det_hist_deprn_ytd  ,20,' ') ||'          |');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 |    deprn_reserve              => '
					   || rpad( l_det_hist_deprn_reserve  ,20,' ') ||'          |');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => '                 ------------------------------------------------');

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			       p_full_path => g_path||'prorate_for_det_balances',
			       p_string => 'Creating historic Depreciation Balances record ....');

            l_out_rowid := NULL;
            igi_iac_fa_deprn_pkg.insert_row(
                 x_rowid                      => l_out_rowid ,
                 x_book_type_code             => p_book_type_code ,
                 x_asset_id                   => p_asset_id ,
                 x_period_counter             =>  p_prd_rec.period_counter ,
                 x_adjustment_id              => p_adj_id ,
                 x_distribution_id            => l_all_dist.distribution_id ,
                 x_deprn_period               => l_det_hist_deprn_amount ,
                 x_deprn_ytd                  => l_det_hist_deprn_ytd ,
                 x_deprn_reserve              => l_det_hist_deprn_reserve ,
                 x_active_flag                => l_flag ,
                 x_mode                       => 'R' );


	END LOOP;
    	RETURN TRUE ;
    EXCEPTION
    	WHEN OTHERS
    	THEN
	    igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => g_path||'prorate_for_det_balances');
    	    RETURN FALSE ;
    END Prorate_for_Det_Balances; -- end function


    FUNCTION  Create_Adjustments  ( p_book_type_code    VARCHAR2 ,
                                    p_asset_id          NUMBER   ,
                                    p_adj_id            NUMBER   ,
                                    p_period_counter    NUMBER   ,
                                    p_errbuf  OUT NOCOPY       VARCHAR2,
                                    p_event_id          number )
    RETURN BOOLEAN IS
        CURSOR  c_dists IS
                SELECT *
                FROM   igi_iac_det_balances db
                WHERE  db.book_type_Code = p_book_type_code
                AND    db.asset_id       = p_asset_id
                AND    db.adjustment_id  = p_adj_id
                AND    db.active_flag is NULL;

        l_out_rowid                     VARCHAR2(250) ;
        l_account_Type                  VARCHAR2(50) ;
        l_adj_type                      VARCHAR2(50) ;
        l_amount                        NUMBER ;
        l_units                         NUMBER ;
        l_ccid                          NUMBER ;
        l_set_of_books_Id               NUMBER ;
        l_coa_id                        NUMBER ;
        l_currency                      VARCHAR2(30) ;
        l_precision                     NUMBER ;
        l_dr_cr_flag                    VARCHAR2(2) ;
	l_reval_rsv_ccid		NUMBER ;
	l_op_exp_ccid		    	NUMBER ;
	l_report_ccid			NUMBER ;
	l_adjustment_offset_type	VARCHAR2(50) ;

    BEGIN

        l_amount                        := 0 ;
        l_units                         := 0 ;
        l_ccid                          := 0 ;
        l_set_of_books_Id               := 0 ;
        l_coa_id                        := 0 ;
        l_precision                     := 2 ;
	l_reval_rsv_ccid		:=null;
	l_op_exp_ccid		    	:=null;
	l_report_ccid			:= null;
	l_adjustment_offset_type	:= null;

        GLOBAL_CURRENT_PROC  := 'CREATE_ADJUSTMENTS > ' ;

       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		          p_full_path => g_path||'create_adjustments',
		          p_string => 'Getting GL Info for book ...');

       IF ( NOT ( Igi_Iac_Common_Utils.Get_Book_GL_Info ( p_book_type_code  ,
                                                          l_set_of_books_Id ,
                                                          l_coa_id          ,
                                                          l_currency        ,
                                                          l_precision       ))) THEN
              FND_MESSAGE.SET_NAME('IGI', 'IGI_IAC_EXCEPTION');
	      FND_MESSAGE.SET_TOKEN('PACKAGE','igi_imp_iac_transfer_pkg');
	      FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE','Error Getting GL Info.');

	      igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  	     p_full_path => g_path||'create_adjustments',
		  	     p_remove_from_stack => FALSE);
	      p_errbuf := FND_MESSAGE.GET;
	      fnd_file.put_line(fnd_file.log, p_errbuf);
              RETURN FALSE ;
       END IF;

       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		          p_full_path => g_path||'create_adjustments',
		          p_string => 'Processing Distributions ...');

       FOR drec IN c_dists LOOP

	      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		          	 p_full_path => g_path||'create_adjustments',
		         	 p_string => '------------------- Processing Distribution ID ->'
					     ||drec.distribution_id );

            SELECT units_assigned
            INTO   l_units
            FROM   fa_distribution_history
            WHERE  distribution_id  = drec.distribution_id ;

        IF  l_units =0
        THEN
        igi_iac_adjustments_pkg.insert_row
        		(x_rowid                            => l_out_rowid         ,
    			x_adjustment_id                    => p_adj_id            ,
    			x_book_type_code                   => p_book_type_code    ,
    			x_code_combination_id              => -1             	 ,
    			x_set_of_books_id                  => -1   		,
    			x_dr_cr_flag                       => ' '	    	 ,
    			x_amount                           => 0                  ,
    			x_adjustment_type                  => ' '	         ,
    			x_transfer_to_gl_flag              => 'I'                 ,
    			x_units_assigned                   => l_units   ,
    			x_asset_id                         => p_asset_id          ,
    			x_distribution_id                  => drec.distribution_id ,
    			x_period_counter                   => p_period_counter    ,
			    x_adjustment_offset_type           => Null,
			    x_report_ccid                      => Null,
    			x_mode                             => 'R',
                x_event_id                         => p_event_id ) ;


        ELSE
	    l_reval_rsv_ccid:=null;
	    l_op_exp_ccid:=null;

            FOR l_index in 1 .. 10 LOOP
    		l_ccid             :=  null ;
            l_report_ccid      := null;
    		IF ( mod(l_index,2) = 1 ) THEN
    		     l_dr_cr_flag       :=  'DR' ;
    		ELSE
    		     l_dr_cr_flag       :=  'CR' ;
    		END IF;

		    IF l_index = 1 THEN
    		  IF ( drec.adjustment_cost < 0 ) THEN
                    l_account_Type     :=  'OPERATING_EXPENSE_ACCT' ;
                    l_adj_type         :=  'OP EXPENSE' ;
     		  ELSE
                    l_account_Type     :=  'REVAL_RESERVE_ACCT' ;
                    l_adj_type         :=  'REVAL RESERVE' ;
     		  END IF;
                  l_amount           :=  drec.adjustment_cost ;
                  l_adjustment_offset_type :='COST';
       		ELSIF l_index = 2 THEN
     		      l_account_Type     :=  'ASSET_COST_ACCT' ;
             	  l_adj_type         :=  'COST' ;
             	  l_amount           :=  drec.adjustment_cost ;
        		  IF ( drec.adjustment_cost < 0 ) THEN
                      l_adjustment_offset_type :='OP EXPENSE';
              	      l_report_ccid :=l_op_exp_ccid;
     		      ELSE
         	        l_adjustment_offset_type :='REVAL RESERVE';
            	    l_report_ccid :=l_reval_rsv_ccid;
            	  END IF;
    		ELSIF l_index = 3 THEN
    		      l_account_Type     :=  'OPERATING_EXPENSE_ACCT' ;
    		      l_adj_type         :=  'OP EXPENSE' ;
    		      l_amount           :=  drec.operating_acct_backlog ;
		          l_adjustment_offset_type :='BL RESERVE';
    		ELSIF l_index = 4 THEN
    		      l_account_Type     :=  'BACKLOG_DEPRN_RSV_ACCT' ;
    		      l_adj_type         :=  'BL RESERVE' ;
    		      l_amount           :=  drec.operating_acct_backlog ;
		          l_adjustment_offset_type :='OP EXPENSE';
             	  l_report_ccid :=l_op_exp_ccid;
    		ELSIF l_index = 5 THEN
    		      l_account_Type     :=  'REVAL_RESERVE_ACCT' ;
    		      l_adj_type         :=  'REVAL RESERVE' ;
    		      l_amount           :=  drec.reval_reserve_backlog ;
		          l_adjustment_offset_type :='BL RESERVE';
    		ELSIF l_index = 6 THEN
    		      l_account_Type     :=  'BACKLOG_DEPRN_RSV_ACCT' ;
    		      l_adj_type         :=  'BL RESERVE' ;
    		      l_amount           :=  drec.reval_reserve_backlog ;
                  l_adjustment_offset_type :='REVAL RESERVE';
            	  l_report_ccid :=l_reval_rsv_ccid;
    		ELSIF l_index = 7 THEN
    		      l_account_Type     :=  'DEPRN_EXPENSE_ACCT' ;
    		      l_adj_type         :=  'EXPENSE' ;
    		      l_amount           :=  drec.deprn_reserve ;
    		      l_adjustment_offset_type :='RESERVE';
    		ELSIF l_index = 8 THEN
    		      l_account_Type     :=  'DEPRN_RESERVE_ACCT' ;
    		      l_adj_type         :=  'RESERVE' ;
    		      l_amount           :=  drec.deprn_reserve ;
	              l_adjustment_offset_type :='EXPENSE';
    		ELSIF l_index = 9 THEN
    		      l_account_Type     :=  'REVAL_RESERVE_ACCT' ;
    		      l_adj_type         :=  'REVAL RESERVE' ;
    		      l_amount           :=  drec.general_fund_acc ;
		          l_adjustment_offset_type :='GENERAL FUND' ;
    		ELSIF l_index = 10 THEN
    		      l_account_Type     :=  'GENERAL_FUND_ACCT' ;
    		      l_adj_type         :=  'GENERAL FUND' ;
    		      l_amount           :=  drec.general_fund_acc ;
 	    	      l_adjustment_offset_type :='REVAL RESERVE';
        	      l_report_ccid :=l_reval_rsv_ccid;
       		END IF;

	        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		          	 p_full_path => g_path||'create_adjustments',
		         	 p_string => 'Creating entry for adj '|| l_adj_type
					     ||' account '|| l_account_type ) ;

	        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		          	 p_full_path => g_path||'create_adjustments',
		         	 p_string => '==============Amount = '|| l_amount
					     ||' DR/CR '|| l_dr_cr_flag ) ;

            IF l_amount <> 0 THEN
	            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		          	 p_full_path => g_path||'create_adjustments',
		         	 p_string => 'Getting CCID ...') ;

    		    IF ( NOT ( Igi_Iac_Common_Utils.Get_Account_CCID (
    			   p_book_type_code      ,
    			   p_asset_id            ,
    			   drec.distribution_id  ,
    			   l_account_Type        ,
    			   l_ccid             ))) THEN

	      			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		          			   p_full_path => g_path||'create_adjustments',
						   p_string => 'Error : Common Utils Function Get_Account_CCID                                                                failed for asset '|| p_asset_id
							       ||' distribution_id '|| drec.distribution_id
							       ||' and account type '|| l_Account_type );
    		    END IF;

	            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		          	 p_full_path => g_path||'create_adjustments',
		         	 p_string => 'Creating Adjustment ...') ;

    		    IF l_adj_type='REVAL RESERVE' THEN
	            	      l_reval_rsv_ccid:= l_ccid;
         		    ELSIF l_adj_type='OP EXPENSE' THEN
     	                  l_op_exp_ccid:=l_ccid;
     		    END IF;


    		    igi_iac_adjustments_pkg.insert_row (
    			    x_rowid                            => l_out_rowid         ,
    			    x_adjustment_id                    => p_adj_id            ,
    			    x_book_type_code                   => p_book_type_code    ,
    			    x_code_combination_id              => l_ccid              ,
    			    x_set_of_books_id                  => l_set_of_books_id   ,
    			    x_dr_cr_flag                       => l_dr_cr_flag        ,
    			    x_amount                           => l_amount            ,
    			    x_adjustment_type                  => l_adj_type          ,
    			    x_transfer_to_gl_flag              => 'I'                 ,
    			    x_units_assigned                   => l_units   ,
    			    x_asset_id                         => p_asset_id          ,
    			    x_distribution_id                  => drec.distribution_id ,
    			    x_period_counter                   => p_period_counter    ,
                  	    x_adjustment_offset_type           => l_adjustment_offset_type,
                   	    x_report_ccid                      => l_report_ccid,
    			    x_mode                             => 'R' ,
                    x_event_id                         => p_event_id) ;
            END IF;

            END LOOP ;
            END IF;
       END LOOP ;


       RETURN TRUE ;

    EXCEPTION
       WHEN OTHERS THEN
            p_errbuf := 'Error Creating adjustments '|| sqlerrm ;
	    igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => g_path||'create_adjustments');
            RETURN FALSE ;
    END;


    PROCEDURE TRANSFER_DATA ( errbuf           OUT NOCOPY   VARCHAR2 ,
			      retcode          OUT NOCOPY   NUMBER ,
			      p_book_type_code       VARCHAR2 ,
			      p_category_id          NUMBER,
                  p_event_id             number)    --R12 uptake
    IS
    CURSOR c_ctrl IS
               SELECT *
               FROM   igi_imp_iac_interface_ctrl ic
               WHERE  ic.book_type_code  = p_book_type_code
               AND    ic.category_id     = p_Category_id ;

        CURSOR c_assets IS
               SELECT *
               FROM   igi_imp_iac_interface ii
               WHERE  ii.book_type_code   = p_book_type_code
               AND    ii.category_id      = p_Category_id
               AND    ii.transferred_flag = 'N'
               AND    ii.valid_flag       = 'Y'; --Fix for Bug 5137813

         Cursor C_book_class is
         Select book_class
         from fa_booK_controls
         where book_type_code = p_booK_type_code;

--        Cursor to fetch the assets from the interface table
        CURSOR c_txns(cp_book VARCHAR2) IS
               SELECT 'Y'
               FROM   igi_iac_transaction_headers it
               WHERE  it.book_type_code  = cp_book
               AND    it.category_id           = p_Category_id
               AND    NOT ( nvl(it.transaction_sub_type,'AA')   = 'IMPLEMENTATION')
               AND    rownum = 1 ;

         Cursor  c_get_reval_factor( cp_book VARCHAR2,cp_asset_id number) is
         select    current_reval_factor,cummulative_reval_factor
         from igi_imp_iac_interface_py_add
         where book_type_code = cp_book
         and asset_id =cp_asset_id;


          Cursor C_Book_Info(cp_book in varchar2, cp_asset_id in number) Is
            Select  bk.asset_id,
                    bk.date_placed_in_service,
                    bk.life_in_months,
                    nvl(bk.cost,0) cost,
                    nvl(bk.adjusted_cost,0) adjusted_cost,
                    nvl(bk.original_cost,0) original_cost,
                    nvl(bk.salvage_value,0) salvage_value,
                    nvl(bk.adjusted_recoverable_cost, 0) adjusted_recoverable_cost,
                    nvl(bk.recoverable_cost,0) recoverable_cost,
                    bk.deprn_start_date,
                    bk.cost_change_flag,
                    bk.rate_adjustment_factor,
                    bk.depreciate_flag,
                    bk.fully_rsvd_revals_counter,
                    bk.period_counter_fully_reserved,
                    bk.period_counter_fully_retired
            From    fa_books bk
            Where   bk.book_type_code = cp_book
            and     bk.asset_id = cp_asset_id
            and     bk.transaction_header_id_out is null;

            cursor C_get_deprn_details(cp_book in varchar2, cp_asset_id in number)is
            Select period_counter,deprn_reserve
            from fa_deprn_summary fds
            where book_type_code =cp_book
            and asset_id = cp_asset_id
            and period_counter = ( select max(period_counter)
                                   from fa_deprn_summary
                                   where book_type_code =fds.book_type_code
                                    and asset_id = fds.asset_id);

    --l_errbuf                        VARCHAR2(1200) ;
    l_transfer_status               VARCHAR2(1) ;
    l_out_rowid                     VARCHAR2(200) ;
    l_reserved_flag                 VARCHAR2(1);
    l_txns_flag                     VARCHAR2(1);
    l_period_counter                NUMBER(15) ;
    l_ytd_deprn                     NUMBER(15) ;
    l_out_adj_id                    NUMBER(15) ;
    l_prd_rec                       igi_iac_types.prd_rec ;
    l_prev_prd_rec                  igi_iac_types.prd_rec ;
    l_out_reval_id                  NUMBER(15) ;
    l_net_book_value                NUMBER ;
    l_adjusted_cost                 NUMBER ;
    l_operating_acct                NUMBER ;
    l_reval_reserve                 NUMBER ;
    l_deprn_amount                  NUMBER ;
    l_deprn_reserve                 NUMBER ;
    l_assetrec                      c_assets%ROWTYPE ;
    l_backlog_deprn_reserve         NUMBER ;
    l_general_fund                  NUMBER ;
    l_current_reval_factor          NUMBER ;
    l_cumulative_reval_factor       NUMBER ;
    l_corporate_book                VARCHAR2(30);
    l_prev_out_adj_id               NUMBER(15) ;
    l_period_for_rates              NUMBER ;
    l_num_per_fiscal_year           NUMBER ;
    l_period_num_for_catchup        NUMBER ;
    l_hist_deprn_amount             NUMBER ;
    l_hist_deprn_ytd                NUMBER ;
    l_hist_deprn_reserve            NUMBER ;
    l_book_class                    fa_book_controls.book_class%type;
    --l_book_type_code       	    VARCHAR2(15):=p_book_type_code;
    l_book_info_rec                 C_Book_Info%rowtype;
    l_corp_deprn_summary            number ;
    l_hist_info                     igi_iac_types.fa_hist_asset_info;
    l_corp_last_per_counter        number;
    l_dpis_period_counter          number;
    l_hist_deprn_amount_sal_corr    Number;
    l_assets_valid                  BOOLEAN; -- For BUG 5137813

    BEGIN


       l_transfer_status               := 'X' ;
       l_net_book_value                := 0 ;
       l_adjusted_cost                 := 0 ;
       l_operating_acct                := 0 ;
       l_reval_reserve                 := 0 ;
       l_deprn_amount                  := 0 ;
       l_deprn_reserve                 := 0 ;
       l_backlog_deprn_reserve         := 0 ;
       l_general_fund                  := 0 ;
       l_current_reval_factor          := 0 ;
       l_cumulative_reval_factor       := 0 ;
       l_hist_deprn_amount             := 0;
       l_hist_deprn_ytd                := 0;
       l_hist_deprn_reserve            := 0;
       l_corp_deprn_summary            :=0;
       l_corp_last_per_counter         :=0;
       l_dpis_period_counter           :=0;

       retcode := 2 ;


       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		          p_full_path => g_path||'transfer_data',
		          p_string => '*********** Start of Transfer to IAC... **********');

       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		          p_full_path => g_path||'transfer_data',
		          p_string => '*********** Start of Transfer to IAC... **********');

       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		          p_full_path => g_path||'transfer_data',
		          p_string => '------> Book        :  '|| rpad(p_book_type_code ,15,' ')||'     ') ;

       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		          p_full_path => g_path||'transfer_data',
		          p_string => '------> Category ID :  '|| rpad(p_category_id,15,' ')    ||'     ') ;
       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		          p_full_path => g_path||'transfer_data',
		          p_string => '-------------------------------------- ');


       GLOBAL_CURRENT_PROC  := 'TRANSFER_DATA > ' ;


       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		          p_full_path => g_path||'transfer_data',
		          p_string => 'Checking availability of book and category for transfer ....');

       --    Check if the category has already been transferred
       --
       l_transfer_status := 'X' ;

       FOR ctrlrec IN c_ctrl LOOP
          l_transfer_status := ctrlrec.transfer_Status ;
          IF ctrlrec.transfer_status = 'C'  THEN
              fnd_message.set_name ('IGI','IGI_IMP_IAC_TFR_ALREADY_DONE');
	      igi_iac_debug_pkg.debug_other_msg(p_level => g_state_level,
		  	      p_full_path => g_path||'transfer_data',
		              p_remove_from_stack => FALSE);
              errbuf := fnd_message.get;
	      fnd_file.put_line(fnd_file.log, errbuf);
              retcode := 0 ;
              RETURN ;
          END IF;
       END LOOP ;


       IF l_transfer_status ='X' THEN
              set_interface_ctrl_status( p_book_type_code ,
					 p_category_id    ,
					 'N' );
              fnd_message.set_name ('IGI','IGI_IMP_IAC_NO_PREPARE');
	      igi_iac_debug_pkg.debug_other_msg(p_level => g_state_level,
		  	      p_full_path => g_path||'transfer_data',
		              p_remove_from_stack => FALSE);
              errbuf := fnd_message.get;
	      fnd_file.put_line(fnd_file.log, errbuf);
              retcode := 0 ;
              COMMIT WORK;
              RETURN ;
       END IF;
       l_reserved_flag := 'Y' ;


       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		          p_full_path => g_path||'transfer_data',
		          p_string => ' Getting the period counter and corporate book ...');

       -- Get the period counter and corporate book
       --
       BEGIN
           SELECT ic.period_counter , ic.corp_book
           INTO   l_period_counter , l_corporate_book
           FROM   igi_imp_iac_controls ic
           WHERE  ic.book_type_code = p_book_type_code ;
       EXCEPTION
           WHEN OTHERS THEN
	        igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		         	   p_full_path => g_path||'transfer_data',
		         	   p_string => 'Error : Fetching period counter from control '|| sqlerrm);
                fnd_message.set_name ('IGI','IGI_IMP_IAC_TRF_GENERIC_ERROR');
	        igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  	        p_full_path => g_path||'transfer_data',
		                p_remove_from_stack => FALSE);
                errbuf := fnd_message.get;
	        fnd_file.put_line(fnd_file.log, errbuf);
                raise igi_imp_tfr_error ;
       END;


	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	         	   p_full_path => g_path||'transfer_data',
		           p_string => 'Checking if there have been transactions in Inflation Accounting ...');
        l_txns_flag  := 'N' ;
        For txnrec in c_txns(l_corporate_book) loop
            l_txns_flag  := 'Y' ;
        end loop ;

        If l_txns_flag = 'Y' Then
	    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
	         	       p_full_path => g_path||'transfer_data',
		               p_string => 'Error: There have been transactions in Inflation Accounting .');
            set_interface_ctrl_status( p_book_type_code ,
                                       p_category_id    ,
                                       'E' );
            fnd_message.set_name ('IGI','IGI_IMP_IAC_TRF_TXNS_IN_IAC');
	    igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  	    p_full_path => g_path||'transfer_data',
		            p_remove_from_stack => FALSE);
            Errbuf := fnd_message.get;
	    fnd_file.put_line(fnd_file.log, errbuf);
            retcode := 2 ;
            COMMIT WORK;
            RETURN ;
        End If;

        --Check for transactions in open period

        IF( NOT Trxns_In_Open_Period(p_book_type_code))
        THEN
	    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
	         	       p_full_path => g_path||'transfer_data',
		               p_string => 'Error: There have been open period transactions on the Book.');
            set_interface_ctrl_status( p_book_type_code ,
                                       p_category_id    ,
                                       'E' );
            fnd_message.set_name ('IGI','IGI_IMP_IAC_TRXNS_IN_OPEN_PERD');
	    igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  	    p_full_path => g_path||'transfer_data',
		            p_remove_from_stack => FALSE);
            Errbuf := fnd_message.get;
	    fnd_file.put_line(fnd_file.log, errbuf);
            retcode := 2 ;
            COMMIT WORK;
            RETURN ;
        END IF;

       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	         	  p_full_path => g_path||'transfer_data',
      		          p_string => 'Fetching period Info for counter : '|| l_period_counter );
       -- Fetch period Info for the counter
       --
       IF ( NOT( Igi_Iac_Common_Utils.Get_Period_Info_For_Counter (
                      l_corporate_book ,
                      l_period_Counter ,
                      l_prd_rec
                    ))) THEN
            igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
	         	       p_full_path => g_path||'transfer_data',
      		               p_string => 'Fetching period Info for counter : '|| l_period_counter );
            fnd_message.set_name ('IGI','IGI_IMP_IAC_TRF_GENERIC_ERROR');
	    igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  	    p_full_path => g_path||'transfer_data',
		            p_remove_from_stack => FALSE);
            errbuf := fnd_message.get;
	    fnd_file.put_line(fnd_file.log, errbuf);
            raise igi_imp_tfr_error ;
       END IF;

       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	         	  p_full_path => g_path||'transfer_data',
      		          p_string => 'Fetching period Info for closed period , counter : '|| (l_period_counter-1) );

       -- Fetch period Info for the closed period counter
       --
       IF ( NOT( Igi_Iac_Common_Utils.Get_Period_Info_For_Counter (
                      l_corporate_book ,
                      l_period_Counter-1 ,
                      l_prev_prd_rec
                    ))) THEN
            igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
	         	       p_full_path => g_path||'transfer_data',
      		               p_string => 'Error: Fetching period Info for counter : '|| (l_period_counter-1) );
            fnd_message.set_name ('IGI','IGI_IMP_IAC_TRF_GENERIC_ERROR');
	    igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  	    p_full_path => g_path||'transfer_data',
		            p_remove_from_stack => FALSE);
            errbuf := fnd_message.get;
	    fnd_file.put_line(fnd_file.log, errbuf);
            raise igi_imp_tfr_error ;
       END IF;


       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	         	  p_full_path => g_path||'transfer_data',
      		          p_string => 'Before creating Revaluations record ...');
       -- Create row in igi_iac_revaluations
       --
       igi_iac_revaluations_pkg.insert_row (
                   X_rowid                      => l_out_rowid ,
                   X_revaluation_id             => l_out_reval_id ,
                   X_book_type_code             => l_corporate_book ,
                   X_revaluation_date           => l_prd_rec.period_end_date ,
                   X_revaluation_period         => l_prd_rec.period_counter ,
                   X_status                     => 'COMPLETE' ,
                   X_reval_request_id           => NULL ,
                   X_create_request_id          => NULL ,
                   X_calling_program            => 'IMPLEMENTATION' ,
                   X_mode                       => 'R',
                   x_event_id                         => p_event_id
                   ) ;


       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	         	  p_full_path => g_path||'transfer_data',
      		          p_string => ' Creating row in igi_iac_Reval_categories ...');
       -- Create row in igi_iac_Reval_categories
       --
       BEGIN
           INSERT INTO igi_iac_reval_categories
                (
                    REVALUATION_ID      ,
                    BOOK_TYPE_CODE      ,
                    CATEGORY_ID         ,
                    SELECT_CATEGORY     ,
                    CREATED_BY          ,
                    CREATION_DATE       ,
                    LAST_UPDATE_LOGIN   ,
                    LAST_UPDATE_DATE    ,
                    LAST_UPDATED_BY
                )
                VALUES
                (
                    l_out_reval_id ,
                    l_corporate_book  ,
                    p_category_id ,
                    'Y' ,
                    fnd_global.user_id ,
                    sysdate ,
                    fnd_global.login_id ,
                    sysdate ,
                    fnd_global.user_id
                );
       EXCEPTION
               WHEN OTHERS THEN
	            igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		         	       p_full_path => g_path||'transfer_data',
		         	       p_string => 'Error : Creating record in igi_iac_reval_categories  '
						   || sqlerrm);
                    fnd_message.set_name ('IGI','IGI_IMP_IAC_TRF_GENERIC_ERROR');
	            igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  	            p_full_path => g_path||'transfer_data',
		                    p_remove_from_stack => FALSE);
                    errbuf := fnd_message.get;
	    	    fnd_file.put_line(fnd_file.log, errbuf);
                    raise igi_imp_tfr_error ;
       END;


       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	         	  p_full_path => g_path||'transfer_data',
      		          p_string => 'Get all records in the category to process ...');

      open c_booK_class;
       Fetch c_booK_class into l_booK_class;
       Close c_book_class;

        -- Validate Assets (fix for BUG 5137813)
        l_assets_valid := Validate_Assets(p_book_type_code,p_category_id);

       --  Get all records in the category to process.
       --
       FOR arec IN c_assets LOOP

       		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	         	  	   p_full_path => g_path||'transfer_data',
      		         	   p_string => '  ----------------> Processing Asset ID : '|| arec.asset_id ) ;

       		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	         	  	   p_full_path => g_path||'transfer_data',
      		         	   p_string => '  Creating row in igi_iac_transaction_headers for closed period...');
                --  Create row in igi_iac_transaction_headers for closed period
                --
                l_prev_out_adj_id := null;
                l_out_adj_id      := null;

                igi_iac_trans_headers_pkg.insert_row (
                       x_rowid                     => l_out_rowid ,
                       x_adjustment_id             => l_prev_out_adj_id ,
                       x_transaction_header_id     => null ,
                       x_adjustment_id_out         => null ,
                       x_transaction_type_code     => 'DEPRECIATION' ,
                       x_transaction_date_entered  => l_prev_prd_rec.period_end_date ,
                       x_mass_refrence_id          => l_out_reval_id ,
                       x_transaction_sub_type      => 'IMPLEMENTATION' ,
                       x_book_type_code            => l_corporate_book  ,
                       x_asset_id                  => arec.asset_id ,
                       x_category_id               => arec.category_id ,
                       x_adj_deprn_start_date      => sysdate ,
                       x_revaluation_type_flag     => 'P' ,
                       x_adjustment_status         => 'COMPLETE' ,
                       x_period_counter            => l_prev_prd_rec.period_counter,
                       x_mode                      => 'R',
                       x_event_id                         => p_event_id
                     ) ;
                SELECT    igi_iac_transaction_headers_s.NEXTVAL
                INTO      l_out_adj_id
                FROM      sys.dual;

                UPDATE  igi_iac_transaction_headers
                SET     adjustment_id_out =  l_out_adj_id
                WHERE   asset_id = arec.asset_id
                AND     book_type_code  = l_corporate_book
                AND     adjustment_id_out IS NULL ;


       		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	         	  	   p_full_path => g_path||'transfer_data',
      		         	   p_string => '  Creating row in igi_iac_transaction_headers ...');
                --  Create row in igi_iac_transaction_headers
                --
                igi_iac_trans_headers_pkg.insert_row (
                       x_rowid                     => l_out_rowid ,
                       x_adjustment_id             => l_out_adj_id ,
                       x_transaction_header_id     => null ,  -- mass ref id will be populated with reval id
                       x_adjustment_id_out         => null ,
                       x_transaction_type_code     => 'REVALUATION' ,
                       x_transaction_date_entered  => l_prd_rec.period_end_date ,
                       x_mass_refrence_id          => l_out_reval_id ,
                       x_transaction_sub_type      => 'IMPLEMENTATION' ,
                       x_book_type_code            => l_corporate_book  ,
                       x_asset_id                  => arec.asset_id ,
                       x_category_id               => arec.category_id ,
                       x_adj_deprn_start_date      => sysdate , --????
                       x_revaluation_type_flag     => 'P' , --??? -- Setting to occassional
                       x_adjustment_status         => 'COMPLETE' ,
                       x_period_counter            => l_prd_rec.period_counter,
                       x_mode                      => 'R',
                       x_event_id                  => p_event_id
                     ) ;

       		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	         	  	   p_full_path => g_path||'transfer_data',
      		         	   p_string => 'Assigning variables to populate asset balances...');
                --  Assign variables to populate asset balances
                --
                l_net_book_value         := nvl(arec.nbv_mhca,0) - nvl(arec.nbv_hist,0) ;--stop
                l_adjusted_cost          := nvl(arec.cost_mhca,0) - nvl(arec.cost_hist,0) ;
                l_operating_acct         := nvl(arec.operating_account_mhca,0) - nvl(arec.operating_account_hist,0) ;
                l_reval_reserve          := nvl(arec.reval_reserve_mhca,0) - nvl(arec.reval_reserve_hist,0) ;
                l_deprn_amount           := nvl(arec.deprn_exp_mhca,0) - nvl(arec.deprn_exp_hist,0) ;
                l_ytd_deprn              := nvl(arec.ytd_mhca,0) - nvl(arec.ytd_hist,0) ;
                l_deprn_reserve          := nvl(arec.accum_deprn_mhca,0) - nvl(arec.accum_deprn_hist,0) ;
                l_backlog_deprn_reserve  := nvl(arec.backlog_mhca,0) - nvl(arec.backlog_hist,0) ;
                l_general_fund           := nvl(arec.general_fund_mhca,0) - nvl(arec.general_fund_hist,0) ;
                l_hist_deprn_amount      := nvl(arec.deprn_exp_hist,0);
                l_hist_deprn_ytd         := nvl(arec.ytd_hist,0);
                l_hist_deprn_reserve     := nvl(arec.accum_deprn_hist,0);


                IF ( nvl( arec.cost_hist,0) = 0 ) THEN
                     l_current_reval_factor    := 1 ;
                     l_cumulative_reval_factor := 1 ;
                ELSE
                     l_current_reval_factor    := arec.cost_mhca/arec.cost_hist ;
                     l_cumulative_reval_factor := arec.cost_mhca/arec.cost_hist ;
                END IF;


               /* IF l_book_class = 'CORPORATE' THEN

	                l_hist_deprn_ytd:= (arec.ytd_mhca-l_hist_deprn_ytd) /(l_cumulative_reval_factor-1);
			        -- remove salvage value correction
                   IF ((arec.hist_salvage_value is not Null) or   (NOt arec.hist_salvage_value =0)) THEN
                         l_hist_deprn_ytd := l_hist_deprn_ytd - ((l_hist_deprn_ytd/(arec.cost_hist-arec.hist_salvage_value))*arec.hist_salvage_value);
                   End if;

                END IF;*/

                       IF l_book_class = 'CORPORATE' THEN

                                open c_book_info(l_corporate_book,arec.asset_id);
                                Fetch c_book_info into l_book_info_rec;
                                close c_book_info;

                                l_hist_info.cost := l_book_info_rec.cost;
                                l_hist_info.adjusted_cost := l_book_info_rec.adjusted_cost;
                                l_hist_info.original_cost := l_book_info_rec.original_cost;
                                l_hist_info.salvage_value := l_book_info_rec.salvage_value;
                                l_hist_info.life_in_months := l_book_info_rec.life_in_months;
                                l_hist_info.rate_adjustment_factor := l_book_info_rec.rate_adjustment_factor;
                                l_hist_info.period_counter_fully_reserved := l_book_info_rec.period_counter_fully_reserved;
                                l_hist_info.adjusted_recoverable_cost := l_book_info_rec.adjusted_recoverable_cost;
                                l_hist_info.recoverable_cost := l_book_info_rec.recoverable_cost;
                                l_hist_info.date_placed_in_service := l_book_info_rec.date_placed_in_service;
                                l_hist_info.deprn_start_date := l_book_info_rec.deprn_start_date;
                                l_hist_info.depreciate_flag  := l_book_info_rec.depreciate_flag;

                                --get latest period counter and deprn_resereve for the asset

                                /*Open C_get_deprn_details(l_corporate_book,arec.asset_id);
                                fetch C_get_deprn_details into l_corp_last_per_counter,l_corp_deprn_summary;
                                close c_get_deprn_details;*/

                                l_hist_info.last_period_counter := l_corp_last_per_counter;
                                l_hist_info.gl_posting_allowed_flag := NULL;
                                l_hist_info.ytd_deprn  := 0;
                                l_hist_info.deprn_reserve :=arec.accum_deprn_hist;
                                l_hist_info.deprn_amount := 0;
                                l_corp_last_per_counter:=l_prd_rec.period_counter-1;
                                l_dpis_period_counter:=null;

                               IF NOT igi_iac_ytd_engine.Calculate_YTD
                                             ( l_corporate_book,
                                                arec.asset_id,
                                                l_hist_info,
                                                l_dpis_period_counter,
                                                l_corp_last_per_counter,
                                            'UPGRADE') THEN

                                     fnd_message.set_name ('IGI', 'IGI_IMP_IAC_PREP_ERROR');
                                     fnd_message.set_token('ROUTINE','igi_iac_ytd_engine.Calculate_YTD');
          		                    igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
            		      		   	p_full_path => g_path,
		  	                		p_remove_from_stack => FALSE);
                                      errbuf := fnd_message.get;
                                      Raise IGI_IMP_TFR_ERROR ;
                              END IF;
                                 l_hist_deprn_ytd:=l_hist_info.ytd_deprn;
                                 l_hist_deprn_amount:=l_hist_info.deprn_amount;
                                 l_hist_deprn_amount_sal_corr:=l_hist_deprn_amount;

                                  IF  ( NOT l_hist_info.salvage_value is Null) or (NOT  l_hist_info.salvage_value=0) THEN
                                	IF NOT igi_iac_salvage_pkg.correction(arec.asset_id,
                                                          l_corporate_book,
                                                           l_hist_deprn_amount_sal_corr,
                                                          l_hist_info.cost,
                                                          l_hist_info.salvage_value,
                                                          P_calling_program=>'IMPLEMENTATTION') THEN

        	                     	         fnd_message.set_token('ROUTINE','igi_iac_salvage_pkg.correction');
          		                                  igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
                    	    	  		        	p_full_path => g_path,
		      	                    		        p_remove_from_stack => FALSE);
                                                  errbuf := fnd_message.get;
                                              Raise IGI_IMP_TFR_ERROR ;
            	                  END IF;
                               END IF;
                                        l_deprn_amount:= l_hist_deprn_amount_sal_corr*(l_cumulative_reval_factor-1);
                                        l_ytd_deprn := l_deprn_amount * l_hist_Info.deprn_periods_current_year;
                       End If;

                --
                --  Round Values
                --
                IF NOT( Igi_Iac_Common_Utils.Iac_Round ( l_net_book_value         ,
                                                         l_corporate_book )) THEN
                        null;
                END IF;
                IF NOT( Igi_Iac_Common_Utils.Iac_Round ( l_adjusted_cost          ,
                                                         l_corporate_book )) THEN
                        null;
                END IF;
                IF NOT( Igi_Iac_Common_Utils.Iac_Round ( l_operating_acct         ,
                                                         l_corporate_book )) THEN
                        null;
                END IF;
                IF NOT( Igi_Iac_Common_Utils.Iac_Round ( l_reval_reserve          ,
                                                         l_corporate_book )) THEN
                        null;
                END IF;
                IF NOT( Igi_Iac_Common_Utils.Iac_Round ( l_deprn_amount           ,
                                                         l_corporate_book )) THEN
                        null;
                END IF;
                IF NOT( Igi_Iac_Common_Utils.Iac_Round ( l_ytd_deprn           ,
                                                         l_corporate_book )) THEN
                        null;
                END IF;
                IF NOT( Igi_Iac_Common_Utils.Iac_Round ( l_deprn_reserve          ,
                                                         l_corporate_book )) THEN
                        null;
                END IF;
                IF NOT( Igi_Iac_Common_Utils.Iac_Round ( l_backlog_deprn_reserve  ,
                                                         l_corporate_book )) THEN
                        null;
                END IF;
                IF NOT( Igi_Iac_Common_Utils.Iac_Round ( l_general_fund           ,
                                                         l_corporate_book )) THEN
                        null;
                END IF;
                IF NOT( Igi_Iac_Common_Utils.Iac_Round ( l_hist_deprn_amount      ,
                                                         l_corporate_book )) THEN
                        null;
                END IF;
                IF NOT( Igi_Iac_Common_Utils.Iac_Round ( l_hist_deprn_ytd         ,
                                                         l_corporate_book )) THEN
                        null;
                END IF;
                IF NOT( Igi_Iac_Common_Utils.Iac_Round ( l_hist_deprn_reserve     ,
                                                         l_corporate_book )) THEN
                        null;
                END IF;

       		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	         	  	   p_full_path => g_path||'transfer_data',
      		         	   p_string => 'Creating row in igi_iac_asset_balances for closed period ...');

                --  Create row in igi_iac_asset_balances for closed period
                --
                igi_iac_asset_balances_pkg.insert_row (
                           x_rowid                   => l_out_rowid ,
                           x_asset_id                => arec.asset_id ,
                           x_book_type_code          => l_corporate_book ,
                           x_period_counter          => l_prev_prd_rec.period_counter ,
                           x_net_book_value          => l_net_book_value ,
                           x_adjusted_cost           => l_adjusted_cost ,
                           x_operating_acct          => l_operating_acct ,
                           x_reval_reserve           => l_reval_reserve ,
                           x_deprn_amount            => l_deprn_amount ,
                           x_deprn_reserve           => l_deprn_reserve ,
                           x_backlog_deprn_reserve   => l_backlog_deprn_reserve ,
                           x_general_fund            => l_general_fund ,
                           x_last_reval_date         => l_prev_prd_rec.period_end_date ,
                           x_current_reval_factor    => l_current_reval_factor   ,
                           x_cumulative_reval_factor => l_cumulative_reval_factor ,
                           x_mode                    => 'R'
                   );


       		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	         	  	   p_full_path => g_path||'transfer_data',
      		         	   p_string => 'Creating row in igi_iac_asset_balances for current period ...');
                --  Create row in igi_iac_asset_balances
                --
                igi_iac_asset_balances_pkg.insert_row (
                           x_rowid                   => l_out_rowid ,
                           x_asset_id                => arec.asset_id ,
                           x_book_type_code          => l_corporate_book ,
                           x_period_counter          => l_prd_rec.period_counter ,
                           x_net_book_value          => l_net_book_value ,
                           x_adjusted_cost           => l_adjusted_cost ,
                           x_operating_acct          => l_operating_acct ,
                           x_reval_reserve           => l_reval_reserve ,
                           x_deprn_amount            => l_deprn_amount ,
                           x_deprn_reserve           => l_deprn_reserve ,
                           x_backlog_deprn_reserve   => l_backlog_deprn_reserve ,
                           x_general_fund            => l_general_fund ,
                           x_last_reval_date         => l_prd_rec.period_end_date ,
                           x_current_reval_factor    => l_current_reval_factor   ,
                           x_cumulative_reval_factor => l_cumulative_reval_factor ,
                           x_mode                    => 'R'
                   );

       		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	         	  	   p_full_path => g_path||'transfer_data',
      		         	   p_string => ' Creating rows in igi_iac_det_balances for closed period...');
                --  Create rows in igi_iac_det_balances for closed period
                --
                IF ( NOT ( Prorate_for_Det_Balances (
                            p_book_type_code          => l_corporate_book ,
                            p_category_id             => p_category_id ,
                            p_asset_id                => arec.asset_id ,
                            p_net_book_value          => l_net_book_value ,
                            p_adjusted_cost           => l_adjusted_cost ,
                            p_operating_acct          => l_operating_acct ,
                            p_reval_reserve           => l_reval_reserve ,
                            p_deprn_amount            => l_deprn_amount ,
                            p_ytd_deprn               => l_ytd_deprn ,
                            p_deprn_reserve           => l_deprn_reserve ,
                            p_backlog_deprn_reserve   => l_backlog_deprn_reserve ,
                            p_general_fund            => l_general_fund ,
                            p_prd_rec                 => l_prev_prd_rec ,
                            p_current_reval_factor    => l_current_reval_factor ,
                            p_cumulative_reval_factor => l_cumulative_reval_factor ,
                            p_adj_id                  => l_prev_out_adj_id ,
                            p_run_book                => p_book_type_code ,
                            p_op_ac_cost              => arec.operating_account_cost ,
                            p_op_ac_backlog           => arec.operating_account_backlog ,
                            p_hist_deprn_amount       => l_hist_deprn_amount,
                            p_hist_deprn_ytd          => l_hist_deprn_ytd,
                            p_hist_deprn_reserve      => l_hist_deprn_reserve,
                            p_errbuf                  => errbuf )))
                THEN
                    fnd_message.set_name ('IGI','IGI_IMP_IAC_TRF_GENERIC_ERROR');
	            igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  	            p_full_path => g_path||'transfer_data',
		                    p_remove_from_stack => FALSE);
                    errbuf := fnd_message.get;
	    	    fnd_file.put_line(fnd_file.log, errbuf);
                    raise igi_imp_tfr_error ;
                END IF;


       		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	         	  	   p_full_path => g_path||'transfer_data',
      		         	   p_string => ' Creating rows in igi_iac_det_balances ...');
                --  Create rows in igi_iac_det_balances
                --
                IF ( NOT ( Prorate_for_Det_Balances (
                            p_book_type_code          => l_corporate_book ,
                            p_category_id             => p_category_id ,
                            p_asset_id                => arec.asset_id ,
                            p_net_book_value          => l_net_book_value ,
                            p_adjusted_cost           => l_adjusted_cost ,
                            p_operating_acct          => l_operating_acct ,
                            p_reval_reserve           => l_reval_reserve ,
                            p_deprn_amount            => l_deprn_amount ,
                            p_ytd_deprn               => l_ytd_deprn ,
                            p_deprn_reserve           => l_deprn_reserve ,
                            p_backlog_deprn_reserve   => l_backlog_deprn_reserve ,
                            p_general_fund            => l_general_fund ,
                            p_prd_rec                 => l_prd_rec ,
                            p_current_reval_factor    => l_current_reval_factor ,
                            p_cumulative_reval_factor => l_cumulative_reval_factor ,
                            p_adj_id                  => l_out_adj_id ,
                            p_run_book                => p_book_type_code ,
                            p_op_ac_cost              => arec.operating_account_cost ,
                            p_op_ac_backlog           => arec.operating_account_backlog ,
                            p_hist_deprn_amount       => l_hist_deprn_amount,
                            p_hist_deprn_ytd          => l_hist_deprn_ytd,
                            p_hist_deprn_reserve      => l_hist_deprn_reserve,
                            p_errbuf                  => errbuf )))
                THEN
                    fnd_message.set_name ('IGI','IGI_IMP_IAC_TRF_GENERIC_ERROR');
	            igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  	            p_full_path => g_path||'transfer_data',
		                    p_remove_from_stack => FALSE);
                    errbuf := fnd_message.get;
	    	    fnd_file.put_line(fnd_file.log, errbuf);
                    raise igi_imp_tfr_error ;
                END IF;


       		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	         	  	   p_full_path => g_path||'transfer_data',
      		         	   p_string => 'Creating rows in igi_iac_adjustments ...');
                --  Create rows in igi_iac_adjustments
                --

                IF ( NOT ( Create_Adjustments  (
                                   l_corporate_book       ,
                                   arec.asset_id          ,
                                   l_out_adj_id            ,
                                   l_prev_prd_rec.period_counter ,
                                   errbuf  ,
                                   p_event_id  ))) THEN
                       fnd_message.set_name ('IGI','IGI_IMP_IAC_TRF_GENERIC_ERROR');
	               igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  	               p_full_path => g_path||'transfer_data',
		                       p_remove_from_stack => FALSE);
                       errbuf := fnd_message.get;
	    	       fnd_file.put_line(fnd_file.log, errbuf);
                       raise igi_imp_tfr_error ;
                END IF;

                IF ( p_book_type_code = l_corporate_book ) THEN
			BEGIN
			       SELECT  number_per_fiscal_year
			       INTO    l_num_per_fiscal_year
			       FROM    fa_calendar_types ct ,
				       fa_book_controls  bc
			       WHERE   ct.calendar_type  = bc.deprn_calendar
			       AND     bc.book_type_code = l_corporate_book ;
			EXCEPTION
			       WHEN OTHERS THEN
				   fnd_message.set_name ('IGI','IGI_IMP_IAC_TRF_GENERIC_ERROR');
	               		   igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  	               		   p_full_path => g_path||'transfer_data',
		                       		   p_remove_from_stack => FALSE);
				   errbuf := fnd_message.get;
	    			   fnd_file.put_line(fnd_file.log, errbuf);
				   raise igi_imp_tfr_error ;
			END ;
			BEGIN
			       SELECT  period_num_for_catchup
			       INTO    l_period_num_for_catchup
			       FROM    igi_iac_book_controls ib
			       WHERE   ib.book_type_code = l_corporate_book ;
			EXCEPTION
			       WHEN OTHERS THEN
				   fnd_message.set_name ('IGI','IGI_IMP_IAC_TRF_GENERIC_ERROR');
	               		   igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  	               		   p_full_path => g_path||'transfer_data',
		                       		   p_remove_from_stack => FALSE);
				   errbuf := fnd_message.get;
	    			   fnd_file.put_line(fnd_file.log, errbuf);
				   raise igi_imp_tfr_error ;
			END ;

			IF    (  l_prev_prd_rec.period_num < l_period_num_for_catchup ) THEN
				l_period_for_rates := l_prev_prd_rec.period_counter -
					    ( l_num_per_fiscal_year + l_prev_prd_rec.period_num - l_period_num_for_catchup ) ;
			ELSIF (  l_prev_prd_rec.period_num > l_period_num_for_catchup ) THEN
			       l_period_for_rates := l_prev_prd_rec.period_counter -
					    ( l_prev_prd_rec.period_num - l_period_num_for_catchup ) ;
			ELSIF  (  l_prev_prd_rec.period_num = l_period_num_for_catchup ) THEN
			       l_period_for_rates := l_prev_prd_rec.period_counter  ;
			END IF;
                ELSE
                        --
                        -- IF this was a tax book then the revaluation will have been run till the last closed period
                        --
			l_period_for_rates := l_prev_prd_rec.period_counter  ;
                END IF;


       		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	         	  	   p_full_path => g_path||'transfer_data',
      		         	   p_string => 'Creating rows in igi_iac_revaluation_rates ...');
                --  Create rows in igi_iac_revaluation_rates
                --
                BEGIN
                        INSERT INTO igi_iac_revaluation_rates
                           (
                           ASSET_ID                 ,
                           BOOK_TYPE_CODE            ,
                           REVALUATION_ID            ,
                           PERIOD_COUNTER            ,
                           REVAL_TYPE                ,
                           CURRENT_REVAL_FACTOR      ,
                           CUMULATIVE_REVAL_FACTOR   ,
                           PROCESSED_FLAG            ,
                           LATEST_RECORD             ,
                           CREATED_BY                ,
                           CREATION_DATE             ,
                           LAST_UPDATE_LOGIN         ,
                           LAST_UPDATE_DATE          ,
                           LAST_UPDATED_BY           ,
                           ADJUSTMENT_ID
                           )
                        VALUES
                           (
                           arec.asset_id             ,
                           l_corporate_book          ,
                           l_out_reval_id            ,
                           l_period_for_rates        ,
                           'P'                       ,
                           l_current_reval_factor    ,
                           l_cumulative_reval_factor ,
                           'Y'                       ,
                           'Y'                       ,
                           fnd_global.user_id        ,
                           sysdate                   ,
                           fnd_global.login_id       ,
                           sysdate                   ,
                           fnd_global.user_id        ,
                           l_out_adj_id
                           );
                EXCEPTION
                    WHEN OTHERS THEN
	               igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		         	          p_full_path => g_path||'transfer_data',
		         	          p_string => 'Error : Creating rows in igi_iac_revaluation_rates ...'
						      ||sqlerrm);
                       fnd_message.set_name ('IGI','IGI_IMP_IAC_TRF_GENERIC_ERROR');
	               igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  	               p_full_path => g_path||'transfer_data',
		                       p_remove_from_stack => FALSE);
                       errbuf := fnd_message.get;
	    	       fnd_file.put_line(fnd_file.log, errbuf);
                       raise igi_imp_tfr_error ;
                END;


       		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	         	  	   p_full_path => g_path||'transfer_data',
      		         	   p_string => '>>Processed Asset ID : '|| arec.asset_id ) ;

            UPDATE igi_imp_iac_interface --Fix for Bug 5137813
            SET    transferred_flag = 'Y'
            WHERE  book_type_code = arec.book_type_code
            AND    asset_id = arec.asset_id;

       END LOOP ;

       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
         	  	  p_full_path => g_path||'transfer_data',
      		          p_string => 'Updating igi_iac_category_books run details...');
       -- Updating igi_iac_category_books run details...
       --
       UPDATE igi_iac_category_books c
       SET     c.imp_run_number     =  nvl(c.imp_run_number  ,0) + 1 ,
               c.imp_period_counter =  l_prd_rec.period_counter ,
               c.imp_date           =  sysdate
       WHERE   c.book_type_code     =  l_corporate_book
       AND     c.category_id        =  p_category_id ;

       IF ( SQL%ROWCOUNT = 0 ) THEN
	    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
	        	       p_full_path => g_path||'transfer_data',
		               p_string => ' ERROR -> Updating igi_iac_category_books ...'|| sqlerrm );
            fnd_message.set_name ('IGI','IGI_IMP_IAC_TRF_GENERIC_ERROR');
	    igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  	    p_full_path => g_path||'transfer_data',
		            p_remove_from_stack => FALSE);
            errbuf := fnd_message.get;
	    fnd_file.put_line(fnd_file.log, errbuf);
            raise igi_imp_tfr_error ;
       ELSE
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
         	  	       p_full_path => g_path||'transfer_data',
      		               p_string => SQL%rowcount || ' rows updated.');
       END IF;


       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
         	  	  p_full_path => g_path||'transfer_data',
      		          p_string => 'Setting Transfer Status to Completed ...');

        IF (l_assets_valid) THEN --Fix for Bug 5137813
            -- Update the transferred status to COMPLETED 'C'
            set_interface_ctrl_status( p_book_type_code ,
                                      p_category_id    ,
                                      'C' );

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => g_path||'transfer_data',
            p_string => '*********** Transfer Successfully Completed ... **********');

            retcode := 0 ;

        ELSE
            set_interface_ctrl_status( p_book_type_code ,
                                      p_category_id    ,
                                      'N' );
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => g_path||'transfer_data',
            p_string => '*********** Transfer Partially Completed ... **********');

            retcode := 1 ;

        END IF;

       COMMIT WORK;

       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
         	  	  p_full_path => g_path||'transfer_data',
      		          p_string => '*********** Transfer Successfully Completed ... **********');


       RETURN ;

    EXCEPTION
           WHEN igi_imp_tfr_error THEN
	       ROLLBACK WORK ;
	       IF ( l_reserved_flag = 'Y' ) THEN
		      set_interface_ctrl_status( p_book_type_code ,
						 p_category_id    ,
						 'E' );
		      COMMIT WORK;
	       END IF;
	       retcode := 2 ;
	       RETURN ;
	   WHEN OTHERS THEN
	       ROLLBACK WORK ;
  	       igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => g_path||'transfer_data');
	       IF ( l_reserved_flag = 'Y' ) THEN
		      set_interface_ctrl_status( p_book_type_code ,
						 p_category_id    ,
						 'E' );
		      COMMIT WORK;
	       END IF;
	       retcode := 0 ;
	       RETURN  ;


    END ; -- procedure transfer_data

BEGIN
 --===========================FND_LOG.START=====================================

 g_state_level 	     :=	FND_LOG.LEVEL_STATEMENT;
 g_proc_level  	     :=	FND_LOG.LEVEL_PROCEDURE;
 g_event_level 	     :=	FND_LOG.LEVEL_EVENT;
 g_excep_level 	     :=	FND_LOG.LEVEL_EXCEPTION;
 g_error_level 	     :=	FND_LOG.LEVEL_ERROR;
 g_unexp_level 	     :=	FND_LOG.LEVEL_UNEXPECTED;
 g_path              := 'IGI.PLSQL.igiimtdb.igi_imp_iac_transfer_pkg.';
 --===========================FND_LOG.END=====================================


END ; --package body

/
